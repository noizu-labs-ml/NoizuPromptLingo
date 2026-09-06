# PRD-N5: PRD-5 Adoption + Hex Flip

**Series**: NPL last-mile (N5 of 6) — see [INDEX-NPL.md](./INDEX-NPL.md)
**Repo**: `Portfolio/Apps/AI/NoizuPromptLingo` (anchors relative to `backend/`)
**Gate**: **hex 0.3.0 PUBLISHED** (user-run, 2FA OTP — agents never publish, never touch hex keys). Precondition chain: lib PRD-1..4 merged on lib `main` @ `@version "0.3.0"` → N6a staging soak green (PRD-N6 §7) → user publishes → THEN this PRD's flip commits land on `feat/tool-sets-integration` → merge train to NPL `main`.
**Branch**: `feat/n5-flip` (cut from the integration branch; carries the flip commit)
**Normative references**: lib **PRD-5** (`Portfolio/Libs/ai/elixir-mcp/project-management/PRDs/PRD-5-npl-migration.md`) is the normative migration spec — NPL-side execution order was split across N2b (providers, done), N3 (mapper/resolver, done), and THIS PRD (flip + retirement + conformance). Where this PRD and lib PRD-5 overlap, lib PRD-5 governs shapes; this PRD governs sequencing and the retirement ledger.
**Status**: Draft

---

## 1. Goal

Move NPL wholesale onto the lib 0.3.0 toolset stack and delete the out-of-tree engine:

1. `use NoizuPromptLingua.MCP.Server` STOPS emitting `handle_call_tool/3` / `handle_list_tools/2`; every server serves through the lib's protocol-generated defaults carrying `toolset:` / `principal:` / `providers:` / `toolset_cache:` opts (authored since N2b/N3).
2. `Session_Manifest` rewritten over `Toolset.permissions/3` + `metadata/3` — output shape UNCHANGED.
3. `Custom` (`tobor_custom`) becomes provider-backed `%Toolset.Custom{}`.
4. The NPL test matrices port as `_conformance` suites proving behavior parity; new set-layer conformance retargets the N1 parity suite.
5. RETIRE the legacy engine (§7 ledger) — including the legacy `insufficient_authorization` envelope (**wire delta #1**, Decision 3) and dotted wire aliases (**wire delta #2**).
6. Dep flip to `{:noizu_mcp, "~> 0.3.0"}` as the FINAL commit of the train.

---

## 2. Decisions applied (INDEX-NPL §3)

- **Decision 1**: single publish already happened; the flip commit swaps `path:` → hex.
- **Decision 2**: providers over NPL tables — PERMANENT; zero-writes guard re-asserted post-flip.
- **Decision 3 (wire delta #1)**: destructive-tool step-up = MCP-level `forbidden` carrying `negotiation.metadata.elevation_uri`; the legacy `insufficient_authorization` tool-result envelope (`mcp/dispatch.ex:36-45`) DIES HERE; new shape asserted in `key_toolset_guard_conformance_test.exs`; both deltas CHANGELOG-noted (with N6 docs).
- **Decision 4**: profiles stay immutable `%Toolset.Custom{}` structs (built since N2b); registry-derived membership unchanged.
- **Decision 7**: `ToolGuard` STAYS — re-homed as the policy source invoked BY `AclProvider.check_all/5` (deny = weight 300). `notify_changed` context call sites (N1) are the FINAL home — they survive the flip unchanged.
- **D1**: after the flip there is NO NPL-side resolution engine — listing/dispatch/manifest/Catalog all consume the lib protocol through the providers.
- **Rollback doctrine**: pre-flip = drop the branch (production stays hex 0.1.5). Post-flip = revert the flip merge commit — all legacy DELETIONS live only in it, so the revert is atomic and restores the old engine byte-for-byte. Lib 0.3.0 is immutable; fixes ship as 0.3.1 (lib PRD-4 §10).

---

## 3. Current state entering N5 (delivered by N1-N4b)

| Artifact | State |
|---|---|
| `mcp/toolset_provider.ex`, `mcp/acl_provider.ex` | N2b, wired as `providers:` opts on the N3 endpoint fixture only |
| `mcp/toolsets/profiles.ex` | N2a data + `@profile_groups`; N2b `custom/1` structs |
| `mcp/principal_mapper.ex`, `mcp/toolset_resolver.ex`, `mcp/tool_set_endpoint.ex` | N3; endpoint bridge is TRANSITIONAL |
| `mcp/session_manifest.ex` | N1 state: `client_for/1` DELEGATES to `EffectiveToolset.client_for_ctx/1`; `included:` flag from `custom_specs/1` |
| `mcp_custom_scopes.ex`/`entities/mcp_api_keys.ex`/`oauth/clients.ex` | N1 notify hooks (FINAL home — survive) |
| Legacy engine alive | `mcp/dispatch.ex`, `mcp/effective_toolset.ex`, `mcp/effective_toolset/behaviour.ex`, `mcp/toolset_cache.ex`, `mcp/toolset_config.ex`, `mcp/key_toolsets.ex`, `mcp/window.ex`, `mcp/legacy_keys.ex`, base-macro `handle_*` emissions in `mcp/server.ex` (`__using__` quote, `handle_call_tool` ~`:27-30`, `handle_list_tools` ~`:32-35`) |

---

## 4. Public surface changes

### 4.1 `mcp/server.ex` — base-macro flip (lib PRD-5 §6.5)

- DELETE the emitted `def handle_call_tool/3` and `def handle_list_tools/2` from `__using__`'s quote.
- EMIT in their place: `use Noizu.MCP.Server, unquote(opts) ++ [toolset: {NoizuPromptLingua.MCP.ToolsetResolver, :resolve, []}, principal: {NoizuPromptLingua.MCP.PrincipalMapper, :from_claims, []}, providers: [persistence: NoizuPromptLingua.MCP.ToolsetProvider, acl: NoizuPromptLingua.MCP.AclProvider], toolset_cache: true]` (per-server `opts` still merge in; hosts may override individual keys).
- Registration-time name canonicalization: feed `__mcp__(:tools)` through `ToolNames`-equivalent canonicalization pre-expansion so wire names are underscore-canonical; `ToolNames` (`mcp/tool_names.ex`) STAYS as the canonicalizer. **Dotted wire aliases retire (wire delta #2)** — lib resolves exact canonical names only (lib PRD-1 §4.4).

### 4.2 `mcp/session_manifest.ex` — rewrite (lib PRD-5 §6.7)

- `generate/2` over `Toolset.permissions/3` (effective visible/callable per caller) + `Toolset.metadata/3`; `expires_at` column populated via ONE `Store.list(:grant, ...)`-equivalent read (`Noizu.MCP.Store.list("toolset_grants", %{toolset_slug: ..., authenticator: ..., subject: ...})`) — keeps lib `permissions/3` shape frozen (lib PRD-5 Q4 resolution).
- Output shape UNCHANGED: `%{tools: [%{name, group, enabled, visible, included, expires_at}], generated_at}` (`included` from N1 stays).
- `client_for/1` DELETES the N1 delegation — identity now flows from `ctx.auth` (`%Principal{}`); `included` derives from the composed catalog of the resolved toolset, not `custom_specs/1`.

### 4.3 `mcp/custom.ex` — provider-backed (lib PRD-5 §6.10)

- `tobor_custom` refactors to a `%Toolset.Custom{}` resolved from the provider record; scope slug rides `Principal.metadata[:custom_scope_slug]` (mapper copies it — lib PRD-5 §10 Q3 resolution; N3's route metadata pattern generalizes). `custom_specs/1` remains only as a thin delegate (or retires if no other consumer remains — grep-decided, recorded in the PR).
- Discovery tools unchanged.

### 4.4 Retirements + stays — see §7 ledger (normative).

---

## 5. Functional requirements

**FR-5-1 Base-macro flip.** After the flip, `NoizuPromptLingua.MCP.Server.__using__` emits NO `handle_call_tool`/`handle_list_tools`; a source-level test greps `mcp/server.ex` for the emissions and fails if present (AP-12 family). Every NPL server's listing/dispatch flows through the lib defaults with the four opts; a server-level fixture proves `tools/list` and `tools/call` honor the resolver's toolset per principal.

**FR-5-2 N3 bridge deletion.** `mcp/tool_set_endpoint.ex` is DELETED; the set gateway (`mcp_set_gateway_controller.ex`) serves through the SAME base-macro defaults now carried by every server (the gateway binds a server whose opts already resolve the set — `ToolsetResolver` reads route metadata identically). Routes/URLs/audience gates (N3) unchanged.

**FR-5-3 Manifest rewrite.** `Session_Manifest.generate/2` consumes `Toolset.permissions/3` + `metadata/3` + one grant-list read; shape unchanged (§4.2); the N1 parity suite re-targets: manifest `included: true` == served `tools/list` == `Toolset.catalog/3` entries (scope AND set endpoints). The `client_for` delegation from N1 no longer exists.

**FR-5-4 Provider-backed custom.** `tobor_custom` serves the same surface through the provider path — `custom_key_toolset_conformance` proves parity (same fixtures, same outputs).

**FR-5-5 Conformance ports (lib PRD-5 §7, renamed `_conformance`).** Each original test file ports under the SAME fixtures exercised through the lib stack (provider + resolver + protocol), asserting BEHAVIOR PARITY:

| Original (verified paths, `backend/test/noizu_prompt_lingua/`) | Conformance port |
|---|---|
| `mcp/effective_toolset_test.exs` | `mcp/effective_toolset_conformance_test.exs` |
| `mcp/effective_toolset_acl_test.exs` | `mcp/effective_toolset_acl_conformance_test.exs` |
| `mcp/effective_toolset_matrix_test.exs` | `mcp/effective_toolset_matrix_conformance_test.exs` |
| `mcp/key_toolset_guard_test.exs` | `mcp/key_toolset_guard_conformance_test.exs` — asserts the NEW step-up shape: `forbidden` + `negotiation.metadata.elevation_uri`; the legacy `insufficient_authorization` envelope MUST NOT appear (wire delta #1) |
| `oauth/client_toolsets_test.exs` | `oauth/client_toolsets_conformance_test.exs` |
| `mcp/custom_key_toolset_test.exs`, `mcp/key_toolsets_test.exs`, `mcp/toolset_cache_test.exs` | `_conformance` ports (custom sets through provider; cache-policy parity — reconcile TTL with lib default, N3 §10.4) |
| `noizu_prompt_lingua_web/controllers/mcp_key_toolset_rest_test.exs` | REST surface unchanged (stays, may rename only if handlers move) |

**FR-5-6 Set-layer conformance.** NEW `mcp/tool_sets_conformance_test.exs`: the N3 `tool_set_endpoint_test.exs` cases (enum-prune e2e, canonical dispatch, wire-key args, `forbidden`+elevation, audience gates) re-hosted on the flipped base-macro path — same fixtures, zero bridge.

**FR-5-7 Retirement ledger (§7) executed.** Every RETIRE artifact is deleted; every STAY artifact is verifiably re-homed; grep-guards (FR-5-8) lock the state.

**FR-5-8 Anti-pattern grep-guards (lib PRD-5 §7).**
- **AP-12**: `effective_toolset|defp run_spec|ToolGuard.before_call` must NOT reappear under `backend/lib` (the lib path is the only dispatch path; `ToolGuard` survives ONLY as functions invoked BY `AclProvider` — the guard's regex accounts for its re-homed module, agreed spelling recorded in the test).
- **AP-13**: handlers read identity ONLY via `ctx.auth`; `assigns[:auth_claims]` / `assigns[:mcp_auth_claims]` reads outside `principal_mapper.ex` forbidden (grep-guard).
- **AP-14**: Catalog tool + `Session_Manifest` reflect ACL denies identically to `tools/list`/`tools/call` (behavioral test at NPL scale).

**FR-5-9 Zero-writes re-assertion.** `zero_writes_guard_test.exs` (N2b) runs green against the flipped stack (full conformance run ⇒ zero rows in `noizu_mcp_toolset*`).

**FR-5-10 Dep flip.** Final commit: `backend/mix.exs:99` → `{:noizu_mcp, "~> 0.3.0"}`; `mix deps.update noizu_mcp`; the FULL conformance suite + REST tests green AGAINST HEX (not the path dep). The path dep commit never merges to `main`.

**FR-5-11 Legacy window/legacy-keys data paths.** `mcp/window.ex` expiry semantics and `mcp/legacy_keys.ex` fallbacks fold into the provider (grant `expires_at`; authenticator tags like `:api_key_legacy` per lib PRD-5 §5 row 8) — legacy KEYS keep their distinct grants; no key rotation, no data migration.

**FR-5-12 Elevation negotiation records.** At consent-request time, NPL writes `metadata.elevation_uri` into the negotiation record (lib PRD-4 §4.5 passthrough) — the write path replaces `ToolGuard`'s in-result URI transport (`tool_guard.ex:219` env config stays as the URI SOURCE); destructive tools gated through negotiations behave per FR-5-5's conformance row.

---

## 6. Acceptance criteria

**AC-N5-1** Post-flip, a bare `use NoizuPromptLingua.MCP.Server` server lists+dispatches through the lib path honoring per-principal toolsets (resolver matrix: api-key / oauth / set-bound / profile-bound / none ⇒ correct surfaces through ONE server module).

**AC-N5-2** All conformance ports green on the same fixtures as their originals (parity by construction; originals deleted in the SAME merge train that lands the ports — never both present on `main`).

**AC-N5-3** `key_toolset_guard_conformance`: hidden tool call ⇒ `invalid_params` identical-to-absent; visible-but-scope-gated ⇒ `forbidden` with required/missing scopes + `elevation_uri`; allowed tools execute with original-atom args. NO `insufficient_authorization` string anywhere in the wire path (grep + behavioral assertion).

**AC-N5-4** Manifest parity re-target green (FR-5-3) for scope AND set endpoints; manifest output shape identical to N1-era fixtures modulo the identity source.

**AC-N5-5** Set endpoints serve post-bridge-deletion with byte-identical `tools/list` output vs. N3 fixtures (snapshot).

**AC-N5-6** Dotted-alias retirement: a dotted tool name in `tools/call` ⇒ unknown-tool error; canonical underscore name ⇒ dispatches (wire delta #2). `tool_names_test.exs` updated for registration-time canonicalization.

**AC-N5-7** Retirement ledger: §7 RETIRE list absent from `backend/lib` and `backend/test`; STAY list present with re-homed call sites; AP-12/13/14 guards green.

**AC-N5-8** Zero-writes guard green post-flip (FR-5-9).

**AC-N5-9** Full suite green against HEX `~> 0.3.0` (FR-5-10) — CI proves the hex resolution, not the path dep.

**AC-N5-10** `tobor_custom` conformance green; Discovery tools unchanged.

---

## 7. Retirement ledger (normative)

### RETIRE (deleted in the flip merge train — all deletions land in/with the flip commit so the revert is atomic)

| Artifact | Replaced by |
|---|---|
| `mcp/dispatch.ex` (incl. `run_spec` private copy + `insufficient_authorization` envelope `:36-45`) | lib `protocol_call`/`invoke/5`; step-up via negotiations (FR-5-12) |
| `mcp/effective_toolset.ex` + `mcp/effective_toolset/behaviour.ex` | lib `Toolset` protocol + provider layers |
| Base-macro `handle_call_tool`/`handle_list_tools` emissions (`mcp/server.ex` quote) | lib generated protocol defaults (FR-5-1) |
| `mcp/tool_set_endpoint.ex` (N3 bridge) | base-macro opts on every server (FR-5-2) |
| `mcp/custom.ex` LEGACY path (`custom_specs/1` engine internals) | provider-backed `%Toolset.Custom{}` (FR-5-4; thin delegate survives only if grep finds consumers) |
| `mcp/toolset_cache.ex` | lib `Toolset.Cache` via `toolset_cache: true` (TTL reconciled per N3 §10.4) |
| `mcp/toolset_config.ex` | provider translation at resolution time (FR-5-11) |
| `mcp/key_toolsets.ex` | provider grants store + resolver binding |
| `mcp/window.ex` | grant `expires_at` via provider expiry invariant |
| `mcp/legacy_keys.ex` | `PrincipalMapper` authenticator tags (FR-5-11) |
| N1 `client_for` delegation + `ToolsetChanges.@server_modules` list | `ctx.auth` identity; lib Store/context notify split (context notify hooks SURVIVE — Decision 7) |
| 9 original test files (§5 table left column) | their `_conformance` ports |

### STAYS (re-homed)

| Artifact | New role |
|---|---|
| `mcp/tool_guard.ex` | policy source invoked BY `AclProvider.check_all/5` — deny = weight-300 layer (Decision 7); elevation_uri source for negotiation records (FR-5-12) |
| `mcp/tool_names.ex` | registration-time canonicalizer (wire delta #2) |
| `mcp/dual_token_verifier.ex` | transport verification feeding `PrincipalMapper` |
| `mcp/session_manifest.ex` | REWRITTEN (§4.2), shape unchanged |
| `mcp/custom.ex` | refactored provider-backed (§4.3) |
| `mcp/urls.ex` | unchanged + N3 builders |
| `mcp/tool_guard_test.exs`, `tool_names_test.exs`, `urls_test.exs`, `session_manifest_parity_test.exs` (re-targeted), `zero_writes_guard_test.exs` | updated, not retired |

---

## 8. Flip-to-hex checklist (normative order — lib PRD-5 §9 + plan §3 N5)

1. Lib `main`: PRD-1..4 merged; `@version "0.3.0"`; cumulative suite green.
2. **N6a soak GREEN** (PRD-N6 §7: live checks 1/3/5 in staging against lib `main` via path dep) — gate for the publish.
3. **USER-RUN** (2FA OTP): `cd Portfolio/Libs/ai/elixir-mcp && mix hex.publish`; verify hex shows 0.3.0 + docs/links; tag `v0.3.0`. Agents NEVER run this.
4. NPL `feat/n5-flip`: full conformance suite green against the path dep first (fast iteration), then execute the flip: retire ledger (§7), conformance ports, manifest rewrite, custom refactor, base-macro flip.
5. Dep flip commit: `{:noizu_mcp, "~> 0.3.0"}`; full suite green AGAINST HEX.
6. Merge train to NPL `main` (integration branch + flip, sequential, scoped tests at each step; land once green).
7. Monorepo gitlink update (worktree-based, per standing rules).
8. CHANGELOG: BOTH wire deltas (§9) + provider/topology notes (N6 docs carry the full write-up).
9. Staging smoke (with N6b): `effective_toolset_matrix_conformance` + `client_toolsets_conformance` + set-endpoint smoke against the session-domain server and `tobor_custom`.

**Rollback**: pre-flip = drop `feat/tool-sets-integration` + `feat/n5-flip` (production stays hex 0.1.5, untouched). Post-flip = `git revert` the flip merge commit on NPL `main` — all deletions live in that commit, so the legacy engine returns atomically; lib 0.3.0 stays published and harmless; fixes as lib 0.3.1.

---

## 9. Compat — the two deliberate wire deltas (CHANGELOG-mandatory)

1. **Step-up envelope (Decision 3)**: legacy `insufficient_authorization` tool-result (`dispatch.ex:36-45`) → MCP-level `forbidden` error, data `%{tool, required_scopes, missing, negotiation: %{id, metadata}}`, `metadata.elevation_uri` present when NPL recorded it. Clients complete elevation via NPL's existing REST/consent endpoints, then re-call.
2. **Dotted-alias retirement**: wire resolves canonical underscore names only; `ToolNames` canonicalization moved to registration time.

Both asserted in conformance suites (FR-5-5/5-6); both documented in N6's PROJ-ARCH/CHANGELOG pass. NO other client-visible deltas: manifest shape unchanged, REST surfaces unchanged, legacy routes/keys/clients unchanged (R7).

---

## 10. Out of scope

- Any lib change (freeze — 0.4.0 ADR path only); set-layer feature work; admin UI changes (N4 shipped); Infra/helm changes; consent UI rework.

---

## 11. Open questions

1. **`custom_specs/1` final disposition** — thin delegate vs full retirement; grep-decide during the flip and record the outcome here (no consumer ⇒ delete).
2. **TTL reconciliation** — lib `Toolset.Cache` default 60s vs NPL 45s policy: explicit `ttl:` in server opts (preferred) or accept 60s (N3 §10.4 carries the decision; confirm it landed).
3. **`window_test.exs` / `legacy_keys_test.exs`** — not among the 9 named ports; their coverage (expiry windows, legacy-key mapping) folds into the conformance suites' expiry/authenticator cases. Confirm nothing unique is lost (implementer diff-covers before deleting).
4. **`elevation_test.exs` / `consent_manifest_test.exs`** — port or update in place (they exercise the consent REST side, which survives); decide during the flip; record.

---

## 12. File change map (flip merge train)

| File | Change |
|---|---|
| `backend/mix.exs` | dep flip `:99` (final commit) |
| `backend/lib/noizu_prompt_lingua/mcp/server.ex` | base-macro flip (§4.1) |
| `backend/lib/noizu_prompt_lingua/mcp/session_manifest.ex` | rewrite (§4.2) |
| `backend/lib/noizu_prompt_lingua/mcp/custom.ex` | provider-backed (§4.3) |
| `backend/lib/noizu_prompt_lingua/mcp/{dispatch,effective_toolset,toolset_cache,toolset_config,key_toolsets,window,legacy_keys}.ex`, `mcp/effective_toolset/`, `mcp/tool_set_endpoint.ex` | DELETE (ledger §7) |
| `backend/lib/noizu_prompt_lingua/mcp/acl_provider.ex` | ToolGuard invocation re-home (Decision 7) |
| `backend/lib/noizu_prompt_lingua/mcp/principal_mapper.ex` | `custom_scope_slug` metadata copy (§4.3) |
| `backend/test/noizu_prompt_lingua/mcp/*` + `oauth/*` | ports per §5 table; originals deleted |
| `CHANGELOG` (NPL) | both wire deltas |
