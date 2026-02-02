# AT-003: List Stories Tests

```python
import pytest
import json

class TestListStories:
    """Tests for list_stories tool with filters."""

    @pytest.fixture
    def multi_story_index(self, tmp_path):
        """Create index with multiple stories for filtering tests."""
        index_content = """
version: 2
stories:
  - id: US-001
    title: Critical Draft Story
    file: US-001.md
    persona: P-001
    persona_name: AI Agent
    priority: critical
    status: draft
    prd_group: npl_load
    prds: [PRD-008]
  - id: US-002
    title: High Draft Story
    file: US-002.md
    persona: P-001
    persona_name: AI Agent
    priority: high
    status: draft
    prd_group: npl_load
    prds: [PRD-008]
  - id: US-003
    title: Medium In-Progress Story
    file: US-003.md
    persona: P-003
    persona_name: Vibe Coder
    priority: medium
    status: in-progress
    prd_group: mcp_tools
    prds: [PRD-010]
  - id: US-004
    title: Low Documented Story
    file: US-004.md
    persona: P-002
    persona_name: Product Manager
    priority: low
    status: documented
    prd_group: mcp_tools
    prds: [PRD-010, PRD-011]
"""
        index_path = tmp_path / "index.yaml"
        index_path.write_text(index_content)
        return tmp_path

    async def test_list_all_stories(self, multi_story_index):
        """List all stories without filters."""
        result = await list_stories()
        data = json.loads(result)

        assert data["total_count"] == 4
        assert data["returned_count"] == 4
        assert len(data["stories"]) == 4

    async def test_stories_sorted_by_priority(self, multi_story_index):
        """Stories are sorted by priority (critical first)."""
        result = await list_stories()
        data = json.loads(result)

        priorities = [s["priority"] for s in data["stories"]]
        assert priorities == ["critical", "high", "medium", "low"]

    async def test_filter_by_status(self, multi_story_index):
        """Filter stories by status."""
        result = await list_stories(status="draft")
        data = json.loads(result)

        assert data["total_count"] == 2
        for story in data["stories"]:
            assert story["status"] == "draft"

    async def test_filter_by_priority(self, multi_story_index):
        """Filter stories by priority."""
        result = await list_stories(priority="critical")
        data = json.loads(result)

        assert data["total_count"] == 1
        assert data["stories"][0]["id"] == "US-001"

    async def test_filter_by_persona(self, multi_story_index):
        """Filter stories by persona ID."""
        result = await list_stories(persona="P-001")
        data = json.loads(result)

        assert data["total_count"] == 2
        for story in data["stories"]:
            assert story["persona"] == "P-001"

    async def test_filter_by_prd_group(self, multi_story_index):
        """Filter stories by PRD group."""
        result = await list_stories(prd_group="mcp_tools")
        data = json.loads(result)

        assert data["total_count"] == 2
        ids = [s["id"] for s in data["stories"]]
        assert "US-003" in ids
        assert "US-004" in ids

    async def test_filter_by_prd(self, multi_story_index):
        """Filter stories by linked PRD."""
        result = await list_stories(prd="PRD-010")
        data = json.loads(result)

        assert data["total_count"] == 2
        ids = [s["id"] for s in data["stories"]]
        assert "US-003" in ids
        assert "US-004" in ids

    async def test_combined_filters_and_logic(self, multi_story_index):
        """Multiple filters use AND logic."""
        result = await list_stories(status="draft", priority="high")
        data = json.loads(result)

        assert data["total_count"] == 1
        assert data["stories"][0]["id"] == "US-002"

    async def test_pagination_limit(self, multi_story_index):
        """Limit number of returned stories."""
        result = await list_stories(limit=2)
        data = json.loads(result)

        assert data["total_count"] == 4
        assert data["returned_count"] == 2
        assert len(data["stories"]) == 2

    async def test_pagination_offset(self, multi_story_index):
        """Skip stories with offset."""
        result = await list_stories(limit=2, offset=2)
        data = json.loads(result)

        assert data["total_count"] == 4
        assert data["offset"] == 2
        assert data["returned_count"] == 2
        # Should get medium and low priority stories
        priorities = [s["priority"] for s in data["stories"]]
        assert "medium" in priorities
        assert "low" in priorities

    async def test_no_matching_stories(self, multi_story_index):
        """No stories match filter criteria."""
        result = await list_stories(status="tested")
        data = json.loads(result)

        assert data["total_count"] == 0
        assert data["returned_count"] == 0
        assert data["stories"] == []

    async def test_empty_index(self, tmp_path):
        """Index exists but has no stories."""
        index_content = "version: 2\nstories: []"
        index_path = tmp_path / "index.yaml"
        index_path.write_text(index_content)

        result = await list_stories()
        data = json.loads(result)

        assert data["total_count"] == 0
        assert data["stories"] == []
```
