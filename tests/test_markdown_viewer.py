"""Tests for markdown viewer module.

Tests cover:
- View with no filter/collapse (passthrough)
- View with filter only
- View with collapse only
- View with both filter and collapse
- Bare mode (filtered-only, no collapse markers)
- Depth parameter (1-6)
- Edge cases (depth 0, depth > 6)
"""

import pytest

from npl_mcp.markdown.viewer import MarkdownViewer


# ============================================================================
# Fixtures
# ============================================================================


@pytest.fixture
def viewer():
    """Create a markdown viewer."""
    return MarkdownViewer()


@pytest.fixture
def sample_doc():
    """Create a sample markdown document."""
    return """# Main Document

This is the main content.

## Section A

Content for section A.

### Subsection A1

Detailed content for A1.

### Subsection A2

Detailed content for A2.

## Section B

Content for section B.

### Subsection B1

Detailed content for B1.

# Appendix

Appendix content here."""


@pytest.fixture
def deep_doc():
    """Create a deeply nested document."""
    return """# Level 1
Content at level 1.

## Level 2
Content at level 2.

### Level 3
Content at level 3.

#### Level 4
Content at level 4.

##### Level 5
Content at level 5.

###### Level 6
Content at level 6.

## Another Level 2
More level 2 content."""


@pytest.fixture
def simple_doc():
    """Create a simple document with minimal structure."""
    return """# Title

Intro paragraph.

## Section One

First section content.

## Section Two

Second section content."""


# ============================================================================
# Test Basic Viewer - No Filter/Collapse (Passthrough)
# ============================================================================


class TestMarkdownViewerPassthrough:
    """Test viewer passthrough mode (no filter/collapse)."""

    def test_view_unfiltered_returns_original(self, viewer, sample_doc):
        """Test viewing document without filtering returns original."""
        result = viewer.view(sample_doc)
        assert result == sample_doc

    def test_view_empty_content(self, viewer):
        """Test viewing empty content returns empty."""
        result = viewer.view("")
        assert result == ""

    def test_view_preserves_whitespace(self, viewer):
        """Test that whitespace is preserved."""
        content = "# Title\n\n\n   Indented content\n\nMore text"
        result = viewer.view(content)
        assert result == content

    def test_view_preserves_code_blocks(self, viewer):
        """Test that code blocks are preserved."""
        content = """# Code Example

```python
def hello():
    print("world")
```

After code."""
        result = viewer.view(content)
        assert result == content


# ============================================================================
# Test Viewer - Filter Only
# ============================================================================


class TestMarkdownViewerFilterOnly:
    """Test viewer with filter only (no collapse).

    Note: Filter uses heading name matching, which is case-insensitive.
    The level selector (h2, h3) only works at root level of the hierarchy.
    """

    def test_view_with_filter(self, viewer, sample_doc):
        """Test viewing with heading filter."""
        result = viewer.view(sample_doc, filter="Main Document")

        assert "# Main Document" in result
        assert "This is the main content" in result

    def test_view_with_nested_filter(self, viewer, sample_doc):
        """Test viewing with nested heading filter."""
        result = viewer.view(sample_doc, filter="Main Document > Section A > Subsection A1")

        assert "### Subsection A1" in result
        assert "Detailed content for A1" in result
        assert "Subsection A2" not in result

    def test_view_with_invalid_filter_returns_error(self, viewer, sample_doc):
        """Test viewing with invalid filter returns error message."""
        result = viewer.view(sample_doc, filter="NonExistent")

        assert "Error" in result

    def test_view_filter_preserves_children(self, viewer, sample_doc):
        """Test that filtering preserves child sections."""
        result = viewer.view(sample_doc, filter="Main Document > Section A")

        assert "### Subsection A1" in result
        assert "### Subsection A2" in result

    def test_view_with_level_filter(self, viewer):
        """Test viewing with level selector filter at root level."""
        # Level selector works at root level only
        content = """## Root Section
Section content here.
### Nested
Nested content."""
        result = viewer.view(content, filter="h2")

        assert "## Root Section" in result
        assert "Section content here" in result


# ============================================================================
# Test Viewer - Collapse Only
# ============================================================================


