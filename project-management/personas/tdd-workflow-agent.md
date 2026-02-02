# Persona: TDD Workflow Agent

**ID**: P-008
**Created**: 2026-02-02T18:00:00Z
**Updated**: 2026-02-02T18:00:00Z

## Demographics

- **Role**: Specialized TDD pipeline agent (LLM-powered)
- **Tech Savvy**: Expert (programmatic API consumer, test-driven development specialist)
- **Primary Interface**: MCP tools via orchestration controller

## Context

TDD Workflow Agents are specialized AI agents that operate within the test-driven development pipeline. This persona represents the collective needs of npl-tdd-tester, npl-tdd-coder, and npl-tdd-debugger agents that require programmatic access to project management artifacts (PRDs, user stories, acceptance tests, functional requirements) to perform their specialized roles.

Unlike general-purpose AI agents (P-001), TDD Workflow Agents have specific needs around accessing structured specification data to generate tests, implement code, and diagnose failures. They need to read PRDs to understand requirements, access acceptance tests to verify completeness, and reference user stories to maintain traceability.

## Goals

1. Access PRD documents programmatically to understand feature requirements
2. Read specific functional requirements and acceptance tests from PRDs
3. Query user stories to maintain test-to-requirement traceability
4. Access persona definitions to understand user context for test scenarios
5. Update story metadata to reflect implementation progress
6. Navigate the specification hierarchy efficiently (PRD -> FR -> AT)

## Pain Points

1. PRDs are stored as markdown files, requiring parsing to extract structured data
2. Functional requirements and acceptance tests are in subdirectories, not easily discoverable
3. No programmatic way to list all acceptance tests for a given PRD
4. Cannot update story status or metadata without manual file editing
5. Cross-references between stories, PRDs, and personas require manual lookups
6. Index files use YAML, but agents often work with JSON APIs

## Behaviors

- Queries PRD index to find relevant specifications before starting work
- Reads specific functional requirements to understand implementation scope
- Accesses acceptance tests to generate corresponding test cases
- Updates story metadata when implementation milestones are reached
- Maintains traceability links between tests and requirements
- Uses filtering to find stories by status, priority, or persona

## Quotes

> "I need to read PRD-005 functional requirement FR-003 to understand the exact acceptance criteria."

> "Before generating tests, I need to list all acceptance tests in this PRD to avoid duplication."

> "The user story says 'draft' but I've implemented it - I need to update the status to 'in-progress'."

## Key MCP Tool Usage

| Category | Primary Tools |
|----------|---------------|
| PRD Access | `get_prd`, `list_prds`, `get_prd_functional_requirement`, `get_prd_acceptance_test` |
| Story Access | `get_story`, `list_stories`, `edit_story`, `update_story_metadata` |
| Persona Access | `get_persona`, `list_personas` |
| Cross-Reference | Story-to-PRD mapping, PRD-to-persona mapping |

## Related Personas

- **AI Agent (P-001)**: General-purpose agent; TDD agents are specialized variants
- **Control Agent (P-006)**: Orchestrates TDD workflow, dispatches to TDD agents
- **Dave the Fellow Developer (P-005)**: Reviews TDD agent outputs

## TDD Pipeline Role

```
Controller
    |
    v
+-------------------+     +-------------------+     +-------------------+
| npl-tdd-tester    | --> | npl-tdd-coder     | --> | npl-tdd-debugger  |
| (reads PRDs,      |     | (reads PRDs,      |     | (reads PRDs,      |
|  generates tests) |     |  implements code) |     |  diagnoses issues)|
+-------------------+     +-------------------+     +-------------------+
         |                         |                         |
         v                         v                         v
   [Project Management MCP Tools - Read PRDs, stories, update status]
```

## Related Stories

- US-226: Read User Story by ID
- US-227: List and Filter User Stories
- US-228: Read PRD Content by ID
- US-229: Access PRD Functional Requirements
- US-230: Access PRD Acceptance Tests
- US-231: Update User Story Metadata
- US-232: List and Access Personas
