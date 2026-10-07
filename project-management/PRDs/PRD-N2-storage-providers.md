# PRD-N2: Storage + Providers (N2a storage/profiles-data · N2b providers)

**Series**: NPL last-mile (N2 of 6) — see [INDEX-NPL.md](./INDEX-NPL.md)
**Repo**: `Portfolio/Apps/AI/NoizuPromptLingo` (anchors relative to `backend/` unless prefixed)
**Gates**: **N2a** starts now on hex 0.1.5 (zero lib deps; merges to NPL `main` after N1). **N2b** is gated on **lib PRD-4 merge** (needs `Noizu.MCP.Persistence`, `%Permission.Grant/Negotiation`, `providers:` selection — lib PRD-4 §4.1/§4.4/§4.3); it develops on `feat/tool-sets-integration` carrying the path dep (`{:noizu_mcp, path: "../../../../Libs/ai/elixir-mcp"}` — depth verified, INDEX-NPL §6.3) and does NOT merge to `main` before the flip.
**Branches**: `feat/n2a-storage`, `feat/n2b-providers`
**Normative references**: lib `PRD-1 §4.5` (override vocabulary), `PRD-4 §4.1/§4.4/§4.5` (behaviour, records, persisted layers), `PRD-5 §4.1/§4.2/§5` (provider shapes + legacy translation — N2b is the PULLED-FORWARD execution of PRD-5 §4.1/§4.2/§6.1/§6.2)
**Status**: Draft

---

## 1. Goal

Give tool sets durable NPL-owned storage and the lib-facing provider layer:

**N2a** — the `mcp_tool_sets` table (Liquibase 083) with a CLOSED-operation-vocabulary `config` jsonb (1:1 with lib PRD-1 ops), `Schema.MCPToolSet`, the `MCP.ToolSets` context (CRUD + clone + request-path lookup + a thin `assemble_custom`), and `mcp/toolsets/profiles.ex`: the 5 capability profiles as pure DATA with the decision-4 annotation registry.

**N2b** — `MCP.ToolsetProvider` (lib `Persistence` behaviour over NPL tables — PERMANENT disposition), `MCP.AclProvider` (always-answers `ACL.Provider` over `NoizuPromptLingua.Acl.resolve/4`), the grants mapping (client/key `toolset_config` → weight-200 layers), and the zero-writes guard proving lib tables stay empty.

---

## 2. Decisions applied (INDEX-NPL §3)

- **Decision 1**: N2a touches nothing in `mix.exs`; N2b compiles against the lib via the path dep on the integration branch.
- **Decision 2 (PERMANENT)**: the provider reads/writes NPL tables; lib `noizu_mcp_toolset*` tables get zero rows (FR-2B-6). No data ever migrates.
- **Decision 4 (annotation DSL NOW)**: `@profile_groups` compile-time registry map; membership validated against `MCPServers.customizable()` ids at compile time; `full` = `customizable()`; profiles become immutable `%Toolset.Custom{}` structs only at N2b; tool-level annotation overrides out of scope.
- **Decision 7**: grants-never-hide — grants weight-200 adjust, ACL weight-300 gate. `ToolGuard` stays, re-homed as `AclProvider`'s policy source (N5 wiring; N2b delivers the provider shell).
- **D5**: invalid set config disables THAT set (read-side lazy drop + warn), never 500s a listing; structural validation at SAVE per N2a, full catalog compile-validation arrives with `Validator.compile/3` at N4b.
- **R8 / plan N2a**: save-time structural validation; stale config never 500s a listing.
- **083 DDL precondition (SATISFIED)**: authz groups table name confirmed = **`groups`** (`schema/authz/group.ex:6`).

---

## 3. Current state (verified anchors)

