"""Markdown viewer with filtering and collapsing support."""

import re
from typing import Optional


class MarkdownViewer:
    """Filter and view markdown with optional collapsible sections."""

    def view(
        self,
        content: str,
        filter: Optional[str] = None,
        bare: bool = False,
        depth: Optional[int] = None,
    ) -> str:
        """Filter and view markdown.

        Args:
            content: Markdown content
            filter: Optional heading filter selector
            bare: If True, show ONLY filtered content (no collapsed headings)
            depth: When not bare, number of collapsed heading layers to show

        Returns:
            Filtered markdown, optionally with collapsed sections

        Examples:
            # Show only "API Reference" section
            viewer.view(content, filter="API Reference", bare=True)

            # Show filtered section + collapsed sub-sections at depth 2
            viewer.view(content, filter="API Reference", bare=False, depth=2)

            # Show all headings collapsed at depth 2
            viewer.view(content, bare=False, depth=2)
        """
        # Apply filter if specified
        if filter:
            from .filters import apply_filter

            content = apply_filter(content, filter)

        # If bare mode, return filtered content as-is (no collapsed headings)
        if bare:
            return content

        # Apply collapsing to show collapsed indicator text
        if depth is not None:
            return self._collapse_sections(content, depth)

        # No collapsing requested - return as-is
        return content

    def _collapse_sections(self, content: str, depth: int) -> str:
        """Collapse sections below specified depth.

        When depth=2, shows:
        - # Heading 1 (expanded)
        - ## Heading 2 (expanded)
        - ### Inner Content (collapsed)  - heading text shown but marked as collapsed
        - #### Deep Content (collapsed)   - only first level below shown, others hidden

        Content under collapsed headings is hidden.

        Args:
            content: Markdown content
            depth: Show headings up to this level expanded, collapse below

        Returns:
            Markdown with collapsed indicators for levels > depth
        """
        lines = []
        in_collapsed_section = False
        collapsed_section_depth = 0

        for line in content.split("\n"):
            # Check if heading
            match = re.match(r"^(#{1,6})\s+(.+)$", line)
            if match:
                level = len(match.group(1))
                heading_text = match.group(2)

                # If we're returning to a level <= depth, exit collapsed section
                if level <= depth:
                    in_collapsed_section = False
                    # This heading is at or above depth - show it fully expanded
                    lines.append(line)
                else:
                    # Level > depth: show heading but mark as collapsed
                    if not in_collapsed_section:
                        # First level below threshold - show heading with "(collapsed)" marker
                        heading_prefix = "#" * level
                        lines.append(f"{heading_prefix} {heading_text} (collapsed)")
                        in_collapsed_section = True
                        collapsed_section_depth = level
                    elif level < collapsed_section_depth:
                        # Return to a shallower collapsed level - show but mark as collapsed
                        heading_prefix = "#" * level
                        lines.append(f"{heading_prefix} {heading_text} (collapsed)")
                        collapsed_section_depth = level
                    # else: deeper nested under collapse - skip entirely
            else:
                # Content line
                if not in_collapsed_section:
                    # Show content for expanded sections
                    lines.append(line)
                # Skip content for collapsed sections

        return "\n".join(lines)
