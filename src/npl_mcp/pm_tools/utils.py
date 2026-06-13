"""Utility functions for PM MCP tools."""

import re
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import yaml

from .exceptions import ParseError, ValidationError


def load_yaml_index(index_path: Path) -> Dict[str, Any]:
    """Load and parse a YAML index file.

    Args:
        index_path: Path to the index.yaml file

    Returns:
        Parsed YAML content as dictionary

    Raises:
        FileNotFoundError: If index file doesn't exist
        ParseError: If YAML parsing fails
    """
    if not index_path.exists():
        raise FileNotFoundError(f"Index file not found: {index_path}")

    try:
        with open(index_path, 'r', encoding='utf-8') as f:
            content = yaml.safe_load(f) or {}
        return content
    except yaml.YAMLError as e:
        raise ParseError(f"Failed to parse YAML in {index_path.name}: {e}")


def normalize_story_id(story_id: str) -> str:
    """Normalize a story ID to the US-XXX format.

    Args:
        story_id: Input story ID (e.g., "US-001", "001", "1")

    Returns:
        Normalized ID in US-XXX format

    Raises:
        ValidationError: If ID format is invalid
    """
    story_id = story_id.strip()

    if not story_id:
        raise ValidationError("Invalid story ID format: ''. Expected 'US-XXX' or numeric ID")

    # Check for whitespace-only
    if not story_id.replace(' ', ''):
        raise ValidationError("Invalid story ID format: whitespace-only. Expected 'US-XXX' or numeric ID")

    # Already in US-XXX format
    if re.match(r'^US-\d+$', story_id, re.IGNORECASE):
        # Normalize case and padding
        num = int(story_id[3:])
        return f"US-{num:03d}"

    # Pure numeric
    if re.match(r'^\d+$', story_id):
        num = int(story_id)
        return f"US-{num:03d}"

    # Invalid format
    raise ValidationError(f"Invalid story ID format: '{story_id}'. Expected 'US-XXX' or numeric ID")


def normalize_prd_id(prd_id: str) -> str:
    """Normalize a PRD ID to the PRD-XXX format.

    Args:
        prd_id: Input PRD ID (e.g., "PRD-015", "015", "15")

    Returns:
        Normalized ID in PRD-XXX format

    Raises:
        ValidationError: If ID format is invalid
    """
    prd_id = prd_id.strip()

    if not prd_id:
        raise ValidationError("Invalid PRD ID format: ''. Expected 'PRD-XXX' or numeric ID")

    # Already in PRD-XXX format
    if re.match(r'^PRD-\d+$', prd_id, re.IGNORECASE):
        num = int(prd_id[4:])
        return f"PRD-{num:03d}"

    # Pure numeric
    if re.match(r'^\d+$', prd_id):
        num = int(prd_id)
        return f"PRD-{num:03d}"

    # Invalid format
    raise ValidationError(f"Invalid PRD ID format: '{prd_id}'. Expected 'PRD-XXX' or numeric ID")


def normalize_fr_id(fr_id: str) -> str:
    """Normalize a functional requirement ID to FR-XXX format.

    Args:
        fr_id: Input FR ID (e.g., "FR-001", "001", "1")

    Returns:
        Normalized ID in FR-XXX format
    """
    fr_id = fr_id.strip()

    if re.match(r'^FR-\d+$', fr_id, re.IGNORECASE):
        num = int(fr_id[3:])
        return f"FR-{num:03d}"

    if re.match(r'^\d+$', fr_id):
        num = int(fr_id)
        return f"FR-{num:03d}"

    return fr_id


def normalize_at_id(at_id: str) -> str:
    """Normalize an acceptance test ID to AT-XXX format.

    Args:
        at_id: Input AT ID (e.g., "AT-001", "001", "1")

    Returns:
        Normalized ID in AT-XXX format
    """
    at_id = at_id.strip()

    if re.match(r'^AT-\d+$', at_id, re.IGNORECASE):
        num = int(at_id[3:])
        return f"AT-{num:03d}"

    if re.match(r'^\d+$', at_id):
        num = int(at_id)
        return f"AT-{num:03d}"

    return at_id


def normalize_persona_id(persona_id: str) -> str:
    """Normalize a persona ID (P-XXX or A-XXX format).

    Args:
        persona_id: Input persona ID

    Returns:
        Normalized ID

    Raises:
        ValidationError: If ID format is invalid
    """
    persona_id = persona_id.strip()

    if not persona_id:
        raise ValidationError("Invalid persona ID format: ''. Expected 'P-XXX', 'A-XXX', or numeric ID")

    # P-XXX format (core personas)
    if re.match(r'^P-\d+$', persona_id, re.IGNORECASE):
        num = int(persona_id[2:])
        return f"P-{num:03d}"

    # A-XXX format (agents)
    if re.match(r'^A-\d+$', persona_id, re.IGNORECASE):
        num = int(persona_id[2:])
        return f"A-{num:03d}"

    # U-XXX format (utilities)
    if re.match(r'^U-\d+$', persona_id, re.IGNORECASE):
        num = int(persona_id[2:])
        return f"U-{num:03d}"

    # Invalid format
    raise ValidationError(f"Invalid persona ID format: '{persona_id}'. Expected 'P-XXX', 'A-XXX', or numeric ID")


