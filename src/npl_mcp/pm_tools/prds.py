"""PRD MCP tools.

Implements FR-003 (get_prd), FR-004 (get_prd_functional_requirement),
and FR-005 (get_prd_acceptance_test).
"""

import json
import re
from pathlib import Path
from typing import Any, Dict, List, Optional

from .exceptions import NotFoundError, ValidationError, ParseError
from .utils import (
    load_yaml_index,
    normalize_prd_id,
    normalize_fr_id,
    normalize_at_id,
    extract_prd_metadata,
    extract_user_story_references,
    extract_list_items,
    get_project_root,
)


def _get_prds_dir(prds_dir: Optional[Path] = None) -> Path:
    """Get the PRDs directory path."""
    if prds_dir is not None:
        return prds_dir
    return get_project_root() / "project-management" / "PRDs"


def _find_prd_file(prds_dir: Path, prd_id: str) -> Optional[Path]:
    """Find the PRD file matching the given ID.

    PRDs are discovered by glob pattern: PRD-XXX-*.md

    Args:
        prds_dir: Directory containing PRDs
        prd_id: Normalized PRD ID (e.g., "PRD-015")

    Returns:
        Path to PRD file if found, None otherwise
    """
    # Search for files matching pattern
    pattern = f"{prd_id}-*.md"
    matches = list(prds_dir.glob(pattern))

    # Also try exact match without suffix
    exact = prds_dir / f"{prd_id}.md"
    if exact.exists():
        matches.append(exact)

    if matches:
        return matches[0]
    return None


def _find_supporting_directory(prds_dir: Path, prd_id: str, prd_file: Path) -> Optional[Path]:
    """Find the supporting directory for a PRD.

    Supporting directories are named like the PRD file without .md extension.

    Args:
        prds_dir: Directory containing PRDs
        prd_id: Normalized PRD ID
        prd_file: Path to the PRD markdown file

    Returns:
        Path to supporting directory if found, None otherwise
    """
    # Try directory named after the file (without .md)
    dir_name = prd_file.stem
    support_dir = prds_dir / dir_name
    if support_dir.is_dir():
        return support_dir

    # Try pattern PRD-XXX-*/ (directory)
    for d in prds_dir.iterdir():
        if d.is_dir() and d.name.startswith(prd_id):
            return d

    return None


def _count_items_in_dir(directory: Path, file_pattern: str, index_key: str) -> int:
    """Count items in a directory by index or file glob.

    Args:
        directory: Directory to search
        file_pattern: Glob pattern for files (e.g., "FR-*.md")
        index_key: Key in index.yaml containing items list

    Returns:
        Count of items
    """
    if not directory.exists():
        return 0

    # Try index.yaml first
    index_path = directory / "index.yaml"
    if index_path.exists():
        try:
            index_data = load_yaml_index(index_path)
            items = index_data.get(index_key, [])
            return len(items)
        except:
            pass

    # Fall back to file glob
    files = list(directory.glob(file_pattern))
    return len(files)


async def get_prd(prd_id: str, *, prds_dir: Optional[Path] = None) -> str:
    """Load a PRD by ID.

    Args:
        prd_id: PRD ID (e.g., "PRD-005" or "005" or "5")
        prds_dir: Optional override for PRDs directory (for testing)

    Returns:
        JSON-formatted string containing PRD data

    Raises:
        NotFoundError: If PRD not found
        ValidationError: If PRD ID format is invalid
    """
    # Normalize and validate PRD ID
    try:
        normalized_id = normalize_prd_id(prd_id)
    except ValidationError:
        raise

    dir_path = _get_prds_dir(prds_dir)

    # Find PRD file
    prd_file = _find_prd_file(dir_path, normalized_id)
    if prd_file is None:
        raise NotFoundError(f"PRD '{normalized_id}' not found")

    # Read content
    content = prd_file.read_text(encoding='utf-8')

    # Extract metadata
    metadata = extract_prd_metadata(content)

    # Find supporting directory
    support_dir = _find_supporting_directory(dir_path, normalized_id, prd_file)

    # Check for functional requirements and acceptance tests
    has_frs = False
    has_ats = False
    fr_count = 0
    at_count = 0

    if support_dir:
        fr_dir = support_dir / "functional-requirements"
        at_dir = support_dir / "acceptance-tests"

        has_frs = fr_dir.exists()
        has_ats = at_dir.exists()

        if has_frs:
            fr_count = _count_items_in_dir(fr_dir, "FR-*.md", "functional_requirements")

        if has_ats:
            at_count = _count_items_in_dir(at_dir, "AT-*.md", "acceptance_tests")

    # Extract user story references
    user_stories = extract_user_story_references(content)

    result: Dict[str, Any] = {
        "id": normalized_id,
        "title": metadata.get("title"),
        "file": str(prd_file.name),
        "status": metadata.get("status"),
        "version": metadata.get("version"),
        "content": content,
        "supporting_directory": str(support_dir.name) if support_dir else None,
        "has_functional_requirements": has_frs,
        "has_acceptance_tests": has_ats,
        "functional_requirements_count": fr_count,
        "acceptance_tests_count": at_count,
        "user_stories": user_stories,
    }

    return json.dumps(result, indent=2)


