# Backend Domains — changesets 011–082

Authoritative source: `backend/db/changelog/` (Liquibase, applied via `make migrate` / liquibase-shell). Changesets 000–010 (core identity) are documented in [core-identity.md](core-identity.md).

## Changeset → Domain Index

| Domain | Changesets | Tables / objects |
|--------|-----------|------------------|
| Webhooks | 011 | webhooks |
| Admin flag | 012 | users.admin flag |
| PBAC / ACL | 013–016, 018, 019, 021, 053, 081 | group_policies, ad_groups, ad_copies, custom_roles, custom_role_permissions, user_policies, memberships→PBAC migration, stored procedures, seed data, lead role, ACL core |
| Projects | 017, 034, 055 | projects, domain-org binding, ticket human keys |
| Invitations | 022 | invite_tokens enhancement |
| Media / assets | 023, 024, 040 | media visibility + short-id, variants cache, asset_entries, asset_outputs, asset_entry_history |
| Sessions | 025, 026, 072, 079 | sessions, claim codes, runner model, inactivity |
| GitHub | 027, 028, 029 | github_tokens, github_repos, repo ACL |
| Cross-cutting | 030 | shared infra (npl_attachments, npl_comments, npl_reactions, npl_watches, npl_notifications) |
| Artifacts | 031 | artifacts, artifact_revisions |
| Chat | 032, 052, 054, 067, 068 | chat_rooms, chat_messages, chat_members, chat_events, chat_notifications; room slugs, message threads, DMs + membership, pins/highlights |
| Reviews | 033 | reviews, review_overlays |
| Tickets | 035, 036, 037, 055 | tickets, ticket_queues, ticket_links, ticket_entity_links, ticket_type_definitions, ticket_type_fields, ticket_field_definitions, ticket_number_counters |
| Boards | 038 | board_iterations, board_stages |
| Mock MCP | 039, 057, 058 | mock_mcp_definitions, mock_mcp_llms, mock_mcp_call_logs, modules |
| Personas | 041, 056 | personas, persona_journal_entries, persona_knowledge_entries, member-type persona |
| Instructions | 042 | instructions, instruction_versions |
| Agent pipes | 043, 051, 069 | npl_agent_pipe_entries, cursor; pipes dropped 069 |
| Remote access | 044 | remote_access_tunnels |
| Memory | 045–049 | memories, memory_compartments, memory_quarantine, memory_agent_state, memory_recall_log, association_edges + memory enums |
| Agent call signs | 050 | agent_call_signs |
| Customers | 059 | customers, customer_personas, customer_segments |
| Market | 060, 061 | market_reports, competitors, keywords, landing_pages, ad_copies, ad_groups, campaigns |
| LLM models | 062 | llm_models |
| Media providers | 063 | media_provider_configs |
| Notifications | 064 | chat_notifications |
| PubSub | 065, 066 | npl_pubsub_channels, npl_pubsub_messages, npl_pubsub_follows; watch filters |
| Unicode codex | 070 | unicode_elements, unicode_element_relations, unicode_element_usages, unicode_special_usages |
| MCP platform | 070a, 071, 073, 075, 076, 080 | mcp_custom_scopes, mcp_pairing_grants, mcp_tool_vectors, scope packaging, mcp_overviews, account default, mcp_endpoint_templates, mcp_api_keys + toolsets |
| OAuth AS | 074 | oauth_clients, oauth_authorization_codes, oauth_refresh_tokens |
| Marketing | 077 | marketing signups |
| PM split | 078 | cross-DB FK drops (PM data moved to TRP) |
| Org slugs | 082 | org slug uniqueness |

## Table Inventory (all backend tables)

Core: users, user_credentials, user_sessions, user_media, media, organizations, memberships, invite_tokens, auth_providers, versioned_strings/names/descriptions, seed_helper_records, webhooks

ACL/PBAC: group_policies, ad_groups, ad_copies, custom_roles, custom_role_permissions, user_policies

Work surfaces: projects, sessions, artifacts, artifact_revisions, tickets + ticket_* (8 tables), board_iterations, board_stages, reviews, review_overlays, wiki_spaces, wiki_pages, wiki_attachments, wiki_comments, wiki_reactions

Chat: chat_rooms, chat_messages, chat_members, chat_events, chat_notifications

Personas/memory: personas, persona_journal_entries, persona_knowledge_entries, memories, memory_compartments, memory_quarantine, memory_agent_state, memory_recall_log, association_edges, agent_call_signs

Market/customers: customers, customer_personas, customer_segments, market_reports, competitors, keywords, landing_pages, ad_copies, ad_groups, campaigns, llm_models, media_provider_configs

MCP platform: mcp_api_keys, mcp_custom_scopes, mcp_pairing_grants, mcp_tool_vectors, mcp_overviews, mcp_endpoint_templates, oauth_clients, oauth_authorization_codes, oauth_refresh_tokens

GitHub: github_tokens, github_repos

Infra: remote_access_tunnels, asset_entries, asset_outputs, asset_entry_history, npl_attachments, npl_comments, npl_reactions, npl_watches, npl_notifications, npl_pubsub_channels, npl_pubsub_messages, npl_pubsub_follows, instructions, instruction_versions, unicode_elements, unicode_element_relations, unicode_element_usages, unicode_special_usages, mock_mcp_definitions, mock_mcp_llms, mock_mcp_call_logs

## Conventions

- UUID PKs, `timestamptz` with `now()` defaults, `updated_at` (not `modified_at`), soft-delete `deleted_at` on most tables
- Cross-cutting tables prefixed `npl_` (attachments/comments/reactions/watches/pubsub) attach to domain rows generically (owner type + id)
- Schema ownership: **Liquibase** (`backend/db/changelog/`) owns the schema; `backend/priv/repo/migrations/` holds only a minimal Ecto set (oban tables, MCP scopes/toolsets/templates, SSO claim codes, clients, org slug uniqueness) — do not add new schema via Ecto migrations
