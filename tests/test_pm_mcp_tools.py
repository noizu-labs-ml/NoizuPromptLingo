#!/usr/bin/env python3
"""
Tests for Project Management MCP Tools (PRD-017).

This test suite validates the PM MCP tools for accessing project management
artifacts: user stories, PRDs, functional requirements, acceptance tests, and personas.

PRD: project-management/PRDs/PRD-017-pm-mcp-tools.md
Acceptance Tests: project-management/PRDs/PRD-017-pm-mcp-tools/acceptance-tests/

Run with:
    uv run pytest tests/test_pm_mcp_tools.py -v
    mise run test-errors tests/test_pm_mcp_tools.py
"""

import json
from pathlib import Path
from typing import Any

import pytest
import yaml


# =============================================================================
# Import exceptions and tools from implementation
# =============================================================================

from npl_mcp.pm_tools.exceptions import NotFoundError, ValidationError, ParseError
from npl_mcp.pm_tools.stories import get_story, list_stories, update_story_metadata
from npl_mcp.pm_tools.prds import get_prd, get_prd_functional_requirement, get_prd_acceptance_test
from npl_mcp.pm_tools.personas import get_persona, list_personas


# =============================================================================
# Fixtures
# =============================================================================

@pytest.fixture
def sample_story_index(tmp_path: Path) -> Path:
    """Create a sample user stories index.yaml for testing."""
    stories_dir = tmp_path / "user-stories"
    stories_dir.mkdir(parents=True)

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
    (stories_dir / "index.yaml").write_text(index_content.strip())
    return stories_dir


@pytest.fixture
def sample_story_file(sample_story_index: Path) -> Path:
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
    (sample_story_index / "US-001-load-npl-core.md").write_text(story_content)
    return sample_story_index


@pytest.fixture
def multi_story_index(tmp_path: Path) -> Path:
    """Create index with multiple stories for filtering tests."""
    stories_dir = tmp_path / "user-stories"
    stories_dir.mkdir(parents=True)

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
    (stories_dir / "index.yaml").write_text(index_content.strip())
    return stories_dir


@pytest.fixture
def sample_prd(tmp_path: Path) -> Path:
    """Create a sample PRD with supporting directory."""
    prd_dir = tmp_path / "PRDs"
    prd_dir.mkdir(parents=True)

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
    (fr_dir / "index.yaml").write_text(
        "functional_requirements:\n  - id: FR-001\n    title: Test FR\n    file: FR-001.md"
    )
    (fr_dir / "FR-001.md").write_text("# FR-001: Test")

    # Create AT directory with files
    at_dir = support_dir / "acceptance-tests"
    at_dir.mkdir()
    (at_dir / "index.yaml").write_text(
        "acceptance_tests:\n  - id: AT-001\n    title: Test AT\n    file: AT-001.md"
    )
    (at_dir / "AT-001.md").write_text("# AT-001: Test")

    return prd_dir


@pytest.fixture
def prd_with_frs(tmp_path: Path) -> Path:
    """Create PRD with functional requirements directory."""
    prd_dir = tmp_path / "PRDs"
    prd_dir.mkdir(parents=True)

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
    (fr_dir / "index.yaml").write_text(index_content.strip())

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


@pytest.fixture
def prd_with_ats(tmp_path: Path) -> Path:
    """Create PRD with acceptance tests directory."""
    prd_dir = tmp_path / "PRDs"
    prd_dir.mkdir(parents=True)

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
    (at_dir / "index.yaml").write_text(index_content.strip())

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


@pytest.fixture
def updatable_index(tmp_path: Path) -> Path:
    """Create index that can be updated."""
    stories_dir = tmp_path / "user-stories"
    stories_dir.mkdir(parents=True)

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
    (stories_dir / "index.yaml").write_text(index_content.strip())
    return stories_dir


@pytest.fixture
def persona_index(tmp_path: Path) -> Path:
    """Create personas directory with index and files."""
    personas_dir = tmp_path / "personas"
    personas_dir.mkdir(parents=True)

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
    (personas_dir / "index.yaml").write_text(index_content.strip())

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


@pytest.fixture
def full_project_structure(tmp_path: Path) -> Path:
    """Create realistic project structure with all artifacts."""
    pm_dir = tmp_path / "project-management"
    pm_dir.mkdir(parents=True)

    # Create user stories
    stories_dir = pm_dir / "user-stories"
    stories_dir.mkdir()

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
    (stories_dir / "index.yaml").write_text(stories_index.strip())

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
    prds_dir = pm_dir / "PRDs"
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
    (fr_dir / "index.yaml").write_text(fr_index.strip())
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
    (at_dir / "index.yaml").write_text(at_index.strip())
    (at_dir / "AT-001-get-story-basic.md").write_text("# AT-001: Get Story Basic")

    # Create personas
    personas_dir = pm_dir / "personas"
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
    (personas_dir / "index.yaml").write_text(personas_index.strip())
    (personas_dir / "tdd-workflow-agent.md").write_text("# Persona: TDD Workflow Agent")

    return pm_dir


# =============================================================================
# AT-001: Get Story Basic Tests
# =============================================================================

class TestGetStoryBasic:
    """Basic tests for get_story tool (AT-001)."""

    @pytest.mark.asyncio
    async def test_get_story_by_full_id(self, sample_story_file: Path) -> None:
        """Get story using full ID format US-XXX."""
        result = await get_story("US-001", stories_dir=sample_story_file)
        data = json.loads(result)

        assert data["id"] == "US-001"
        assert data["title"] == "Load NPL Core Components"
        assert data["persona"] == "P-001"
        assert data["priority"] == "critical"
        assert data["status"] == "draft"

    @pytest.mark.asyncio
    async def test_get_story_by_numeric_id(self, sample_story_file: Path) -> None:
        """Get story using numeric ID without prefix."""
        result = await get_story("001", stories_dir=sample_story_file)
        data = json.loads(result)

        assert data["id"] == "US-001"

    @pytest.mark.asyncio
    async def test_get_story_by_bare_number(self, sample_story_file: Path) -> None:
        """Get story using bare number."""
        result = await get_story("1", stories_dir=sample_story_file)
        data = json.loads(result)

        assert data["id"] == "US-001"

    @pytest.mark.asyncio
    async def test_get_story_returns_metadata(self, sample_story_file: Path) -> None:
        """Verify all metadata fields are returned."""
        result = await get_story("US-001", stories_dir=sample_story_file)
        data = json.loads(result)

        assert "prd_group" in data
        assert data["prd_group"] == "npl_load"
        assert "prds" in data
        assert "PRD-008" in data["prds"]
        assert "related_stories" in data
        assert "US-002" in data["related_stories"]
        assert "related_personas" in data
        assert "P-001" in data["related_personas"]

    @pytest.mark.asyncio
    async def test_get_story_returns_content(self, sample_story_file: Path) -> None:
        """Verify markdown content is returned."""
        result = await get_story("US-001", stories_dir=sample_story_file)
        data = json.loads(result)

        assert "content" in data
        assert "# User Story: Load NPL Core Components" in data["content"]

    @pytest.mark.asyncio
    async def test_get_story_parses_acceptance_criteria(self, sample_story_file: Path) -> None:
        """Verify acceptance criteria are parsed correctly."""
        result = await get_story("US-001", stories_dir=sample_story_file)
        data = json.loads(result)

        assert "acceptance_criteria" in data
        criteria = data["acceptance_criteria"]
        assert len(criteria) == 3

        assert criteria[0]["text"] == "First criterion not completed"
        assert criteria[0]["completed"] is False

        assert criteria[1]["text"] == "Second criterion completed"
        assert criteria[1]["completed"] is True

        assert criteria[2]["text"] == "Third criterion not completed"
        assert criteria[2]["completed"] is False