async def get_prd_functional_requirement(
    prd_id: str,
    fr_id: str = "*",
    *,
    prds_dir: Optional[Path] = None
) -> str:
    """Access PRD functional requirements.

    Args:
        prd_id: PRD ID (e.g., "PRD-005")
        fr_id: FR ID (e.g., "FR-003") or "*" to list all
        prds_dir: Optional override for PRDs directory (for testing)

    Returns:
        JSON-formatted string containing FR data or list

    Raises:
        NotFoundError: If PRD or FR not found
        ValidationError: If ID format is invalid
    """
    # Normalize PRD ID
    try:
        normalized_prd_id = normalize_prd_id(prd_id)
    except ValidationError:
        raise

    dir_path = _get_prds_dir(prds_dir)

    # Find PRD file to confirm it exists
    prd_file = _find_prd_file(dir_path, normalized_prd_id)
    if prd_file is None:
        raise NotFoundError(f"PRD '{normalized_prd_id}' not found")

    # Find supporting directory
    support_dir = _find_supporting_directory(dir_path, normalized_prd_id, prd_file)
    if support_dir is None:
        # No supporting directory - return empty list
        if fr_id == "*":
            return json.dumps({
                "prd_id": normalized_prd_id,
                "total_count": 0,
                "functional_requirements": [],
            }, indent=2)
        else:
            raise NotFoundError(
                f"Functional requirement '{normalize_fr_id(fr_id)}' not found in PRD '{normalized_prd_id}'"
            )

    fr_dir = support_dir / "functional-requirements"
    if not fr_dir.exists():
        if fr_id == "*":
            return json.dumps({
                "prd_id": normalized_prd_id,
                "total_count": 0,
                "functional_requirements": [],
            }, indent=2)
        else:
            raise NotFoundError(
                f"Functional requirement '{normalize_fr_id(fr_id)}' not found in PRD '{normalized_prd_id}'"
            )

    # Load FR data from index or discover via glob
    fr_data_list = _load_fr_data(fr_dir)

    if fr_id == "*":
        # List all FRs
        summaries = []
        for fr in fr_data_list:
            summaries.append({
                "fr_id": fr.get("id"),
                "title": fr.get("title"),
                "status": fr.get("status", "documented"),
                "priority": fr.get("priority", "medium"),
                "file": fr.get("file"),
            })

        return json.dumps({
            "prd_id": normalized_prd_id,
            "total_count": len(summaries),
            "functional_requirements": summaries,
        }, indent=2)
    else:
        # Get specific FR
        normalized_fr_id = normalize_fr_id(fr_id)

        fr_entry = None
        for fr in fr_data_list:
            if fr.get("id") == normalized_fr_id:
                fr_entry = fr
                break

        if fr_entry is None:
            raise NotFoundError(
                f"Functional requirement '{normalized_fr_id}' not found in PRD '{normalized_prd_id}'"
            )

        # Load content from file
        file_name = fr_entry.get("file")
        content = ""
        if file_name:
            file_path = fr_dir / file_name
            if file_path.exists():
                content = file_path.read_text(encoding='utf-8')

        return json.dumps({
            "prd_id": normalized_prd_id,
            "fr_id": normalized_fr_id,
            "title": fr_entry.get("title"),
            "file": file_name,
            "status": fr_entry.get("status", "documented"),
            "priority": fr_entry.get("priority", "medium"),
            "content": content,
        }, indent=2)


def _load_fr_data(fr_dir: Path) -> List[Dict[str, Any]]:
    """Load functional requirements data from directory.

    Tries index.yaml first, falls back to glob discovery.

    Args:
        fr_dir: Functional requirements directory

    Returns:
        List of FR data dictionaries
    """
    index_path = fr_dir / "index.yaml"

    if index_path.exists():
        try:
            index_data = load_yaml_index(index_path)
            return index_data.get("functional_requirements", [])
        except:
            pass

    # Fall back to glob discovery
    fr_files = sorted(fr_dir.glob("FR-*.md"))
    result = []
    for f in fr_files:
        # Extract ID from filename (e.g., FR-001-user-story-reader.md -> FR-001)
        match = re.match(r'(FR-\d+)', f.stem)
        if match:
            fr_id = match.group(1)
            # Try to extract title from file
            content = f.read_text(encoding='utf-8')
            title_match = re.match(r'^#\s*FR-\d+:\s*(.+)$', content, re.MULTILINE)
            title = title_match.group(1).strip() if title_match else f.stem

            result.append({
                "id": fr_id,
                "title": title,
                "file": f.name,
                "status": "documented",
                "priority": "medium",
            })

    return result


