# Domain Architecture

## Overview

The application is organized into 8 domain MCP servers plus a root server. Each domain is a supervised GenServer registered as an MCP server with its own tool catalog. Domains are accessed via subdomain routing (`{domain}.tobor.locker/mcp`) and share a PostgreSQL database through Ecto.

## Domain Inventory

| Domain | Subdomain | Key Schemas | Tool Count |
|--------|-----------|-------------|------------|
| Sessions | `sessions.` | Session | 8 (create, update, get, list, contents, archive, activity, overview) |
| Tickets | `tickets.` | Ticket, TicketQueue, TicketTypeDefinition, TicketFieldDefinition, TicketLink | ~20 (CRUD + queues + definitions + links + feeds) |
| Chat | `chat.` | ChatRoom, ChatMessage, ChatMember, ChatEvent, ChatNotification | ~12 (rooms, messages, members, events) |
| Review | `review.` | Review, ReviewOverlay, Comment | ~8 (create, comment, overlay, compile) |
| Wiki | `wiki.` | WikiSpace, WikiPage, WikiPermission, Attachment | ~10 (spaces, pages, permissions) |
| Projects | `projects.` | Project, ProjectMember | ~11 (CRUD + membership + invites) |
| Artifacts | `artifacts.` | Artifact, ArtifactRevision | ~6 (CRUD + versioned revisions) |
| Assets | `assets.` | AssetEntry, AssetOutput, AssetEntryHistory | ~12 (media prompts, generation, evaluation, publishing) |
| Agents | *(root)* | AgentInstruction, AgentOrchestration, AgentPipeMessage | ~12 (orchestration, pipes, instructions) |

## Domain Module Structure

Each domain follows a consistent layout:

```
lib/noizu_prompt_lingua/domains/{domain}/
├── mcp.ex              # MCP server definition (use Noizu.MCP.Server)
├── {domain}.ex          # Domain logic module (CRUD, queries)
└── tools/
    ├── overview.ex      # Domain summary tool (always visible)
    ├── {entity}_create.ex
    ├── {entity}_get.ex
    ├── {entity}_list.ex
    ├── {entity}_update.ex
    └── ...
```

## Tool Visibility

Tools use the `hidden: true` option by default for CRUD operations. The Overview tool for each domain is always visible and serves as the entry point — it lists available tools and domain stats. Hidden tools are accessible via the root server's `ToolCall` discovery tool or direct MCP invocation.

## Mock MCP Gateway

The `mockmcp.tobor.locker` subdomain provides a dynamic MCP server generator. Users define MCP servers via YAML specifications (tool schemas, database tables), and the gateway dynamically provisions them with auto-generated tools, SQLite backing stores, and per-definition `/mcp/:slug/mcp` endpoints.

## Cross-Domain References

- **Sessions** group rooms, artifacts, and tickets under a shared context
- **Tickets**, **Artifacts**, and **Assets** are project-scoped via `project_id`
- **Reviews** can reference artifacts via overlays
- **Chat** rooms can be linked to sessions
- **Wiki** spaces operate independently with their own permission model

## Supervision Tree

All domain MCP servers are supervised under `NoizuPromptLingua.Supervisor` with a `:one_for_one` strategy. On startup, ticket type definitions are seeded via `Tickets.Seed.run()`.
