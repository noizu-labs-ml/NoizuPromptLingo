"""Markdown output generation."""

from typing import Dict, List, Optional, Set

from .config import DEFAULT_SECTION_ORDER
from .refs import ReferenceManager
from .yaml_ops import YAMLLoader


class Formatter:
    """Generate markdown output from NPL data."""

    def __init__(self, data: Dict[str, Dict], with_labels: bool = False):
        """Initialize formatter.

        Args:
            data: Dict from YAMLLoader.load_all() or load_from_database()
            with_labels: Whether to include taxonomy labels in output
        """
        self.data = data
        self.with_labels = with_labels
        self._refs = ReferenceManager(data)

    def format_output(self, with_instructional_notes: bool = False) -> str:
        """Generate complete NPL markdown document.

        Args:
            with_instructional_notes: Include instructional appendix

        Returns:
            Complete markdown document as string
        """
        lines = []

        # Header
        lines.append("\u231cNPL@1.0\u231d")  # ⌜NPL@1.0⌝
        lines.append("# Noizu Prompt Lingua (NPL)")
        lines.append("")
        lines.append("A modular, structured framework for advanced prompt engineering "
                     "and agent simulation with context-aware loading capabilities.")
        lines.append("")
        lines.append("**Convention**: Additional details and deep-dive instructions are "
                     "available under `${NPL_HOME}/npl/` and can be loaded on an as-needed basis.")
        lines.append("")

        # Get section order
        order_config = self._refs.get_section_order()
        component_order = order_config.get("components", DEFAULT_SECTION_ORDER["components"])

        # Process sections in order
        processed = set()
        for section_key in component_order:
            if section_key in self.data:
                lines.extend(self.format_section(section_key, self.data[section_key]))
                processed.add(section_key)

        # Process remaining sections (excluding npl metadata)
        for key, section_data in sorted(self.data.items()):
            if key not in processed and key != "npl":
                lines.extend(self.format_section(key, section_data))

        # Instructional notes
        if with_instructional_notes:
            notes_lines = self._format_instructional_notes(component_order)
            if notes_lines:
                lines.extend(notes_lines)

        # Footer
        lines.append("\u231eNPL@1.0\u231f")  # ⌞NPL@1.0⌟

        return "\n".join(lines)

    def format_section(self, name: str, data: dict, level: int = 2) -> List[str]:
        """Format a section to markdown.

        Args:
            name: Section key/slug
            data: Section data with "content" key
            level: Heading level

        Returns:
            List of markdown lines
        """
        lines = []
        content = data.get("content", {})
        heading = "#" * level

        section_name = content.get("name", name)
        lines.append(f"{heading} {section_name.title()}")
        lines.append("")

        brief = content.get("brief", "")
        if brief:
            lines.append(f"*{brief}*")
            lines.append("")

        description = content.get("description", "").strip()
        if description:
            lines.append(description)
            lines.append("")

        purpose = content.get("purpose", "").strip()
        if purpose:
            lines.append("**Purpose**:")
            lines.append(purpose)
            lines.append("")

        # Components
        for component in content.get("components", []):
            lines.extend(self.format_component(component, level + 1))

        # Concepts (for npl.yaml)
        concepts = content.get("concepts", [])
        if concepts:
            lines.append(f"{'#' * (level + 1)} Core Concepts")
            lines.append("")
            for concept in concepts:
                concept_name = concept.get("name", "")
                concept_desc = concept.get("description", "").strip().split("\n")[0]
                concept_purpose = concept.get("purpose", "").strip()
                lines.append(f"**{concept_name}**")
                lines.append(f": {concept_desc}")
                if concept_purpose:
                    lines.append(f"  *Purpose*: {concept_purpose.split('.')[0]}.")
                lines.append("")

        return lines

    def format_component(self, component: dict, level: int = 3) -> List[str]:
        """Format a component to markdown.

        Args:
            component: Component dict
            level: Heading level

        Returns:
            List of markdown lines
        """
        lines = []
        heading = "#" * level

        name = component.get("name", "Unknown")
        lines.append(f"{heading} {name}")
        lines.append("")

        brief = component.get("brief", "")
        if brief:
            lines.append(f"*{brief}*")
            lines.append("")

        description = component.get("description", "").strip()
        if description:
            lines.append(description)
            lines.append("")

        syntax = component.get("syntax")
        if syntax:
            if isinstance(syntax, str):
                lines.append("**Syntax**:")
                lines.append("```")
                lines.append(syntax.strip())
                lines.append("```")
                lines.append("")
            elif isinstance(syntax, list):
                lines.append("**Syntax**:")
                lines.append("")
                for s in syntax:
                    if isinstance(s, dict):
                        syn_name = s.get("name", "")
                        syn_syntax = s.get("syntax", "")
                        syn_desc = s.get("description", "")
                        if syn_name:
                            lines.append(f"- **{syn_name}**: `{syn_syntax}`")
                            if syn_desc:
                                lines.append(f"  - {syn_desc}")
                    else:
                        lines.append(f"- `{s}`")
                lines.append("")

        if self.with_labels:
            labels = component.get("labels", [])
            if labels:
                lines.append(f"**Labels**: {', '.join(f'`{l}`' for l in labels)}")
                lines.append("")

        # Priority 0 examples only
        examples = component.get("examples", [])
        priority0 = [e for e in examples if e.get("priority", 0) == 0]
        if priority0:
            lines.append("**Example**:")
            lines.append("")
            for ex in priority0:
                ex_example = ex.get("example", "")
                if ex_example:
                    lines.append("```")
                    lines.append(ex_example.strip())
                    lines.append("```")
                    lines.append("")

        return lines

    def _format_instructional_notes(self, section_order: List[str]) -> List[str]:
        """Format instructional notes appendix.

        Args:
            section_order: Ordered list of section names

        Returns:
            List of markdown lines, or empty if no instructional content
        """
        # Check if any section has instructional items
        has_instructional = any(
            section_data.get("content", {}).get("instructional", [])
            for section_data in self.data.values()
        )

        if not has_instructional:
            return []

        lines = []
        lines.append("")
        lines.append("---")
        lines.append("")
        lines.append("# Instructional Notes")
        lines.append("")
        lines.append("*Guidance on using NPL concepts and patterns.*")
        lines.append("")

        included = self._refs.get_included_components()

        # Process in order
        processed = set()
        for section_key in section_order:
            if section_key in self.data:
                section_lines = self._format_instructional_section(
                    section_key, self.data[section_key], included
                )
                if section_lines:
                    lines.extend(section_lines)
                    processed.add(section_key)

        # Process remaining
        for key, section_data in sorted(self.data.items()):
            if key not in processed:
                section_lines = self._format_instructional_section(key, section_data, included)
                if section_lines:
                    lines.extend(section_lines)

        return lines

    def _format_instructional_section(self, section_key: str, section_data: dict,
                                       included: Set[str], level: int = 2) -> List[str]:
        """Format instructional items from a section.

        Args:
            section_key: Section identifier
            section_data: Section data
            included: Set of included component IDs for filtering
            level: Heading level

        Returns:
            List of markdown lines, or empty if no items pass filter
        """
        content = section_data.get("content", {})
        section_name = content.get("name", section_key)
        section_slug = content.get("slug", YAMLLoader.slugify(section_name))

        # Section-level references filter
        section_refs = set(content.get("references", []))
        if section_refs and not section_refs.intersection(included):
            return []

        instructional = content.get("instructional", [])

        # Filter by references
        items = []
        for item in instructional:
            refs = set(item.get("references", []))
            if not refs or refs.intersection(included):
                items.append(item)

        if not items:
            return []

        lines = []
        heading = "#" * level

        lines.append(f"{heading} {section_name}")
        lines.append("")

        brief = content.get("brief", "")
        if brief:
            lines.append(f"*{brief}*")
            lines.append("")

        for item in items:
            lines.extend(self._format_instructional_note(item, section_slug, level + 1))

        return lines

    def _format_instructional_note(self, item: dict, section_slug: str, level: int = 3) -> List[str]:
        """Format a single instructional note.

        Args:
            item: Instructional item dict
            section_slug: Parent section slug
            level: Heading level

        Returns:
            List of markdown lines
        """
        lines = []
        heading = "#" * level

        name = item.get("name", "Unknown")
        lines.append(f"{heading} {name}")
        lines.append("")

        refs = item.get("references", [])
        if refs:
            ref_links = ", ".join(f"`{r}`" for r in refs)
            lines.append(f"**References**: {ref_links}")
            lines.append("")

        brief = item.get("brief", "")
        if brief:
            lines.append(f"*{brief}*")
            lines.append("")

        purpose = item.get("purpose", "").strip()
        if purpose:
            lines.append(purpose)
            lines.append("")

        content = item.get("content", "").strip()
        if content:
            lines.append(content)
            lines.append("")

        # Priority 0 and 1 examples
        examples = item.get("examples", [])
        relevant = [e for e in examples if e.get("priority", 0) <= 1]
        if relevant:
            lines.append("**Example**:")
            lines.append("")
            for ex in relevant[:2]:
                ex_brief = ex.get("brief", "")
                if ex_brief:
                    lines.append(f"*{ex_brief}*")
                ex_example = ex.get("example", "")
                if ex_example:
                    lines.append("```")
                    lines.append(ex_example.strip())
                    lines.append("```")
                    lines.append("")

        return lines