# =============================================================================
# AT-002: Get Story Edge Cases
# =============================================================================

class TestGetStoryEdgeCases:
    """Edge case tests for get_story tool (AT-002)."""

    @pytest.mark.asyncio
    async def test_story_not_found(self, sample_story_index: Path) -> None:
        """Get story that doesn't exist in index."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_story("US-999", stories_dir=sample_story_index)

        assert "User story 'US-999' not found in index" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_invalid_id_format(self, sample_story_index: Path) -> None:
        """Get story with invalid ID format."""
        with pytest.raises(ValidationError) as exc_info:
            await get_story("ABC-001", stories_dir=sample_story_index)

        assert "Invalid story ID format" in str(exc_info.value)
        assert "Expected 'US-XXX' or numeric ID" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_story_file_missing(self, sample_story_index: Path) -> None:
        """Story in index but file doesn't exist."""
        # Index has US-001 but file doesn't exist
        result = await get_story("US-001", stories_dir=sample_story_index)
        data = json.loads(result)

        # Should return metadata with null/empty content
        assert data["id"] == "US-001"
        assert data["content"] is None or data["content"] == ""
        assert "warning" in data or data.get("file_exists") is False

    @pytest.mark.asyncio
    async def test_index_file_missing(self, tmp_path: Path) -> None:
        """Index file doesn't exist."""
        empty_dir = tmp_path / "empty-stories"
        empty_dir.mkdir()

        with pytest.raises(FileNotFoundError) as exc_info:
            await get_story("US-001", stories_dir=empty_dir)

        assert "Index file not found" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_malformed_yaml_index(self, tmp_path: Path) -> None:
        """Index file has invalid YAML."""
        stories_dir = tmp_path / "bad-stories"
        stories_dir.mkdir()
        (stories_dir / "index.yaml").write_text("invalid: yaml: content: [")

        with pytest.raises(ParseError) as exc_info:
            await get_story("US-001", stories_dir=stories_dir)

        assert "Failed to parse YAML" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_empty_story_id(self, sample_story_index: Path) -> None:
        """Get story with empty ID."""
        with pytest.raises(ValidationError) as exc_info:
            await get_story("", stories_dir=sample_story_index)

        assert "Invalid story ID" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_whitespace_story_id(self, sample_story_index: Path) -> None:
        """Get story with whitespace-only ID."""
        with pytest.raises(ValidationError) as exc_info:
            await get_story("   ", stories_dir=sample_story_index)

        assert "Invalid story ID" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_story_with_no_acceptance_criteria(self, sample_story_index: Path) -> None:
        """Story markdown has no acceptance criteria section."""
        story_content = """# User Story: Simple Story

**ID**: US-001

## Story

Just a simple story with no AC.
"""
        (sample_story_index / "US-001-load-npl-core.md").write_text(story_content)

        result = await get_story("US-001", stories_dir=sample_story_index)
        data = json.loads(result)

        assert data["acceptance_criteria"] == []

    @pytest.mark.asyncio
    async def test_story_with_nested_checkboxes(self, sample_story_index: Path) -> None:
        """Story has nested checkbox items."""
        story_content = """# User Story

## Acceptance Criteria

- [ ] Main criterion
  - [ ] Sub-criterion 1
  - [x] Sub-criterion 2
- [ ] Another main criterion
"""
        (sample_story_index / "US-001-load-npl-core.md").write_text(story_content)

        result = await get_story("US-001", stories_dir=sample_story_index)
        data = json.loads(result)

        # Should handle nested items appropriately
        assert len(data["acceptance_criteria"]) >= 2


# =============================================================================
# AT-003: List Stories Tests
# =============================================================================

