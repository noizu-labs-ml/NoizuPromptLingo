# Tool Design for Agents

How to build tools (MCP servers, function calls, CLI wrappers) that agents can actually use well. Based primarily on Anthropic's "Writing Effective Tools for AI Agents" (2025) and OpenAI's agent guidance.

---

## The Six Rules

### Rule 1: Format Responses for the Model, Not Humans

Tools should return structured data the model can reason about, not human-readable formatting.

**Bad:**
```
╔══════════════════╗
║  User: John Doe  ║
║  Email: j@doe.io ║
║  Status: Active  ║
╚══════════════════╝
```

**Good:**
```json
{"user_id": "u123", "name": "John Doe", "email": "j@doe.io", "status": "active", "created_at": "2025-01-15T10:30:00Z"}
```

**Why:** Models parse JSON natively. Pretty-printing wastes tokens and introduces parsing ambiguity.

### Rule 2: Include Examples in Tool Descriptions

The tool description is the agent's only documentation. Make it count.

**Bad:**
```json
{
  "name": "search_users",
  "description": "Search for users in the database"
}
```

**Good:**
```json
{
  "name": "search_users",
  "description": "Search users by any field. Example: search_users(query='email:*@gmail.com', limit=10) returns [{id, name, email, status}]. Supports field:value syntax for exact match, field:*pattern for wildcard. Common fields: email, name, status, role."
}
```

**Why:** Models learn usage patterns from examples more reliably than from abstract descriptions.

### Rule 3: Design for Recoverability

When a tool call fails, the error should tell the agent how to fix it.

**Bad:**
```
Error: NullPointerException at UserService.java:142
```

**Good:**
```json
{
  "error": "user_not_found",
  "message": "No user with ID 'u999'. Try list_users(limit=10) to see available user IDs, or search_users(query='name:John') to find by name.",
  "suggestion": "list_users"
}
```

**Why:** Agents with recoverable errors self-correct. Agents with stack traces give up or hallucinate.

### Rule 4: Paginate Everything

Never return unbounded data. Every data-returning tool needs `limit` and `offset` (or cursor) parameters.

**Bad:**
```json
{
  "name": "list_orders",
  "description": "Returns all orders for a user"
}
```

**Good:**
```json
{
  "name": "list_orders",
  "description": "Returns orders for a user. Default limit=20, max limit=100. Returns {items, total_count, has_more, next_cursor}.",
  "parameters": {
    "user_id": {"type": "string", "required": true},
    "limit": {"type": "integer", "default": 20, "maximum": 100},
    "cursor": {"type": "string", "description": "Pagination cursor from previous response"}
  }
}
```

**Why:** An agent calling `list_orders` on a user with 50,000 orders will blow the context window and waste money.

### Rule 5: Build High-Leverage Operations

Low-leverage tools do one small thing. High-leverage tools do something smart that saves the agent multiple steps.

| Low Leverage | High Leverage |
|-------------|--------------|
| `read_file(path)` | `search_codebase(query, file_pattern)` with semantic understanding |
| `list_directory(path)` | `find_files(pattern, content_match)` with recursive search |
| `get_user(id)` | `get_user_context(id)` returning user + recent orders + support tickets |
| `execute_sql(query)` | `analyze_table(name)` returning schema + stats + sample rows |

**Why:** Each tool call costs a round trip. A high-leverage tool that does 3 things in one call saves 2 round trips.

### Rule 6: Lazy Loading via Tool Search

For agents with large tool catalogs (50+), don't load all schemas into context at startup.

**Pattern:** Provide a `tool_search(query)` meta-tool that discovers relevant tools on demand.

```json
{
  "name": "tool_search",
  "description": "Find available tools by keyword. Returns tool names and descriptions matching the query. Use this before calling a tool you haven't used yet.",
  "parameters": {
    "query": {"type": "string", "description": "Keywords describing what you need to do"}
  }
}
```

**Why:** Loading 100 tool schemas consumes 10,000-50,000 tokens of context before the agent even starts working.

