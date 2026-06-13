# User Story: Read PRD Content by ID

**ID**: US-228
**Persona**: P-008 (TDD Workflow Agent), P-001 (AI Agent)
**PRD Group**: pm_mcp_tools
**Priority**: Critical
**Status**: Draft
**Created**: 2026-02-02T18:00:00Z

## Story

As a **TDD workflow agent**,
I want to **read the full content of a PRD document by its ID** (e.g., "PRD-005"),
So that **I can understand the feature requirements, scope, and acceptance criteria needed to generate comprehensive tests**.

## Acceptance Criteria

- [ ] `get_prd(prd_id: str)` tool accepts a PRD ID in format "PRD-XXX"
- [ ] Tool returns the full markdown content of the main PRD file
- [ ] Tool returns structured metadata from index.yaml (title, status, version, categories)
- [ ] Tool returns list of associated user stories
- [ ] Tool returns list of MCP tools defined in the PRD
- [ ] Tool returns list of database tables and web routes
- [ ] Tool returns paths to functional requirements and acceptance test directories
- [ ] Tool returns 404-style error if PRD ID does not exist
- [ ] Tool handles both numeric IDs ("005") and prefixed IDs ("PRD-005")

## Technical Details

### Input Schema
```json
{
  "prd_id": "PRD-005"
}
```

### Output Schema
```json
{
  "id": "PRD-005",
  "title": "Task Queue System",
  "file": "PRD-005-task-queue-system.md",
  "status": "documented",
  "version": "1.0",
  "categories": ["C-06"],
  "tools": ["create_task_queue", "get_task", "list_tasks"],
  "user_stories": ["US-020", "US-021", "US-022"],
  "personas": ["P-001", "P-003", "P-004", "P-005"],
  "database_tables": ["task_queues", "tasks", "task_events"],
  "web_routes": ["GET /tasks", "GET /api/task/{task_id}"],
  "test_coverage": "0%",
  "content": "# PRD-005: Task Queue System\n...",
  "supporting_directory": "project-management/PRDs/PRD-005-task-queue-system/",
  "has_functional_requirements": true,
  "has_acceptance_tests": true,
  "functional_requirements_count": 12,
  "acceptance_tests_count": 8
}
```

### File Locations
- PRD files: `project-management/PRDs/PRD-XXX-name.md`
- PRD index: `project-management/PRDs/index.yaml`
- Supporting directory: `project-management/PRDs/PRD-XXX-name/`
- Functional requirements: `project-management/PRDs/PRD-XXX-name/functional-requirements/`
- Acceptance tests: `project-management/PRDs/PRD-XXX-name/acceptance-tests/`

## Notes

- PRDs are the primary specification documents for TDD agents
- The supporting directory structure may or may not exist for each PRD
- This tool should provide enough metadata to navigate to FRs and ATs without reading them all

## Dependencies

- `project-management/PRDs/index.yaml` must exist and be valid YAML
- PRD markdown files must follow the established template format

## Open Questions

- Should the tool parse and return structured sections from the PRD markdown?
- Should we include test coverage data from the index?
- Should we return a list of FR/AT IDs or just counts?

## Related Tools

- `list_prds` - List PRDs with filtering
- `get_prd_functional_requirement` - Read specific FR (US-229)
- `get_prd_acceptance_test` - Read specific AT (US-230)
