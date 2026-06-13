# Authentication & Authorization Patterns for MCP Servers

> Implementation patterns for auth in MCP servers. Covers no-auth, API key, OAuth 2.0, JWT, and per-tool authorization.

> For the specification checklist (Section 3), see `references/specification-checklist.md`.
> For implementation, see **trl-mcp-forge** (`references/scaffold-nodejs-production.md`).

---

## Pattern Overview

| Pattern | Transport | Complexity | Best For |
|---------|-----------|------------|----------|
| No Auth | stdio | None | Local tools, personal use |
| API Key | HTTP | Low | Simple remote, internal tools |
| OAuth 2.0 | HTTP | High | User-delegated access, third-party apps |
| JWT | HTTP | Medium | Service-to-service, microservices |

---

## Pattern 1: No Auth (Local stdio)

### When to Use

- Server runs locally on the same machine as the client
- Transport is stdio (stdin/stdout)
- Single user, single client
- Server accesses only local resources or credentials stored locally

### How It Works

The client spawns the server as a child process. Communication happens over stdin/stdout. There is no network boundary, so there is no authentication boundary.

### Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Local privilege escalation | Medium | Run server with minimum necessary permissions |
| Credential exposure in process list | Low | Pass credentials via env vars, not CLI args |
| Unintended tool execution | Low | Annotations (destructiveHint) trigger user confirmation in clients |

### Downstream Credential Management

Even without client auth, the server may need credentials for downstream services (databases, APIs). These should be managed via environment variables:

```bash
# .env file (never committed to git)
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
EXTERNAL_API_KEY=sk-abc123
```

### TypeScript Example

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new McpServer({
  name: "local-tool",
  version: "1.0.0",
});