| Concern | Anchor | Note |
|---|---|---|
| Liquibase layout | `db/changelog/db.changelog-master.yaml` (includes end `:238-250`); latest `082-org-slug-uniqueness.yaml` | Next changeset file: `db/changelog/083-mcp-tool-sets.yaml`, registered in master |
| Slugifier | `lib/noizu_prompt_lingua/organizations/slug_backfill.ex:24-39` `slugify/1` | Reused for set slugs |
| Scope config storage (legacy sibling) | `schema/mcp_custom_scope.ex:28` `schema "mcp_custom_scopes"` | Sets are a NEW table; scopes keep legacy global-slug/301/kind semantics (forking those is worse than a sibling table) |
| Client/key override storage | `schema/oauth_client.ex:23` + `schema/mcp_api_key.ex:34` `toolset_config :map, default: %{}` | Read (never written) by N2b grants mapping |
| Toolset_config normalization | `entities/mcp_api_keys.ex:65` `normalize_toolset/1`; `admin_controller.ex ~:1419-1423` (empty ⇒ `%{}` reset) | Shape precedent for the closed vocabulary |
| Server registry | `mcp_servers.ex:15` `@servers` (22), `:126` `all/0`, `:129` `customizable/0` (21, root excluded) | Profile universe |
| ACL engine | `acl.ex:58` `resolve/4`; `schema/mcp/mcp_tool.ex` (`Schema.McpTool`) | AclProvider backing |
| Group memberships | `entities/authz/scoped_memberships.ex` (`:28` add, `:78` list_for_resource, `:194` list_for_user); `schema/authz/scoped_membership.ex:6` (`expires_at` `:12`) | Consumed by N3's group gate; no writes needed in N2 |
| Org resolution precedent | `entities/organizations.ex:39` `resolve_org_id/1` | get_by_org_and_slug pattern precedent |

---

## 4. Public surface

### 4.1 N2a — storage

