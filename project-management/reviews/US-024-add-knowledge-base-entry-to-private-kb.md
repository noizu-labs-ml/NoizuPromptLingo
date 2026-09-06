# Review: Add Knowledge Base Entry to Private KB

- **Story**: `project-management/user-stories/US-024-add-knowledge-base-entry-to-private-kb.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Persona knowledge bases are implemented in the Elixir backend: `knowledge_add.ex` (`backend/lib/noizu_prompt_lingua/domains/personas/knowledge_add.ex`) creates entries with a slug **unique per persona KB** and tags; `personas.ex` provides persona-scoped listing with tag filtering (`list_knowledge`, `backend/lib/noizu_prompt_lingua/domains/personas/personas.ex:139`) and update support. However, privacy scoping has a hole: **UUID-based direct lookup bypasses persona scoping** — `get_knowledge` fetches any entry by UUID without verifying it belongs to the requesting persona (`personas.ex:128-137`), so an agent that learns/guesses a UUID can read another persona's "private" KB entry. Confidence: high (read directly).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Agent can add an entry (title/body/tags) to its own KB | Met | `knowledge_add.ex` (slug + tags supported) |
| Slug unique within the persona's KB | Met | slug uniqueness enforced per persona (`knowledge_add.ex`) |
| Agent can update its own entries | Met | update path in `personas.ex` |
| KB entries are private to the owning persona | Partially Met | listing is persona-scoped with tag filter (`personas.ex:139`), but UUID lookup bypasses scoping (`personas.ex:128-137`) |
| Tag-based filtering on retrieval | Met | `personas.ex:139` |

## Gaps / Risks

- Privacy gap: UUID enumeration/leak = cross-persona KB read. Fix: verify `entry.persona_id == requesting persona` inside `get_knowledge` (or route through a scoped fetch like the journal's).
- No delete restriction noted; confirm deletion is intended.

## BDD Scenario

```gherkin
Feature: Private persona knowledge base
  Scenario: Agent stores and retrieves its own notes
    Given a registered persona with a private KB
    When it adds an entry with slug and tags
    Then the entry is stored uniquely within its KB
    And it can list/filter its entries by tag
  Scenario: Cross-persona read
    When another persona fetches the entry by UUID
    Then the story expects denial
    But today the lookup succeeds, exposing the private entry
```
