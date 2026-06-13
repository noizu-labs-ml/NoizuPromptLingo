# Data Store Integration Patterns for MCP Servers

> Patterns for connecting MCP servers to databases, file systems, and external APIs. Covers read-only vs read-write, connection management, sandboxing, caching, and data ownership.

> For the specification checklist (Section 4), see `references/specification-checklist.md`.
> For implementation, see **trl-mcp-forge** (`references/scaffold-nodejs-production.md`).

---

## Read-Only Tools

Read-only tools are simpler, safer, and should be the default unless write access is genuinely required.

### Advantages

- No data corruption risk from bugs
- No need for confirmation dialogs or undo mechanisms
- Can be cached aggressively
- Lower auth requirements (reader role sufficient)
- Easier to test (no state cleanup between tests)

### Database Read-Only Pattern

```typescript
import { Pool } from "pg";

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,
  // Force read-only at the connection level
  options: "-c default_transaction_read_only=on",
});

server.tool("list_tables", "List all tables in the database with row counts", {}, async () => {
  const result = await pool.query(`
    SELECT schemaname, tablename, n_live_tup as row_count
    FROM pg_stat_user_tables
    ORDER BY schemaname, tablename
  `);
  return {
    content: [{ type: "text", text: JSON.stringify(result.rows, null, 2) }],
  };
});
```

```python
import asyncpg
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("db-reader")

pool = None

@mcp.tool()
async def list_tables() -> str:
    """List all tables in the database with row counts."""
    global pool
    if pool is None:
        pool = await asyncpg.create_pool(
            dsn=os.environ["DATABASE_URL"],
            min_size=2,
            max_size=10,
            server_settings={"default_transaction_read_only": "on"},
        )
    rows = await pool.fetch("""
        SELECT schemaname, tablename, n_live_tup as row_count
        FROM pg_stat_user_tables
        ORDER BY schemaname, tablename
    """)
    return json.dumps([dict(r) for r in rows], indent=2)
```

### API Read-Only Pattern

```typescript
server.tool(
  "get_current_weather",
  "Get current weather conditions for a location",
  {
    location_id: { type: "string", description: "Location ID from search_locations" },
  },
  async ({ location_id }) => {
    const response = await fetch(
      `https://api.openweathermap.org/data/3.0/onecall?lat=${lat}&lon=${lon}&appid=${API_KEY}`
    );
    if (!response.ok) {
      throw new Error(`Weather API error: ${response.status}`);
    }
    const data = await response.json();
    return {
      content: [{
        type: "text",
        text: JSON.stringify({
          temperature: data.current.temp,
          humidity: data.current.humidity,
          description: data.current.weather[0].description,
        }),
      }],
    };
  }
);
```

---

## Read-Write Tools

Read-write tools require additional safeguards: input validation, confirmation patterns, audit trails, and error handling.

### Validation Patterns

Always validate before writing:

```typescript
server.tool(
  "create_document",
  "Create a new document in the specified folder",
  {
    folder_id: { type: "string", description: "Target folder ID" },
    title: { type: "string", description: "Document title (max 200 chars)" },
    content: { type: "string", description: "Document content in Markdown" },
  },
  async ({ folder_id, title, content }) => {
    // Validate inputs beyond schema
    if (title.length > 200) {
      throw new Error("Title exceeds 200 character limit");
    }
    if (!await folderExists(folder_id)) {
      throw new Error(`Folder ${folder_id} not found`);
    }
    if (!await hasWritePermission(folder_id, currentUser)) {
      throw new Error("No write permission for this folder");
    }

    const doc = await db.documents.create({ folder_id, title, content });

    // Audit log
    await auditLog("create_document", { doc_id: doc.id, folder_id, user: currentUser });

    return {
      content: [{
        type: "text",
        text: JSON.stringify({ id: doc.id, title: doc.title, created_at: doc.created_at }),
      }],
    };
  }
);
```

### Confirmation Patterns for Destructive Operations

For destructive tools, require explicit confirmation:

```typescript
server.tool(
  "delete_document",
  "Permanently delete a document. Requires confirm=true. Irreversible.",
  {
    document_id: { type: "string", description: "Document ID to delete" },
    confirm: {
      type: "boolean",
      description: "Must be true to proceed. Safety check.",
      default: false,
    },
  },
  async ({ document_id, confirm }) => {
    if (!confirm) {
      return {
        content: [{
          type: "text",
          text: "Deletion requires confirm=true. This action is irreversible.",
        }],
      };
    }

    const doc = await db.documents.findById(document_id);
    if (!doc) {
      throw new Error(`Document ${document_id} not found`);
    }

    await db.documents.delete(document_id);
    await auditLog("delete_document", { doc_id: document_id, title: doc.title });

    return {
      content: [{
        type: "text",
        text: `Deleted document "${doc.title}" (${document_id})`,
      }],
    };
  }
);
```

### Audit Trail Pattern

```typescript
interface AuditEntry {
  timestamp: string;
  tool: string;
  client_id: string;
  input_hash: string;  // Hash of inputs, not raw values (may contain sensitive data)
  outcome: "success" | "error";
  duration_ms: number;
  details: Record<string, unknown>;
}

