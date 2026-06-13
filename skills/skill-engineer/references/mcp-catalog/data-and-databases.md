# Category: Data and Databases

## Overview
Use tools in this category when a skill needs to query, migrate, or manage structured data as part of its workflow. Common scenarios: schema-aware code generation, data migration scripts, real-time sync patterns, branch-based testing environments, and multi-database administration. The key design decision is read-only vs. read-write access — most production workflows should default to read-only MCP connections and promote writes through a separate approval step.

## MCP Services

| Name | Deployment | Key Features | Security Notes | Maturity |
|------|-----------|-------------|----------------|----------|
| PostgreSQL MCP (official) | Local stdio | Read-only, schema inspection | No write access by design | Stable |
| Neon MCP | Hosted SSE / local stdio | 20 tools, branch-based safety, OAuth remote | Branch isolation protects production | Stable |
| Supabase MCP | Hosted SSE / local stdio | Multi-project, real-time, edge functions | Supabase service role key required | Stable |
| SQLite MCP (official) | Local stdio | Local file, read+write | File path determines scope | Stable |
| MongoDB MCP (official) | Local stdio | Atlas + local, aggregation pipeline | Atlas API key or connection string | Stable |
| DBHub | Local stdio | Universal: Postgres/MySQL/MariaDB/SQLServer/SQLite, SSH tunneling | SSH tunnel for remote DBs | Beta |
| Convex | Hosted SaaS | Full-stack, real-time sync, TypeScript-native | Managed platform, Convex account | Stable |
| Prisma MCP | Local stdio | Schema-aware, migration planning | Reads schema file + DB | Beta |
| Postgres MCP Pro | Local stdio | Configurable read/write, index recommendations | Write mode needs explicit opt-in | Beta |

---

### Neon MCP
- **What it does**: Full-featured MCP server for Neon serverless Postgres with 20 exposed tools covering database creation, branch management, schema inspection, query execution, and migration tracking. The branching model is the killer feature — each dev or test session gets an isolated database branch that can be deleted without affecting production.
- **Deployment**: Two modes: (1) remote hosted SSE at `https://mcp.neon.tech` with OAuth — no local setup; (2) local stdio via `npx @neondatabase/mcp-server-neon` with a Neon API key
- **Key features**: 20 MCP tools including `create_branch`, `delete_branch`, `run_sql`, `list_projects`, `get_connection_string`, `run_migration`; branch-based isolation (create a branch per feature/agent run, delete when done); serverless auto-suspend (no idle costs); OAuth remote mode means zero local config for end users; `run_migration` validates SQL before applying; schema diffing between branches
- **Security considerations**: Branch isolation is the primary safety mechanism — agent writes go to a branch, not main. Production branch should be accessed read-only; use branch credentials for agent sessions. OAuth remote mode means credentials are managed by Neon's auth server, not stored locally. API key scoping: use project-scoped keys, not org-wide keys.
- **When to use**: Serverless Postgres workloads (Next.js, edge functions); any skill involving database migrations (branch = safe sandbox); dev/test environment automation; skills that need to provision ephemeral databases per workflow run; remote OAuth mode when end users should not manage connection strings.
- **When to avoid**: Existing self-hosted Postgres infrastructure (use DBHub or Postgres MCP Pro instead); when data must never leave a private network (Neon is SaaS); workloads requiring persistent connections (Neon auto-suspends after inactivity).

---

