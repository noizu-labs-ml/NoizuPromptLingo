# AT-009: Error Handling Tests

```python
import pytest
import json

class TestErrorHandling:
    """Tests for error conditions across all tools."""

    # ============ Story Tool Errors ============

    async def test_get_story_empty_id(self):
        """Empty story ID raises ValidationError."""
        with pytest.raises(ValidationError) as exc_info:
            await get_story("")

        assert "Invalid story ID" in str(exc_info.value)

    async def test_get_story_invalid_format(self):
        """Invalid story ID format raises ValidationError."""
        with pytest.raises(ValidationError) as exc_info:
            await get_story("INVALID-001")

        assert "Invalid story ID format" in str(exc_info.value)
        assert "Expected 'US-XXX'" in str(exc_info.value)

    async def test_list_stories_missing_index(self, tmp_path):
        """Missing index.yaml raises FileNotFoundError."""
        with pytest.raises(FileNotFoundError) as exc_info:
            await list_stories()

        assert "Index file not found" in str(exc_info.value)

    async def test_list_stories_malformed_yaml(self, tmp_path):
        """Malformed YAML raises ParseError."""
        index_path = tmp_path / "index.yaml"
        index_path.write_text("invalid: yaml: [[[")

        with pytest.raises(ParseError) as exc_info:
            await list_stories()

        assert "Failed to parse YAML" in str(exc_info.value)

    # ============ PRD Tool Errors ============

    async def test_get_prd_empty_id(self):
        """Empty PRD ID raises ValidationError."""
        with pytest.raises(ValidationError) as exc_info:
            await get_prd("")

        assert "Invalid PRD ID" in str(exc_info.value)

    async def test_get_prd_not_found(self, tmp_path):
        """Non-existent PRD raises NotFoundError."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()

        with pytest.raises(NotFoundError) as exc_info:
            await get_prd("PRD-999")

        assert "PRD 'PRD-999' not found" in str(exc_info.value)

    async def test_get_fr_prd_not_found(self, tmp_path):
        """FR for non-existent PRD raises NotFoundError."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_prd_functional_requirement("PRD-999", "FR-001")

        assert "PRD" in str(exc_info.value) and "not found" in str(exc_info.value)

    async def test_get_at_prd_not_found(self, tmp_path):
        """AT for non-existent PRD raises NotFoundError."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_prd_acceptance_test("PRD-999", "AT-001")

        assert "PRD" in str(exc_info.value) and "not found" in str(exc_info.value)

    # ============ Update Tool Errors ============

    async def test_update_story_not_found(self, tmp_path):
        """Update non-existent story raises NotFoundError."""
        index_content = "version: 2\nstories: []"
        index_path = tmp_path / "index.yaml"
        index_path.write_text(index_content)

        with pytest.raises(NotFoundError) as exc_info:
            await update_story_metadata("US-001", "status", "draft")

        assert "not found" in str(exc_info.value).lower()

    async def test_update_invalid_key(self, tmp_path):
        """Update with invalid key raises ValidationError."""
        index_content = """
version: 2
stories:
  - id: US-001
    status: draft
"""
        index_path = tmp_path / "index.yaml"
        index_path.write_text(index_content)

        with pytest.raises(ValidationError) as exc_info:
            await update_story_metadata("US-001", "invalid_key", "value")

        assert "Invalid metadata key" in str(exc_info.value)
        assert "Valid keys:" in str(exc_info.value)

    async def test_update_invalid_status_value(self, tmp_path):
        """Update status with invalid value raises ValidationError."""
        index_content = """
version: 2
stories:
  - id: US-001
    status: draft
"""
        index_path = tmp_path / "index.yaml"
        index_path.write_text(index_content)

        with pytest.raises(ValidationError) as exc_info:
            await update_story_metadata("US-001", "status", "invalid-status")

        assert "Invalid value" in str(exc_info.value)
        assert "draft" in str(exc_info.value) or "in-progress" in str(exc_info.value)

    # ============ Persona Tool Errors ============

    async def test_get_persona_not_found(self, tmp_path):
        """Non-existent persona raises NotFoundError."""
        personas_dir = tmp_path / "personas"
        personas_dir.mkdir()
        (personas_dir / "index.yaml").write_text("version: 1\npersonas: []")

        with pytest.raises(NotFoundError) as exc_info:
            await get_persona("P-999")

        assert "Persona 'P-999' not found" in str(exc_info.value)

    async def test_get_persona_invalid_format(self):
        """Invalid persona ID format raises ValidationError."""
        with pytest.raises(ValidationError) as exc_info:
            await get_persona("INVALID-001")

        assert "Invalid" in str(exc_info.value)

    async def test_list_personas_missing_index(self, tmp_path):
        """Missing personas index raises FileNotFoundError."""
        with pytest.raises(FileNotFoundError) as exc_info:
            await list_personas()

        assert "Index file not found" in str(exc_info.value)

    # ============ Error Message Quality ============

    async def test_error_includes_context(self, tmp_path):
        """Error messages include helpful context."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_story("US-999")

        error_msg = str(exc_info.value)
        # Should include the ID that wasn't found
        assert "US-999" in error_msg

    async def test_validation_error_includes_allowed_values(self, tmp_path):
        """Validation errors include allowed values."""
        index_content = """
version: 2
stories:
  - id: US-001
    status: draft
"""
        index_path = tmp_path / "index.yaml"
        index_path.write_text(index_content)

        with pytest.raises(ValidationError) as exc_info:
            await update_story_metadata("US-001", "status", "bad-value")

        error_msg = str(exc_info.value)
        # Should list allowed values
        assert any(v in error_msg for v in ["draft", "in-progress", "documented"])
```
