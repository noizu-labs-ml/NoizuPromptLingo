"""User story MCP tools.

Implements FR-001 (get_story), FR-002 (list_stories), and FR-006 (update_story_metadata).
"""

import json
import tempfile
import shutil
from pathlib import Path
from typing import Any, Dict, List, Optional

import yaml

from .exceptions import NotFoundError, ValidationError, ParseError
from .utils import (
    load_yaml_index,
    normalize_story_id,
    parse_acceptance_criteria,
    sort_by_priority,
    get_project_root,
)


# Valid values for metadata fields
VALID_STATUS_VALUES = ["draft", "in-progress", "documented", "implemented", "tested"]
VALID_PRIORITY_VALUES = ["critical", "high", "medium", "low"]
VALID_METADATA_KEYS = ["status", "priority", "prds", "related_stories", "related_personas"]


def _get_stories_dir(stories_dir: Optional[Path] = None) -> Path:
    """Get the stories directory path."""
    if stories_dir is not None:
        return stories_dir
    return get_project_root() / "project-management" / "user-stories"


async def get_story(story_id: str, *, stories_dir: Optional[Path] = None) -> str:
    """Load a user story by ID.

    Args:
        story_id: User story ID (e.g., "US-001" or "001" or "1")
        stories_dir: Optional override for stories directory (for testing)

    Returns:
        JSON-formatted string containing story data

    Raises:
        NotFoundError: If story ID not found in index
        ValidationError: If story ID format is invalid
        ParseError: If YAML parsing fails
        FileNotFoundError: If index file doesn't exist
    """
    # Normalize and validate story ID
    try:
        normalized_id = normalize_story_id(story_id)
    except ValidationError:
        raise

    # Load index
    dir_path = _get_stories_dir(stories_dir)
    index_path = dir_path / "index.yaml"
    index_data = load_yaml_index(index_path)

    # Find story in index
    stories = index_data.get("stories", [])
    story_entry = None
    for story in stories:
        if story.get("id") == normalized_id:
            story_entry = story
            break

    if story_entry is None:
        raise NotFoundError(f"User story '{normalized_id}' not found in index")

    # Build response
    result: Dict[str, Any] = {
        "id": story_entry.get("id"),
        "title": story_entry.get("title"),
        "file": story_entry.get("file"),
        "persona": story_entry.get("persona"),
        "persona_name": story_entry.get("persona_name"),
        "priority": story_entry.get("priority"),
        "status": story_entry.get("status"),
        "prd_group": story_entry.get("prd_group"),
        "prds": story_entry.get("prds", []),
        "related_stories": story_entry.get("related_stories", []),
        "related_personas": story_entry.get("related_personas", []),
    }

    # Try to load content from file
    file_name = story_entry.get("file")
    content = None
    file_exists = False

    if file_name:
        file_path = dir_path / file_name
        if file_path.exists():
            file_exists = True
            try:
                content = file_path.read_text(encoding='utf-8')
            except Exception:
                content = None

    result["content"] = content
    result["file_exists"] = file_exists

    # Add warning if file doesn't exist
    if not file_exists and file_name:
        result["warning"] = f"Story file '{file_name}' not found"

    # Parse acceptance criteria from content
    if content:
        result["acceptance_criteria"] = parse_acceptance_criteria(content)
    else:
        result["acceptance_criteria"] = []

    return json.dumps(result, indent=2)