class TestListStories:
    """Tests for list_stories tool with filters (AT-003)."""

    @pytest.mark.asyncio
    async def test_list_all_stories(self, multi_story_index: Path) -> None:
        """List all stories without filters."""
        result = await list_stories(stories_dir=multi_story_index)
        data = json.loads(result)

        assert data["total_count"] == 4
        assert data["returned_count"] == 4
        assert len(data["stories"]) == 4

    @pytest.mark.asyncio
    async def test_stories_sorted_by_priority(self, multi_story_index: Path) -> None:
        """Stories are sorted by priority (critical first)."""
        result = await list_stories(stories_dir=multi_story_index)
        data = json.loads(result)

        priorities = [s["priority"] for s in data["stories"]]
        assert priorities == ["critical", "high", "medium", "low"]

    @pytest.mark.asyncio
    async def test_filter_by_status(self, multi_story_index: Path) -> None:
        """Filter stories by status."""
        result = await list_stories(status="draft", stories_dir=multi_story_index)
        data = json.loads(result)

        assert data["total_count"] == 2
        for story in data["stories"]:
            assert story["status"] == "draft"

    @pytest.mark.asyncio
    async def test_filter_by_priority(self, multi_story_index: Path) -> None:
        """Filter stories by priority."""
        result = await list_stories(priority="critical", stories_dir=multi_story_index)
        data = json.loads(result)

        assert data["total_count"] == 1
        assert data["stories"][0]["id"] == "US-001"

    @pytest.mark.asyncio
    async def test_filter_by_persona(self, multi_story_index: Path) -> None:
        """Filter stories by persona ID."""
        result = await list_stories(persona="P-001", stories_dir=multi_story_index)
        data = json.loads(result)

        assert data["total_count"] == 2
        for story in data["stories"]:
            assert story["persona"] == "P-001"

    @pytest.mark.asyncio
    async def test_filter_by_prd_group(self, multi_story_index: Path) -> None:
        """Filter stories by PRD group."""
        result = await list_stories(prd_group="mcp_tools", stories_dir=multi_story_index)
        data = json.loads(result)

        assert data["total_count"] == 2
        ids = [s["id"] for s in data["stories"]]
        assert "US-003" in ids
        assert "US-004" in ids

    @pytest.mark.asyncio
    async def test_filter_by_prd(self, multi_story_index: Path) -> None:
        """Filter stories by linked PRD."""
        result = await list_stories(prd="PRD-010", stories_dir=multi_story_index)
        data = json.loads(result)

        assert data["total_count"] == 2
        ids = [s["id"] for s in data["stories"]]
        assert "US-003" in ids
        assert "US-004" in ids

    @pytest.mark.asyncio
    async def test_combined_filters_and_logic(self, multi_story_index: Path) -> None:
        """Multiple filters use AND logic."""
        result = await list_stories(
            status="draft",
            priority="high",
            stories_dir=multi_story_index
        )
        data = json.loads(result)

        assert data["total_count"] == 1
        assert data["stories"][0]["id"] == "US-002"

    @pytest.mark.asyncio
    async def test_pagination_limit(self, multi_story_index: Path) -> None:
        """Limit number of returned stories."""
        result = await list_stories(limit=2, stories_dir=multi_story_index)
        data = json.loads(result)

        assert data["total_count"] == 4
        assert data["returned_count"] == 2
        assert len(data["stories"]) == 2

    @pytest.mark.asyncio
    async def test_pagination_offset(self, multi_story_index: Path) -> None:
        """Skip stories with offset."""
        result = await list_stories(limit=2, offset=2, stories_dir=multi_story_index)
        data = json.loads(result)

        assert data["total_count"] == 4
        assert data["offset"] == 2
        assert data["returned_count"] == 2
        # Should get medium and low priority stories
        priorities = [s["priority"] for s in data["stories"]]
        assert "medium" in priorities
        assert "low" in priorities

    @pytest.mark.asyncio
    async def test_no_matching_stories(self, multi_story_index: Path) -> None:
        """No stories match filter criteria."""
        result = await list_stories(status="tested", stories_dir=multi_story_index)
        data = json.loads(result)

        assert data["total_count"] == 0
        assert data["returned_count"] == 0
        assert data["stories"] == []

    @pytest.mark.asyncio
    async def test_empty_index(self, tmp_path: Path) -> None:
        """Index exists but has no stories."""
        stories_dir = tmp_path / "empty-stories"
        stories_dir.mkdir()
        (stories_dir / "index.yaml").write_text("version: 2\nstories: []")

        result = await list_stories(stories_dir=stories_dir)
        data = json.loads(result)

        assert data["total_count"] == 0
        assert data["stories"] == []


# =============================================================================
# AT-004: Get PRD Tests
# =============================================================================

