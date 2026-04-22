# AT-007: Update Story Metadata Tests

```python
import pytest
import json
from pathlib import Path
import yaml

class TestUpdateStoryMetadata:
    """Tests for update_story_metadata tool."""

    @pytest.fixture
    def updatable_index(self, tmp_path):
        """Create index that can be updated."""
        index_content = """
version: 2
stories:
  - id: US-001
    title: Test Story
    file: US-001.md
    persona: P-001
    persona_name: AI Agent
    priority: medium
    status: draft
    prd_group: test
    prds: []
    related_stories: []
    related_personas: []
"""
        index_path = tmp_path / "index.yaml"
        index_path.write_text(index_content)
        return tmp_path

    async def test_update_status(self, updatable_index):
        """Update story status field."""
        result = await update_story_metadata("US-001", "status", "in-progress")
        data = json.loads(result)

        assert data["success"] == True
        assert data["story_id"] == "US-001"
        assert "status" in data["updated_fields"]
        assert data["previous_values"]["status"] == "draft"
        assert data["current_entry"]["status"] == "in-progress"

        # Verify file was actually updated
        index_path = updatable_index / "index.yaml"
        with open(index_path) as f:
            updated = yaml.safe_load(f)
        assert updated["stories"][0]["status"] == "in-progress"

    async def test_update_priority(self, updatable_index):
        """Update story priority field."""
        result = await update_story_metadata("US-001", "priority", "critical")
        data = json.loads(result)

        assert data["success"] == True
        assert data["current_entry"]["priority"] == "critical"

    async def test_append_to_prds_array(self, updatable_index):
        """Append PRD to prds array."""
        result = await update_story_metadata("US-001", "prds", "PRD-017")
        data = json.loads(result)

        assert data["success"] == True
        assert "PRD-017" in data["current_entry"]["prds"]

    async def test_append_avoids_duplicates(self, updatable_index):
        """Appending same value twice doesn't create duplicates."""
        await update_story_metadata("US-001", "prds", "PRD-017")
        result = await update_story_metadata("US-001", "prds", "PRD-017")
        data = json.loads(result)

        # Should only have one PRD-017
        assert data["current_entry"]["prds"].count("PRD-017") == 1

    async def test_update_related_stories(self, updatable_index):
        """Update related_stories array."""
        result = await update_story_metadata("US-001", "related_stories", "US-002,US-003")
        data = json.loads(result)

        assert data["success"] == True
        assert "US-002" in data["current_entry"]["related_stories"]
        assert "US-003" in data["current_entry"]["related_stories"]

    async def test_update_related_personas(self, updatable_index):
        """Update related_personas array."""
        result = await update_story_metadata("US-001", "related_personas", "P-002")
        data = json.loads(result)

        assert data["success"] == True
        assert "P-002" in data["current_entry"]["related_personas"]

    async def test_story_not_found(self, updatable_index):
        """Update story that doesn't exist."""
        with pytest.raises(NotFoundError) as exc_info:
            await update_story_metadata("US-999", "status", "draft")

        assert "not found" in str(exc_info.value).lower()

    async def test_invalid_key(self, updatable_index):
        """Update with invalid metadata key."""
        with pytest.raises(ValidationError) as exc_info:
            await update_story_metadata("US-001", "invalid_key", "value")

        assert "Invalid metadata key" in str(exc_info.value)
        assert "Valid keys" in str(exc_info.value)

    async def test_invalid_status_value(self, updatable_index):
        """Update status with invalid value."""
        with pytest.raises(ValidationError) as exc_info:
            await update_story_metadata("US-001", "status", "invalid-status")

        assert "Invalid value" in str(exc_info.value)
        assert "status" in str(exc_info.value)

    async def test_invalid_priority_value(self, updatable_index):
        """Update priority with invalid value."""
        with pytest.raises(ValidationError) as exc_info:
            await update_story_metadata("US-001", "priority", "super-high")

        assert "Invalid value" in str(exc_info.value)
        assert "priority" in str(exc_info.value)

    async def test_atomic_write_preserves_other_stories(self, tmp_path):
        """Update preserves other stories in index."""
        index_content = """
version: 2
stories:
  - id: US-001
    title: First Story
    status: draft
    priority: high
  - id: US-002
    title: Second Story
    status: in-progress
    priority: medium
"""
        index_path = tmp_path / "index.yaml"
        index_path.write_text(index_content)

        await update_story_metadata("US-001", "status", "documented")

        # Verify US-002 is unchanged
        with open(index_path) as f:
            updated = yaml.safe_load(f)
        us002 = [s for s in updated["stories"] if s["id"] == "US-002"][0]
        assert us002["status"] == "in-progress"
        assert us002["priority"] == "medium"

    async def test_preserves_yaml_structure(self, updatable_index):
        """Update preserves YAML structure and formatting."""
        await update_story_metadata("US-001", "status", "in-progress")

        index_path = updatable_index / "index.yaml"
        with open(index_path) as f:
            content = f.read()

        # Should still have version field
        assert "version:" in content
        # Should still be valid YAML
        data = yaml.safe_load(content)
        assert data["version"] == 2
```
