# tools/git_tree.py
"""Python implementation of the ``git-tree`` script.

The script displays a directory tree of files in a git repository, respecting
.gitignore. It first attempts to use the external ``tree`` command; if that is not
available it falls back to a pure‑Python implementation.
"""

import argparse
import os
import shutil
import subprocess
import sys
from typing import Dict, List

# Shared helpers
from tools.lib.git_helpers import get_git_root, resolve_target, list_git_files


def _build_tree(file_paths: List[str]) -> Dict:
    """Build a nested dictionary representing the directory hierarchy.

    Each key is a directory or file name; directories map to another dict, while
    files map to an empty dict.
    """
    root: Dict = {}
    for path in file_paths:
        parts = path.split('/')
        cur = root
        for part in parts:
            cur = cur.setdefault(part, {})
    return root


def _print_tree(node: Dict, prefix: str = "") -> None:
    """Recursively print the tree using Unicode box‑drawing characters.

    ``node`` is a dict where keys are filenames or directory names and values are
    nested dicts (empty for leaf files).
    """
    entries = sorted(node.keys())
    for i, name in enumerate(entries):
        is_last = i == len(entries) - 1
        connector = "└── " if is_last else "├── "
        sys.stdout.write(f"{prefix}{connector}{name}\n")
        child = node[name]
        if child:
            extension = "    " if is_last else "│   "
            _print_tree(child, prefix + extension)


def _render_with_tree_cmd(files: List[str]) -> None:
    """Render the tree using the external ``tree`` command.

    The ``tree`` command expects a list of file paths on stdin with the ``--fromfile``
    flag.
    """
    try:
        proc = subprocess.Popen(
            ["tree", "--fromfile"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        stdout, stderr = proc.communicate("\n".join(files))
        if proc.returncode == 0:
            sys.stdout.write(stdout)
        else:
            sys.stderr.write(stderr)
    except Exception as exc:
        sys.stderr.write(f"Failed to run tree command: {exc}\n")
        # Fallback to Python implementation
        _render_fallback(files)


def _render_fallback(files: List[str]) -> None:
    """Pure‑Python fallback rendering.

    Prints a leading ``.`` line to match the original bash fallback.
    """
    sys.stdout.write(".\n")
    tree = _build_tree(files)
    _print_tree(tree)


def main() -> None:
    parser = argparse.ArgumentParser(description="Display a git‑aware directory tree")
    parser.add_argument("target", nargs="?", default=".", help="Target folder (default: .)")
    args = parser.parse_args()

    # Ensure we are inside a git repository
    try:
        repo_root = get_git_root()
    except RuntimeError as exc:
        sys.stderr.write(str(exc) + "\n")
        sys.exit(1)

    # Resolve target path
    try:
        target_dir, target_rel = resolve_target(args.target)
    except Exception as exc:
        sys.stderr.write(str(exc) + "\n")
        sys.exit(1)

    # Compute path relative to repository root
    abs_target_path = os.path.join(target_dir, target_rel) if target_rel != "." else target_dir
    rel_path = os.path.relpath(abs_target_path, repo_root).replace(os.sep, "/")

    # List files via git
    try:
        files = list_git_files(rel_path)
    except Exception as exc:
        sys.stderr.write(f"Failed to list git files: {exc}\n")
        sys.exit(1)

    # Render the tree
    if shutil.which("tree"):
        _render_with_tree_cmd(files)
    else:
        _render_fallback(files)

    sys.exit(0)


if __name__ == "__main__":
    main()
