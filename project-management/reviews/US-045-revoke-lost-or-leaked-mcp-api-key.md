# Review: Revoke a Lost or Leaked MCP API Key

- **Story**: `project-management/user-stories/US-045-revoke-lost-or-leaked-mcp-api-key.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The full revoke flow exists end-to-end. The frontend `/app/mcp-keys` page renders each key with its status and a confirm-guarded revoke button (`frontend/src/app/app/mcp-keys/page.tsx:196-211`, status badge at `page.tsx:446-447`), wired to `DELETE /auth/mcp-keys/:id` (`[Elixir backend] backend/lib/noizu_prompt_lingua_web/router.ex:459`), whose controller scopes the key to the caller's own key list before revoking (`auth_controller.ex:455-472`). Revocation sets `status: "revoked"` in a single UPDATE (`entities/mcp_api_keys.ex:269-280`). The JWT exchange path rejects revoked keys because `verify_api_key/1` queries only `status == "active"` (`entities/mcp_api_keys.ex:244`), and `POST /api/mcp/token` uses that exact function (`token_controller.ex:41`). Confidence is high; the only gap is that the audit trail shows status but not a revocation timestamp. ([Elixir backend] = NoizuPromptLingo/backend, the Phoenix app.)

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Select "revoke" + confirm on `/app/mcp-keys` → status changes to "revoked" immediately | Met | `frontend/src/app/app/mcp-keys/page.tsx:196-211` (confirm dialog + `api.revokeMcpKey`); `[Elixir backend] backend/lib/noizu_prompt_lingua_web/controllers/auth_controller.ex:455-472`; `entities/mcp_api_keys.ex:269-280` (status UPDATE) |
| Revoked key's raw value rejected at `POST /api/mcp/token` | Met | `verify_api_key` filters `status == "active"` (`entities/mcp_api_keys.ex:244`); used by token exchange (`controllers/token_controller.ex:41`) and key-auth plug (`plugs/mcp_key_auth.ex:67`) |
| Revoked key remains visible afterward with "revoked" status and timestamp | Partially Met | `list_for_user` returns all statuses (`entities/mcp_api_keys.ex:262-267`); `mcp_key_json` includes `status` + `inserted_at`/`last_used_at` (`auth_controller.ex:563-574`); frontend shows status (`page.tsx:446-447`) — but there is no `revoked_at` field, so the *revocation* timestamp is not shown |

## Gaps / Risks

- No `revoked_at` column on the key schema — the audit trail cannot show *when* a key was revoked (only creation and last-use timestamps).
- The story's own note is correct and worth restating: revocation does not retroactively invalidate an already-minted MCP JWT; a live JWT survives until its short expiry. Any emergency response must also consider killing active sessions.
- User-scoped revoke is deny-closed (key must be in the caller's own list); the admin surface has a parallel revoke route (`router.ex:553`) for support scenarios.

## BDD Scenario

```gherkin
Feature: Revoke a lost or leaked MCP API key

  Scenario: Revoke a key from the key list
    Given a listed API key on /app/mcp-keys with status "active"
    When I click revoke and confirm the dialog
    Then the key's status changes to "revoked" immediately
    And the key remains visible in my key list with the "revoked" badge

  Scenario: Revoked key cannot mint tokens
    Given a key was just revoked
    When a client presents that key's raw value to POST /api/mcp/token
    Then the exchange is rejected because verify_api_key only matches active keys

  Scenario: Audit trail
    When I view my key list after revocation
    Then the revoked key is still listed with status "revoked"
    But no revocation timestamp is displayed (no revoked_at field exists)
```
