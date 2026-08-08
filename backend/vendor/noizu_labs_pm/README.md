# noizu_labs_pm

Shared project-management data layer for the Noizu product family.

`noizu_labs_pm` owns the `Noizu.PM.Repo` Ecto repository (the consolidated
`pm_core` database) and the identity-spine + work-item schemas/entities that
`npl-mcp` (NoizuPromptLingua) and `therobotplans` share. It centralizes the
organizations / projects / users / authz / items / artifacts / wiki / personas
tables that previously lived as byte-identical or near-identical copies in each
app, so the two PM products read and write a single source of truth. Host
applications start `Noizu.PM.Repo` in their own supervision tree; this library
itself stays inert. The schema is managed by the Liquibase changelog under
`db/changelog/`.

## Status

**Always-on shared mode** for host apps until `pm_core` is split out as a
microservice. Migration history / ownership matrix: monorepo
`docs/pm-core-cutover.md`.

Canonical work primitive is **`items`** (NPL `tickets` fold in via ETL /
`ticket_type` → `item_type`). NPL MCP may keep `Ticket.*` tool names as aliases.

## Host wiring (sketch)

```elixir
# mix.exs
{:noizu_labs_pm, path: "../../../Libs/pm"}  # monorepo-relative; adjust

# application.ex children (in addition to App.Repo)
{Noizu.PM.Repo, []}

# runtime — always-on; opt-out only via PM_CORE_ENABLED=0
# PM_CORE_DATABASE_URL=ecto://pm_core:***@app-timescaledb:5432/pm_core
# config :my_app, :pm_core, enabled: true
```
