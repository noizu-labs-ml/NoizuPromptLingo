# tools/git_dump.py
"""Python implementation of the ``dump-files`` script, renamed to ``git-dump``.

The script dumps the contents of all files under a given target path in a git
repository, respecting .gitignore. Output format matches the original bash
script:

    # <path>
    ---
    <file contents>
    * * *
"""

import argparse
import os
import sys
from typing import List

# Import shared helpers
from tools.lib.git_helpers import get_git_root, resolve_target, list_git_files


def _print_file_header(path: str) -> None:
    sys.stdout.write(f"\n# {path}\n---\n")


def _print_separator() -> None:
    sys.stdout.write("\n* * *\n")


def _stream_file(file_path: str) -> None:
    """Stream file contents to stdout.

    Attempts to read the file as UTF‑8 text; on decoding errors the raw bytes are
    written to ``sys.stdout.buffer``.
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            for line in f:
                sys.stdout.write(line)
    except UnicodeDecodeError:
        # Fallback to binary mode
        with open(file_path, "rb") as bf:
            for chunk in iter(lambda: bf.read(8192), b""):
                sys.stdout.buffer.write(chunk)
    except Exception as exc:
        # Print an error but continue processing other files
        sys.stderr.write(f"Error reading {file_path}: {exc}\n")


def main() -> None:
    parser = argparse.ArgumentParser(description="Dump files from a git repository")
    parser.add_argument("target", help="Path to a directory or file inside the repository")
    args = parser.parse_args()

    # Ensure we are inside a git repository
    try:
        repo_root = get_git_root()
    except RuntimeError as exc:
        sys.stderr.write(str(exc) + "\n")
        sys.exit(1)

    # Resolve target and compute git‑relative path
    try:
        target_dir, target_rel = resolve_target(args.target)
    except Exception as exc:
        sys.stderr.write(str(exc) + "\n")
        sys.exit(1)

    # Compute relative path from repo root to the target (file or directory)
    abs_target_path = os.path.join(target_dir, target_rel) if target_rel != "." else target_dir
    rel_path = os.path.relpath(abs_target_path, repo_root).replace(os.sep, "/")

    # List files via git
    try:
        files: List[str] = list_git_files(rel_path)
    except Exception as exc:
        sys.stderr.write(f"Failed to list git files: {exc}\n")
        sys.exit(1)

    # Dump each file
    for file_path in files:
        _print_file_header(file_path)
        full_path = os.path.join(repo_root, file_path)
        _stream_file(full_path)
        _print_separator()

    # Exit cleanly
    sys.exit(0)


if __name__ == "__main__":
    main()
