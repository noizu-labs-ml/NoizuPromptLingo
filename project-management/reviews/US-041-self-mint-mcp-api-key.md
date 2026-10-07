# Review: Self-Mint MCP API Key

- **Story**: `project-management/user-stories/US-041-self-mint-mcp-api-key.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Fully implemented in the Elixir backend plus Next.js frontend UI. `POST /auth/mcp-keys` (`backend/lib/noizu_prompt_lingua_web/router.ex:452-459` → `auth_controller.ex` `create_mcp_key` at `backend/lib/noizu_prompt_lingua_web/controllers/auth_controller.ex:417`) generates a random key, returns the **raw key exactly once** in the response, and persists only a bcrypt hash plus a `key_prefix` for display (`backend/lib/noizu_prompt_lingua/entities/mcp_api_keys.ex` — see `mcp_key_json` serialization at `auth_controller.ex:563-574`: id, label, key_prefix, status, last_used_at, expires_at, toolset_config, inserted_at). Verification on use does a prefix lookup + `Bcrypt.verify_pass` + active/expiry checks + `last_used_at` update (`mcp_api_keys.ex:239-260`). The frontend key page (`frontend/src/app/app/mcp-keys/page.tsx`) shows the new key once (raw in React state only, never persisted) and masks the prefix afterward. Gated by the `LegacyKeys` feature flag per project config. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Logged-in user can mint a new API key for self | Met | `auth_controller.ex:417` `create_mcp_key`; route `router.ex:452-459`; UI `frontend/src/app/app/mcp-keys/page.tsx` |
| Key returned once, only hash stored | Met | bcrypt hash + `key_prefix` stored (`mcp_api_keys.ex`); raw shown once in UI (`page.tsx:157,445`) |
| Cannot retrieve the plaintext key later | Met | `mcp_key_json` (`auth_controller.ex:563-574`) exposes only `key_prefix` |
| Key works against MCP endpoints | Met | `McpKeyAuth` plug (`backend/lib/noizu_prompt_lingua_web/plugs/mcp_key_auth.ex`) verifies raw key via `verify_api_key/1` (`mcp_api_keys.ex:239-260`) |
| Deletion/revocation | Met | key status lifecycle (active/revoked) enforced in `verify_api_key` (`status=="active"`) |

## Gaps / Risks

- Story's literal surface was this repo's Python MCP server; implementation lives in the Elixir backend — correct home given the platform architecture, but the story should be re-pointed.
- Key TTL/`expires_at` is optional; a user can mint a never-expiring key. Consider a default expiry policy.

## BDD Scenario

```gherkin
Feature: Self-service MCP API key minting
  Scenario: User mints a key for a new connector
    Given an authenticated user on the MCP Keys page
    When they click "Create key" and provide a label
    Then the raw key is displayed once with a copy button
    And only its bcrypt hash and key_prefix are stored server-side
    And a later request with that key authenticates via McpKeyAuth
    And the key list shows the masked prefix and last-used time, never the plaintext
```
