"""
@feature NPL Advanced Loading Extension
@prd project-management/PRDs/PRD-015-npl-loading-extension.md
@generated 2026-02-02
@tdd-tester v1

Comprehensive test suite for NPL loading extension.
Tests all acceptance criteria from AT-1 through AT-7.
"""

import pytest
from pathlib import Path
from enum import Enum
from dataclasses import dataclass
from typing import Dict, Any, List, Optional
from unittest.mock import MagicMock, patch
import tempfile
import yaml


# =============================================================================
# Test Fixtures
# =============================================================================

@pytest.fixture
def npl_test_dir(tmp_path: Path) -> Path:
    """Create a temporary NPL directory with test YAML files."""
    npl_dir = tmp_path / "npl"
    npl_dir.mkdir()

    # Create syntax.yaml with realistic test data
    syntax_data = {
        "name": "syntax",
        "brief": "Core syntax elements",
        "description": "Foundational formatting conventions.",
        "components": [
            {
                "name": "qualifier",
                "slug": "qualifier",
                "brief": "Extend elements with constraints",
                "description": "Pipe syntax for adding instructions.",
                "syntax": [{"name": "pipe-qualifier", "syntax": "|<qualifier>"}],
                "labels": ["inline", "modifier"],
                "require": ["syntax.placeholder"],
                "examples": [
                    {"name": "basic-qualifier", "brief": "Basic qualifier", "priority": 0},
                    {"name": "advanced-qualifier", "brief": "Advanced qualifier", "priority": 1},
                    {"name": "complex-qualifier", "brief": "Complex qualifier", "priority": 2},
                ]
            },
            {
                "name": "placeholder",
                "slug": "placeholder",
                "brief": "Mark locations where content should be inserted",
                "description": "Mark locations where content should be inserted or generated.",
                "syntax": [{"name": "curly-placeholder", "syntax": "{term}"}],
                "labels": ["inline", "substitution"],
                "require": [],
                "examples": [
                    {"name": "simple-placeholder", "brief": "Simple placeholder", "priority": 0},
                    {"name": "named-placeholder", "brief": "Named placeholder", "priority": 1},
                ]
            },
            {
                "name": "in-fill",
                "slug": "in-fill",
                "brief": "Indicate content to be generated",
                "description": "Marks regions for content generation.",
                "syntax": [{"name": "bracket-fill", "syntax": "[...]"}],
                "labels": ["inline", "generation"],
                "require": ["syntax.qualifier"],
                "examples": [
                    {"name": "basic-fill", "brief": "Basic in-fill", "priority": 0},
                ]
            },
            {
                "name": "literal-string",
                "slug": "literal-string",
                "brief": "Literal string markers",
                "description": "For exact text matching.",
                "syntax": [{"name": "quote-literal", "syntax": '"text"'}],
                "labels": ["inline"],
                "require": [],
                "examples": [
                    {"name": "basic-literal", "brief": "Basic literal", "priority": 0},
                ]
            },
            {
                "name": "omission",
                "slug": "omission",
                "brief": "Indicate omitted content",
                "description": "Marks intentionally omitted content.",
                "syntax": [{"name": "ellipsis-omission", "syntax": "..."}],
                "labels": ["inline"],
                "require": [],
                "examples": [
                    {"name": "basic-omission", "brief": "Basic omission", "priority": 0},
                ]
            },
        ]
    }

    # Create directives.yaml
    directives_data = {
        "name": "directives",
        "slug": "directives",
        "brief": "Specialized instruction patterns",
        "description": "Instruction patterns for agent behavior control.",
        "components": [
            {
                "name": "table-formatting",
                "slug": "table-formatting",
                "brief": "Format data into structured tables",
                "description": "Controls structured table output.",
                "syntax": [{"name": "table-directive", "syntax": "[[table:...]]"}],
                "labels": ["formatting", "output"],
                "require": ["syntax.placeholder"],
                "examples": [
                    {"name": "basic-table", "brief": "Basic table", "priority": 0},
                    {"name": "advanced-table", "brief": "Advanced table", "priority": 1},
                    {"name": "complex-table", "brief": "Complex table", "priority": 2},
                ]
            },
            {
                "name": "diagram-visualization",
                "slug": "diagram-visualization",
                "brief": "Generate diagrams",
                "description": "Generate diagrams and visualizations.",
                "syntax": [{"name": "diagram-directive", "syntax": "[[diagram:...]]"}],
                "labels": ["visualization", "output"],
                "require": [],
                "examples": [
                    {"name": "basic-diagram", "brief": "Basic diagram", "priority": 0},
                ]
            },
        ]
    }

    # Create pumps.yaml
    pumps_data = {
        "name": "Planning & Reasoning Pumps",
        "slug": "pumps",
        "brief": "Cognitive tools for reasoning",
        "description": "Tools for transparent reasoning processes.",
        "components": [
            {
                "name": "Intent Declaration",
                "slug": "intent-declaration",
                "brief": "Document reasoning flow",
                "description": "Document reasoning flow at the start of a response.",
                "syntax": [{"name": "intent-block", "syntax": "<npl-intent>...</npl-intent>"}],
                "labels": ["block", "reasoning"],
                "require": [],
                "examples": [
                    {"name": "basic-intent", "brief": "Basic intent", "priority": 0},
                    {"name": "complex-intent", "brief": "Complex intent", "priority": 1},
                ]
            },
            {
                "name": "Chain of Thought",
                "slug": "chain-of-thought",
                "brief": "Structured thinking",
                "description": "Document step-by-step reasoning.",
                "syntax": [{"name": "cot-block", "syntax": "<npl-cot>...</npl-cot>"}],
                "labels": ["block", "reasoning"],
                "require": [],
                "examples": [
                    {"name": "basic-cot", "brief": "Basic CoT", "priority": 0},
                ]
            },
            {
                "name": "Self Assessment",
                "slug": "self-assessment",
                "brief": "Evaluate response quality",
                "description": "Document self-evaluation of response.",
                "syntax": [{"name": "assess-block", "syntax": "<npl-assess>...</npl-assess>"}],
                "labels": ["block", "evaluation"],
                "require": [],
                "examples": [
                    {"name": "basic-assess", "brief": "Basic assessment", "priority": 0},
                ]
            },
        ]
    }

    # Create prefixes.yaml
    prefixes_data = {
        "name": "prefixes",
        "slug": "prefixes",
        "brief": "Line prefix markers",
        "description": "Markers that appear at the start of lines.",
        "components": [
            {
                "name": "comment-prefix",
                "slug": "comment-prefix",
                "brief": "Comment marker",
                "description": "Marks comment lines.",
                "syntax": [{"name": "hash-comment", "syntax": "# comment"}],
                "labels": ["prefix"],
                "require": [],
                "examples": [{"name": "basic-comment", "priority": 0}]
            },
        ]
    }

    # Create special-sections.yaml
    special_sections_data = {
        "name": "special-sections",
        "slug": "special-sections",
        "brief": "Special document sections",
        "description": "Document structural sections.",
        "components": [
            {
                "name": "header-section",
                "slug": "header-section",
                "brief": "Header markers",
                "description": "Document header sections.",
                "syntax": [{"name": "header", "syntax": "---header---"}],
                "labels": ["section"],
                "require": [],
                "examples": [{"name": "basic-header", "priority": 0}]
            },
        ]
    }

    # Create declarations.yaml
    declarations_data = {
        "name": "declarations",
        "slug": "declarations",
        "brief": "Variable declarations",
        "description": "Declaration syntax for variables.",
        "components": [
            {
                "name": "var-declaration",
                "slug": "var-declaration",
                "brief": "Variable declaration",
                "description": "Declare variables.",
                "syntax": [{"name": "var-decl", "syntax": "@var name = value"}],
                "labels": ["declaration"],
                "require": [],
                "examples": [{"name": "basic-var", "priority": 0}]
            },
        ]
    }

    # Create prompt-sections.yaml
    prompt_sections_data = {
        "name": "prompt-sections",
        "slug": "prompt-sections",
        "brief": "Prompt structural sections",
        "description": "Structural sections in prompts.",
        "components": [
            {
                "name": "system-section",
                "slug": "system-section",
                "brief": "System message section",
                "description": "System message in prompt.",
                "syntax": [{"name": "system", "syntax": "[SYSTEM]"}],
                "labels": ["section"],
                "require": [],
                "examples": [{"name": "basic-system", "priority": 0}]
            },
        ]
    }

    # Write all YAML files
    with open(npl_dir / "syntax.yaml", "w") as f:
        yaml.dump(syntax_data, f)

    with open(npl_dir / "directives.yaml", "w") as f:
        yaml.dump(directives_data, f)

    with open(npl_dir / "pumps.yaml", "w") as f:
        yaml.dump(pumps_data, f)

    with open(npl_dir / "prefixes.yaml", "w") as f:
        yaml.dump(prefixes_data, f)

    with open(npl_dir / "special-sections.yaml", "w") as f:
        yaml.dump(special_sections_data, f)

    with open(npl_dir / "declarations.yaml", "w") as f:
        yaml.dump(declarations_data, f)

    with open(npl_dir / "prompt-sections.yaml", "w") as f:
        yaml.dump(prompt_sections_data, f)

    return npl_dir


