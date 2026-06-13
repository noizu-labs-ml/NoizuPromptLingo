# AT-005: Get Functional Requirement Tests

```python
import pytest
import json
from pathlib import Path

class TestGetFunctionalRequirement:
    """Tests for get_prd_functional_requirement tool."""

    @pytest.fixture
    def prd_with_frs(self, tmp_path):
        """Create PRD with functional requirements directory."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()

        # Create main PRD file
        (prd_dir / "PRD-017-pm-mcp-tools.md").write_text("# PRD-017")

        # Create supporting directory
        support_dir = prd_dir / "PRD-017-pm-mcp-tools"
        support_dir.mkdir()

        # Create FR directory with index and files
        fr_dir = support_dir / "functional-requirements"
        fr_dir.mkdir()

        index_content = """
functional_requirements:
  - id: FR-001
    title: User Story Reader
    file: FR-001-user-story-reader.md
    status: documented
    priority: high
  - id: FR-002
    title: User Story Lister
    file: FR-002-user-story-lister.md
    status: draft
    priority: medium
"""
        (fr_dir / "index.yaml").write_text(index_content)

        fr1_content = """# FR-001: User Story Reader

**Description**: Read and parse user story by ID.

## Interface

```python
async def get_story(story_id: str) -> str:
    pass
```

## Behavior

- Given story_id "US-001"
- When get_story is called
- Then returns story data
"""
        (fr_dir / "FR-001-user-story-reader.md").write_text(fr1_content)
        (fr_dir / "FR-002-user-story-lister.md").write_text("# FR-002: User Story Lister")

        return prd_dir

    async def test_get_single_fr(self, prd_with_frs):
        """Get a specific functional requirement."""
        result = await get_prd_functional_requirement("PRD-017", "FR-001")
        data = json.loads(result)

        assert data["prd_id"] == "PRD-017"
        assert data["fr_id"] == "FR-001"
        assert data["title"] == "User Story Reader"
        assert "content" in data
        assert "## Interface" in data["content"]

    async def test_get_fr_metadata(self, prd_with_frs):
        """Verify FR metadata is returned."""
        result = await get_prd_functional_requirement("PRD-017", "FR-001")
        data = json.loads(result)

        assert data["status"] == "documented"
        assert data["priority"] == "high"
        assert "file" in data

    async def test_list_all_frs_with_asterisk(self, prd_with_frs):
        """List all FRs using asterisk."""
        result = await get_prd_functional_requirement("PRD-017", "*")
        data = json.loads(result)

        assert data["prd_id"] == "PRD-017"
        assert data["total_count"] == 2
        assert len(data["functional_requirements"]) == 2

    async def test_list_all_frs_default(self, prd_with_frs):
        """List all FRs when fr_id is omitted."""
        result = await get_prd_functional_requirement("PRD-017")
        data = json.loads(result)

        assert data["total_count"] == 2

    async def test_fr_not_found(self, prd_with_frs):
        """Get FR that doesn't exist."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_prd_functional_requirement("PRD-017", "FR-999")

        assert "Functional requirement 'FR-999' not found" in str(exc_info.value)

    async def test_prd_has_no_fr_directory(self, tmp_path):
        """PRD exists but has no functional-requirements directory."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()
        (prd_dir / "PRD-001-simple.md").write_text("# PRD-001")

        result = await get_prd_functional_requirement("PRD-001", "*")
        data = json.loads(result)

        assert data["total_count"] == 0
        assert data["functional_requirements"] == []

    async def test_fr_id_without_prefix(self, prd_with_frs):
        """Get FR using ID without prefix."""
        result = await get_prd_functional_requirement("PRD-017", "001")
        data = json.loads(result)

        assert data["fr_id"] == "FR-001"

    async def test_fr_discovery_without_index(self, tmp_path):
        """Discover FRs by glob when index.yaml missing."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()
        (prd_dir / "PRD-001-simple.md").write_text("# PRD-001")

        support_dir = prd_dir / "PRD-001-simple"
        support_dir.mkdir()
        fr_dir = support_dir / "functional-requirements"
        fr_dir.mkdir()

        # No index.yaml, just FR files
        (fr_dir / "FR-001-test.md").write_text("# FR-001: Test FR")
        (fr_dir / "FR-002-another.md").write_text("# FR-002: Another FR")

        result = await get_prd_functional_requirement("PRD-001", "*")
        data = json.loads(result)

        assert data["total_count"] == 2
```
