# Implementation Plan — CodeFresh

**Purpose:** the single source of truth for how this project moves from design (done) to shippable product. Paired with `docs/user-stories/`, `docs/arch/data-model.md`, and `docs/cypress-attributes.md`, which are inputs to this plan.

**Status:** Stage 0 in progress. Stages 0.5–12 pending. See §15 for the exact 151-row per-story execution sequence.

---

## 1. Context

The design phase is complete. We have:

- **150 user stories** under `docs/user-stories/` (15 categories, P0–P3, with `schema_refs` populated)
- **45 Ecto migrations** staged under `app/backend/priv/repo/migrations/`
- **Canonical schema doc** at `docs/arch/data-model.md` (1200 lines, §1–§17)
- **7 persona specs** at `docs/personas/`
- **Cypress attribute conventions** at `docs/cypress-attributes.md`
- **Auth + invite-token system** already implemented in `Codefresh.Accounts`, `AuthController`, with invite-gated signup, seed_helper-backed dev/test/prod seeds, and updated shared init script that provisions all 5 Postgres extensions

What's **not** yet implemented: everything beyond auth. No Prompts / Scripts / Runs / Agents / Dashboards contexts. No product UI. No Cypress. No CI. See §3 for the full inventory.

**Why this plan:** 150 stories × 45 migrations × 7 personas × 4 test layers is too many moving pieces to execute ad-hoc. This plan defines **14 vertical-slice stages** that each ship a coherent feature (schema + context + API + UI + tests) and can be reviewed in isolation. The staging principle is "group by surface area, not by priority" — a P3 story in the same cluster as a P0 story ships with it because context-switching costs more than priority deviation.

---

## 2. Staging Principle

Each stage = **one entity cluster** delivered end-to-end across the stack:

| Layer | Deliverable |
|---|---|
| Database | Migrations applied + rollback-tested |
| Ecto schemas | Modules with `@primary_key {:id, :binary_id, autogenerate: true}` + `@foreign_key_type :binary_id` |
| Contexts | Pure business logic, ≥80% unit coverage via ExUnit + DataCase |
| Controllers | Phoenix routes with ConnCase integration tests + OpenAPI schema emission |
| Frontend | Next.js pages + components with `data-cy` attributes per `docs/cypress-attributes.md` |
| Tests | Cypress smoke per story-group + backend unit + controller integration |
| Docs | `data-model.md` cross-links, `PROJ-LAYOUT.md` updated, story `status` advanced |

A stage is shippable only when **every row** is satisfied. See §7 Definition of Done for the full checklist.

---

## 3. Current State (Inventory)

| Surface | State |
|---|---|
| Migrations | ✅ 45 files written. ❌ **Never run** against any database |
| Ecto schemas | ✅ 4 of ~40: `User`, `Organization`, `Membership`, `InviteToken`. ❌ 36+ missing |
| Contexts | ✅ `Codefresh.Accounts`, `Codefresh.Organizations`. ❌ No Prompts / Scripts / Runs / Agents / Rubrics / Personas / Datasets / OTel / Webhooks / Audit / Review / Dashboards |
| Controllers | ✅ `AuthController` (register, login, refresh, me), `HealthController`. ❌ No other controllers |
| Routes | ✅ `/api/v1/auth/*`, `/health`. ❌ No other routes |
| Seed files | ✅ Populated (dev/test/prod) using seed_helper. ❌ Not yet executed |
| Docker init-databases.sh | ✅ All 5 extensions (pgcrypto, citext, vector, timescaledb, age). Re-run requires `docker compose down -v db` to clear volume |
| Frontend auth | ⚠️ Login + signup exist but forms not in centered card; signup missing `invite_token` field |
| Frontend product UI | ❌ No script editor, no run view, no dashboards, no agent config |
| Cypress | ❌ Not installed. `cyAttrs` helper absent |
| CI | ❌ No `.github/workflows/*.yml` |
| Tests | ❌ Zero ExUnit tests. Zero Cypress tests |
| mix.exs deps | ⚠️ Missing: Oban, `opentelemetry_*`, `open_api_spex`, credo, dialyxir, stream_data, excoveralls |
| Runner / OTP supervisor | ❌ Not written |
| Freeball engine | ❌ Not written |
| OTLP receiver | ❌ Not written |

### Deployment Readiness Matrix

| Goal | Blockers | Time to ready |
|---|---|---|
| **Skeleton deploy** (waitlist with auth) | Verify pgvector in Docker image; run migrations in dev; fix auth-UI; build+push images | ~1 day after decision |
| **Critical-path demo** (author script → run → see results) | Stages 0 through 6 shipped | 6–10 weeks |
| **MVP with CLI + personas + rubrics + review** | Stages 0–8 shipped | 10–14 weeks |
| **Full product with SDKs + OTel + SSO** | Stages 0–12 shipped | 18–26 weeks |

---

## 4. Stage Map

