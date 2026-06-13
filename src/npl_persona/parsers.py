"""
Markdown parsing utilities for npl_persona.

Extracts all markdown parsing logic into testable functions, replacing
the regex patterns scattered throughout the original codebase.
"""

import re
from datetime import datetime, date
from typing import Dict, List, Optional, Tuple

from .config import (
    TABLE_MARKERS,
    SECTIONS,
    DATE_FORMAT,
)
from .models import (
    JournalEntry,
    Task,
    TaskStatus,
    KnowledgeDomain,
    KnowledgeEntry,
    TeamMember,
)


def extract_section(content: str, header: str) -> Optional[str]:
    """
    Extract content between a section header and the next ## heading.

    Args:
        content: Full markdown content
        header: Section header to find (e.g., "## Recent Interactions")

    Returns:
        Section content or None if not found
    """
    if header not in content:
        return None

    parts = content.split(header, 1)
    if len(parts) < 2:
        return None

    section = parts[1]

    # Find next ## heading
    next_heading = re.search(r"\n## ", section)
    if next_heading:
        section = section[:next_heading.start()]

    return section.strip()


def parse_table_rows(
    content: str,
    marker: str,
    expected_columns: int = 4
) -> List[List[str]]:
    """
    Extract rows from NPL-style table.

    NPL tables use markers like ⟪📅: (l,c,c,r) | Column1,Column2,...⟫

    Args:
        content: Content containing the table
        marker: Table marker to find (e.g., "⟪📅:")
        expected_columns: Minimum number of columns expected

    Returns:
        List of row data (each row is a list of cell values)
    """
    rows: List[List[str]] = []

    if marker not in content:
        return rows

    lines = content.split("\n")
    in_table = False

    for line in lines:
        if marker in line:
            in_table = True
            continue

        if in_table:
            stripped = line.strip()

            # End of table
            if stripped.startswith("##") or stripped.startswith("```"):
                break

            # Skip empty lines and non-table content
            if not stripped.startswith("|"):
                continue

            # Skip header separator rows
            if "---" in stripped:
                continue

            # Parse table row
            parts = [p.strip() for p in stripped.split("|")]

            # Filter empty parts (from leading/trailing |)
            parts = [p for p in parts if p]

            if len(parts) >= expected_columns:
                rows.append(parts)

    return rows


def parse_journal_entries(content: str) -> List[JournalEntry]:
    """
    Extract journal entries from journal file content.

    Entries follow the pattern:
    ### YYYY-MM-DD - session-id
    **Context**: ...
    <npl-reflection>...</npl-reflection>
    ...

    Args:
        content: Journal file content

    Returns:
        List of JournalEntry objects, most recent first
    """
    entries: List[JournalEntry] = []

    # Pattern: ### YYYY-MM-DD - session-id followed by content until next ###
    pattern = r"###\s+(\d{4}-\d{2}-\d{2})\s+-\s+([^\n]+)(.*?)(?=###|\Z)"
    matches = re.findall(pattern, content, re.DOTALL)

    for date_str, session_id, text in matches:
        try:
            entry = JournalEntry.from_raw(date_str, session_id.strip(), text.strip())
            entries.append(entry)
        except ValueError:
            # Skip entries with invalid dates
            continue

    return entries


def parse_tasks(content: str) -> List[Task]:
    """
    Extract tasks from tasks file content.

    Args:
        content: Tasks file content

    Returns:
        List of Task objects
    """
    tasks: List[Task] = []

    # Find the Active Tasks section
    section = extract_section(content, SECTIONS["active_tasks"])
    if not section:
        return tasks

    # Parse table rows
    rows = parse_table_rows(section, TABLE_MARKERS["task"], expected_columns=4)

    for row in rows:
        task = Task.from_table_row(row)
        if task:
            tasks.append(task)

    return tasks


def parse_team_members(content: str) -> List[TeamMember]:
    """
    Extract team members from team file content.

    Args:
        content: Team file content

    Returns:
        List of TeamMember objects
    """
    members: List[TeamMember] = []

    # Parse table rows with team marker
    rows = parse_table_rows(content, TABLE_MARKERS["team"], expected_columns=4)

    for row in rows:
        if len(row) < 4:
            continue

        # Row format: @persona_id | role | joined | status
        persona_id = row[0].lstrip("@").strip()
        role = row[1].strip()
        joined_str = row[2].strip()
        status = row[3].strip() if len(row) > 3 else "Active"

        # Parse joined date
        try:
            joined = datetime.strptime(joined_str, DATE_FORMAT).date()
        except ValueError:
            joined = date.today()

        if persona_id and not persona_id.startswith("<!--"):
            members.append(TeamMember(
                persona_id=persona_id,
                role=role,
                joined=joined,
                status=status,
            ))

    return members