**Source:** Anthropic, "Advanced Tool Use" (2025) — this is exactly how Claude Code's `ToolSearch` works.

---

## Advanced Patterns

### Programmatic Tool Calling (2025)

Let the model write code that calls tools in a sandbox, instead of one-tool-at-a-time through the API.

**Traditional (5 round trips):**
```
Agent: search_users(query="active")
System: [results]
Agent: get_orders(user_id="u1")
System: [results]
Agent: get_orders(user_id="u2")
System: [results]
Agent: get_orders(user_id="u3")
System: [results]
Agent: [synthesize]
```

**Programmatic (1 round trip):**
```python
users = search_users(query="active")
orders = [get_orders(user_id=u["id"]) for u in users[:3]]
return {"users": users, "orders": orders}
```

**Trade-off:** More powerful but requires a secure sandbox for code execution.

**Source:** Anthropic, "Advanced Tool Use" (2025)

### Compound Tools (Tool Composition)

Build higher-level tools that compose multiple lower-level tools internally.

```
deploy_service(service_name, version)
  → internally calls: build_image() → push_image() → update_manifest() → apply_manifest() → health_check()
```

**When to use:** When a multi-step tool workflow is always the same sequence. The agent doesn't need to manage the intermediate steps.

### Confirmation Tools

For high-risk operations, return a confirmation token that the agent must pass back:

```json
// First call
{"action": "delete_database", "confirmation_required": true, "token": "abc123", "message": "This will permanently delete 50,000 records. Call confirm_action(token='abc123') to proceed."}

// Second call (only if agent decides to proceed)
confirm_action(token="abc123")
```

**When to use:** Destructive operations, external-facing actions, costly operations.

---

## Tool Description Templates

### Data Retrieval Tool
```
{name} — {what it retrieves} from {source}.
Returns: {field list with types}.
Pagination: limit (default={N}, max={M}), cursor for next page.
Filters: {filter fields with syntax}.
Example: {name}({example params}) → {example response shape}
Errors: {common errors with recovery guidance}
```

### Action Tool
```
{name} — {what it does} to {target}.
Requires: {required params with constraints}.
Returns: {success shape} on success, {error shape} on failure.
Side effects: {what changes in the system}.
Idempotent: {yes/no — can it be safely retried?}
Example: {name}({example params}) → {example response}
Recovery: {what to do if it fails}
```

### Search Tool
```
{name} — Search {domain} by {search criteria}.
Query syntax: {syntax description with examples}.
Returns: [{result shape}], sorted by {sort order}.
Pagination: limit (default={N}, max={M}).
Example queries:
  - "field:value" — exact match
  - "field:*pattern" — wildcard
  - "field:>value" — comparison
Empty results: {guidance on broadening search}
```

---

## MCP-Specific Design Guidance

When building MCP (Model Context Protocol) servers:

### Transport Selection

| Transport | When to Use |
|-----------|-------------|
| stdio | Development, local tools, Claude Code integration |
| SSE/HTTP | Remote servers, multi-client, production deployment |
| Streamable HTTP | Long-running operations with progress updates |

### Tool Naming Conventions

- Use `snake_case` for tool names
- Prefix with domain: `github_search_issues`, `db_query_table`
- Keep names under 50 characters
- Make names verb-first: `search_*`, `create_*`, `list_*`, `get_*`

### Resource Design

MCP resources (read-only data the model can access) complement tools:

| Use Resources For | Use Tools For |
|-------------------|--------------|
| Static reference data | Dynamic queries |
| Configuration | State-changing operations |
| Documentation | External API calls |
| Schema definitions | Computations |

### Security Checklist

- [ ] Input validation on all parameters
- [ ] No SQL injection vectors
- [ ] No command injection vectors
- [ ] Rate limiting on expensive operations
- [ ] Authentication for sensitive operations
- [ ] Audit logging for all state changes
- [ ] Secrets never returned in tool output
