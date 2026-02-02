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
            selector: Heading selector (name or level)

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

        # Handle text match (case-insensitive)
        for section in sections:
            if section["text"].lower() == selector.lower():
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