### DBHub
- **What it does**: Universal database MCP server that connects to Postgres, MySQL, MariaDB, SQL Server, and SQLite through a single interface. SSH tunneling support makes it the right choice for accessing databases on private networks or remote servers.
- **Deployment**: Local stdio; `npx @dbhub/mcp` or Docker; connection configured via environment variables or a `dbhub.config.json` file
- **Key features**: Single MCP server for 5 database engines (no engine-specific server needed); SSH tunnel support for remote/private databases (jump host, private key auth); schema inspection across all engines; SQL execution with configurable read/write mode; table listing, column metadata, index inspection; connection string or individual credential config
- **Security considerations**: SSH private key path must be accessible to the process — store in `~/.ssh/`, not in project directories. Read-only mode (default) prevents accidental writes. Connection strings in config files should use env var interpolation (`${DB_PASSWORD}`) rather than hardcoded values. The universal nature means a misconfigured connection string could point to the wrong database engine silently.
- **When to use**: Polyglot database environments (multiple engines in one project); remote databases accessible only via SSH tunnel; legacy MySQL or SQL Server databases that lack a dedicated MCP server; skills that need to work across client databases with heterogeneous stacks.
- **When to avoid**: When Neon branching or Supabase real-time features are needed; when the target is exclusively Postgres with advanced needs (use Postgres MCP Pro for index recommendations); when the user's database is already on Supabase or Neon (use native MCP for deeper feature access).

---

### Supabase MCP
- **What it does**: Official Supabase MCP server exposing database operations, real-time subscriptions, storage management, edge function deployment, and auth user management across multiple Supabase projects.
- **Deployment**: Local stdio via `npx @supabase/mcp-server-supabase`; requires a Supabase personal access token (not the anon/service key); also available as a remote hosted endpoint
- **Key features**: Multi-project management (list and switch between Supabase projects); schema inspection and SQL execution; edge function deployment and logs; storage bucket management; auth user listing and admin actions; real-time channel inspection; Row Level Security policy listing; migration history tracking; `apply_migration` for schema changes with rollback metadata
- **Security considerations**: Requires a Supabase personal access token (PAT) with project-level permissions — this is more privileged than an anon key. Treat the PAT like a database superuser credential. RLS policies visible but not enforced by the MCP connection (MCP uses service role). Any SQL executed bypasses RLS — validate inputs carefully in agentic contexts. Use read-only SQL queries for inspection; gate `apply_migration` calls behind human approval.
- **When to use**: Projects already deployed on Supabase; skills involving real-time features, auth management, or edge functions alongside database access; multi-project management workflows; Supabase-native scaffolding skills that need to inspect and modify schema during setup.
- **When to avoid**: Non-Supabase Postgres instances (use DBHub or Postgres MCP Pro); when RLS enforcement in the MCP connection is required (service role bypasses it); when the end user does not have a Supabase PAT and account setup overhead is a barrier.

---

## CLI Tools

| Name | Install | What It Does | Skill Relevance |
|------|---------|-------------|-----------------|
| `psql` | OS package manager | Postgres interactive + scripted queries | Direct DB access for migrations |
| `supabase` | `npm i -g supabase` | Supabase CLI: local dev, migrations, deploy | Local Supabase stack management |
| `neon` | `npm i -g neonctl` | Neon CLI: branch/project management | Branch automation in CI |
| `prisma` | `npm i -g prisma` | ORM CLI: schema push, migrate, studio | Schema-driven DB management |
| `dbmate` | Homebrew / binary | Language-agnostic migration runner | Raw SQL migration workflows |

---

## Selection Guide

**Choose by database platform:**

| Platform | Best MCP | Fallback |
|----------|---------|---------|
| Neon serverless Postgres | Neon MCP | Postgres MCP Pro |
| Supabase | Supabase MCP | DBHub |
| Self-hosted Postgres | Postgres MCP Pro | DBHub |
| MySQL / MariaDB | DBHub | Native MySQL MCP |
| SQL Server | DBHub | None (DBHub is the only option) |
| SQLite | SQLite MCP (official) | DBHub |
| MongoDB Atlas | MongoDB MCP (official) | — |
| Multi-engine polyglot | DBHub | — |

**Choose by feature need:**

| Need | Best Choice |
|------|------------|
| Branch-per-agent isolation | Neon MCP |
| SSH tunnel to private network | DBHub |
| Real-time + auth + storage | Supabase MCP |
| Index recommendations | Postgres MCP Pro |
| Schema-aware migration planning | Prisma MCP |
| Zero-config remote OAuth | Neon MCP (remote SSE) |

**Read-only vs. read-write:**
- Default to read-only for all production connections
- Use Neon branches or SQLite for agent write workflows
- Gate `apply_migration` and DDL behind human-in-the-loop approval steps