class TestGetPRD:
    """Tests for get_prd tool (AT-004)."""

    @pytest.mark.asyncio
    async def test_get_prd_by_full_id(self, sample_prd: Path) -> None:
        """Get PRD using full ID format PRD-XXX."""
        result = await get_prd("PRD-015", prds_dir=sample_prd)
        data = json.loads(result)

        assert data["id"] == "PRD-015"
        assert data["title"] == "NPL Advanced Loading Extension"

    @pytest.mark.asyncio
    async def test_get_prd_by_numeric_id(self, sample_prd: Path) -> None:
        """Get PRD using numeric ID without prefix."""
        result = await get_prd("015", prds_dir=sample_prd)
        data = json.loads(result)

        assert data["id"] == "PRD-015"

    @pytest.mark.asyncio
    async def test_get_prd_returns_metadata(self, sample_prd: Path) -> None:
        """Verify metadata is extracted from PRD."""
        result = await get_prd("PRD-015", prds_dir=sample_prd)
        data = json.loads(result)

        assert data["version"] == "1.0"
        assert data["status"] == "Draft"

    @pytest.mark.asyncio
    async def test_get_prd_returns_content(self, sample_prd: Path) -> None:
        """Verify full markdown content is returned."""
        result = await get_prd("PRD-015", prds_dir=sample_prd)
        data = json.loads(result)

        assert "content" in data
        assert "## Overview" in data["content"]
        assert "Test PRD content" in data["content"]

    @pytest.mark.asyncio
    async def test_get_prd_detects_supporting_directory(self, sample_prd: Path) -> None:
        """Verify supporting directory is detected."""
        result = await get_prd("PRD-015", prds_dir=sample_prd)
        data = json.loads(result)

        assert data["has_functional_requirements"] is True
        assert data["has_acceptance_tests"] is True
        assert "supporting_directory" in data
        assert "PRD-015-npl-loading-extension" in data["supporting_directory"]

    @pytest.mark.asyncio
    async def test_get_prd_counts_fr_and_at(self, sample_prd: Path) -> None:
        """Verify FR and AT counts are returned."""
        result = await get_prd("PRD-015", prds_dir=sample_prd)
        data = json.loads(result)

        assert data["functional_requirements_count"] == 1
        assert data["acceptance_tests_count"] == 1

    @pytest.mark.asyncio
    async def test_get_prd_extracts_user_stories(self, sample_prd: Path) -> None:
        """Verify user story references are extracted."""
        result = await get_prd("PRD-015", prds_dir=sample_prd)
        data = json.loads(result)

        assert "user_stories" in data
        assert "US-201" in data["user_stories"]
        assert "US-202" in data["user_stories"]

    @pytest.mark.asyncio
    async def test_prd_not_found(self, sample_prd: Path) -> None:
        """Get PRD that doesn't exist."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_prd("PRD-999", prds_dir=sample_prd)

        assert "PRD 'PRD-999' not found" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_prd_without_supporting_directory(self, tmp_path: Path) -> None:
        """PRD exists but has no supporting directory."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()

        prd_content = "# PRD-001: Simple PRD\n\n**Version**: 0.1\n**Status**: Draft"
        (prd_dir / "PRD-001-simple.md").write_text(prd_content)

        result = await get_prd("PRD-001", prds_dir=prd_dir)
        data = json.loads(result)

        assert data["id"] == "PRD-001"
        assert data["supporting_directory"] is None
        assert data["has_functional_requirements"] is False
        assert data["has_acceptance_tests"] is False
        assert data["functional_requirements_count"] == 0

    @pytest.mark.asyncio
    async def test_prd_missing_metadata_uses_defaults(self, tmp_path: Path) -> None:
        """PRD without standard metadata lines uses defaults."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()

        prd_content = "# PRD-001: No Metadata PRD\n\nJust content."
        (prd_dir / "PRD-001-no-meta.md").write_text(prd_content)

        result = await get_prd("PRD-001", prds_dir=prd_dir)
        data = json.loads(result)

        # Should use defaults
        assert data["version"] in ["0.0", "Unknown", None]
        assert data["status"] in ["draft", "Unknown", None]


# =============================================================================
# AT-005: Get Functional Requirement Tests
# =============================================================================

class TestGetFunctionalRequirement:
    """Tests for get_prd_functional_requirement tool (AT-005)."""

    @pytest.mark.asyncio
    async def test_get_single_fr(self, prd_with_frs: Path) -> None:
        """Get a specific functional requirement."""
        result = await get_prd_functional_requirement(
            "PRD-017", "FR-001", prds_dir=prd_with_frs
        )
        data = json.loads(result)

        assert data["prd_id"] == "PRD-017"
        assert data["fr_id"] == "FR-001"
        assert data["title"] == "User Story Reader"
        assert "content" in data
        assert "## Interface" in data["content"]

    @pytest.mark.asyncio
    async def test_get_fr_metadata(self, prd_with_frs: Path) -> None:
        """Verify FR metadata is returned."""
        result = await get_prd_functional_requirement(
            "PRD-017", "FR-001", prds_dir=prd_with_frs
        )
        data = json.loads(result)

        assert data["status"] == "documented"
        assert data["priority"] == "high"
        assert "file" in data

    @pytest.mark.asyncio
    async def test_list_all_frs_with_asterisk(self, prd_with_frs: Path) -> None:
        """List all FRs using asterisk."""
        result = await get_prd_functional_requirement(
            "PRD-017", "*", prds_dir=prd_with_frs
        )
        data = json.loads(result)

        assert data["prd_id"] == "PRD-017"
        assert data["total_count"] == 2
        assert len(data["functional_requirements"]) == 2

    @pytest.mark.asyncio
    async def test_list_all_frs_default(self, prd_with_frs: Path) -> None:
        """List all FRs when fr_id is omitted (defaults to *)."""
        result = await get_prd_functional_requirement("PRD-017", prds_dir=prd_with_frs)
        data = json.loads(result)

        assert data["total_count"] == 2

    @pytest.mark.asyncio
    async def test_fr_not_found(self, prd_with_frs: Path) -> None:
        """Get FR that doesn't exist."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_prd_functional_requirement(
                "PRD-017", "FR-999", prds_dir=prd_with_frs
            )

        assert "Functional requirement 'FR-999' not found" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_prd_has_no_fr_directory(self, tmp_path: Path) -> None:
        """PRD exists but has no functional-requirements directory."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()
        (prd_dir / "PRD-001-simple.md").write_text("# PRD-001")

        result = await get_prd_functional_requirement(
            "PRD-001", "*", prds_dir=prd_dir
        )
        data = json.loads(result)

        assert data["total_count"] == 0
        assert data["functional_requirements"] == []

    @pytest.mark.asyncio
    async def test_fr_id_without_prefix(self, prd_with_frs: Path) -> None:
        """Get FR using ID without prefix."""
        result = await get_prd_functional_requirement(
            "PRD-017", "001", prds_dir=prd_with_frs
        )
        data = json.loads(result)

        assert data["fr_id"] == "FR-001"

    @pytest.mark.asyncio
    async def test_fr_discovery_without_index(self, tmp_path: Path) -> None:
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

        result = await get_prd_functional_requirement(
            "PRD-001", "*", prds_dir=prd_dir
        )
        data = json.loads(result)

        assert data["total_count"] == 2


# =============================================================================
# AT-006: Get Acceptance Test Tests
# =============================================================================

class TestGetAcceptanceTest:
    """Tests for get_prd_acceptance_test tool (AT-006)."""

    @pytest.mark.asyncio
    async def test_get_single_at(self, prd_with_ats: Path) -> None:
        """Get a specific acceptance test."""
        result = await get_prd_acceptance_test(
            "PRD-017", "AT-001", prds_dir=prd_with_ats
        )
        data = json.loads(result)

        assert data["prd_id"] == "PRD-017"
        assert data["at_id"] == "AT-001"
        assert data["title"] == "Get Story Basic Tests"
        assert "content" in data

    @pytest.mark.asyncio
    async def test_get_at_structured_data(self, prd_with_ats: Path) -> None:
        """Verify structured test data is extracted."""
        result = await get_prd_acceptance_test(
            "PRD-017", "AT-001", prds_dir=prd_with_ats
        )
        data = json.loads(result)

        assert "preconditions" in data
        assert len(data["preconditions"]) == 2
        assert "Index.yaml exists" in data["preconditions"]

        assert "steps" in data
        assert len(data["steps"]) >= 3

        assert "expected_results" in data
        assert len(data["expected_results"]) >= 3

    @pytest.mark.asyncio
    async def test_get_at_metadata(self, prd_with_ats: Path) -> None:
        """Verify AT metadata is returned."""
        result = await get_prd_acceptance_test(
            "PRD-017", "AT-001", prds_dir=prd_with_ats
        )
        data = json.loads(result)

        assert data["fr_id"] == "FR-001"
        assert data["status"] == "documented"
        assert data["test_type"] == "unit"
        assert data["implementation_status"] == "implemented"

    @pytest.mark.asyncio
    async def test_list_all_ats_with_asterisk(self, prd_with_ats: Path) -> None:
        """List all ATs using asterisk."""
        result = await get_prd_acceptance_test("PRD-017", "*", prds_dir=prd_with_ats)
        data = json.loads(result)

        assert data["prd_id"] == "PRD-017"
        assert data["total_count"] == 3
        assert len(data["acceptance_tests"]) == 3

    @pytest.mark.asyncio
    async def test_list_ats_with_coverage_stats(self, prd_with_ats: Path) -> None:
        """Verify coverage statistics are returned."""
        result = await get_prd_acceptance_test("PRD-017", "*", prds_dir=prd_with_ats)
        data = json.loads(result)

        assert data["implemented_count"] == 1
        assert data["coverage_percentage"] == pytest.approx(33.33, rel=0.1)

    @pytest.mark.asyncio
    async def test_filter_ats_by_fr(self, prd_with_ats: Path) -> None:
        """Filter ATs by functional requirement."""
        result = await get_prd_acceptance_test(
            "PRD-017", "*", fr_id="FR-001", prds_dir=prd_with_ats
        )
        data = json.loads(result)

        assert data["total_count"] == 2
        for at in data["acceptance_tests"]:
            assert at["fr_id"] == "FR-001"

    @pytest.mark.asyncio
    async def test_at_not_found(self, prd_with_ats: Path) -> None:
        """Get AT that doesn't exist."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_prd_acceptance_test("PRD-017", "AT-999", prds_dir=prd_with_ats)

        assert "Acceptance test 'AT-999' not found" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_prd_has_no_at_directory(self, tmp_path: Path) -> None:
        """PRD exists but has no acceptance-tests directory."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()
        (prd_dir / "PRD-001-simple.md").write_text("# PRD-001")

        result = await get_prd_acceptance_test("PRD-001", "*", prds_dir=prd_dir)
        data = json.loads(result)

        assert data["total_count"] == 0
        assert data["acceptance_tests"] == []
        assert data["coverage_percentage"] == 0.0

    @pytest.mark.asyncio
    async def test_at_without_structured_sections(self, tmp_path: Path) -> None:
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

        result = await get_prd_acceptance_test("PRD-001", "AT-001", prds_dir=prd_dir)
        data = json.loads(result)

        # Should return content with empty structured lists
        assert data["at_id"] == "AT-001"
        assert "content" in data
        assert data["preconditions"] == []
        assert data["steps"] == []
        assert data["expected_results"] == []


# =============================================================================
# AT-007: Update Story Metadata Tests
# =============================================================================

class TestUpdateStoryMetadata:
    """Tests for update_story_metadata tool (AT-007)."""

    @pytest.mark.asyncio
    async def test_update_status(self, updatable_index: Path) -> None:
        """Update story status field."""
        result = await update_story_metadata(
            "US-001", "status", "in-progress", stories_dir=updatable_index
        )
        data = json.loads(result)

        assert data["success"] is True
        assert data["story_id"] == "US-001"
        assert "status" in data["updated_fields"]
        assert data["previous_values"]["status"] == "draft"
        assert data["current_entry"]["status"] == "in-progress"

        # Verify file was actually updated
        index_path = updatable_index / "index.yaml"
        with open(index_path) as f:
            updated = yaml.safe_load(f)
        assert updated["stories"][0]["status"] == "in-progress"

    @pytest.mark.asyncio
    async def test_update_priority(self, updatable_index: Path) -> None:
        """Update story priority field."""
        result = await update_story_metadata(
            "US-001", "priority", "critical", stories_dir=updatable_index
        )
        data = json.loads(result)

        assert data["success"] is True
        assert data["current_entry"]["priority"] == "critical"

    @pytest.mark.asyncio
    async def test_append_to_prds_array(self, updatable_index: Path) -> None:
        """Append PRD to prds array."""
        result = await update_story_metadata(
            "US-001", "prds", "PRD-017", stories_dir=updatable_index
        )
        data = json.loads(result)

        assert data["success"] is True
        assert "PRD-017" in data["current_entry"]["prds"]

    @pytest.mark.asyncio
    async def test_append_avoids_duplicates(self, updatable_index: Path) -> None:
        """Appending same value twice doesn't create duplicates."""
        await update_story_metadata(
            "US-001", "prds", "PRD-017", stories_dir=updatable_index
        )
        result = await update_story_metadata(
            "US-001", "prds", "PRD-017", stories_dir=updatable_index
        )
        data = json.loads(result)

        # Should only have one PRD-017
        assert data["current_entry"]["prds"].count("PRD-017") == 1

    @pytest.mark.asyncio
    async def test_update_related_stories(self, updatable_index: Path) -> None:
        """Update related_stories array."""
        result = await update_story_metadata(
            "US-001", "related_stories", "US-002,US-003", stories_dir=updatable_index
        )
        data = json.loads(result)

        assert data["success"] is True
        assert "US-002" in data["current_entry"]["related_stories"]
        assert "US-003" in data["current_entry"]["related_stories"]

    @pytest.mark.asyncio
    async def test_update_related_personas(self, updatable_index: Path) -> None:
        """Update related_personas array."""
        result = await update_story_metadata(
            "US-001", "related_personas", "P-002", stories_dir=updatable_index
        )
        data = json.loads(result)

        assert data["success"] is True
        assert "P-002" in data["current_entry"]["related_personas"]

    @pytest.mark.asyncio
    async def test_story_not_found(self, updatable_index: Path) -> None:
        """Update story that doesn't exist."""
        with pytest.raises(NotFoundError) as exc_info:
            await update_story_metadata(
                "US-999", "status", "draft", stories_dir=updatable_index
            )

        assert "not found" in str(exc_info.value).lower()

    @pytest.mark.asyncio
    async def test_invalid_key(self, updatable_index: Path) -> None:
        """Update with invalid metadata key."""
        with pytest.raises(ValidationError) as exc_info:
            await update_story_metadata(
                "US-001", "invalid_key", "value", stories_dir=updatable_index
            )

        assert "Invalid metadata key" in str(exc_info.value)
        assert "Valid keys" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_invalid_status_value(self, updatable_index: Path) -> None:
        """Update status with invalid value."""
        with pytest.raises(ValidationError) as exc_info:
            await update_story_metadata(
                "US-001", "status", "invalid-status", stories_dir=updatable_index
            )

        assert "Invalid value" in str(exc_info.value)
        assert "status" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_invalid_priority_value(self, updatable_index: Path) -> None:
        """Update priority with invalid value."""
        with pytest.raises(ValidationError) as exc_info:
            await update_story_metadata(
                "US-001", "priority", "super-high", stories_dir=updatable_index
            )

        assert "Invalid value" in str(exc_info.value)
        assert "priority" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_atomic_write_preserves_other_stories(self, tmp_path: Path) -> None:
        """Update preserves other stories in index."""
        stories_dir = tmp_path / "user-stories"
        stories_dir.mkdir()

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
        index_path = stories_dir / "index.yaml"
        index_path.write_text(index_content.strip())

        await update_story_metadata(
            "US-001", "status", "documented", stories_dir=stories_dir
        )

        # Verify US-002 is unchanged
        with open(index_path) as f:
            updated = yaml.safe_load(f)
        us002 = [s for s in updated["stories"] if s["id"] == "US-002"][0]
        assert us002["status"] == "in-progress"
        assert us002["priority"] == "medium"

    @pytest.mark.asyncio
    async def test_preserves_yaml_structure(self, updatable_index: Path) -> None:
        """Update preserves YAML structure and formatting."""
        await update_story_metadata(
            "US-001", "status", "in-progress", stories_dir=updatable_index
        )

        index_path = updatable_index / "index.yaml"
        with open(index_path) as f:
            content = f.read()

        # Should still have version field
        assert "version:" in content
        # Should still be valid YAML
        data = yaml.safe_load(content)
        assert data["version"] == 2


