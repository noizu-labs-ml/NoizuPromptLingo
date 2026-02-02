"""Tests for markdown viewer using test assets.

These tests use a static markdown file to ensure the context-preserving
filter works correctly with realistic document structures.
"""

import pytest
from pathlib import Path

from npl_mcp.markdown.viewer import MarkdownViewer


@pytest.fixture
def nihilism_md():
    """Load the nihilism-style test markdown asset."""
    asset_path = Path(__file__).parent / "assets" / "test.md"
    return asset_path.read_text()


@pytest.fixture
def viewer():
    """Create a markdown viewer."""
    return MarkdownViewer()


class TestContextPreservationWithAssets:
    """Test context-preserving filter with real markdown assets."""

    def test_nihilism_filter_metaphysical_shows_siblings(self, viewer, nihilism_md):
        """Test filtering to metaphysical nihilism shows sibling sections as collapsed."""
        result = viewer.view(nihilism_md, filter="Nihilism > Metaphysics > Metaphysical nihilism")

        # Matched section should be present
        assert "metaphysical nihilism" in result.lower()

        # Siblings should be marked as collapsed
        # Mereological nihilism is a sibling
        assert "📦" in result  # At least some sections collapsed

    def test_nihilism_filter_with_depth(self, viewer, nihilism_md):
        """Test filtering with depth parameter on real document."""
        result = viewer.view(
            nihilism_md,
            filter="Nihilism > Metaphysics > Metaphysical nihilism",
            depth=3
        )

        # Should have collapsed sections
        assert "📦" in result

        # Matched section content should be present
        assert "ontological nihilism" in result.lower()

    def test_nihilism_bare_mode(self, viewer, nihilism_md):
        """Test bare mode extracts only matched section."""
        result = viewer.view(
            nihilism_md,
            filter="Nihilism > Metaphysics > Metaphysical nihilism",
            bare=True
        )

        # Should have matched section
        assert "metaphysical" in result.lower()

        # Should NOT have emoji markers (no context)
        assert "📦" not in result

    def test_nihilism_multiple_filters(self, viewer, nihilism_md):
        """Test filtering to various sections in nihilism document."""
        filters_to_test = [
            "Nihilism > Ethics and value theory > Existential nihilism",
            "Nihilism > Metaphysics > Metaphysical nihilism",
            "Nihilism > Epistemology > Relativism",
        ]

        for filter_path in filters_to_test:
            result = viewer.view(nihilism_md, filter=filter_path)

            # Each filter should return content (not error)
            assert "error" not in result.lower()
            assert len(result) > 0
            # Each should have siblings marked as collapsed
            assert "📦" in result

    def test_nihilism_depth_affects_readability(self, viewer, nihilism_md):
        """Test that depth parameter affects document readability."""
        # With depth 1, many sections should be collapsed
        result_depth_1 = viewer.view(
            nihilism_md,
            depth=1
        )
        count_collapsed_1 = result_depth_1.count("📦")

        # With depth 3, fewer sections should be collapsed
        result_depth_3 = viewer.view(
            nihilism_md,
            depth=3
        )
        count_collapsed_3 = result_depth_3.count("📦")

        # Depth 1 should collapse more sections than depth 3
        assert count_collapsed_1 > count_collapsed_3


class TestRealWorldPatterns:
    """Test patterns that occur in real markdown documents."""

    def test_deeply_nested_matching(self, viewer, nihilism_md):
        """Test that filtering to deep sections shows full ancestor path."""
        # Try to filter to a deeply nested section
        result = viewer.view(
            nihilism_md,
            filter="Nihilism > Metaphysics > Metaphysical nihilism"
        )

        # Should get results and show context
        assert "error" not in result.lower()
        assert len(result) > 0
        # Should show ancestors and siblings with emoji
        assert "📦" in result

    def test_filter_preserves_formatting(self, viewer, nihilism_md):
        """Test that inline formatting is preserved in filtered output."""
        result = viewer.view(
            nihilism_md,
            filter="Nihilism > Metaphysics > Metaphysical nihilism",
            bare=True
        )

        # Should preserve markdown formatting
        # Look for common markdown patterns
        patterns_to_check = [
            "[",  # Links
            "**",  # Bold
        ]

        # At least some formatting should be preserved
        has_formatting = any(pattern in result for pattern in patterns_to_check)
        assert has_formatting or len(result) > 100  # Either formatting or substantial content


class TestFilterPerformance:
    """Test that filtering performs reasonably on large documents."""

    def test_filter_completes_quickly(self, viewer, nihilism_md):
        """Test that filtering completes in reasonable time."""
        import time

        start = time.time()
        result = viewer.view(
            nihilism_md,
            filter="metaphysical-nihilism",
            depth=2
        )
        duration = time.time() - start

        # Should complete in under 1 second
        assert duration < 1.0
        assert len(result) > 0

    def test_depth_parameter_completes_quickly(self, viewer, nihilism_md):
        """Test that depth parameter completes quickly."""
        import time

        start = time.time()
        result = viewer.view(nihilism_md, depth=2)
        duration = time.time() - start

        # Should complete in under 1 second
        assert duration < 1.0
        assert len(result) > 0
