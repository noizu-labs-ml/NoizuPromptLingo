"""
Layout strategies for formatting NPL components.

Provides different organization strategies for the output:
- YAML_ORDER: Preserve YAML definition order
- CLASSIC: Category-based organization
- GROUPED: Group by section type
"""

from enum import Enum
from typing import List, Dict, Any

from .resolver import ResolvedComponent


class LayoutStrategy(Enum):
    """Available layout strategies for output formatting."""
    YAML_ORDER = "yaml-order"      # Preserve YAML definition order
    CLASSIC = "classic"            # Category-based organization
    GROUPED = "grouped"            # Group by type/labels


class NPLLayoutEngine:
    """Formats resolved components into markdown output."""

    def __init__(self, strategy: LayoutStrategy = LayoutStrategy.YAML_ORDER):
        """Initialize with layout strategy.

        Args:
            strategy: The layout strategy to use
        """
        self.strategy = strategy

    def format(self, components: List[ResolvedComponent]) -> str:
        """Format components into markdown string.

        Args:
            components: List of resolved components to format

        Returns:
            Markdown formatted string with all components
        """
        if not components:
            return ""

        if self.strategy == LayoutStrategy.YAML_ORDER:
            return self._format_yaml_order(components)
        elif self.strategy == LayoutStrategy.CLASSIC:
            return self._format_classic(components)
        elif self.strategy == LayoutStrategy.GROUPED:
            return self._format_grouped(components)
        else:
            # Default to YAML order
            return self._format_yaml_order(components)

    def _format_yaml_order(self, components: List[ResolvedComponent]) -> str:
        """Format components in their original YAML order.

        Args:
            components: Components to format

        Returns:
            Markdown string
        """
        parts = []
        for comp in components:
            parts.append(self.format_component(comp))
        return "\n\n".join(parts)

    def _format_classic(self, components: List[ResolvedComponent]) -> str:
        """Format components organized by category/labels.

        Args:
            components: Components to format

        Returns:
            Markdown string
        """
        # Group by first label (if any), otherwise "Uncategorized"
        categories: Dict[str, List[ResolvedComponent]] = {}

        for comp in components:
            category = comp.labels[0] if comp.labels else "uncategorized"
            if category not in categories:
                categories[category] = []
            categories[category].append(comp)

        parts = []
        for category, comps in sorted(categories.items()):
            parts.append(f"## {category.title()}")
            for comp in comps:
                parts.append(self.format_component(comp))

        return "\n\n".join(parts)

    def _format_grouped(self, components: List[ResolvedComponent]) -> str:
        """Format components grouped by section type.

        Args:
            components: Components to format

        Returns:
            Markdown string
        """
        # Group by section
        groups: Dict[str, List[ResolvedComponent]] = {}

        for comp in components:
            section_name = comp.section.value
            if section_name not in groups:
                groups[section_name] = []
            groups[section_name].append(comp)

        parts = []
        for section_name, comps in groups.items():
            parts.append(f"## {section_name.replace('-', ' ').title()}")
            for comp in comps:
                parts.append(self.format_component(comp))

        return "\n\n".join(parts)

    def format_component(self, component: ResolvedComponent) -> str:
        """Format a single component to markdown.

        Args:
            component: The component to format

        Returns:
            Markdown string for this component
        """
        parts = []

        # Header with name and slug
        # Always include slug to enable lookup by slug in the output
        if component.slug:
            parts.append(f"### {component.name} (`{component.slug}`)")
        else:
            parts.append(f"### {component.name}")

        # Brief
        if component.brief:
            parts.append(f"*{component.brief}*")

        # Description
        if component.description:
            parts.append(component.description)

        # Syntax
        if component.syntax:
            parts.append("**Syntax:**")
            for syn in component.syntax:
                syn_text = syn.get('syntax', syn.get('name', ''))
                parts.append(f"- `{syn_text}`")

        # Examples
        if component.examples:
            parts.append("**Examples:**")
            parts.append(self.format_examples(component.examples))

        # Labels
        if component.labels:
            labels_str = ", ".join(f"`{l}`" for l in component.labels)
            parts.append(f"*Labels: {labels_str}*")

        # Requirements
        if component.require:
            requires_str = ", ".join(f"`{r}`" for r in component.require)
            parts.append(f"*Requires: {requires_str}*")

        return "\n\n".join(parts)

    def format_examples(self, examples: List[Dict[str, Any]]) -> str:
        """Format component examples to markdown.

        Args:
            examples: List of example dictionaries

        Returns:
            Markdown string with formatted examples
        """
        if not examples:
            return ""

        parts = []
        for example in examples:
            name = example.get('name', 'Example')
            brief = example.get('brief', '')
            priority = example.get('priority', 0)

            if brief:
                parts.append(f"- **{name}**: {brief} (priority {priority})")
            else:
                parts.append(f"- **{name}** (priority {priority})")

        return "\n".join(parts)
