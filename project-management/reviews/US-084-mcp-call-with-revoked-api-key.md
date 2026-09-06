# Review: Reject MCP Calls Using a Revoked API Key

- **Story**: `project-management/user-stories/US-084-mcp-call-with-revoked-api-key.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Revocation is effective immediately (the story's "So that" holds), but the rejection taxonomy is generic. `MCPApiKeys.revoke/1` sets `status: "revoked"` and synchronously bumps the toolset cache + broadcasts `tools/list_changed` (`lib/noizu_prompt_lingua/entities/mcp_api_keys.ex:269-289`), so propagation is immediate — better than the ≤60s bound required. Revoked keys fail every auth path because lookups filter `status == "active"`: `verify_api_key/1` (`entities/mcp_api_keys.ex:244`) and the JWT path `Repo.get(McpApiKey, id)` guarded by `%McpApiKey{status: "active"}` (`lib/noizu_prompt_lingua_web/plugs/mcp_key_auth.ex:80-83`); the effective-toolset cascade re-checks active status (`lib/noizu_prompt_lingua/mcp/effective_toolset.ex:482`). However, callers get generic 401s ("invalid or expired API key", `lib/noizu_prompt_lingua_web/controllers/auth_controller.ex:293,319`; "Authentication required", `mcp_key_auth.ex:55`) — no distinct `key_revoked` code — and no rejection-time audit entry recording key id/actor/timestamp was found (revocation itself is admin/user endpoints, `admin_controller.ex:392`, `auth_controller.ex:455`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Distinct `key_revoked` error code, not `token_expired`/generic 401 | Not Met | all paths collapse to nil → generic 401 (`mcp_key_auth.ex:52-56,80-83`; `auth_controller.ex:293`) |
| Security-relevant audit log entry with key id (not secret), actor, timestamp on rejection | Not Met | no evidence found; only the revoke mutation endpoints exist (`admin_controller.ex:392`, `auth_controller.ex:455`) |
| P-002 does not auto-retry with same key; error surfaced to operator | Partially Met | the generic 401 gives harnesses nothing to branch on; client behavior unverifiable server-side |
| Revocation propagates across caching layers within a bounded time (≤60s), not next deploy | Met | cache bump + `notify_toolset_changed()` inside the revoke transaction path (`entities/mcp_api_keys.ex:286-289`); key lookups always filter active status at read time (`mcp_api_keys.ex:244`) |

## Gaps / Risks

- Distinguishing revoked vs expired vs malformed requires exactly the error taxonomy US-083 also lacks — the two stories share one fix point in the auth plug.
- Per-key toolset config is enforced even in shadow mode (`lib/noizu_prompt_lingua/mcp/tool_guard.ex:80-101`, `tool_disabled_for_key`), which mitigates but does not replace a distinct revoked signal.

## BDD Scenario

```gherkin
Feature: Revoked API key is rejected immediately

  Scenario: Admin revokes a key in active use
    Given Ilya revoked an MCP API key via the admin console
    When an MCP call authenticated with that key arrives
    Then the key fails the active-status check and the request is rejected 401 immediately
    And connected clients receive a tools/list_changed notification

  Scenario: Caller needs to know the key was revoked
    When the caller inspects the rejection
    Then the response is a generic 401 with no key_revoked code or audit trail entry (gap)
```
