# AT-010: Integration Tests

```python
import pytest
import json
from pathlib import Path

class TestIntegration:
    """End-to-end integration tests."""

    @pytest.fixture
    def full_project_structure(self, tmp_path):
        """Create realistic project structure with all artifacts."""
        # Create user stories
        stories_dir = tmp_path / "project-management" / "user-stories"
        stories_dir.mkdir(parents=True)

        stories_index = """
version: 2
stories:
  - id: US-226
    title: Read User Story by ID
    file: US-226-read-user-story-by-id.md
    persona: P-008
    persona_name: TDD Workflow Agent
    priority: critical
    status: draft
    prd_group: pm_mcp_tools
    prds: []
    related_stories:
      - US-227
    related_personas:
      - P-008
  - id: US-227
    title: List and Filter User Stories
    file: US-227-list-and-filter-user-stories.md
    persona: P-008
    persona_name: TDD Workflow Agent
    priority: high
    status: draft
    prd_group: pm_mcp_tools
    prds: []
    related_stories:
      - US-226
    related_personas:
      - P-008
"""
        (stories_dir / "index.yaml").write_text(stories_index)

        story_content = """# User Story: Read User Story by ID

**ID**: US-226
**Persona**: P-008 (TDD Workflow Agent)
**Priority**: Critical

## Acceptance Criteria

- [ ] get_story accepts story ID
- [ ] Returns full markdown content
- [ ] Returns structured metadata
"""
        (stories_dir / "US-226-read-user-story-by-id.md").write_text(story_content)
        (stories_dir / "US-227-list-and-filter-user-stories.md").write_text("# US-227")

        # Create PRDs
        prds_dir = tmp_path / "project-management" / "PRDs"
        prds_dir.mkdir()

        prd_content = """# PRD-017: Project Management MCP Tools

**Version**: 1.0
**Status**: Draft

## User Stories

| ID | Title |
|---|---|
| US-226 | Read User Story by ID |
| US-227 | List and Filter User Stories |
"""
        (prds_dir / "PRD-017-pm-mcp-tools.md").write_text(prd_content)

        # Create supporting directory
        support_dir = prds_dir / "PRD-017-pm-mcp-tools"
        support_dir.mkdir()

        fr_dir = support_dir / "functional-requirements"
        fr_dir.mkdir()
        fr_index = """
functional_requirements:
  - id: FR-001
    title: User Story Reader
    file: FR-001-user-story-reader.md
"""
        (fr_dir / "index.yaml").write_text(fr_index)
        (fr_dir / "FR-001-user-story-reader.md").write_text("# FR-001: User Story Reader")

        at_dir = support_dir / "acceptance-tests"
        at_dir.mkdir()
        at_index = """
acceptance_tests:
  - id: AT-001
    title: Get Story Basic Tests
    file: AT-001-get-story-basic.md
    fr_id: FR-001
    implementation_status: not_implemented
"""
        (at_dir / "index.yaml").write_text(at_index)
        (at_dir / "AT-001-get-story-basic.md").write_text("# AT-001: Get Story Basic")

        # Create personas
        personas_dir = tmp_path / "project-management" / "personas"
        personas_dir.mkdir()

        personas_index = """
version: 1
personas:
  - id: P-008
    name: TDD Workflow Agent
    file: tdd-workflow-agent.md
    tags:
      - tdd
      - autonomous
    related_stories:
      - US-226
      - US-227
"""
        (personas_dir / "index.yaml").write_text(personas_index)
        (personas_dir / "tdd-workflow-agent.md").write_text("# Persona: TDD Workflow Agent")

        return tmp_path / "project-management"

    async def test_full_workflow_get_story_and_prd(self, full_project_structure):
        """Test getting story then navigating to PRD."""
        # 1. Get story
        story_result = await get_story("US-226")
        story = json.loads(story_result)

        assert story["id"] == "US-226"
        assert story["prd_group"] == "pm_mcp_tools"

        # 2. List stories in same PRD group
        list_result = await list_stories(prd_group="pm_mcp_tools")
        stories = json.loads(list_result)

        assert stories["total_count"] == 2

        # 3. Get PRD (assuming story has PRD reference)
        prd_result = await get_prd("PRD-017")
        prd = json.loads(prd_result)

        assert prd["id"] == "PRD-017"
        assert "US-226" in prd["user_stories"]

    async def test_full_workflow_prd_to_fr_to_at(self, full_project_structure):
        """Test navigating from PRD to FR to AT."""
        # 1. Get PRD
        prd_result = await get_prd("PRD-017")
        prd = json.loads(prd_result)

        assert prd["has_functional_requirements"] == True
        assert prd["functional_requirements_count"] >= 1

        # 2. List FRs for PRD
        frs_result = await get_prd_functional_requirement("PRD-017", "*")
        frs = json.loads(frs_result)

        assert frs["total_count"] >= 1
        fr_ids = [fr["fr_id"] for fr in frs["functional_requirements"]]
        assert "FR-001" in fr_ids

        # 3. Get specific FR
        fr_result = await get_prd_functional_requirement("PRD-017", "FR-001")
        fr = json.loads(fr_result)

        assert fr["fr_id"] == "FR-001"

        # 4. Get ATs for that FR
        ats_result = await get_prd_acceptance_test("PRD-017", "*", fr_id="FR-001")
        ats = json.loads(ats_result)

        assert ats["total_count"] >= 1

    async def test_update_and_verify_workflow(self, full_project_structure):
        """Test updating story metadata and verifying change."""
        # 1. Get initial story state
        initial = await get_story("US-226")
        initial_data = json.loads(initial)

        assert initial_data["status"] == "draft"
        assert "PRD-017" not in initial_data.get("prds", [])

        # 2. Update status
        await update_story_metadata("US-226", "status", "in-progress")

        # 3. Add PRD reference
        await update_story_metadata("US-226", "prds", "PRD-017")

        # 4. Verify changes
        updated = await get_story("US-226")
        updated_data = json.loads(updated)

        assert updated_data["status"] == "in-progress"
        assert "PRD-017" in updated_data["prds"]

        # 5. Verify story appears in PRD-filtered list
        filtered = await list_stories(prd="PRD-017")
        filtered_data = json.loads(filtered)

        assert any(s["id"] == "US-226" for s in filtered_data["stories"])

    async def test_persona_to_stories_workflow(self, full_project_structure):
        """Test navigating from persona to related stories."""
        # 1. Get persona
        persona_result = await get_persona("P-008")
        persona = json.loads(persona_result)

        assert persona["id"] == "P-008"
        assert "US-226" in persona["related_stories"]

        # 2. List stories for this persona
        stories_result = await list_stories(persona="P-008")
        stories = json.loads(stories_result)

        assert stories["total_count"] >= 1
        assert any(s["id"] == "US-226" for s in stories["stories"])

        # 3. Get one of the related stories
        story_result = await get_story("US-226")
        story = json.loads(story_result)

        assert story["persona"] == "P-008"

    async def test_tdd_agent_workflow(self, full_project_structure):
        """Simulate TDD agent workflow: find work -> get spec -> get tests."""
        # 1. TDD agent finds draft stories with critical priority
        stories_result = await list_stories(status="draft", priority="critical")
        stories = json.loads(stories_result)

        assert stories["total_count"] >= 1
        target_story = stories["stories"][0]

        # 2. Get full story details
        story_result = await get_story(target_story["id"])
        story = json.loads(story_result)

        assert "acceptance_criteria" in story

        # 3. Find PRD for this story's group
        prd_result = await get_prd("PRD-017")
        prd = json.loads(prd_result)

        # 4. Get acceptance tests to implement
        ats_result = await get_prd_acceptance_test("PRD-017", "*")
        ats = json.loads(ats_result)

        # 5. Update story status to in-progress
        await update_story_metadata(target_story["id"], "status", "in-progress")

        # Verify update
        updated = await get_story(target_story["id"])
        updated_data = json.loads(updated)
        assert updated_data["status"] == "in-progress"
```
