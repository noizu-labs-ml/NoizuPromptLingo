# Review: Change a User's Global Role with Self-Lockout Guard

- **Story**: `project-management/user-stories/US-055-change-a-users-global-role-with-self-lockout-guard.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend implements admin role changes via `POST`-style admin route handled in `update_user/2` at [Elixir backend] `backend/lib/noizu_prompt_lingua_web/controllers/admin_controller.ex:65-105`, with role validation against a fixed role list (`parse_role/1`, lines 111-118). A self-lockout guard exists but is stricter than the story specifies: an admin can *never* change their own role (lines 68-70), rather than only being blocked when they are the last admin. There is no audit-log write anywhere in the role-change path. Frontend admin users page exists (`frontend/src/app/app/admin/users/page.tsx`). Moderate confidence: core mutation and guard verified; "effective on next request" is satisfied implicitly because role is read per-request by authz code, but no test evidence was found.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Change another user's global role; takes effect on next request | Met | `admin_controller.ex:65-105` (`Repo.update_all(set: [role: ...])`); role consulted per-request by authz |
| Last remaining admin blocked from demoting self, with explanatory error | Partially Met | `admin_controller.ex:68-70` blocks ALL self-role edits ("You cannot change your own role") — lockout is prevented, but not via a last-admin check and the error message does not mention the zero-admin rationale |
| With ≥2 platform admins, self-demotion succeeds | Not Met | `admin_controller.ex:68-70` unconditionally forbids self-role change, even when other admins exist |
| Audit log records who, prior role, new role, when | Not Met | no audit/history write in `update_user/2`; only role update query at line 80-81 |

## Gaps / Risks

- The blanket self-edit ban deviates from spec: an admin with co-admins cannot hand the story's success path; role changes require a second admin account.
- No audit trail for privilege changes — compliance/investigation gap.
- `parse_role/1` uses `String.to_existing_atom/1` (safe) but role atoms are implicit; no test coverage found for the guard.

## BDD Scenario

```gherkin
Feature: Admin changes a user's global platform role

  Scenario: Admin changes another admin's role
    Given Ilya is an authenticated platform admin viewing another user's detail page
    When he submits a new global role for that user via the admin users API
    Then the user's role is updated in the database
    And subsequent authorization checks for that user use the new role

  Scenario: Admin attempts to change own role
    Given Ilya is an authenticated platform admin
    When he attempts to change his own role through the admin API
    Then the request is rejected with 403 "You cannot change your own role"

  Scenario: Role change audit
    Given Ilya changes another user's role
    When the change is saved
    Then no audit log entry is produced (gap: story requires who/prior/new/when)
```
