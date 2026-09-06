# Review: Generate a Landing Page Draft

- **Story**: `project-management/user-stories/US-032-generate-landing-page-draft.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No landing-page generation exists. Greps for `landing_page`, `campaign`, and `ad_copy` across `src/` and `tests/` return zero hits. There is no landing-page record model, no draft/version history, no LLM generation call, and no provenance linkage. The prerequisite entities (campaign from US-029, approved variants from US-031) are also entirely absent.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Generating a draft for a campaign with an approved variant creates sectioned copy in "draft" status, linked to the campaign | Not Met | no evidence found |
| Regeneration creates a new version while prior versions remain retrievable in campaign history | Not Met | no evidence found |
| Draft displays source campaign and ad-copy variant (traceable provenance) | Not Met | no evidence found |

## Gaps / Risks

- Depends on the whole Creative Assets & Campaigns epic (US-029/US-030/US-031), none of which exists.
- Version-history requirement should be shaped with the existing versioned-artifact patterns in `src/npl_mcp/artifacts/` when implemented, rather than a bespoke history table.

## BDD Scenario

```gherkin
Feature: Generate a landing page draft

  Scenario: Generate from approved copy
    Given a campaign with at least one approved ad copy variant
    When I trigger "generate landing page draft"
    Then a sectioned draft is created, linked to the campaign, in "draft" status
    And it records which campaign and variant it was generated from

  Scenario: Regenerate keeps history
    Given a landing page draft already exists for the campaign
    When I request regeneration
    Then a new draft version is created and prior versions remain retrievable
```

(Scenario describes target behavior — none of it is executable today.)