# =============================================================================
# AT-008: Persona Access Tests
# =============================================================================

class TestPersonaAccess:
    """Tests for get_persona and list_personas tools (AT-008)."""

    @pytest.mark.asyncio
    async def test_get_persona_by_id(self, persona_index: Path) -> None:
        """Get persona using full ID."""
        result = await get_persona("P-001", personas_dir=persona_index)
        data = json.loads(result)

        assert data["id"] == "P-001"
        assert data["name"] == "AI Agent"
        assert "content" in data

    @pytest.mark.asyncio
    async def test_get_persona_structured_data(self, persona_index: Path) -> None:
        """Verify structured data is extracted."""
        result = await get_persona("P-001", personas_dir=persona_index)
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

    @pytest.mark.asyncio
    async def test_get_persona_returns_tags(self, persona_index: Path) -> None:
        """Verify tags are returned."""
        result = await get_persona("P-001", personas_dir=persona_index)
        data = json.loads(result)

        assert "tags" in data
        assert "autonomous" in data["tags"]
        assert "programmatic" in data["tags"]

    @pytest.mark.asyncio
    async def test_get_persona_returns_related_stories(self, persona_index: Path) -> None:
        """Verify related stories are returned."""
        result = await get_persona("P-001", personas_dir=persona_index)
        data = json.loads(result)

        assert "related_stories" in data
        assert "US-001" in data["related_stories"]
        assert "US-002" in data["related_stories"]

    @pytest.mark.asyncio
    async def test_get_agent_persona(self, persona_index: Path) -> None:
        """Get agent persona (A-XXX ID)."""
        result = await get_persona("A-001", personas_dir=persona_index)
        data = json.loads(result)

        assert data["id"] == "A-001"
        assert data["name"] == "Gopher Scout"
        assert data["category"] == "Core"

    @pytest.mark.asyncio
    async def test_get_additional_agent(self, persona_index: Path) -> None:
        """Get additional agent from nested directory."""
        result = await get_persona("A-017", personas_dir=persona_index)
        data = json.loads(result)

        assert data["id"] == "A-017"
        assert data["name"] == "NPL Build Manager"
        assert data["category"] == "Infrastructure"

    @pytest.mark.asyncio
    async def test_persona_not_found(self, persona_index: Path) -> None:
        """Get persona that doesn't exist."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_persona("P-999", personas_dir=persona_index)

        assert "Persona 'P-999' not found" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_list_all_personas(self, persona_index: Path) -> None:
        """List all personas without filters."""
        result = await list_personas(personas_dir=persona_index)
        data = json.loads(result)

        assert data["total_count"] == 4
        assert len(data["personas"]) == 4

    @pytest.mark.asyncio
    async def test_list_personas_by_tag(self, persona_index: Path) -> None:
        """Filter personas by tag."""
        result = await list_personas(tags="autonomous", personas_dir=persona_index)
        data = json.loads(result)

        assert data["total_count"] == 1
        assert data["personas"][0]["id"] == "P-001"

    @pytest.mark.asyncio
    async def test_list_personas_by_multiple_tags(self, persona_index: Path) -> None:
        """Filter by multiple tags (OR logic)."""
        result = await list_personas(
            tags="autonomous,discovery", personas_dir=persona_index
        )
        data = json.loads(result)

        # Should match P-001 (autonomous) and A-001 (discovery)
        assert data["total_count"] == 2
        ids = [p["id"] for p in data["personas"]]
        assert "P-001" in ids
        assert "A-001" in ids

    @pytest.mark.asyncio
    async def test_list_personas_by_category(self, persona_index: Path) -> None:
        """Filter personas by category."""
        result = await list_personas(category="Core", personas_dir=persona_index)
        data = json.loads(result)

        # A-001 has category: Core
        assert data["total_count"] >= 1
        for persona in data["personas"]:
            assert persona.get("category") == "Core" or persona["id"].startswith("P-")

    @pytest.mark.asyncio
    async def test_list_personas_counts(self, persona_index: Path) -> None:
        """Verify category counts are returned."""
        result = await list_personas(personas_dir=persona_index)
        data = json.loads(result)

        # Should have counts for different persona types
        assert "core_personas" in data or "total_count" in data

    @pytest.mark.asyncio
    async def test_persona_file_missing(self, persona_index: Path) -> None:
        """Persona in index but file doesn't exist."""
        # Add a persona to index without creating file
        index_path = persona_index / "index.yaml"
        with open(index_path) as f:
            data = yaml.safe_load(f)
        data["personas"].append({
            "id": "P-999",
            "name": "Missing Persona",
            "file": "missing.md",
            "tags": []
        })
        with open(index_path, "w") as f:
            yaml.dump(data, f)

        result = await get_persona("P-999", personas_dir=persona_index)
        data = json.loads(result)

        # Should return index data with null/empty content
        assert data["id"] == "P-999"
        assert data["content"] is None or data["content"] == ""


