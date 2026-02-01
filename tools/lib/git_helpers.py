# tools/lib/git_helpers.py
"""Shared helper functions for the tools package.

Provides utilities to locate the git repository root, resolve a target path (file or
folder) relative to that repository, and list files tracked by git (including
untracked files that are not ignored).
"""

import os
import subprocess
from typing import List, Tuple


def get_git_root() -> str:
    """Return the absolute path to the git repository root.

    Raises:
        RuntimeError: If the current directory is not inside a git repository.
    """
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as exc:
        raise RuntimeError("Not inside a git repository") from exc


def resolve_target(target: str) -> Tuple[str, str]:
    """Resolve ``target`` to an absolute directory and a relative path.

    Args:
        target: Path to a directory or a file.

    Returns:
        A tuple ``(target_dir, target_rel)`` where ``target_dir`` is the absolute
        path to the directory containing the target and ``target_rel`` is the
        basename of the target if it is a file, otherwise ``"."``.

    Raises:
        FileNotFoundError: If ``target`` does not exist.
    """
    if not target:
        raise ValueError("Target path must be provided")

    if os.path.isdir(target):
        target_dir = os.path.abspath(target)
        target_rel = "."
    elif os.path.isfile(target):
        target_dir = os.path.abspath(os.path.dirname(target))
        target_rel = os.path.basename(target)
    else:
        raise FileNotFoundError(f"Target does not exist: {target}")

    return target_dir, target_rel


def _relative_to_root(path: str, root: str) -> str:
    """Return ``path`` relative to ``root`` using POSIX separators.

    If ``path`` is the same as ``root`` the function returns ``"."``.
    """
    # Normalise to absolute paths
    path = os.path.abspath(path)
    root = os.path.abspath(root)
    if path == root:
        return "."
    # ``os.path.relpath`` uses the OS separator; we convert to POSIX for git.
    rel = os.path.relpath(path, root)
    return rel.replace(os.sep, "/")


def list_git_files(relative_path: str) -> List[str]:
    """List git‑tracked and untracked‑but‑not‑ignored files under ``relative_path``.

    Args:
        relative_path: Path relative to the repository root ("." for the root).

    Returns:
        A list of file paths using POSIX separators.
    """
    # Ensure we use POSIX separators for git commands.
    rel = relative_path.replace(os.sep, "/")
    cmd = [
        "git",
        "-c",
        "core.quotepath=false",
        "ls-files",
        "--cached",
        "--others",
        "--exclude-standard",
        rel,
    ]
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        check=True,
    )
    # ``git ls-files`` returns one file per line; filter empty lines.
    files = [line for line in result.stdout.splitlines() if line]
    return files
