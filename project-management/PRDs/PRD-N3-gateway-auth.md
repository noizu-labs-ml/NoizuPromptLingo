# PRD-N3: Gateway, Identity & Auth

**Series**: NPL last-mile (N3 of 6) — see [INDEX-NPL.md](./INDEX-NPL.md)
**Repo**: `Portfolio/Apps/AI/NoizuPromptLingo` (anchors relative to `backend/` unless prefixed)
**Gate**: **lib PRD-3 merge** (needs `Features.Tools.protocol_list/protocol_call`, `toolset:`/`principal:`/`providers:`/`toolset_cache:` opts, `%Auth.Principal{}` + `Ctx.auth`, MFA resolver contract, `%Toolset.Custom{}` — lib PRD-1 §4.9, PRD-3 §4.7, PRD-2 §4.1/§4.4, PRD-3 §4.1). Builds on N2a (mcp_tool_sets) and N2b (providers) on `feat/tool-sets-integration` (path dep). Does NOT merge to NPL `main` before the flip.
**Branch**: `feat/n3-gateway`
**Normative references**: plan §3 N3 (verbatim scope); lib PRD-5 §4.4/§4.5 (`PrincipalMapper`, `ToolsetResolver` shapes — pulled forward here)
**Status**: Draft

---

## 1. Goal

Serve tool sets at slug URLs under the EXISTING tobor.locker ingress (the vendored `helm/npl-mcp` already routes `Prefix /org` — zero infra change):

