# Review: Research Competitors for a Market Segment

- **Story**: `project-management/user-stories/US-034-research-competitors-for-market-segment.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend ships competitor CRUD as MCP tools — `Competitor.Create/Get/List/Update` (`backend/lib/noizu_prompt_lingua/domains/market/tools/competitor_create.ex` et al.) over an org-scoped schema with tiers and active/archived status (`backend/lib/noizu_prompt_lingua/schema/competitor.ex:12-43`). However the story's core action — LLM-assisted *research* of a market segment returning stored candidate competitors — has no implementation; only keyword research is LLM-backed (`Keyword.Research`, `backend/lib/noizu_prompt_lingua/domains/market/tools/keyword_research.ex:6-15`; `Market.research_keywords`, `backend/lib/noizu_prompt_lingua/domains/market/market.ex:58`). There is no notion of research runs, so run history is impossible, and competitor classification is limited to active/archived rather than relevant/dismissed.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Trigger "research competitors" for a segment → candidate list (name + summary) stored against the segment | Partially Met | competitors can be created/stored (`competitor_create.ex`) with summary fields, but no LLM research trigger exists; storage is org/project-scoped, not segment-keyed |
| Re-running research preserves prior and new result sets | Not Met | no research-run/versioning concept anywhere (`backend/lib/noizu_prompt_lingua/domains/market/market.ex:1-10`) |
| Mark competitor "relevant"/"dismissed"; classification persists and controls default view | Partially Met | `Competitor.Update` can set status active/archived (`schema/competitor.ex:12,39`; `competitor_update.ex`), which approximates dismissal but there is no relevant/dismissed vocabulary nor default-view filtering semantics |

## Gaps / Risks

- The competitor schema has no segment/market-segment association field — findings cannot be "stored against that segment" without schema work.
- LLM generation plumbing exists for keywords (reusable), so implementing competitor research is mostly a new tool + prompt, not new infrastructure.

## BDD Scenario

```gherkin
Feature: Research Competitors for a Market Segment

  Scenario: Manual competitor tracking (works today)
    Given a growth operator in an organization
    When they call Competitor.Create with name, tier, and summary
    Then the competitor is stored org-scoped and visible via Competitor.List
    And Competitor.Update can archive it (hidden from an "active" filter)

  Scenario: LLM competitor research (not available)
    Given a market segment label and short description
    When the operator triggers competitor research for that segment
    Then no research tool exists to generate candidate competitors
    And no run history is kept, so prior results cannot be preserved
```
