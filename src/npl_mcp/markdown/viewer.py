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
        - ### Inner Content 📦  - heading text shown but marked as collapsed
        - #### Deep Content 📦   - only first level below shown, others hidden

        Content under collapsed headings is hidden.

        Args:
            content: Markdown content
            depth: Show headings up to this level expanded, collapse below

        Returns:
            Markdown with collapsed indicators (📦 emoji) for levels > depth
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
                        # First level below threshold - show heading with emoji marker
                        heading_prefix = "#" * level
                        lines.append(f"{heading_prefix} {heading_text} 📦")
                        in_collapsed_section = True
                        collapsed_section_depth = level
                    elif level < collapsed_section_depth:
                        # Return to a shallower collapsed level - show but mark as collapsed
                        heading_prefix = "#" * level
                        lines.append(f"{heading_prefix} {heading_text} 📦")
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
        - Matched ancestors: ALWAYS shown expanded to provide navigation context
        - Other sections: shown as collapsed with emoji marker

        Args:
            sections: Full document structure (list of section dicts)
            matched_ids: Set of IDs of matched sections
            depth: Global collapse depth (applies to non-matched siblings)
            filter_inner_depth: Collapse depth WITHIN matched sections only

        Returns:
            Rendered markdown with context preservation and emoji markers
        """
        lines = []
        COLLAPSED_EMOJI = "📦"  # Emoji to indicate collapsed section

        def render_section(section: dict, is_inside_matched: bool = False) -> None:
            level = section['level']
            text = section['text']
            is_matched = id(section) in matched_ids
            is_matched_ancestor = section.get('matched_ancestor', False)

            # Determine if this section should be collapsed
            should_collapse = False

            if is_matched_ancestor:
                # ANCESTORS ALWAYS SHOWN EXPANDED - never collapse
                should_collapse = False
            elif is_matched:
                # MATCHED SECTIONS ALWAYS SHOWN EXPANDED
                # (they are the focal point of the filter)
                should_collapse = False
            else:
                # Non-matched section - check if should collapse
                # Global depth always takes precedence
                if depth is not None and level > depth:
                    should_collapse = True
                elif is_inside_matched:
                    # Inside a matched section (and depth didn't force collapse)
                    if filter_inner_depth is not None:
                        # Use filter_inner_depth to control collapse
                        should_collapse = level > filter_inner_depth
                    # else: no filter_inner_depth, show all children expanded
                elif len(matched_ids) > 0:
                    # Filtering mode - collapse all non-matched (not inside matched)
                    should_collapse = True

            # Render heading
            heading = f"{'#' * level} {text}"
            if should_collapse:
                # Show collapsed marker with emoji
                lines.append(f"{heading} {COLLAPSED_EMOJI}")
                return  # Skip content and children
            else:
                # Not collapsed - show fully expanded
                lines.append(heading)
                # Render content
                lines.extend(section.get('content', []))
                # Render children (pass flag if we're matched or already inside matched)
                for child in section.get('children', []):
                    render_section(child, is_inside_matched=is_matched or is_inside_matched)

        # Render all top-level sections
        for section in sections:
            render_section(section)

        return "\n".join(lines)
