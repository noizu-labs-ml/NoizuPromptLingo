"""
NPL Section Resolver.

Resolves NPL expressions to component data by loading YAML files
and applying filters.
"""

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Any, List, Optional
import yaml
import logging

from .parser import NPLSection, NPLExpression, NPLComponent
from .filters import filter_by_priority
from .exceptions import NPLResolveError

logger = logging.getLogger(__name__)


@dataclass
class ResolvedComponent:
    """A resolved NPL component with its data."""
    section: NPLSection
    name: str
    slug: str
    brief: str
    description: str
    syntax: List[Dict[str, Any]]
    examples: List[Dict[str, Any]]
    labels: List[str]
    require: List[str]
    priority_filtered: bool  # True if examples were filtered by priority


# Mapping from section enum to YAML filename
_SECTION_FILES = {
    NPLSection.SYNTAX: "syntax.yaml",
    NPLSection.DECLARATIONS: "declarations.yaml",
    NPLSection.DIRECTIVES: "directives.yaml",
    NPLSection.PREFIXES: "prefixes.yaml",
    NPLSection.PROMPT_SECTIONS: "prompt-sections.yaml",
    NPLSection.SPECIAL_SECTIONS: "special-sections.yaml",
    NPLSection.PUMPS: "pumps.yaml",
    NPLSection.FENCES: "fences.yaml",
}


class NPLResolver:
    """Resolves NPL expressions to component data."""

    def __init__(self, npl_dir: Path):
        """Initialize resolver with path to NPL YAML files.

        Args:
            npl_dir: Path to directory containing NPL YAML files
        """
        self.npl_dir = Path(npl_dir)
        self._cache: Dict[NPLSection, Dict[str, Any]] = {}

    def _load_section(self, section: NPLSection) -> Dict[str, Any]:
        """Load and cache a section's YAML data.

        Args:
            section: The section to load

        Returns:
            Parsed YAML data

        Raises:
            NPLResolveError: If file not found or invalid YAML
        """
        # Return cached data if available
        if section in self._cache:
            return self._cache[section]

        filename = _SECTION_FILES[section]
        filepath = self.npl_dir / filename

        if not filepath.exists():
            raise NPLResolveError(
                f"Section file not found: {filename}. "
                f"Expected at: {filepath}"
            )

        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
        except yaml.YAMLError as e:
            raise NPLResolveError(
                f"Invalid YAML in {filename}: {str(e)}"
            )

        # Cache the loaded data
        self._cache[section] = data
        return data

    def get_section_components(self, section: NPLSection) -> List[str]:
        """Get list of component slugs in a section.

        Args:
            section: The section to query

        Returns:
            List of component slugs
        """
        data = self._load_section(section)
        components = data.get('components', [])
        return [c.get('slug', '') for c in components if c.get('slug')]

    def validate_component(self, section: NPLSection, component: str) -> bool:
        """Check if component exists in section.

        Args:
            section: The section to check
            component: The component slug to validate

        Returns:
            True if component exists, False otherwise
        """
        slugs = self.get_section_components(section)
        return component in slugs

    def _resolve_component(
        self,
        section: NPLSection,
        component_data: Dict[str, Any],
        priority_max: Optional[int]
    ) -> ResolvedComponent:
        """Convert raw component data to ResolvedComponent.

        Args:
            section: The section this component belongs to
            component_data: Raw component data from YAML
            priority_max: Maximum priority for filtering examples (None = no filter)

        Returns:
            ResolvedComponent with filtered examples
        """
        examples = component_data.get('examples', [])
        priority_filtered = False

        # Apply priority filter if specified
        if priority_max is not None:
            examples = filter_by_priority(examples, priority_max)
            priority_filtered = True

        return ResolvedComponent(
            section=section,
            name=component_data.get('name', ''),
            slug=component_data.get('slug', ''),
            brief=component_data.get('brief', ''),
            description=component_data.get('description', ''),
            syntax=component_data.get('syntax', []),
            examples=examples,
            labels=component_data.get('labels', []),
            require=component_data.get('require', []),
            priority_filtered=priority_filtered,
        )

    def _resolve_single(self, component: NPLComponent) -> List[ResolvedComponent]:
        """Resolve a single NPLComponent to ResolvedComponent(s).

        Args:
            component: The component to resolve

        Returns:
            List of ResolvedComponent (one if specific component, many if entire section)

        Raises:
            NPLResolveError: If component not found
        """
        data = self._load_section(component.section)
        components_data = data.get('components', [])

        if component.component is None:
            # Load entire section
            return [
                self._resolve_component(
                    component.section,
                    comp_data,
                    component.priority_max
                )
                for comp_data in components_data
            ]
        else:
            # Load specific component
            for comp_data in components_data:
                if comp_data.get('slug') == component.component:
                    return [
                        self._resolve_component(
                            component.section,
                            comp_data,
                            component.priority_max
                        )
                    ]

            # Component not found
            available = self.get_section_components(component.section)
            raise NPLResolveError(
                f"Component '{component.component}' not found in section '{component.section.value}'. "
                f"Available components: {', '.join(available)}"
            )

    def resolve(self, expression: NPLExpression) -> List[ResolvedComponent]:
        """Resolve expression to list of components.

        Applies additions first, then subtractions.
        Validates all component references exist.

        Args:
            expression: The parsed expression to resolve

        Returns:
            List of resolved components

        Raises:
            NPLResolveError: If component not found
        """
        # Track components by (section, slug) to handle additions/subtractions
        components_map: Dict[tuple, ResolvedComponent] = {}

        # Process additions
        for addition in expression.additions:
            resolved = self._resolve_single(addition)
            for comp in resolved:
                key = (comp.section, comp.slug)
                # Later additions can override earlier ones (for re-adding)
                components_map[key] = comp

        # Process subtractions
        for subtraction in expression.subtractions:
            if subtraction.component is None:
                # Subtract entire section
                keys_to_remove = [
                    key for key in components_map
                    if key[0] == subtraction.section
                ]
                for key in keys_to_remove:
                    del components_map[key]
            else:
                # Subtract specific component
                key = (subtraction.section, subtraction.component)
                if key in components_map:
                    del components_map[key]
                else:
                    # Subtracting something not loaded - warn but don't error
                    logger.warning(
                        f"Cannot subtract '{subtraction.component}' from '{subtraction.section.value}' "
                        "- not in loaded set. Ignoring."
                    )

        # Return components in a stable order
        # Preserve the order from additions (first occurrence)
        result = []
        seen = set()
        for addition in expression.additions:
            if addition.component is None:
                # Entire section - add all in YAML order
                try:
                    data = self._load_section(addition.section)
                    for comp_data in data.get('components', []):
                        slug = comp_data.get('slug', '')
                        key = (addition.section, slug)
                        if key in components_map and key not in seen:
                            result.append(components_map[key])
                            seen.add(key)
                except NPLResolveError:
                    pass  # Section might have been fully subtracted
            else:
                # Specific component
                key = (addition.section, addition.component)
                if key in components_map and key not in seen:
                    result.append(components_map[key])
                    seen.add(key)

        return result
