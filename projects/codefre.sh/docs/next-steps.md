# Next Steps — codefre.sh Backend Bring-Up

Status as of 2026-05-12: Phase 0 (audit + fixes) complete. 12 backend files modified, 2 new migrations added. No migrations have been executed yet.

---

## Step 1: Verify shared Postgres is running with extensions

**Prompt:**
> Check if the incubator shared docker-compose Postgres is running. If not, start it. Then verify the required extensions are available: `pgvector`, `timescaledb`, `postgis`, `pgcrypto`, `citext`. The backend dev config connects to `localhost:5432` with user `codefresh` / password `codefresh_dev` / database `codefresh_dev`. If the shared Postgres doesn't have a `codefresh` user or the required extensions, create them.

**Files:**
- `docker-compose.yaml` (incubator root)
- `docker/postgres/` (incubator root)
- `app/backend/config/dev.exs` — DB connection config

---

## Step 2: Run all 54 migrations

**Prompt:**
> `cd app/backend && mix deps.get && mix ecto.create && mix ecto.migrate`. There are 54 migration files (52 original + 2 new). Fix any failures — likely candidates: TimescaleDB hypertable syntax, extension ordering (pgvector/timescaledb must be created before tables that use them), or UUID generation (`gen_random_uuid` requires pgcrypto). After migrations pass, run `mix ecto.dump` to capture the schema.

**Files:**
- `app/backend/priv/repo/migrations/` (54 files)
- `app/backend/config/dev.exs`

---

## Step 3: Seed dev data

**Prompt:**
> Run `mix run priv/repo/seeds/dev.exs` to populate the dev database with sample data. If the seed file references context functions that don't exist yet or have mismatched arities, fix them. The seeds should create: 1 org, 1 user, 2-3 scripts with nodes/edges, 2-3 prompts, 2 rubrics, 2 personas, 2 agents, and a few sample runs.

**Files:**
- `app/backend/priv/repo/seeds/dev.exs`
- `app/backend/priv/repo/seeds/seeds_helper.exs` (if exists)

---

## Step 4: Verify backend compiles and starts

**Prompt:**
> `cd app/backend && mix compile --warnings-as-errors && mix phx.server`. Fix any compilation errors from the Phase 0 render/router changes. The server should start on port 5585. Test with `curl http://localhost:5585/health`.

**Files:**
- `app/backend/lib/codefresh_web/` (all controllers modified in Phase 0)
- `app/backend/lib/codefresh_web/router.ex`

---

## Step 5: Smoke-test API against frontend

**Prompt:**
> With the backend running on port 5585, start the frontend with `NEXT_PUBLIC_API_URL=http://localhost:5585/api/v1 npm run dev` from `app/frontend/`. Register a user, create an org, and verify the following pages load with real data: scripts list, prompts list, agents list, runs list. Check the browser network tab for any 404s or 500s from the API.

---

## Step 6: Run existing test suite

**Prompt:**
> `cd app/backend && mix test`. There are 28 test files. Fix failures caused by: (a) migration schema changes, (b) render function signature changes from Phase 0, (c) missing context functions referenced by new controller actions (list_steps, list_scores, logs_by_attr, retry_delivery). Add stubs for any missing context functions that tests or controllers reference.

**Files:**
- `app/backend/test/codefresh/` (context tests)
- `app/backend/test/codefresh_web/controllers/` (controller tests)
- `app/backend/test/support/fixtures.ex`

---

## Step 7: Add missing context functions

**Prompt:**
> The Phase 0 controller changes added new actions that call context functions which may not exist yet. Audit each new action and ensure the backing context function exists:
> - `Runs.list_run_steps(run)` — used by `RunController.list_steps`
> - `Runs.list_run_scores(run)` — used by `RunController.list_scores`
> - `OTel.search_logs(org_id, query)` — used by `OtelController.logs_by_attr`
> - `Webhooks.retry_delivery(org_id, webhook_id, delivery_id)` — used by `WebhookController.retry_delivery`
> - `Webhooks.list_deliveries(org_id, webhook_id)` — used by `WebhookController.deliveries` (now scoped by webhook_id)
>
> Read each context module, check if the function exists, and add it if missing. Use patterns from existing similar functions in the same module.

**Files:**
- `app/backend/lib/codefresh/runs.ex`
- `app/backend/lib/codefresh/otel.ex`
- `app/backend/lib/codefresh/webhooks.ex`

---

## Step 8: Wire frontend to real backend (remove demo mode)

**Prompt:**
> Once the backend is serving real data, test the frontend against it. Remove `NEXT_PUBLIC_DEMO_MODE=true` from `.env.local` and set `NEXT_PUBLIC_API_URL=http://localhost:5585/api/v1`. Walk through every page in the app and verify it renders correctly. Document any remaining mismatches between backend responses and frontend expectations.

---

## Step 9: Implement Oban workers for run execution

**Prompt:**
> The run execution worker at `lib/codefresh/runs/worker.ex` (764 lines) exists but needs verification. Trigger a run via the API (`POST /organizations/:org_id/runs` with script_id and agent_id), then check if the Oban job is enqueued and processes. The worker should: resolve script version, call the agent adapter, record run_steps, score expectations, and update run status to terminal. If the worker crashes or doesn't process, debug using `Oban.drain_queue(:runner)` in IEx.

**Files:**
- `app/backend/lib/codefresh/runs/worker.ex`
- `app/backend/lib/codefresh/runs/scheduler.ex`
- `app/backend/lib/codefresh/agents/adapters/` (adapter implementations)

---

## Step 10: End-to-end golden path test

**Prompt:**
> Write a ConnCase integration test that exercises the full golden path:
> 1. Register user → create org
> 2. Create prompt → publish
> 3. Create rubric → publish
> 4. Create agent (stub adapter) → publish
> 5. Create script → add 2 nodes → add edge → add expectation → publish
> 6. Trigger run → poll until terminal status
> 7. List run steps → verify step shape matches frontend RunStep interface
> 8. List run scores → verify score shape matches frontend RunScore interface
>
> This test validates the entire contract end-to-end.

**Files:**
- `app/backend/test/codefresh_web/controllers/` (new test file)
- `app/backend/test/support/fixtures.ex` (may need new factory helpers)

---

## Reference: What Phase 0 Changed

| File | Changes |
|------|---------|
| `router.ex` | +9 routes (listRunSteps, listRunScores, OTel paths, webhook deliveries, retry, captures promote, review actions) |
| `run_controller.ex` | +list_steps, +list_scores, fixed render_step (sequence/voice/content), fixed render_score (value/label), fixed render_run (joined fields) |
| `agent_controller.ex` | Nested config object, endpoint_url→base_url |
| `webhook_controller.ex` | 3 field renames, computed delivery status, +retry_delivery |
| `otel_controller.ex` | Unix nano time, sample_rate rename, +logs_by_attr |
| `script_controller.ex` | direction enum (positive→maximize), Decimal.to_float(weight), checksum nil guard |
| `persona_controller.ex` | direction enum (positive→pass) |
| `review_controller.ex` | assignee_id/email/notes fixes, status collapsing |
| `enterprise_controller.ex` | SSO config flat extraction |
| `rubric_controller.ex` | +n_samples |
| `dataset_controller.ex` | created_at→inserted_at |
| `sampling_policy.ex` | +enabled field |
| 2 new migrations | auto_flag_rules table, enabled on otel_sampling_policies |

## Reference: Audit Report

Full mismatch inventory at `docs/arch/audit-report.md`.
