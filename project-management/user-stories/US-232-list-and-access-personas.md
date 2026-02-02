# User Story: List and Access Personas

**ID**: US-232
**Persona**: P-008 (TDD Workflow Agent), P-001 (AI Agent)
**PRD Group**: pm_mcp_tools
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T18:00:00Z

## Story

As a **TDD workflow agent**,
I want to **list all personas and read individual persona definitions**,
So that **I can understand the user context when generating tests and ensure test scenarios align with user goals and behaviors**.

## Acceptance Criteria

- [ ] `list_personas()` tool returns all personas from personas/index.yaml
- [ ] Tool returns summary data (id, name, file, tags, related_stories)
- [ ] Tool supports filtering by `tags` (e.g., "autonomous", "developer")
- [ ] Tool supports filtering by `category` (Core personas vs Agents)
- [ ] `get_persona(persona_id: str)` tool reads full persona markdown file
- [ ] Tool returns structured persona data (demographics, goals, pain points, behaviors)
- [ ] Tool returns related stories from the index
- [ ] Tool handles both P-XXX (personas) and A-XXX (agents) ID formats
- [ ] Tool returns 404-style error if persona ID does not exist

## Technical Details

### Input Schema (List)
```json
{
  "tags": ["autonomous"],
  "category": "Core"
}
```

### Input Schema (Get Single)
```json
{
  "persona_id": "P-001"
}
```

### Output Schema (List)
```json
{
  "personas": [
    {
      "id": "P-001",
      "name": "AI Agent",
      "file": "ai-agent.md",
      "tags": ["autonomous", "programmatic", "automation"],
      "related_stories_count": 12,
      "category": "Core Persona"
    },
    {
      "id": "A-001",
      "name": "Gopher Scout",
      "file": "agents/gopher-scout.md",
      "tags": ["discovery", "research", "evidence-backed"],
      "category": "Core Agent"
    }
  ],
  "total_count": 46,
  "core_personas": 7,
  "core_agents": 16,
  "additional_agents": 23
}
```

### Output Schema (Get Single)
```json
{
  "id": "P-001",
  "name": "AI Agent",
  "file": "ai-agent.md",
  "category": "Core Persona",
  "content": "# Persona: AI Agent\n...",
  "demographics": {
    "role": "Autonomous AI agent (LLM-powered)",
    "tech_savvy": "Expert",
    "primary_interface": "MCP tools via Python client or SSE endpoint"
  },
  "goals": [
    "Execute assigned tasks efficiently with minimal human intervention",
    "Maintain clear audit trails of all actions taken"
  ],
  "pain_points": [
    "Ambiguous task specifications that require human clarification",
    "Lack of structured context when starting tasks"
  ],
  "behaviors": [
    "Loads NPL context before starting significant work",
    "Polls task queues for assigned work in priority order"
  ],
  "related_stories": ["US-001", "US-002", "US-008"],
  "related_personas": ["P-006", "P-007"],
  "tags": ["autonomous", "programmatic", "automation"]
}
```

### File Locations
- Personas index: `project-management/personas/index.yaml`
- Core persona files: `project-management/personas/*.md`
- Core agent files: `project-management/personas/agents/*.md`
- Additional agents: `project-management/personas/additional-agents/*/*.md`

## Notes

- Personas provide context for test scenario generation (what would this user try to do?)
- Understanding pain points helps identify edge cases to test
- Related stories help maintain traceability

## Dependencies

- `project-management/personas/index.yaml` must exist and be valid YAML
- Persona markdown files must follow established template format

## Open Questions

- Should we parse and return the "Quotes" section for test scenario inspiration?
- Should we support searching personas by related_stories?
- Should agent personas (A-XXX) be returned by default or require explicit filtering?

## Related Tools

- `get_story` - Read stories that reference this persona (US-226)
- `list_stories` - Filter stories by persona (US-227)
- `get_prd` - Read PRDs that reference this persona (US-228)
