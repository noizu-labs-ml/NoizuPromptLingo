# INTEGRATION-NOTES.md — F5 underscore-names (branch feat/underscore-names)

Contract: staging/TOBOR-CONTRACTS.md §4 (naming) + §2 (EffectiveToolset keyed by
canonical underscore name — consumed as-is by F2).

## What F5 changed (backend)

| File | Change |
|------|--------|
| `backend/lib/noizu_prompt_lingua/mcp/tool_names.ex` | NEW. `canonical/1`, `alias?/1`, `dotted/1`, `canonical_spec/1`, `canonical_specs/1`. Canonical = underscore; dotted = alias. |
| `backend/lib/noizu_prompt_lingua/mcp/server.ex` | `list_tools/3` normalizes specs to canonical names BEFORE hidden/disabled filtering + pagination — the wire `tools/list` payload never contains dots. |
| `backend/lib/noizu_prompt_lingua/mcp/dispatch.ex` | Name matching via `ToolNames.canonical/1` both sides; matched spec canonicalized so ToolGuard + KeyToolsets + error text see the underscore name. Dotted dispatch works. |
| `backend/lib/noizu_prompt_lingua/tools/catalog.ex` | `resolve_alias/1` now canonicalizes (was identity); `build/2` emits canonical names; `call_hidden_tool/4` canonicalizes specs before find — ToolCall hidden dispatch accepts dotted input. |
| `backend/lib/noizu_prompt_lingua/tools/tool_summary.ex` | `get_tool` resolves alias before catalog match. |
| `backend/lib/noizu_prompt_lingua/tools/tool_search.ex` | text search canonicalizes query so dotted queries match canonical names. |
| `backend/lib/noizu_prompt_lingua/tools/tool_call.ex` | description + `tool` arg description document underscore canonical form; dotted accepted. |
| `backend/lib/noizu_prompt_lingua/mcp/key_toolsets.ex` | `state_from_config` + `overlay_tools` probe tool keys in BOTH spellings (legacy dotted configs keep working against canonical lookups and vice versa). MINIMAL touch only — F2 is restructuring this module; reconcile at merge. |
| `backend/lib/noizu_prompt_lingua/mcp/custom.ex` | `group_specs` config lookups probe both spellings via new `tool_config_entry/2`. MINIMAL touch only — F2 restructures; reconcile at merge. |

## Key design facts for integrators

1. **Tool declarations stay dotted** (27 `use Noizu.MCP.Server.Tool` modules, e.g.
   `name: "Session.Create"`). The dotted registry name is the ALIAS SOURCE;
   canonicalization happens at the emission/dispatch seam, not per-module. Do not
   mass-rename tool modules at integration.
2. **DB config jsonb keys** (`mcp_custom_scopes.config`, `mcp_api_keys.toolset_config`)
   may hold either spelling; both are accepted at lookup. Existing dotted keys need
   no migration. W9/W2 should WRITE canonical underscore keys going forward
   (contract §7: overrides keyed by canonical name).
3. `Catalog.specs/2` intentionally returns RAW specs (dotted names) — it is the
   registry view (`Custom.catalog_specs/1` likewise). Canonical emission is in
   `Catalog.build/2` + `Server.list_tools/3` + `Dispatch.call/4`.

## F5's contract surface for later branches

- W5 Session.Manifest: tool names in the manifest payload MUST be canonical
  (`ToolNames.canonical/1` on whatever EffectiveToolset returns — contract §2
  already keys resolve/2 by canonical name, so pass-through).
- W9 name_override: overrides apply AFTER canonicalization; `name_override` value
  is emitted verbatim (author may pick any legal name), lookups still canonical.
- W8 per-client list_tools: route through `Server.list_tools/3` or re-apply
  `ToolNames.canonical_specs/1` after client-specific filtering.

## Tests

- NEW `backend/test/noizu_prompt_lingua/mcp/tool_names_test.exs` — mapping table
  (canonical/alias?), spec canonicalization, list_tools emits underscore-only,
  dispatch normalization (dotted ≡ canonical, unknown-tool still errors, dotted
  config keys honored).
- Updated emission assertions in `custom_key_toolset_test.exs` +
  `custom_scope_test.exs` (listing/discovery now canonical; dotted input proven
  still accepted at ToolDefinition/ToolHelp).
- Gate: `mix test test/noizu_prompt_lingua/mcp test/noizu_prompt_lingua/tools`
  → 115 + 3 passed (2026-08-31, this worktree).

## Submodule doc updates done

- `docs/arch/mcp-tools.md` — all tool-name tables swept to underscore; naming
  note added at top. (This was the only NPL-repo doc referencing dotted names.)

## Monorepo-level doc updates NEEDED (NOT done here — outside worktree)

Verified by grep 2026-08-31. Dotted NPL tool names ARE present:

1. `/Users/keithbrings/Work/Space/Noizu/CLAUDE.md` line ~30 — `ToolCall(tool: "Session.Create", arguments: {` in the FIRST-ACTION session-registration snippet → change to `"Session_Create"`.
2. `/Users/keithbrings/Work/Space/Noizu/AGENTS.md` line ~35 — same snippet, same change.
3. `Portfolio/skills/` (skills submodule — sweep to underscore form):
   - `foreman/` (12 files), `team-member/` (6), `persona-session/` (6), `qa-engineer/` (2), `agentic-project-manager/` (2), `prompt-optimizer/` (2), `pubsub-monitor/` (1).
   - Grep: `\b(Session|Project|Organization|Ticket|Task|Key|Client|Wiki|Chat)\.[A-Z][a-z]`.
   - Skills keep working pre-sweep (dotted = alias at dispatch).
4. `staging/TOBOR-CONTRACTS.md` — already canonical; no change.
5. Memory files under `~/.claude/.../memory/` quoting dotted NPL tool names — low priority, aliases keep resolving.

---

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
