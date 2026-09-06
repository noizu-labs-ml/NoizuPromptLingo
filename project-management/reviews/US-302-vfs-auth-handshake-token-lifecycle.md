# Review: Complete the vfs/auth handshake and token lifecycle including re-auth and revocation

- **Story**: `project-management/user-stories/US-302-vfs-auth-handshake-token-lifecycle.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Initial bind is solid: the upgrade runs the same `DualTokenVerifier` bearer pipeline as the MCP surface (Elixir backend, `lib/noizu_prompt_lingua_web/mcp_config.ex:74-91`), and the first-frame `vfs/auth` handshake re-verifies the token and binds claims into the connection `Ctx` (`deps/noizu_mcp/lib/noizu/mcp/transport/vfs_ws.ex:188-239`, `build_ctx/3` at 388-402 puts claims in `assigns.auth_claims`; NPL's `Principal.context_assigns/0` is the documented insertion hook, `lib/noizu_prompt_lingua/mcp/vfs/principal.ex:120`). A second `vfs/auth` is refused `-32600` ("connection already authenticated", vfs_ws.ex:192-194, documented in the moduledoc). However, the claims are bound **once**: no per-operation re-verification exists, so a token that expires or is revoked server-side while the connection is open continues to operate until the socket drops for other reasons. `validate_api_key` (`MCPAuth.api_key_active?/1`) runs only at upgrade and handshake time. The Principal gate map does inherit a 45s TTL + toolset-change invalidation via `ToolsetCache` (principal.ex:18-26), but that invalidates the *toolset cascade*, not token validity. Lifecycle states beyond initial bind are explicitly uncovered (story Notes agree).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `vfs/auth` as first frame binds verified claims to the connection Ctx; ops run under that principal | Met | Elixir backend `deps/noizu_mcp/lib/noizu/mcp/transport/vfs_ws.ex:188-239, 388-402`; tested in `test/noizu_prompt_lingua/mcp/vfs/vfs_ws_transport_test.exs:119-180` |
| Token expires mid-session → next op denied, client told to re-authenticate | Not Met | No expiry re-check after bind: dispatch (`vfs_ws.ex:242-272`) never re-runs the verifier; claims from handshake live for the socket's lifetime |
| Server-side revocation → ops denied (or connection terminated) within bounded time | Not Met | `validate_api_key` only invoked inside `verify/3` at upgrade + handshake (`vfs_ws.ex:106-127, 374-383`); no periodic recheck or revocation watcher exists |
| Re-auth on existing connection refreshes claims or returns documented reconnect-required behavior — no silent continuation under old claims | Partially Met | Second `vfs/auth` returns `-32600` invalid_request and the connection stays open (`vfs_ws.ex:192-194`) — the refusal is documented, but old claims silently keep working until the client chooses to reconnect; there is no forced close or "stale" signal |
| Only documented token kinds accepted on `/vfs` (legacy fleet tokens vs DualTokenVerifier pipeline) | Met | Both upgrade (`mcp_config.ex:74-91`) and handshake (`vfs_ws.ex:374-383`) use the same `DualTokenVerifier` opts — RS256 (JWKS) + legacy HS256 compound JWTs only, with active `api_key_id` required |

## Gaps / Risks

- **Security**: long-lived connections outlive their authorization — expiry and revocation are invisible to an open socket. A revocation response window is effectively unbounded (until keepalive drops at 2 missed 30s pongs, which still does not re-verify).
- The `-32600` re-auth refusal leaves a compromised connection fully operational; "reconnect required" is implied, not enforced or signalled.
- Handshake `conn_info` is only `%{transport: :vfs_ws}` (vfs_ws.ex:223) — the verifier's per-request context (peer IP, headers) is absent on the handshake verify, unlike the upgrade verify.
- Recommended remediation aligns with the story: re-run claim verification on a TTL (or per-op cheap check against the API key row) and define re-auth as close-1008 + client reconnect.

## BDD Scenario

```gherkin
Feature: VFS auth handshake and token lifecycle

  Scenario: Handshake binds claims (implemented today)
    Given a valid bearer token accepted at the /vfs upgrade
    When the client sends vfs/auth with that token as the first frame
    Then the verified claims bind to the connection Ctx
    And subsequent vfs operations execute under that principal

  Scenario: Mid-session expiry (not yet implemented — aspirational)
    Given a connection authenticated with a token that then expires
    When the client issues any vfs operation
    Then the operation is denied with a re-authenticate signal
    And a second vfs/auth with a fresh token either refreshes the Ctx or the connection is closed
```
