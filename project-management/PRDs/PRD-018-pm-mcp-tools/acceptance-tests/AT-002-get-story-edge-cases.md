# AT-002: Get Story Edge Cases

```python
import pytest
import json

class TestGetStoryEdgeCases:
    """Edge case tests for get_story tool."""

    async def test_story_not_found(self, sample_index):
        """Get story that doesn't exist in index."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_story("US-999")

        assert "User story 'US-999' not found in index" in str(exc_info.value)

    async def test_invalid_id_format(self):
        """Get story with invalid ID format."""
        with pytest.raises(ValidationError) as exc_info:
            await get_story("ABC-001")

        assert "Invalid story ID format" in str(exc_info.value)
        assert "Expected 'US-XXX' or numeric ID" in str(exc_info.value)

    async def test_story_file_missing(self, sample_index):
        """Story in index but file doesn't exist."""
        # Index has US-001 but file doesn't exist
        result = await get_story("US-001")
        data = json.loads(result)

        # Should return metadata with null/empty content
        assert data["id"] == "US-001"
        assert data["content"] is None or data["content"] == ""
        assert "warning" in data or data.get("file_exists") == False

    async def test_index_file_missing(self, tmp_path):
        """Index file doesn't exist."""
        with pytest.raises(FileNotFoundError) as exc_info:
            await get_story("US-001")

        assert "Index file not found" in str(exc_info.value)

    async def test_malformed_yaml_index(self, tmp_path):
        """Index file has invalid YAML."""
        index_path = tmp_path / "index.yaml"
        index_path.write_text("invalid: yaml: content: [")

        with pytest.raises(ParseError) as exc_info:
            await get_story("US-001")

        assert "Failed to parse YAML" in str(exc_info.value)

    async def test_empty_story_id(self):
        """Get story with empty ID."""
        with pytest.raises(ValidationError) as exc_info:
            await get_story("")

        assert "Invalid story ID" in str(exc_info.value)

    async def test_whitespace_story_id(self):
        """Get story with whitespace-only ID."""
        with pytest.raises(ValidationError) as exc_info:
            await get_story("   ")

        assert "Invalid story ID" in str(exc_info.value)

    async def test_story_with_no_acceptance_criteria(self, sample_index):
        """Story markdown has no acceptance criteria section."""
        story_content = """# User Story: Simple Story

**ID**: US-001

## Story

Just a simple story with no AC.
"""
        story_path = sample_index / "US-001-load-npl-core.md"
        story_path.write_text(story_content)

        result = await get_story("US-001")
        data = json.loads(result)

        assert data["acceptance_criteria"] == []

    async def test_story_with_nested_checkboxes(self, sample_index):
        """Story has nested checkbox items."""
        story_content = """# User Story

## Acceptance Criteria

- [ ] Main criterion
  - [ ] Sub-criterion 1
  - [x] Sub-criterion 2
- [ ] Another main criterion
"""
        story_path = sample_index / "US-001-load-npl-core.md"
        story_path.write_text(story_content)

        result = await get_story("US-001")
        data = json.loads(result)

        # Should handle nested items appropriately
        assert len(data["acceptance_criteria"]) >= 2
```
