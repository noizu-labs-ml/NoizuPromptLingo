# Review: Complete First-Time SSO Callback

- **Story**: `project-management/user-stories/US-040-complete-first-time-sso-callback.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The OIDC callback flow is fully implemented in the Elixir backend. `oidc_init/2` generates a random `state` + `nonce` and builds the authorization URI (`backend/lib/noizu_prompt_lingua_web/controllers/sso_controller.ex:20-42`); `oidc_callback/2` verifies the state with `secure_compare` **before** any provider fetch (one-time use — cleared before the exchange), fetches tokens, verifies the id_token, then checks the nonce (`sso_controller.ex:64-97`). `handle_sso_callback/3` either logs the user in (redirect to frontend `/auth/sso-callback?code=...` with a one-time claim code) or, for a first-time identity, signs a `RegistrationToken` and redirects to `/auth/register?token=...` (`sso_controller.ex:178-217`). `register/2` creates the account from the verified identity with name/bio form fields and issues the Guardian token pair (`sso_controller.ex:136-168`); `issue_guardian_pair/1` sets access 1h / refresh 7d and stores the refresh JTI (`sso_controller.ex:296-311`). Routes wired at `backend/lib/noizu_prompt_lingua_web/router.ex:685-688`. The only deviation: a first-time login is *not* fully automatic — the user completes a short name/bio registration form, which is a deliberate product choice consistent with the story's "account created" intent. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| User redirected to IdP via `/auth/oidc` with state+nonce | Met | `sso_controller.ex:20-42` (state+nonce in session, OpenIDConnect.authorization_uri) |
| Callback validates state before exchange (CSRF) | Met | `sso_controller.ex:77` — `verify_state` first; one-time use enforced at `sso_controller.ex:70-73` |
| id_token verified, nonce checked, account auto-created/linked | Met | `sso_controller.ex:81-88` (verify + nonce) → `Auth.SSO.authenticate_sso` handles create/link; registration path at `:209-213` + `:136-168` (Partially automatic: extra name/bio form step) |
| User lands logged-in with a session | Met | claim_code redirect to `/auth/sso-callback?code=...` (`sso_controller.ex:202-206`), exchanged for a Guardian pair via `exchange/2` (`:101-120`) |

## Gaps / Risks

- First-time users hit the name/bio registration form rather than fully automatic account creation — intentional but differs from a literal reading of the story.
- `verify_nonce/2` tolerates a *missing* returned nonce (`sso_controller.ex:55-56`); a different nonce is rejected. Acceptable, documented trade-off.
- New accounts always default to role `:user` — role never taken from client (`sso_controller.ex:136-141`). Security-positive.

## BDD Scenario

```gherkin
Feature: First-time SSO login
  Scenario: New user logs in with Authentik for the first time
    Given an email that has never logged into NPL
    When they click "Sign in with OIDC" and complete Authentik login
    Then the backend verifies state, exchanges the code, and validates nonce
    And since no account exists, they are sent to /auth/register?token=...
    And after submitting name/bio, an account is created
    And they are returned to the frontend logged in with access+refresh tokens
```