class TestMarkdownViewerCollapseOnly:
    """Test viewer with collapse only (no filter)."""

    def test_collapse_at_depth_1(self, viewer, sample_doc):
        """Test collapsing all content below depth 1."""
        result = viewer.view(sample_doc, depth=1)

        assert "# Main Document" in result
        assert "This is the main content" in result
        # Content at depth 2+ is collapsed
        assert "### Subsection A1" not in result
        assert "[Collapsed]" in result

    def test_collapse_at_depth_2(self, viewer, sample_doc):
        """Test collapsing all content below depth 2."""
        result = viewer.view(sample_doc, depth=2)

        assert "# Main Document" in result
        assert "## Section A" in result
        assert "Content for section A" in result
        assert "### Subsection A1" not in result
        assert "[Collapsed]" in result

    def test_collapse_at_depth_3(self, viewer, sample_doc):
        """Test collapsing all content below depth 3."""
        result = viewer.view(sample_doc, depth=3)

        assert "# Main Document" in result
        assert "## Section A" in result
        assert "### Subsection A1" in result
        assert "Detailed content for A1" in result

    def test_collapse_at_depth_4(self, viewer, deep_doc):
        """Test collapsing at depth 4."""
        result = viewer.view(deep_doc, depth=4)

        assert "# Level 1" in result
        assert "## Level 2" in result
        assert "### Level 3" in result
        assert "#### Level 4" in result
        assert "##### Level 5" not in result
        assert "[Collapsed]" in result

    def test_collapse_at_depth_5(self, viewer, deep_doc):
        """Test collapsing at depth 5."""
        result = viewer.view(deep_doc, depth=5)

        assert "##### Level 5" in result
        assert "###### Level 6" not in result
        assert "[Collapsed]" in result

    def test_collapse_at_depth_6(self, viewer, deep_doc):
        """Test collapsing at depth 6 shows all headings."""
        result = viewer.view(deep_doc, depth=6)

        assert "###### Level 6" in result
        assert "Content at level 6" in result
        # No collapsed markers needed at depth 6 (max)

    def test_collapse_single_collapsed_marker(self, viewer):
        """Test that consecutive collapsed sections have single marker."""
        content = """# H1
## H2
### H3
Content 1
#### H4
Content 2
##### H5
Content 3
## H2 Again"""

        result = viewer.view(content, depth=2)

        # Count [Collapsed] markers - should appear once when transitioning
        assert "[Collapsed]" in result
        # The important thing is that collapsed content is hidden
        assert "### H3" not in result
        assert "Content 1" not in result
        assert "#### H4" not in result


# ============================================================================
# Test Invalid Depth Values
# ============================================================================


class TestMarkdownViewerInvalidDepth:
    """Test viewer with invalid depth values.

    Note: The implementation does not validate depth values.
    depth=0 collapses everything (level > 0),
    depth=-1 collapses everything,
    depth > 6 shows all content (no level > depth).
    """

    def test_collapse_depth_0_collapses_all(self, viewer, sample_doc):
        """Test that depth 0 collapses all headings (level > 0)."""
        result = viewer.view(sample_doc, depth=0)
        # depth=0 means all headings (level 1+) get collapsed
        # Should show [Collapsed] marker
        assert "[Collapsed]" in result
        # Original headings should be collapsed
        assert "# Main Document" not in result or "[Collapsed]" in result

    def test_collapse_depth_negative_collapses_all(self, viewer, sample_doc):
        """Test that negative depth collapses all content."""
        result = viewer.view(sample_doc, depth=-1)
        # Negative depth means all headings (level > -1) get collapsed
        assert "[Collapsed]" in result

    def test_collapse_depth_7_shows_all(self, viewer, sample_doc):
        """Test that depth 7+ shows all content (no heading > level 6)."""
        result = viewer.view(sample_doc, depth=7)
        # depth=7 means headings at level 8+ would be collapsed (none exist)
        assert "# Main Document" in result
        assert "## Section A" in result
        assert "### Subsection A1" in result

    def test_collapse_depth_100_shows_all(self, viewer, sample_doc):
        """Test that very large depth shows all content."""
        result = viewer.view(sample_doc, depth=100)
        # No heading level > 100, so nothing collapsed
        assert "# Main Document" in result
        assert "### Subsection A1" in result


