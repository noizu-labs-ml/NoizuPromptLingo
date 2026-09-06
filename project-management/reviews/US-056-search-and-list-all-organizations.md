# Review: List and Search All Organizations

- **Story**: `project-management/user-stories/US-056-search-and-list-all-organizations.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend provides platform-wide org listing and detail endpoints in `admin_controller.ex` [Elixir backend] `backend/lib/noizu_prompt_lingua_web/controllers/admin_controller.ex:120-166`: `list_organizations/2` returns a paginated list of ALL orgs (page/per_page/total) regardless of the admin's memberships, and `show_organization/2` returns org metadata plus the full members list. A frontend admin orgs page exists (`frontend/src/app/app/admin/orgs/page.tsx`). The missing piece is search: `list_organizations/2` accepts no query parameter and always orders by `inserted_at desc` — there is no name/slug substring filter. Confidence: high (query body read directly).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Paginated list of all orgs regardless of own memberships | Met | `admin_controller.ex:120-144` — unscoped query over `OrgSchema` with page/per_page/total |
| Partial org name or key prefix, case-insensitive substring filter | Not Met | `admin_controller.ex:120-137` — no search/q param; only pagination params parsed |
| Detail view shows name, key prefix, member count, creation date without membership | Met | `admin_controller.ex:146-166` — returns slug/name/created_at plus `Organizations.list_members/1`; member count is derivable from the returned members list (no explicit count field, minor deviation) |

## Gaps / Risks

- No search capability — an admin with many orgs must page through them 50 at a time.
- `show_organization/2` returns the entire members list rather than a count; fine for small orgs, unbounded for large ones.
- No test evidence found for either endpoint.

## BDD Scenario

```gherkin
Feature: Admin lists and inspects all organizations

  Scenario: Paginated org list
    Given Ilya is an authenticated platform admin on the admin organizations page
    When the org list loads
    Then all orgs on the platform are returned paginated with a total count

  Scenario: Search by partial name
    Given Ilya types a partial org name into the search box
    When results are requested
    Then no server-side filter is applied (gap: the API ignores search terms)

  Scenario: Org detail without membership
    Given Ilya selects an org he does not belong to
    When the detail view loads
    Then the API returns the org's slug, name, creation date, and member list
```
