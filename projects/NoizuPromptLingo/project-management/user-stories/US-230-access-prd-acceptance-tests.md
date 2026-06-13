# User Story: Access PRD Acceptance Tests

**ID**: US-230
**Persona**: P-008 (TDD Workflow Agent), P-001 (AI Agent)
**PRD Group**: pm_mcp_tools
**Priority**: Critical
**Status**: Draft
**Created**: 2026-02-02T18:00:00Z

## Story

As a **TDD workflow agent**,
I want to **access specific acceptance tests from a PRD by PRD ID and AT ID**,
So that **I can generate test implementations that directly verify the acceptance criteria defined in the specification**.

## Acceptance Criteria

- [ ] `get_prd_acceptance_test(prd_id: str, at_id: str)` tool accepts PRD and AT IDs
- [ ] Tool returns the full markdown content of the acceptance test file
- [ ] Tool returns AT metadata (id, title, status, test_type)
- [ ] Tool returns the functional requirement this AT verifies
- [ ] Tool returns preconditions, steps, and expected results as structured data
- [ ] Tool supports listing all ATs for a PRD when `at_id` is omitted or set to "*"
- [ ] Tool supports listing all ATs for a specific FR with `fr_id` parameter
- [ ] Tool returns 404-style error if PRD or AT does not exist
- [ ] AT IDs follow format "AT-XXX-YYY" (FR number + test number)

## Technical Details

### Input Schema (Single AT)
```json
{
  "prd_id": "PRD-005",
  "at_id": "AT-003-001"
}
```

### Input Schema (All ATs for PRD)
```json
{
  "prd_id": "PRD-005",
  "at_id": "*"
}
```

### Input Schema (All ATs for FR)
```json
{
  "prd_id": "PRD-005",
  "fr_id": "FR-003",
  "at_id": "*"
}
```

### Output Schema (Single AT)
```json
{
  "prd_id": "PRD-005",
  "at_id": "AT-003-001",
  "title": "Task transitions from pending to in_progress",
  "file": "AT-003-001-pending-to-in-progress.md",
  "fr_id": "FR-003",
  "status": "documented",
  "test_type": "integration",
  "content": "# AT-003-001: Task transitions from pending to in_progress\n...",
  "preconditions": [
    "Task queue exists",
    "Task exists with status 'pending'"
  ],
  "steps": [
    "Call update_task_status with status='in_progress'",
    "Verify task status is updated",
    "Verify task_event is created"
  ],
  "expected_results": [
    "Task status is 'in_progress'",
    "task_events table contains status change event",
    "Timestamp is recorded"
  ],
  "implementation_status": "not_implemented"
}
```

### Output Schema (List All ATs)
```json
{
  "prd_id": "PRD-005",
  "acceptance_tests": [
    {
      "at_id": "AT-001-001",
      "title": "Create empty task queue",
      "fr_id": "FR-001",
      "status": "documented",
      "test_type": "unit",
      "implementation_status": "implemented"
    },
    {
      "at_id": "AT-003-001",
      "title": "Task transitions from pending to in_progress",
      "fr_id": "FR-003",
      "status": "documented",
      "test_type": "integration",
      "implementation_status": "not_implemented"
    }
  ],
  "total_count": 8,
  "implemented_count": 3,
  "coverage_percentage": 37.5
}
```

### File Locations
- AT directory: `project-management/PRDs/PRD-XXX-name/acceptance-tests/`
- AT files: `AT-XXX-YYY-title.md`
- AT index: `project-management/PRDs/PRD-XXX-name/acceptance-tests/index.yaml` (if exists)

## Notes

- Acceptance tests are the primary input for TDD-tester to generate test code
- AT structure should map directly to test function structure (preconditions -> fixtures, steps -> test body)
- Implementation status tracking enables coverage reporting

## Dependencies

- PRD must exist and have an acceptance-tests directory
- AT files should follow naming convention `AT-XXX-YYY-*.md`
- Structured AT format (preconditions, steps, expected results) must be parseable

## Open Questions

- Should we support linking ATs to actual test file locations (e.g., `tests/test_task_queue.py::test_pending_to_in_progress`)?
- Should implementation status be tracked in AT files or a separate index?
- How do we handle ATs that span multiple FRs?

## Related Tools

- `get_prd` - Read PRD overview (US-228)
- `get_prd_functional_requirement` - Read FRs (US-229)
- `get_story` - Read linked user stories (US-226)
