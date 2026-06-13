# User Story: List and Filter User Stories

**ID**: US-227
**Persona**: P-008 (TDD Workflow Agent), P-001 (AI Agent)
**PRD Group**: pm_mcp_tools
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T18:00:00Z

## Story

As a **TDD workflow agent**,
I want to **list user stories with optional filtering by status, priority, persona, or PRD group**,
So that **I can discover relevant stories for my current task and track implementation progress across the project**.

## Acceptance Criteria

- [ ] `list_stories()` tool returns all stories from index.yaml when called with no filters
- [ ] Tool supports `status` filter (draft, in-progress, documented, implemented, tested)
- [ ] Tool supports `priority` filter (critical, high, medium, low)
- [ ] Tool supports `persona` filter by persona ID (e.g., "P-001")
- [ ] Tool supports `prd_group` filter (e.g., "mcp_tools", "npl_load")
- [ ] Tool supports `prd` filter to find stories linked to a specific PRD (e.g., "PRD-005")
- [ ] Tool returns summary data for each story (id, title, status, priority, persona)
- [ ] Tool supports pagination with `limit` and `offset` parameters
- [ ] Results are sorted by priority (critical first) then by ID

## Technical Details

### Input Schema
```json
{
  "status": "draft",
  "priority": "high",
  "persona": "P-001",
  "prd_group": "mcp_tools",
  "prd": "PRD-010",
  "limit": 50,
  "offset": 0
}
```

### Output Schema
```json
{
  "total_count": 120,
  "returned_count": 50,
  "offset": 0,
  "stories": [
    {
      "id": "US-226",
      "title": "Read User Story by ID",
      "status": "draft",
      "priority": "critical",
      "persona": "P-008",
      "persona_name": "TDD Workflow Agent",
      "prd_group": "pm_mcp_tools",
      "prds": ["PRD-011"]
    }
  ]
}
```

### File Locations
- Index file: `project-management/user-stories/index.yaml`

## Notes

- Filtering should be combinable (AND logic) - e.g., status=draft AND priority=high
- This tool is essential for agents to understand project scope and find relevant work
- Should be efficient even with 200+ stories in the index

## Dependencies

- `project-management/user-stories/index.yaml` must exist and be valid YAML
- Index schema must include all filterable fields

## Open Questions

- Should we support full-text search in story titles?
- Should we support "OR" logic for filters (e.g., priority in [high, critical])?
- Should we include a "has_tests" filter for implementation tracking?

## Related Tools

- `get_story` - Read full story content (US-226)
- `list_prds` - List PRDs with filtering (US-228)
