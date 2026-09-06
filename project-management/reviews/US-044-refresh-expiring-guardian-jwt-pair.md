# Review: Refresh Expiring Guardian JWT Pair

- **Story**: `project-management/user-stories/US-044-refresh-expiring-guardian-jwt-pair.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Refresh rotation is implemented in the Elixir backend: `POST /auth/refresh` (`backend/lib/noizu_prompt_lingua_web/router.ex:413` → `backend/lib/noizu_prompt_lingua_web/controllers/auth_controller.ex:10-44`) decodes the presented refresh token (requires `typ: "refresh"`), checks its `jti` against the token store (`Auth.TokenStore.valid_refresh_jti?`), revokes the old JTI, and issues a fresh access(1h)/refresh(7d) pair — single-use rotation with the new JTI stored. The SSO login path registers the initial refresh JTI (`sso_controller.ex:296-311`), so SSO-issued refresh tokens are refreshable (an earlier gap now fixed). Gaps: the access token is stateless and is **not** invalidated on refresh (a stolen access token lives out its 1h TTL), and the frontend's handling of refresh failure (redirect to login with return URL) could not be confirmed in the reviewed frontend code paths. Confidence: medium-high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Presenting a valid refresh token yields a new token pair | Met | `auth_controller.ex:10-44` (decode → jti check → new pair) |
| Old refresh token cannot be reused (rotation, single-use) | Met | old JTI revoked in TokenStore before re-issue (`auth_controller.ex:10-44`); store wired at `sso_controller.ex:301-307` |
| Invalid/expired/rotated refresh token → 401 | Met | `valid_refresh_jti?` rejection path in `auth_controller.ex:10-44` |
| Frontend silently refreshes before expiry and redirects to login on failure | Partially Met | refresh endpoint exists; frontend auto-refresh/redirect behavior not verified in reviewed frontend code (no evidence found) |
| Access token invalidated on refresh | Not Met | access JWTs are stateless with 1h TTL; no denylist/`token_version` bump on refresh |

## Gaps / Risks

- Stolen access tokens remain valid up to 1h after a refresh; mitigated by the short TTL but worth a documented decision (or `token_version` bump on refresh).
- Frontend refresh-on-401 interceptor behavior unconfirmed — verify `frontend/src` auth client handles refresh failure → login redirect.

## BDD Scenario

```gherkin
Feature: Refresh the Guardian JWT pair
  Scenario: Client refreshes before access-token expiry
    Given a client holding a valid access + refresh pair
    When it posts the refresh token to /auth/refresh
    Then a new access(1h) + refresh(7d) pair is returned
    And the old refresh token's jti is revoked and cannot be reused
  Scenario: Replay of a rotated refresh token
    When the old refresh token is presented again
    Then a 401 is returned
```