| # | Stage | Task ID | Cluster | Stories | Dep | Primary personas |
|---|---|---|---|---|---|---|
| 0 | Foundations | `#1` 🟡 | migrations, Oban, OTel outbound, OpenAPI spex, Cypress scaffold, CI, auth-UI fix, api_tokens, audit ingest | US-039, 040, 096, 097 | — | Marcus, Priya |
| 0.5 | Contract freeze | `#2` | OpenAPI spec, YAML script schema, rubric DSL JSON-schema, OTLP receiver contract | — | 0 | Alex, Priya |
| 1 | Prompts | `#3` | prompts, prompt_versions | US-009, 010, 011, 048, 049, 050, 114, 115 | 0.5 | Priya, Alex |
| 2a | Rubrics | `#4` | rubrics, rubric_versions | US-033, 034, 056, 057, 058, 059, 060, 119, 120, 121 | 1 | Sofia, Nia |
| 2b | Personas | `#5` | personas, persona_versions, persona_expectations | US-035, 036, 051, 053, 054, 055, 116, 117, 118 | 1 | Yuki, Derek |
| 3 | Scripts + Graph | `#6` | scripts, script_versions, script_nodes, script_edges, expectations | US-001–008, 041–047, 111, 112, 113 | 1, 2a | Priya, Alex |
| 4 | Agents | `#7` | agents, agent_versions | US-012, 013, 014, 061–065, 122, 123 | 0.5 | Priya, Yuki |
| 5 | Runner + basic Freeball | `#8` | runs, run_personas, run_steps, freeball_nodes, freeball_expectations, scores | US-015–024, 052, 066–076, 124, 126–128 | 3, 4, 2b | Priya, Yuki, Derek |
| 6 | Results + Dashboards | `#9` | (queries only) | US-025–032, 077–080, 129, 130 | 5 | Priya, Sofia, Marcus |
| 7 | CLI + CI/CD | `#10` | (no schema; uses API) | US-037, 038, 083–087, 134–136 | 0, 5, 6 | Priya, Alex |
| 8 | Review + Promotion | `#11` | review_queue, branch_promotions | US-088, 089, 090, 137–141 | 3, 5 | Marcus, Sofia, Derek |
| 9 | Datasets + manual captures | `#12` | datasets, dataset_versions, dataset_entries, flagged_captures (manual) | US-101–110, 125, 147 (manual), 148, 149, 150 | 2a, 5 | Nia, Sofia, Derek, Alex |
| 10 | OTel ingest + query | `#13` | otel_spans, otel_logs, otel_sampling_policies | US-081, 082, 098, 099, 100, 131, 132, 133 | 5 | Priya, Yuki |
| 10+ | Auto-flagging rules | `#14` | auto_flag_rules (rules engine + UI) | US-106 (auto), 147 (auto rules) | 9, 10 | Derek, Priya |
| 11 | SDKs + Webhooks | `#15` | webhooks, webhook_deliveries | US-091–095, 144, 145, 146 | 0.5, 5, 10 | Alex, Priya, Nia |
| 12 | Tenancy admin + Enterprise | `#16` | sso_config | US-142, 143 | 0, 8 | Marcus |

🟡 = in progress

**Stage 9 split note:** US-106 has two modes. *Manual* flagging is UI-driven and ships in Stage 9. *Auto-triggered* flagging needs OTel ingest and ships in Stage 10+.

---

## 5. Critical Path (Minimum Demoable E2E)

```
Stage 0 (foundations)
  → Stage 0.5 (contract freeze)
  → Stage 1 (Prompts)
  → Stage 2a (Rubrics — US-033/034 only)
  → Stage 3 (Scripts + Graph)
  → Stage 4 (Agents)
  → Stage 5 (Runner + basic Freeball — P0 freeball only)
  → Stage 6 (Results — P0 only)
```

**~45 P0 stories to demo.** A user can redeem an invite, author a script in the graph editor, attach a prompt and expectations, publish version 1, configure an OpenAI agent, trigger a run, watch the live status stream, and see pass/warn/fail with per-step scores and drill-down.

Stages 7–12 and the P1/P2/P3 tails of every cluster are post-MVP value expansion.

---

## 6. Stage 0 Immediate Checklist

Task `#1` is in progress. Sub-items in order:

- [ ] **Verify pgvector availability** in Docker image: `docker compose exec db psql -U postgres -c "SELECT * FROM pg_available_extensions WHERE name = 'vector';"`
  - If missing: swap image or extend Dockerfile with `postgresql-17-pgvector`
- [ ] **Wipe + reinitialize shared DB volume** (to pick up updated `init-databases.sh`): `cd incubator && docker compose down -v db && docker compose up -d db`
- [ ] **Add mix.exs deps:**
  - `{:oban, "~> 2.x"}`
  - `{:opentelemetry, "~> 1.x"}`, `{:opentelemetry_phoenix, "~> 2.x"}`, `{:opentelemetry_ecto, "~> 1.x"}`, `{:opentelemetry_exporter, "~> 1.x"}`
  - `{:open_api_spex, "~> 3.x"}`
  - `{:stream_data, "~> 1.x", only: [:test]}`
  - `{:excoveralls, "~> 0.x", only: [:test]}`
  - `{:credo, "~> 1.x", only: [:dev, :test], runtime: false}`
  - `{:dialyxir, "~> 1.x", only: [:dev, :test], runtime: false}`
