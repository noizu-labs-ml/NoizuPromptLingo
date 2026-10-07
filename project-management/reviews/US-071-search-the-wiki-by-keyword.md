# Review: Search the Wiki by Keyword

- **Story**: `project-management/user-stories/US-071-search-the-wiki-by-keyword.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend exposes keyword search only as an optional `search` parameter on `Wiki.SpaceList` and `Wiki.PageList` (MCP tools), implemented via `ilike` substring match over `name/slug` (spaces) and `title/slug` (pages) in `Domains.Wiki.maybe_search/3` (Elixir backend `lib/noizu_prompt_lingua/domains/wiki/wiki.ex:280-283`). There is no dedicated cross-space keyword search tool, no search over page *body* content, and no relevance ranking (results are ordered by position/title). Project scoping is indirect: spaces can be filtered by `project_id`, and pages are always listed within a single space, so cross-project exclusion holds when the caller scopes correctly, but org-scoped (project-less) spaces are included by `space_list` when `project` is omitted. Confidence: high that this is the full extent of the feature.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Keyword search returns matching Pages ranked by relevance, showing Space + Page title | Partially Met | `backend/lib/noizu_prompt_lingua/domains/wiki/wiki.ex:280-283` (ilike on title/slug only, no body match); `backend/lib/noizu_prompt_lingua/domains/wiki/tools/page_list.ex:11` (`search` field); ordering is positional (`wiki.ex:61`), not relevance-ranked; results do not include the parent Space title, only page fields |
| Keyword appearing only in Page title still matches | Met | `wiki.ex:60` — `maybe_search([:title, :slug], ...)` matches title substring |
| Results from other projects' wiki Spaces are excluded | Partially Met | Pages are fetched per-space (`wiki.ex:56-58`), so scoping depends on caller passing the correct space; `space_list` (wiki.ex:16-25) includes org-scoped spaces with NULL `project_id` when `project` is omitted — no enforced project boundary |

## Gaps / Risks

- No body-content search: a keyword in the page body alone will not match, contradicting the story's premise of finding "documentation" content.
- No relevance ranking of any kind.
- No single project-wide search entry point; caller must enumerate spaces.
- Duplicate-id collision: two stories share id US-071 (this one and the secret-leakage story), which will confuse traceability tooling.

## BDD Scenario

```gherkin
Feature: Wiki keyword search
  As a Harness Operator I can find wiki pages by keyword via MCP tools.

  Scenario: Title match returns the page
    Given a wiki space "Runbooks" containing a page titled "Deploy Pipeline" with an empty body
    When the agent calls Wiki.PageList with space=<Runbooks UUID> and search="Deploy"
    Then the response includes the "Deploy Pipeline" page (substring match on title)

  Scenario: Body-only keyword does not match
    Given a page titled "Misc" whose body contains the word "kubernetes" but whose title does not
    When the agent calls Wiki.PageList with search="kubernetes"
    Then the page is NOT returned (search only covers title and slug)

  Scenario: Results are listed, not ranked
    When the agent calls Wiki.PageList with search="deploy"
    Then pages are returned ordered by position then title, not by relevance score
```