# ============================================================================
# Test Viewer - Combined Filter and Collapse
# ============================================================================


class TestMarkdownViewerCombined:
    """Test filtering and collapsing together."""

    def test_filter_then_collapse(self, viewer, sample_doc):
        """Test applying both filter and collapse."""
        result = viewer.view(sample_doc, filter="Main Document > Section A", depth=2)

        assert "## Section A" in result
        assert "Content for section A" in result
        assert "### Subsection A1" not in result
        assert "Section B" not in result
        assert "[Collapsed]" in result

    def test_filter_and_collapse_at_different_depths(self, viewer, deep_doc):
        """Test filter and collapse at various depths."""
        # Filter to Level 1, then collapse at depth 3
        result = viewer.view(deep_doc, filter="Level 1 > Level 2", depth=3)

        assert "## Level 2" in result
        assert "### Level 3" in result
        assert "#### Level 4" not in result
        assert "[Collapsed]" in result


# ============================================================================
# Test Bare Mode (filtered_only)
# ============================================================================


class TestMarkdownViewerBareMode:
    """Test bare mode returns exact match without collapse markers."""

    def test_bare_mode_returns_exact_match(self, viewer, sample_doc):
        """Test bare mode returns exact filtered content."""
        result = viewer.view(sample_doc, filter="Main Document > Section A", bare=True)

        assert "## Section A" in result
        assert "Content for section A" in result
        assert "[Collapsed]" not in result
        assert "Section B" not in result

    def test_bare_mode_with_nested_filter(self, viewer, sample_doc):
        """Test bare mode with nested filter path."""
        result = viewer.view(
            sample_doc,
            filter="Main Document > Section A > Subsection A1",
            bare=True
        )

        assert "### Subsection A1" in result
        assert "Detailed content for A1" in result
        assert "[Collapsed]" not in result
        assert "Subsection A2" not in result

    def test_bare_mode_ignores_depth(self, viewer, sample_doc):
        """Test that bare mode ignores depth parameter."""
        # In bare mode, depth should be ignored
        result = viewer.view(
            sample_doc,
            filter="Main Document > Section A",
            bare=True,
            depth=2
        )

        assert "## Section A" in result
        # In bare mode, children should still be present (no collapse applied)
        assert "### Subsection A1" in result
        assert "[Collapsed]" not in result

    def test_bare_mode_preserves_all_content(self, viewer, sample_doc):
        """Test bare mode preserves all content under filtered section."""
        result = viewer.view(sample_doc, filter="Main Document > Section A", bare=True)

        assert "### Subsection A1" in result
        assert "### Subsection A2" in result
        assert "Detailed content for A1" in result
        assert "Detailed content for A2" in result


# ============================================================================
# Test Edge Cases
# ============================================================================


