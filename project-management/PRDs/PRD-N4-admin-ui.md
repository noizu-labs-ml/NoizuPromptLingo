# PRD-N4: Admin API + UI

**Series**: NPL last-mile (N4 of 6) — see [INDEX-NPL.md](./INDEX-NPL.md)
**Repo**: `Portfolio/Apps/AI/NoizuPromptLingo` (anchors relative to `backend/`; frontend paths relative to `frontend/`)
**Gates**: **N4a** (controller CRUD + frontend, contract-first) starts now on hex 0.1.5 — merges to NPL `main`. **N4b** (validate dry-run, effective preview, controller clone) is gated on **lib PRD-3 merge** (`Validator.compile/3`, `%Toolset.Custom{}` catalog preview) — develops on `feat/tool-sets-integration`, does not merge to `main` before the flip.
**Branches**: `feat/n4a-admin-frontend`, `feat/n4b-admin-validate`
**Status**: Draft

---

## 1. Goal

Org-admin management for tool sets, backend + frontend:

1. `mcp/tool_set_profiles_controller.ex` — index (built-ins + org sets + shapes + member counts), show (effective preview — the D1-correct view), create/update/deactivate/clone/validate (dry-run against the LIVE catalog with structured issues). Audit every mutation with actor (R8).
2. Frontend: a Tool-Sets section in the existing MCP admin area, a `kind=tool-set` config page, the overrides editor extended to the closed op vocabulary, and the ACL/api plumbing for the new endpoints.

Split rationale: CRUD + UI are contract-first and lib-independent (N4a, hex 0.1.5 — the frontend builds against the JSON contract while N2a lands storage); the preview/validate endpoints need lib `Validator.compile/3` + `Toolset.catalog/3` (N4b, PRD-3 gate). Controller-level clone ships in N4b so clone-from-profile previews/validates its copied config with the same machinery (the CONTEXT `clone/2` exists since N2a — FR-2A-7).

---

## 2. Decisions applied (INDEX-NPL §3)

- **Decision 6 (gates)**: N4a on hex 0.1.5; N4b on PRD-3 via the path dep.
- **D1**: `show`'s effective preview renders through the SAME resolver the serving path uses (`Toolset.catalog/3` over `ToolsetResolver`'s assembled toolset) — the admin sees exactly what a caller would get, never a parallel renderer.
- **D5**: validate is a pure dry-run; save-time rejection only for structural/config errors (N2a FR-2A-3); catalog-compile issues surface via validate + show, and D5 lazily at read.
- **R8**: audit trail on every mutation; config validated at SAVE (structural in N4a-era via the N2a changeset, full compile at N4b).
- **R1**: built-ins are read-only, cloneable, never editable — enforced controller-side as well as changeset-side.

---

## 3. Current state (verified anchors)

| Concern | Anchor | Note |
|---|---|---|
| Controller pattern | `lib/noizu_prompt_lingua_web/controllers/mcp_endpoints_controller.ex` — `index/2` `:12`, `show/2` `:57`, `create/2` `:69`, `update/2` `:101` | org-admin pipe/action pattern the new controller mirrors |
| Admin surface (related) | `admin_controller.ex` — client toolset_config endpoints `show_client_toolset_config` `:1362`, `update_client_toolset_config` ~`:1370-1390`, normalize/reset `~:1419-1423` | Adjacent surface; NOT modified by this PRD |
| In-row audit precedent | `mcp_custom_scopes.ex:1159` + `:1174-1177` (`carry_audit/2` — provenance preserved in config jsonb) | NPL has NO dedicated audit table (verified 2026-09-01) |
| Storage + context | N2a: `Schema.MCPToolSet`, `MCP.ToolSets` (create/update/deactivate/list_for_org/get_by_org_and_slug/to_overrides); N2b: `assemble_custom/2`, `Profiles.custom/1` | Controller's data plane |
| Profiles | `mcp_servers.ex:15` `@servers`; `Toolsets.Profiles` (N2a data, N2b structs) | index lists built-ins from DATA, never rows |
| Frontend admin area | `frontend/src/app/app/admin/mcp-custom-scopes/page.tsx`; `frontend/src/app/app/admin/mcp-config/page.tsx`; `frontend/src/app/app/admin/mcp-config/[kind]/[id]/page.tsx` | Tool-Sets section + `kind=tool-set` extend these |
| Reused components | `frontend/src/components/mcp-include-editor.tsx`, `mcp-endpoint-manager.tsx` (top level); `frontend/src/components/kit/{tool-overrides-editor.tsx, tool-toggles-grid.tsx, acl-editor.tsx}` | Per plan: components live at BOTH levels — verified |
| API client layer | `frontend/src/lib/acl-api.ts` | New set-management fns |
| Catalog validation (N4b) | lib `Noizu.MCP.Toolset.Validator.compile/3` (PRD-3 §4.5) + issue codes table | Dry-run engine |

