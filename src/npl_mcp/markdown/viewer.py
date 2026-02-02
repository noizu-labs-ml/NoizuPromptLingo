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
        filter_inner_depth: Optional[int] = None,
    ) -> str:
        """Filter and view markdown with context preservation.

        Args:
            content: Markdown content
            filter: Optional heading filter selector
            bare: If True, extract ONLY filtered content (no context)
                  If False (default), show full document with filtered section highlighted
            depth: Collapse level for entire document (1-6)
            filter_inner_depth: Collapse level WITHIN filtered sections only (1-6)

        Returns:
            Filtered markdown, optionally with collapsed sections

        Examples:
            # Show only "API Reference" section (extraction mode)
            viewer.view(content, filter="API Reference", bare=True)

            # Show full document with "API Reference" section expanded, others collapsed
            viewer.view(content, filter="API Reference", bare=False)

            # Show full document with context, collapse at depth 2
            viewer.view(content, filter="API Reference", depth=2)

            # Show filtered section with its children collapsed at depth 2
            viewer.view(content, filter="API Reference", filter_inner_depth=2)

            # Show all headings collapsed at depth 2 (no filter)
            viewer.view(content, bare=False, depth=2)
        """
        # No filter specified
        if not filter:
            if depth is not None:
                return self._collapse_sections(content, depth)
            return content

        # Bare mode: extract only (backward compatibility)
        if bare:
            from .filters import apply_filter
            return apply_filter(content, filter)

        # Context mode: show full document with filtered section highlighted
        from .filters.heading import HeadingFilter
        marked = HeadingFilter().filter_with_context(content, filter)

        if not marked['has_matches']:
            return f"# Error: Section not found: {filter}"

        return self._render_with_context(
            marked['sections'],
            marked['matched_ids'],
            depth,
            filter_inner_depth
        )

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

    def _render_with_context(
        self,
        sections: list,
        matched_ids: set,
        depth: Optional[int] = None,
        filter_inner_depth: Optional[int] = None,
    ) -> str:
        """Render full document with matched sections expanded for context.

        Renders the entire document structure with:
        - Matched sections: shown expanded (or controlled by filter_inner_depth)
        - Matched ancestors: shown expanded to provide navigation context
        - Other sections: shown as collapsed with "(collapsed)" marker

        Args:
            sections: Full document structure (list of section dicts)
            matched_ids: Set of IDs of matched sections
            depth: Global collapse depth (overrides per-section logic if set)
            filter_inner_depth: Collapse depth WITHIN matched sections only

        Returns:
            Rendered markdown with context preservation
        """
        lines = []

        def render_section(section: dict, is_ancestor: bool = False) -> None:
            level = section['level']
            text = section['text']
            is_matched = id(section) in matched_ids
            is_matched_ancestor = section.get('matched_ancestor', False)

            # Determine if this section should be collapsed
            should_collapse = False

            if depth is not None and level > depth:
                # Global depth always takes precedence
                should_collapse = True
            elif is_matched or is_matched_ancestor:
                # Matched sections and their ancestors shown expanded
                if filter_inner_depth is not None and is_matched:
                    # Only apply inner depth to matched sections (not ancestors)
                    should_collapse = level > filter_inner_depth
            else:
                # Non-matched, non-ancestor sections always collapse
                should_collapse = True

            # Render heading
            heading = f"{'#' * level} {text}"
            if should_collapse:
                # Show collapsed marker when collapsing
                lines.append(f"{heading} (collapsed)")
                return  # Skip content and children
            else:
                # Not collapsed - show fully expanded
                lines.append(heading)
                # Render content
                lines.extend(section.get('content', []))
                # Render children
                for child in section.get('children', []):
                    render_section(child)

        # Render all top-level sections
        for section in sections:
            render_section(section)

        return "\n".join(lines)