```elixir
defmodule NoizuPromptLingua.Schema.MCPToolSet do   # lib/noizu_prompt_lingua/schema/mcp_tool_set.ex
  # schema "mcp_tool_sets": fields organization_id (uuid), project_id (uuid | nil),
  # group_id (uuid | nil), slug, display_name, description, source (:custom | :clone,
  # default :custom), source_profile (string | nil), config (map, default %{}),
  # settings (map, default %{}), expires_at, is_active (default true), timestamps.
  # changeset/2:
  #   * slug: SlugBackfill.slugify/1, max 64, REQUIRED, format ^[a-z0-9][a-z0-9-]{0,63}$
  #   * reserved slugs: the 5 profile slugs (Toolsets.Profiles.slugs/0) ⇒
  #     {:error, "slug is reserved"} — profiles are virtual (R1: read-only, NOT editable)
  #   * org-wide unique (organization_id, slug) — deliberate, stricter than per-org-project (R4)
  #   * source/clone invariant: source == :clone ⇒ source_profile OR source_set_id present
  #   * config: closed vocabulary validation (FR-2A-3)
  #   * settings whitelist (FR-2A-5)
  #   * shape invariants: project XOR group XOR neither w/ organization (FR-2A-6)
end

defmodule NoizuPromptLingua.MCP.ToolSets do        # lib/noizu_prompt_lingua/mcp/tool_sets.ex
  create/2                     # attrs → {:ok, %MCPToolSet{}} | {:error, changeset}
  update/2                     # partial update (config/settings/display_name/description/is_active)
  deactivate/1                 # is_active: false (soft-kill, R8)
  clone/2                      # source (profile slug | %MCPToolSet{}), attrs ⇒ new row
                               #   source: :clone, source_profile set when cloning a profile,
                               #   slug auto-suggest "<slug>-copy" (first free), config deep-copied
  list_for_org/1               # org_id → active sets incl. project/group shapes + member counts
  get_by_org_and_slug/2        # (org_id, slug) → set | nil   (active-only on the request path)
  get_for_request/2            # (org_id, slug) → assembled view for serving — THIN in N2a:
                               #   returns %MCPToolSet{} | nil; return type FLIPS to the lib
                               #   toolset at PRD-3 time (N3/N2b wiring) — plan §3 N2a
  assemble_custom/2            # (set, ctx) → effective view — THIN in N2a: normalized config;
                               #   at N2b returns %Noizu.MCP.Toolset.Custom{} built via
                               #   to_overrides/1; see FR-2B-4
  to_overrides/1               # config map → [%{op: atom, target: ..., value: ...}] normalized
                               #   op maps (N2a); N2b flips the element type to
                               #   %Noizu.MCP.Toolset.Override{} — one-line wrap, same function
end

defmodule NoizuPromptLingua.MCP.Toolsets.Profiles do   # lib/noizu_prompt_lingua/mcp/toolsets/profiles.ex
  @profile_groups  # compile-time map, group_id => [profile_slug]:
                   #   "organizations" => ["full", "agent-ops"]
                   #   "sessions"      => ["full", "agent-ops", "pm-dev"]
                   #   "projects"      => ["full", "agent-ops", "pm-dev"]
                   #   "notifications" => ["full", "agent-ops", "comms"]
                   #   "memory"        => ["full", "agent-ops", "comms"]
                   #   "tickets"       => ["full", "pm-dev"]
                   #   "review"        => ["full", "pm-dev"]
                   #   "github"        => ["full", "pm-dev"]
                   #   "instructions"  => ["full", "pm-dev"]
                   #   "artifacts"     => ["full", "content"]
                   #   "assets"        => ["full", "content"]
                   #   "wiki"          => ["full", "content", "comms"]
                   #   "markdown"      => ["full", "content"]
                   #   "market"        => ["full", "content"]
                   #   "campaigns"     => ["full", "content"]
                   #   "customers"     => ["full", "content"]
                   #   "unicode"       => ["full", "content"]
                   #   "chat"          => ["full", "comms"]
                   #   "pubsub"        => ["full", "comms"]
                   #   "personas"      => ["full", "comms"]
                   # every key ∈ MCPServers.customizable() ids else CompileError (Decision 4)
  slugs/0                  # ["full", "agent-ops", "pm-dev", "content", "comms"]
  get/1                    # slug → profile DATA (group list + metadata) | nil
  all/0
  groups_for/1             # profile slug → [group_id] (expanded: "full" = MCPServers.customizable())
  groups_for_tool/1        # group_id → [profile_slug] (@profile_groups inverse)
  # N2b adds: custom/1 → %Noizu.MCP.Toolset.Custom{} (immutable: true, include = expanded
  # group tool names, base = domain server module, tools: %{}) — FR-2B-4
end
```

`config` jsonb closed vocabulary (per-tool beats per-group, mirroring the EffectiveToolset cascade):

```json
{"groups": {"tickets": {"enabled": true, "tools": {"Tickets_Create": {
  "enabled": true, "name": "create_ticket", "description": "...",
  "args": {"priority": {"enum_remove": ["urgent"]}, "internal_field": {"hide": true},
           "assignee": {"rename": "owner"}, "mode": {"default": "fast"},
           "notes": {"description": "..."}}}}}}}
```

Vocabulary keys — tool level: `enabled`, `name`, `description`; arg level: `enum_remove`, `hide`, `rename`, `default`, `description`. NOTHING else validates (unknown keys ⇒ changeset error). This is 1:1 with lib PRD-1 §4.5 ops (`:set_visible|:set_callable` from `enabled`, `:set_name`, `:set_description`, `:prune_enum`, `:hide_field`, `:rename_field`, `:pin_default`, `:set_arg_description`).

### 4.2 N2b — providers (shapes are lib PRD-5 §4.1/§4.2 VERBATIM — cited, not re-specified)

