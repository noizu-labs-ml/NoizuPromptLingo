# Data Layer

## Database

PostgreSQL accessed via Ecto 3.13. Connection configured by `DATABASE_URL` environment variable, defaulting to `ecto://tobor:tobor_dev_password@localhost:5432/tobor_locker`.

## Schema Inventory

| Schema | Table | Key Fields | Scoped To |
|--------|-------|------------|-----------|
| User | users | email, name, oidc_sub | — |
| Project | projects | name, slug (unique), status, owner_id | — |
| ProjectMember | project_members | project_id, user_id, role, status | project |
| Session | sessions | title, description, status, project_id | project |
| Ticket | tickets | title, ticket_type, status, priority, project_id, queue_id | project |
| TicketQueue | ticket_queues | name, slug | — |
| TicketTypeDefinition | ticket_type_definitions | name, slug, description | — |
| TicketFieldDefinition | ticket_field_definitions | name, field_type, options | — |
| TicketLink | ticket_links | source_id, target_id, link_type | — |
| Artifact | artifacts | kind, title, mime_type, project_id | project |
| ArtifactRevision | artifact_revisions | artifact_id, version, content | artifact |
| AssetEntry | asset_entries | title, slug, asset_type, status, project_id | project |
| AssetOutput | asset_outputs | asset_entry_id, output_type, content | asset |
| AssetEntryHistory | asset_entry_history | asset_entry_id, action | asset |
| ChatRoom | chat_rooms | name, slug, topic, room_type | — |
| ChatMessage | chat_messages | room_id, sender_id, body | room |
| ChatMember | chat_members | room_id, user_id, role | room |
| ChatEvent | chat_events | room_id, event_type | room |
| ChatNotification | chat_notifications | user_id, room_id | user |
| Review | reviews | title, status, verdict, reviewer | — |
| ReviewOverlay | review_overlays | review_id, content | review |
| Comment | comments | commentable_type, commentable_id, body | polymorphic |
| Reaction | reactions | reactable_type, reactable_id, emoji | polymorphic |
| Watch | watches | watchable_type, watchable_id, user_id | polymorphic |
| WikiSpace | wiki_spaces | name, slug | — |
| WikiPage | wiki_pages | space_id, title, slug, body | space |
| WikiPermission | wiki_permissions | space_id, user_id, level | space |
| Attachment | attachments | attachable_type, attachable_id, filename | polymorphic |
| McpApiKey | mcp_api_keys | user_id, key_prefix, key_hash, status | user |
| AgentInstruction | agent_instructions | name, content | — |
| AgentOrchestration | agent_orchestrations | name, pattern, status | — |
| AgentPipeMessage | agent_pipe_messages | pipe_id, direction, payload | pipe |
| MockMcpDefinition | mock_mcp_definitions | slug, name, spec | — |
| MockMcpCallLog | mock_mcp_call_logs | definition_id, tool_name, args | definition |

## Migrations

Database schema is managed by **Liquibase** (not Ecto migrations). Changelog files live in `db/changelog/` and are registered in `db/changelog/db.changelog-master.yaml`. The Liquibase runner is containerized via `db/Dockerfile`.

Current changelogs:
- `000-extensions.yaml` — PostgreSQL extensions
- `001-enums.yaml` — Custom enum types
- `002-users.yaml` — Users table
- `003-mcp-api-keys.yaml` — API key storage
- `004-add-project-id-to-sessions.yaml` — Session-project association

> **Note**: Ecto migration files exist under `priv/repo/migrations/` for historical reasons (initial schema bootstrap) but Liquibase is the canonical migration system going forward.

## Project Scoping

Entities that belong to a project use a `project_id` foreign key (UUID, nullable). Currently project-scoped: Tickets, Artifacts, AssetEntries, Sessions. The `Projects.get/1` function accepts both UUIDs and slugs for lookup.

## Polymorphic Associations

Comments, Reactions, Watches, and Attachments use `{type, id}` pairs (`commentable_type`/`commentable_id` etc.) for polymorphic references across domains.
