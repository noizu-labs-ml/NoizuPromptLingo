# pm_core ETL scaffold (Phase 4 prep)

Templates for migrating **shared** PM data from NPL (`tobor_locker`) and TRP
(`therobotplans`) into a greenfield **`pm_core`** database.

**Do not flip app traffic.** The load script may target a live `pm_core` used only
as a shadow DB until `PM_CORE_ENABLED=true`. Prefer a disposable clone when possible.

### Runnable staging load

```bash
# From monorepo (needs kubectl + docker + cluster access):
./Portfolio/Libs/pm/priv/etl/run_staging_etl.sh
```

Loads TRP `items` + NPL `tickets` (as items) + orgs/projects/queues/stages into
`pm_core` via dblink, then PBAC groups/memberships (`11_load_pbac.sql`).
Re-runnable. Does **not** enable app dual-write.

### Helm (default off)

```yaml
# therobotplans values / npl-mcp values
pmCore:
  enabled: false                    # domain cutover
  secretName: pm-core-secrets       # starts Noizu.PM.Repo when URL present
  databaseUrlKey: PM_CORE_DATABASE_URL
```

Canonical plan: monorepo `docs/pm-core-cutover.md` (ETL order § Phase 4).

## Prerequisites

1. Empty (or disposable) `pm_core` with Liquibase master applied  
   (`Portfolio/Libs/pm/db/changelog/db.changelog-master.pm.yaml`).
2. Read-only (or snapshot) access to source DBs — never write back to sources
   during dry runs.
3. Operator-reviewed ID census (overlapping emails, org slugs, project keys).
4. Decisions from cutover doc confirmed (D1–D6), especially:
   - **D1** user merge via OIDC subject / email → one `pm_core` user UUID
   - **D2** TRP wins on org/project collision; NPL FKs re-point via maps
   - Prefer **preserving UUIDs** when no collision

## Environment variables

No real secrets in this tree. Export connection URLs from your secret store
(Infisical / direnv / k8s port-forward) at run time.

| Variable | Purpose | Example shape (fake) |
|----------|---------|----------------------|
| `SOURCE_NPL_URL` | NPL / `tobor_locker` Postgres URL | `postgres://npl_ro:***@127.0.0.1:15432/tobor_locker` |
| `SOURCE_TRP_URL` | TRP / `therobotplans` Postgres URL | `postgres://trp_ro:***@127.0.0.1:15433/therobotplans` |
| `PM_CORE_URL` | Target `pm_core` URL | `postgres://pm_core:***@127.0.0.1:15434/pm_core` |

Optional helpers (operator-defined):

| Variable | Purpose |
|----------|---------|
| `ETL_SCHEMA` | Schema for ID maps if not `public` (default: `public`) |
| `ETL_BATCH_SIZE` | Row batch size for bulk inserts (default: `1000`) |
| `ETL_SOURCE` | Restrict a step to `npl` or `trp` |

Example local port-forwards (illustrative only):

```bash
# After port-forwards / tunnel to non-prod DBs:
export SOURCE_NPL_URL='postgres://npl_ro:${NPL_RO_PASSWORD}@127.0.0.1:15432/tobor_locker'
export SOURCE_TRP_URL='postgres://trp_ro:${TRP_RO_PASSWORD}@127.0.0.1:15433/therobotplans'
export PM_CORE_URL='postgres://pm_core:${PM_CORE_PASSWORD}@127.0.0.1:15434/pm_core'
```

## How to run (order of steps)

Scripts are **templates**. Review, fill TODOs, and run under a transaction or
with explicit checkpoints. Prefer `psql` + dblink/`postgres_fdw` or an external
ETL runner that can read two sources and write one target.

```text
1. Apply Liquibase to empty pm_core (outside this folder).
2. 00_id_maps.sql     → create migration map tables on pm_core
3. 01_order.md        → follow table load order (identity → work → content)
4. Per-table load     → operator scripts / dblink (not automated here)
5. 02_npl_tickets…    → NPL tickets → items (ticket_type → item_type)
6. 03_validate.sql    → count / sample comparisons; fix maps; re-run steps
```

Suggested `psql` invocations (staging only):

```bash
# 1) ID maps on target
psql "$PM_CORE_URL" -v ON_ERROR_STOP=1 -f 00_id_maps.sql

# 2) After operator load scripts for steps 1–7 in 01_order.md…
#    (example only — uncommented templates in 02_ are not safe to run blind)
psql "$PM_CORE_URL" -v ON_ERROR_STOP=1 -f 02_npl_tickets_to_items.sql

# 3) Validation queries (adjust source FDW / dblink first)
psql "$PM_CORE_URL" -v ON_ERROR_STOP=1 -f 03_validate.sql
```

## Idempotency

- Map tables: `CREATE TABLE IF NOT EXISTS` + unique `(source_system, source_id)`.
- Inserts: prefer `ON CONFLICT DO NOTHING` (or map-driven skip) so re-runs do
  not duplicate rows. Patterns appear as comments in the SQL templates.
- Prefer preserving source UUIDs as `pm_id` when free; on collision keep **TRP**
  id and rewrite NPL FKs via the maps (cutover D2).

## Out of scope (stay app-local)

- NPL: sessions, chat, memory, MCP keys, campaigns, etc.
- TRP: goals/OKRs, notifications, recurrence, saved views, voice state

See ownership matrix in `docs/pm-core-cutover.md`.

## Safety checklist

- [ ] `PM_CORE_URL` host is **not** production
- [ ] Sources are read-only or snapshots
- [ ] Write freeze on sources before final ETL pass
- [ ] Validation counts pass before flipping `PM_CORE_ENABLED`
- [ ] Rollback plan: flag off restores app-local DBs during soak
