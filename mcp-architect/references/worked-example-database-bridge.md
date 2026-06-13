# Worked Example: PostgreSQL Database Bridge MCP Server

> Full specification walkthrough for a PostgreSQL Database Bridge MCP server. This is a complex, security-sensitive domain. Walks through all 8 checklist sections with detailed answers.

> For the checklist itself, see `references/specification-checklist.md`.
> For implementation, see **trl-mcp-forge** (`references/scaffold-nodejs-production.md`).

---

## Server Overview

| Field | Value |
|-------|-------|
| **Name** | pg-bridge-mcp |
| **Version** | 1.0.0 |
| **Description** | Read-only access to PostgreSQL databases for LLM-assisted data exploration |
| **Tools** | 4 (query, list_tables, describe_table, explain_query) |
| **Transport** | stdio (local only) |
| **Auth** | None (stdio); database credentials via environment variables |
| **Data Source** | Direct PostgreSQL connection |
| **Hosting** | Local (installed via npm/pip) |

---

## Section 1: Purpose & Scope

### 1.1 Problem Statement

Developers and analysts need to explore database schemas and query data during LLM-assisted work sessions. Without a database bridge, they must context-switch between the LLM client and a database client, copy-pasting results back and forth.

### 1.2 Consumers

- Claude Desktop (primary -- developer data exploration)
- Cursor (secondary -- code-context database queries)
- Local use only -- never exposed to network

### 1.3 Tool Inventory

| Tool | Description | Read/Write |
|------|-------------|------------|
| `list_tables` | List all tables in the database with schema, row counts, and size | Read |
| `describe_table` | Show column names, types, constraints, and indexes for a table | Read |
| `query` | Execute a read-only SQL query and return results | Read |
| `explain_query` | Show the query execution plan without running the query | Read |

### 1.4 Resources & Prompts

**Resources:** Consider exposing database schema as a resource (stable URI, infrequently changing). Deferred to v1.1 -- tools are sufficient for v1.0.

**Prompts:** None.

### 1.5 Out of Scope

- Write operations (INSERT, UPDATE, DELETE, DDL) -- deliberately excluded for safety
- Database administration (user management, replication, backups)
- Multiple database connections (v1 supports one database per instance)
- Cross-database queries
- Stored procedure execution
- Binary/blob data retrieval
- Connection to non-PostgreSQL databases

### 1.6 MCP vs REST API

MCP is correct because:
- Primary consumer is an LLM client that needs to decide when to query
- Tool discovery lets the LLM understand what database operations are available
- A REST API would require custom client integration for each LLM

### 1.7 Expected Volume

Low -- single user, interactive exploration. Estimated 10-50 queries per session, 1-5 sessions per day.

**Section 1 Status: COMPLETE**

---

## Section 2: Transport

### Decision: stdio

### Rationale

| Question | Answer | Implication |
|----------|--------|-------------|
| Local or remote? | **Local only** -- database access is security-sensitive | stdio (no network) |
| Concurrent clients? | 1 (the developer) | stdio supports this |
| Push updates? | No | Not a factor |
| Network constraints? | Deliberately no network -- security boundary | stdio enforces this |
| Latency? | Minimal required | stdio is IPC-level |
| Migration path? | No migration planned. If multi-user needed, would be a different server. | N/A |

### Security Rationale

This server has direct access to a database. Exposing it over HTTP would create a network-accessible SQL execution endpoint, which is an extreme security risk regardless of auth layer. By using stdio:

- No network listener exists -- cannot be accessed remotely
- No auth to bypass -- there is no auth surface
- Access is limited to whoever can run the process (OS-level access control)
- Database credentials never cross a network boundary

### ADR

**ADR-001: stdio Transport for Database Bridge**

- **Context:** Server provides read access to PostgreSQL databases. Database access is inherently security-sensitive.
- **Decision:** stdio transport only. No HTTP. No network listener.
- **Consequences:** Single user per instance (acceptable for the use case). Cannot be used as a team tool (acceptable -- each developer runs their own instance). Maximum security posture for database access.
- **Alternatives rejected:** Streamable HTTP (security risk of network-accessible database query endpoint outweighs multi-user benefit).

**Section 2 Status: COMPLETE**

---

## Section 3: Authentication & Authorization

### Decision: No Auth (stdio)

### Rationale

