# Security Model

## Dual-Principal Authorization

Every MCP request carries two principals:

1. **Caller** — the AI agent or application invoking the MCP tool (identified by API key, OAuth client, or signed token)
2. **User** — the human whose session initiated the agent's action (propagated via delegated auth token, RFC 8693)

Authorization formula: `allow(tool, args) = caller_policy(tool, args) AND user_policy(tool, args)`

Neither principal alone can escalate beyond their own permissions.

## Delegated Authorization

MCP Host never receives or stores user credentials for downstream services:

- Users authorize MCP Host as an OAuth delegate with explicitly scoped permissions
- Downstream access tokens are scoped to what the user granted, not what the service supports
- Token scope is further narrowed by the caller's policy before use
- Refresh tokens are encrypted at rest, rotated on use, and revocable per-caller

## Policy Scope Hierarchy

Policies are evaluated innermost-first across six levels:

| Level | Scope | Example |
|-------|-------|---------|
| Global | Platform-wide defaults | Rate limits, banned tool patterns |
| Organization | All callers/users in an org | "No file-delete tools in production" |
| MCP Server | All tools on a specific server | "This server's tools are read-only" |
| Tool | Individual tool | "gmail.send requires user confirmation" |
| Caller | Specific API client | "Claude Desktop: search tools only" |
| User | Specific human | "keith@: admin tools; contractors: denied" |

## Policy Expressions

- Allow/deny lists per tool per caller
- Argument constraints (e.g., `file.write` only to paths matching `/tmp/**`)
- Rate limiting (per caller, per user, per tool, per time window)
- Confirmation gates (human-in-the-loop for sensitive operations)
- Time-based rules (business hours, maintenance windows)

## Auth Protocols

### OAuth 2.1 + MCP Extensions

- `mcp:tool` scope — fine-grained per tool (e.g., `mcp:tool:gmail.read`)
- `mcp:server` scope — blanket access to all tools on a server
- Delegated user claim — JWT `sub` = calling app; `act.sub` = human user
- Dynamic scope narrowing at call time

### API Key with Policy Binding

Keys are bound to a policy document at creation time defining allowed/denied tools, rate limits, and whether user context is required.

### Mutual TLS (mTLS)

For service-to-service MCP calls within a cluster. Certificate SANs map to caller policies.

## Audit Trail

Every tool invocation produces an immutable audit record containing: timestamp, request ID, caller identity, user identity, tool metadata, arguments (redacted per policy), policy decision with matched rules, and result status. Logs are queryable, exportable, and support SOC 2 / GDPR compliance workflows.
