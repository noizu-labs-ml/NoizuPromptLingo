# W8 oauth-consent-manifest — INTEGRATION NOTES

Branch: `feat/oauth-consent-manifest` (worktree `staging/npl-w8-oauth`).
Base: `50d7361b0`. Contracts: `staging/TOBOR-CONTRACTS.md` §2/§5.

## What shipped

| File | Change |
|---|---|
| `backend/lib/noizu_prompt_lingua/oauth/consent_manifest.ex` | NEW — `sections/0` (manifest for the consent screen: one section per `tobor` default-package group + expanded tool names) and `narrowing/2` (checkbox params → KeyToolsets-shape `toolset_config`; only BLOCKED entries stored). |
| `backend/lib/noizu_prompt_lingua/mcp/oauth_toolsets.ex` | NEW — per-OAuth-client list filtering. `config_for/1` resolves the client from `ctx.assigns.auth_claims["client_id"]`; `apply_hidden/3` mirrors `KeyToolsets.apply_hidden/3` (flag resolution delegated verbatim to `KeyToolsets.state_from_config/3`). |
| `backend/lib/noizu_prompt_lingua/schema/oauth_client.ex` | `toolset_config :map` field (default `%{}`) + cast. |
| `backend/priv/repo/migrations/20260831010000_oauth_client_toolsets.exs` | `ALTER TABLE oauth_clients ADD COLUMN IF NOT EXISTS toolset_config JSONB NOT NULL DEFAULT '{}'::jsonb` (twin of 20260831000000_mcp_key_toolsets). |
| `backend/test/support/oauth_test_schema.ex` | Column added to test DDL (+ `ADD COLUMN IF NOT EXISTS` for pre-existing test DBs). |
| `backend/lib/noizu_prompt_lingua/oauth/clients.ex` | `update_toolset_config/2` — normalize-on-write via `MCPApiKeys.normalize_toolset/1`; empty narrowing stores `%{}` (= ungated/legacy). |
| `backend/lib/noizu_prompt_lingua_web/controllers/oauth_controller.ex` | `render_consent/5` renders the manifest (sections + per-tool toggles, pre-checked; required core groups locked); `consent/2` approve path calls `capture_narrowing/2` before issuing the code (failure logs, never blocks consent). |
| `backend/lib/noizu_prompt_lingua/mcp/server.ex` | `list_tools/3` chains `OAuthToolsets.apply_hidden/3` after the existing KeyToolsets filter. |

Tests: `backend/test/noizu_prompt_lingua/oauth/consent_manifest_test.exs`,
`backend/test/noizu_prompt_lingua/oauth/client_toolsets_test.exs`,
`backend/test/noizu_prompt_lingua_web/controllers/oauth_consent_test.exs`.

## SINGLE WIRING POINT for F2 (post-merge)

**Execution gating.** W8 captures + persists `oauth_clients.toolset_config` and
enforces it for DISCOVERY (`list_tools`, local filter). EXECUTION enforcement is
F2's job. The single wiring point post-F2-merge:

1. `EffectiveToolset.resolve/4` cascade must add the client tier for OAuth
   tokens. Today the client is resolved in
   `NoizuPromptLingua.MCP.OAuthToolsets.config_for/1` — replace its body with:

   ```elixir
   EffectiveToolset.resolve(scope, %{
     id: client.id, kind: :oauth_client, toolset_config: client.toolset_config
   }, user_ref)
   ```

   (client map shape per TOBOR-CONTRACTS.md §2 `@type client`. The JWT already
   carries `client_id` in `auth_claims`, minted by
   `NoizuPromptLingua.OAuth.TokenService.mint_tokens/1`; user id is
   `auth_claims["sub"]`.)

2. Then swap `NoizuPromptLingua.MCP.Server.list_tools/3`'s
   `OAuthToolsets.apply_hidden/3` call for the `EffectiveToolset`-resolved
   visible/enabled map and delete `oauth_toolsets.ex`
   (flag semantics are identical: absent = enabled + visible).

Note: `KeyToolsets.config_for/1` resolves `auth_claims["api_key_id"]`; for a
token-exchange token carrying BOTH, `list_tools` currently applies key config
then client config (both must allow listing) — F2's unified resolve should
preserve that intersection.

## Compat assessment (standing-consent / silent re-auth)

- `authorize/2`'s silent path (`finish_authorize/5`) is untouched — a standing
  grant issues the code without ever rendering the manifest. Verified by test
  ("existing grant re-authorizes silently").
- Existing client rows: column default `'{}'::jsonb` → `%{}` →
  `OAuthToolsets.config_for/1` returns `nil` → `list_tools` filter is an
  identity no-op. Verified by test.
- `Grants.approve!/4`, `TokenService`, DCR, token/revoke endpoints: unchanged.
- Consent POST: purely additive (`capture_narrowing/2` before `Grants.approve!/4`);
  a `prompt=consent` re-approval overwrites the narrowing with the new decision
  (latest-consent-wins) — no behavioral change for grants that skip consent.
- Consent HTML: manifest block + `.consent-*` CSS classes are additive;
  `html_page/2` is shared with the elevation pages but the new classes/rules
  don't alter their markup.
- `sanitize_params/1` and the session resume flow are unchanged (manifest state
  is rebuilt server-side on POST, not carried through the session).

## Deliberate exclusions

- Root-plane tools (Discovery / NPL) are absent from the manifest — they are
  ungated by design (`KeyToolsets.ungated_category?/1`); consent never promises
  a block it can't enforce.
- Required core groups (`MCPServers.required_ids/0` — sessions, organizations)
  render locked; the normalizer would force-enable them anyway (all_in_one
  typed-confirm semantics, not wired for consent).
- Tool names are stored verbatim from `spec.definition.name` (dotted until F5
  lands; self-consistent between manifest and filter). After F5, re-consent
  refreshes stored names to canonical underscore form.
- Execution gating for `disabled` entries intentionally deferred to F2 (above).
