# Review: Generate Ad Copy Variants for an Ad Group

- **Story**: `project-management/user-stories/US-030-generate-ad-copy-variants-for-ad-group.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No ad-copy generation exists. Greps for `ad_copy`, `ad_group`, `campaign`, and `landing_page` across `src/` and `tests/` return zero hits. There is no ad-copy record model, no "pending review" status workflow, no LLM generation call, and no error/rollback path for failed generation. The prerequisite ad-group entity (US-029) is also absent.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| N distinct ad copy drafts created under an ad group in "pending review" status | Not Met | no evidence found |
| LLM failure/timeout yields clear error with no partial records left behind | Not Met | no evidence found |
| New drafts added alongside existing approved copy without overwriting | Not Met | no evidence found |

## Gaps / Risks

- Depends on US-029 data model, which is entirely unimplemented.
- Atomicity requirement (no partial records on LLM failure) should be designed in from the start — a generation tool that writes rows per streaming chunk would violate it.

## BDD Scenario

```gherkin
Feature: Generate ad copy variants

  Scenario: Generate three variants
    Given an ad group with a target-audience label and product description
    When I trigger generation with variant count 3
    Then 3 distinct ad copy drafts are created under the ad group in "pending review" status

  Scenario: LLM failure
    Given a generation request in flight
    When the LLM call fails or times out
    Then a clear error is shown and no partial ad copy records remain
```

(Scenario describes target behavior — none of it is executable today.)
