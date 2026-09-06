# Review: Approve or Reject a Generated Ad Copy Variant

- **Story**: `project-management/user-stories/US-031-approve-reject-ad-copy-variant.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No ad-copy approval workflow exists. Greps for `ad_copy`, `approved`, `pending review` in a campaign/ad context, `ad_group`, and `campaign` across `src/` and `tests/` return zero hits. There is no ad-copy record with a status field, no approve/reject tool or route, and no copy list view with filtering. The prerequisite generation story (US-030) and ad-group entity (US-029) are also entirely absent.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Approving a "pending review" variant sets status "approved" and marks it eligible downstream | Not Met | no evidence found |
| Rejecting with optional reason sets status "rejected" and excludes from active-use lists | Not Met | no evidence found |
| Copy list visually distinguishes and filters pending/approved/rejected statuses | Not Met | no evidence found |

## Gaps / Risks

- Fully dependent on the unimplemented US-029/US-030 data model.
- "Excluded from active-use selection lists" implies downstream consumers must filter on status — that contract should be defined when the data model lands so later consumers inherit it.

## BDD Scenario

```gherkin
Feature: Approve or reject ad copy variants

  Scenario: Approve a variant
    Given an ad copy variant in "pending review" status
    When I select "approve"
    Then its status becomes "approved" and it is eligible for downstream use

  Scenario: Reject with reason
    Given an ad copy variant in "pending review" status
    When I select "reject" with reason "off-brand"
    Then its status becomes "rejected" and it is excluded from active-use selection lists
```

(Scenario describes target behavior — none of it is executable today.)
