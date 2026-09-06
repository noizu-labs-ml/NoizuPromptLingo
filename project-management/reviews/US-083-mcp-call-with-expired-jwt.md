# Review: Reject MCP Calls with an Expired JWT

- **Story**: `project-management/user-stories/US-083-mcp-call-with-expired-jwt.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Expired JWTs ARE rejected, but with a generic taxonomy, not the story's distinct `token_expired` code. The NPL-side `DualTokenVerifier` does return a distinct `{:error, :expired}` (`lib/noizu_prompt_lingua/mcp/dual_token_verifier.ex:138-139`), but its consumers flatten it: `McpKeyAuth.key_from_jwt/2` rescues verifier errors into `nil` → 401 "Authentication required" (`lib/noizu_prompt_lingua_web/plugs/mcp_key_auth.ex:77-90,52-56`). On the MCP transport itself, `noizu_mcp`'s `JwtVerifier` maps an expired `exp` to `{:error, :invalid_token}` (`deps/noizu_mcp/lib/noizu/mcp/auth/jwt_verifier.ex:128-141`), rendered as HTTP 401 with a `WWW-Authenticate` bearer challenge carrying `error="invalid_token"` (`deps/noizu_mcp/lib/noizu/mcp/transport/streamable_http/plug.ex:183-184,219-228`). No expiry timestamp is included in any response, and no routine-vs-incident log classification for expiry events was found.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Distinct `token_expired` error code, not generic 401/500 | Not Met | transport maps expiry → generic `:invalid_token` (`deps/noizu_mcp/lib/noizu/mcp/auth/jwt_verifier.ex:141`; `plug.ex:183-184`); NPL-internal `:expired` (`dual_token_verifier.ex:139`) never reaches the caller |
| Error includes the token's expiry timestamp | Not Met | no evidence found — 401 body is the literal string "Unauthorized" with a challenge header only (`plug.ex:219-228`) |
| Logged as routine auth-expiry event, not security incident | Not Met | no expiry-specific logging found in either verifier or plug |
| Retry with fresh token succeeds without duplicate side effects | Partially Met | rejection happens in the auth plug before dispatch, so the original call had no side effects; a freshly minted token (`POST /api/mcp/token`, `router.ex:117-119`) is then accepted — but no idempotency machinery exists should a call time out mid-dispatch |

## Gaps / Risks

- Agent harnesses cannot programmatically distinguish expired vs malformed vs revoked: all surface as `invalid_token`/401. This defeats the story's core purpose (triggering targeted re-auth).
- DualTokenVerifier already computes the richer signal (`:expired`) — surfacing it through the transport is a small, contained change.
- Related: US-084 needs a sibling distinct code (`key_revoked`); a shared error-mapping point in the transport plug would serve both.

## BDD Scenario

```gherkin
Feature: Expired JWT rejection on MCP calls

  Scenario: Agent calls a tool after its token expired
    Given an MCP session whose JWT expired moments ago
    When the agent issues any tool call
    Then the server returns 401 with WWW-Authenticate error="invalid_token"
    And the response does NOT contain a distinct token_expired code or expiry timestamp (gap)

  Scenario: Harness refreshes and retries
    When the harness mints a fresh token via POST /api/mcp/token and retries the call
    Then the call is dispatched normally, with no duplicate side effects from the rejected attempt
```