def parse_knowledge_domains(content: str) -> List[KnowledgeDomain]:
    """
    Extract knowledge domains with confidence levels.

    Domains follow the pattern:
    ### Domain Name
    ```knowledge
    confidence: NN%
    depth: level
    last_updated: YYYY-MM-DD
    ```

    Args:
        content: Knowledge base file content

    Returns:
        List of KnowledgeDomain objects
    """
    domains: List[KnowledgeDomain] = []

    # Pattern to find domain sections with knowledge blocks
    pattern = r"###\s+([^\n]+)\s*```knowledge\s*(.*?)```"
    matches = re.findall(pattern, content, re.DOTALL)

    for name, block in matches:
        name = name.strip()

        # Skip date-prefixed entries (those are knowledge entries, not domains)
        if re.match(r"\d{4}-\d{2}-\d{2}", name):
            continue

        # Parse knowledge block
        confidence = 0
        depth = "surface"
        last_updated = date.today()

        confidence_match = re.search(r"confidence:\s*(\d+)%", block)
        if confidence_match:
            confidence = int(confidence_match.group(1))

        depth_match = re.search(r"depth:\s*(\w+)", block)
        if depth_match:
            depth = depth_match.group(1)

        date_match = re.search(r"last_updated:\s*(\d{4}-\d{2}-\d{2})", block)
        if date_match:
            try:
                last_updated = datetime.strptime(date_match.group(1), DATE_FORMAT).date()
            except ValueError:
                pass

        domains.append(KnowledgeDomain(
            name=name,
            confidence=confidence,
            depth=depth,
            last_updated=last_updated,
        ))

    return domains


def parse_knowledge_entries(content: str) -> List[KnowledgeEntry]:
    """
    Extract recent knowledge entries.

    Entries follow the pattern:
    ### YYYY-MM-DD - Topic
    **Source**: ...
    **Learning**: ...
    ...

    Args:
        content: Knowledge base file content

    Returns:
        List of KnowledgeEntry objects
    """
    entries: List[KnowledgeEntry] = []

    # Get recently acquired section
    section = extract_section(content, SECTIONS["recently_acquired"])
    if not section:
        return entries

    # Pattern for knowledge entries
    pattern = r"###\s+(\d{4}-\d{2}-\d{2})\s+-\s+([^\n]+)(.*?)(?=###|\Z)"
    matches = re.findall(pattern, section, re.DOTALL)

    for date_str, topic, text in matches:
        try:
            entry_date = datetime.strptime(date_str, DATE_FORMAT).date()
        except ValueError:
            continue

        # Extract source
        source_match = re.search(r"\*\*Source\*\*:\s*(.+?)(?:\n|$)", text)
        source = source_match.group(1).strip() if source_match else "Unknown"

        # Extract learning
        learning_match = re.search(r"\*\*Learning\*\*:\s*(.+?)(?=\*\*|$)", text, re.DOTALL)
        learning = learning_match.group(1).strip() if learning_match else ""

        entries.append(KnowledgeEntry(
            date=entry_date,
            topic=topic.strip(),
            source=source,
            learning=learning,
        ))

    return entries


def extract_mentions(text: str) -> List[str]:
    """
    Extract @mentions from text.

    Args:
        text: Text to search for mentions

    Returns:
        List of persona IDs (without @ prefix)
    """
    matches = re.findall(r"@(\w+[-\w]*)", text)
    return list(set(matches))  # Deduplicate


def extract_persona_role(content: str) -> Optional[str]:
    """
    Extract role from persona definition file.

    Args:
        content: Persona definition file content

    Returns:
        Role string or None
    """
    # Try **Role**: format first
    match = re.search(r"\*\*Role\*\*:\s*(.+?)(?:\n|$)", content)
    if match:
        return match.group(1).strip()

    # Try header format: ⌜persona:id|role|NPL@1.0⌝
    match = re.search(r"⌜persona:[^|]+\|([^|]+)\|", content)
    if match:
        return match.group(1).strip()

    return None


def insert_after_section(
    content: str,
    section_header: str,
    new_content: str
) -> str:
    """
    Insert content after a section header.

    Args:
        content: Full markdown content
        section_header: Header to insert after
        new_content: Content to insert

    Returns:
        Modified content
    """
    if section_header in content:
        parts = content.split(section_header, 1)
        return parts[0] + section_header + new_content + parts[1]
    return content + new_content


def update_table_row(
    content: str,
    pattern: str,
    column_index: int,
    new_value: str
) -> Tuple[str, bool]:
    """
    Update a specific column in a table row matching a pattern.

    Args:
        content: Full content
        pattern: Pattern to find in the row
        column_index: 0-based column index to update
        new_value: New value for the column

    Returns:
        Tuple of (modified content, was_updated)
    """
    lines = content.split("\n")
    updated = False

    for i, line in enumerate(lines):
        if pattern in line and line.strip().startswith("|"):
            parts = [p.strip() for p in line.split("|")]
            if len(parts) > column_index + 1:  # +1 for leading empty part
                parts[column_index + 1] = f" {new_value} "
                lines[i] = "|".join(parts)
                updated = True
                break

    return "\n".join(lines), updated


def remove_table_row(content: str, pattern: str) -> Tuple[str, bool]:
    """
    Remove a table row matching a pattern.

    Args:
        content: Full content
        pattern: Pattern to find in the row to remove

    Returns:
        Tuple of (modified content, was_removed)
    """
    lines = content.split("\n")
    new_lines = []
    removed = False

    for line in lines:
        if pattern in line and line.strip().startswith("|") and not removed:
            removed = True
            continue
        new_lines.append(line)

    return "\n".join(new_lines), removed