```elixir
defmodule NoizuPromptLingua.MCP.ToolsetProvider do  # mcp/toolset_provider.ex
  # @behaviour Noizu.MCP.Persistence  (lib PRD-4 §4.1 — frozen)
  # store_keys "toolsets" | "toolset_grants" | "toolset_negotiations"
  # "toolsets"     ← mcp_custom_scopes.config (+ KeyToolsets custom sets) translated per PRD-5 §4.1 row 1
  # "toolset_grants" ← mcp_api_keys.toolset_config + oauth_clients.toolset_config per PRD-5 §4.1 row 2
  #                    (+ N2b extension: grant layers sourced from mcp_tool_sets when the
  #                     set slug is the toolset_slug — set context ops as weight-200 layers)
  # "toolset_negotiations" ← scope required_scopes + consent + MCP.Window per PRD-5 §4.1 row 3
  # put/get/delete on "toolsets" delegate to MCPCustomScopes/KeyToolsets context APIs (no new tables)
  # version/2 = max(updated_at) + record_count per source table, mixed with
  #             Application.spec(:noizu_prompt_lingua, :vsn)   (PRD-5 §4.1)
  # translation AT RESOLUTION TIME (D3); failures degrade per lib D5
end

defmodule NoizuPromptLingua.MCP.AclProvider do      # mcp/acl_provider.ex
  # @behaviour Noizu.MCP.ACL.Provider (lib PRD-2 §4.6 — frozen)
  # check_all/5 OVERRIDES the default — ALWAYS answers for every offered tool via
  #   NoizuPromptLingua.Acl.resolve(subject, "mcp.tool", {:ref, Schema.McpTool, canonical_name},
  #                                 default: :allow)   (acl.ex:58)
  #   so the lib's fail-closed default-deny never fires spuriously (PRD-5 §4.2)
  # :deny ⇒ visible+callable false at weight 300; resources: per-tool {:ref, Schema.McpTool, name},
  #   kind wildcard {:ref, Schema.McpTool, :any}, global {:ref, :any, :any},
  #   scope-wide {:ref, Schema.MCPCustomScope, scope_id}
  # allow / no-match ⇒ :allow no-op; supported_kinds [:tool, :toolset]
end
```

---

## 5. Functional requirements

### N2a (hex 0.1.5)

**FR-2A-1 Migration 083.** `db/changelog/083-mcp-tool-sets.yaml` (raw SQL + rollback blocks, style of the 07x/08x files) creates `mcp_tool_sets`:

```sql
create table mcp_tool_sets (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations (id) on delete cascade,
  project_id uuid references projects (id) on delete cascade,
  group_id uuid references groups (id) on delete cascade,
  slug varchar(64) not null,
  display_name varchar(200),
  description text,
  source varchar(20) not null default 'custom' check (source in ('custom','clone')),
  source_profile varchar(64),
  config jsonb not null default '{}'::jsonb,
  settings jsonb not null default '{}'::jsonb,
  expires_at timestamptz,
  is_active boolean not null default true,
  inserted_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table mcp_tool_sets add constraint mcp_tool_sets_org_slug_key unique (organization_id, slug);
create index mcp_tool_sets_org_idx   on mcp_tool_sets (organization_id);
create index mcp_tool_sets_proj_idx  on mcp_tool_sets (project_id);
create index mcp_tool_sets_group_idx on mcp_tool_sets (group_id);
```

Registered in `db.changelog-master.yaml` after the 082 include. Down block drops table + indexes. FK targets verified: `organizations`, `projects`, `groups` (groups name from `schema/authz/group.ex:6` — Decision 8 precondition).

**FR-2A-2 `Schema.MCPToolSet`.** Changeset rules per §4.1: slugify via `SlugBackfill.slugify/1` (`organizations/slug_backfill.ex:26`), reserved-slug block listing `Toolsets.Profiles.slugs/0`, org-wide unique violation surfaced as a friendly changeset error, `config`/`settings` object-shape validation, `is_active` default true, source check.

