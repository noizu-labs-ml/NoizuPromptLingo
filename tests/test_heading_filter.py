"""Tests for heading filter module."""

import pytest

from npl_mcp.markdown.filters.heading import HeadingFilter


@pytest.fixture
def filter():
    """Create a heading filter."""
    return HeadingFilter()


class TestHeadingFilterBasic:
    """Test basic heading filter operations."""

    def test_filter_by_heading_name(self, filter):
        """Test filtering by heading name."""
        content = "# Overview\nOverview content\n# API\nAPI content\n# Examples\nExample content"
        result = filter.filter(content, "API")

        assert "# API" in result
        assert "API content" in result
        assert "Overview" not in result
        assert "Example" not in result

    def test_filter_by_heading_case_insensitive(self, filter):
        """Test that heading filter is case-insensitive."""
        content = "# OVERVIEW\nContent here\n# API\nAPI content"
        result = filter.filter(content, "overview")

        assert "# OVERVIEW" in result
        assert "Content here" in result

    def test_filter_by_heading_level(self, filter):
        """Test filtering by heading level."""
        content = "# H1 Heading\n## H2 Heading\n### H3 Heading\n# Another H1"
        result = filter.filter(content, "h2")

        assert "# H2" in result
        assert "# H1" not in result
        assert "# Another H1" not in result

    def test_filter_missing_heading(self, filter):
        """Test filtering for missing heading."""
        content = "# Overview\nContent"
        result = filter.filter(content, "Missing")

        assert "Error" in result
        assert "not found" in result.lower()

    def test_filter_empty_content(self, filter):
        """Test filtering empty content."""
        result = filter.filter("", "heading")

        assert "Error" in result


class TestHeadingFilterNested:
    """Test nested path filtering."""

    def test_nested_path_two_levels(self, filter):
        """Test filtering with nested path."""
        content = """# Parent
Parent content
## Child
Child content
## Other Child
Other content
# Another Parent"""

        result = filter.filter(content, "Parent > Child")

        # Filter returns the deepest matched section only
        assert "## Child" in result
        assert "Child content" in result
        assert "Other Child" not in result
        assert "Another Parent" not in result

    def test_nested_path_three_levels(self, filter):
        """Test filtering with three-level nested path."""
        content = """# Level 1
## Level 2
### Level 3
Deep content
## Other L2
Other content
# Other L1"""

        result = filter.filter(content, "Level 1 > Level 2 > Level 3")

        # Filter returns the deepest matched section only
        assert "### Level 3" in result
        assert "Deep content" in result
        assert "Other L2" not in result

    def test_nested_path_missing_intermediate(self, filter):
        """Test nested path with missing intermediate section."""
        content = """# Parent
## Child
Content"""

        result = filter.filter(content, "Parent > Missing > Grandchild")

        assert "Error" in result

    def test_nested_path_with_wildcard(self, filter):
        """Test nested path with wildcard to get all children."""
        content = """# Parent
Parent content
## Child 1
Child 1 content
## Child 2
Child 2 content
# Other Parent"""

        result = filter.filter(content, "Parent > *")

        # Wildcard returns all children at that level
        assert "## Child 1" in result
        assert "## Child 2" in result
        assert "Child 1 content" in result
        assert "Child 2 content" in result
        assert "Other Parent" not in result


class TestHeadingFilterEdgeCases:
    """Test edge cases and special scenarios."""

    def test_content_with_no_headings(self, filter):
        """Test content with no headings."""
        content = "Just plain text\nNo headings here\nAt all"

        result = filter.filter(content, "heading")

        assert "Error" in result or "not found" in result.lower()

    def test_heading_with_special_characters(self, filter):
        """Test headings with special characters."""
        content = """# API Reference (v2.0)
Content here
## GET /users?id=123
More content"""

        result = filter.filter(content, "API Reference (v2.0)")

        assert "# API Reference (v2.0)" in result
        assert "Content here" in result

    def test_similar_heading_names(self, filter):
        """Test that exact match is found among similar names."""
        content = """# API
First API
# API Reference
Second API
# API Docs
Third API"""

        result = filter.filter(content, "API")

        assert "# API" in result
        assert "First API" in result
        assert "API Reference" not in result

    def test_heading_with_inline_code(self, filter):
        """Test headings with inline code."""
        content = """# Introduction to `FastAPI`
Content about FastAPI
# Other Section
Other content"""

        result = filter.filter(content, "Introduction to `FastAPI`")

        assert "Introduction to `FastAPI`" in result
        assert "Content about FastAPI" in result

    def test_multiple_content_blocks_under_heading(self, filter):
        """Test that all content blocks under heading are included."""
        content = """# Section
First paragraph

Second paragraph with more details

- List item 1
- List item 2

Code block:
```
code here
```

# Other Section"""

        result = filter.filter(content, "Section")

        assert "# Section" in result
        assert "First paragraph" in result
        assert "Second paragraph" in result
        assert "List item 1" in result
        assert "Code block" in result
        assert "Other Section" not in result

    def test_level_selector_multiple_matches(self, filter):
        """Test level selector with multiple headings at that level."""
        content = """# Level 1
## Subsection A
A content
## Subsection B
B content
# Level 2
## Subsection C
C content"""

        result = filter.filter(content, "h2")

        # Note: Filter returns first match only
        assert "## Subsection A" in result
        assert "A content" in result

    def test_whitespace_in_selector(self, filter):
        """Test selector with extra whitespace."""
        content = """# Main Section
Main content
## Sub Section
Sub content"""

        result = filter.filter(content, "Main Section  >  Sub Section")

        assert "## Sub Section" in result
        assert "Sub content" in result