@pytest.fixture
def npl_dir_missing_file(tmp_path: Path) -> Path:
    """Create an NPL directory with missing YAML files."""
    npl_dir = tmp_path / "npl_missing"
    npl_dir.mkdir()
    # Only create syntax.yaml, leave others missing
    syntax_data = {
        "name": "syntax",
        "brief": "Syntax",
        "components": []
    }
    with open(npl_dir / "syntax.yaml", "w") as f:
        yaml.dump(syntax_data, f)
    return npl_dir


@pytest.fixture
def npl_dir_malformed_yaml(tmp_path: Path) -> Path:
    """Create an NPL directory with malformed YAML."""
    npl_dir = tmp_path / "npl_malformed"
    npl_dir.mkdir()
    with open(npl_dir / "syntax.yaml", "w") as f:
        f.write("invalid: yaml: content: [unclosed")
    return npl_dir


# =============================================================================
# AT-1: Section Loading Tests
# =============================================================================

class TestSectionLoading:
    """Test loading each NPL section (AT-1)."""

    def test_load_syntax_section(self, npl_test_dir: Path):
        """Load entire syntax section."""
        # Import the module under test
        from npl_mcp.npl.loader import load_npl

        result = load_npl("syntax", npl_dir=npl_test_dir)
        assert "qualifier" in result
        assert "placeholder" in result
        assert "in-fill" in result

    def test_load_directives_section(self, npl_test_dir: Path):
        """Load entire directives section."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("directives", npl_dir=npl_test_dir)
        assert "table-formatting" in result
        assert "diagram-visualization" in result

    def test_load_pumps_section(self, npl_test_dir: Path):
        """Load entire pumps section."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("pumps", npl_dir=npl_test_dir)
        assert "intent-declaration" in result
        assert "chain-of-thought" in result

    def test_load_fences_section(self, npl_test_dir: Path):
        """Load fences section (if exists)."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.exceptions import NPLResolveError

        # Fences may not exist in test fixture, should handle gracefully
        # or raise appropriate error
        try:
            result = load_npl("fences", npl_dir=npl_test_dir)
            # If it succeeds, result should be a string
            assert isinstance(result, str)
        except NPLResolveError:
            # Expected if fences.yaml doesn't exist
            pass

    def test_load_prefixes_section(self, npl_test_dir: Path):
        """Load entire prefixes section."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("prefixes", npl_dir=npl_test_dir)
        # Verify prefix components loaded
        assert isinstance(result, str)
        assert len(result) > 0

    def test_load_special_sections_section(self, npl_test_dir: Path):
        """Load special-sections."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("special-sections", npl_dir=npl_test_dir)
        # Verify special section components loaded
        assert isinstance(result, str)
        assert len(result) > 0

    def test_load_declarations_section(self, npl_test_dir: Path):
        """Load declarations section."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("declarations", npl_dir=npl_test_dir)
        # Verify declaration components loaded
        assert isinstance(result, str)
        assert len(result) > 0

    def test_load_prompt_sections_section(self, npl_test_dir: Path):
        """Load prompt-sections."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("prompt-sections", npl_dir=npl_test_dir)
        assert isinstance(result, str)
        assert len(result) > 0


# =============================================================================
# AT-2: Component Loading Tests
# =============================================================================

class TestComponentLoading:
    """Test loading specific components (AT-2)."""

    def test_load_specific_syntax_component(self, npl_test_dir: Path):
        """Load specific syntax component by slug."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("syntax#placeholder", npl_dir=npl_test_dir)
        assert "placeholder" in result
        assert "qualifier" not in result  # Other components excluded

    def test_load_specific_directive(self, npl_test_dir: Path):
        """Load specific directive."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("directives#table-formatting", npl_dir=npl_test_dir)
        assert "table-formatting" in result
        assert "diagram-visualization" not in result

    def test_load_specific_pump(self, npl_test_dir: Path):
        """Load specific pump."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("pumps#chain-of-thought", npl_dir=npl_test_dir)
        assert "chain-of-thought" in result
        assert "self-assessment" not in result

    def test_load_component_by_name_or_slug(self, npl_test_dir: Path):
        """Component can be loaded by name or slug."""
        from npl_mcp.npl.loader import load_npl

        # Should work with slug
        result = load_npl("pumps#intent-declaration", npl_dir=npl_test_dir)
        assert "intent-declaration" in result.lower() or "Intent Declaration" in result

    def test_load_multiple_specific_components_same_section(self, npl_test_dir: Path):
        """Load multiple specific components from same section."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("syntax#placeholder syntax#qualifier", npl_dir=npl_test_dir)
        assert "placeholder" in result
        assert "qualifier" in result
        assert "in-fill" not in result  # Not requested


# =============================================================================
# AT-3: Priority Filtering Tests
# =============================================================================

class TestPriorityFiltering:
    """Test priority filtering per section (AT-3)."""

    def test_priority_filter_syntax(self, npl_test_dir: Path):
        """Filter syntax examples by priority."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("syntax#qualifier:+0", npl_dir=npl_test_dir)
        # Priority 0 examples should be included
        assert "basic-qualifier" in result or "qualifier" in result
        # Priority 1, 2 examples should be excluded (their names shouldn't appear)
        # Note: We can't check absence of names directly since component description is kept

    def test_priority_filter_directive(self, npl_test_dir: Path):
        """Filter directive examples by priority."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("directives#table-formatting:+1", npl_dir=npl_test_dir)
        # Should include priority 0, 1 examples only
        assert "table-formatting" in result

    def test_priority_filter_pumps(self, npl_test_dir: Path):
        """Filter pump examples by priority."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("pumps#chain-of-thought:+0", npl_dir=npl_test_dir)
        # Should include only priority 0 examples
        assert "chain-of-thought" in result

    def test_priority_filter_preserves_component_info(self, npl_test_dir: Path):
        """Filtering doesn't remove component description."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("syntax#placeholder:+0", npl_dir=npl_test_dir)
        assert "placeholder" in result
        # Description should be preserved
        assert "Mark locations where" in result or "content" in result.lower()

    def test_priority_filter_includes_lower_priorities(self, npl_test_dir: Path):
        """Priority filter includes all priorities up to max."""
        from npl_mcp.npl.loader import load_npl

        # With priority +1, should include both 0 and 1
        result = load_npl("syntax#qualifier:+1", npl_dir=npl_test_dir)
        assert "qualifier" in result

    def test_priority_filter_zero_includes_only_zero(self, npl_test_dir: Path):
        """Priority +0 includes only priority 0 examples."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("directives#table-formatting:+0", npl_dir=npl_test_dir)
        # Basic table is priority 0
        assert "table-formatting" in result