- [ ] **Wire Oban in `application.ex`** supervisor tree; config in `config.exs`
- [ ] **Wire OpenTelemetry outbound** exporter config; instrument Phoenix + Ecto spans
- [ ] **Configure open_api_spex** with base `ApiSpec` module; hook into router
- [ ] **Run migrations in dev**: `cd app && make run-dev` (or `docker compose -f docker-compose.yaml -f docker-compose.dev.yaml up` — migrations auto-run on backend container start)
- [ ] **Run dev seeds**: `MIX_ENV=dev mix run priv/repo/seeds.exs` — captures printed invite tokens from stdout for local testing
- [ ] **Install Cypress** in `app/frontend`: `npm install -D cypress cypress-real-events @types/cypress`
- [ ] **Author `app/frontend/src/utils/cypress.ts`** — `cyAttrs` helper per `docs/cypress-attributes.md` §3
- [ ] **Author `cypress/config.ts`**, `cypress/support/commands.ts` (getByCy, getByCyId, getByCyFor, withinScope, pair), `cypress/support/e2e.ts`
- [ ] **Author `cypress/e2e/smoke.cy.ts`** with four scenarios: login happy, login invalid, signup-with-invite happy, signup-without-invite rejected
- [ ] **Create `app/frontend/src/components/auth-card.tsx`** — centered-card wrapper component using `@the-robot-lives/styleguide` tokens
- [ ] **Refactor login/signup pages** to wrap form in `<AuthCard>`; add `invite_token` input on signup; add `data-cy` attributes throughout; update `auth.tsx` context to forward `invite_token` in register request
- [ ] **Author `.github/workflows/backend.yml`**: mix format, compile --warnings-as-errors, test with coveralls, credo, dialyzer
- [ ] **Author `.github/workflows/frontend.yml`**: npm run lint, tsc --noEmit, npx cypress run (smoke)
- [ ] **Author story-status CI check** that diffs `docs/user-stories/*.md` frontmatter `status` field on feature PRs
- [ ] **Author `scripts/regen-user-stories-index.sh`** — extract from earlier session's Python one-off
- [ ] **Mark US-039, 040, 096, 097, and any auth-UI stories** `status: shipped` in frontmatter

---

## 7. Definition of Done (per stage)

A stage ships only when **all** are true:

1. **Migrations** apply cleanly + roll back cleanly in CI on a disposable DB
2. **Ecto schemas** compile; `@primary_key binary_id` consistent; changesets validated
3. **Contexts** covered ≥80% by ExUnit + DataCase; Dialyzer clean
4. **Controllers** + routes tested via Phoenix.ConnCase (happy + 401 + 422 + 403 cross-org paths)
5. **OpenAPI schema** emitted by `open_api_spex`; diffed against Stage 0.5 contract file on every PR
6. **Frontend pages + components** built with `data-cy` / `data-cy-id` / `data-cy-for` / `data-cy-value` / `data-cy-scope` per `docs/cypress-attributes.md`; TypeScript strict
7. **Cypress E2E** ≥ 1 smoke per story-group under `cypress/e2e/{stage}/{cluster}.cy.ts`; passes locally and in CI
8. **Seeds** (`test-seeds.exs`) expose fixtures via `SeedHelper.set_handle` for downstream stages
9. **Docs updates**: `data-model.md` cross-linked for any schema touched; `PROJ-ARCH.md` / `PROJ-LAYOUT.md` updated if surface grew; CHANGELOG entry in PR description
10. **Observability** — every new controller mutation emits:
    - `audit_events` row (via shared helper)
    - OTel span (via `opentelemetry_phoenix` auto-instrumentation)
11. **Story status** — every story in the cluster advances `status: shipped` in frontmatter; `external_refs.jira/linear/github` populated if synced

---

## 8. Test Strategy (Four Layers)

### Layer 1 — Backend Unit (ExUnit + DataCase)

- Per-context modules: `Accounts`, `Organizations`, `Prompts`, `Scripts`, `Runs`, etc.
- Coverage target: **≥80% of public functions** per module
- `Ecto.Adapters.SQL.Sandbox` isolates DB per test
- **Property-based tests** (StreamData) for:
  - Graph reachability + cycle detection (Stage 3)
  - Version-number monotonicity (all versioned entities)
  - Score aggregation matches verdict logic (direction=negative overrides)
  - Freeball determinism (seeded runner produces identical chains)

### Layer 2 — Controller Integration (Phoenix.ConnCase)

- Per-controller: happy + 401 unauthenticated + 422 validation + 403 cross-org
- JWT-wrapped via `Guardian.Plug.sign_in`
- OpenAPI schema diffed against Stage 0.5 contract file per PR

### Layer 3 — Frontend Cypress E2E

Strict adherence to `docs/cypress-attributes.md`:

