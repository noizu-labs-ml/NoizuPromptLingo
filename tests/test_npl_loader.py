#!/usr/bin/env python3
"""Tests for NPL Loader data reconstruction."""

import pytest
import yaml
from typing import Dict, List, Set

# Import the functions we want to test
import sys
sys.path.insert(0, str(__file__).rsplit("/tests/", 1)[0] + "/tools")

from npl.yaml_ops import YAMLLoader

# Use the static method from YAMLLoader
slugify = YAMLLoader.slugify


def reconstruct_section_from_db(
    section_id: str,
    section_value: Dict,
    components: List[Dict]
) -> Dict:
    """Reconstruct a section's data structure from database values.

    This simulates what load_from_database does for a single section.

    Args:
        section_id: The section's id (slug)
        section_value: The section's value field from npl_sections table
        components: List of component value fields from npl_component table

    Returns:
        Dict with structure: {section_id: {"content": {...}}}
    """
    # Separate components and instructional items based on _instructional flag
    regular_components = []
    instructional = []

    for item in components:
        if item.get("_instructional"):
            # Remove the internal flag before adding
            item_copy = {k: v for k, v in item.items() if k != "_instructional"}
            instructional.append(item_copy)
        else:
            regular_components.append(item)

    content = {
        "name": section_value.get("name", section_id),
        "slug": section_id,
        "brief": section_value.get("brief", ""),
        "description": section_value.get("description", ""),
        "purpose": section_value.get("purpose", ""),
        "components": regular_components,
        "instructional": instructional,
    }

    return {section_id: {"content": content}}


def load_yaml_section(yaml_string: str) -> Dict:
    """Load a YAML string and structure it like load_all_yaml_files does.

    Args:
        yaml_string: YAML content for a section

    Returns:
        Dict with structure matching load_all_yaml_files output
    """
    parsed = yaml.safe_load(yaml_string)
    section_name = parsed.get("name", "test")
    section_slug = parsed.get("slug", slugify(section_name))

    return {section_slug: {"content": parsed}}


class TestReconstruction:
    """Test that database values can reconstruct YAML-loaded structure."""

    def test_simple_section_reconstruction(self):
        """Test reconstruction of a simple section with components."""
        yaml_content = """
name: test-syntax
slug: syntax
brief: Core syntax elements
description: Test description for syntax.
purpose: Test purpose statement.
components:
  - name: placeholder
    slug: placeholder
    brief: Variable substitution markers
    syntax: "{{variable}}"
    labels:
      - formatting
      - substitution
  - name: omission
    slug: omission
    brief: Content elision markers
    syntax: "[___|content]"
"""
        # Load from YAML
        yaml_data = load_yaml_section(yaml_content)

        # Simulate database values
        section_value = {
            "name": "test-syntax",
            "brief": "Core syntax elements",
            "description": "Test description for syntax.",
            "purpose": "Test purpose statement."
        }
        components = [
            {
                "name": "placeholder",
                "slug": "placeholder",
                "brief": "Variable substitution markers",
                "syntax": "{{variable}}",
                "labels": ["formatting", "substitution"]
            },
            {
                "name": "omission",
                "slug": "omission",
                "brief": "Content elision markers",
                "syntax": "[___|content]"
            }
        ]

        # Reconstruct from DB values
        db_data = reconstruct_section_from_db("syntax", section_value, components)

        # Verify structure matches
        assert "syntax" in db_data
        assert "content" in db_data["syntax"]

        yaml_content_obj = yaml_data["syntax"]["content"]
        db_content_obj = db_data["syntax"]["content"]

        assert db_content_obj["name"] == yaml_content_obj["name"]
        assert db_content_obj["slug"] == yaml_content_obj["slug"]
        assert db_content_obj["brief"] == yaml_content_obj["brief"]
        assert len(db_content_obj["components"]) == len(yaml_content_obj["components"])
        assert db_content_obj["components"][0]["name"] == yaml_content_obj["components"][0]["name"]
        assert db_content_obj["instructional"] == []

    def test_section_with_instructional_items(self):
        """Test reconstruction with instructional items separated."""
        yaml_content = """
name: declarations
slug: declarations
brief: Framework declarations
components:
  - name: npl-declaration
    slug: npl-declaration
    brief: Core NPL declaration block
    syntax: "⌜NPL@version⌝...⌞NPL@version⌟"
instructional:
  - name: Version Control Rules
    slug: version-control-rules
    type: usage-guideline
    brief: Rules for version handling
    references:
      - declarations.npl-declaration
"""
        # Load from YAML
        yaml_data = load_yaml_section(yaml_content)

        # Simulate database values - all items stored together with _instructional flag
        section_value = {
            "name": "declarations",
            "brief": "Framework declarations",
            "description": "",
            "purpose": ""
        }
        components = [
            {
                "name": "npl-declaration",
                "slug": "npl-declaration",
                "brief": "Core NPL declaration block",
                "syntax": "⌜NPL@version⌝...⌞NPL@version⌟"
            },
            {
                "name": "Version Control Rules",
                "slug": "version-control-rules",
                "type": "usage-guideline",
                "brief": "Rules for version handling",
                "references": ["declarations.npl-declaration"],
                "_instructional": True  # Flag set during sync
            }
        ]

        # Reconstruct from DB values
        db_data = reconstruct_section_from_db("declarations", section_value, components)

        db_content = db_data["declarations"]["content"]
        yaml_content_obj = yaml_data["declarations"]["content"]

        # Regular component should be in components
        assert len(db_content["components"]) == 1
        assert db_content["components"][0]["name"] == "npl-declaration"

        # Instructional item should be separated (without _instructional flag)
        assert len(db_content["instructional"]) == 1
        assert db_content["instructional"][0]["name"] == "Version Control Rules"
        assert db_content["instructional"][0]["type"] == "usage-guideline"
        assert "_instructional" not in db_content["instructional"][0]

        # Compare with YAML structure
        assert len(db_content["components"]) == len(yaml_content_obj["components"])
        assert len(db_content["instructional"]) == len(yaml_content_obj["instructional"])

    def test_instructional_flag_removal(self):
        """Test that _instructional flag is removed from reconstructed items."""
        section_value = {"name": "test", "brief": "", "description": "", "purpose": ""}

        components = [
            {"name": "Regular", "slug": "regular"},
            {"name": "Instructional", "slug": "instructional", "_instructional": True, "type": "guideline"}
        ]

        result = reconstruct_section_from_db("test", section_value, components)
        content = result["test"]["content"]

        # Regular component should not have flag
        assert "_instructional" not in content["components"][0]

        # Instructional item should have flag removed
        assert "_instructional" not in content["instructional"][0]
        assert content["instructional"][0]["type"] == "guideline"

    def test_empty_instructional(self):
        """Test section with no instructional items."""
        section_value = {"name": "test", "brief": "", "description": "", "purpose": ""}

        components = [
            {"name": "Component1", "slug": "comp1"},
            {"name": "Component2", "slug": "comp2"}
        ]

        result = reconstruct_section_from_db("test", section_value, components)
        content = result["test"]["content"]

        assert len(content["components"]) == 2
        assert content["instructional"] == []

    def test_all_instructional(self):
        """Test section with only instructional items."""
        section_value = {"name": "guidance", "brief": "", "description": "", "purpose": ""}

        components = [
            {"name": "Guide1", "slug": "guide1", "_instructional": True},
            {"name": "Guide2", "slug": "guide2", "_instructional": True}
        ]

        result = reconstruct_section_from_db("guidance", section_value, components)
        content = result["guidance"]["content"]

        assert content["components"] == []
        assert len(content["instructional"]) == 2