**FR-2A-3 Closed-vocabulary `config` validation.** The changeset rejects: unknown tool-level keys, unknown arg-level keys, non-map `groups`/`tools`/`args` containers, `rename` colliding with another arg of the same tool, `enum_remove` that is not a list of scalars, `enabled`/`hide` non-boolean. It does NOT validate against the live catalog in N2a (unknown tool/field names pass structurally; full compile-validation lands at N4b via `Validator.compile/3`) — read-side D5 covers staleness: an unknown tool/field at RESOLUTION time is dropped with `Logger.warning`, never 500s a listing.

**FR-2A-4 `to_overrides/1` translator (pure).** Given a valid config map, returns one normalized op per configured change, in stable order (group → tool → arg; tool-level `enabled: false` ⇒ `:set_visible false` + `:set_callable false`), with op names/values EXACTLY the lib PRD-1 §4.5 vocabulary. Purity: no DB/ETS/env access; same input ⇒ same output.

**FR-2A-5 Settings whitelist.** `settings` accepts exactly: `allow_api_keys` (boolean, default true), `description_verbosity` (atom/string: `:full | :concise | :minimal`), `instructions` (string). Anything else ⇒ changeset error (R5 v1).

**FR-2A-6 Shape invariants.** Exactly one audience shape per row: org-set (`project_id nil, group_id nil`), project-set (`project_id set, group_id nil`), group-set (`group_id set, project_id nil`, org still set). Group-sets additionally require the group to be an MCP group id (string registry) — validated at changeset against `MCPServers.customizable()` ids.

**FR-2A-7 Context CRUD + clone.** `create/update/deactivate/list_for_org/get_by_org_and_slug` behave per §4.1. `clone/2` from a profile ⇒ row `source: "clone"`, `source_profile` = profile slug, config = deep-copied allowlist from profile groups (`{"groups": {g => {"enabled": true}}}`), slug auto-suggest `"<slug>-copy"` then `-copy-2`…; from a set ⇒ same with the set's config. Clones are fully editable; profiles are never backed by rows (R1).

**FR-2A-8 Profiles as DATA + annotation registry.** `Toolsets.Profiles` per §4.1: 5 slugs; `groups_for("full")` == ids from `MCPServers.customizable()` (21); every R1 profile group id resolves to a `@servers` entry (`mcp_servers.ex:15`); `@profile_groups` keys compile-checked against the registry — an unknown group id FAILS COMPILATION (Decision 4, D4). R1 mappings: `agent-ops` = organizations, sessions, projects, notifications, memory; `pm-dev` = projects, tickets, review, github, instructions, sessions; `content` = artifacts, assets, wiki, markdown, market, campaigns, customers, unicode; `comms` = chat, notifications, pubsub, personas, memory, wiki.

**FR-2A-9 Profiles are virtual.** No DB rows, no seed data; `get_by_org_and_slug/2` NEVER returns a profile (profile serving resolves at N3 via the resolver, plan §3 N3); the reserved-slug block prevents shadowing (FR-2A-2).

### N2b (gate: lib PRD-4 merge; path dep)

**FR-2B-1 `ToolsetProvider` behaviour.** Implements `Noizu.MCP.Persistence` (PRD-4 §4.1) with the three store keys, expiry exclusion (`expires_at <= at` rows excluded) as a provider invariant, Jason round-trip with atoms restored on read, and `version/2` per §4.1 (max(updated_at)+count per source table + `:vsn`). Put/get/delete on `"toolsets"` delegate to the NPL contexts (PRD-5 §4.1 contract). Provider failures degrade per lib D5 (never crash the server).

**FR-2B-2 Grants mapping (weight 200).** Key/client `toolset_config` translates per the PRD-5 §5 table: `enabled: false` ⇒ `:set_callable false` + `:set_visible false`; `visible: false` ⇒ `:set_visible false`; `name_override`/`description_override` ⇒ `:set_name`/`:set_description`; `expires_at` via `MCP.Window` (`mcp/window.ex`) ⇒ grant expiry; authenticator `:api_key | :oauth`, subject = key/client id (JSON-scalar-legal per PRD-4 §4.4). Inverted-default preservation: absent row ⇒ no ops (no grant row is not a denial — grants-never-hide, Decision 7 / PRD-4 §4.5).

