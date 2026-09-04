# PRD-N1: Manifest / Serving Parity

**Series**: NPL last-mile (N1 of 6) — see [INDEX-NPL.md](./INDEX-NPL.md)
**Repo**: `Portfolio/Apps/AI/NoizuPromptLingo` (all anchors relative to `backend/` unless prefixed)
**Gate**: NONE — starts now on hex 0.1.5 (`mix.exs:99`, `mix.lock:59`); zero lib deps; merges straight to NPL `main`
**Branch**: `feat/n1-parity` (worktree from the submodule's own `.git`)
**Depends on**: nothing. Blocks nothing, but N2a/N4a build on its write-site conventions.
**Status**: Draft
**Anchor verification**: all `file:line` below verified against `develop.q3 @ cbec5d6ba`, 2026-09-01

---

## 1. Goal

Close the R6 defect class on the LEGACY serving path (no lib changes, no dep change):

1. `Session_Manifest` reports the same surface the server actually serves — `client_for/1` delegates to `EffectiveToolset.client_for_ctx/1`, and every manifest entry carries an `included:` flag marking membership in the served universe.
2. Config edits propagate to live connections: scope / API-key / OAuth-client toolset writes fire `notify_changed(:tools)` + `ToolsetCache.bump/0`.
3. The client-permissions editor states its narrowing-only semantics in the UI.
4. A parity regression test pins manifest == served == applied-specs so the class cannot silently return.

Incident being closed: client `tobor-ce56171f6764` — save landed on the client layer (narrowing-only, `effective_toolset.ex:70` + `:152-157`), 14 tools served, manifest over-reported ~270 because `client_for/1` (`session_manifest.ex:157`, OAuth branch `toolset_config: nil` at `:167-174`) ignores the W8-era `oauth_clients.toolset_config` (`schema/oauth_client.ex:23`).

---

## 2. Decisions applied (INDEX-NPL §3)

- Decision 6 gate: runs on hex 0.1.5; `notify_changed/1` already exists there (generated per server module, `deps/noizu_mcp/lib/noizu/mcp/server.ex:177`).
- Decision 7: `notify_changed` call sites land in NPL context modules — FINAL home; the lib `Store` notify chain never fires for NPL admin writes (re-asserted at N5).
- D1 (one resolver): the parity test asserts manifest follows the SAME cascade the serving path uses (`EffectiveToolset`), not a second implementation.
- The `client_for` DELEGATION is explicitly transitional: it retires at N5 when `Session_Manifest` is rewritten over `Toolset.permissions/3` (PRD-N5 FR-5-6).

---

## 3. Current state (verified anchors)

| Concern | Anchor | Behavior today |
|---|---|---|
| Manifest generation | `mcp/session_manifest.ex:32` `generate/2` | Enumerates registered specs; emits `%{tools: [%{name, group, enabled, visible, expires_at}], generated_at}`; `Map.get(states, name) || %{}` defaults absent ⇒ enabled+visible over the FULL catalog |
| Client resolution | `mcp/session_manifest.ex:157` `client_for/1` | API keys ⇒ loads `toolset_config` (`:178-186`); OAuth clients/anonymous ⇒ `toolset_config: nil` (`:167-174`) — stale pre-W8 |
| Serving cascade | `mcp/effective_toolset.ex:478` `client_for_ctx/1` | THE real resolution: reads BOTH scope config and the active client's stored `toolset_config` (`:473-496` region incl. revoked/unknown ⇒ nil, empty-narrowing handling) |
| Narrowing semantics | `mcp/effective_toolset.ex:70`, `:152-157` `include_groups/2` | Scope present ⇒ scope groups govern; clients only flip flags; clients never ADD tools |
| Per-tool application | `mcp/effective_toolset.ex:385` `apply_state/2`, `:419` `apply_to_specs/3` | Applies resolved state onto specs (the "served" transform) |
| Served universe (dynamic server) | `mcp/custom.ex:39` `custom_specs/1` | Spec list for the `tobor_custom` include-set server |
| Cache | `mcp/toolset_cache.ex:61` `bump/0` (`fetch/1` `:31`, TTL 45s `:82`) | Node-local generation bump |
| Notification primitive | `deps/noizu_mcp/.../server.ex:177` `notify_changed/1` | Per-server session cast → `notifications/tools/list_changed` |
| Scope writes | `mcp_custom_scopes.ex:737` `create/1`, `:756` `update/3` (slug clause `:787`) | NO propagation of any kind |
| API-key writes | `entities/mcp_api_keys.ex:33` `generate_api_key/3`, `:80-91` `update/2,3`, `:126` `clone/2` | NO propagation |
| OAuth-client writes | `oauth/clients.ex:153` `update_toolset_config/2` | NO propagation |
| MCP-tool-driven key writes | `mcp/keys/tools/key_create.ex:63`, `mcp/keys/tools/key_update.ex:75` | Delegate to `MCPApiKeys` context — covered transitively by context-level hooks |
| Manifest tests | `test/noizu_prompt_lingua/mcp/session_manifest_test.exs` | Exists; extended by this PRD |

Grep fact: ZERO `notify_changed` call sites exist anywhere in `lib/noizu_prompt_lingua` or `lib/noizu_prompt_lingua_web` today. N1 introduces the first ones, in contexts only.

---

## 4. Public surface

### 4.1 NEW `mcp/toolset_changes.ex` — `NoizuPromptLingua.MCP.ToolsetChanges`

```elixir
defmodule NoizuPromptLingua.MCP.ToolsetChanges do
  @server_modules [
    # Compile-time literal list of EVERY module that does
    # `use NoizuPromptLingua.MCP.Server` under lib/noizu_prompt_lingua/mcp/**.ex
    # (the domain servers + Custom + Projects + Sessions + Organizations + Clients...).
  ]

  @doc """
  Fan out surface-change propagation after ANY toolset-affecting write:
  each server module's generated notify_changed(:tools) (casts its live
  sessions → notifications/tools/list_changed), then ToolsetCache.bump/0.
  Never raises: a down server only logs — the write already succeeded (D5).
  """
  @spec notify_tools() :: :ok
end
```

### 4.2 CHANGED `mcp/session_manifest.ex`

- `client_for/1` body becomes a delegation: `EffectiveToolset.client_for_ctx(ctx)` (shape-compat shim: the returned `%{id, kind, toolset_config}` is adapted if `client_for_ctx/1` returns its native shape — adapt, do not re-implement the lookup).
- `generate/2` tool entries gain `included: boolean` (see FR-1-2). Output shape otherwise UNCHANGED (`%{tools: [...], generated_at}`; existing keys keep names/positions — client-facing contract).

### 4.3 CHANGED write sites (one line each, context layer only)

`MCPCustomScopes.create/1` (`:737`), `MCPCustomScopes.update/3` (`:756` — both clauses, incl. `:787`), `MCPApiKeys.generate_api_key/3` (`:33`), `MCPApiKeys.update/3` (`:80`, both clauses), `MCPApiKeys.clone/2` (`:126`), `OAuth.Clients.update_toolset_config/2` (`oauth/clients.ex:153`) — each fires `ToolsetChanges.notify_tools/0` AFTER the commit succeeds.

### 4.4 CHANGED frontend

`frontend/src/components/kit/tool-toggles-grid.tsx` gains an optional `narrowingOnly?: boolean` prop rendering the label "narrowing only — clients never ADD tools"; enabled where the grid edits a CLIENT's `toolset_config` (admin client-toolset editor in `mcp-custom-scopes` page + any client-permissions surface). Scope-layer editors do NOT set it.

---

## 5. Functional requirements

**FR-1-1 `client_for/1` delegation.**
- Given any ctx (API-key claims, OAuth-client claims, anonymous).
- When `Session_Manifest.client_for(ctx)` runs.
- Then the returned client record reflects exactly what `EffectiveToolset.client_for_ctx/1` (`:478`) resolves — in particular an OAuth client WITH a stored non-empty `toolset_config` (`oauth_clients.toolset_config`, W8) yields that config, and the stale hardcoded `toolset_config: nil` branch (`session_manifest.ex:167-174`) no longer exists in the file.
- Given a revoked/unknown client id, behavior matches `client_for_ctx/1` (ungated/nil per `:496`).

**FR-1-2 `included:` flag universe.**
- Given `generate/2` output.
- When the ctx is scope-bound (a scope participates in the `EffectiveToolset` cascade).
- Then every tool entry carries `included: true` iff its canonical name is a member of `Custom.custom_specs/1` (`mcp/custom.ex:39`) for that ctx — i.e. membership in the SERVED universe — and `included: false` otherwise; `enabled`/`visible` keep their per-tool state semantics (a tool may be `included: true, enabled: false`).
- When the ctx has no scope (root/global enumeration), then every enumerated entry carries `included: true` (the global enumeration IS the root universe) — the enumeration itself does not change.
- Given any two entries with the same canonical name (dotted alias collapse via `canonical_name/1` `:61`), they do not disagree on `included`.

**FR-1-3 Propagation helper.**
- `ToolsetChanges.notify_tools/0` calls `notify_changed(:tools)` on EVERY module in `@server_modules` (wrapped in `try/rescue/catch` — log `:warning`, continue), then `ToolsetCache.bump/0` (`toolset_cache.ex:61`).
- `@server_modules` is complete: a source-level guard test greps `lib/noizu_prompt_lingua/mcp/**.ex` for `use NoizuPromptLingua.MCP.Server` and fails if any module is missing from the list (pattern of the AP grep-guards; superseded by the lib-path rewrite at N5, where the helper itself retires into `Store`-side notify semantics for NPL contexts per Decision 7 — the CONTEXT call sites survive, the list lives until the lib `notify_changed` contract replaces it).

**FR-1-4 Write-site propagation.**
- Given each write fn in §4.3 completes successfully (row committed).
- When it returns.
- Then `ToolsetChanges.notify_tools/0` has been invoked exactly once for that logical write (batch callers — e.g. the MCP tools `key_create`/`key_update` that delegate to the context — get ONE fan-out via the context, not one per row).
- Given a write FAILS (changeset error, raise), then no notification fires.
- Notification failure never fails the write (FR-1-3 never raises).

**FR-1-5 Frontend narrowing label.**
- Given the client toolset editor (`tool-toggles-grid.tsx` with `narrowingOnly`).
- When rendered.
- Then the label "narrowing only — clients never ADD tools" is visible adjacent to the toggles; scope-layer editors (scope config editor on `mcp-custom-scopes/page.tsx`) render without it.

**FR-1-6 Legacy endpoints unchanged.**
- `/custom/:slug/mcp`, `/org/:org_slug/custom/:slug/mcp`, `/user/:slug/mcp`, bare `/mcp` (router `:352/:361/:369/:372`) — listing/dispatch behavior is byte-identical except that config edits now propagate. No route, controller, or `EffectiveToolset` cascade semantics change in this PRD.

---

## 6. Acceptance criteria

**AC-N1-1 (incident closure, offline)** — For a fixture OAuth client mirroring `tobor-ce*` (14 enabled tools via client `toolset_config` narrowing over a 270-tool catalog): `Session_Manifest.generate/2` reports `included: true` for exactly the 14, `included: false` for the rest; the served listing (`EffectiveToolset.apply_to_specs/3` survivors, `:419`) has the same 14 names. Manifest count == served count.

**AC-N1-2 (API-key path)** — Same parity holds for an API-key caller with `toolset_config` narrowing (exercises the `:178-186` legacy lookup through the new delegation).

**AC-N1-3 (anonymous / no-scope)** — Root ctx manifest: all entries `included: true`; shape otherwise unchanged vs. pre-PRD snapshot (existing `session_manifest_test.exs` cases stay green unmodified or updated ONLY for the new key).

**AC-N1-4 (propagation e2e)** — With a test-session sink attached to a fixture server module: `MCPCustomScopes.update/3` on a scope config ⇒ the sink records `notifications/tools/list_changed` AND `ToolsetCache` generation increments (a cached `fetch/1` entry loaded before the write misses after). Repeated for `MCPApiKeys.update/3` and `OAuth.Clients.update_toolset_config/2`.

**AC-N1-5 (write-failure isolation)** — A failing scope update (invalid attrs) fires zero notifications; a server module whose session registry is down does not prevent the write from returning ok.

**AC-N1-6 (guard)** — The `@server_modules` completeness guard passes; adding a fixture `use NoizuPromptLingua.MCP.Server` module without registering it FAILS the guard (negative check in the same test file).

**AC-N1-7 (UI)** — Component test: `tool-toggles-grid` with `narrowingOnly` renders the label; without it, does not.

**AC-N1-8 (regression suite)** — `session_manifest_parity_test.exs` (§7) green; full scoped suite (`session_manifest_test.exs`, `effective_toolset*_test.exs`, `custom_scope_test.exs`, `scope_packaging_test.exs`, `custom_key_toolset_test.exs`, `key_toolsets_test.exs`) green.

---

## 7. Test plan

New/changed under `backend/test/`:

- **`noizu_prompt_lingua/mcp/session_manifest_parity_test.exs`** (NEW) — the AC-N1-1/2/3 matrix: for ctx ∈ {api_key, oauth_client, anonymous} × {scope, no-scope}: manifest `included:true` names == `Custom.custom_specs/1` names == `EffectiveToolset.apply_to_specs/3` survivor names. Includes the 14-of-270 incident fixture.
- **`noizu_prompt_lingua/mcp/session_manifest_test.exs`** (EXTEND) — `client_for/1` delegation cases: OAuth client with stored config / empty config / revoked id; delegation identity (monkeypatch-free: assert equality with `EffectiveToolset.client_for_ctx/1` output for the same ctx).
- **`noizu_prompt_lingua/mcp/toolset_changes_test.exs`** (NEW) — fan-out: notify reaches each listed module (test sink), bump increments generation, failure isolation, write-failure no-op, `@server_modules` completeness guard (AC-N1-4/5/6).
- **`noizu_prompt_lingua/mcp/custom_scope_test.exs`** (EXTEND) — update/create fire `notify_tools/0` exactly once (assert via `ToolsetCache` generation delta, avoiding per-module sinks).
- **`noizu_prompt_lingua/oauth/client_toolsets_test.exs`** (EXTEND) — `update_toolset_config/2` fires propagation.
- **frontend component test** alongside `tool-toggles-grid.tsx` (project's existing component-test lane) — AC-N1-7.

Run scoped: `mix test test/noizu_prompt_lingua/mcp/ test/noizu_prompt_lingua/oauth/client_toolsets_test.exs` (+ frontend lane).

---

## 8. Compat & rollback

- Additive-only on hex 0.1.5: `notify_changed/1` and `ToolsetCache.bump/0` both exist today; no dep change; no route change.
- Manifest output GAINS a key (`included`). Known consumers of `Session_Manifest` output: the Discovery-plane tools and admin UI. Audit consumers during implementation; unknown external consumers see an additive key only.
- Rollback: revert the single PR. No data, no migrations, no config.
- The `client_for` delegation and the `@server_modules` list are BOTH transitional and are explicitly retired/re-homed at N5 (flip) — tracked in PRD-N5 §7 retirement ledger so they cannot linger.

---

## 9. Out of scope

- Fresh-JWT-claims-per-request (old baseline 3.1 second-order item) — absorbed by lib PRD-2 per-request claims transport; lands with N3's `principal_mapper`.
- Any set-layer work (N2+), any router change, any lib change.
- Cross-node notification hardening (PubSub broadcast) — noted in N6 as optional hardening; `ToolsetCache.bump/0` stays node-local with the 45s TTL backstop (`toolset_cache.ex:82`).

---

## 10. Open questions

1. **Manifest `included` for non-scope key-gated listings** — root/static subdomain listings are key-gated, never template-gated (`effective_toolset.ex:152-157`). Spec keeps `included: true` there (enumeration == universe). Confirm no consumer needs client-narrowing reflected as `included: false` in ROOT manifests (it does not: client narrowing at root is enforced per-request by the cascade, and the manifest tool itself is per-caller).
2. **`ToolsetChanges` module placement** — spec puts it at `mcp/toolset_changes.ex`; alternative `mcp/propagation.ex`. Cosmetic; implementer picks one and updates this PRD.
3. Should `MCPCustomScopes` DELETION paths (if any exist beyond `update`) propagate? Spec: any fn that mutates a scope/config row propagates; implementer enumerates via grep and lists them in the PR description.

---

## 11. File change map

| File | Change |
|---|---|
| `backend/lib/noizu_prompt_lingua/mcp/toolset_changes.ex` | NEW (§4.1) |
| `backend/lib/noizu_prompt_lingua/mcp/session_manifest.ex` | `client_for/1` delegation; `generate/2` `included:` flag |
| `backend/lib/noizu_prompt_lingua/mcp_custom_scopes.ex` | notify hooks at `:737`/`:756`/`:787` |
| `backend/lib/noizu_prompt_lingua/entities/mcp_api_keys.ex` | notify hooks at `:33`/`:80`/`:126` |
| `backend/lib/noizu_prompt_lingua/oauth/clients.ex` | notify hook at `:153` |
| `frontend/src/components/kit/tool-toggles-grid.tsx` | `narrowingOnly` prop + label |
| `frontend/src/app/app/admin/mcp-custom-scopes/page.tsx` (client editor region) | pass `narrowingOnly` for client-layer editors |
| Tests | §7 list |
