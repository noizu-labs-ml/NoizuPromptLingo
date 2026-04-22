# AT-004: Get PRD Tests

```python
import pytest
import json
from pathlib import Path

class TestGetPRD:
    """Tests for get_prd tool."""

    @pytest.fixture
    def sample_prd(self, tmp_path):
        """Create a sample PRD with supporting directory."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()

        # Create main PRD file
        prd_content = """# PRD-015: NPL Advanced Loading Extension

**Version**: 1.0
**Status**: Draft
**Author**: npl-prd-editor
**Created**: 2026-02-02

## Overview

Test PRD content.

## User Stories

| ID | Title |
|---|---|
| US-201 | Load Directives Section |
| US-202 | Load Fences Section |
"""
        prd_file = prd_dir / "PRD-015-npl-loading-extension.md"
        prd_file.write_text(prd_content)

        # Create supporting directory
        support_dir = prd_dir / "PRD-015-npl-loading-extension"
        support_dir.mkdir()

        # Create FR directory with files
        fr_dir = support_dir / "functional-requirements"
        fr_dir.mkdir()
        (fr_dir / "index.yaml").write_text("functional_requirements:\n  - id: FR-1\n    title: Test FR")
        (fr_dir / "FR-1.md").write_text("# FR-1: Test")

        # Create AT directory with files
        at_dir = support_dir / "acceptance-tests"
        at_dir.mkdir()
        (at_dir / "index.yaml").write_text("acceptance_tests:\n  - id: AT-1\n    title: Test AT")
        (at_dir / "AT-1.md").write_text("# AT-1: Test")

        return prd_dir

    async def test_get_prd_by_full_id(self, sample_prd):
        """Get PRD using full ID format PRD-XXX."""
        result = await get_prd("PRD-015")
        data = json.loads(result)

        assert data["id"] == "PRD-015"
        assert data["title"] == "NPL Advanced Loading Extension"

    async def test_get_prd_by_numeric_id(self, sample_prd):
        """Get PRD using numeric ID without prefix."""
        result = await get_prd("015")
        data = json.loads(result)

        assert data["id"] == "PRD-015"

    async def test_get_prd_returns_metadata(self, sample_prd):
        """Verify metadata is extracted from PRD."""
        result = await get_prd("PRD-015")
        data = json.loads(result)

        assert data["version"] == "1.0"
        assert data["status"] == "Draft"

    async def test_get_prd_returns_content(self, sample_prd):
        """Verify full markdown content is returned."""
        result = await get_prd("PRD-015")
        data = json.loads(result)

        assert "content" in data
        assert "## Overview" in data["content"]
        assert "Test PRD content" in data["content"]

    async def test_get_prd_detects_supporting_directory(self, sample_prd):
        """Verify supporting directory is detected."""
        result = await get_prd("PRD-015")
        data = json.loads(result)

        assert data["has_functional_requirements"] == True
        assert data["has_acceptance_tests"] == True
        assert "supporting_directory" in data
        assert "PRD-015-npl-loading-extension" in data["supporting_directory"]

    async def test_get_prd_counts_fr_and_at(self, sample_prd):
        """Verify FR and AT counts are returned."""
        result = await get_prd("PRD-015")
        data = json.loads(result)

        assert data["functional_requirements_count"] == 1
        assert data["acceptance_tests_count"] == 1

    async def test_get_prd_extracts_user_stories(self, sample_prd):
        """Verify user story references are extracted."""
        result = await get_prd("PRD-015")
        data = json.loads(result)

        assert "user_stories" in data
        assert "US-201" in data["user_stories"]
        assert "US-202" in data["user_stories"]

    async def test_prd_not_found(self, sample_prd):
        """Get PRD that doesn't exist."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_prd("PRD-999")

        assert "PRD 'PRD-999' not found" in str(exc_info.value)

    async def test_prd_without_supporting_directory(self, tmp_path):
        """PRD exists but has no supporting directory."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()

        prd_content = "# PRD-001: Simple PRD\n\n**Version**: 0.1\n**Status**: Draft"
        (prd_dir / "PRD-001-simple.md").write_text(prd_content)

        result = await get_prd("PRD-001")
        data = json.loads(result)

        assert data["id"] == "PRD-001"
        assert data["supporting_directory"] is None
        assert data["has_functional_requirements"] == False
        assert data["has_acceptance_tests"] == False
        assert data["functional_requirements_count"] == 0

    async def test_prd_missing_metadata_uses_defaults(self, tmp_path):
        """PRD without standard metadata lines uses defaults."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()

        prd_content = "# PRD-001: No Metadata PRD\n\nJust content."
        (prd_dir / "PRD-001-no-meta.md").write_text(prd_content)

        result = await get_prd("PRD-001")
        data = json.loads(result)

        # Should use defaults
        assert data["version"] in ["0.0", "Unknown", None]
        assert data["status"] in ["draft", "Unknown", None]
```