// No auth middleware needed for stdio
server.tool("get_data", "Retrieve local data", {
  path: { type: "string", description: "File path to read" },
}, async ({ path }) => {
  // Validate path is within allowed directory
  const resolved = resolve(path);
  if (!resolved.startsWith(ALLOWED_DIR)) {
    throw new Error("Path outside allowed directory");
  }
  const data = await readFile(resolved, "utf-8");
  return { content: [{ type: "text", text: data }] };
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

### FastMCP Example

```python
from mcp.server.fastmcp import FastMCP
import os

mcp = FastMCP("local-tool")

ALLOWED_DIR = os.environ.get("ALLOWED_DIR", os.getcwd())

@mcp.tool()
def get_data(path: str) -> str:
    """Retrieve local data from a file path within the allowed directory."""
    resolved = os.path.realpath(path)
    if not resolved.startswith(os.path.realpath(ALLOWED_DIR)):
        raise ValueError("Path outside allowed directory")
    with open(resolved) as f:
        return f.read()

mcp.run()
```

---

## Pattern 2: API Key (Simple Remote)

### When to Use

- Server is accessible over HTTP
- Need to identify clients for rate limiting and usage tracking
- Read-only or low-risk write operations
- Simple onboarding is important (no OAuth dance)
- No need for user-level identity (client-level is sufficient)

### How It Works

1. Client obtains an API key (via dashboard, email, or admin)
2. Client includes key in every request: `Authorization: Bearer <key>`
3. Server validates key against a store (database, in-memory map, etc.)
4. Server extracts client identity from key for rate limiting and logging

### Key Generation

API keys should be:
- Cryptographically random (at least 32 bytes, base64 or hex encoded)
- Prefixed for identification (`wea_` for weather API, `mcp_` for generic)
- Stored hashed (bcrypt or SHA-256) -- never store plaintext keys

```typescript
import { randomBytes, createHash } from "crypto";

function generateApiKey(prefix: string = "mcp"): { key: string; hash: string } {
  const raw = randomBytes(32).toString("base64url");
  const key = `${prefix}_${raw}`;
  const hash = createHash("sha256").update(key).digest("hex");
  return { key, hash };
}
```

### Key Rotation

- Keys should be rotatable (generate new, invalidate old)
- Support a grace period where both old and new keys work (e.g., 24 hours)
- Log key usage so you can identify which keys are active before rotation
- Notify key owners before forced rotation

### Key Storage

| Location | Security | Convenience | Use When |
|----------|----------|-------------|----------|
| Environment variable | Good | High | Single key, simple deployment |
| Secrets vault (e.g., Infisical, Vault) | Excellent | Medium | Production, multiple keys |
| Database table | Good | High | Self-service key management |
| Config file | Poor | High | **Never** -- too easy to commit to git |

### Validation Middleware

**TypeScript (Streamable HTTP):**

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import express from "express";
import { createHash } from "crypto";

const app = express();

// API key validation middleware
function validateApiKey(req: express.Request, res: express.Response, next: express.NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith("Bearer ")) {
    res.status(401).json({ error: "Missing API key" });
    return;
  }

  const key = authHeader.slice(7);
  const hash = createHash("sha256").update(key).digest("hex");

  const client = lookupClientByKeyHash(hash);  // Your lookup function
  if (!client) {
    res.status(401).json({ error: "Invalid API key" });
    return;
  }

  req.clientId = client.id;  // Attach client identity for downstream use
  next();
}

app.use("/mcp", validateApiKey);

// Set up MCP server with Streamable HTTP transport
app.post("/mcp", async (req, res) => {
  const transport = new StreamableHTTPServerTransport({ sessionIdGenerator: undefined });
  // ... connect server to transport
});
```

**FastMCP (Python):**

```python
from mcp.server.fastmcp import FastMCP
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse
import hashlib
import os

class ApiKeyMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        auth = request.headers.get("authorization", "")
        if not auth.startswith("Bearer "):
            return JSONResponse({"error": "Missing API key"}, status_code=401)

        key = auth[7:]
        key_hash = hashlib.sha256(key.encode()).hexdigest()

        client = lookup_client_by_key_hash(key_hash)  # Your lookup
        if not client:
            return JSONResponse({"error": "Invalid API key"}, status_code=401)

        request.state.client_id = client["id"]
        return await call_next(request)

mcp = FastMCP("weather-api")

# Add middleware when running as HTTP
# mcp.run(transport="streamable-http", middleware=[ApiKeyMiddleware])
```

---

## Pattern 3: OAuth 2.0 (User-Delegated Access)

### When to Use

- Tools act on behalf of individual users (e.g., access their GitHub repos, Google Drive files)
- Need user consent before accessing their data
- Third-party applications consuming the MCP server
- Regulatory requirements demand user-level audit trails

### How It Works

1. Client initiates OAuth flow (redirects user to authorization server)
2. User grants consent for specific scopes
3. Authorization server issues access token (and refresh token)
4. Client includes access token in MCP requests
5. Server validates token and extracts user identity
6. Server calls downstream APIs using the user's delegated credentials

### MCP-Specific Considerations

| Consideration | Details |
|--------------|---------|
| Token storage | MCP clients (Claude Desktop, Cursor) must store tokens securely. Server should not cache user tokens. |
| Token refresh | Implement refresh token flow. Access tokens expire (typically 1 hour). Clients must handle 401 → refresh → retry. |
| Scope mapping | Map OAuth scopes to MCP tool permissions. A user with `read` scope should not access `delete_document`. |
| Consent screen | Users must understand what tools will do with their data. |
| Revocation | Users must be able to revoke access. Server must handle revoked tokens gracefully. |

### Flow Diagram

```
Client                Auth Server              MCP Server           Downstream API
  |                       |                        |                      |
  |-- Auth request ------>|                        |                      |
  |                       |-- User consent ------->|                      |
  |                       |                        |                      |
  |<-- Auth code ---------|                        |                      |
  |-- Exchange code ----->|                        |                      |
  |<-- Access + Refresh --|                        |                      |
  |                       |                        |                      |
  |-- MCP request (token) ----------------------->|                      |
  |                       |                        |-- Validate token --->|
  |                       |                        |<-- User identity ----|
  |                       |                        |                      |
  |                       |                        |-- API call (token) ->|
  |                       |                        |<-- Data -------------|
  |<-- Tool result --------------------------------|                      |
```

### Token Refresh Handling

```typescript
async function callWithRefresh(
  accessToken: string,
  refreshToken: string,
  apiCall: (token: string) => Promise<Response>
): Promise<{ result: Response; newTokens?: { access: string; refresh: string } }> {
  let response = await apiCall(accessToken);

  if (response.status === 401) {
    // Token expired, attempt refresh
    const refreshResponse = await fetch(TOKEN_ENDPOINT, {
      method: "POST",
      body: new URLSearchParams({
        grant_type: "refresh_token",
        refresh_token: refreshToken,
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
      }),
    });

    if (!refreshResponse.ok) {
      throw new Error("Token refresh failed. User must re-authenticate.");
    }

    const tokens = await refreshResponse.json();
    response = await apiCall(tokens.access_token);

    return {
      result: response,
      newTokens: {
        access: tokens.access_token,
        refresh: tokens.refresh_token ?? refreshToken,
      },
    };
  }

  return { result: response };
}
```

---

## Pattern 4: JWT (Service-to-Service)

### When to Use

- MCP server consumed by other services (not end users)
- Need stateless token validation (no database lookup per request)
- Microservice architecture where multiple services share an identity provider
- Need rich claims (roles, permissions, tenant ID) in the token

### How It Works

1. Service authenticates with identity provider (client credentials flow)
2. Identity provider issues a signed JWT with claims
3. Service includes JWT in MCP requests: `Authorization: Bearer <jwt>`
4. MCP server validates JWT signature and claims locally (no network call)
5. Server extracts identity and permissions from token claims

### Claims Design

```json
{
  "iss": "https://auth.example.com",
  "sub": "service:data-pipeline",
  "aud": "mcp:weather-api",
  "iat": 1715100000,
  "exp": 1715103600,
  "roles": ["reader"],
  "tenant_id": "acme-corp",
  "allowed_tools": ["get_current_weather", "get_forecast"]
}
```

| Claim | Purpose |
|-------|---------|
| `iss` | Token issuer (your auth server) |
| `sub` | Subject (the service identity) |
| `aud` | Audience (this MCP server) |
| `iat` / `exp` | Issued-at and expiration timestamps |
| `roles` | Role-based access control |
| `tenant_id` | Multi-tenant isolation |
| `allowed_tools` | Per-tool authorization (custom claim) |

### Key Rotation

JWT signing keys must be rotated regularly:

1. Publish keys via JWKS endpoint (`/.well-known/jwks.json`)
2. Include `kid` (key ID) in JWT header
3. MCP server caches JWKS with TTL (e.g., 1 hour)
4. On rotation: add new key to JWKS, sign new tokens with new key, remove old key after grace period

### Validation

```typescript
import jwt from "jsonwebtoken";
import jwksClient from "jwks-rsa";

const client = jwksClient({
  jwksUri: "https://auth.example.com/.well-known/jwks.json",
  cache: true,
  cacheMaxAge: 3600000, // 1 hour
});

function getSigningKey(header: jwt.JwtHeader): Promise<string> {
  return new Promise((resolve, reject) => {
    client.getSigningKey(header.kid!, (err, key) => {
      if (err) reject(err);
      else resolve(key!.getPublicKey());
    });
  });
}

async function validateJwt(token: string): Promise<JwtPayload> {
  return new Promise((resolve, reject) => {
    jwt.verify(
      token,
      (header, callback) => {
        getSigningKey(header).then(
          (key) => callback(null, key),
          (err) => callback(err)
        );
      },
      {
        audience: "mcp:weather-api",
        issuer: "https://auth.example.com",
        algorithms: ["RS256"],
      },
      (err, decoded) => {
        if (err) reject(err);
        else resolve(decoded as JwtPayload);
      }
    );
  });
}
```

---

## Per-Tool Authorization

### Role-Based Tool Access

Define a permission matrix mapping roles to tools:

```typescript
const TOOL_PERMISSIONS: Record<string, string[]> = {
  "reader": [
    "get_current_weather",
    "get_forecast",
    "get_alerts",
    "search_locations",
  ],
  "writer": [
    // inherits reader permissions
    "create_alert_subscription",
    "update_preferences",
  ],
  "admin": [
    // inherits writer permissions
    "delete_alert_subscription",
    "manage_api_keys",
    "view_usage_stats",
  ],
};

function canAccessTool(roles: string[], toolName: string): boolean {
  // Build cumulative permissions
  const roleHierarchy = ["reader", "writer", "admin"];
  const effectiveTools = new Set<string>();

  for (const role of roles) {
    const roleIndex = roleHierarchy.indexOf(role);
    for (let i = 0; i <= roleIndex; i++) {
      const tools = TOOL_PERMISSIONS[roleHierarchy[i]] ?? [];
      tools.forEach((t) => effectiveTools.add(t));
    }
  }

  return effectiveTools.has(toolName);
}
```

### Permission Matrix Template

| Tool | Public | Reader | Writer | Admin |
|------|--------|--------|--------|-------|
| `search_locations` | Yes | Yes | Yes | Yes |
| `get_current_weather` | No | Yes | Yes | Yes |
| `get_forecast` | No | Yes | Yes | Yes |
| `create_subscription` | No | No | Yes | Yes |
| `delete_subscription` | No | No | No | Yes |
| `view_usage_stats` | No | No | No | Yes |

---

## Secrets Rotation Strategies

### API Key Rotation

```
1. Generate new key (new_key)
2. Add new_key to valid keys (both old and new accepted)
3. Notify client to switch to new_key
4. After grace period (24-48 hours), invalidate old_key
5. Log any requests still using old_key as warnings
```

### JWT Key Rotation

```
1. Generate new signing key pair (new_kid)
2. Add new public key to JWKS endpoint
3. Start signing new tokens with new_kid
4. After max token lifetime (e.g., 1 hour), remove old public key from JWKS
5. Old tokens with old_kid will fail validation naturally after expiry
```

### Environment Variable Rotation

```
1. Update secret in vault (e.g., Infisical)
2. Trigger rolling restart of server instances
3. New instances pick up new env vars
4. Old instances drain connections and terminate
```

---

## Quick Selection Guide

```
Is the server local-only (stdio)?
  Yes → No Auth
  No ↓

Is the server consumed by end users who own data?
  Yes → OAuth 2.0
  No ↓

Is the server consumed by other services?
  Yes → JWT
  No ↓

Simple remote access with rate limiting?
  Yes → API Key
```
