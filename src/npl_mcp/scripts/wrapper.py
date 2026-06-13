"""Async wrappers for NPL script tools — PRD-008.

Each function wraps either a subprocess-based CLI tool or an existing
NPL/browser library function, providing a uniform async interface callable
via the catalog's ToolCall dispatcher.
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path
from typing import Optional, Union


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _project_root() -> Path:
    """Return the project root (parent of src/)."""
    return Path(__file__).resolve().parents[3]


def _run_tool_script(script_name: str, *args: str) -> str:
    """Run a tools/ script as a subprocess and return captured stdout.

    The script is run with the project root as the working directory so that
    ``tools.lib.git_helpers`` can locate the git repository correctly.

    Args:
        script_name: Module name relative to project root, e.g. ``"tools.git_dump"``.
        *args: Positional arguments forwarded to the script.

    Returns:
        Captured stdout as a string.

    Raises:
        RuntimeError: If the subprocess exits with a non-zero status.
    """
    root = _project_root()
    cmd = [sys.executable, "-m", script_name, *args]
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        cwd=str(root),
    )
    if result.returncode != 0:
        stderr = result.stderr.strip()
        raise RuntimeError(stderr or f"{script_name} exited with code {result.returncode}")
    return result.stdout


# ---------------------------------------------------------------------------
# Public async wrappers
# ---------------------------------------------------------------------------

async def dump_files(
    path: str,
    glob_filter: Optional[str] = None,
) -> Union[str, dict]:
    """Dump file contents from a directory, respecting .gitignore.

    Wraps ``tools/git_dump.py`` (registered as the ``git-dump`` console script).
    Files are printed with a path header and ``* * *`` separator between them.

    Args:
        path: Absolute (or relative) path to the directory to dump.
        glob_filter: Optional glob pattern to filter files (currently passed as
            the target path to the underlying git-dump script; future versions
            may support explicit glob filtering).

    Returns:
        Captured output as a string, or ``{"error": "..."}`` on failure.
    """
    target = glob_filter if glob_filter else path
    try:
        return _run_tool_script("tools.git_dump", target)
    except Exception as exc:
        return {"error": str(exc)}


async def git_tree(path: str = ".") -> Union[str, dict]:
    """Display a directory tree respecting .gitignore.

    Wraps ``tools/git_tree.py``.  Uses the external ``tree`` command when
    available, otherwise falls back to a pure-Python implementation.

    Args:
        path: Absolute (or relative) path to the directory to render
            (default: current working directory).

    Returns:
        Tree output as a string, or ``{"error": "..."}`` on failure.
    """
    try:
        return _run_tool_script("tools.git_tree", path)
    except Exception as exc:
        return {"error": str(exc)}


async def git_tree_depth(path: str) -> Union[str, dict]:
    """List directory tree with depth information, respecting .gitignore.

    Reuses ``git_tree`` to obtain the file listing and annotates each entry
    with its nesting depth (0 = root-level item inside *path*).

    Args:
        path: Absolute (or relative) path to the directory to inspect.

    Returns:
        Annotated tree output as a string, or ``{"error": "..."}`` on failure.
    """
    try:
        raw = _run_tool_script("tools.git_tree", path)
    except Exception as exc:
        return {"error": str(exc)}

    # Annotate with depth based on indentation of each line.
    lines = raw.splitlines()
    annotated: list[str] = []
    for line in lines:
        # Count leading spaces to derive depth (4 spaces per level in fallback,
        # or box-drawing prefix: "│   " / "    " = 4 chars per level).
        stripped = line.lstrip()
        indent = len(line) - len(stripped)
        depth = indent // 4
        if stripped and stripped not in (".", ".."):
            annotated.append(f"[depth={depth}] {line}")
        else:
            annotated.append(line)

    return "\n".join(annotated)


async def npl_load(
    resource_type: str,
    items: str,
    skip: Optional[str] = None,
) -> Union[str, dict]:
    """Load NPL components, metadata, or style guides.

    Thin wrapper around ``npl_mcp.npl.loader.load_npl``.  The ``resource_type``
    parameter maps historical CLI flags to NPL expression prefixes:

    * ``"c"`` / ``"core"`` — load ``items`` as a bare expression (e.g. ``"syntax"``)
    * ``"s"`` / ``"syntax"`` / ``"style"`` — same as core
    * ``"m"`` / ``"metadata"`` — prefix ``items`` with ``"metadata"`` context
    * ``"agent"`` — prefix ``items`` with ``"agent"`` context
    * anything else — pass ``items`` directly to ``load_npl``

    Args:
        resource_type: Resource class to load (``"c"``, ``"s"``, ``"m"``, ``"agent"``, …).
        items: Comma-separated NPL components or a full NPL expression.
        skip: Optional comma-separated components to omit (passed as exclusions
            in the expression via ``-section#component`` syntax).

    Returns:
        Markdown-formatted NPL content string, or ``{"error": "..."}`` on failure.
    """
    from npl_mcp.npl.loader import load_npl
    from npl_mcp.npl.exceptions import NPLParseError, NPLResolveError, NPLLoadError

    # Normalise resource_type
    rt = resource_type.lower().strip()

    # Build exclusion suffix
    exclusions = ""
    if skip:
        parts = [s.strip() for s in skip.split(",") if s.strip()]
        exclusions = " " + " ".join(f"-{p}" for p in parts)

    # Build expression
    if rt in {"c", "core", "s", "syntax", "style"}:
        expression = items.strip() + exclusions
    elif rt in {"m", "metadata"}:
        # Prepend metadata qualifier so resolver looks in metadata files
        expression = f"metadata {items.strip()}{exclusions}"
    elif rt in {"agent"}:
        expression = f"agent {items.strip()}{exclusions}"
    else:
        # Generic fallback — treat items as a full expression
        expression = items.strip() + exclusions

    try:
        return load_npl(expression)
    except (NPLParseError, NPLResolveError, NPLLoadError) as exc:
        return {"error": str(exc)}
    except Exception as exc:
        return {"error": f"Unexpected error loading NPL: {exc}"}


async def web_to_md(
    url: str,
    timeout: Optional[int] = None,  # noqa: ARG001 — reserved for future use
) -> Union[dict, str]:
    """Fetch a web page and return its content as markdown via Jina Reader.

    Thin wrapper around ``npl_mcp.browser.to_markdown.to_markdown``.

    Args:
        url: The URL of the web page to fetch and convert.
        timeout: Request timeout in seconds (currently informational only;
            the underlying converter uses its own default timeout).

    Returns:
        Dict with ``content``, ``source``, and metadata keys on success, or
        ``{"error": "..."}`` on failure.
    """
    from npl_mcp.browser.to_markdown import to_markdown

    try:
        return await to_markdown(url)
    except Exception as exc:
        return {"error": str(exc)}
