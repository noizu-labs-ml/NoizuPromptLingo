"""
Journal operations for npl_persona.

Handles journal add, view, and archive operations.
"""

import re
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Optional

from .config import DATE_FORMAT, SECTIONS, DEFAULT_JOURNAL_ENTRIES
from .models import JournalEntry
from .paths import resolve_persona
from .io import read_file, write_file
from .parsers import parse_journal_entries, insert_after_section
from .templates import generate_journal_entry


class JournalManager:
    """Manages journal operations for personas."""

    def add_entry(
        self,
        persona_id: str,
        message: Optional[str] = None,
        interactive: bool = False
    ) -> bool:
        """
        Add a journal entry.

        Args:
            persona_id: Persona identifier
            message: Journal entry message
            interactive: Use interactive input mode

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        journal_file = base_path / f"{persona_id}.journal.md"

        if not journal_file.exists():
            print(f"Error: Journal file not found: {journal_file}", file=sys.stderr)
            return False

        # Get message
        if interactive:
            print("Enter journal entry (Ctrl+D or Ctrl+Z to finish):")
            lines = []
            try:
                while True:
                    line = input()
                    lines.append(line)
            except EOFError:
                message = "\n".join(lines)

        if not message:
            print("Error: No message provided", file=sys.stderr)
            return False

        # Generate entry
        entry = generate_journal_entry(message)

        # Read existing content
        result = read_file(journal_file)
        if result.is_err():
            print(f"Error reading journal: {result.error}", file=sys.stderr)
            return False

        content = result.value

        # Insert after "## Recent Interactions"
        new_content = insert_after_section(
            content,
            SECTIONS["recent_interactions"],
            entry
        )

        # Write back
        result = write_file(journal_file, new_content)
        if result.is_err():
            print(f"Error writing journal: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Journal entry added to {persona_id}")
        return True

    def view_entries(
        self,
        persona_id: str,
        entries: int = DEFAULT_JOURNAL_ENTRIES,
        since: Optional[str] = None
    ) -> bool:
        """
        View recent journal entries.

        Args:
            persona_id: Persona identifier
            entries: Number of entries to view
            since: Only show entries since date (YYYY-MM-DD)

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        journal_file = base_path / f"{persona_id}.journal.md"

        if not journal_file.exists():
            print(f"Error: Journal file not found: {journal_file}", file=sys.stderr)
            return False

        result = read_file(journal_file)
        if result.is_err():
            print(f"Error reading journal: {result.error}", file=sys.stderr)
            return False

        content = result.value

        # Parse entries
        parsed_entries = parse_journal_entries(content)

        if not parsed_entries:
            print(f"No journal entries found for {persona_id}")
            return True

        # Filter by date if specified
        if since:
            try:
                since_date = datetime.strptime(since, DATE_FORMAT).date()
                parsed_entries = [e for e in parsed_entries if e.date >= since_date]
            except ValueError:
                print(f"Error: Invalid date format '{since}'. Use YYYY-MM-DD", file=sys.stderr)
                return False

        # Show most recent entries
        display_count = min(entries, len(parsed_entries))
        print(f"# Journal entries for {persona_id} (showing {display_count} of {len(parsed_entries)})\n")

        for entry in parsed_entries[:entries]:
            print(f"### {entry.date.strftime(DATE_FORMAT)} - {entry.session_id}")
            print(entry.content)
            print("---\n")

        return True

    def archive_entries(self, persona_id: str, before: str) -> bool:
        """
        Archive journal entries before a specific date.

        Args:
            persona_id: Persona identifier
            before: Archive entries before date (YYYY-MM-DD)

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        journal_file = base_path / f"{persona_id}.journal.md"

        if not journal_file.exists():
            print(f"Error: Journal file not found: {journal_file}", file=sys.stderr)
            return False

        # Parse date
        try:
            before_date = datetime.strptime(before, DATE_FORMAT).date()
        except ValueError:
            print(f"Error: Invalid date format '{before}'. Use YYYY-MM-DD", file=sys.stderr)
            return False

        result = read_file(journal_file)
        if result.is_err():
            print(f"Error reading journal: {result.error}", file=sys.stderr)
            return False

        content = result.value

        # Extract entries with dates using regex
        entry_pattern = r"###\s+(\d{4}-\d{2}-\d{2})\s+-\s+([^\n]+)(.*?)(?=###|\Z)"
        matches = re.findall(entry_pattern, content, re.DOTALL)

        if not matches:
            print(f"No journal entries found to archive")
            return True

        # Separate entries to keep vs archive
        to_keep = []
        to_archive = []

        for date_str, session_id, text in matches:
            try:
                entry_date = datetime.strptime(date_str, DATE_FORMAT).date()
            except ValueError:
                to_keep.append(f"### {date_str} - {session_id}{text}")
                continue

            entry_text = f"### {date_str} - {session_id}{text}"

            if entry_date < before_date:
                to_archive.append(entry_text)
            else:
                to_keep.append(entry_text)

        if not to_archive:
            print(f"No entries found before {before}")
            return True

        # Create archive file
        archive_file = base_path / f"{persona_id}.journal.{before_date.strftime('%Y%m%d')}.md"
        archive_content = f"""# {persona_id} Journal Archive
Archived: {datetime.now().strftime(DATE_FORMAT)}
Entries before: {before}

## Archived Interactions
{"".join(to_archive)}
"""

        result = write_file(archive_file, archive_content)
        if result.is_err():
            print(f"Error creating archive: {result.error}", file=sys.stderr)
            return False

        # Update main journal
        header_end = content.find(SECTIONS["recent_interactions"])
        if header_end != -1:
            header = content[:header_end + len(SECTIONS["recent_interactions"])] + "\n"
        else:
            header = f"# {persona_id} Journal\n\n{SECTIONS['recent_interactions']}\n"

        # Find relationship section if exists
        relationship_section = ""
        if SECTIONS["relationship_evolution"] in content:
            rel_start = content.find(SECTIONS["relationship_evolution"])
            relationship_section = content[rel_start:]

        new_content = header + "\n".join(to_keep)
        if relationship_section:
            new_content += "\n\n" + relationship_section

        result = write_file(journal_file, new_content)
        if result.is_err():
            print(f"Error updating journal: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Archived {len(to_archive)} entries to {archive_file.name}")
        return True
