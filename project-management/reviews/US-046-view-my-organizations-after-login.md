# Review: View My Organizations After Login

- **Story**: `project-management/user-stories/US-046-view-my-organizations-after-login.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The post-login landing flow implements all three criteria. The authenticated `/app` root page ("Your Organizations") lists every organization the user belongs to with its name and the user's role (`frontend/src/app/app/page.tsx:27-46`); the org list itself is loaded by the `OrgProvider` from the auth payload or `api.listOrganizations()` (`frontend/src/context/org.tsx:51-74`), and the role column is also surfaced in the Organizations console table (`frontend/src/lib/console/descriptors/organizations.ts:25`). A single-org user is redirected straight into that org's context without a selection step (`page.tsx:22-25`), and multi-org selection persists across logins via `localStorage.currentOrgId` (`org.tsx:61-63, 80-87`), restored on the next session. Confidence is high; the only nuance is that the persisted selection restores the *active org context* (switcher/sidebar), while the `/app` list page itself always shows the full list — which matches the story's intent.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Post-login screen lists my organizations with name and my role | Met | `frontend/src/app/app/page.tsx:29-46` (list + `org.role`); org loading at `context/org.tsx:51-74`; role column in console table `lib/console/descriptors/organizations.ts:25` |
| Exactly one org → taken directly into its context, no extra selection step | Met | `frontend/src/app/app/page.tsx:22-25` (auto-redirect to `/app/<slug>`); `context/org.tsx:63,70` auto-selects first org into context |
| Multiple orgs → select one to enter; selection remembered for next login | Met | `page.tsx:34-44` (links into `/app/<slug>`); `context/org.tsx:80-87` (`switchOrg` persists `currentOrgId`) and `org.tsx:61-63` (restored on load) |

## Gaps / Risks

- None of substance. Minor polish notes: the `/app` list page uses inline styles rather than the design-system components used elsewhere, and the role badge renders raw (`(owner)`) without the RBAC-gated styling the Organizations console table applies.
- Selection persistence is `localStorage`-keyed per browser; a user on a new device re-lands on the list (acceptable, matches "my next login" on the same browser).

## BDD Scenario

```gherkin
Feature: View my organizations after login

  Scenario: Newcomer with multiple orgs logs in
    Given I belong to two organizations
    When I log in and land on /app
    Then I see "Your Organizations" listing both names with my role in each
    When I select one
    Then I enter that org's context and the choice is remembered on my next login

  Scenario: Single-org user logs in
    Given I belong to exactly one organization
    When I log in and land on /app
    Then I am redirected directly into that organization without a selection step
```