- Every addressable element → `data-cy` + `data-cy-id` where applicable
- Cross-linked UI → `data-cy-for` points to sibling `data-cy-id`
- Scoped regions → `data-cy-scope` for `cy.withinScope(...)` constraints
- Derived values → `data-cy-value` — never text-parse
- `cyAttrs` helper spreads attributes; reusable components accept `cy` / `cyId` / `cyFor` props
- Custom commands: `getByCy`, `getByCyId`, `getByCyFor`, `withinScope`, `pair`
- File layout: `cypress/e2e/{stage}/{cluster}.cy.ts` — one file per story-group
- Seeding via `test-seeds.exs` handles; `beforeEach` resets DB state via Sandbox checkout or `mix ecto.reset`

**Cadence:**
- **Per-PR:** smoke suite (login + one happy path per affected cluster)
- **Per-stage:** full suite
- **Nightly:** full suite across every shipped stage

Lint rules forbid class-based selectors, `nth-*`, inline text, SVG-path.

### Layer 4 — Contract + Infrastructure Tests

- **SDK contract tests** (Stage 11): Python/Elixir/TS suites assert clients match Stage 0.5 OpenAPI
- **OTel hypertable schema tests** (Stage 0, Stage 10): migration-level property tests verify chunk interval, compression policy, retention
- **Migration rollback tests** (Stage 0): every migration tested up-down-up in CI
- **Audit-emit tests**: every controller mutation emits an `audit_events` row (per-controller ConnCase assertion)

---

## 9. CI Gates (per PR)

1. ✅ All migrations apply cleanly + roll back cleanly on a disposable DB
2. ✅ `mix format --check-formatted`
3. ✅ `mix compile --warnings-as-errors`
4. ✅ `mix test` with ≥80% coverage on touched contexts (via `mix coveralls.html`)
5. ✅ `mix credo --strict`
6. ✅ `mix dialyzer` (warm cache)
7. ✅ Frontend: `npm run lint` + `tsc --noEmit`. **NOT** `npx next build` during dev CI (per project convention — type-check only)
8. ✅ Cypress smoke suite passes on affected clusters; full on main
9. ✅ OpenAPI schema diff: additions/deprecations only; **no breaking changes**
10. ✅ At least one story's `status` advanced (feature PR: `ready` → `in-progress`; release PR: `in-progress` → `shipped`)

---

## 10. Cross-Stage Dependencies (Non-Obvious Couplings)

Stories living in one cluster but *gating* on another stage's work:

| Story | Lives in | Gates on | Reason |
|---|---|---|---|
| US-059 (re-score past run) | 2a Rubrics | Stage 6 (run history) | Can't re-score runs that don't exist |
| US-069 (scheduled runs) | 5 Runner | **Stage 0** (Oban) | Scheduler infra is foundational |
| US-090 (promote freeball chain) | 8 Review | Stage 3 (fork API) | Promotion produces new `script_version` |
| US-094 (SDK OTel bridge) | 11 SDKs | Stage 10 (OTel receiver) | Bridge needs the receiver to exist |
| US-105 (dataset run) | 9 Datasets | Stage 5 (runner) | Unifies with runs schema |
| US-106 / US-147 auto-flagging | 9 Datasets | Stage 10 (OTel ingest) | Auto-rules evaluate on inbound spans |
| US-087 (CLI login) | 7 CLI | **Stage 0** (US-096/097 forward-loaded) | Login issues API tokens |

Implementers: write the code in the entity-cluster stage, guard runtime activation behind the blocking stage's readiness flag.

---

## 11. Story Status Workflow

Story frontmatter `status` field is the single source of truth. Lifecycle:

```
draft → triaged → ready → in-progress → in-review → shipped
                                              ↓
                                          cancelled
```

- `draft` — initial (all stories start here)
- `triaged` — stage assigned, priority confirmed
- `ready` — accepted into the current stage PR; ACs frozen
- `in-progress` — implementation active (feature PR open)
- `in-review` — PR in final review
- `shipped` — merged + released
- `cancelled` — rejected or deprecated

`docs/user-stories/index.md` is regenerated per stage PR via `scripts/regen-user-stories-index.sh`.

---

## 12. Session Task Tracking

The TaskCreate system has one task per stage (Task IDs 1–16). Check progress via `TaskList`. Stage 0 is the currently in-progress task (ID `#1`); others are pending with `blockedBy` dependencies mirroring §4's stage map.

Task IDs for quick reference:
- `#1` Stage 0 — Foundations 🟡
- `#2` Stage 0.5 — Contract Freeze
- `#3` Stage 1 — Prompts
- `#4` Stage 2a — Rubrics
- `#5` Stage 2b — Personas
- `#6` Stage 3 — Scripts + Graph
- `#7` Stage 4 — Agents
- `#8` Stage 5 — Runner + basic Freeball
- `#9` Stage 6 — Results + Dashboards
- `#10` Stage 7 — CLI + CI/CD
- `#11` Stage 8 — Review + Promotion
- `#12` Stage 9 — Datasets + Manual Captures
- `#13` Stage 10 — OTel ingest + query
- `#14` Stage 10+ — Auto-flagging rules
- `#15` Stage 11 — SDKs + Webhooks
- `#16` Stage 12 — Tenancy admin + Enterprise

---

## 13. Verification Checkpoints

### Stage 0 exit

