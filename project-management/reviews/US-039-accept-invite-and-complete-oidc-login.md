# Review: Accept an Invite and Complete OIDC Login

- **Story**: `project-management/user-stories/US-039-accept-invite-and-complete-oidc-login.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The invite-token *data layer* exists in the Elixir backend: `create_invite_token/1` generates a bcrypt-hashed token with `key_prefix`, `find_active_invite_by_raw_token/1` enforces revoked/expiry/max-uses checks, and `increment_invite_uses/1` bumps use counts (Elixir backend `backend/lib/noizu_prompt_lingua/entities/organizations.ex:254-303`, schema `backend/lib/noizu_prompt_lingua/schema/organizations/invite_token.ex`). However, **no caller exists** for `find_active_invite_by_raw_token` or `increment_invite_uses` anywhere in `backend/lib` or the frontend — there is no invite-acceptance route in `backend/lib/noizu_prompt_lingua_web/router.ex`, no invite page in `frontend/src`, and no flow that converts a redeemed invite into org membership. The OIDC login half (per US-040) is implemented (`sso_controller.ex`), but the invite-guided entry point this story describes is absent. Confidence: high (verified zero call sites).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Invite page shows org name + single SSO CTA | Not Met | No invite page/route: no "invite" routes in `backend/lib/noizu_prompt_lingua_web/router.ex`; no invite UI in `frontend/src` |
| Continue routes through `/auth/oidc`, account created/linked, added as org member | Partially Met | OIDC login + account creation/linking implemented (`backend/lib/noizu_prompt_lingua_web/controllers/sso_controller.ex:64-93,178-217`); invite redemption + org-membership grant does not exist |
| Expired/exhausted invite shows plain-language error without token details | Not Met | No acceptance endpoint exists to return such an error; `find_active_invite_by_raw_token` has no callers |

## Gaps / Risks

- Invite entity is dead code: token minting exists (e.g. `create_invite_token/1`) but no redemption path ever consumes it.
- Security-positive: token hashing (bcrypt) and prefix lookup are done correctly — but the missing redemption flow means US-038-issued invites cannot be used end-to-end.
- Risk if built later: the redemption endpoint must add the invitee to the org *after* OIDC identity is verified (see `Auth.SSO.authenticate_sso`) and enforce the expiry/max-uses checks atomically with `increment_invite_uses`.

## BDD Scenario

```gherkin
Feature: Invite-based onboarding via OIDC
  Scenario: Accept a valid invite and log in
    Given an unexpired invite token issued per US-038
    When the newcomer opens the invite link
    Then no invite page is served and the link leads nowhere
    # Today the user can only log in via /auth/oidc directly; org membership
    # must be granted manually (ScopedMemberships.add_member by an admin).
```