class TestSlugify:
    """Test the slugify function."""

    def test_basic_slugify(self):
        assert slugify("Hello World") == "hello-world"
        assert slugify("Test Name") == "test-name"

    def test_special_characters(self):
        assert slugify("Hello! World?") == "hello-world"
        assert slugify("Test (Name)") == "test-name"

    def test_multiple_spaces(self):
        assert slugify("Hello   World") == "hello-world"

    def test_underscores(self):
        assert slugify("hello_world") == "hello-world"

    def test_already_slug(self):
        assert slugify("hello-world") == "hello-world"


class TestYAMLDBRoundTrip:
    """Test full round-trip from YAML string to DB values and back."""

    def test_full_round_trip(self):
        """Test that YAML -> DB values -> reconstructed matches original."""
        yaml_content = """
name: Example Section
slug: example
brief: An example section for testing
description: |
  This is a longer description
  that spans multiple lines.
purpose: To demonstrate round-trip reconstruction.
components:
  - name: Widget
    slug: widget
    brief: A widget component
    syntax: "<widget />"
    labels:
      - ui
      - component
  - name: Gadget
    slug: gadget
    brief: A gadget component
    description: Does gadget things.
instructional:
  - name: Widget Best Practices
    slug: widget-best-practices
    type: best-practice
    brief: How to use widgets effectively
    references:
      - example.widget
"""
        # Load from YAML
        yaml_data = load_yaml_section(yaml_content)
        yaml_content_obj = yaml_data["example"]["content"]

        # Simulate what sync does - store section value and components
        section_value = {
            "name": yaml_content_obj["name"],
            "brief": yaml_content_obj.get("brief", ""),
            "description": yaml_content_obj.get("description", ""),
            "purpose": yaml_content_obj.get("purpose", "")
        }

        # Components stored with _instructional flag for instructional items
        db_components = []
        for comp in yaml_content_obj.get("components", []):
            db_components.append(comp.copy())
        for instr in yaml_content_obj.get("instructional", []):
            item = instr.copy()
            item["_instructional"] = True
            db_components.append(item)

        # Reconstruct from DB values
        reconstructed = reconstruct_section_from_db("example", section_value, db_components)
        recon_content = reconstructed["example"]["content"]

        # Verify structure matches
        assert recon_content["name"] == yaml_content_obj["name"]
        assert recon_content["brief"] == yaml_content_obj["brief"]
        assert len(recon_content["components"]) == len(yaml_content_obj["components"])
        assert len(recon_content["instructional"]) == len(yaml_content_obj["instructional"])

        # Verify component content
        assert recon_content["components"][0]["name"] == "Widget"
        assert recon_content["components"][1]["name"] == "Gadget"

        # Verify instructional content
        assert recon_content["instructional"][0]["name"] == "Widget Best Practices"
        assert recon_content["instructional"][0]["type"] == "best-practice"
        assert "_instructional" not in recon_content["instructional"][0]


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