async def get_prd_acceptance_test(
    prd_id: str,
    at_id: str = "*",
    fr_id: Optional[str] = None,
    *,
    prds_dir: Optional[Path] = None
) -> str:
    """Access PRD acceptance tests.

    Args:
        prd_id: PRD ID (e.g., "PRD-005")
        at_id: AT ID (e.g., "AT-003") or "*" to list all
        fr_id: Optional FR ID to filter ATs by functional requirement
        prds_dir: Optional override for PRDs directory (for testing)

    Returns:
        JSON-formatted string containing AT data or list

    Raises:
        NotFoundError: If PRD or AT not found
        ValidationError: If ID format is invalid
    """
    # Normalize PRD ID
    try:
        normalized_prd_id = normalize_prd_id(prd_id)
    except ValidationError:
        raise

    dir_path = _get_prds_dir(prds_dir)

    # Find PRD file to confirm it exists
    prd_file = _find_prd_file(dir_path, normalized_prd_id)
    if prd_file is None:
        raise NotFoundError(f"PRD '{normalized_prd_id}' not found")

    # Find supporting directory
    support_dir = _find_supporting_directory(dir_path, normalized_prd_id, prd_file)

    # Check for acceptance tests directory
    at_dir = support_dir / "acceptance-tests" if support_dir else None

    if at_dir is None or not at_dir.exists():
        if at_id == "*":
            return json.dumps({
                "prd_id": normalized_prd_id,
                "total_count": 0,
                "implemented_count": 0,
                "coverage_percentage": 0.0,
                "acceptance_tests": [],
            }, indent=2)
        else:
            raise NotFoundError(
                f"Acceptance test '{normalize_at_id(at_id)}' not found in PRD '{normalized_prd_id}'"
            )

    # Load AT data from index or discover via glob
    at_data_list = _load_at_data(at_dir)

    # Apply FR filter if provided
    if fr_id:
        normalized_fr_id = normalize_fr_id(fr_id)
        at_data_list = [at for at in at_data_list if at.get("fr_id") == normalized_fr_id]

    if at_id == "*":
        # List all ATs with coverage stats
        summaries = []
        implemented_count = 0

        for at in at_data_list:
            impl_status = at.get("implementation_status", "not_implemented")
            if impl_status == "implemented":
                implemented_count += 1

            summaries.append({
                "at_id": at.get("id"),
                "title": at.get("title"),
                "fr_id": at.get("fr_id"),
                "status": at.get("status", "documented"),
                "test_type": at.get("test_type", "unit"),
                "implementation_status": impl_status,
                "file": at.get("file"),
            })

        total = len(summaries)
        coverage = (implemented_count / total * 100) if total > 0 else 0.0

        return json.dumps({
            "prd_id": normalized_prd_id,
            "total_count": total,
            "implemented_count": implemented_count,
            "coverage_percentage": round(coverage, 2),
            "acceptance_tests": summaries,
        }, indent=2)
    else:
        # Get specific AT
        normalized_at_id = normalize_at_id(at_id)

        at_entry = None
        for at in at_data_list:
            if at.get("id") == normalized_at_id:
                at_entry = at
                break

        if at_entry is None:
            raise NotFoundError(
                f"Acceptance test '{normalized_at_id}' not found in PRD '{normalized_prd_id}'"
            )

        # Load content from file
        file_name = at_entry.get("file")
        content = ""
        if file_name:
            file_path = at_dir / file_name
            if file_path.exists():
                content = file_path.read_text(encoding='utf-8')

        # Parse structured test data
        preconditions = extract_list_items(content, "Preconditions")
        steps = extract_list_items(content, "Steps")
        expected_results = extract_list_items(content, "Expected Results")

        return json.dumps({
            "prd_id": normalized_prd_id,
            "at_id": normalized_at_id,
            "title": at_entry.get("title"),
            "file": file_name,
            "fr_id": at_entry.get("fr_id"),
            "status": at_entry.get("status", "documented"),
            "test_type": at_entry.get("test_type", "unit"),
            "implementation_status": at_entry.get("implementation_status", "not_implemented"),
            "content": content,
            "preconditions": preconditions,
            "steps": steps,
            "expected_results": expected_results,
        }, indent=2)


def _load_at_data(at_dir: Path) -> List[Dict[str, Any]]:
    """Load acceptance tests data from directory.

    Tries index.yaml first, falls back to glob discovery.

    Args:
        at_dir: Acceptance tests directory

    Returns:
        List of AT data dictionaries
    """
    index_path = at_dir / "index.yaml"

    if index_path.exists():
        try:
            index_data = load_yaml_index(index_path)
            return index_data.get("acceptance_tests", [])
        except:
            pass

    # Fall back to glob discovery
    at_files = sorted(at_dir.glob("AT-*.md"))
    result = []
    for f in at_files:
        # Extract ID from filename (e.g., AT-001-get-story-basic.md -> AT-001)
        match = re.match(r'(AT-\d+)', f.stem)
        if match:
            at_id = match.group(1)
            # Try to extract title from file
            content = f.read_text(encoding='utf-8')
            title_match = re.match(r'^#\s*AT-\d+:\s*(.+)$', content, re.MULTILINE)
            title = title_match.group(1).strip() if title_match else f.stem

            result.append({
                "id": at_id,
                "title": title,
                "file": f.name,
                "status": "documented",
                "test_type": "unit",
                "implementation_status": "not_implemented",
            })

    return result
