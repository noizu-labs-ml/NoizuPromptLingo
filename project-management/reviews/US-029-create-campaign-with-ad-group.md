# Review: Create a Campaign with an Ad Group

- **Story**: `project-management/user-stories/US-029-create-campaign-with-ad-group.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No campaign or ad-group domain exists. Greps for `campaign`, `ad_group`, `adgroup` across `src/` and `tests/` return zero hits. There are no campaign/ad-group storage tables, no MCP tools, no HTTP routes, and no dashboard UI. The "Campaigns dashboard" UI referenced in the acceptance criteria does not exist either (`src/npl_mcp/web/` contains only a `.gitignore`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| New campaign form (name + objective) creates record with status "draft" and appears in campaign list | Not Met | no evidence found |
| Ad group with name + target-audience label persists nested under campaign in detail view | Not Met | no evidence found |
| UI blocks ad-copy generation for campaigns with zero ad groups | Not Met | no evidence found |

## Gaps / Risks

- Entire epic (Creative Assets & Campaigns) is greenfield: data model, tools, and UI all needed.
- The blocking rule in the third criterion is a UI-level invariant that will need a corresponding API-level guard so generation tools also reject ad-group-less campaigns.

## BDD Scenario

```gherkin
Feature: Create a campaign with an ad group

  Scenario: Create a campaign
    Given I am viewing the Campaigns dashboard for my org
    When I submit the "new campaign" form with a name and objective
    Then a campaign record with status "draft" appears in my campaign list

  Scenario: Add an ad group
    Given an existing campaign
    When I create an ad group with a name and target-audience label
    Then the ad group appears nested under the campaign

  Scenario: Generation blocked without ad group
    Given a campaign with zero ad groups
    When I attempt ad-copy generation for it
    Then the action is blocked and I am prompted to create an ad group first
```

(Scenario describes target behavior — none of it is executable today.)
