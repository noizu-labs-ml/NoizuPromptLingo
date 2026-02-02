"""Heading-based filter for markdown content.

Supported syntax:
- "heading-name" - Find heading by text
- "heading-a > heading-b" - Nested path
- "heading-a > *" - All content under heading-a
- "h2" - All level 2 headings
- "heading-a:subsection" - Named subsection under heading-a
"""

import re
from typing import List, Optional, Dict, Any


class HeadingFilter:
    """Filter markdown by heading paths."""

    @staticmethod
    def _normalize_heading_name(text: str) -> str:
        """Normalize heading text to kebab-case for matching.

        Examples:
            "Mereological nihilism" -> "mereological-nihilism"
            "API Reference" -> "api-reference"
            "HTTP/2" -> "http2"

        Args:
            text: Heading text to normalize

        Returns:
            Normalized heading name in kebab-case
        """
        # Convert to lowercase
        normalized = text.lower()
        # Replace spaces and underscores with hyphens
        normalized = re.sub(r'[\s_]+', '-', normalized)
        # Remove non-alphanumeric characters except hyphens
        normalized = re.sub(r'[^a-z0-9\-]', '', normalized)
        # Remove consecutive hyphens
        normalized = re.sub(r'-+', '-', normalized)
        # Strip leading/trailing hyphens
        normalized = normalized.strip('-')
        return normalized

    def filter_with_context(self, content: str, selector: str) -> Dict[str, Any]:
        """Apply filter while preserving document context by marking matches.

        Instead of extracting the matched section, this returns the full
        document structure with matched sections marked for context-aware rendering.

        Args:
            content: Markdown content to filter
            selector: Heading selector (path, level, or name)

        Returns:
            Dict with:
                - 'sections': Full document structure with marking flags
                - 'has_matches': Whether any sections matched
                - 'matched_ids': Set of IDs of matched sections
        """
        # Parse selector into path parts
        parts = [p.strip() for p in selector.split(">")]

        # Parse markdown into sections
        sections = self._parse_sections(content)

        # Navigate path to find matched section(s)
        current = sections
        for part in parts:
            if part == "*":
                # Match all at current level
                if isinstance(current, dict):
                    current = current.get("children", [])
                break
            else:
                # Find matching section
                if isinstance(current, list):
                    current = self._find_section(current, part)
                else:
                    # Already narrowed to single section, search its children
                    current = self._find_section(current.get("children", []), part)

                if not current:
                    return {
                        'sections': sections,
                        'has_matches': False,
                        'matched_ids': set()
                    }

        # Ensure current is a list for consistent handling
        if isinstance(current, dict):
            current = [current]

        # Mark matched sections and their ancestors
        matched_ids = set()
        for matched_section in current:
            self._mark_matched(matched_section, matched_ids)
            self._mark_ancestors(sections, matched_section)

        return {
            'sections': sections,
            'has_matches': len(matched_ids) > 0,
            'matched_ids': matched_ids
        }

    def filter(self, content: str, selector: str) -> str:
        """Apply heading selector to markdown content.

        Args:
            content: Markdown content to filter
            selector: Heading selector (path, level, or name)

        Returns:
            Filtered markdown content
        """
        # Parse selector into path parts
        parts = [p.strip() for p in selector.split(">")]

        # Parse markdown into sections
        sections = self._parse_sections(content)

        # Navigate path
        current = sections
        for part in parts:
            if part == "*":
                # Return all content at current level
                # If current is a single section, return its children
                if isinstance(current, dict):
                    children = current.get("children", [])
                    return self._sections_to_markdown(children)
                # If current is a list, return all sections in that list
                return self._sections_to_markdown(current)
            else:
                # Find matching section
                if isinstance(current, list):
                    current = self._find_section(current, part)
                else:
                    # Already narrowed to single section, search its children
                    current = self._find_section(current.get("children", []), part)

                if not current:
                    return f"# Error: Section not found: {part}"

        if isinstance(current, list):
            return self._sections_to_markdown(current)
        else:
            return self._sections_to_markdown([current])

    def _mark_matched(self, section: Dict[str, Any], matched_ids: set) -> None:
        """Recursively mark section and all children as matched.

        Args:
            section: Section dictionary to mark
            matched_ids: Set to accumulate matched section IDs
        """
        section['matched'] = True
        matched_ids.add(id(section))
        for child in section.get('children', []):
            self._mark_matched(child, matched_ids)

    def _mark_ancestors(self, sections: List[Dict[str, Any]], matched_section: Dict[str, Any]) -> bool:
        """Mark all ancestors of matched section for context rendering.

        Recursively searches the section tree to find the matched section,
        and marks all its ancestors with 'matched_ancestor' flag.

        Args:
            sections: List of sections to search
            matched_section: The matched section to find ancestors for

        Returns:
            True if the matched section was found and ancestors were marked
        """
        def find_and_mark_ancestors(section_list, target, ancestors_chain):
            for section in section_list:
                # Check if this is the target section
                if id(section) == id(target):
                    # Mark all ancestors
                    for ancestor in ancestors_chain:
                        ancestor['matched_ancestor'] = True
                    return True

                # Recurse into children
                if find_and_mark_ancestors(
                    section.get('children', []),
                    target,
                    ancestors_chain + [section]
                ):
                    return True

            return False

        return find_and_mark_ancestors(sections, matched_section, [])

    def _parse_sections(self, content: str) -> List[Dict[str, Any]]:
        """Parse markdown into hierarchical sections.

        Args:
            content: Markdown content

        Returns:
            List of section dictionaries with hierarchy
        """
        sections = []
        current_stack: List[Dict[str, Any]] = []
        lines = content.split("\n")

        for i, line in enumerate(lines):
            # Match heading lines (# Heading, ## Heading, etc.)
            match = re.match(r"^(#{1,6})\s+(.+?)(?:\s*#*)?$", line)
            if match:
                level = len(match.group(1))
                text = match.group(2).strip()

                section = {
                    "level": level,
                    "text": text,
                    "start": i,
                    "end": len(lines),
                    "content": [],
                    "children": [],
                }

                # Pop stack until we find parent level or reach root
                while current_stack and current_stack[-1]["level"] >= level:
                    current_stack.pop()

                # Add to parent or root
                if not current_stack:
                    sections.append(section)
                else:
                    current_stack[-1]["children"].append(section)

                current_stack.append(section)
            elif current_stack:
                # Add content to current section
                current_stack[-1]["content"].append(line)

        return sections

    def _find_section(self, sections: List[Dict[str, Any]], selector: str) -> Optional[Dict[str, Any]]:
        """Find section matching selector.

        Args:
            sections: List of sections to search
            selector: Heading selector (name, level, or normalized name)

        Returns:
            Matching section or None
        """
        # Handle level selectors (h1, h2, etc.)
        if re.match(r"^h[1-6]$", selector):
            level = int(selector[1])
            for section in sections:
                if section["level"] == level:
                    return section
            return None

        # Normalize selector for matching
        normalized_selector = self._normalize_heading_name(selector)

        # Handle text match - try both raw text and normalized names
        for section in sections:
            section_text = section["text"]
            # Match by raw text (case-insensitive)
            if section_text.lower() == selector.lower():
                return section
            # Match by normalized name
            if self._normalize_heading_name(section_text) == normalized_selector:
                return section

        return None

    def _sections_to_markdown(self, sections: List[Dict[str, Any]]) -> str:
        """Convert sections back to markdown.

        Args:
            sections: List of section dictionaries

        Returns:
            Markdown content
        """
        lines = []

        for section in sections:
            # Add heading
            heading_prefix = "#" * section["level"]
            lines.append(f"{heading_prefix} {section['text']}")

            # Add content
            lines.extend(section["content"])

            # Add children recursively
            if section["children"]:
                child_markdown = self._sections_to_markdown(section["children"])
                if child_markdown:
                    lines.append(child_markdown)

        return "\n".join(lines)