**FR-2B-3 Set config as grant/static layers.** `mcp_tool_sets.config` enters resolution via `ToolSets.to_overrides/1` (now emitting `%Override{}` structs — the N2a map form flips here): set-scope ops are the set's STATIC layer (weight 100 of the assembled `%Custom{}`), and per-caller grants stay weight 200, ACL 300 — the sandwich is testable at 100/200/300 (PRD-4 AC-4.4 shape).

**FR-2B-4 `assemble_custom/2` + `Profiles.custom/1`.** `assemble_custom(set, ctx)` returns `%Noizu.MCP.Toolset.Custom{}`: `slug` = `"set:" <> set.slug`, `base` = the domain server module (org sets ⇒ root aggregate; project/group sets ⇒ same base with metadata pinning), `include` = expanded universe from `config` (explicit ALLOWLIST semantics — empty config ⇒ Discovery/NPL/overview plane only, R2), `tools` = to_overrides map keyed by base canonical name, `immutable: false`, `metadata` = `%{mcp_tool_set_id: id, source: ...}`. `Profiles.custom(slug)` returns the immutable `%Toolset.Custom{}` per Decision 4 (`immutable: true`, `tools: %{}` — slicing only, no ops).

**FR-2B-5 `AclProvider`.** Per §4.2 / PRD-5 §4.2: always-answers `check_all/5`; deny ⇒ visible+callable false (weight 300); resource shapes incl. scope-wide `{:ref, Schema.MCPCustomScope, scope_id}`; `allow`/no-match no-op preserving config-cascade state; `supported_kinds [:tool, :toolset]`.

**FR-2B-6 Zero-writes guard.** A test that runs the FULL N2b suite (provider list/get/put flows, grants mapping, acl checks, assemble paths) against a DB with the lib tables present (`noizu_mcp_toolsets`, `noizu_mcp_toolset_grants`, `noizu_mcp_toolset_negotiations` — created via the lib Runner) and asserts ZERO rows in all three at the end (Decision 2). Source-level companion: no `Repo`/SQL access to `noizu_mcp_*` tables anywhere under `backend/lib` outside the guard itself (AP-11 analog).

**FR-2B-7 Provider selection wiring (deferred activation).** The `providers: [persistence: ToolsetProvider, acl: AclProvider]` opts (PRD-4 §4.3 combined form) are AUTHORED in this phase as a server-opts fragment but activated on real servers only at N5's base-macro flip (plan §3 N5). N2b proves them via direct `Toolset`-protocol calls against fixture servers, not by flipping NPL servers.

---

## 6. Acceptance criteria

**AC-2A-1** Liquibase up creates the table/constraint/indexes exactly per FR-2A-1; `down` reverts; re-run of `up` after manual drop succeeds; master changelog registration present (tag test or changelog-syntax check in CI lane).

**AC-2A-2** Changeset matrix: reserved slug (`full`, `agent-ops`, `pm-dev`, `content`, `comms`) rejected; duplicate `(org, slug)` rejected across SHAPES (org-set vs project-set — org-wide namespace, R4); unsluggable display name ⇒ slugified; missing org rejected; shape invariants (FR-2A-6) enforced including group-id registry check.

**AC-2A-3** Closed-vocabulary matrix (FR-2A-3): each valid key accepted; each unknown key (`name_override`, `arg_overrides`, `enum`, `visible`, typos) rejected with a named error; rename-collision rejected; non-boolean `enabled` rejected.

**AC-2A-4** `to_overrides/1` purity + vocabulary: the §4.1 example config yields exactly [`:set_callable/:set_visible` combos per disabled, `:set_name`, `:set_description`, `:prune_enum`, `:hide_field`, `:rename_field`, `:pin_default`, `:set_arg_description`] with correct targets/values; determinism (two calls, identical term).

