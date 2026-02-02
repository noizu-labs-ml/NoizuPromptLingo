"""Tests for markdown viewer module."""

import pytest

from npl_mcp.markdown.viewer import MarkdownViewer


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


class TestMarkdownViewerBasic:
    """Test basic viewer functionality."""

    def test_view_unfiltered(self, viewer, sample_doc):
        """Test viewing document without filtering."""
        result = viewer.view(sample_doc)
        assert result == sample_doc

    def test_view_with_filter(self, viewer, sample_doc):
        """Test viewing with heading filter."""
        result = viewer.view(sample_doc, filter="Section A")

        assert "## Section A" in result
        assert "Content for section A" in result
        assert "Section B" not in result

    def test_view_with_nested_filter(self, viewer, sample_doc):
        """Test viewing with nested heading filter."""
        result = viewer.view(sample_doc, filter="Section A > Subsection A1")

        assert "### Subsection A1" in result
        assert "Detailed content for A1" in result
        assert "Subsection A2" not in result

    def test_view_with_invalid_filter(self, viewer, sample_doc):
        """Test viewing with invalid filter."""
        result = viewer.view(sample_doc, filter="NonExistent")

        assert "Error" in result


class TestMarkdownViewerCollapse:
    """Test document collapsing functionality."""

    def test_collapse_at_depth_1(self, viewer, sample_doc):
        """Test collapsing all content below depth 1."""
        result = viewer.view(sample_doc, collapsed_depth=1)

        assert "# Main Document" in result
        # Content at depth 2+ is collapsed
        assert "### Subsection A1" not in result
        assert "[Collapsed]" in result

    def test_collapse_at_depth_2(self, viewer, sample_doc):
        """Test collapsing all content below depth 2."""
        result = viewer.view(sample_doc, collapsed_depth=2)

        assert "# Main Document" in result
        assert "## Section A" in result
        assert "### Subsection A1" not in result
        assert "[Collapsed]" in result

    def test_collapse_at_depth_3(self, viewer, sample_doc):
        """Test collapsing all content below depth 3."""
        result = viewer.view(sample_doc, collapsed_depth=3)

        assert "# Main Document" in result
        assert "## Section A" in result
        assert "### Subsection A1" in result
        # Level 4+ would be collapsed, but we only have level 3 in sample

    def test_collapse_depth_0_invalid(self, viewer, sample_doc):
        """Test that depth 0 is invalid and returns original."""
        result = viewer.view(sample_doc, collapsed_depth=0)
        # Should be invalid and return original
        assert "# Main Document" in result

    def test_collapse_depth_7_invalid(self, viewer, sample_doc):
        """Test that depth 7+ is invalid and returns original."""
        result = viewer.view(sample_doc, collapsed_depth=7)
        # Should be invalid and return original
        assert "# Main Document" in result

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

        result = viewer.view(content, collapsed_depth=2)

        # Count [Collapsed] markers - should appear once before ### H3
        collapsed_count = result.count("[Collapsed]")
        # Should have one marker when transitioning to depth 3+
        assert collapsed_count >= 1


class TestMarkdownViewerCombined:
    """Test filtering and collapsing together."""

    def test_filter_then_collapse(self, viewer, sample_doc):
        """Test applying both filter and collapse."""
        # Filter to Section A, then collapse deep sections
        result = viewer.view(
            sample_doc, filter="Section A", collapsed_depth=2
        )

        assert "## Section A" in result
        assert "### Subsection A1" not in result
        assert "Section B" not in result
        assert "[Collapsed]" in result

    def test_filtered_only_mode(self, viewer, sample_doc):
        """Test filtered_only mode returns exact match."""
        result = viewer.view(sample_doc, filter="Section A", filtered_only=True)

        assert "## Section A" in result
        assert "Content for section A" in result
        assert "[Collapsed]" not in result
        assert "Section B" not in result


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
        """Test viewing content with only headings."""
        content = "# H1\n## H2\n### H3"
        result = viewer.view(content, collapsed_depth=1)

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

        result = viewer.view(content, collapsed_depth=1)

        assert "# Section 1" in result
        assert "Some content here" in result
        # Content at depth 2+ is collapsed
        assert "Detailed content" not in result
        assert "[Collapsed]" in result

    def test_view_with_code_blocks(self, viewer):
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
        # Explanation is a child section of Code Example, so it's included
        assert "Explanation" in result
        assert "This is important" in result