With stdio transport, the authentication boundary is the operating system. Only a user who can spawn the process can use it. This is the strongest possible auth for a local tool.

### Database Credentials

| Credential | Storage | Format |
|------------|---------|--------|
| Database URL | Environment variable `DATABASE_URL` | `postgresql://user:password@host:port/database` |
| SSL certificate (if needed) | File path via `PGSSLCERT` env var | PEM file |

### Credential Management

```bash
# Option 1: .env file (not committed to git)
DATABASE_URL=postgresql://readonly_user:password@localhost:5432/mydb

# Option 2: Shell environment
export DATABASE_URL=postgresql://readonly_user:password@localhost:5432/mydb

# Option 3: Credential helper
DATABASE_URL=$(vault read -field=url secret/database/readonly)
```

### Database User Permissions

The database user **MUST** be a read-only role:

```sql
-- Create a read-only role for the MCP server
CREATE ROLE mcp_readonly LOGIN PASSWORD 'secure_password';

-- Grant read access to existing tables
GRANT CONNECT ON DATABASE mydb TO mcp_readonly;
GRANT USAGE ON SCHEMA public TO mcp_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO mcp_readonly;

-- Grant read access to future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO mcp_readonly;

-- Explicitly deny write permissions
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public FROM mcp_readonly;
REVOKE CREATE ON SCHEMA public FROM mcp_readonly;
```

This is defense-in-depth: the server enforces read-only at the application level AND the database level.

**Section 3 Status: COMPLETE**

---

## Section 4: Data Stores

### Data Source Catalog

| Source | Type | Access | Owner | Connection | Cache TTL | Failure Mode |
|--------|------|--------|-------|------------|-----------|--------------|
| Target PostgreSQL database | Database | Read-only | User/organization | Connection pool (3) | None (queries) / 1hr (schema) | Exit with error |

### Connection Management

| Setting | Value | Rationale |
|---------|-------|-----------|
| Pool size | 3 | Single user, minimal concurrency |
| Idle timeout | 30 seconds | Free connections quickly |
| Connection timeout | 5 seconds | Fail fast if DB unreachable |
| Statement timeout | 30 seconds | Kill runaway queries |
| Max result rows | 1000 | Prevent memory exhaustion |

### Caching Strategy

| Data | Cache? | TTL | Rationale |
|------|--------|-----|-----------|
| Query results | No | -- | Results depend on current data state |
| Table list | Yes | 1 hour | Schema changes rarely during a session |
| Table descriptions | Yes | 1 hour | Schema changes rarely during a session |
| Query plans | No | -- | Plans depend on current table statistics |

### Failure Modes

| Failure | Behavior |
|---------|----------|
| Database unreachable at startup | Exit with clear error message including connection troubleshooting |
| Database disconnects during session | Attempt reconnection (3 retries, exponential backoff) |
| Query timeout | Return error with the query that timed out |
| Out of memory (large result set) | Enforced by max result rows limit |

**Section 4 Status: COMPLETE**

---

## Section 5: Security

### This Is the Most Important Section for This Server

A database bridge is a powerful and dangerous tool. Security is not optional -- it is the primary design constraint.

### Input Validation

| Tool | Input | Validation | Threat |
|------|-------|------------|--------|
| `query` | `sql` (string) | See SQL validation below | SQL injection, DDL execution |
| `list_tables` | `schema` (string, optional) | Alphanumeric + underscore, max 63 chars | Schema traversal |
| `describe_table` | `table` (string) | Alphanumeric + underscore + dot, max 128 chars | Schema traversal |
| `explain_query` | `sql` (string) | Same as `query` | Same as `query` |

### SQL Query Validation

The `query` tool accepts raw SQL. This is the primary attack surface.

**Layer 1: Statement Type Allowlist**

Only `SELECT` statements are permitted. Parse the SQL to verify statement type before execution.

```typescript
import { parse } from "pgsql-ast-parser";

function validateQuery(sql: string): void {
  let ast;
  try {
    ast = parse(sql);
  } catch (err) {
    throw new Error("Invalid SQL syntax");
  }

  for (const statement of ast) {
    if (statement.type !== "select") {
      throw new Error(
        `Only SELECT statements are allowed. Got: ${statement.type.toUpperCase()}`
      );
    }
  }
}
```

**Layer 2: Keyword Blocklist (Defense in Depth)**

Even after AST parsing, block dangerous patterns:

```typescript
const BLOCKED_PATTERNS = [
  /\bINSERT\b/i,
  /\bUPDATE\b/i,
  /\bDELETE\b/i,
  /\bDROP\b/i,
  /\bALTER\b/i,
  /\bCREATE\b/i,
  /\bTRUNCATE\b/i,
  /\bGRANT\b/i,
  /\bREVOKE\b/i,
  /\bCOPY\b/i,
  /\bEXECUTE\b/i,
  /\bCALL\b/i,
  /\bpg_sleep\b/i,
  /\bpg_terminate_backend\b/i,
  /\bpg_cancel_backend\b/i,
  /\blo_import\b/i,
  /\blo_export\b/i,
];
```

**Layer 3: Database-Level Enforcement**

The database user is read-only (see Section 3). Even if application-level validation fails, the database rejects writes.

**Layer 4: Transaction Wrapping**

Every query runs in a read-only transaction:

```typescript
async function executeReadOnlyQuery(pool: Pool, sql: string): Promise<QueryResult> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN READ ONLY");
    await client.query("SET statement_timeout = '30s'");
    const result = await client.query(sql);
    await client.query("COMMIT");
    return result;
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
}
```

### Result Size Limits

| Limit | Value | Rationale |
|-------|-------|-----------|
| Max rows | 1000 | Prevent memory exhaustion; LLMs can't usefully process more |
| Max columns | 100 | Schema width sanity check |
| Max cell size | 10,000 chars | Truncate large text fields |
| Max result size | 1 MB (serialized) | Absolute ceiling |

### Threat Model

| Threat | Actor | Surface | Likelihood | Impact | Mitigation |
|--------|-------|---------|-----------|--------|------------|
| DDL/DML execution via query tool | Malicious prompt | SQL input | Medium | Critical | 4-layer validation (AST, keyword, DB user, transaction) |
| Data exfiltration via query tool | Malicious prompt | SQL input | Low | High | Read-only user has access only to intended tables; consider schema allowlist |
| Resource exhaustion (slow query) | Careless or malicious | SQL input | Medium | Medium | Statement timeout (30s), result size limits |
| Credential leakage | Bug | Error messages | Low | High | Sanitize errors; never include connection string |
| Prompt injection via query results | Database data | Tool results | Low | Medium | Return structured JSON, not raw text |
| File system access via SQL | Malicious prompt | SQL (COPY, lo_import) | Low | Critical | Keyword blocklist + read-only DB user |

### Audit Logging

```
[2026-05-08T10:15:30Z] QUERY tool="query" sql="SELECT count(*) FROM users" rows=1 duration_ms=12
[2026-05-08T10:15:45Z] QUERY tool="query" sql="SELECT * FROM orders LIMIT 10" rows=10 duration_ms=45
[2026-05-08T10:16:00Z] BLOCKED tool="query" sql="DROP TABLE users" reason="DDL statement blocked"
```

**Section 5 Status: COMPLETE**

---

## Section 6: Hosting & Deployment

### Decision: Local (npm package)

### Rationale

