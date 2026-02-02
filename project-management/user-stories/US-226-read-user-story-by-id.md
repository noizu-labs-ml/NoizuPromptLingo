# User Story: Read User Story by ID

**ID**: US-226
**Persona**: P-008 (TDD Workflow Agent), P-001 (AI Agent)
**PRD Group**: pm_mcp_tools
**Priority**: Critical
**Status**: Draft
**Created**: 2026-02-02T18:00:00Z

## Story

As a **TDD workflow agent**,
I want to **read the full content of a user story by its ID** (e.g., "US-001"),
So that **I can understand the requirements, acceptance criteria, and context needed to generate tests or implement code**.

## Acceptance Criteria

- [ ] `get_story(story_id: str)` tool accepts a story ID in format "US-XXX"
- [ ] Tool returns the full markdown content of the story file
- [ ] Tool returns structured metadata (id, title, persona, priority, status, prd_group)
- [ ] Tool returns parsed acceptance criteria as a list of items with completion status
- [ ] Tool returns related stories and related personas from index.yaml
- [ ] Tool returns 404-style error if story ID does not exist
- [ ] Tool handles both numeric IDs ("226") and prefixed IDs ("US-226")

## Technical Details

### Input Schema
```json
{
  "story_id": "US-001"
}
```

### Output Schema
```json
{
  "id": "US-001",
  "title": "Load NPL Core Components",
  "file": "US-001-load-npl-core.md",
  "persona": "P-001",
  "persona_name": "AI Agent",
  "priority": "critical",
  "status": "draft",
  "prd_group": "npl_load",
  "prds": ["PRD-008", "PRD-014"],
  "related_stories": ["US-002"],
  "related_personas": ["P-001"],
  "content": "# User Story: Load NPL Core Components\n...",
  "acceptance_criteria": [
    {"text": "`npl_load` tool successfully loads core NPL syntax definitions", "completed": false},
    {"text": "`npl_load` tool successfully loads agent communication protocols", "completed": false}
  ]
}
```

### File Locations
- Story files: `project-management/user-stories/US-XXX-*.md`
- Index file: `project-management/user-stories/index.yaml`

## Notes

- Story content should be returned both as raw markdown and as structured data where possible
- Acceptance criteria parsing should handle both `- [ ]` and `- [x]` formats
- This is a foundational tool for the TDD pipeline - tdd-tester uses it to understand what to test

## Dependencies

- `project-management/user-stories/index.yaml` must exist and be valid YAML
- Story markdown files must follow the established template format

## Open Questions

- Should the tool also return the full dependency graph (blocked_by, blocks)?
- Should acceptance criteria completion be synced from the markdown file or index.yaml?

## Related Tools

- `list_stories` - List and filter stories (US-227)
- `edit_story` - Modify story content (future enhancement)
- `update_story_metadata` - Update index.yaml fields (US-231)