# =============================================================================
# AT-009: Error Handling Tests
# =============================================================================

class TestErrorHandling:
    """Tests for error conditions across all tools (AT-009)."""

    # ============ Story Tool Errors ============

    @pytest.mark.asyncio
    async def test_get_story_empty_id(self, sample_story_index: Path) -> None:
        """Empty story ID raises ValidationError."""
        with pytest.raises(ValidationError) as exc_info:
            await get_story("", stories_dir=sample_story_index)

        assert "Invalid story ID" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_get_story_invalid_format(self, sample_story_index: Path) -> None:
        """Invalid story ID format raises ValidationError."""
        with pytest.raises(ValidationError) as exc_info:
            await get_story("INVALID-001", stories_dir=sample_story_index)

        assert "Invalid story ID format" in str(exc_info.value)
        assert "Expected 'US-XXX'" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_list_stories_missing_index(self, tmp_path: Path) -> None:
        """Missing index.yaml raises FileNotFoundError."""
        empty_dir = tmp_path / "no-stories"
        empty_dir.mkdir()

        with pytest.raises(FileNotFoundError) as exc_info:
            await list_stories(stories_dir=empty_dir)

        assert "Index file not found" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_list_stories_malformed_yaml(self, tmp_path: Path) -> None:
        """Malformed YAML raises ParseError."""
        stories_dir = tmp_path / "bad-yaml"
        stories_dir.mkdir()
        (stories_dir / "index.yaml").write_text("invalid: yaml: [[[")

        with pytest.raises(ParseError) as exc_info:
            await list_stories(stories_dir=stories_dir)

        assert "Failed to parse YAML" in str(exc_info.value)

    # ============ PRD Tool Errors ============

    @pytest.mark.asyncio
    async def test_get_prd_empty_id(self, sample_prd: Path) -> None:
        """Empty PRD ID raises ValidationError."""
        with pytest.raises(ValidationError) as exc_info:
            await get_prd("", prds_dir=sample_prd)

        assert "Invalid PRD ID" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_get_prd_not_found(self, tmp_path: Path) -> None:
        """Non-existent PRD raises NotFoundError."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()

        with pytest.raises(NotFoundError) as exc_info:
            await get_prd("PRD-999", prds_dir=prd_dir)

        assert "PRD 'PRD-999' not found" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_get_fr_prd_not_found(self, tmp_path: Path) -> None:
        """FR for non-existent PRD raises NotFoundError."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()

        with pytest.raises(NotFoundError) as exc_info:
            await get_prd_functional_requirement("PRD-999", "FR-001", prds_dir=prd_dir)

        assert "PRD" in str(exc_info.value) and "not found" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_get_at_prd_not_found(self, tmp_path: Path) -> None:
        """AT for non-existent PRD raises NotFoundError."""
        prd_dir = tmp_path / "PRDs"
        prd_dir.mkdir()

        with pytest.raises(NotFoundError) as exc_info:
            await get_prd_acceptance_test("PRD-999", "AT-001", prds_dir=prd_dir)

        assert "PRD" in str(exc_info.value) and "not found" in str(exc_info.value)

    # ============ Update Tool Errors ============

    @pytest.mark.asyncio
    async def test_update_story_not_found(self, tmp_path: Path) -> None:
        """Update non-existent story raises NotFoundError."""
        stories_dir = tmp_path / "user-stories"
        stories_dir.mkdir()
        (stories_dir / "index.yaml").write_text("version: 2\nstories: []")

        with pytest.raises(NotFoundError) as exc_info:
            await update_story_metadata(
                "US-001", "status", "draft", stories_dir=stories_dir
            )

        assert "not found" in str(exc_info.value).lower()

    @pytest.mark.asyncio
    async def test_update_invalid_key(self, updatable_index: Path) -> None:
        """Update with invalid key raises ValidationError."""
        with pytest.raises(ValidationError) as exc_info:
            await update_story_metadata(
                "US-001", "invalid_key", "value", stories_dir=updatable_index
            )

        assert "Invalid metadata key" in str(exc_info.value)
        assert "Valid keys:" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_update_invalid_status_value(self, updatable_index: Path) -> None:
        """Update status with invalid value raises ValidationError."""
        with pytest.raises(ValidationError) as exc_info:
            await update_story_metadata(
                "US-001", "status", "invalid-status", stories_dir=updatable_index
            )

        assert "Invalid value" in str(exc_info.value)
        assert any(
            v in str(exc_info.value)
            for v in ["draft", "in-progress", "documented"]
        )

    # ============ Persona Tool Errors ============

    @pytest.mark.asyncio
    async def test_get_persona_not_found(self, tmp_path: Path) -> None:
        """Non-existent persona raises NotFoundError."""
        personas_dir = tmp_path / "personas"
        personas_dir.mkdir()
        (personas_dir / "index.yaml").write_text("version: 1\npersonas: []")

        with pytest.raises(NotFoundError) as exc_info:
            await get_persona("P-999", personas_dir=personas_dir)

        assert "Persona 'P-999' not found" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_get_persona_invalid_format(self, persona_index: Path) -> None:
        """Invalid persona ID format raises ValidationError."""
        with pytest.raises(ValidationError) as exc_info:
            await get_persona("INVALID-001", personas_dir=persona_index)

        assert "Invalid" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_list_personas_missing_index(self, tmp_path: Path) -> None:
        """Missing personas index raises FileNotFoundError."""
        empty_dir = tmp_path / "no-personas"
        empty_dir.mkdir()

        with pytest.raises(FileNotFoundError) as exc_info:
            await list_personas(personas_dir=empty_dir)

        assert "Index file not found" in str(exc_info.value)

    # ============ Error Message Quality ============

    @pytest.mark.asyncio
    async def test_error_includes_context(self, sample_story_index: Path) -> None:
        """Error messages include helpful context."""
        with pytest.raises(NotFoundError) as exc_info:
            await get_story("US-999", stories_dir=sample_story_index)

        error_msg = str(exc_info.value)
        # Should include the ID that wasn't found
        assert "US-999" in error_msg

    @pytest.mark.asyncio
    async def test_validation_error_includes_allowed_values(
        self, updatable_index: Path
    ) -> None:
        """Validation errors include allowed values."""
        with pytest.raises(ValidationError) as exc_info:
            await update_story_metadata(
                "US-001", "status", "bad-value", stories_dir=updatable_index
            )

        error_msg = str(exc_info.value)
        # Should list allowed values
        assert any(
            v in error_msg for v in ["draft", "in-progress", "documented"]
        )