```bash
cd app/backend
mix test && mix credo --strict && mix dialyzer
cd ../frontend
npm run lint && npx tsc --noEmit
npx cypress run --spec cypress/e2e/smoke.cy.ts
```

Expected: all green. All 45 migrations apply + roll back on a disposable DB. GitHub Actions backend + frontend workflows green on PR.

### Critical-path exit (Stage 6 shipped)

A user can execute this flow end-to-end:

1. Redeem dev invite token → user + org + membership created
2. Author a 3-node / 2-edge script in the graph editor
3. Attach 2 expectations (one LLM-as-judge with rubric, one regex)
4. Publish script v1
5. Configure OpenAI agent; pass health check
6. Trigger run; watch live status stream; see pass/warn/fail verdict; drill into step JSON
7. View run in `/runs`; filter by script; open detail; see conversation timeline

### Full-plan exit (Stage 12 shipped)

- OSS CLI installable: `brew install codefresh` + `codefresh run script.yaml --agent=<slug>` works end-to-end
- Python SDK: `pip install codefresh; client.runs.create(...)` works against hosted API
- OTel bridge: agent emits spans → they correlate to run_steps → visible in trace drill-down
- SOC2 story: audit log export produces CSV of all admin actions since org creation
- SSO: SAML login works via configured IdP

---

## 14. Memory + Process Notes

Two session-level preferences that guide execution:

1. **Document-first for data-layer work** — design docs + schema + personas + migrations before implementation; migrations don't auto-run on approval of design docs. Stage 0 represents the explicit transition from design to implementation.
2. **Parallel haiku taskers for bulk file work** — reformats, validations, and fan-out analyses default to parallel `npl-tasker-haiku` agents (one per file or small batches) rather than regex one-shots. This project used that pattern successfully for the schema-requirements analyst pass and story-format cleanup.

These are stored at `~/.claude/projects/.../memory/` and applied automatically in future sessions.

---

## 15. Exact Implementation Sequence

Recommended total order for all 150 user stories. Within each stage, stories are ordered by dependency chain (fewer deps first). Stories that live in one stage but *gate* on a later stage's work are noted with "← gated on …" — schema/context/API scaffolding happens in-stage, runtime activation is deferred behind a feature flag or TODO until the blocking stage ships.

**Critical path to demoable MVP = seqs 1–93 (Stages 0 → 6, ~45 P0 stories).** Seqs 94–150 are post-MVP value expansion.

### Stage 0 — Foundations (seqs 1–4)

Mostly infrastructure chores (see §6 checklist for the full list); four story-level deliverables.

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 1 | US-039 | P0 | Create an organization | — |
| 2 | US-040 | P0 | Invite user as member of organization | US-039 |
| 3 | US-096 | P1 | Issue an API token *(forward-loaded from Wave 2)* | US-039 |
| 4 | US-097 | P1 | Revoke / rotate API token *(forward-loaded)* | US-096 |

### Stage 0.5 — Contract freeze (no stories)

### Stage 1 — Prompts (seqs 5–12)

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 5 | US-009 | P0 | Create a standalone prompt | — |
| 6 | US-010 | P0 | Publish a new prompt version | US-009 |
| 7 | US-011 | P0 | Reference a published prompt from a script node | US-010 *(script-node side stubbed; final wiring in Stage 3 via US-003)* |
| 8 | US-050 | P1 | Browse the prompt library | US-009 |
| 9 | US-048 | P1 | Define template variables on a prompt | US-010 |
| 10 | US-049 | P1 | Define tool / function schemas on a prompt | US-010 |
| 11 | US-114 | P2 | Prompt testing sandbox | US-010 |
| 12 | US-115 | P3 | Loops / conditionals in prompt templating | US-048 |

### Stage 2a — Rubrics (seqs 13–19, with 3 deferred to Stage 6 tail)

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 13 | US-033 | P0 | Create simple rubric with LLM-as-judge | US-010 |
| 14 | US-034 | P0 | Attach a rubric to an expectation | US-033 *(expectation side stubbed; wire via US-004 in Stage 3)* |
| 15 | US-056 | P1 | Weighted multi-criterion rubric | US-033 |
| 16 | US-057 | P1 | Ladder / enum scoring scale | US-033 |
| 17 | US-058 | P1 | Preview rubric by scoring sample | US-033 |
| 18 | US-119 | P2 | Rubric marketplace | US-033 |
| 19 | US-120 | P2 | Rubric confidence bands (n_samples) | US-033 |

*Deferred to near end of Stage 6 (see seqs 99–101): US-059, US-060, US-121 — all depend on run history existing.*

### Stage 2b — Personas (seqs 20–27, with 2 deferred to Stage 6+)

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 20 | US-035 | P0 | Create a basic persona with tone | — |
| 21 | US-036 | P0 | Attach a persona to a run | US-035 *(runtime wiring gated on Stage 5)* |
| 22 | US-053 | P1 | Attach system-prompt preamble to persona | US-035, US-010 |
| 23 | US-055 | P1 | Import persona from shared starter library | US-035 |
| 24 | US-051 | P1 | Layered persona expectations | US-035 *(expectation side stubbed via US-004 in Stage 3)* |
| 25 | US-116 | P2 | Import persona from marketplace | US-055 |
| 26 | US-118 | P3 | Per-step persona switching mid-run | US-036 *(gated on Stage 5)* |