**AC-2A-5** Settings whitelist: each v1 key accepted with type checks; unknown/misspelled rejected.

**AC-2A-6** `clone/2`: from profile (source_profile recorded, allowlist config deep-copied, editable) and from set (config copied); slug auto-suggest skips taken slugs; cloned set independent of source (mutating clone does not touch source).

**AC-2A-7** Profiles: `groups_for` each of the 5 == R1 lists (`full` == customizable, 21 groups); `groups_for_tool/1` inverse consistent; compile-time registry validation provably fails on a bad key (negative compile-check test using `Code.compile_string` on a fixture module, or an excluded tagged test documented in the file).

**AC-2A-8** `get_for_request/2` returns nil for inactive sets and sets of other orgs (org+slug scoping precedent `MCPCustomScopes.get_by_org_and_slug/2`, `:250`).

**AC-2B-1** Provider conformance: the lib persistence conformance case (PRD-4 AC-4.1 case module) passes against `ToolsetProvider` for the stores NPL backs (put/get/list/delete/version/expiry/JSON-round-trip/filter-combos).

**AC-2B-2** Grants mapping translation table (PRD-5 §5 rows 1-4) exercised through the provider: a key with `enabled: false` on tool T ⇒ T `visible:false, callable:false` for THAT principal; a client with `name_override` ⇒ listed under the new name for that principal only; a second principal without config sees the base surface (grants-never-hide, AP-10 re-proven at NPL scale).

**AC-2B-3** Weight sandwich: set static hide (100) + grant show (200) ⇒ visible; grant deny (200) + ACL deny (300) ⇒ denied; ACL allow + static hide ⇒ hidden (weights, not layer names, decide).

**AC-2B-4** AclProvider: per-tool deny hides+disables; `:any` wildcards; scope-wide deny; allow/no-match no-op; provider answers for EVERY tool (no default-deny surprise — PRD-2 FR-2.10 inverted deliberately here per PRD-5 §4.2).

**AC-2B-5** `assemble_custom/2` + `Profiles.custom/1` return protocol-dispatchable `%Toolset.Custom{}` values: `Toolset.catalog/3` over a fixture set lists the allowlisted surface with ops applied (rename visible in listing), `immutable: true` profiles ignore grant ops (PRD-3 AC-3.5) while ACL still applies.

**AC-2B-6** Zero-writes guard green (FR-2B-6), including the source-level grep companion.

**AC-2B-7** `version/2` rotates when a source row's `updated_at` advances or a row is added, and is stable across identical states (cheap fingerprint proof — feeds N5/N6 rotation checks).

---

## 7. Test plan

Under `backend/test/`:

- **`noizu_prompt_lingua/mcp/tool_sets_test.exs`** (NEW, N2a) — changeset matrices (AC-2A-2/3/5), context CRUD, clone (AC-2A-6), get_for_request scoping (AC-2A-8), to_overrides purity/vocabulary (AC-2A-4).
- **`noizu_prompt_lingua/mcp/toolsets/profiles_test.exs`** (NEW, N2a) — AC-2A-7 + registry cross-check against `MCPServers.customizable()`.
- **Liquibase lane** — 083 up/down/registration (AC-2A-1) via the repo's changelog test pattern (or a documented manual-verification checklist in the PR if the lane has no Liquibase harness — implementer confirms which exists and records it).
- **`noizu_prompt_lingua/mcp/toolset_provider_conformance_test.exs`** (NEW, N2b; tag `:ecto` for the DB cases, mirroring the lib auth-store suite pattern) — AC-2B-1/2/7.
- **`noizu_prompt_lingua/mcp/acl_provider_test.exs`** (NEW, N2b) — AC-2B-4 matrix.
- **`noizu_prompt_lingua/mcp/tool_sets_assemble_test.exs`** (NEW, N2b) — AC-2B-3/5 incl. 100/200/300 sandwich and immutable profiles.
- **`noizu_prompt_lingua/mcp/zero_writes_guard_test.exs`** (NEW, N2b) — AC-2B-6; tagged to run in CI where the scratch Postgres exists (skip-with-message locally, matching the lib Ecto-suite pattern).