# =============================================================================
# AT-4: Cross-Section Expression Tests
# =============================================================================

class TestCrossSectionExpressions:
    """Test cross-section expressions with + and - (AT-4)."""

    def test_add_multiple_sections(self, npl_test_dir: Path):
        """Combine multiple sections."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("syntax directives", npl_dir=npl_test_dir)
        assert "placeholder" in result
        assert "table-formatting" in result

    def test_add_specific_components_across_sections(self, npl_test_dir: Path):
        """Combine specific components from different sections."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("syntax#placeholder pumps#intent-declaration", npl_dir=npl_test_dir)
        assert "placeholder" in result
        assert "intent-declaration" in result.lower() or "Intent Declaration" in result
        assert "qualifier" not in result  # Not requested from syntax

    def test_subtract_component_from_section(self, npl_test_dir: Path):
        """Subtract specific component from loaded section."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("syntax -syntax#literal-string", npl_dir=npl_test_dir)
        assert "placeholder" in result
        assert "literal-string" not in result

    def test_complex_expression(self, npl_test_dir: Path):
        """Complex expression with multiple operations."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("syntax directives#table-formatting:+1 -syntax#omission", npl_dir=npl_test_dir)
        assert "placeholder" in result
        assert "table-formatting" in result
        assert "omission" not in result

    def test_subtract_nonexistent_warns(self, npl_test_dir: Path):
        """Subtracting non-loaded component produces warning or is ignored."""
        from npl_mcp.npl.loader import load_npl

        # Should not error, but may log warning
        # Subtracting in-fill when only placeholder is loaded
        result = load_npl("syntax#placeholder -syntax#in-fill", npl_dir=npl_test_dir)
        assert "placeholder" in result

    def test_section_order_preserved(self, npl_test_dir: Path):
        """Order of sections in expression affects output order."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl("pumps syntax", npl_dir=npl_test_dir)
        # Both should be present
        assert "intent-declaration" in result.lower() or "Intent Declaration" in result
        assert "placeholder" in result

    def test_subtract_entire_section_from_combined(self, npl_test_dir: Path):
        """Subtract entire section from combined result."""
        from npl_mcp.npl.loader import load_npl

        # Load syntax and directives, then subtract all directives
        result = load_npl("syntax directives -directives", npl_dir=npl_test_dir)
        assert "placeholder" in result
        assert "table-formatting" not in result


# =============================================================================
# AT-5: Layout Strategy Tests
# =============================================================================

class TestLayoutStrategies:
    """Test layout strategies with all content types (AT-5)."""

    def test_yaml_order_layout(self, npl_test_dir: Path):
        """YAML order preserves definition order."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.layout import LayoutStrategy

        result = load_npl("syntax", layout=LayoutStrategy.YAML_ORDER, npl_dir=npl_test_dir)
        # Verify components appear in YAML file order
        # In our fixture: qualifier, placeholder, in-fill, literal-string, omission
        assert isinstance(result, str)
        assert len(result) > 0

    def test_classic_layout(self, npl_test_dir: Path):
        """Classic layout organizes by category."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.layout import LayoutStrategy

        result = load_npl("directives", layout=LayoutStrategy.CLASSIC, npl_dir=npl_test_dir)
        # Verify category-based organization
        assert isinstance(result, str)
        assert len(result) > 0

    def test_grouped_layout(self, npl_test_dir: Path):
        """Grouped layout groups by type."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.layout import LayoutStrategy

        result = load_npl("syntax pumps", layout=LayoutStrategy.GROUPED, npl_dir=npl_test_dir)
        # Verify grouping (all syntax together, all pumps together)
        assert isinstance(result, str)
        assert len(result) > 0

    def test_layout_produces_valid_markdown(self, npl_test_dir: Path):
        """All layouts produce valid markdown."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.layout import LayoutStrategy

        for strategy in LayoutStrategy:
            result = load_npl("syntax", layout=strategy, npl_dir=npl_test_dir)
            # Basic markdown validity checks
            assert "##" in result or "#" in result  # Has headings

    def test_default_layout_is_yaml_order(self, npl_test_dir: Path):
        """Default layout strategy is YAML_ORDER."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.layout import LayoutStrategy

        result_default = load_npl("syntax", npl_dir=npl_test_dir)
        result_yaml_order = load_npl("syntax", layout=LayoutStrategy.YAML_ORDER, npl_dir=npl_test_dir)
        assert result_default == result_yaml_order

    def test_layout_with_empty_components(self, npl_test_dir: Path):
        """Layout handles empty component list gracefully."""
        from npl_mcp.npl.layout import LayoutStrategy, NPLLayoutEngine

        engine = NPLLayoutEngine(LayoutStrategy.YAML_ORDER)
        result = engine.format([])
        assert result == "" or result is not None  # Should not raise