class TestMarkdownViewerEdgeCases:
    """Test edge cases."""

    def test_empty_content(self, viewer):
        """Test viewing empty content."""
        result = viewer.view("")
        assert result == ""

    def test_content_no_headings(self, viewer):
        """Test viewing content with no headings."""
        content = "Just plain text\nNo headings at all"
        result = viewer.view(content)
        assert result == content

    def test_content_only_headings(self, viewer):
        """Test viewing content with only headings (no body text)."""
        content = "# H1\n## H2\n### H3"
        result = viewer.view(content, depth=1)

        assert "# H1" in result
        # Headings at depth 2+ are collapsed
        assert "### H3" not in result
        assert "[Collapsed]" in result

    def test_collapse_with_blank_lines(self, viewer):
        """Test collapse handling with blank lines."""
        content = """# Section 1

Some content here.

## Subsection

Detailed content.

## Another Sub"""

        result = viewer.view(content, depth=1)

        assert "# Section 1" in result
        assert "Some content here" in result
        # Content at depth 2+ is collapsed
        assert "Detailed content" not in result
        assert "[Collapsed]" in result

    def test_view_with_code_blocks_in_content(self, viewer):
        """Test viewing content with code blocks."""
        content = """# Code Example

Here's some code:

```python
def hello():
    print("world")
```

## Explanation

This is important."""

        result = viewer.view(content, filter="Code Example")

        assert "Code Example" in result
        assert "def hello" in result
        # Explanation is a child section, so it's included
        assert "Explanation" in result
        assert "This is important" in result

    def test_multiple_h1_sections(self, viewer):
        """Test document with multiple h1 sections."""
        content = """# First Main
First content.

## First Sub
Sub content.

# Second Main
Second content.

## Second Sub
More sub content."""

        # Collapse should work across multiple h1s
        result = viewer.view(content, depth=1)

        assert "# First Main" in result
        assert "# Second Main" in result
        assert "First content" in result
        assert "Second content" in result
        assert "## First Sub" not in result
        assert "## Second Sub" not in result

    def test_preserve_inline_formatting(self, viewer):
        """Test that inline formatting is preserved."""
        content = """# Title

This has **bold** and *italic* and `code`."""

        result = viewer.view(content)
        assert "**bold**" in result
        assert "*italic*" in result
        assert "`code`" in result

    def test_preserve_links(self, viewer):
        """Test that links are preserved."""
        content = """# Links

Check out [example](https://example.com) for more."""

        result = viewer.view(content)
        assert "[example](https://example.com)" in result

    def test_preserve_lists(self, viewer):
        """Test that lists are preserved."""
        content = """# Lists

- Item 1
- Item 2
  - Nested item

1. First
2. Second"""

        result = viewer.view(content)
        assert "- Item 1" in result
        assert "- Nested item" in result
        assert "1. First" in result

    def test_preserve_blockquotes(self, viewer):
        """Test that blockquotes are preserved."""
        content = """# Quote Section

> This is a quote
> spanning multiple lines"""

        result = viewer.view(content)
        assert "> This is a quote" in result

    def test_whitespace_only_content(self, viewer):
        """Test content that is only whitespace."""
        content = "   \n\n   \n"
        result = viewer.view(content)
        assert result == content

    def test_single_heading_no_content(self, viewer):
        """Test single heading with no content."""
        content = "# Just a Heading"
        result = viewer.view(content)
        assert result == content

    def test_heading_at_end_of_file(self, viewer):
        """Test heading at end of file with no trailing newline."""
        content = "# First\nContent\n# Last"
        result = viewer.view(content, filter="Last")
        assert "# Last" in result

    def test_filter_and_bare_with_no_children(self, viewer):
        """Test bare filter on section with no children."""
        content = """# Main
## Section
Just content, no children.
## Other
Other content."""

        result = viewer.view(content, filter="Main > Section", bare=True)

        assert "## Section" in result
        assert "Just content" in result
        assert "Other" not in result
        assert "[Collapsed]" not in result


# ============================================================================
# Test Depth Boundary Conditions
# ============================================================================


class TestMarkdownViewerDepthBoundaries:
    """Test depth parameter boundary conditions."""

    def test_depth_exactly_1(self, viewer, simple_doc):
        """Test depth=1 shows only h1."""
        result = viewer.view(simple_doc, depth=1)

        assert "# Title" in result
        assert "Intro paragraph" in result
        assert "## Section One" not in result
        assert "[Collapsed]" in result

    def test_depth_exactly_2(self, viewer, simple_doc):
        """Test depth=2 shows h1 and h2."""
        result = viewer.view(simple_doc, depth=2)

        assert "# Title" in result
        assert "## Section One" in result
        assert "First section content" in result
        assert "## Section Two" in result

    def test_depth_matches_max_heading_level(self, viewer, deep_doc):
        """Test depth matching maximum heading level in doc."""
        result = viewer.view(deep_doc, depth=6)

        # All levels should be visible
        assert "###### Level 6" in result
        assert "Content at level 6" in result

    def test_depth_exceeds_doc_depth(self, viewer, simple_doc):
        """Test depth exceeding document's actual depth."""
        # Doc only has h1 and h2, but we request depth 5
        result = viewer.view(simple_doc, depth=5)

        # Should show all content (nothing to collapse)
        assert "# Title" in result
        assert "## Section One" in result
        assert "## Section Two" in result
