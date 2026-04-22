# AT-006: Get Acceptance Test Tests

```python
import pytest
import json
from pathlib import Path

class TestGetAcceptanceTest:
    """Tests for get_prd_acceptance_test tool."""

    @pytest.fixture
    def prd_with_ats(self, tmp_path):
        """Create PRD with acceptance tests directory."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()

        # Create main PRD file
        (prd_dir / "PRD-017-pm-mcp-tools.md").write_text("# PRD-017")

        # Create supporting directory
        support_dir = prd_dir / "PRD-017-pm-mcp-tools"
        support_dir.mkdir()

        # Create AT directory with index and files
        at_dir = support_dir / "acceptance-tests"
        at_dir.mkdir()

        index_content = """
acceptance_tests:
  - id: AT-001
    title: Get Story Basic Tests
    file: AT-001-get-story-basic.md
    fr_id: FR-001
    status: documented
    test_type: unit
    implementation_status: implemented
  - id: AT-002
    title: Get Story Edge Cases
    file: AT-002-get-story-edge-cases.md
    fr_id: FR-001
    status: documented
    test_type: unit
    implementation_status: not_implemented
  - id: AT-003
    title: List Stories Tests
    file: AT-003-list-stories.md
    fr_id: FR-002
    status: documented
    test_type: integration
    implementation_status: not_implemented
"""
        (at_dir / "index.yaml").write_text(index_content)

        at1_content = """# AT-001: Get Story Basic Tests

## Preconditions

- Index.yaml exists
- Story file exists

## Steps

1. Call get_story with valid ID
2. Parse the JSON response
3. Verify fields are present

## Expected Results

- Story ID matches input
- Title is returned
- Content is returned
"""
        (at_dir / "AT-001-get-story-basic.md").write_text(at1_content)
        (at_dir / "AT-002-get-story-edge-cases.md").write_text("# AT-002: Edge Cases")
        (at_dir / "AT-003-list-stories.md").write_text("# AT-003: List Stories")

        return prd_dir

    async def test_get_single_at(self, prd_with_ats):
        """Get a specific acceptance test."""
        result = await get_prd_acceptance_test("PRD-017", "AT-001")
        data = json.loads(result)

        assert data["prd_id"] == "PRD-017"
        assert data["at_id"] == "AT-001"
        assert data["title"] == "Get Story Basic Tests"
        assert "content" in data

    async def test_get_at_structured_data(self, prd_with_ats):
        """Verify structured test data is extracted."""
        result = await get_prd_acceptance_test("PRD-017", "AT-001")
        data = json.loads(result)

        assert "preconditions" in data
        assert len(data["preconditions"]) == 2
        assert "Index.yaml exists" in data["preconditions"]

        assert "steps" in data
        assert len(data["steps"]) >= 3

        assert "expected_results" in data
        assert len(data["expected_results"]) >= 3

    async def test_get_at_metadata(self, prd_with_ats):
        """Verify AT metadata is returned."""
        result = await get_prd_acceptance_test("PRD-017", "AT-001")
        data = json.loads(result)

        assert data["fr_id"] == "FR-001"
        assert data["status"] == "documented"
        assert data["test_type"] == "unit"
        assert data["implementation_status"] == "implemented"

    async def test_list_all_ats_with_asterisk(self, prd_with_ats):
        """List all ATs using asterisk."""
        result = await get_prd_acceptance_test("PRD-017", "*")
        data = json.loads(result)

        assert data["prd_id"] == "PRD-017"
        assert data["total_count"] == 3
        assert len(data["acceptance_tests"]) == 3

    async def test_list_ats_with_coverage_stats(self, prd_with_ats):
        """Verify coverage statistics are returned."""
        result = await get_prd_acceptance_test("PRD-017", "*")
        data = json.loads(result)

        assert data["implemented_count"] == 1
        assert data["coverage_percentage"] == pytest.approx(33.33, rel=0.1)

    async def test_filter_ats_by_fr(self, prd_with_ats):
        """Filter ATs by functional requirement."""
        result = await get_prd_acceptance_test("PRD-017", "*", fr_id="FR-001")
        data = json.loads(result)

        assert data["total_count"] == 2
        for at in data["acceptance_tests"]:
            assert at["fr_id"] == "FR-001"

    async def test_at_not_found(self, prd_with_ats):
        """Get AT that doesn't exist."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_prd_acceptance_test("PRD-017", "AT-999")

        assert "Acceptance test 'AT-999' not found" in str(exc_info.value)

    async def test_prd_has_no_at_directory(self, tmp_path):
        """PRD exists but has no acceptance-tests directory."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()
        (prd_dir / "PRD-001-simple.md").write_text("# PRD-001")

        result = await get_prd_acceptance_test("PRD-001", "*")
        data = json.loads(result)

        assert data["total_count"] == 0
        assert data["acceptance_tests"] == []
        assert data["coverage_percentage"] == 0.0

    async def test_at_without_structured_sections(self, tmp_path):
        """AT markdown doesn't have standard sections."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()
        (prd_dir / "PRD-001-simple.md").write_text("# PRD-001")

        support_dir = prd_dir / "PRD-001-simple"
        support_dir.mkdir()
        at_dir = support_dir / "acceptance-tests"
        at_dir.mkdir()

        # AT file without structured sections
        (at_dir / "AT-001-simple.md").write_text("# AT-001: Simple Test\n\nJust content.")

        result = await get_prd_acceptance_test("PRD-001", "AT-001")
        data = json.loads(result)

        # Should return content with empty structured lists
        assert data["at_id"] == "AT-001"
        assert "content" in data
        assert data["preconditions"] == []
        assert data["steps"] == []
        assert data["expected_results"] == []
```