async def list_stories(
    *,
    status: Optional[str] = None,
    priority: Optional[str] = None,
    persona: Optional[str] = None,
    prd_group: Optional[str] = None,
    prd: Optional[str] = None,
    limit: int = 50,
    offset: int = 0,
    stories_dir: Optional[Path] = None
) -> str:
    """List and filter user stories.

    Args:
        status: Filter by status (draft, in-progress, documented, implemented, tested)
        priority: Filter by priority (critical, high, medium, low)
        persona: Filter by persona ID (e.g., "P-001")
        prd_group: Filter by PRD group (e.g., "mcp_tools", "npl_load")
        prd: Filter by linked PRD (e.g., "PRD-005")
        limit: Maximum stories to return (default 50)
        offset: Number of stories to skip (default 0)
        stories_dir: Optional override for stories directory (for testing)

    Returns:
        JSON-formatted string containing list result

    Raises:
        FileNotFoundError: If index.yaml not found
        ParseError: If YAML parsing fails
    """
    dir_path = _get_stories_dir(stories_dir)
    index_path = dir_path / "index.yaml"
    index_data = load_yaml_index(index_path)

    stories = index_data.get("stories", [])

    # Apply filters (AND logic)
    filtered = []
    for story in stories:
        # Status filter
        if status is not None and story.get("status") != status:
            continue

        # Priority filter
        if priority is not None and story.get("priority") != priority:
            continue

        # Persona filter
        if persona is not None and story.get("persona") != persona:
            continue

        # PRD group filter
        if prd_group is not None and story.get("prd_group") != prd_group:
            continue

        # PRD filter (check if prd is in the prds array)
        if prd is not None:
            story_prds = story.get("prds", [])
            if prd not in story_prds:
                continue

        filtered.append(story)

    # Sort by priority
    sorted_stories = sort_by_priority(filtered)

    # Calculate totals before pagination
    total_count = len(sorted_stories)

    # Apply pagination
    offset = max(0, offset)  # Negative offset treated as 0
    paginated = sorted_stories[offset:offset + limit]

    # Build summary objects (without full content)
    story_summaries = []
    for story in paginated:
        summary = {
            "id": story.get("id"),
            "title": story.get("title"),
            "status": story.get("status"),
            "priority": story.get("priority"),
            "persona": story.get("persona"),
            "persona_name": story.get("persona_name"),
            "prd_group": story.get("prd_group"),
            "prds": story.get("prds", []),
        }
        story_summaries.append(summary)

    result = {
        "total_count": total_count,
        "returned_count": len(story_summaries),
        "offset": offset,
        "stories": story_summaries,
    }

    return json.dumps(result, indent=2)


async def update_story_metadata(
    story_id: str,
    key: str,
    value: str,
    *,
    stories_dir: Optional[Path] = None
) -> str:
    """Update user story metadata in index.yaml.

    Args:
        story_id: User story ID (e.g., "US-001")
        key: Metadata field to update (status, priority, prds, related_stories, related_personas)
        value: New value (string for scalar fields, comma-separated for arrays)
        stories_dir: Optional override for stories directory (for testing)

    Returns:
        JSON-formatted string containing update result

    Raises:
        NotFoundError: If story ID not found
        ValidationError: If key or value is invalid
        IOError: If file write fails
    """
    # Normalize story ID
    try:
        normalized_id = normalize_story_id(story_id)
    except ValidationError:
        raise

    # Validate key
    if key not in VALID_METADATA_KEYS:
        raise ValidationError(
            f"Invalid metadata key '{key}'. Valid keys: {', '.join(VALID_METADATA_KEYS)}"
        )

    # Validate value based on key
    if key == "status":
        if value not in VALID_STATUS_VALUES:
            raise ValidationError(
                f"Invalid value '{value}' for key 'status'. "
                f"Allowed: {', '.join(VALID_STATUS_VALUES)}"
            )

    if key == "priority":
        if value not in VALID_PRIORITY_VALUES:
            raise ValidationError(
                f"Invalid value '{value}' for key 'priority'. "
                f"Allowed: {', '.join(VALID_PRIORITY_VALUES)}"
            )

    # Load index
    dir_path = _get_stories_dir(stories_dir)
    index_path = dir_path / "index.yaml"
    index_data = load_yaml_index(index_path)

    stories = index_data.get("stories", [])

    # Find story
    story_index = None
    story_entry = None
    for i, story in enumerate(stories):
        if story.get("id") == normalized_id:
            story_index = i
            story_entry = story
            break

    if story_entry is None:
        raise NotFoundError(f"User story '{normalized_id}' not found in index")

    # Record previous value
    previous_value = story_entry.get(key)

    # Update the value
    updated_fields = [key]

    if key in ["prds", "related_stories", "related_personas"]:
        # Array field - parse comma-separated values and add to existing
        new_values = [v.strip() for v in value.split(",") if v.strip()]
        existing = story_entry.get(key, []) or []

        # Add new values avoiding duplicates
        for v in new_values:
            if v not in existing:
                existing.append(v)

        story_entry[key] = existing
    else:
        # Scalar field - replace value
        story_entry[key] = value

    # Write back to file atomically
    try:
        # Write to temp file first
        fd, temp_path = tempfile.mkstemp(suffix=".yaml", dir=dir_path)
        with open(fd, 'w', encoding='utf-8') as f:
            yaml.dump(index_data, f, default_flow_style=False, allow_unicode=True, sort_keys=False)

        # Rename (atomic on POSIX)
        shutil.move(temp_path, index_path)

    except Exception as e:
        # Clean up temp file if it exists
        try:
            Path(temp_path).unlink(missing_ok=True)
        except:
            pass
        raise IOError(f"Failed to write to {index_path}: {e}")

    result = {
        "success": True,
        "story_id": normalized_id,
        "updated_fields": updated_fields,
        "previous_values": {key: previous_value},
        "current_entry": story_entry,
    }

    return json.dumps(result, indent=2)
