# Review: Suspend a User Account

- **Story**: `project-management/user-stories/US-054-suspend-a-user-account.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented in the Elixir backend as substrate plus one enforcement point, but the admin action itself does not exist. The user schema defines the `:suspended` status (`backend/lib/noizu_prompt_lingua/schema/users/user.ex:22-25`, enum `[:active, :unverified, :waitlist, :suspended, :deleted]`), and SSO authentication gates login on `u.status == :active` (`backend/lib/noizu_prompt_lingua/auth/sso.ex:70-71`), so a user manually flipped to suspended would be unable to start a new SSO login. That is the entire implementation. There is no admin suspend/un-suspend endpoint: `AdminController` exposes `list_users`, `show_user`, and `update_user` for role changes only (self-lockout guard at `admin_controller.ex:65`); a grep for `suspend` across the backend lib finds the schema enum and a "belt+suspenders" comment in `workers/session_inactivity_worker.ex` — no setter, no route. Because authentication there is token-based (Guardian/MCP keys), existing sessions, MCP API keys, and OAuth tokens carry no status check: the "any authenticated request is rejected" criterion is not enforced anywhere outside the SSO login query, and nothing signs out active sessions on suspension.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Admin suspends account; status changes to suspended; active sessions immediately signed out | Not Met | no evidence found — no suspend action in `admin_controller.ex` (only role update at `:65-107`), no session-invalidation on status change |
| Suspended user's authenticated requests rejected with "account suspended" regardless of org | Not Met | no evidence found — SSO blocks new logins (`sso.ex:70-71`) but Guardian/MCP-key/OAuth auth paths perform no user-status check; no "account suspended" error exists |
| UI shows suspended status, admin who performed it, and timestamp | Partially Met | `show_user` returns the user including status (`admin_controller.ex:40`), and audit fields exist on users — but with no suspend action there is no suspension event, actor, or timestamp recorded |
| Un-suspend restores access on next authentication | Partially Met | restoring `status: :active` would satisfy the SSO gate (`sso.ex:70-71`), but no un-suspend action exists to perform the flip |

## Gaps / Risks

- Biggest risk is the false sense of security: an operator assuming the enum means enforcement would be wrong — a suspended user's existing MCP keys and tokens keep working. A per-request status check in the auth plug/token-verification path is the missing enforcement point.
- The suspension metadata (who/when) needs either an audit table or `suspended_by`/`suspended_at` columns; the story requires actor + timestamp visibility.
- Implementation is trivially reachable: add admin suspend/un-suspend actions setting status via a changeset, a status check in token verification, and session revocation (invalidate Guardian claims / revoke MCP keys for the user).

## BDD Scenario

```gherkin
Feature: Global account suspension

  Scenario: Admin suspends a user
    Given Ilya views a target user as platform admin
    When he suspends the account
    Then the story expects status=suspended, immediate sign-out of all sessions,
      and an actor+timestamp shown on the detail page
    But no suspend endpoint exists, so this scenario cannot be executed

  Scenario: Suspended user attempts authenticated request
    Given a user with status :suspended and a still-valid MCP key
    When the key authenticates a request
    Then the story expects rejection with "account suspended"
    But no auth path checks user status, so the request succeeds
```
