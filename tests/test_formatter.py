"""Tests for formatter module (Formatter class)."""

import pytest
from pathlib import Path

import sys
sys.path.insert(0, str(Path(__file__).parent.parent / "tools"))

from npl.formatter import Formatter


class TestFormatterInit:
    """Test Formatter initialization."""

    def test_init_with_data(self):
        """Should accept data dict."""
        data = {"syntax": {"content": {"name": "Syntax"}}}
        fmt = Formatter(data)
        assert fmt.data == data
        assert fmt.with_labels is False

    def test_init_with_labels(self):
        """Should accept with_labels flag."""
        fmt = Formatter({}, with_labels=True)
        assert fmt.with_labels is True


class TestFormatComponent:
    """Test format_component method."""

    def test_includes_name_as_heading(self):
        """Should include component name as heading."""
        fmt = Formatter({})
        lines = fmt.format_component({"name": "Test Component"})
        assert any("### Test Component" in line for line in lines)

    def test_includes_brief(self):
        """Should include brief in italics."""
        fmt = Formatter({})
        lines = fmt.format_component({"name": "X", "brief": "Short desc"})
        assert any("*Short desc*" in line for line in lines)

    def test_includes_description(self):
        """Should include description."""
        fmt = Formatter({})
        lines = fmt.format_component({"name": "X", "description": "Full description here"})
        assert any("Full description" in line for line in lines)

    def test_includes_syntax_string(self):
        """Should format string syntax."""
        fmt = Formatter({})
        lines = fmt.format_component({"name": "X", "syntax": "{var}"})
        output = "\n".join(lines)
        assert "**Syntax**" in output
        assert "{var}" in output

    def test_includes_syntax_list(self):
        """Should format list of syntax variants."""
        fmt = Formatter({})
        lines = fmt.format_component({
            "name": "X",
            "syntax": [
                {"name": "basic", "syntax": "{x}"},
                {"name": "advanced", "syntax": "{x|mod}"}
            ]
        })
        output = "\n".join(lines)
        assert "basic" in output
        assert "{x}" in output

    def test_includes_labels_when_enabled(self):
        """Should include labels when with_labels=True."""
        fmt = Formatter({}, with_labels=True)
        lines = fmt.format_component({"name": "X", "labels": ["tag1", "tag2"]})
        output = "\n".join(lines)
        assert "**Labels**" in output
        assert "tag1" in output

    def test_excludes_labels_by_default(self):
        """Should not include labels by default."""
        fmt = Formatter({}, with_labels=False)
        lines = fmt.format_component({"name": "X", "labels": ["tag1"]})
        output = "\n".join(lines)
        assert "Labels" not in output

    def test_includes_priority_0_examples(self):
        """Should include priority 0 examples."""
        fmt = Formatter({})
        lines = fmt.format_component({
            "name": "X",
            "examples": [
                {"priority": 0, "example": "example code"},
                {"priority": 1, "example": "skipped"}
            ]
        })
        output = "\n".join(lines)
        assert "example code" in output
        assert "skipped" not in output


class TestFormatSection:
    """Test format_section method."""

    def test_includes_section_name(self):
        """Should include section name as heading."""
        fmt = Formatter({})
        data = {"content": {"name": "Syntax Elements"}}
        lines = fmt.format_section("syntax", data)
        assert any("## Syntax Elements" in line for line in lines)

    def test_includes_components(self):
        """Should include formatted components."""
        fmt = Formatter({})
        data = {
            "content": {
                "name": "Syntax",
                "components": [{"name": "Placeholder"}]
            }
        }
        lines = fmt.format_section("syntax", data)
        output = "\n".join(lines)
        assert "Placeholder" in output


class TestFormatOutput:
    """Test format_output method."""

    def test_includes_npl_header(self):
        """Should start with NPL header."""
        fmt = Formatter({})
        output = fmt.format_output()
        assert "⌜NPL@1.0⌝" in output

    def test_includes_npl_footer(self):
        """Should end with NPL footer."""
        fmt = Formatter({})
        output = fmt.format_output()
        assert "⌞NPL@1.0⌟" in output

    def test_includes_title(self):
        """Should include main title."""
        fmt = Formatter({})
        output = fmt.format_output()
        assert "# Noizu Prompt Lingua" in output

    def test_includes_section_content(self):
        """Should include section content."""
        data = {
            "syntax": {
                "content": {
                    "name": "Syntax",
                    "components": [{"name": "Test Comp"}]
                }
            }
        }
        fmt = Formatter(data)
        output = fmt.format_output()
        assert "Syntax" in output
        assert "Test Comp" in output

    def test_instructional_notes_off_by_default(self):
        """Should not include instructional notes by default."""
        data = {
            "syntax": {
                "content": {
                    "name": "Syntax",
                    "components": [],
                    "instructional": [{"name": "Guide"}]
                }
            }
        }
        fmt = Formatter(data)
        output = fmt.format_output(with_instructional_notes=False)
        assert "Instructional Notes" not in output

    def test_instructional_notes_when_enabled(self):
        """Should include instructional notes when enabled."""
        data = {
            "syntax": {
                "content": {
                    "slug": "syntax",
                    "name": "Syntax",
                    "components": [{"name": "Comp", "slug": "comp"}],
                    "instructional": [
                        {"name": "Guide", "slug": "guide", "references": ["syntax.comp"]}
                    ]
                }
            }
        }
        fmt = Formatter(data)
        output = fmt.format_output(with_instructional_notes=True)
        assert "Instructional Notes" in output


class TestInstructionalFiltering:
    """Test instructional note filtering by references."""

    def test_filters_by_references(self):
        """Should only include instructional items with matching references."""
        data = {
            "syntax": {
                "content": {
                    "slug": "syntax",
                    "name": "Syntax",
                    "components": [{"name": "Included", "slug": "included"}],
                    "instructional": [
                        {"name": "Has Match", "slug": "has-match", "references": ["syntax.included"]},
                        {"name": "No Match", "slug": "no-match", "references": ["syntax.missing"]}
                    ]
                }
            }
        }
        fmt = Formatter(data)
        output = fmt.format_output(with_instructional_notes=True)
        assert "Has Match" in output
        assert "No Match" not in output

    def test_includes_items_without_references(self):
        """Should include instructional items with no references (generic guides)."""
        data = {
            "syntax": {
                "content": {
                    "slug": "syntax",
                    "name": "Syntax",
                    "components": [{"name": "Comp", "slug": "comp"}],
                    "instructional": [
                        {"name": "Generic Guide", "slug": "generic-guide"}
                    ]
                }
            }
        }
        fmt = Formatter(data)
        output = fmt.format_output(with_instructional_notes=True)
        assert "Generic Guide" in output


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