*Deferred: US-054, US-117 — depend on Stage 5 fan-out + Stage 6 dashboards respectively.*

### Stage 3 — Scripts + Graph (seqs 28–45)

Strict dependency chain. This is the largest single-stage effort (18 stories).

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 28 | US-001 | P0 | Create empty script with name + description | — |
| 29 | US-002 | P0 | Add user-turn node to script | US-001 |
| 30 | US-003 | P0 | Attach a prompt to a script node | US-002, US-011 |
| 31 | US-004 | P0 | Add an expectation to a script node | US-002 *(finalizes US-034, US-051 wiring)* |
| 32 | US-005 | P0 | Add directed edge with match condition | US-002 |
| 33 | US-006 | P0 | Publish first version of a script | US-001, US-003, US-005 |
| 34 | US-041 | P1 | Add system-prompt node | US-002 |
| 35 | US-042 | P1 | Add terminal node | US-002 |
| 36 | US-047 | P1 | Archive a script | US-001 |
| 37 | US-008 | P0 | Export script to YAML | US-006 |
| 38 | US-007 | P0 | Import script from YAML | US-001, US-006 |
| 39 | US-044 | P1 | Start new draft from published version | US-006 |
| 40 | US-046 | P1 | Fork published script to new head | US-006 |
| 41 | US-045 | P1 | Diff two script versions | US-006 |
| 42 | US-111 | P2 | Bulk node operations in editor | US-002 |
| 43 | US-112 | P2 | Inline comments on script nodes | US-002 |
| 44 | US-113 | P3 | Auto-layout the graph | US-002 |
| 45 | US-043 | P1 | Freeball-anchor node | US-002 *(gated on Stage 5 for runtime behavior)* |

### Stage 4 — Agents (seqs 46–55)

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 46 | US-012 | P0 | Configure OpenAI agent adapter | — |
| 47 | US-014 | P0 | Publish an agent version | US-012 |
| 48 | US-013 | P0 | Test agent connectivity via health check | US-012 |
| 49 | US-061 | P1 | Anthropic agent adapter | US-012 |
| 50 | US-063 | P1 | Arbitrary HTTP agent adapter | US-012 |
| 51 | US-062 | P1 | LangChain agent adapter | US-012 |
| 52 | US-064 | P1 | Per-agent cost cap + rate limit | US-012 |
| 53 | US-065 | P1 | Agent health on list page | US-013 |
| 54 | US-122 | P2 | Bedrock + Vertex adapters | US-012 |
| 55 | US-123 | P2 | Agent streaming responses | US-012 |

### Stage 5 — Runner + basic Freeball (seqs 56–81)

P0 chunk (seqs 56–65) is the **MVP demo spine**. Everything after seq 65 is value expansion.

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 56 | US-015 | P0 | Trigger a one-off run from the editor | US-006, US-014 |
| 57 | US-016 | P0 | View run status update in real time | US-015 |
| 58 | US-017 | P0 | See each step's prompt + agent response | US-015 |
| 59 | US-018 | P0 | Cancel an in-flight run | US-015 |
| 60 | US-020 | P0 | See individual step scores | US-015, US-033, US-034 |
| 61 | US-019 | P0 | Run-level pass/warn/fail verdict | US-020 |
| 62 | US-021 | P0 | Aggregate run score summary | US-020 |
| 63 | US-022 | P0 | Fall through to freeball | US-015, US-005 |
| 64 | US-023 | P0 | See freeball-generated prompt | US-022 |
| 65 | US-024 | P0 | See freeball runner confidence | US-022 |
| 66 | US-052 | P1 | Fan out across personas in parallel | US-036, US-015 *(finalizes US-036 activation)* |
| 67 | US-066 | P1 | Retry failed run from failing step | US-015 |
| 68 | US-067 | P1 | Enforce run-level cost cap | US-015, US-064 |
| 69 | US-069 | P1 | Schedule recurring runs (Oban) | US-015 |
| 70 | US-070 | P1 | Batch run against multiple agents | US-015 |
| 71 | US-071 | P1 | Configure freeball runner per org | US-022 |
| 72 | US-072 | P1 | Enforce freeball depth cap / budget | US-022 |
| 73 | US-074 | P1 | Freeball strict mode on a node | US-022 |
| 74 | US-075 | P1 | Freeball required mode on a node | US-022 |
| 75 | US-073 | P1 | Freeball within freeball | US-022, US-072 |
| 76 | US-076 | P1 | Runner capability-match warning | US-022, US-071 |
| 77 | US-068 | P1 | Stream scores in real time | US-016, US-020 |
| 78 | US-124 | P2 | Cost prediction before run | US-015 |
| 79 | US-126 | P3 | Freeball confidence distribution histograms | US-024 |
| 80 | US-128 | P3 | Adaptive freeball depth based on confidence | US-072 |
| 81 | US-127 | P3 | Freeball learning mode | US-090 *(gated on Stage 8)* |