def parse_acceptance_criteria(content: str) -> List[Dict[str, Any]]:
    """Parse acceptance criteria from markdown content.

    Args:
        content: Markdown content containing acceptance criteria

    Returns:
        List of acceptance criteria with text and completed status
    """
    criteria = []

    # Find the Acceptance Criteria section
    lines = content.split('\n')
    in_ac_section = False

    for line in lines:
        # Check for start of AC section
        if re.match(r'^##\s+Acceptance Criteria', line, re.IGNORECASE):
            in_ac_section = True
            continue

        # Check for end of section (next heading)
        if in_ac_section and line.startswith('## '):
            break

        if in_ac_section:
            # Match checkbox patterns: - [ ] or - [x]
            match = re.match(r'^\s*-\s*\[([ xX])\]\s*(.+)$', line)
            if match:
                completed = match.group(1).lower() == 'x'
                text = match.group(2).strip()
                criteria.append({
                    "text": text,
                    "completed": completed
                })

    return criteria


def extract_list_items(content: str, section_name: str) -> List[str]:
    """Extract list items from a markdown section.

    Args:
        content: Full markdown content
        section_name: Name of the section (e.g., "Preconditions", "Steps")

    Returns:
        List of text items from the section
    """
    items = []
    lines = content.split('\n')
    in_section = False

    for line in lines:
        # Check for section header (## or ###)
        if re.match(rf'^##[#]?\s+{section_name}', line, re.IGNORECASE):
            in_section = True
            continue

        # Check for end of section (next heading)
        if in_section and re.match(r'^##[#]?\s+', line):
            break

        if in_section:
            # Match list items (-, *, or numbered)
            match = re.match(r'^\s*(?:[-*]|\d+\.)\s*(.+)$', line)
            if match:
                text = match.group(1).strip()
                if text:
                    items.append(text)

    return items


def extract_demographics(content: str) -> Dict[str, str]:
    """Extract demographics section from persona markdown.

    Args:
        content: Full markdown content

    Returns:
        Dictionary of demographic key-value pairs
    """
    demographics = {}
    lines = content.split('\n')
    in_section = False

    for line in lines:
        if re.match(r'^##\s+Demographics', line, re.IGNORECASE):
            in_section = True
            continue

        if in_section and line.startswith('## '):
            break

        if in_section:
            # Match "- **Key**: Value" or "- Key: Value"
            match = re.match(r'^\s*-\s*\**([^*:]+)\**:\s*(.+)$', line)
            if match:
                key = match.group(1).strip()
                value = match.group(2).strip()
                demographics[key] = value

    return demographics


def extract_prd_metadata(content: str) -> Dict[str, Optional[str]]:
    """Extract metadata from PRD markdown content.

    Args:
        content: PRD markdown content

    Returns:
        Dictionary with version, status, title
    """
    metadata = {
        "version": None,
        "status": None,
        "title": None
    }

    lines = content.split('\n')

    for line in lines:
        # Extract title from first H1
        if metadata["title"] is None and line.startswith('# '):
            # e.g., "# PRD-015: NPL Advanced Loading Extension"
            title_match = re.match(r'^#\s*PRD-\d+:\s*(.+)$', line)
            if title_match:
                metadata["title"] = title_match.group(1).strip()
            else:
                metadata["title"] = line[2:].strip()

        # Extract version
        version_match = re.match(r'^\*\*Version\*\*:\s*(.+)$', line)
        if version_match:
            metadata["version"] = version_match.group(1).strip()

        # Extract status
        status_match = re.match(r'^\*\*Status\*\*:\s*(.+)$', line)
        if status_match:
            metadata["status"] = status_match.group(1).strip()

    return metadata


def extract_user_story_references(content: str) -> List[str]:
    """Extract user story IDs referenced in PRD content.

    Args:
        content: PRD markdown content

    Returns:
        List of unique user story IDs (US-XXX)
    """
    # Find all US-XXX patterns
    matches = re.findall(r'US-\d+', content)
    return list(dict.fromkeys(matches))  # Unique, preserving order


def get_project_root() -> Path:
    """Get the project root directory.

    Returns:
        Path to the project root (containing project-management/)
    """
    # Look for project-management directory starting from current directory
    current = Path.cwd()

    while current != current.parent:
        if (current / "project-management").exists():
            return current
        current = current.parent

    # Default to current directory
    return Path.cwd()


PRIORITY_ORDER = {
    "critical": 0,
    "high": 1,
    "medium": 2,
    "low": 3
}


def sort_by_priority(stories: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Sort stories by priority (critical first) then by ID.

    Args:
        stories: List of story dictionaries

    Returns:
        Sorted list of stories
    """
    def sort_key(story: Dict[str, Any]) -> Tuple[int, int]:
        priority = story.get("priority", "medium").lower()
        priority_order = PRIORITY_ORDER.get(priority, 2)

        # Extract numeric ID for secondary sort
        story_id = story.get("id", "US-000")
        try:
            id_num = int(story_id.split("-")[1])
        except (IndexError, ValueError):
            id_num = 0

        return (priority_order, id_num)

    return sorted(stories, key=sort_key)
