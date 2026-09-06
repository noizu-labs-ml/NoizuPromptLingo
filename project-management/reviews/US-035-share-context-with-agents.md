# Review: Share Architectural Context with Agents

- **Story**: `project-management/user-stories/US-035-share-context-with-agents.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The primitive building blocks all exist: versioned artifacts with revisions and notes in the Python MCP server (`src/npl_mcp/artifacts/artifacts.py:82-356`), a versioned instructions store agents can search and load (`src/npl_mcp/instructions/instructions.py:51-505`, including intent/embedding search and active-version resolution), and NPL convention loading via `NPLLoad`/`npl_load`. Agents can therefore store, version, discover, and load markdown/yaml context today. But the story's specific machinery is absent: there is no `list_context_artifacts(scope, category, applies_to)` discovery tool, no scope/category metadata vocabulary (project/module/task precedence), no convention that agents log "Loaded context: …" to work logs (no work-log system exists), and no usage tracking or effectiveness reporting.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Create context artifacts via `create_artifact` (markdown/yaml) | Met | `src/npl_mcp/artifacts/artifacts.py:82`; type is caller-supplied |
| Metadata tags scope/category | Not Met | artifact metadata is free-form; no scope/category validation or semantics anywhere |
| Context linked to tasks/modules/sessions for scoping | Partially Met | generic artifact linking exists (`link_artifact_to_task` per story's own cross-refs; see artifacts module), but no glob `applies_to` module scoping |
| Standard sections (Purpose/Standards/Patterns/Anti-patterns/Examples) | Not Met | content is free text; no structure enforcement (acceptable as convention, but no evidence of the convention in tooling) |
| Discover via `list_context_artifacts(scope?, category?)` | Not Met | no such tool; closest is instructions text/intent search (`src/npl_mcp/instructions/instructions.py:398-505`) |
| Load via `get_artifact` | Met | `src/npl_mcp/artifacts/artifacts.py:238` |
| Agents log "Loaded context: …" in work logs | Not Met | no work-log system in either codebase (US-031 dependency also unimplemented) |
| Precedence: task > module > project | Not Met | no hierarchy/merge logic found |
| Update via new revision with changelog notes | Met | `artifact_add_revision` accepts notes (`src/npl_mcp/artifacts/artifacts.py:156`); Elixir instructions also version (`instructions.py:191-350`) |
| Latest revision used unless pinned | Partially Met | artifact_get supports revision selection; no pinning semantics |
| Track which artifacts loaded per task | Not Met | no evidence found |
| Review comments reference context violations ("Violates {artifact}#{section}") | Not Met | no evidence found (review comments are free text: `src/npl_mcp/artifacts/reviews.py:73-100`) |
| Context effectiveness report | Not Met | no evidence found |

## Gaps / Risks

- The story depends on US-031 work logs for the "acknowledge loaded context" loop; that dependency is itself unimplemented, blocking the effectiveness-tracking half.
- Without structured scope metadata, context discovery remains manual — agents need to know artifact IDs a priori.

## BDD Scenario

```gherkin
Feature: Share Architectural Context with Agents

  Scenario: Store and load a coding standard (works today)
    Given a developer creates an artifact "coding-standards" of type markdown
    And adds a revision with changelog notes
    When an agent calls get_artifact for its latest revision
    Then the agent receives the standards content including revision notes

  Scenario: Scoped discovery and precedence (not available)
    Given context artifacts exist at project, module, and task scope
    When an agent starts a task and asks for applicable context
    Then no list_context_artifacts tool exists
    And no merge logic applies task > module > project precedence
```
