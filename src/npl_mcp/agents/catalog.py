"""Agent definition catalog — parses agents/*.md.

Loads agent ``.md`` files from the top-level ``agents/`` directory.
Each file is expected to have a YAML frontmatter block followed by a
markdown body.

Exposed API
-----------
``list_agents()``
    Return lightweight metadata for every agent found (no body).

``get_agent(name)``
    Return full spec (metadata + body) for a specific agent, or ``None``.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Optional, TypedDict

import yaml


class AgentInfo(TypedDict):
    name: str                # filename stem e.g. "npl-idea-to-spec"
    display_name: str        # from frontmatter "name:" or fallback to stem
    description: str         # frontmatter description or first paragraph
    model: Optional[str]     # frontmatter model
    allowed_tools: list[str] # from frontmatter allowed-tools
    kind: str                # "pipeline" | "utility" | "executor"
    path: str                # relative to repo root e.g. "agents/npl-idea-to-spec.md"
    body_length: int         # char count of markdown body


# Default location: top-level agents/ directory
_AGENTS_DIR: Path = Path(__file__).resolve().parent.parent.parent.parent / "agents"

_FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n(.*)", re.DOTALL)


def _infer_kind(name: str) -> str:
    """Infer agent kind from its slug name."""
    if name.startswith("npl-tasker"):
        return "executor"
    if name.startswith("npl-tdd"):
        return "pipeline"
    if name in ("npl-idea-to-spec", "npl-prd-editor"):
        return "pipeline"
    return "utility"


def _first_paragraph(body: str) -> str:
    """Extract up to 300 chars of the first paragraph from body text."""
    lines = body.strip().split("\n\n")
    return lines[0][:300] if lines else ""


def _parse_file(path: Path) -> tuple[dict, str]:
    """Parse frontmatter and body from an agent .md file."""
    text = path.read_text(encoding="utf-8")
    m = _FRONTMATTER_RE.match(text)
    if m:
        try:
            meta = yaml.safe_load(m.group(1)) or {}
        except Exception:
            meta = {}
        body = m.group(2)
    else:
        meta, body = {}, text
    return meta, body


async def list_agents(agents_dir: Optional[Path] = None) -> list[AgentInfo]:
    """Return lightweight metadata for all agent .md files (no body).

    Args:
        agents_dir: Override the default agents directory (used in tests).
    """
    d = agents_dir or _AGENTS_DIR
    result: list[AgentInfo] = []
    if not d.exists():
        return result
    for path in sorted(d.glob("*.md")):
        try:
            meta, body = _parse_file(path)
        except Exception:
            meta, body = {}, ""
        stem = path.stem
        allowed = meta.get("allowed-tools", [])
        if not isinstance(allowed, list):
            allowed = []
        result.append(AgentInfo(
            name=stem,
            display_name=meta.get("name", stem),
            description=(meta.get("description", "") or "").strip() or _first_paragraph(body),
            model=meta.get("model"),
            allowed_tools=allowed,
            kind=_infer_kind(stem),
            path=f"agents/{path.name}",
            body_length=len(body),
        ))
    return result


async def get_agent(name: str, agents_dir: Optional[Path] = None) -> Optional[dict]:
    """Return full agent detail (metadata + body) for a named agent, or None.

    Matches by the filename stem (e.g. "npl-tasker-fast").

    Args:
        name: Agent slug to look up.
        agents_dir: Override the default agents directory (used in tests).
    """
    d = agents_dir or _AGENTS_DIR
    target = d / f"{name}.md"
    if not target.exists():
        return None
    try:
        meta, body = _parse_file(target)
    except Exception:
        return None
    allowed = meta.get("allowed-tools", [])
    if not isinstance(allowed, list):
        allowed = []
    info = AgentInfo(
        name=name,
        display_name=meta.get("name", name),
        description=(meta.get("description", "") or "").strip() or _first_paragraph(body),
        model=meta.get("model"),
        allowed_tools=allowed,
        kind=_infer_kind(name),
        path=f"agents/{name}.md",
        body_length=len(body),
    )
    return {**info, "body": body}