### Stage 6 — Results + Dashboards (seqs 82–103)

Closes the critical-path demo at seq 93. Seqs 94–103 are P1+ dashboard polish + deferred stories from Stage 2a/2b/5.

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 82 | US-025 | P0 | List recent runs for organization | US-015, US-039 |
| 83 | US-029 | P0 | Open run detail from list | US-025, US-017 |
| 84 | US-026 | P0 | Filter runs by script | US-025 |
| 85 | US-027 | P0 | Filter runs by agent | US-025 |
| 86 | US-028 | P0 | Filter runs by status | US-025 |
| 87 | US-030 | P0 | View conversation as linear timeline | US-029 |
| 88 | US-031 | P0 | Drill down into step JSON | US-029 |
| 89 | US-032 | P0 | Export run as JSON | US-029 |
| 90 | US-077 | P1 | Side-by-side diff of two runs | US-015 |
| 91 | US-079 | P1 | Filter runs by date range | US-025 |
| 92 | US-080 | P1 | Filter runs by persona | US-025, US-036 |
| 93 | US-078 | P1 | Trend chart of scores over time | US-021, US-025 |
|   | ⬆ *Critical-path MVP demo complete at seq 93* | | | |
| 94 | US-129 | P2 | Cohort comparison across runs | US-070 |
| 95 | US-130 | P3 | Custom dashboard builder | US-078 |
| 96 | US-059 | P1 | Re-score past run with newer rubric | US-033, US-020 *(deferred from Stage 2a)* |
| 97 | US-060 | P1 | Side-by-side score comparison across rubric versions | US-059 *(deferred from 2a)* |
| 98 | US-121 | P3 | Rubric disagreement analytics | US-060 *(deferred from 2a)* |
| 99 | US-054 | P1 | Per-persona results breakdown | US-052 *(deferred from 2b)* |
| 100 | US-117 | P3 | Persona heatmap visualization | US-054 *(deferred from 2b)* |

### Stage 7 — CLI + CI/CD (seqs 101–110)

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 101 | US-037 | P0 | Run script via codefresh CLI with YAML | US-008, US-015 |
| 102 | US-038 | P0 | CLI pass/fail exit code | US-037, US-019 |
| 103 | US-087 | P1 | codefresh login + token management | US-096 *(already shipped in Stage 0)* |
| 104 | US-083 | P1 | Emit JUnit XML from CLI | US-037, US-019 |
| 105 | US-085 | P1 | GitHub Actions reusable workflow | US-037, US-038, US-083 |
| 106 | US-086 | P1 | GitLab CI template | US-037, US-083 |
| 107 | US-084 | P1 | CLI --personas flag | US-037, US-052 |
| 108 | US-134 | P2 | codefresh init scaffolding | US-087 |
| 109 | US-136 | P3 | TAP + Allure output formats | US-083 |
| 110 | US-135 | P3 | CLI watch mode | US-037 |

### Stage 8 — Review + Promotion (seqs 111–118)

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 111 | US-088 | P1 | Show freeball review queue | US-022 |
| 112 | US-089 | P1 | Claim / approve / reject freeball | US-088 |
| 113 | US-090 | P1 | Promote freeball chain to new script_version | US-089, US-006 |
| 114 | US-138 | P2 | Bulk review queue actions | US-089 |
| 115 | US-140 | P2 | Review assignment workflow | US-088 |
| 116 | US-137 | P2 | Regression suite from rejected freeballs | US-089 |
| 117 | US-139 | P3 | Promote freeball to persona expectation | US-089, US-051 |
| 118 | US-141 | P3 | Freeball SLA aging alerts | US-140 |

### Stage 9 — Datasets + Manual Captures (seqs 119–132)

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 119 | US-101 | P1 | Create dataset | — |
| 120 | US-103 | P1 | Add entries to dataset manually | US-101 |
| 121 | US-102 | P1 | Publish dataset version | US-101, US-103 |
| 122 | US-110 | P1 | Attach rubric to dataset | US-101, US-033 |
| 123 | US-104 | P1 | Import dataset from CSV / JSON | US-101 |
| 124 | US-105 | P1 | Run dataset against agent (model-based eval) | US-102, US-014, US-110 |
| 125 | US-106 | P1 | Flag OTel span / interaction *(manual mode only; auto in Stage 10+)* | US-029 |
| 126 | US-107 | P1 | Browse flagged captures library | US-106 |
| 127 | US-108 | P1 | Promote flag to script node input | US-107, US-044 |
| 128 | US-109 | P1 | Promote flag to dataset entry | US-107, US-103 |
| 129 | US-149 | P2 | HuggingFace datasets integration | US-104 |
| 130 | US-150 | P2 | Dataset Parquet export | US-102 |
| 131 | US-125 | P3 | Dataset-run persona fan-out | US-105, US-052 |
| 132 | US-148 | P3 | Flag digest email | US-107 |