---

## 4. Public surface

### 4.1 `lib/noizu_prompt_lingua_web/controllers/tool_set_profiles_controller.ex` — `NoizuPromptLinguaWeb.ToolSetProfilesController`

Org-admin required (same pipe/role gate as `mcp_endpoints_controller.ex`). JSON API:

| Action | Route (admin scope) | N4x | Contract |
|---|---|---|---|
| `index/2` | `GET /api/.../tool-sets` | N4a | `%{profiles: [profile_view], sets: [set_view]}` — `profile_view`: slug, display name, description, `groups` (expanded ids), `group_count`, `tool_count` (from registry/specs), `cloneable: true, editable: false`; `set_view`: id, slug, display_name, description, shape (`org|project|group` + shape ids), `source`, `source_profile`, `is_active`, `config_digest`, `member_count` (group-sets), `updated_at`, `urls: %{mcp, admin}` (N3 builders) |
| `show/2` | `GET .../tool-sets/:slug` | N4b (preview)/N4a (row) | Row fields + `effective`: the D1-correct preview (below) |
| `create/2` | `POST .../tool-sets` | N4a | attrs → 201 + set_view, or 422 + changeset errors |
| `update/2` | `PATCH .../tool-sets/:slug` | N4a | partial (config/settings/display_name/description) → 200/422 |
| `deactivate/2` | `POST .../tool-sets/:slug/deactivate` | N4a | soft-kill → 200 |
| `clone/2` | `POST .../tool-sets/clone` | N4b | `{source: profile_slug | set_slug, attrs}` → 201 + new set (FR-2A-7 semantics) + validation result |
| `validate/2` | `POST .../tool-sets/validate` | N4b | `{config, settings}` dry-run → `%{ok: true, warnings: [...]}` or `%{ok: false, issues: [%{code, message, tool, field}]}` — NEVER persists |

