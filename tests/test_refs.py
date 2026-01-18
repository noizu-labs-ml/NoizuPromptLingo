"""Tests for refs module (ReferenceManager class)."""

import pytest
from pathlib import Path

import sys
sys.path.insert(0, str(Path(__file__).parent.parent / "tools"))

from npl.refs import ReferenceManager
from npl.config import DEFAULT_SECTION_ORDER


class TestReferenceManagerInit:
    """Test ReferenceManager initialization."""

    def test_init_with_data(self):
        """Should accept data dict."""
        data = {"syntax": {"content": {"name": "Syntax", "components": []}}}
        rm = ReferenceManager(data)
        assert rm.data == data

    def test_init_empty_data(self):
        """Should accept empty data."""
        rm = ReferenceManager({})
        assert rm.data == {}


class TestGetSectionOrder:
    """Test section order extraction."""

    def test_returns_default_when_no_npl_section(self):
        """Should return default order when npl.yaml not in data."""
        data = {"syntax": {"content": {"name": "Syntax"}}}
        rm = ReferenceManager(data)
        order = rm.get_section_order()
        assert order == DEFAULT_SECTION_ORDER

    def test_extracts_order_from_npl_section(self):
        """Should extract section_order from npl.yaml."""
        data = {
            "npl": {
                "content": {
                    "npl": {
                        "section_order": {
                            "components": ["a", "b", "c"]
                        }
                    }
                }
            }
        }
        rm = ReferenceManager(data)
        order = rm.get_section_order()
        assert order["components"] == ["a", "b", "c"]


class TestGetAllComponents:
    """Test get_all_components method."""

    def test_empty_data(self):
        """Should return empty set for empty data."""
        rm = ReferenceManager({})
        assert rm.get_all_components() == set()

    def test_collects_components(self):
        """Should collect component IDs from all sections."""
        data = {
            "syntax": {
                "content": {
                    "name": "Syntax",
                    "slug": "syntax",
                    "components": [
                        {"name": "placeholder", "slug": "placeholder"},
                        {"name": "infill", "slug": "infill"}
                    ],
                    "instructional": []
                }
            }
        }
        rm = ReferenceManager(data)
        comps = rm.get_all_components()
        assert "syntax.placeholder" in comps
        assert "syntax.infill" in comps

    def test_includes_instructional_items(self):
        """Should include instructional items in component set."""
        data = {
            "syntax": {
                "content": {
                    "slug": "syntax",
                    "components": [{"name": "comp", "slug": "comp"}],
                    "instructional": [{"name": "guide", "slug": "guide"}]
                }
            }
        }
        rm = ReferenceManager(data)
        comps = rm.get_all_components()
        assert "syntax.comp" in comps
        assert "syntax.guide" in comps

    def test_generates_slug_if_missing(self):
        """Should generate slug from name if not provided."""
        data = {
            "syntax": {
                "content": {
                    "name": "Syntax Elements",
                    "components": [{"name": "Test Component"}],
                    "instructional": []
                }
            }
        }
        rm = ReferenceManager(data)
        comps = rm.get_all_components()
        assert "syntax-elements.test-component" in comps


class TestGetIncludedComponents:
    """Test get_included_components method."""

    def test_excludes_instructional(self):
        """Should only include regular components, not instructional."""
        data = {
            "syntax": {
                "content": {
                    "slug": "syntax",
                    "components": [{"name": "comp", "slug": "comp"}],
                    "instructional": [{"name": "guide", "slug": "guide"}]
                }
            }
        }
        rm = ReferenceManager(data)
        included = rm.get_included_components()
        assert "syntax.comp" in included
        assert "syntax.guide" not in included


class TestValidateReferences:
    """Test validate method."""

    def test_valid_references_no_warnings(self):
        """Should return empty list when all references valid."""
        data = {
            "syntax": {
                "content": {
                    "slug": "syntax",
                    "components": [
                        {"name": "comp1", "slug": "comp1"},
                        {"name": "comp2", "slug": "comp2", "require": ["syntax.comp1"]}
                    ],
                    "instructional": []
                }
            }
        }
        rm = ReferenceManager(data)
        warnings = rm.validate(output_warnings=False)
        assert warnings == []

    def test_invalid_require_generates_warning(self):
        """Should warn about missing required components."""
        data = {
            "syntax": {
                "content": {
                    "slug": "syntax",
                    "components": [
                        {"name": "comp", "slug": "comp", "require": ["missing.component"]}
                    ],
                    "instructional": []
                }
            }
        }
        rm = ReferenceManager(data)
        warnings = rm.validate(output_warnings=False)
        assert len(warnings) == 1
        assert "missing.component" in warnings[0]

    def test_invalid_reference_generates_warning(self):
        """Should warn about missing referenced components."""
        data = {
            "syntax": {
                "content": {
                    "slug": "syntax",
                    "components": [],
                    "instructional": [
                        {"name": "guide", "slug": "guide", "references": ["nonexistent.comp"]}
                    ]
                }
            }
        }
        rm = ReferenceManager(data)
        warnings = rm.validate(output_warnings=False)
        assert len(warnings) == 1
        assert "nonexistent.comp" in warnings[0]

    def test_supports_legacy_import_field(self):
        """Should check 'import' field for backwards compatibility."""
        data = {
            "syntax": {
                "content": {
                    "slug": "syntax",
                    "components": [
                        {"name": "comp", "slug": "comp", "import": ["missing.dep"]}
                    ],
                    "instructional": []
                }
            }
        }
        rm = ReferenceManager(data)
        warnings = rm.validate(output_warnings=False)
        assert len(warnings) == 1


class TestComponentToSearchText:
    """Test component_to_search_text method."""

    def test_includes_name(self):
        """Should include component name."""
        rm = ReferenceManager({})
        text = rm.component_to_search_text({"name": "Test Component"})
        assert "Test Component" in text

    def test_includes_brief(self):
        """Should include brief description."""
        rm = ReferenceManager({})
        text = rm.component_to_search_text({"name": "X", "brief": "Short desc"})
        assert "Short desc" in text

    def test_includes_syntax_string(self):
        """Should include string syntax."""
        rm = ReferenceManager({})
        text = rm.component_to_search_text({"name": "X", "syntax": "{var}"})
        assert "{var}" in text

    def test_includes_syntax_list(self):
        """Should include syntax from list of dicts."""
        rm = ReferenceManager({})
        text = rm.component_to_search_text({
            "name": "X",
            "syntax": [{"syntax": "pattern1"}, {"syntax": "pattern2"}]
        })
        assert "pattern1" in text
        assert "pattern2" in text

    def test_includes_labels(self):
        """Should include labels."""
        rm = ReferenceManager({})
        text = rm.component_to_search_text({"name": "X", "labels": ["tag1", "tag2"]})
        assert "tag1" in text
        assert "tag2" in text


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
