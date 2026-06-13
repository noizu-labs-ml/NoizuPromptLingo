# Tool Layout Reference

This directory documents the NPL MCP tool surface organized by domain. Each domain groups related tools behind a single MCP-visible `{Domain}.Overview` method; all other tools in the domain are hidden and callable via `ToolCall`.

## Visibility Model

- **MCP-visible**: Appears in the MCP `tools/list` response. Clients can call directly.
- **Hidden**: Not in `tools/list`. Discoverable via `ToolSummary`/`ToolSearch`. Invoked via `ToolCall(tool="Name", arguments={...})`.
- **Overview pattern**: Each domain exposes exactly one MCP-visible tool (`{Domain}.Overview`) that lists all tools in that domain with descriptions.

### Always-visible tools (no domain gate)

| Tool | Purpose |
|------|---------|
| `ToolSummary` | Browse tools by domain |
| `ToolSearch` | Search by name, description, or intent |
| `ToolDefinition` | Get full parameter schema |
| `ToolCall` | Invoke any hidden tool |
| `ToolHelp` | LLM-driven usage guidance |
| `NPLSpec` | Generate NPL spec blocks |
| `NPLLoad` | Load NPL components |
| `ToolSession.Generate` | Generate/lookup session UUID |
| `ToolSession` | Get session info |

## Domains

| # | Domain | Subdomain | Overview Tool | Doc |
|---|--------|-----------|---------------|-----|
| 1 | Tool Discovery | *(root)* | *(always visible)* | [01-tool-discovery.md](01-tool-discovery.md) |
| 2 | Session | `sessions.tobor.locker` | `Session.Overview` | [02-session.md](02-session.md) |
| 3 | Ticket | `tickets.tobor.locker` | `Ticket.Overview` | [03-ticket.md](03-ticket.md) |
| 4 | Review | `review.tobor.locker` | `Review.Overview` | [04-review.md](04-review.md) |
| 5 | Chat | `chat.tobor.locker` | `Chat.Overview` | [05-chat.md](05-chat.md) |
| 6 | Wiki | `wiki.tobor.locker` | `Wiki.Overview` | [06-wiki.md](06-wiki.md) |
| 7 | Artifact | *(default)* | `Artifact.Overview` | [07-artifact.md](07-artifact.md) |
| 8 | Gopher | *(default)* | `Gopher.Overview` | [08-gopher.md](08-gopher.md) |
| 9 | Web | *(default)* | `Web.Overview` | [09-web.md](09-web.md) |
| 10 | Agent | *(default)* | `Agent.Overview` | [10-agent.md](10-agent.md) |
| 11 | Other | *(various)* | *(various)* | [11-other.md](11-other.md) |

## Cross-Cutting Patterns

Several operations are shared across domains via generic polymorphic handlers rather than per-domain reimplementations:

| Pattern | Domains | Doc |
|---------|---------|-----|
| **Attach** | Ticket, Review, Chat, Wiki | [12-cross-cutting.md](12-cross-cutting.md) |
| **Comment** | Ticket, Review, Wiki | [12-cross-cutting.md](12-cross-cutting.md) |
| **React** | Chat, Ticket, Comment | [12-cross-cutting.md](12-cross-cutting.md) |
| **Watch** | Ticket, Wiki | [12-cross-cutting.md](12-cross-cutting.md) |

## Backwards Compatibility

Renamed tools retain permanent aliases so old names continue to resolve:

| Old Name | New Name |
|----------|----------|
| `Tasks.*` | `Ticket.*` |
| `Tasker.*` | `Gopher.*` |
| `Browser.*` | `Web.*` |
| `Chat.ShareArtifact` | `Chat.Attach` |
| `Chat.ReadNotification` | `Chat.Notification.Clear` |
| `Review.AddComment` | `Review.Comment` |
| `Review.AddOverlay` | `Review.Overlay` |
| `AgentInputPipe` | `Agent.Pipe.In` |
| `AgentOutputPipe` | `Agent.Pipe.Out` |