**Effective preview (show/clone/validate, N4b)**: assemble the candidate toolset (existing set via `ToolSets.assemble_custom/2` for the ADMIN's own org ctx; candidate config for validate via a scratch `%Toolset.Custom{}`) and run `Toolset.catalog/3` against the live base catalog — returning per-tool `%{name, title, description, visible, callable, reason}` + `version`. This is the D1-correct view: identical machinery to serving.

**Audit (FR-4-5)**: every mutating action records actor + action + target + result, following the in-row `carry_audit/2` precedent (`mcp_custom_scopes.ex:1174-1177`): a `%{"audit" => [%{at, actor, action}]}`-style provenance appended under `settings["_audit"]` (bounded, last 20), plus a structured `Logger.info` event `[:mcp_tool_set, :mutation]` with the same fields.

### 4.2 Frontend

- **Tool-Sets section** in `frontend/src/app/app/admin/mcp-custom-scopes/page.tsx` (sibling section to scopes; lists profiles + sets via `index`, reusing `mcp-endpoint-manager.tsx` patterns for endpoint display and `mcp-include-editor.tsx` for group/include selection UI).
- **`kind=tool-set`** in `frontend/src/app/app/admin/mcp-config/[kind]/[id]/page.tsx` — the detail page renders set config: include editor (groups), the extended overrides editor, settings form (`allow_api_keys`, `description_verbosity`, `instructions`), shape/audience editor, clone + deactivate actions, validate button (calls the dry-run, renders `issues` inline).
- **`frontend/src/components/kit/tool-overrides-editor.tsx`** EXTENDED to the closed vocabulary: per-tool rows → name (`name`), description (`description`), enabled toggle (`enabled`); per-arg rows → `enum_remove` (multi-select from the tool's live enum), `hide` (checkbox), `rename` (text), `default` (value picker), `description` (text). Emits exactly the PRD-N2 §4.1 jsonb shape; unknown keys are impossible by construction.
- **`frontend/src/lib/acl-api.ts`** — new fns: `listToolSets(orgId)`, `getToolSet(orgId, slug)`, `createToolSet(...)`, `updateToolSet(...)`, `deactivateToolSet(...)`, `cloneToolSet(...)`, `validateToolSet(...)` — matching the controller contract 1:1.

---

## 5. Functional requirements

**FR-4-1 Controller + auth.** All actions require org-admin (mirror `mcp_endpoints_controller.ex` pipe). Non-admin ⇒ 403. Set access is org-scoped by the pipe — a slug from another org 404s (no cross-org read).

**FR-4-2 Index composition.** `index/2` returns built-in profiles (from `Toolsets.Profiles` DATA — never DB rows, R1) plus the org's sets with shape + member counts (`list_for_org/1`); profile `groups` expand via `groups_for/1` (`full` == `MCPServers.customizable()`, 21 groups).

**FR-4-3 CRUD contract.** `create/update/deactivate` delegate to `MCP.ToolSets` (N2a changeset = single validation authority). Errors return the changeset field errors verbatim (422). Deactivate is idempotent; deactivated sets disappear from `get_for_request/2` (AC-2A-8) and from serving (N3), remain listable with `is_active: false` + reactivate via update.

**FR-4-4 Read-only built-ins.** Profile slugs reject update/deactivate at the CONTROLLER (405/422) in addition to the changeset reserved-slug block (FR-2A-2); clone from a profile is the only mutation.

**FR-4-5 Audit.** Every mutation (create/update/deactivate/clone) records actor+action+target+result via §4.1 (in-row provenance + Logger event). Audit failure NEVER fails the mutation (log-only path). Actor = the admin's user id from the admin session/pipe.

**FR-4-6 Validate dry-run (N4b).** `validate/2` compiles the candidate config: `to_overrides/1` → scratch `%Toolset.Custom{}` → `Validator.compile/3` vs the live base catalog; returns structured issues using the lib codes (`:unknown_tool`, `:unknown_field`, `:prune_not_subset`, `:rename_target_missing`, `:rename_collision`, `:pin_default_invalid`, `:raw_schema_op`, `:name_charset`, `:name_collision`, `:cycle` — PRD-3 §4.5 table) + warnings. Never persists, never 500s on issue paths.

**FR-4-7 Effective preview (N4b).** `show/2` (and `clone/2` response) carry `effective` via `Toolset.catalog/3` through the serving resolver — visible/callable/reason per tool, matching what `tools/list` + `ToolSummary` serve for a caller of the same shape (D1; cross-checked by test).

**FR-4-8 Frontend CRUD + editor.** The Tool-Sets section + detail page drive the full CRUD/clone/validate surface; the extended `tool-overrides-editor.tsx` emits only closed-vocabulary keys; the validate button renders issues per tool/field inline (no raw error dumps).

**FR-4-9 Contract-first frontend (N4a).** The N4a frontend builds against the §4.1 JSON contract with a fixture/mock lane where N4b endpoints are pending (validate/clone buttons render disabled with a "pending backend" state until N4b lands on the integration branch). No frontend dependency on lib internals.

---

## 6. Acceptance criteria

**AC-N4-1** Auth matrix: org-admin ⇒ 2xx; non-admin ⇒ 403; cross-org slug ⇒ 404.

**AC-N4-2** Index: profiles listed with expanded groups (`full` = 21 ids) and cloneable flags; sets listed with shape + member_count; member_count correct for a fixture group-set (via `scoped_memberships` fixtures).

**AC-N4-3** CRUD: create → 201 + row; duplicate slug / reserved slug / bad vocabulary ⇒ 422 with field errors matching the N2a changeset; update partial-applies; deactivate idempotent; deactivated set absent from `get_for_request/2` (serving proof) but present in index.

**AC-N4-4** Built-in immutability at the controller: PATCH/DELETE (or deactivate) on `full`/`agent-ops`/`pm-dev`/`content`/`comms` ⇒ rejected.

**AC-N4-5** Audit: after each mutation type, the row's provenance + the Logger event carry actor/action/target; a Logger failure (captured/sandboxed) does not fail the request.

**AC-N4-6** Validate (N4b): each PRD-3 §4.5 issue code reproducible via a crafted config (at minimum `:unknown_tool`, `:unknown_field`, `:prune_not_subset`, `:rename_collision`, `:name_charset`); warnings path (`{:ok, warnings}`) exercised; response shape per §4.1; nothing persisted (row count unchanged).

**AC-N4-7** Effective preview (N4b): for a set with rename + enum-prune, `show.effective` names == a live `tools/list` through the N3 endpoint for an equivalent caller (names AND schemas' effective enums); `version` present.

**AC-N4-8** Clone (N4b): from profile — 201, `source_profile` recorded, allowlist config deep-copied, `effective` preview present; from set — config copied; slug auto-suggest `-copy` honored.

**AC-N4-9** Frontend: component/page tests — Tool-Sets section renders profiles+sets; detail page kind=tool-set round-trips config through the extended editor (jsonb in == jsonb out for a representative config); validate issues render inline; N4a mock lane keeps validate/clone disabled until backend present.

**AC-N4-10** Scoped suites green: controller tests + `tool_sets_test.exs` (N2a) + frontend lane.

---

## 7. Test plan

Under `backend/test/`:

- **`noizu_prompt_lingua_web/controllers/tool_set_profiles_controller_test.exs`** (NEW, N4a) — AC-N4-1..5.
- **(N4b additions in the same file, or `tool_set_profiles_validate_test.exs`)** — AC-N4-6..8 (path-dep branch).
- Frontend lane: page/component tests beside `mcp-custom-scopes/page.tsx`, `[kind]/[id]/page.tsx`, `kit/tool-overrides-editor.tsx` (project's existing component-test lane; contract tests follow the `*.contract.test.ts` naming already used in `src/components/`).

Run scoped: backend `mix test test/noizu_prompt_lingua_web/controllers/tool_set_profiles_controller_test.exs`; frontend project lane.

---

## 8. Compat & rollback

- N4a: purely additive routes + UI; hex 0.1.5; storage dependency (N2a) merges first — controller tests use the context directly. Rollback = revert PR.
- N4b: integration-branch only; `validate`/`clone`/`effective` additions are additive to the controller. Rollback = drop branch commits.
- The frontend mock lane means UI work never blocks on the PRD-3 gate.
- Audit is in-row + logs (no schema change); a future dedicated audit table is a non-breaking addition (open question 2).

---

## 9. Out of scope

- Serving/permission enforcement (N3); client/key toolset_config admin (existing `admin_controller.ex` surface — untouched); profile EDITING (never — R1); bulk import/export; per-set analytics.

---

## 10. Open questions

1. **Route namespace** — spec says "admin scope, `/api/.../tool-sets`"; exact prefix must match the existing admin API scope the frontend already calls (implementer copies the `mcp_endpoints_controller.ex` routing block and records the final path in the PR).
2. **Audit channel** — in-row `settings["_audit"]` + Logger follows the `carry_audit` precedent; if the lead wants a dedicated `mcp_tool_set_audit` table instead, that is an 084-scale addition — decide BEFORE 083 merges (083 as planned carries no audit columns).
3. **Member counts** — `index` computes group-set `member_count` live via `ScopedMemberships.list_for_resource/3` (`:78`); fine at current scale, but if orgs grow this becomes a cached count — noted, no action in v1.
4. **Verbosity editor** — `description_verbosity` UI: select from `:full | :concise | :minimal` (pending PRD-N2 open question 2 confirmation).

---

## 11. File change map

| Phase | File | Change |
|---|---|---|
| N4a | `backend/lib/noizu_prompt_lingua_web/controllers/tool_set_profiles_controller.ex` | NEW (index/create/update/deactivate + audit) |
| N4a | `backend/lib/noizu_prompt_lingua_web/router.ex` (admin scope) | routes |
| N4a | `frontend/src/lib/acl-api.ts` | new fns |
| N4a | `frontend/src/app/app/admin/mcp-custom-scopes/page.tsx` | Tool-Sets section |
| N4a | `frontend/src/app/app/admin/mcp-config/[kind]/[id]/page.tsx` | `kind=tool-set` |
| N4a | `frontend/src/components/kit/tool-overrides-editor.tsx` | closed-vocabulary extension |
| N4b | controller | `show` effective preview, `clone/2`, `validate/2` |
| both | Tests | §7 |