# =============================================================================
# AT-010: Integration Tests
# =============================================================================

class TestIntegration:
    """End-to-end integration tests (AT-010)."""

    @pytest.mark.asyncio
    async def test_full_workflow_get_story_and_prd(
        self, full_project_structure: Path
    ) -> None:
        """Test getting story then navigating to PRD."""
        stories_dir = full_project_structure / "user-stories"
        prds_dir = full_project_structure / "PRDs"

        # 1. Get story
        story_result = await get_story("US-226", stories_dir=stories_dir)
        story = json.loads(story_result)

        assert story["id"] == "US-226"
        assert story["prd_group"] == "pm_mcp_tools"

        # 2. List stories in same PRD group
        list_result = await list_stories(
            prd_group="pm_mcp_tools", stories_dir=stories_dir
        )
        stories = json.loads(list_result)

        assert stories["total_count"] == 2

        # 3. Get PRD (assuming story has PRD reference)
        prd_result = await get_prd("PRD-017", prds_dir=prds_dir)
        prd = json.loads(prd_result)

        assert prd["id"] == "PRD-017"
        assert "US-226" in prd["user_stories"]

    @pytest.mark.asyncio
    async def test_full_workflow_prd_to_fr_to_at(
        self, full_project_structure: Path
    ) -> None:
        """Test navigating from PRD to FR to AT."""
        prds_dir = full_project_structure / "PRDs"

        # 1. Get PRD
        prd_result = await get_prd("PRD-017", prds_dir=prds_dir)
        prd = json.loads(prd_result)

        assert prd["has_functional_requirements"] is True
        assert prd["functional_requirements_count"] >= 1

        # 2. List FRs for PRD
        frs_result = await get_prd_functional_requirement(
            "PRD-017", "*", prds_dir=prds_dir
        )
        frs = json.loads(frs_result)

        assert frs["total_count"] >= 1
        fr_ids = [fr["fr_id"] for fr in frs["functional_requirements"]]
        assert "FR-001" in fr_ids

        # 3. Get specific FR
        fr_result = await get_prd_functional_requirement(
            "PRD-017", "FR-001", prds_dir=prds_dir
        )
        fr = json.loads(fr_result)

        assert fr["fr_id"] == "FR-001"

        # 4. Get ATs for that FR
        ats_result = await get_prd_acceptance_test(
            "PRD-017", "*", fr_id="FR-001", prds_dir=prds_dir
        )
        ats = json.loads(ats_result)

        assert ats["total_count"] >= 1

    @pytest.mark.asyncio
    async def test_update_and_verify_workflow(
        self, full_project_structure: Path
    ) -> None:
        """Test updating story metadata and verifying change."""
        stories_dir = full_project_structure / "user-stories"

        # 1. Get initial story state
        initial = await get_story("US-226", stories_dir=stories_dir)
        initial_data = json.loads(initial)

        assert initial_data["status"] == "draft"
        assert "PRD-017" not in initial_data.get("prds", [])

        # 2. Update status
        await update_story_metadata(
            "US-226", "status", "in-progress", stories_dir=stories_dir
        )

        # 3. Add PRD reference
        await update_story_metadata(
            "US-226", "prds", "PRD-017", stories_dir=stories_dir
        )

        # 4. Verify changes
        updated = await get_story("US-226", stories_dir=stories_dir)
        updated_data = json.loads(updated)

        assert updated_data["status"] == "in-progress"
        assert "PRD-017" in updated_data["prds"]

        # 5. Verify story appears in PRD-filtered list
        filtered = await list_stories(prd="PRD-017", stories_dir=stories_dir)
        filtered_data = json.loads(filtered)

        assert any(s["id"] == "US-226" for s in filtered_data["stories"])

    @pytest.mark.asyncio
    async def test_persona_to_stories_workflow(
        self, full_project_structure: Path
    ) -> None:
        """Test navigating from persona to related stories."""
        stories_dir = full_project_structure / "user-stories"
        personas_dir = full_project_structure / "personas"

        # 1. Get persona
        persona_result = await get_persona("P-008", personas_dir=personas_dir)
        persona = json.loads(persona_result)

        assert persona["id"] == "P-008"
        assert "US-226" in persona["related_stories"]

        # 2. List stories for this persona
        stories_result = await list_stories(persona="P-008", stories_dir=stories_dir)
        stories = json.loads(stories_result)

        assert stories["total_count"] >= 1
        assert any(s["id"] == "US-226" for s in stories["stories"])

        # 3. Get one of the related stories
        story_result = await get_story("US-226", stories_dir=stories_dir)
        story = json.loads(story_result)

        assert story["persona"] == "P-008"

    @pytest.mark.asyncio
    async def test_tdd_agent_workflow(self, full_project_structure: Path) -> None:
        """Simulate TDD agent workflow: find work -> get spec -> get tests."""
        stories_dir = full_project_structure / "user-stories"
        prds_dir = full_project_structure / "PRDs"

        # 1. TDD agent finds draft stories with critical priority
        stories_result = await list_stories(
            status="draft", priority="critical", stories_dir=stories_dir
        )
        stories = json.loads(stories_result)

        assert stories["total_count"] >= 1
        target_story = stories["stories"][0]

        # 2. Get full story details
        story_result = await get_story(target_story["id"], stories_dir=stories_dir)
        story = json.loads(story_result)

        assert "acceptance_criteria" in story

        # 3. Find PRD for this story's group
        prd_result = await get_prd("PRD-017", prds_dir=prds_dir)
        prd = json.loads(prd_result)

        # 4. Get acceptance tests to implement
        ats_result = await get_prd_acceptance_test("PRD-017", "*", prds_dir=prds_dir)
        ats = json.loads(ats_result)

        # 5. Update story status to in-progress
        await update_story_metadata(
            target_story["id"], "status", "in-progress", stories_dir=stories_dir
        )

        # Verify update
        updated = await get_story(target_story["id"], stories_dir=stories_dir)
        updated_data = json.loads(updated)
        assert updated_data["status"] == "in-progress"