| Factor | Value |
|--------|-------|
| Cost | $0 (runs on user's machine) |
| Ops | None (user installs and runs) |
| Latency | Minimal (IPC + LAN to database) |
| Scaling | Single user (appropriate) |
| Deployment | `npm install -g pg-bridge-mcp` |

### Distribution

- Published to npm as `pg-bridge-mcp`
- Users install globally or use `npx`
- No Docker needed (pure Node.js)

### System Requirements

- Node.js 20+
- Network access to target PostgreSQL database
- Database credentials with SELECT permissions

### Monitoring

Minimal -- this is a local tool:
- Console logging (structured JSON)
- Query duration tracking
- Error rate in logs

**Section 6 Status: COMPLETE**

---

## Section 7: Discovery & Registration

### Discovery Mechanism

1. **npm package** -- `npm install -g pg-bridge-mcp`
2. **README** -- Claude Desktop configuration example
3. **Registry** -- Listed on MCP server registries

### Client Configuration

**Claude Desktop:**

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "pg-bridge-mcp"],
      "env": {
        "DATABASE_URL": "postgresql://readonly:password@localhost:5432/mydb"
      }
    }
  }
}
```

### Documentation

- README.md: Quick start, security model, tool reference
- Configuration guide for Claude Desktop and Cursor
- SQL validation rules (what's allowed, what's blocked)
- Database user setup guide (read-only role creation)

**Section 7 Status: COMPLETE**

---

## Section 8: Versioning & Lifecycle

### Versioning Scheme

Semantic versioning: `MAJOR.MINOR.PATCH`

### Breaking Changes

| Change | Breaking? |
|--------|-----------|
| Add new tool | No |
| Change SQL validation rules (more restrictive) | **Yes** (queries that worked before may stop working) |
| Change SQL validation rules (less restrictive) | No (but requires security review) |
| Change result format | **Yes** |
| Change max result limits | **Maybe** (document as breaking if reduced) |

### Deprecation Policy

- 90-day deprecation window
- Deprecated tools annotated in description
- CHANGELOG.md for all changes

**Section 8 Status: COMPLETE**

---

## Tool Manifest

```json
{
  "server": {
    "name": "pg-bridge-mcp",
    "version": "1.0.0",
    "description": "Read-only PostgreSQL database exploration for LLM clients"
  },
  "tools": [
    {
      "name": "list_tables",
      "description": "List all tables in the connected database. Returns table name, schema, estimated row count, and table size. Use this to discover what data is available before querying. Optionally filter by schema name.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "schema": {
            "type": "string",
            "description": "Filter by schema name (e.g., 'public'). Returns all schemas if omitted.",
            "default": "public"
          }
        },
        "required": []
      },
      "annotations": {
        "readOnlyHint": true,
        "destructiveHint": false,
        "idempotentHint": true,
        "openWorldHint": false
      }
    },
    {
      "name": "describe_table",
      "description": "Show the structure of a specific table. Returns column names, data types, nullability, defaults, primary key, foreign keys, and indexes. Use this to understand table structure before writing a query. Use list_tables first to find available tables.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "table": {
            "type": "string",
            "description": "Table name, optionally schema-qualified (e.g., 'users' or 'public.users')"
          }
        },
        "required": ["table"]
      },
      "annotations": {
        "readOnlyHint": true,
        "destructiveHint": false,
        "idempotentHint": true,
        "openWorldHint": false
      }
    },
    {
      "name": "query",
      "description": "Execute a read-only SQL SELECT query and return results as JSON. Only SELECT statements are allowed -- INSERT, UPDATE, DELETE, and DDL are blocked. Results are limited to 1000 rows. Long text values are truncated at 10,000 characters. Use list_tables and describe_table to understand the schema before querying.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "sql": {
            "type": "string",
            "description": "SQL SELECT query to execute. Only SELECT is allowed. Example: 'SELECT id, name FROM users WHERE active = true LIMIT 10'"
          }
        },
        "required": ["sql"]
      },
      "annotations": {
        "readOnlyHint": true,
        "destructiveHint": false,
        "idempotentHint": true,
        "openWorldHint": false
      }
    },
    {
      "name": "explain_query",
      "description": "Show the PostgreSQL query execution plan for a SELECT statement without actually running the query. Returns the EXPLAIN ANALYZE output showing estimated costs, row counts, and join strategies. Use this to understand why a query might be slow or to verify it will use indexes.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "sql": {
            "type": "string",
            "description": "SQL SELECT query to explain. Only SELECT is allowed."
          },
          "analyze": {
            "type": "boolean",
            "description": "If true, actually execute the query to get real timing (slower but more accurate). Default false uses estimates only.",
            "default": false
          }
        },
        "required": ["sql"]
      },
      "annotations": {
        "readOnlyHint": true,
        "destructiveHint": false,
        "idempotentHint": true,
        "openWorldHint": false
      }
    }
  ],
  "resources": [],
  "prompts": []
}
```

---

## Security Summary

This server's security posture is defense-in-depth with four independent layers:

1. **Transport isolation** -- stdio, no network listener
2. **Application validation** -- AST parsing + keyword blocklist
3. **Transaction enforcement** -- `BEGIN READ ONLY` wrapping
4. **Database permissions** -- read-only PostgreSQL role

Any single layer failing does not compromise the system. All four must be bypassed for a write operation to succeed.

---

## Next Steps

With this specification complete:

1. Scaffold with **trl-mcp-forge** (`references/scaffold-nodejs-production.md`)
2. Implement SQL parser and validation
3. Implement connection pool with read-only enforcement
4. Write security-focused tests (blocked queries, injection attempts)
5. Publish to npm
6. Write Claude Desktop setup guide
