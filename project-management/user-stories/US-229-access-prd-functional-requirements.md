# User Story: Access PRD Functional Requirements

**ID**: US-229
**Persona**: P-008 (TDD Workflow Agent), P-001 (AI Agent)
**PRD Group**: pm_mcp_tools
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T18:00:00Z

## Story

As a **TDD workflow agent**,
I want to **access specific functional requirements from a PRD by PRD ID and FR ID**,
So that **I can understand the detailed implementation requirements for generating targeted tests or code**.

## Acceptance Criteria

- [ ] `get_prd_functional_requirement(prd_id: str, fr_id: str)` tool accepts PRD and FR IDs
- [ ] Tool returns the full markdown content of the functional requirement file
- [ ] Tool returns FR metadata (id, title, status, priority)
- [ ] Tool returns related acceptance test IDs
- [ ] Tool returns dependency information (depends_on, blocks)
- [ ] Tool supports listing all FRs for a PRD when `fr_id` is omitted or set to "*"
- [ ] Tool returns 404-style error if PRD or FR does not exist
- [ ] FR IDs follow format "FR-001", "FR-002", etc.

## Technical Details

### Input Schema (Single FR)
```json
{
  "prd_id": "PRD-005",
  "fr_id": "FR-003"
}
```

### Input Schema (List All FRs)
```json
{
  "prd_id": "PRD-005",
  "fr_id": "*"
}
```

### Output Schema (Single FR)
```json
{
  "prd_id": "PRD-005",
  "fr_id": "FR-003",
  "title": "Task Status Transitions",
  "file": "FR-003-task-status-transitions.md",
  "status": "documented",
  "priority": "high",
  "content": "# FR-003: Task Status Transitions\n...",
  "acceptance_tests": ["AT-003-001", "AT-003-002", "AT-003-003"],
  "depends_on": ["FR-001", "FR-002"],
  "blocks": ["FR-005"]
}
```

### Output Schema (List All FRs)
```json
{
  "prd_id": "PRD-005",
  "functional_requirements": [
    {
      "fr_id": "FR-001",
      "title": "Create Task Queue",
      "status": "documented",
      "priority": "critical",
      "acceptance_test_count": 4
    },
    {
      "fr_id": "FR-002",
      "title": "Add Task to Queue",
      "status": "documented",
      "priority": "high",
      "acceptance_test_count": 3
    }
  ],
  "total_count": 12
}
```

### File Locations
- FR directory: `project-management/PRDs/PRD-XXX-name/functional-requirements/`
- FR files: `FR-XXX-title.md`
- FR index: `project-management/PRDs/PRD-XXX-name/functional-requirements/index.yaml` (if exists)

## Notes

- Functional requirements are the bridge between PRD overview and acceptance tests
- TDD-tester uses FRs to understand what specific behaviors need test coverage
- Not all PRDs have a functional-requirements directory; tool should handle gracefully

## Dependencies

- PRD must exist and have a supporting directory structure
- FR files should follow naming convention `FR-XXX-*.md`

## Open Questions

- Should FRs without a formal index.yaml derive metadata from file content?
- Should we support querying FRs by status or priority?
- How should we handle PRDs that embed FRs in the main document vs separate files?

## Related Tools

- `get_prd` - Read PRD overview (US-228)
- `get_prd_acceptance_test` - Read acceptance tests (US-230)
- `get_story` - Read linked user stories (US-226)
