# Review: Register New Agent Persona with Bio

- **Story**: `project-management/user-stories/US-022-register-new-agent-persona-with-bio.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Persona registration exists in the Elixir backend at `backend/lib/noizu_prompt_lingua/domains/personas/persona_create.ex`, requiring organization, slug, and name. However, **`bio` is optional** in the create changeset, whereas the story requires registration to be *rejected* when bio is omitted. The persona domain (`backend/lib/noizu_prompt_lingua/domains/personas/personas.ex`) supports the surrounding lifecycle (list, update, delete). A corresponding registration tool also exists in the memory-tool surface (`backend/lib/noizu_prompt_lingua/domains/memory/tools/agent_register.ex`). No matching persona-registration MCP tool exists on the Python side (`src/npl_mcp/`). Confidence: high (changeset read directly).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Agent can register a persona with name + bio | Met | `persona_create.ex` accepts name + bio |
| Missing bio is rejected with a clear error | Not Met | bio is optional in `persona_create.ex` changeset — no validation error |
| Slug/org scoping enforced (unique per org) | Met | slug required and unique within organization (`persona_create.ex`) |
| Registered persona usable in sessions/rooms | Met | persona domain integrated with chat/session surfaces (`personas.ex`) |

## Gaps / Risks

- Simplest gap in the story: add a required-bio validation to the create changeset (or an explicit `bio` requirement in the MCP-facing tool wrapper).
- No Python-side MCP registration tool — Python-resident agents must go through the backend API.

## BDD Scenario

```gherkin
Feature: Register an agent persona
  Scenario: Register with bio
    Given an authenticated agent in an organization
    When it registers a persona with name, slug, and bio
    Then the persona is created and scoped to that org
  Scenario: Register without bio
    When it registers a persona omitting bio
    Then the story expects rejection with a clear error
    But today the persona is created with a nil bio
```
