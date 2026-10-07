# Review: Research and Track Keywords

- **Story**: `project-management/user-stories/US-035-research-and-track-keywords.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented on the Elixir backend as a Market domain. `Keyword.Research` LLM-generates candidates (term/intent/volume/difficulty/cpc) for a topic and bulk-inserts them org/project-scoped (`backend/lib/noizu_prompt_lingua/domains/market/tools/keyword_research.ex:6-56`; `Market.research_keywords`, `backend/lib/noizu_prompt_lingua/domains/market/market.ex:58`). `Keyword.Create/Get/List/Update` cover manual add, viewing, and editing; the schema enforces term uniqueness within org/project scope (`backend/lib/noizu_prompt_lingua/schema/keyword.ex:46-48`). Gaps: research auto-inserts everything it generates (no operator selection step), and there is no delete/remove path, so keywords cannot be removed from the tracked list.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Trigger keyword research from seed topic → candidate list, with ability to select which to save | Partially Met | research works but inserts all candidates automatically (`keyword_research.ex:34-46`; `market.ex:58-72` insert_researched_keyword per item); no selection step; `Keyword.Create` allows manual adds (`keyword_create.ex`) |
| Tracked keyword list visible per campaign with add/remove controls | Partially Met | `Keyword.List` filters by organization/project (`keyword_list.ex`); no campaign-scoped keyword view; no delete tool (only create/get/list/research/update exist in `backend/lib/noizu_prompt_lingua/domains/market/tools/`) |
| Duplicate keyword not re-added | Met | unique constraints on `(organization_id, term)` and `(organization_id, project_id, term)` reject duplicates at DB level (`schema/keyword.ex:46-48`) |

## Gaps / Risks

- Keywords scope to org/project, not campaign — "reuse across ad copy for a campaign" relies on convention, not data linkage.
- Without a delete/archive path, bad LLM-generated keyword suggestions accumulate permanently; unique constraints only prevent exact re-adds, and re-running research for the same topic will surface `{:error, changeset}` noise per duplicate insert.

## BDD Scenario

```gherkin
Feature: Research and Track Keywords

  Scenario: Research a seed topic
    Given a growth operator in an organization
    When they call Keyword.Research with topic "prompt engineering"
    Then LLM-generated keywords with term/intent/volume/difficulty are persisted
    And Keyword.List returns the tracked keywords for the org/project

  Scenario: Duplicate protection
    Given the keyword "npl" is already tracked for the project
    When Keyword.Create is called again with term "npl" for the same scope
    Then the unique constraint rejects the insert and no duplicate row exists

  Scenario: Remove a tracked keyword (not available)
    Given a keyword the operator no longer wants tracked
    When they attempt to remove it from the campaign's keyword list
    Then no delete or archive operation exists to perform the removal
```
