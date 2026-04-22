# AT-008: Persona Access Tests

```python
import pytest
import json
from pathlib import Path

class TestPersonaAccess:
    """Tests for get_persona and list_personas tools."""

    @pytest.fixture
    def persona_index(self, tmp_path):
        """Create personas directory with index and files."""
        personas_dir = tmp_path / "personas"
        personas_dir.mkdir()

        index_content = """
version: 1
personas:
  - id: P-001
    name: AI Agent
    file: ai-agent.md
    tags:
      - autonomous
      - programmatic
    related_stories:
      - US-001
      - US-002
  - id: P-002
    name: Product Manager
    file: product-manager.md
    tags:
      - non-technical
      - reviewer
    related_stories:
      - US-005
  - id: A-001
    name: Gopher Scout
    file: agents/gopher-scout.md
    category: Core
    tags:
      - discovery
      - research
  - id: A-017
    name: NPL Build Manager
    file: additional-agents/infrastructure/npl-build-manager.md
    category: Infrastructure
    tags:
      - ci-cd
      - deployment
"""
        (personas_dir / "index.yaml").write_text(index_content)

        # Create persona files
        ai_agent_content = """# Persona: AI Agent

## Demographics

- **Role**: Autonomous AI agent (LLM-powered)
- **Tech Savvy**: Expert
- **Primary Interface**: MCP tools

## Goals

1. Execute assigned tasks efficiently
2. Maintain clear audit trails

## Pain Points

1. Ambiguous task specifications
2. Lack of structured context

## Behaviors

1. Loads NPL context before starting work
2. Polls task queues for assigned work
"""
        (personas_dir / "ai-agent.md").write_text(ai_agent_content)
        (personas_dir / "product-manager.md").write_text("# Persona: Product Manager")

        # Create agent directories and files
        agents_dir = personas_dir / "agents"
        agents_dir.mkdir()
        (agents_dir / "gopher-scout.md").write_text("# Agent: Gopher Scout")

        additional_dir = personas_dir / "additional-agents" / "infrastructure"
        additional_dir.mkdir(parents=True)
        (additional_dir / "npl-build-manager.md").write_text("# Agent: NPL Build Manager")

        return personas_dir

    async def test_get_persona_by_id(self, persona_index):
        """Get persona using full ID."""
        result = await get_persona("P-001")
        data = json.loads(result)

        assert data["id"] == "P-001"
        assert data["name"] == "AI Agent"
        assert "content" in data

    async def test_get_persona_structured_data(self, persona_index):
        """Verify structured data is extracted."""
        result = await get_persona("P-001")
        data = json.loads(result)

        assert "demographics" in data
        assert "Role" in data["demographics"] or "role" in data["demographics"]

        assert "goals" in data
        assert len(data["goals"]) == 2
        assert "Execute assigned tasks" in data["goals"][0]

        assert "pain_points" in data
        assert len(data["pain_points"]) == 2

        assert "behaviors" in data
        assert len(data["behaviors"]) == 2

    async def test_get_persona_returns_tags(self, persona_index):
        """Verify tags are returned."""
        result = await get_persona("P-001")
        data = json.loads(result)

        assert "tags" in data
        assert "autonomous" in data["tags"]
        assert "programmatic" in data["tags"]

    async def test_get_persona_returns_related_stories(self, persona_index):
        """Verify related stories are returned."""
        result = await get_persona("P-001")
        data = json.loads(result)

        assert "related_stories" in data
        assert "US-001" in data["related_stories"]
        assert "US-002" in data["related_stories"]

    async def test_get_agent_persona(self, persona_index):
        """Get agent persona (A-XXX ID)."""
        result = await get_persona("A-001")
        data = json.loads(result)

        assert data["id"] == "A-001"
        assert data["name"] == "Gopher Scout"
        assert data["category"] == "Core"

    async def test_get_additional_agent(self, persona_index):
        """Get additional agent from nested directory."""
        result = await get_persona("A-017")
        data = json.loads(result)

        assert data["id"] == "A-017"
        assert data["name"] == "NPL Build Manager"
        assert data["category"] == "Infrastructure"

    async def test_persona_not_found(self, persona_index):
        """Get persona that doesn't exist."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_persona("P-999")

        assert "Persona 'P-999' not found" in str(exc_info.value)

    async def test_list_all_personas(self, persona_index):
        """List all personas without filters."""
        result = await list_personas()
        data = json.loads(result)

        assert data["total_count"] == 4
        assert len(data["personas"]) == 4

    async def test_list_personas_by_tag(self, persona_index):
        """Filter personas by tag."""
        result = await list_personas(tags="autonomous")
        data = json.loads(result)

        assert data["total_count"] == 1
        assert data["personas"][0]["id"] == "P-001"

    async def test_list_personas_by_multiple_tags(self, persona_index):
        """Filter by multiple tags (OR logic)."""
        result = await list_personas(tags="autonomous,discovery")
        data = json.loads(result)

        # Should match P-001 (autonomous) and A-001 (discovery)
        assert data["total_count"] == 2
        ids = [p["id"] for p in data["personas"]]
        assert "P-001" in ids
        assert "A-001" in ids

    async def test_list_personas_by_category(self, persona_index):
        """Filter personas by category."""
        result = await list_personas(category="Core")
        data = json.loads(result)

        # A-001 has category: Core
        assert data["total_count"] >= 1
        for persona in data["personas"]:
            assert persona.get("category") == "Core" or persona["id"].startswith("P-")

    async def test_list_personas_counts(self, persona_index):
        """Verify category counts are returned."""
        result = await list_personas()
        data = json.loads(result)

        # Should have counts for different persona types
        assert "core_personas" in data or "total_count" in data

    async def test_persona_file_missing(self, persona_index):
        """Persona in index but file doesn't exist."""
        # Add a persona to index without creating file
        index_path = persona_index / "index.yaml"
        with open(index_path) as f:
            import yaml
            data = yaml.safe_load(f)
        data["personas"].append({
            "id": "P-999",
            "name": "Missing Persona",
            "file": "missing.md",
            "tags": []
        })
        with open(index_path, "w") as f:
            yaml.dump(data, f)

        result = await get_persona("P-999")
        data = json.loads(result)

        # Should return index data with null/empty content
        assert data["id"] == "P-999"
        assert data["content"] is None or data["content"] == ""
```
