"""Reference handling and validation."""

import sys
from typing import Dict, List, Set

from .config import DEFAULT_SECTION_ORDER
from .yaml_ops import YAMLLoader


class ReferenceManager:
    """Manages component references, validation, and section ordering."""

    def __init__(self, data: Dict[str, Dict]):
        """Initialize with loaded YAML data.

        Args:
            data: Dict from YAMLLoader.load_all() or load_from_database()
        """
        self.data = data

    def get_section_order(self) -> Dict[str, List[str]]:
        """Extract section order from npl.yaml config.

        Returns:
            Dict with "components" key containing ordered section names
        """
        npl_data = self.data.get("npl", {})
        content = npl_data.get("content", {})
        # npl.yaml may use "/npl" or "npl" as key
        npl_config = content.get("/npl", content.get("npl", {}))
        section_order = npl_config.get("section_order", {})

        if section_order:
            return {
                "components": section_order.get("components", DEFAULT_SECTION_ORDER["components"])
            }
        return DEFAULT_SECTION_ORDER.copy()

    def get_all_components(self) -> Set[str]:
        """Get all component IDs including instructional items.

        Returns:
            Set of component IDs in "section.slug" format
        """
        all_components = set()

        for key, section_data in self.data.items():
            content = section_data.get("content", {})
            section_slug = content.get("slug", YAMLLoader.slugify(content.get("name", key)))

            # Process both components and instructional items
            for component in content.get("components", []) + content.get("instructional", []):
                comp_slug = component.get("slug", YAMLLoader.slugify(component.get("name", "")))
                comp_id = f"{section_slug}.{comp_slug}"
                all_components.add(comp_id)

        return all_components

    def get_included_components(self) -> Set[str]:
        """Get component IDs from regular components only (not instructional).

        Used for reference filtering - instructional items should only show
        if their referenced components are in this set.

        Returns:
            Set of component IDs from 'components' lists only
        """
        included = set()

        for key, section_data in self.data.items():
            content = section_data.get("content", {})
            section_slug = content.get("slug", YAMLLoader.slugify(content.get("name", key)))

            for component in content.get("components", []):
                comp_slug = component.get("slug", YAMLLoader.slugify(component.get("name", "")))
                comp_id = f"{section_slug}.{comp_slug}"
                included.add(comp_id)

        return included

    def validate(self, output_warnings: bool = True) -> List[str]:
        """Validate all require and reference declarations.

        Args:
            output_warnings: If True, print warnings to stderr

        Returns:
            List of warning messages for invalid references
        """
        all_components = self.get_all_components()
        warnings = []

        for key, section_data in self.data.items():
            content = section_data.get("content", {})
            section_slug = content.get("slug", YAMLLoader.slugify(content.get("name", key)))

            for component in content.get("components", []) + content.get("instructional", []):
                comp_name = component.get("name", "unknown")
                comp_slug = component.get("slug", YAMLLoader.slugify(comp_name))
                comp_id = f"{section_slug}.{comp_slug}"

                # Check requires (supports legacy 'import' field)
                requires = component.get("require", component.get("import", []))
                for req in (requires or []):
                    if req not in all_components:
                        msg = f"Warning: {comp_id} requires '{req}' which does not exist"
                        warnings.append(msg)

                # Check references
                references = component.get("references", [])
                for ref in (references or []):
                    if ref not in all_components:
                        msg = f"Warning: {comp_id} references '{ref}' which does not exist"
                        warnings.append(msg)

        if output_warnings and warnings:
            for msg in warnings:
                print(msg, file=sys.stderr)

        return warnings

    def component_to_search_text(self, component: dict) -> str:
        """Convert component to text for vector embedding.

        Args:
            component: Component dict

        Returns:
            Plain text suitable for embedding generation
        """
        lines = []

        name = component.get("name", "")
        if name:
            lines.append(f"# {name}")

        brief = component.get("brief", "")
        if brief:
            lines.append(brief)

        description = component.get("description", "").strip()
        if description:
            lines.append(description)

        syntax = component.get("syntax")
        if syntax:
            if isinstance(syntax, str):
                lines.append(f"Syntax: {syntax.strip()}")
            elif isinstance(syntax, list):
                for s in syntax:
                    if isinstance(s, dict):
                        lines.append(f"Syntax: {s.get('syntax', '')}")

        labels = component.get("labels", [])
        if labels:
            lines.append(f"Labels: {', '.join(labels)}")

        return "\n".join(lines)