# =============================================================================
# Performance Tests (NFR)
# =============================================================================

class TestPerformance:
    """Performance tests for NFR compliance."""

    @pytest.mark.asyncio
    async def test_index_parse_performance(self, multi_story_index: Path) -> None:
        """Index YAML parse time < 50ms (NFR-3)."""
        import time

        start = time.perf_counter()
        await list_stories(stories_dir=multi_story_index)
        elapsed = (time.perf_counter() - start) * 1000

        # Allow up to 50ms for index parsing
        assert elapsed < 50, f"Index parse took {elapsed:.2f}ms, expected < 50ms"

    @pytest.mark.asyncio
    async def test_single_item_retrieval_performance(
        self, sample_story_file: Path
    ) -> None:
        """Single item retrieval < 100ms (NFR-4)."""
        import time

        start = time.perf_counter()
        await get_story("US-001", stories_dir=sample_story_file)
        elapsed = (time.perf_counter() - start) * 1000

        # Allow up to 100ms for single item retrieval
        assert elapsed < 100, f"Retrieval took {elapsed:.2f}ms, expected < 100ms"

    @pytest.mark.asyncio
    async def test_list_operation_performance(self, multi_story_index: Path) -> None:
        """List operation < 200ms (NFR-5)."""
        import time

        start = time.perf_counter()
        await list_stories(stories_dir=multi_story_index)
        elapsed = (time.perf_counter() - start) * 1000

        # Allow up to 200ms for list operations
        assert elapsed < 200, f"List took {elapsed:.2f}ms, expected < 200ms"