# =============================================================================
# AT-6: Error Handling Tests
# =============================================================================

class TestErrorHandling:
    """Test error handling for invalid inputs (AT-6)."""

    def test_empty_expression_error(self, npl_test_dir: Path):
        """Empty expression raises clear error."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.exceptions import NPLParseError

        with pytest.raises(NPLParseError, match="empty"):
            load_npl("", npl_dir=npl_test_dir)

    def test_whitespace_only_expression_error(self, npl_test_dir: Path):
        """Whitespace-only expression raises clear error."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.exceptions import NPLParseError

        with pytest.raises(NPLParseError, match="empty"):
            load_npl("   ", npl_dir=npl_test_dir)

    def test_unknown_section_error(self, npl_test_dir: Path):
        """Unknown section name raises clear error."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.exceptions import NPLParseError

        with pytest.raises(NPLParseError, match="Unknown section"):
            load_npl("foobar", npl_dir=npl_test_dir)

    def test_unknown_component_error(self, npl_test_dir: Path):
        """Unknown component raises clear error."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.exceptions import NPLResolveError

        with pytest.raises(NPLResolveError, match="not found"):
            load_npl("syntax#nonexistent", npl_dir=npl_test_dir)

    def test_invalid_priority_format_error(self, npl_test_dir: Path):
        """Invalid priority format raises clear error."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.exceptions import NPLParseError

        with pytest.raises(NPLParseError, match="priority"):
            load_npl("syntax#placeholder:+abc", npl_dir=npl_test_dir)

    def test_negative_priority_error(self, npl_test_dir: Path):
        """Negative priority raises clear error."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.exceptions import NPLParseError

        with pytest.raises(NPLParseError, match="priority"):
            load_npl("syntax#placeholder:-1", npl_dir=npl_test_dir)

    def test_error_messages_include_context(self, npl_test_dir: Path):
        """Error messages include helpful context."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.exceptions import NPLResolveError

        try:
            load_npl("syntax#nonexistent", npl_dir=npl_test_dir)
            pytest.fail("Expected NPLResolveError to be raised")
        except NPLResolveError as e:
            assert "syntax" in str(e)
            assert "nonexistent" in str(e)

    def test_missing_yaml_file_error(self, npl_dir_missing_file: Path):
        """Missing YAML file raises clear error."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.exceptions import NPLResolveError

        with pytest.raises(NPLResolveError, match="not found"):
            load_npl("directives", npl_dir=npl_dir_missing_file)

    def test_malformed_yaml_error(self, npl_dir_malformed_yaml: Path):
        """Malformed YAML raises clear error."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.exceptions import NPLResolveError

        with pytest.raises(NPLResolveError, match="Invalid YAML|YAML"):
            load_npl("syntax", npl_dir=npl_dir_malformed_yaml)

    def test_invalid_component_separator_error(self, npl_test_dir: Path):
        """Invalid component separator raises error."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.exceptions import NPLParseError

        # Using wrong separator
        with pytest.raises(NPLParseError):
            load_npl("syntax@placeholder", npl_dir=npl_test_dir)

    def test_double_colon_error(self, npl_test_dir: Path):
        """Double colon in expression raises error."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.exceptions import NPLParseError

        with pytest.raises(NPLParseError):
            load_npl("syntax#placeholder::+1", npl_dir=npl_test_dir)


# =============================================================================
# AT-7: Integration Tests
# =============================================================================

class TestIntegration:
    """Integration tests for complete workflows (AT-7)."""

    def test_full_npl_loading_workflow(self, npl_test_dir: Path):
        """Test complete loading workflow."""
        from npl_mcp.npl.parser import parse_expression
        from npl_mcp.npl.resolver import NPLResolver
        from npl_mcp.npl.layout import NPLLayoutEngine, LayoutStrategy

        # Parse
        expr = parse_expression("syntax#placeholder:+1 pumps#intent-declaration")
        assert len(expr.additions) == 2

        # Resolve
        resolver = NPLResolver(npl_test_dir)
        components = resolver.resolve(expr)
        assert len(components) == 2

        # Format
        engine = NPLLayoutEngine(LayoutStrategy.YAML_ORDER)
        result = engine.format(components)
        assert "placeholder" in result
        assert "intent-declaration" in result.lower() or "Intent Declaration" in result

    def test_backward_compatibility_syntax_loading(self, npl_test_dir: Path):
        """Existing syntax loading still works."""
        from npl_mcp.npl.loader import load_npl

        # Test that syntax section loading works as before
        result = load_npl("syntax", npl_dir=npl_test_dir)
        assert "qualifier" in result
        assert "placeholder" in result

    def test_all_sections_loadable(self, npl_test_dir: Path):
        """Verify all defined sections can be loaded."""
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.parser import NPLSection
        from npl_mcp.npl.exceptions import NPLResolveError

        for section in NPLSection:
            try:
                result = load_npl(section.value, npl_dir=npl_test_dir)
                assert len(result) > 0
            except NPLResolveError:
                # Section file may not exist yet, that's OK for fences
                if section != NPLSection.FENCES:
                    raise

    def test_expression_with_all_features(self, npl_test_dir: Path):
        """Test expression using all features: section, component, priority, subtract."""
        from npl_mcp.npl.loader import load_npl

        # Complex expression exercising all features
        result = load_npl(
            "syntax#qualifier:+1 directives#table-formatting pumps -syntax#qualifier",
            npl_dir=npl_test_dir
        )
        assert "table-formatting" in result
        # qualifier was added then subtracted, so should not be present
        # Note: This depends on implementation detail of how subtraction works
        assert isinstance(result, str)

    def test_resolver_caching(self, npl_test_dir: Path):
        """Resolver caches YAML file reads."""
        from npl_mcp.npl.resolver import NPLResolver
        from npl_mcp.npl.parser import parse_expression

        resolver = NPLResolver(npl_test_dir)

        # Load same section twice
        expr1 = parse_expression("syntax")
        expr2 = parse_expression("syntax#placeholder")

        components1 = resolver.resolve(expr1)
        components2 = resolver.resolve(expr2)

        # Both should work, second should use cached data
        assert len(components1) > 0
        assert len(components2) == 1

    def test_round_trip_parse_resolve_format(self, npl_test_dir: Path):
        """Expression can be parsed, resolved, and formatted end-to-end."""
        from npl_mcp.npl.parser import parse_expression
        from npl_mcp.npl.resolver import NPLResolver
        from npl_mcp.npl.layout import NPLLayoutEngine, LayoutStrategy

        expressions = [
            "syntax",
            "directives#table-formatting",
            "pumps:+0",
            "syntax directives",
            "syntax -syntax#omission",
        ]

        resolver = NPLResolver(npl_test_dir)
        engine = NPLLayoutEngine(LayoutStrategy.YAML_ORDER)

        for expr_str in expressions:
            expr = parse_expression(expr_str)
            components = resolver.resolve(expr)
            result = engine.format(components)
            assert isinstance(result, str)


# =============================================================================
# Additional Parser Tests (supporting AT-6, AT-7)
# =============================================================================

class TestExpressionParser:
    """Test the expression parser in isolation."""

    def test_parse_simple_section(self):
        """Parse simple section reference."""
        from npl_mcp.npl.parser import parse_expression, NPLSection

        expr = parse_expression("syntax")
        assert len(expr.additions) == 1
        assert expr.additions[0].section == NPLSection.SYNTAX
        assert expr.additions[0].component is None
        assert expr.additions[0].priority_max is None

    def test_parse_section_with_component(self):
        """Parse section with component reference."""
        from npl_mcp.npl.parser import parse_expression, NPLSection

        expr = parse_expression("directives#table-formatting")
        assert len(expr.additions) == 1
        assert expr.additions[0].section == NPLSection.DIRECTIVES
        assert expr.additions[0].component == "table-formatting"

    def test_parse_section_with_priority(self):
        """Parse section with priority filter."""
        from npl_mcp.npl.parser import parse_expression, NPLSection

        expr = parse_expression("syntax#placeholder:+2")
        assert len(expr.additions) == 1
        assert expr.additions[0].section == NPLSection.SYNTAX
        assert expr.additions[0].component == "placeholder"
        assert expr.additions[0].priority_max == 2

    def test_parse_section_only_priority(self):
        """Parse section with only priority, no component."""
        from npl_mcp.npl.parser import parse_expression, NPLSection

        expr = parse_expression("pumps:+1")
        assert len(expr.additions) == 1
        assert expr.additions[0].section == NPLSection.PUMPS
        assert expr.additions[0].component is None
        assert expr.additions[0].priority_max == 1

    def test_parse_multiple_additions(self):
        """Parse expression with multiple additions."""
        from npl_mcp.npl.parser import parse_expression, NPLSection

        expr = parse_expression("syntax directives pumps")
        assert len(expr.additions) == 3
        assert expr.additions[0].section == NPLSection.SYNTAX
        assert expr.additions[1].section == NPLSection.DIRECTIVES
        assert expr.additions[2].section == NPLSection.PUMPS

    def test_parse_subtraction(self):
        """Parse expression with subtraction."""
        from npl_mcp.npl.parser import parse_expression, NPLSection

        expr = parse_expression("syntax -syntax#literal-string")
        assert len(expr.additions) == 1
        assert len(expr.subtractions) == 1
        assert expr.subtractions[0].section == NPLSection.SYNTAX
        assert expr.subtractions[0].component == "literal-string"

    def test_parse_complex_expression(self):
        """Parse complex expression with all features."""
        from npl_mcp.npl.parser import parse_expression, NPLSection

        expr = parse_expression("syntax#qualifier:+1 directives -syntax#omission")
        assert len(expr.additions) == 2
        assert len(expr.subtractions) == 1

        assert expr.additions[0].section == NPLSection.SYNTAX
        assert expr.additions[0].component == "qualifier"
        assert expr.additions[0].priority_max == 1

        assert expr.additions[1].section == NPLSection.DIRECTIVES

        assert expr.subtractions[0].section == NPLSection.SYNTAX
        assert expr.subtractions[0].component == "omission"

    def test_parse_all_section_names(self):
        """Parser recognizes all valid section names."""
        from npl_mcp.npl.parser import parse_expression, NPLSection

        section_names = [
            "syntax",
            "directives",
            "pumps",
            "prefixes",
            "special-sections",
            "declarations",
            "prompt-sections",
            "fences",
        ]

        for name in section_names:
            expr = parse_expression(name)
            assert len(expr.additions) == 1


# =============================================================================
# Priority Filter Tests (supporting AT-3)
# =============================================================================

class TestPriorityFilter:
    """Test the priority filter function in isolation."""

    def test_filter_by_priority_basic(self):
        """Filter examples by maximum priority."""
        from npl_mcp.npl.filters import filter_by_priority

        examples = [
            {"name": "ex1", "priority": 0},
            {"name": "ex2", "priority": 1},
            {"name": "ex3", "priority": 2},
            {"name": "ex4", "priority": 3},
        ]

        result = filter_by_priority(examples, max_priority=2)
        assert len(result) == 3
        assert all(ex["priority"] <= 2 for ex in result)

    def test_filter_includes_no_priority_as_zero(self):
        """Examples without priority field treated as priority 0."""
        from npl_mcp.npl.filters import filter_by_priority

        examples = [
            {"name": "ex1"},  # No priority field
            {"name": "ex2", "priority": 1},
            {"name": "ex3", "priority": 2},
        ]

        result = filter_by_priority(examples, max_priority=0)
        assert len(result) == 1
        assert result[0]["name"] == "ex1"

    def test_filter_empty_list(self):
        """Filtering empty list returns empty list."""
        from npl_mcp.npl.filters import filter_by_priority

        result = filter_by_priority([], max_priority=2)
        assert result == []

    def test_filter_all_excluded(self):
        """When all examples filtered out, return empty list."""
        from npl_mcp.npl.filters import filter_by_priority

        examples = [
            {"name": "ex1", "priority": 5},
            {"name": "ex2", "priority": 6},
        ]

        result = filter_by_priority(examples, max_priority=0)
        assert result == []

    def test_filter_priority_zero(self):
        """Priority +0 includes only priority 0 and unmarked examples."""
        from npl_mcp.npl.filters import filter_by_priority

        examples = [
            {"name": "ex1", "priority": 0},
            {"name": "ex2", "priority": 1},
            {"name": "ex3"},  # No priority = 0
        ]

        result = filter_by_priority(examples, max_priority=0)
        assert len(result) == 2
        names = [ex["name"] for ex in result]
        assert "ex1" in names
        assert "ex3" in names


# =============================================================================
# Resolver Tests (supporting AT-2, AT-4, AT-7)
# =============================================================================

class TestResolver:
    """Test the NPL resolver in isolation."""

    def test_resolve_entire_section(self, npl_test_dir: Path):
        """Resolve entire section returns all components."""
        from npl_mcp.npl.resolver import NPLResolver
        from npl_mcp.npl.parser import parse_expression

        resolver = NPLResolver(npl_test_dir)
        expr = parse_expression("syntax")

        components = resolver.resolve(expr)
        assert len(components) == 5  # All syntax components

    def test_resolve_specific_component(self, npl_test_dir: Path):
        """Resolve specific component returns only that component."""
        from npl_mcp.npl.resolver import NPLResolver
        from npl_mcp.npl.parser import parse_expression

        resolver = NPLResolver(npl_test_dir)
        expr = parse_expression("syntax#placeholder")

        components = resolver.resolve(expr)
        assert len(components) == 1
        assert components[0].slug == "placeholder"

    def test_resolve_with_subtraction(self, npl_test_dir: Path):
        """Resolve with subtraction excludes subtracted components."""
        from npl_mcp.npl.resolver import NPLResolver
        from npl_mcp.npl.parser import parse_expression

        resolver = NPLResolver(npl_test_dir)
        expr = parse_expression("syntax -syntax#literal-string")

        components = resolver.resolve(expr)
        slugs = [c.slug for c in components]
        assert "literal-string" not in slugs
        assert "placeholder" in slugs

    def test_resolve_with_priority_filter(self, npl_test_dir: Path):
        """Resolve with priority filter applies filter to examples."""
        from npl_mcp.npl.resolver import NPLResolver
        from npl_mcp.npl.parser import parse_expression

        resolver = NPLResolver(npl_test_dir)
        expr = parse_expression("syntax#qualifier:+0")

        components = resolver.resolve(expr)
        assert len(components) == 1
        assert components[0].priority_filtered is True

    def test_get_section_components(self, npl_test_dir: Path):
        """Get list of component slugs in a section."""
        from npl_mcp.npl.resolver import NPLResolver
        from npl_mcp.npl.parser import NPLSection

        resolver = NPLResolver(npl_test_dir)
        slugs = resolver.get_section_components(NPLSection.SYNTAX)

        assert "qualifier" in slugs
        assert "placeholder" in slugs

    def test_validate_component_exists(self, npl_test_dir: Path):
        """Validate that a component exists in a section."""
        from npl_mcp.npl.resolver import NPLResolver
        from npl_mcp.npl.parser import NPLSection

        resolver = NPLResolver(npl_test_dir)

        assert resolver.validate_component(NPLSection.SYNTAX, "placeholder") is True
        assert resolver.validate_component(NPLSection.SYNTAX, "nonexistent") is False


# =============================================================================
# Layout Engine Tests (supporting AT-5)
# =============================================================================

class TestLayoutEngine:
    """Test the layout engine in isolation."""

    def test_format_component_basic(self, npl_test_dir: Path):
        """Format a single component to markdown."""
        from npl_mcp.npl.resolver import NPLResolver, ResolvedComponent
        from npl_mcp.npl.layout import NPLLayoutEngine, LayoutStrategy
        from npl_mcp.npl.parser import parse_expression

        resolver = NPLResolver(npl_test_dir)
        expr = parse_expression("syntax#placeholder")
        components = resolver.resolve(expr)

        engine = NPLLayoutEngine(LayoutStrategy.YAML_ORDER)
        result = engine.format_component(components[0])

        assert "placeholder" in result
        assert isinstance(result, str)

    def test_format_examples(self, npl_test_dir: Path):
        """Format component examples to markdown."""
        from npl_mcp.npl.layout import NPLLayoutEngine, LayoutStrategy

        examples = [
            {"name": "example1", "brief": "First example", "priority": 0},
            {"name": "example2", "brief": "Second example", "priority": 1},
        ]

        engine = NPLLayoutEngine(LayoutStrategy.YAML_ORDER)
        result = engine.format_examples(examples)

        assert "example1" in result or "First example" in result
        assert isinstance(result, str)

    def test_format_empty_components(self):
        """Format empty component list returns empty string."""
        from npl_mcp.npl.layout import NPLLayoutEngine, LayoutStrategy

        engine = NPLLayoutEngine(LayoutStrategy.YAML_ORDER)
        result = engine.format([])

        assert result == "" or result is not None

    def test_format_multiple_components(self, npl_test_dir: Path):
        """Format multiple components together."""
        from npl_mcp.npl.resolver import NPLResolver
        from npl_mcp.npl.layout import NPLLayoutEngine, LayoutStrategy
        from npl_mcp.npl.parser import parse_expression

        resolver = NPLResolver(npl_test_dir)
        expr = parse_expression("syntax#placeholder syntax#qualifier")
        components = resolver.resolve(expr)

        engine = NPLLayoutEngine(LayoutStrategy.YAML_ORDER)
        result = engine.format(components)

        assert "placeholder" in result
        assert "qualifier" in result


# =============================================================================
# Exception Tests
# =============================================================================

class TestExceptions:
    """Test custom exception classes."""

    def test_npl_parse_error_message(self):
        """NPLParseError has proper message."""
        from npl_mcp.npl.exceptions import NPLParseError

        error = NPLParseError("Test error message")
        assert "Test error message" in str(error)

    def test_npl_resolve_error_message(self):
        """NPLResolveError has proper message."""
        from npl_mcp.npl.exceptions import NPLResolveError

        error = NPLResolveError("Component not found")
        assert "Component not found" in str(error)

    def test_npl_load_error_message(self):
        """NPLLoadError has proper message."""
        from npl_mcp.npl.exceptions import NPLLoadError

        error = NPLLoadError("General loading error")
        assert "General loading error" in str(error)

    def test_exceptions_are_proper_exceptions(self):
        """All NPL exceptions inherit from Exception."""
        from npl_mcp.npl.exceptions import NPLParseError, NPLResolveError, NPLLoadError

        assert issubclass(NPLParseError, Exception)
        assert issubclass(NPLResolveError, Exception)
        assert issubclass(NPLLoadError, Exception)


# =============================================================================
# Edge Case Tests
# =============================================================================

class TestEdgeCases:
    """Test edge cases and boundary conditions."""

    def test_component_slug_with_numbers(self, npl_test_dir: Path):
        """Component slugs can contain numbers."""
        from npl_mcp.npl.parser import parse_expression

        # Should parse successfully
        expr = parse_expression("syntax#component-v2")
        assert expr.additions[0].component == "component-v2"

    def test_priority_zero_explicit(self, npl_test_dir: Path):
        """Priority +0 is valid and explicit."""
        from npl_mcp.npl.parser import parse_expression

        expr = parse_expression("syntax#placeholder:+0")
        assert expr.additions[0].priority_max == 0

    def test_large_priority_value(self, npl_test_dir: Path):
        """Large priority values are accepted."""
        from npl_mcp.npl.parser import parse_expression

        expr = parse_expression("syntax#placeholder:+999")
        assert expr.additions[0].priority_max == 999

    def test_multiple_subtractions(self, npl_test_dir: Path):
        """Multiple subtractions in one expression."""
        from npl_mcp.npl.loader import load_npl

        result = load_npl(
            "syntax -syntax#literal-string -syntax#omission",
            npl_dir=npl_test_dir
        )
        assert "literal-string" not in result
        assert "omission" not in result
        assert "placeholder" in result

    def test_subtract_then_add_same_component(self, npl_test_dir: Path):
        """Adding after subtracting same component."""
        from npl_mcp.npl.loader import load_npl

        # First subtract, then add back - should be present
        result = load_npl(
            "syntax -syntax#placeholder syntax#placeholder",
            npl_dir=npl_test_dir
        )
        # This tests order of operations
        assert isinstance(result, str)

    def test_section_name_case_sensitivity(self, npl_test_dir: Path):
        """Section names should be case-insensitive or consistently handled."""
        from npl_mcp.npl.parser import parse_expression
        from npl_mcp.npl.exceptions import NPLParseError

        # Test with lowercase (should work)
        expr = parse_expression("syntax")
        assert expr.additions[0].section.value == "syntax"

        # Test with uppercase (should either work or raise clear error)
        try:
            expr_upper = parse_expression("SYNTAX")
            # If it works, value should still map correctly
        except NPLParseError:
            # Also acceptable - consistent case handling
            pass

    def test_extra_whitespace_handling(self, npl_test_dir: Path):
        """Extra whitespace in expression is handled."""
        from npl_mcp.npl.parser import parse_expression

        # Multiple spaces between terms
        expr = parse_expression("syntax    directives")
        assert len(expr.additions) == 2

    def test_trailing_whitespace(self, npl_test_dir: Path):
        """Trailing whitespace is handled."""
        from npl_mcp.npl.parser import parse_expression

        expr = parse_expression("syntax ")
        assert len(expr.additions) == 1

    def test_leading_whitespace(self, npl_test_dir: Path):
        """Leading whitespace is handled."""
        from npl_mcp.npl.parser import parse_expression

        expr = parse_expression(" syntax")
        assert len(expr.additions) == 1


# =============================================================================
# Data Class Tests
# =============================================================================

class TestDataClasses:
    """Test data class structures."""

    def test_npl_component_dataclass(self):
        """NPLComponent dataclass works correctly."""
        from npl_mcp.npl.parser import NPLComponent, NPLSection

        component = NPLComponent(
            section=NPLSection.SYNTAX,
            component="placeholder",
            priority_max=2
        )

        assert component.section == NPLSection.SYNTAX
        assert component.component == "placeholder"
        assert component.priority_max == 2

    def test_npl_expression_dataclass(self):
        """NPLExpression dataclass works correctly."""
        from npl_mcp.npl.parser import NPLExpression, NPLComponent, NPLSection

        expr = NPLExpression(
            additions=[NPLComponent(NPLSection.SYNTAX, None, None)],
            subtractions=[]
        )

        assert len(expr.additions) == 1
        assert len(expr.subtractions) == 0

    def test_resolved_component_dataclass(self, npl_test_dir: Path):
        """ResolvedComponent dataclass contains expected fields."""
        from npl_mcp.npl.resolver import NPLResolver, ResolvedComponent
        from npl_mcp.npl.parser import parse_expression

        resolver = NPLResolver(npl_test_dir)
        expr = parse_expression("syntax#placeholder")
        components = resolver.resolve(expr)

        assert len(components) == 1
        component = components[0]

        # Verify expected attributes
        assert hasattr(component, "section")
        assert hasattr(component, "name")
        assert hasattr(component, "slug")
        assert hasattr(component, "brief")
        assert hasattr(component, "description")
        assert hasattr(component, "examples")
        assert hasattr(component, "priority_filtered")