### Stage 10 — OTel ingest + query (seqs 133–140)

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 133 | US-081 | P1 | OTLP gRPC receiver endpoint | US-015 |
| 134 | US-082 | P1 | Correlate OTel spans to run_steps | US-081 |
| 135 | US-098 | P1 | Query OTel spans by attribute | US-082 |
| 136 | US-099 | P1 | Drill down from step → OTel trace | US-082 |
| 137 | US-100 | P1 | Semantic search over span names (pgvector/Weaviate) | US-082 |
| 138 | US-131 | P2 | OTel partition + retention admin | US-081 |
| 139 | US-132 | P2 | OTLP sampling configuration | US-081 |
| 140 | US-133 | P3 | ClickHouse mirror for OTel | US-081 |

### Stage 10+ — Auto-flagging (seq 141)

US-106's auto-mode path finalizes here; US-147 implements the rule engine that drives it.

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 141 | US-147 | P2 | Auto-flagging rules for production captures | US-106, US-082 |

### Stage 11 — SDKs + Webhooks (seqs 142–149)

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 142 | US-091 | P1 | Python SDK core | US-096 |
| 143 | US-092 | P1 | Elixir SDK core | US-096 |
| 144 | US-093 | P1 | TypeScript SDK core | US-096 |
| 145 | US-095 | P1 | SDK query helpers | US-091 |
| 146 | US-094 | P1 | SDK OTel bridge helper | US-081, US-091 |
| 147 | US-144 | P2 | SDK webhook subscriptions | US-091 |
| 148 | US-145 | P3 | React hooks package | US-093 |
| 149 | US-146 | P3 | SDK Deno / Bun publish | US-093 |

### Stage 12 — Tenancy admin + Enterprise (seqs 150–151)

| # | Story | P | Title | Dependencies |
|---|---|---|---|---|
| 150 | US-143 | P2 | Audit log export | *(audit ingest already writing since Stage 0)* |
| 151 | US-142 | P2 | SSO via SAML / OIDC | US-039 |

*Total: 151 sequence entries; US-106 spans two stages (manual mode in Stage 9 seq 125, auto-mode finalized alongside US-147 in Stage 10+ seq 141) but counts as one story in the 150-story total.*

### Notes on this sequence

1. **Deferred stories** (US-059, US-060, US-121, US-054, US-117, US-127) have their schema + context work scaffolded in their home stage but final runtime activation happens at the later stage indicated. Implementers should leave a TODO comment or feature flag at the deferral point.
2. **Forward-loaded stories** (US-096, US-097 pulled from Wave 2's Stage 11 home to Stage 0) are implemented in full at Stage 0 because downstream stages (CLI login at US-087, SDK auth) require them.
3. **Stub-then-finalize pattern** appears at US-011 (Stage 1 stubs the node-side), US-034 (Stage 2a stubs expectation link), US-051 (Stage 2b stubs expectation link). Their stubs become real when Stage 3 ships node + edge + expectation schemas.
4. **The critical-path demo closes at seq 93** (US-078 trend chart). Implementing 1–93 strictly in order yields demoable MVP. The sequence is validated against each story's `dependencies` frontmatter.
5. **Parallel execution**: Stages 2a and 2b can be implemented in parallel (both depend only on Stage 1). Stages 4 can start as soon as Stage 0.5 ships (contract freeze); it has no dependency on Stages 1/2. If you have the headcount, these branches can run concurrently.

## 16. References

### Design inputs

- `docs/user-stories/README.md` — conventions, categories, epics, priority distribution
- `docs/user-stories/index.md` — catalog of all 150 stories (auto-regenerated)
- `docs/user-stories/US-*.md` — individual story files with Jira/Linear/GitHub frontmatter
- `docs/arch/data-model.md` — canonical schema (§1–§17 including §14.1–§14.16 additions)
- `docs/arch/schema-requirements.md` — analyst-derived schema deltas per story batch
- `docs/arch/freeball-protocol.md` — freeball state machine + promotion lifecycle
- `docs/personas/*.md` — 7 persona specs
- `docs/cypress-attributes.md` — selector philosophy + `cyAttrs` helper + custom commands
- `docs/PROJ-ARCH.md`, `docs/PROJ-LAYOUT.md` — system architecture + directory map

### Code inputs

- `app/backend/priv/repo/migrations/` — 45 migrations (2 pre-existing + 17 Wave 1 + 5 Wave 2 + 20 Wave 3 + 1 invite_tokens)
- `app/backend/lib/codefresh/accounts.ex`, `organizations.ex` — existing contexts
- `app/backend/lib/codefresh/accounts/{user,membership,invite_token}.ex` — existing schemas
- `app/backend/lib/codefresh/organizations/organization.ex` — existing schema
- `app/backend/lib/codefresh_web/controllers/auth_controller.ex` — invite-gated register + login + refresh + me
- `app/backend/priv/repo/seeds/{dev,test,prod}-seeds.exs` — seed_helper-driven fixtures
- `incubator/docker/postgres/init-databases.sh` — DB bootstrap with 5 extensions

### Plan documents (non-repo)

- `/Users/keithbrings/.claude/plans/we-will-need-a-sparkling-hennessy.md` — canonical strategy plan (this doc's source of truth)