Run scoped per phase: N2a `mix test test/noizu_prompt_lingua/mcp/tool_sets_test.exs test/noizu_prompt_lingua/mcp/toolsets/`; N2b adds the provider/assembler/guard files (require the path dep — run on the integration branch).

---

## 8. Compat & rollback

**N2a**: purely additive (new table, new modules); zero behavior change to existing scopes/keys/clients; `mix.exs` untouched. Rollback = revert PR + Liquibase `down` on 083 (table starts empty in prod until N3 serves sets — no data loss vector).

**N2b**: lives on the integration branch only (path dep); production unaffected; no server opts flip (FR-2B-7). Rollback = drop the branch commits. The zero-writes guard stays green for the entire series; lib tables, once created by any test run, are harmless (lib PRD-4 §8).

**Staged validation gap (explicit)**: between N2a merge and N4b, set configs get structural validation only (FR-2A-3); catalog-compile validation arrives with `Validator.compile/3` at N4b. Read-side D5 (drop + warn, never 500) covers the gap. Documented in both PR descriptions.

---

## 9. Out of scope

- Serving sets over any route (N3), admin API/UI (N4), resolver/endpoint bridge (N3), legacy retirement (N5), migration of scope data INTO the new table (never — sets are new surface; scopes keep their semantics).
- Tool-level annotation overrides (Decision 4).
- `MCP.Window` changes (read-only consumer in FR-2B-2).

---

## 10. Open questions

1. **Project-set FK semantics**: `project_id → projects` — projects are TRP shared-key data (`entities/projects.ex:59` `get_project/1`); confirm the local `projects` table is the right FK target vs. storing the TRP project ref in settings (plan §3 N2a specifies the FK; implementer verifies a local `projects` row exists for every project a set will pin — if TRP-first, the FK becomes nullable documentation and validation moves to the resolver, N3).
2. **`description_verbosity` enum values** — `:full | :concise | :minimal` proposed; confirm (R5 lists the key without values).
3. **Grant-layer sourcing for sets (FR-2B-1 extension)**: sets' caller-facing overrides could ride the provider's `"toolset_grants"` store or stay purely in `assemble_custom`'s static layer. Spec: static layer only (simpler, D1), grants reserved for key/client narrowing. Confirm at N2b review.
4. **`source_set_id`**: cloning a SET records provenance how? Spec: `metadata` jsonb inside settings (`{"cloned_from": slug}`) rather than a column (083 stays as planned). Confirm.

---

## 11. File change map

| Phase | File | Change |
|---|---|---|
| N2a | `backend/db/changelog/083-mcp-tool-sets.yaml` | NEW (FR-2A-1) |
| N2a | `backend/db/changelog/db.changelog-master.yaml` | register 083 (after 082 include, ~`:250`) |
| N2a | `backend/lib/noizu_prompt_lingua/schema/mcp_tool_set.ex` | NEW |
| N2a | `backend/lib/noizu_prompt_lingua/mcp/tool_sets.ex` | NEW (`MCP.ToolSets`) |
| N2a | `backend/lib/noizu_prompt_lingua/mcp/toolsets/profiles.ex` | NEW (data + `@profile_groups`) |
| N2b | `backend/lib/noizu_prompt_lingua/mcp/toolset_provider.ex` | NEW |
| N2b | `backend/lib/noizu_prompt_lingua/mcp/acl_provider.ex` | NEW |
| N2b | `backend/lib/noizu_prompt_lingua/mcp/tool_sets.ex` | `to_overrides/1` → `%Override{}`; `assemble_custom/2` real |
| N2b | `backend/lib/noizu_prompt_lingua/mcp/toolsets/profiles.ex` | add `custom/1` (`%Toolset.Custom{}` builder) |
| both | Tests | §7 |