async function auditLog(tool: string, details: Record<string, unknown>): Promise<void> {
  const entry: AuditEntry = {
    timestamp: new Date().toISOString(),
    tool,
    client_id: getCurrentClientId(),
    input_hash: hashInputs(details),
    outcome: "success",
    duration_ms: 0,  // Set by caller
    details,
  };
  // Write to audit log (database, file, or external service)
  await db.audit.insert(entry);
}
```

---

## Database Connection Pooling

### Per-Request vs Shared Pool

| Strategy | Pros | Cons | Use When |
|----------|------|------|----------|
| **Per-request** | Simple, isolated | Slow (connection setup per call), resource exhaustion | Low volume (<10 req/min) |
| **Shared pool** | Fast, efficient | Complexity, pool exhaustion under load | Medium-high volume |
| **Singleton** | Simplest | No concurrency | Single-threaded stdio servers |

### Pool Configuration

```typescript
import { Pool } from "pg";

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,                    // Maximum connections
  min: 2,                     // Minimum idle connections
  idleTimeoutMillis: 30000,   // Close idle connections after 30s
  connectionTimeoutMillis: 5000,  // Fail if can't connect in 5s
  statement_timeout: 10000,   // Kill queries running >10s
});

// Health check
pool.on("error", (err) => {
  console.error("Unexpected pool error:", err);
});
```

### Connection Lifecycle

```
Request arrives
  → Acquire connection from pool (wait if pool exhausted)
  → Execute query (with timeout)
  → Release connection back to pool
  → Return result to client

If pool exhausted:
  → Wait up to connectionTimeoutMillis
  → If still no connection, return 503 Service Unavailable
```

---

## File System Sandboxing

### The Problem

If a tool accepts a file path as input, an attacker can pass `../../etc/passwd` or a symlink to escape the intended directory.

### Path Validation

```typescript
import { resolve, relative } from "path";
import { realpath } from "fs/promises";

const SANDBOX_DIR = resolve(process.env.SANDBOX_DIR ?? "./data");

async function validatePath(userPath: string): Promise<string> {
  // Step 1: Resolve to absolute path
  const absolute = resolve(SANDBOX_DIR, userPath);

  // Step 2: Check prefix (before symlink resolution)
  if (!absolute.startsWith(SANDBOX_DIR)) {
    throw new Error("Path outside sandbox directory");
  }

  // Step 3: Resolve symlinks and check again
  try {
    const real = await realpath(absolute);
    if (!real.startsWith(await realpath(SANDBOX_DIR))) {
      throw new Error("Symlink escape detected");
    }
    return real;
  } catch (err) {
    if ((err as NodeJS.ErrnoException).code === "ENOENT") {
      // File doesn't exist yet (for create operations)
      // Verify parent directory is within sandbox
      const parentReal = await realpath(resolve(absolute, ".."));
      if (!parentReal.startsWith(await realpath(SANDBOX_DIR))) {
        throw new Error("Parent directory outside sandbox");
      }
      return absolute;
    }
    throw err;
  }
}
```

```python
import os

SANDBOX_DIR = os.path.realpath(os.environ.get("SANDBOX_DIR", "./data"))

def validate_path(user_path: str) -> str:
    """Validate and resolve a user-provided path within the sandbox."""
    absolute = os.path.realpath(os.path.join(SANDBOX_DIR, user_path))
    if not absolute.startswith(SANDBOX_DIR + os.sep) and absolute != SANDBOX_DIR:
        raise ValueError("Path outside sandbox directory")
    return absolute
```

### Checklist for File System Tools

- [ ] All paths resolved to absolute before use
- [ ] Prefix check against sandbox directory
- [ ] Symlinks resolved and re-checked
- [ ] Parent directory validated for create operations
- [ ] File size limits enforced (prevent reading 10GB files)
- [ ] File type restrictions (if applicable)

---

## External API Wrapping

### Rate Limiting the Upstream

Your MCP server must respect the upstream API's rate limits:

```typescript
class RateLimitedClient {
  private queue: Array<{ resolve: Function; reject: Function; fn: Function }> = [];
  private activeRequests = 0;
  private readonly maxConcurrent: number;
  private readonly minInterval: number;
  private lastRequest = 0;

  constructor(maxConcurrent: number, requestsPerMinute: number) {
    this.maxConcurrent = maxConcurrent;
    this.minInterval = 60000 / requestsPerMinute;
  }

