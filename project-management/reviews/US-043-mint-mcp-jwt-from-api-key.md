# Review: Mint MCP JWT from API Key

- **Story**: `project-management/user-stories/US-043-mint-mcp-jwt-from-api-key.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented end-to-end in the Elixir backend. `POST /api/mcp/token` (`backend/lib/noizu_prompt_lingua_web/router.ex:117-120` → `TokenController.create`) accepts a raw API key, verifies it via prefix lookup + bcrypt + active/expiry checks (`backend/lib/noizu_prompt_lingua/entities/mcp_api_keys.ex:239-260`), and on failure returns 401 for revoked/expired/unknown keys. On success it mints an RS256 JWT via `Token.mint` (`backend/lib/noizu_prompt_lingua/token.ex` — JWKS-backed keys, HS256 legacy path, default 7-day TTL, claims include `sub`, `api_key_id`, `iss`, `iat`, `exp`, `token_version`, optional RFC 8707 `aud`). The `McpKeyAuth` plug accepts either a raw key or the bearer JWT (`DualTokenVerifier` → resolves `api_key_id` → requires the key still active), so a minted token resolves to the key's owner/permissions. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `POST /api/mcp/token` with valid key returns a JWT | Met | `router.ex:117-120`; `TokenController.create`; `Token.mint` (`token.ex`) |
| Invalid/revoked/expired key → 401, no token issued | Met | `verify_api_key/1` (`mcp_api_keys.ex:239-260`) checks status + expiry before minting |
| JWT identifies the API key / owner and works as bearer | Met | claims carry `api_key_id`+`sub` (`token.ex`); `McpKeyAuth` (`plugs/mcp_key_auth.ex`) resolves bearer via DualTokenVerifier → active key |
| Signed with asymmetric key (verifiable without DB secret) | Met | RS256 via JWKS default in `Token.mint` |

## Gaps / Risks

- Story asks for a "short-lived" JWT; the default TTL is 7 days (`token.ex`). Confirm this matches intended "short-lived" semantics or lower the default for MCP tokens.
- `token_version` claim enables bulk revocation; ensure key revocation also invalidates previously minted JWTs via version bump (verify_api_key's active check does this only at resolution time — acceptable).

## BDD Scenario

```gherkin
Feature: Exchange API key for MCP JWT
  Scenario: Connector mints a token and calls MCP endpoints
    Given a valid active MCP API key
    When the connector posts it to /api/mcp/token
    Then an RS256 JWT bearing api_key_id and sub is returned
    And subsequent bearer calls to /api/mcp resolve through McpKeyAuth
  Scenario: Revoked key
    Given a revoked API key
    When posted to /api/mcp/token
    Then a 401 is returned and no JWT is issued
```
