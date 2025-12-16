"""Wrappers for NPL command-line scripts."""

import subprocess
import sys
from pathlib import Path
from typing import Optional


def _validate_absolute_path(path: str, function_name: str) -> None:
    """Validate that path is absolute, not relative.

    Args:
        path: The path to validate
        function_name: Name of the calling function for error message

    Raises:
        ValueError: If path starts with '.' (relative path)
    """
    if path.startswith("."):
        raise ValueError(
            f"{function_name}: Relative paths are not allowed. "
            f"Got '{path}'. Please pass an absolute path (e.g., '/home/user/project'). "
            f"Use pwd to get the current working directory."
        )


def _find_script(script_name: str) -> Optional[Path]:
    """Find NPL script in core/scripts directory.

    Args:
        script_name: Name of the script to find

    Returns:
        Path to script or None if not found
    """
    # Try to find script relative to project root
    possible_locations = [
        Path(__file__).parents[4] / "core" / "scripts" / script_name,  # From mcp-server
        Path.cwd() / "core" / "scripts" / script_name,  # From project root
    ]

    for location in possible_locations:
        if location.exists():
            return location

    return None


async def dump_files(path: str, glob_filter: Optional[str] = None) -> str:
    """Dump contents of files in a directory respecting .gitignore.

    Args:
        path: Directory path to dump files from (must be absolute)
        glob_filter: Optional glob pattern to filter files (e.g., "*.md")

    Returns:
        Concatenated file contents with headers

    Raises:
        ValueError: If path is relative (starts with '.')
        FileNotFoundError: If dump-files script not found
        subprocess.CalledProcessError: If script execution fails
    """
    _validate_absolute_path(path, "dump_files")
    script_path = _find_script("dump-files")
    if not script_path:
        raise FileNotFoundError("dump-files script not found in core/scripts")

    cmd = [str(script_path), path]
    if glob_filter:
        cmd.extend(["-g", glob_filter])

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        check=True
    )

    return result.stdout


async def git_tree(path: str = ".") -> str:
    """Display directory tree respecting .gitignore.

    Args:
        path: Directory path to show tree for (must be absolute)

    Returns:
        Directory tree output

    Raises:
        ValueError: If path is relative (starts with '.')
        FileNotFoundError: If git-tree script not found
        subprocess.CalledProcessError: If script execution fails
    """
    _validate_absolute_path(path, "git_tree")
    script_path = _find_script("git-tree")
    if not script_path:
        raise FileNotFoundError("git-tree script not found in core/scripts")

    result = subprocess.run(
        [str(script_path), path],
        capture_output=True,
        text=True,
        check=True
    )

    return result.stdout


async def git_tree_depth(path: str) -> str:
    """List directories with nesting depth information.

    Args:
        path: Directory path to analyze (must be absolute)

    Returns:
        Directory listing with depth numbers

    Raises:
        ValueError: If path is relative (starts with '.')
        FileNotFoundError: If git-tree-depth script not found
        subprocess.CalledProcessError: If script execution fails
    """
    _validate_absolute_path(path, "git_tree_depth")
    script_path = _find_script("git-tree-depth")
    if not script_path:
        raise FileNotFoundError("git-tree-depth script not found in core/scripts")

    result = subprocess.run(
        [str(script_path), path],
        capture_output=True,
        text=True,
        check=True
    )

    return result.stdout


async def npl_load(
    resource_type: str,
    items: str,
    skip: Optional[str] = None
) -> str:
    """Load NPL components, metadata, or style guides.

    Args:
        resource_type: Type of resource - 'c' (component), 'm' (meta), or 's' (style)
        items: Comma-separated list of items to load (supports wildcards)
        skip: Optional comma-separated list of patterns to skip

    Returns:
        Loaded NPL content with tracking flags

    Raises:
        FileNotFoundError: If npl-load script not found
        subprocess.CalledProcessError: If script execution fails
        ValueError: If invalid resource_type provided
    """
    if resource_type not in ('c', 'm', 's'):
        raise ValueError(f"Invalid resource_type: {resource_type}. Must be 'c', 'm', or 's'")

    script_path = _find_script("npl-load")
    if not script_path:
        raise FileNotFoundError("npl-load script not found in core/scripts")

    cmd = [sys.executable, str(script_path), resource_type, items]

    if skip:
        cmd.extend(["--skip", skip])

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        check=True
    )

    return result.stdout
