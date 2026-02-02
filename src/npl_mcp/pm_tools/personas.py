"""Persona MCP tools.

Implements FR-007 (get_persona, list_personas).
"""

import json
from pathlib import Path
from typing import Any, Dict, List, Optional

from .exceptions import NotFoundError, ValidationError, ParseError
from .utils import (
    load_yaml_index,
    normalize_persona_id,
    extract_demographics,
    extract_list_items,
    get_project_root,
)


def _get_personas_dir(personas_dir: Optional[Path] = None) -> Path:
    """Get the personas directory path."""
    if personas_dir is not None:
        return personas_dir
    return get_project_root() / "project-management" / "personas"


async def get_persona(persona_id: str, *, personas_dir: Optional[Path] = None) -> str:
    """Load a persona by ID.

    Args:
        persona_id: Persona ID (e.g., "P-001", "A-001")
        personas_dir: Optional override for personas directory (for testing)

    Returns:
        JSON-formatted string containing persona data

    Raises:
        NotFoundError: If persona ID not found
        ValidationError: If ID format is invalid
    """
    # Normalize and validate persona ID
    try:
        normalized_id = normalize_persona_id(persona_id)
    except ValidationError:
        raise

    dir_path = _get_personas_dir(personas_dir)
    index_path = dir_path / "index.yaml"
    index_data = load_yaml_index(index_path)

    # Find persona in index
    personas = index_data.get("personas", [])
    persona_entry = None
    for persona in personas:
        if persona.get("id") == normalized_id:
            persona_entry = persona
            break

    if persona_entry is None:
        raise NotFoundError(f"Persona '{normalized_id}' not found")

    # Build result from index data
    result: Dict[str, Any] = {
        "id": persona_entry.get("id"),
        "name": persona_entry.get("name"),
        "file": persona_entry.get("file"),
        "category": persona_entry.get("category"),
        "tags": persona_entry.get("tags", []),
        "related_stories": persona_entry.get("related_stories", []),
    }

    # Try to load content from file
    file_path_str = persona_entry.get("file")
    content = None

    if file_path_str:
        file_path = dir_path / file_path_str
        if file_path.exists():
            try:
                content = file_path.read_text(encoding='utf-8')
            except Exception:
                content = None

    result["content"] = content

    # Parse structured data from content if available
    if content:
        result["demographics"] = extract_demographics(content)
        result["goals"] = extract_list_items(content, "Goals")
        result["pain_points"] = extract_list_items(content, "Pain Points")
        result["behaviors"] = extract_list_items(content, "Behaviors")
    else:
        result["demographics"] = {}
        result["goals"] = []
        result["pain_points"] = []
        result["behaviors"] = []

    return json.dumps(result, indent=2)


async def list_personas(
    *,
    tags: Optional[str] = None,
    category: Optional[str] = None,
    personas_dir: Optional[Path] = None
) -> str:
    """List and filter personas.

    Args:
        tags: Comma-separated tags to filter by (OR logic)
        category: Category filter (e.g., "Core", "Infrastructure")
        personas_dir: Optional override for personas directory (for testing)

    Returns:
        JSON-formatted string containing persona list

    Raises:
        FileNotFoundError: If index.yaml not found
        ParseError: If YAML parsing fails
    """
    dir_path = _get_personas_dir(personas_dir)
    index_path = dir_path / "index.yaml"
    index_data = load_yaml_index(index_path)

    personas = index_data.get("personas", [])

    # Parse tags filter
    filter_tags = None
    if tags:
        filter_tags = [t.strip() for t in tags.split(",") if t.strip()]

    # Apply filters
    filtered = []
    for persona in personas:
        # Tag filter (OR logic - match any tag)
        if filter_tags:
            persona_tags = persona.get("tags", [])
            if not any(t in persona_tags for t in filter_tags):
                continue

        # Category filter
        if category:
            persona_category = persona.get("category")
            # Core personas (P-XXX) without explicit category are considered "Core"
            if persona_category != category:
                # Check if it's a P-XXX persona and category is "Core"
                persona_id = persona.get("id", "")
                if not (persona_id.startswith("P-") and category == "Core" and persona_category is None):
                    continue

        filtered.append(persona)

    # Build summaries
    summaries = []
    core_personas = 0
    core_agents = 0
    additional_agents = 0

    for persona in filtered:
        persona_id = persona.get("id", "")

        # Count by type
        if persona_id.startswith("P-"):
            core_personas += 1
        elif persona_id.startswith("A-"):
            # A-001 to A-016 are core agents, A-017+ are additional
            try:
                num = int(persona_id[2:])
                if num <= 16:
                    core_agents += 1
                else:
                    additional_agents += 1
            except ValueError:
                additional_agents += 1

        summaries.append({
            "id": persona_id,
            "name": persona.get("name"),
            "file": persona.get("file"),
            "tags": persona.get("tags", []),
            "related_stories_count": len(persona.get("related_stories", [])),
            "category": persona.get("category"),
        })

    result = {
        "total_count": len(summaries),
        "core_personas": core_personas,
        "core_agents": core_agents,
        "additional_agents": additional_agents,
        "personas": summaries,
    }

    return json.dumps(result, indent=2)