1. `/org/{org}/set/{set}/mcp` and `/org/{org}/project/{project}/set/{set}/mcp` (R4).
2. Identity: OAuth bearer/JWT (via NPL's `MCP.DualTokenVerifier`) and API keys resolve to a typed `%Principal{}` whose metadata carries the route's set coordinates (R5).
3. Gating: set-audience resolution (profile slug or set slug), `settings.allow_api_keys`, group-set membership (404, no existence leak), org-membership for org/project sets (R3/R5).
4. Serving through the LIB protocol path via a thin endpoint bridge — listing == enforcement (R2), with enum pruning and renames enforced end-to-end.
5. URL builders for machine + human surfaces.

Explicitly NOT here: the base-macro flip (N5), legacy envelope retirement (N5, wire delta #1), admin CRUD (N4).

---

## 2. Decisions applied (INDEX-NPL §3)

- **Decision 5/6 (gate)**: compiles against lib main via the path dep; gated on PRD-3.
- **Decision 3 (wire delta #1 boundary)**: the legacy `insufficient_authorization` tool-result envelope (`mcp/dispatch.ex:36-45`) stays for LEGACY endpoints until N5. Set endpoints serve through the lib path from day one, so a destructive tool reached THROUGH a set already speaks the new `forbidden` + `negotiation.metadata.elevation_uri` shape (lib PRD-4 §4.5). Both envelopes coexist only during the interim; the conformance suite (FR-3-14) pins the NEW shape, and N5 deletes the old one.
- **D1/D2**: the bridge delegates to `protocol_list`/`protocol_call` — no second resolver.
- **D4**: set/profile slugs resolve through explicit context lookups; the resolver never scans modules.
- **D5**: an invalid set (bad config, unknown base) disables THAT set's endpoint (lib returns the toolset-disabled error), server healthy.
- **R3**: non-member ⇒ 404, `expires_at` respected — no existence leak.
- **R7**: legacy routes (`:352`, `:361`, `:369`, `:372`) untouched; the new matches are purely additive and behind `:tool_sets_enabled`.

---

## 3. Current state (verified anchors)

| Concern | Anchor | Reuse |
|---|---|---|
| Org-addressed gateway pattern | `lib/noizu_prompt_lingua_web/controllers/custom_mcp_gateway_controller.ex` — `handle_org/2` `:15` (resolves `Organizations.resolve_org_id` → `MCPCustomScopes.get_by_org_and_slug/2` `mcp_custom_scopes.ex:250` → `defp serve/4` `:118`), `handle/2` `:34`, `handle_user/2` `:76` | The set controller mirrors `:15-33` + `:118` |
| Router block | `lib/noizu_prompt_lingua_web/router.ex` — host forwards `:138-327`; custom `:352`; org-custom `:361`; user `:369`; bare `scope "/mcp"` + `forward "/"` `:372-373` | Two new `match :*` entries AFTER `:369`, BEFORE `:372`, same scope |
| Token verification | `mcp/dual_token_verifier.ex` (exists; bearer/JWT + API-key dual path) | Claims source for the mapper |
| Claims stash today | lib plug assigns `:auth_claims` (lib PRD-2 §3: `plug.ex:180-181`, folded `:387-406`); NPL reads it in `mcp/resolve.ex:17-22` `current_user_id/1` | Replaced for MCP handlers by `ctx.auth` once `principal:` is wired |
| ACL engine | `acl.ex:58` `resolve/4` | unchanged |
| Set storage | N2a `mcp_tool_sets` via `MCP.ToolSets.get_for_request/2`, `assemble_custom/2`; profiles `Toolsets.Profiles.custom/1` (N2b) | Resolver inputs |
| Providers | N2b `ToolsetProvider` / `AclProvider` | Endpoint opts |
| Membership data | `entities/authz/scoped_memberships.ex` (`:78` `list_for_resource/3`, `:194` `list_for_user/2`); `expires_at` at `schema/authz/scoped_membership.ex:12` | Group gate — NO `member?` helper exists yet (INDEX-NPL §6.7) |
| Project resolution | `entities/projects.ex:59` `get_project/1` (id-only, TRP shared-key); `mcp/projects.ex` is the `tobor_projects` SERVER module, not a resolver (INDEX-NPL §6.4) | Gap closed by FR-3-11 |
| Org resolution | `entities/organizations.ex:39` `resolve_org_id/1` | Reused |
| URL builders | `mcp/urls.ex` — `scope_url/2` `:20`, `user_url/2` `:31`, `legacy_url/2` `:34`, `defp app_url/3` `:51`, `defp build/2` `:61` | Extended |
| Gateway test pattern | `test/noizu_prompt_lingua/mcp/custom_entities_gateway_test.exs` (exists) | Template for the gateway suite |

---

## 4. Public surface

### 4.1 `mcp/tool_set_endpoint.ex` — `NoizuPromptLingua.MCP.ToolSetEndpoint` (TRANSITIONAL — deleted at N5)

```elixir
defmodule NoizuPromptLingua.MCP.ToolSetEndpoint do
  use NoizuPromptLingua.MCP.Server,
    name: "tobor_toolset",
    version: "0.1.0",
    instructions: "Tool set gateway endpoint (per-set surface).",
    toolset: {NoizuPromptLingua.MCP.ToolsetResolver, :resolve, []},
    principal: {NoizuPromptLingua.MCP.PrincipalMapper, :from_claims, []},
    providers: [persistence: NoizuPromptLingua.MCP.ToolsetProvider,
                acl: NoizuPromptLingua.MCP.AclProvider],   # PRD-4 §4.3 combined form wins
    toolset_cache: true

  # ~10-line bridge: this endpoint carries NO tools of its own. catalog_specs/1
  # returns [] and serving rides the LIB-generated protocol_list/protocol_call
  # defaults via the toolset: MFA. Deleted at N5 when the base macro emits the
  # same opts for every server (plan §3 N5 step 1).
end
```

### 4.2 `mcp/principal_mapper.ex` — `NoizuPromptLingua.MCP.PrincipalMapper` (lib PRD-5 §4.4 shape, pulled forward; needs only PRD-2)

```elixir
from_claims(claims, opts) ::
  {:ok, %Noizu.MCP.Auth.Principal{}} | %Noizu.MCP.Auth.Principal{} | {:error, term()}
# API-key path (dual_token_verifier.ex-verified): subject = api_key_id,
#   authenticator: :api_key, token_id = key id, granted_scopes = key scopes,
#   claims = raw claims, metadata %{key: ref}
# OAuth path: subject = client_id, authenticator: :oauth, granted_scopes = token scopes
# Route metadata (THE transport for set resolution) — merged into Principal.metadata
#   by the GATEWAY before the endpoint sees it (§4.4): set_org_slug, set_project_slug,
#   set_slug. Mapping error ⇒ {:error, _} ⇒ ctx.auth = nil + Logger.warning
#   (lib PRD-2 §4.5 fail-open-to-anonymous; the verifier already rejected bad tokens).
```

### 4.3 `mcp/toolset_resolver.ex` — `NoizuPromptLingua.MCP.ToolsetResolver` (lib PRD-3 §4.7 MFA contract)

```elixir
resolve(ctx, opts) :: %Noizu.MCP.Toolset.Custom{} | module() | :none
# 1. Principal from ctx.auth (guaranteed — resolver runs post principal-mapping).
# 2. metadata.set_slug present?
#      → MCP.ToolSets.get_for_request(org_id, set_slug)  (active-only)
#        → ToolSets.assemble_custom(set, ctx)            (N2b real form)
# 3. else metadata.profile_slug present? (profile-style sets / future direct profile URLs)
#      → Toolsets.Profiles.custom(slug) | :none + Logger.warning on unknown slug (D5, never error)
# 4. authenticator binding (api_key/oauth toolset_slug-style binding) → same two paths.
# 5. No binding ⇒ :none (server static surface — today's fallback).
```

### 4.4 `lib/noizu_prompt_lingua_web/controllers/mcp_set_gateway_controller.ex` — `NoizuPromptLinguaWeb.MCPSetGatewayController` (mirror of `custom_mcp_gateway_controller.ex:15-33` + `:118`)

```elixir
handle_org(conn, %{"org_slug" => org_slug, "set_slug" => set_slug})
  # resolve org (Organizations.resolve_org_id/1 :39) → set (ToolSets.get_by_org_and_slug/2,
  #   ACTIVE-only) → audience gate:
  #     * group-set: active membership for the CALLER (FR-3-8) else 404
  #     * org/project-set: org-membership required (existing org-role plumbing)
  #   → settings.allow_api_keys check (FR-3-7)
  #   → serve(conn, endpoint, path, org_id, metadata: %{
  #        set_org_slug: org_slug, set_slug: set_slug})   # route metadata → Principal.metadata

handle_org_project(conn, %{"org_slug" => org_slug, "project_slug" => project_slug,
                            "set_slug" => set_slug})
  # as above + resolve project (FR-3-11) → require set.project_id == project.id
  #   else 404 (no leak)

# serving: binds the ToolSetEndpoint transport (same serve mechanics as
# custom_mcp_gateway_controller.ex defp serve/4 :118 — streamable-http session setup)
```

### 4.5 Router + urls

```elixir
# router.ex — inside the scope holding :352/:361/:369, AFTER :369, BEFORE the :372 scope:
match :*, "/org/:org_slug/set/:set_slug/mcp",                MCPSetGatewayController, :handle_org
match :*, "/org/:org_slug/project/:project_slug/set/:set_slug/mcp",
                                                             MCPSetGatewayController, :handle_org_project
# both gated at the top of each handler by:
#   Application.get_env(:noizu_prompt_lingua, :tool_sets_enabled, false)
#   (flag false ⇒ 404; convention note: existing flags use the :mcp_ prefix,
#    toolset_cache.ex:80 — plan's literal name retained, see §10)

# mcp/urls.ex additions:
set_url(set_or_slug, org, opts \\ [])            # build/2 (:61) → "<base>/org/{org}/set/{slug}/mcp"
set_project_url(set_or_slug, org, project, opts \\ [])
tool_set_admin_url(org_slug, slug, opts \\ [])   # "<app>/app/{org_slug}/settings/tool-sets/{slug}" (human, R4)
```

### 4.6 `entities/authz/scoped_memberships.ex` — NEW helper

```elixir
@doc "True iff user (or persona principal) has an ACTIVE membership (expires_at nil or > now)
      on the resource. Used by the group-set gate."
def active_member?(resource_type, resource_id, user_or_persona_ref) :: boolean()
```

---

## 5. Functional requirements

**FR-3-1 Route surface.** The two routes of §4.5 exist, in the stated order (after `:369`, before `:372` so bare `/mcp` still wins the catch-all); both are inert (404) unless `:noizu_prompt_lingua, :tool_sets_enabled`. Legacy routes are byte-identical (router diff touches only the two new matches).

**FR-3-2 Endpoint bridge.** `ToolSetEndpoint` serves listings/dispatch EXCLUSIVELY through the lib protocol path (`toolset:` MFA); it defines no `handle_list_tools`/`handle_call_tool` of its own beyond the NPL base-macro defaults and registers no domain tools. A direct `Toolset.catalog(ToolSetEndpoint, ctx, [])` and an HTTP `tools/list` round-trip agree on the effective surface.

**FR-3-3 Principal mapping.** `PrincipalMapper.from_claims/2` produces `%Principal{}` per §4.2 for api-key and oauth claims; unknown/invalid claims ⇒ error tuple ⇒ anonymous per lib PRD-2 §4.5; route metadata (`set_org_slug`, `set_project_slug`, `set_slug`) arrives in `Principal.metadata` and is the ONLY set-coordinate source the resolver reads (D1/AP-13 direction — handlers stop inferring identity from `ctx.assigns`).

**FR-3-4 Set resolution.** Resolver per §4.3: set slug ⇒ `get_for_request/2` (nil/inactive ⇒ treat as no binding ⇒ `:none` + warning — the gateway's 404 gate has already filtered unknown slugs, so a resolver miss is a race/staleness case, handled D5) → `assemble_custom/2`; profile slug ⇒ `Profiles.custom/1`; no binding ⇒ `:none`.

**FR-3-5 Allowlist semantics e2e.** Empty/`{}` set config ⇒ only the Discovery/NPL/overview plane is served (R2). Explicit allowlist ⇒ exactly that universe, with per-tool ops materialized: `tools/list` shows pruned enums, hidden fields deleted, renamed fields/args; `tools/call` enforces the SAME shape — a pruned enum value ⇒ invalid-args, structurally IDENTICAL to unknown-tool; a renamed arg is accepted only under its wire name; the handler receives original-keyed args (lib wire_key, PRD-1 §4.8); dispatch by canonical name works even when renamed (`meta["canonical_name"]` path).

**FR-3-6 Audience gates.** (a) Group-set: caller without an ACTIVE membership (expires_at respected — `active_member?/3`) ⇒ HTTP 404 indistinguishable from unknown-slug 404 (no existence leak); expired membership ⇒ 404. (b) Project-set: `set.project_id != project.id` ⇒ 404. (c) Org/project-set: caller without org membership ⇒ 404. (d) Unknown org/slug ⇒ 404 (mirror `custom_mcp_gateway_controller.ex:24-31`).

**FR-3-7 `allow_api_keys`.** `settings.allow_api_keys == false` AND the principal's authenticator is `:api_key` ⇒ authorization error (HTTP-level authz error before session serving; message "api keys not allowed on this set"); default (missing key) ⇒ allowed (N2a FR-2A-5 default true).

**FR-3-8 Group gate helper.** `active_member?/3` respects `expires_at` (`schema/authz/scoped_membership.ex:12`), supports user and persona members (context supports both — `:28`/`:129`), returns false on absent rows.

**FR-3-9 Project resolver.** NEW resolution of a project by slug within an org, added alongside `Organizations.resolve_org_id/1` (TRP shared-key backed, consistent with `entities/projects.ex`); used only by `handle_org_project/2`; unknown project ⇒ 404.

**FR-3-10 URL builders.** `set_url/2`, `set_project_url/3` produce the exact wire URLs of §4.5; `tool_set_admin_url/2` produces the human `/app/{org_slug}/settings/tool-sets/{slug}`; all route through `defp build/2` (`:61`) so host/base handling matches existing builders; `urls_test.exs` cases added.

**FR-3-11 Step-up shape on set endpoints (Decision 3).** A scope-gated destructive tool called through a set endpoint without the required scopes ⇒ lib `forbidden` error whose data carries `%{tool, required_scopes, missing, negotiation: %{id, metadata}}` with `negotiation.metadata.elevation_uri` populated when NPL recorded it (lib PRD-4 §4.5). The legacy `insufficient_authorization` envelope is NOT present on this path.

**FR-3-12 Live consistency.** Set config edits (N2a context writes, already propagating via N1 hooks where applicable) reflect on the NEXT `tools/list` through `toolset_cache: true` TTL/invalidation semantics — no reconnect (verified by the N6a soak live check 3; test-level proof via `Toolset.Cache.invalidate` on write in the fixture).

**FR-3-13 Cross-shape serving.** Org-set, project-set, group-set all serve through the same endpoint/resolver; the resolver's assembled `%Custom{}` metadata carries the set id/shape for audit.

**FR-3-14 Conformance hook.** The wire shape asserted in FR-3-11/3-5 is pinned by tests that SURVIVE N5's rewrite (the enum-prune e2e and step-up cases become `tool_sets_conformance_test.exs` at N5 — written now, renamed then).

---

## 6. Acceptance criteria

**AC-N3-1 (gateway happy path)** — Org-set: `POST /org/{org}/set/{set}/mcp` initialize + tools/list as an org-member OAuth principal ⇒ 200, listing == assembled set surface; URL via `set_url/2` matches the route.

**AC-N3-2 (404 family)** — Unknown org / unknown slug / inactive set / non-member group-set caller / expired membership / project mismatch / `:tool_sets_enabled` false ⇒ ALL return 404 with identical body shape (no oracle between them).

**AC-N3-3 (allow_api_keys)** — Set with `allow_api_keys: false`: API-key identity ⇒ authz error; OAuth identity ⇒ serves normally; flag absent ⇒ API key serves normally.

**AC-N3-4 (enum-prune e2e — the R2 keystone)** — Set pruning an enum on a tickets tool + renaming an arg: listing shows the pruned schema and renamed arg; call with pruned value ⇒ invalid-args BYTE-IDENTICAL to unknown-tool; call with allowed value ⇒ ok and the handler sees original arg keys; call under canonical tool name with renamed tool ⇒ dispatches; call under renamed tool name ⇒ dispatches.

**AC-N3-5 (principal mapper)** — api-key claims / oauth claims / garbage claims ⇒ principal shapes per §4.2; route metadata round-trips into `ctx.auth.metadata` and the resolver resolves the intended set (integration: mapper + resolver through `ToolSetEndpoint` fixture).

**AC-N3-6 (group gate)** — `active_member?/3` matrix: active user / expired user / persona member / absent ⇒ true/false/false/false; controller 404s align.

**AC-N3-7 (project resolver)** — project-by-slug-in-org resolves; unknown ⇒ 404; `handle_org_project` mismatch ⇒ 404.

**AC-N3-8 (step-up)** — Set-gated destructive tool without scopes ⇒ `forbidden` + elevation_uri data path (FR-3-11); with recorded consent ⇒ callable.

**AC-N3-9 (flag)** — `Application.put_env(:noizu_prompt_lingua, :tool_sets_enabled, false)` ⇒ both routes 404; true ⇒ serve; default (unset) ⇒ 404.

**AC-N3-10 (legacy untouched)** — `custom_entities_gateway_test.exs` + `custom_scope_test.exs` + `urls_test.exs` green unmodified except additive cases.

---

## 7. Test plan

Under `backend/test/`:

- **`noizu_prompt_lingua/mcp/tool_set_gateway_test.exs`** (NEW; pattern `custom_entities_gateway_test.exs`) — AC-N3-1/2/3/6/7/9: route-level via the endpoint (Plug-ish conn harness the custom-gateway suite uses).
- **`noizu_prompt_lingua/mcp/tool_set_endpoint_test.exs`** (NEW) — AC-N3-2/4/5/8: the enum-prune e2e (listing == enforcement), canonical dispatch, wire-key-only args, forbidden+elevation shape, mapper→resolver integration.
- **`noizu_prompt_lingua/mcp/urls_test.exs`** (EXTEND) — FR-3-10 builders.
- **`noizu_prompt_lingua/authz`-adjacent test** for `active_member?/3` (place beside the scoped-memberships context tests; AC-N3-6).

Run scoped: `mix test test/noizu_prompt_lingua/mcp/tool_set_gateway_test.exs test/noizu_prompt_lingua/mcp/tool_set_endpoint_test.exs test/noizu_prompt_lingua/mcp/urls_test.exs` (path-dep branch).

---

## 8. Compat & rollback

- Behind `:tool_sets_enabled` (default false) — production impact zero until the flag flips in staging/prod (N6 live checks).
- Routes are additive; no existing route moves (`:372` catch-all unchanged in precedence).
- Rollback: revert PR; `is_active=false` soft-kills any live set without a deploy; Liquibase 083 stays (harmless empty table).
- The endpoint bridge (`ToolSetEndpoint`) is explicitly TRANSITIONAL: deleted at N5 when every server carries the opts. Tracked in PRD-N5 §7.

---

## 9. Out of scope

- Base-macro flip / legacy retirement (N5). Admin CRUD/UI (N4). Consent UI for negotiations (existing NPL consent endpoints serve; elevation flow unchanged). Infra/helm changes (none needed — existing `Prefix /org` ingress).
- Serving sets under the legacy `/custom/:slug` aliases (sets have their own namespace; R7 keeps legacy semantics frozen).

---

## 10. Open questions

1. **Flag name** — plan literal `:tool_sets_enabled` vs. codebase convention `:mcp_tool_sets_enabled` (`toolset_cache.ex:80-82` pattern). Spec keeps the plan's literal; lead may rename at review (one-line diff, update this PRD + AC-N3-9).
2. **Org-membership check for org/project-sets** — "existing org-role plumbing" assumed sufficient (same check the custom org gateway uses, `custom_mcp_gateway_controller.ex:15-33`). If that controller performs NO caller membership check today (trust-by-slug), N3 must add one — implementer verifies and records the finding in the PR.
3. **Anonymous callers** — sets require a principal for gating (no anonymous set serving in v1). Confirm.
4. **`toolset_cache: true` TTL** — lib default 60s (PRD-3 §4.6) vs NPL's 45s policy (`toolset_cache.ex:82`). Spec: pass explicit `ttl: 45_000` if the opt accepts it (PRD-3 Q4 reconciliation), else accept 60s. Decide at implementation.
5. **Persona principals on group sets** — `active_member?/3` accepts persona refs (context supports persona members); whether persona-authenticated MCP callers exist on this gateway is unconfirmed — if not, gate users only and note personas as future.

---

## 11. File change map

| File | Change |
|---|---|
| `backend/lib/noizu_prompt_lingua/mcp/tool_set_endpoint.ex` | NEW (transitional bridge) |
| `backend/lib/noizu_prompt_lingua/mcp/principal_mapper.ex` | NEW |
| `backend/lib/noizu_prompt_lingua/mcp/toolset_resolver.ex` | NEW |
| `backend/lib/noizu_prompt_lingua_web/controllers/mcp_set_gateway_controller.ex` | NEW |
| `backend/lib/noizu_prompt_lingua_web/router.ex` | two matches after `:369` |
| `backend/lib/noizu_prompt_lingua/mcp/urls.ex` | `set_url/2`, `set_project_url/3`, `tool_set_admin_url/2` |
| `backend/lib/noizu_prompt_lingua/entities/authz/scoped_memberships.ex` | `active_member?/3` |
| `backend/lib/noizu_prompt_lingua/entities/projects.ex` (or sibling) | project-by-slug-in-org resolver (FR-3-9) |
| Tests | §7 |