  async request<T>(fn: () => Promise<T>): Promise<T> {
    return new Promise((resolve, reject) => {
      this.queue.push({ resolve, reject, fn });
      this.processQueue();
    });
  }

  private async processQueue() {
    if (this.activeRequests >= this.maxConcurrent || this.queue.length === 0) return;

    const now = Date.now();
    const waitTime = Math.max(0, this.lastRequest + this.minInterval - now);

    if (waitTime > 0) {
      setTimeout(() => this.processQueue(), waitTime);
      return;
    }

    const { resolve, reject, fn } = this.queue.shift()!;
    this.activeRequests++;
    this.lastRequest = Date.now();

    try {
      resolve(await fn());
    } catch (err) {
      reject(err);
    } finally {
      this.activeRequests--;
      this.processQueue();
    }
  }
}
```

### Error Translation

Translate upstream API errors into meaningful MCP tool results:

```typescript
async function callUpstreamApi(url: string): Promise<unknown> {
  const response = await fetch(url, { headers: { Authorization: `Bearer ${API_KEY}` } });

  switch (response.status) {
    case 200:
      return response.json();
    case 401:
      throw new Error("Upstream API authentication failed. Check API key configuration.");
    case 429:
      const retryAfter = response.headers.get("retry-after") ?? "60";
      throw new Error(`Upstream API rate limit exceeded. Retry after ${retryAfter} seconds.`);
    case 404:
      throw new Error("Resource not found in upstream API.");
    case 500:
    case 502:
    case 503:
      throw new Error("Upstream API is temporarily unavailable. Try again later.");
    default:
      throw new Error(`Upstream API returned unexpected status: ${response.status}`);
  }
}
```

---

## Caching Strategies

### In-Memory Cache (Simple)

```typescript
class SimpleCache<T> {
  private cache = new Map<string, { value: T; expiry: number }>();

  get(key: string): T | undefined {
    const entry = this.cache.get(key);
    if (!entry) return undefined;
    if (Date.now() > entry.expiry) {
      this.cache.delete(key);
      return undefined;
    }
    return entry.value;
  }

  set(key: string, value: T, ttlMs: number): void {
    this.cache.set(key, { value, expiry: Date.now() + ttlMs });
  }

  clear(): void {
    this.cache.clear();
  }
}

const weatherCache = new SimpleCache<WeatherData>();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

server.tool("get_current_weather", "...", { location_id: { type: "string" } }, async ({ location_id }) => {
  const cached = weatherCache.get(location_id);
  if (cached) return { content: [{ type: "text", text: JSON.stringify(cached) }] };

  const data = await fetchWeatherFromApi(location_id);
  weatherCache.set(location_id, data, CACHE_TTL);
  return { content: [{ type: "text", text: JSON.stringify(data) }] };
});
```

### TTL Guidelines

| Data Type | Suggested TTL | Rationale |
|-----------|---------------|-----------|
| Current weather | 5 minutes | Changes frequently but not per-second |
| Forecasts | 30 minutes | Updated less frequently |
| Location search | 24 hours | Locations rarely change |
| Database schema | 1 hour | Schema changes are rare |
| User profiles | 5 minutes | Balances freshness and load |
| Static reference data | 24 hours | Rarely changes |

### When NOT to Cache

- Write operations (cache invalidation is error-prone)
- Security-sensitive data (tokens, credentials)
- User-specific data with privacy concerns
- Real-time data where staleness is unacceptable
- Small datasets that are cheap to fetch

---

## Data Ownership and Privacy

### Ownership Categories

| Category | Examples | Obligations |
|----------|----------|-------------|
| **Your data** | Server config, tool metadata | Full control |
| **User data** | User files, settings, history | GDPR/CCPA compliance, deletion on request |
| **Third-party data** | API responses, licensed data | Terms of service compliance, attribution |
| **Derived data** | Analytics, aggregations | Depends on source data category |

### Privacy Checklist

- [ ] What personal data does the server access?
- [ ] Is there a data processing agreement with users?
- [ ] Can users request data deletion?
- [ ] Is data encrypted at rest and in transit?
- [ ] Are access logs retained appropriately (not too long, not too short)?
- [ ] Does the server comply with GDPR/CCPA for affected users?

---

## Connection String Management

### Priority Order

1. **Secrets vault** (Infisical, HashiCorp Vault, AWS Secrets Manager) -- best for production
2. **Environment variables** -- good for simple deployments, CI/CD
3. **Config file** (not in git) -- acceptable for local development
4. **Never:** hardcoded in source code

### Pattern

```typescript
function getDatabaseUrl(): string {
  const url = process.env.DATABASE_URL;
  if (!url) {
    throw new Error(
      "DATABASE_URL environment variable is required. " +
      "Set it in your .env file or secrets vault."
    );
  }
  return url;
}
```

Fail loudly on missing configuration. Silent defaults (e.g., falling back to `localhost:5432`) mask misconfigurations in production.
