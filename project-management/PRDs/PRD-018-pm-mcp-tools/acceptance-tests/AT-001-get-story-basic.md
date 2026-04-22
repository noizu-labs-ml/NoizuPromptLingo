# AT-001: Get Story Basic Tests

```python
import pytest
import json
from pathlib import Path

class TestGetStoryBasic:
    """Basic tests for get_story tool."""

    @pytest.fixture
    def sample_index(self, tmp_path):
        """Create a sample index.yaml for testing."""
        index_content = """
version: 2
stories:
  - id: US-001
    title: Load NPL Core Components
    file: US-001-load-npl-core.md
    persona: P-001
    persona_name: AI Agent
    priority: critical
    status: draft
    prd_group: npl_load
    prds:
      - PRD-008
    related_stories:
      - US-002
    related_personas:
      - P-001
"""
        index_path = tmp_path / "index.yaml"
        index_path.write_text(index_content)
        return tmp_path

    @pytest.fixture
    def sample_story(self, sample_index):
        """Create a sample story markdown file."""
        story_content = """# User Story: Load NPL Core Components

**ID**: US-001
**Persona**: P-001 (AI Agent)
**Priority**: Critical
**Status**: Draft

## Story

As an AI Agent, I want to load NPL core components.

## Acceptance Criteria

- [ ] First criterion not completed
- [x] Second criterion completed
- [ ] Third criterion not completed
"""
        story_path = sample_index / "US-001-load-npl-core.md"
        story_path.write_text(story_content)
        return sample_index

    async def test_get_story_by_full_id(self, sample_story):
        """Get story using full ID format US-XXX."""
        result = await get_story("US-001")
        data = json.loads(result)

        assert data["id"] == "US-001"
        assert data["title"] == "Load NPL Core Components"
        assert data["persona"] == "P-001"
        assert data["priority"] == "critical"
        assert data["status"] == "draft"

    async def test_get_story_by_numeric_id(self, sample_story):
        """Get story using numeric ID without prefix."""
        result = await get_story("001")
        data = json.loads(result)

        assert data["id"] == "US-001"

    async def test_get_story_by_bare_number(self, sample_story):
        """Get story using bare number."""
        result = await get_story("1")
        data = json.loads(result)

        assert data["id"] == "US-001"

    async def test_get_story_returns_metadata(self, sample_story):
        """Verify all metadata fields are returned."""
        result = await get_story("US-001")
        data = json.loads(result)

        assert "prd_group" in data
        assert data["prd_group"] == "npl_load"
        assert "prds" in data
        assert "PRD-008" in data["prds"]
        assert "related_stories" in data
        assert "US-002" in data["related_stories"]
        assert "related_personas" in data
        assert "P-001" in data["related_personas"]

    async def test_get_story_returns_content(self, sample_story):
        """Verify markdown content is returned."""
        result = await get_story("US-001")
        data = json.loads(result)

        assert "content" in data
        assert "# User Story: Load NPL Core Components" in data["content"]

    async def test_get_story_parses_acceptance_criteria(self, sample_story):
        """Verify acceptance criteria are parsed correctly."""
        result = await get_story("US-001")
        data = json.loads(result)

        assert "acceptance_criteria" in data
        criteria = data["acceptance_criteria"]
        assert len(criteria) == 3

        assert criteria[0]["text"] == "First criterion not completed"
        assert criteria[0]["completed"] == False

        assert criteria[1]["text"] == "Second criterion completed"
        assert criteria[1]["completed"] == True

        assert criteria[2]["text"] == "Third criterion not completed"
        assert criteria[2]["completed"] == False
```
