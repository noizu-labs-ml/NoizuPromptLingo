# ETL load order — shared tables → `pm_core`

Matches `docs/pm-core-cutover.md` § **ETL order (Phase 4)**.

Load in dependency order. Prefer **preserving UUIDs** when free; on collision
keep **TRP** id and rewrite NPL FKs via maps from `00_id_maps.sql`.

Human keys (`items.key` / `number`) stay immutable; **rebuild**
`item_number_counters` from `max(number)` after items load (step 8).

---

## 1. Auth providers

| Source | Tables | Target (`pm_core`) |
|--------|--------|--------------------|
| NPL / TRP | auth providers (app-specific names) | `auth_providers` (see liquibase `003-auth-providers`) |

- Map provider rows if both sides define the same OIDC issuer.
- **TODO:** operator merge of duplicate provider slugs.

## 2. Users (+ credential map)

| Source | Tables | Target |
|--------|--------|--------|
| NPL / TRP | `users`, credentials, auth sessions (if shared) | `users`, `user_credentials`, `user_sessions` |

- **D1:** merge by OIDC subject / email → one `pm_id` in `user_id_map`.
- Load TRP users first when emails collide (or pick canonical via census).
- Credentials: re-key `user_id` through `user_id_map`; do not dual-store secrets.
- **TODO:** export credential rows only if shared auth is required at cutover;
  MCP API keys stay NPL-local.

## 3. Organizations, memberships, invites, PBAC

| Source | Tables | Target |
|--------|--------|--------|
| NPL / TRP | `organizations`, memberships, `invite_tokens`, custom roles | same names in pm_core |
| NPL / TRP | PBAC groups, policies, scoped memberships, user/group policies | `groups`, `policies`, `scoped_memberships`, `user_policies`, `group_policies`, … |

- **D2:** TRP wins org slug collisions; record NPL → TRP in `org_id_map`.
- Memberships: map `user_id` + `organization_id` through maps.
- Invites: map org/user FKs; preserve token hashes if still valid.
- **TODO:** custom role permission sets — merge carefully if both define defaults.

## 4. Projects

| Source | Tables | Target |
|--------|--------|--------|
| NPL / TRP | `projects` (+ methodology, `key_prefix`, `default_queue_id`) | `projects` |

- Map `organization_id` via `org_id_map`.
- Defer `default_queue_id` FK until queues exist (step 6), or set NULL then backfill.
- Collisions → `project_id_map` (TRP id wins).

## 5. Item field / type definitions (NPL `ticket_*` → `item_*`)

| Source | Tables | Target |
|--------|--------|--------|
| TRP | `item_field_definitions`, `item_type_definitions`, `item_type_fields` | same |
| NPL | `ticket_field_definitions`, `ticket_type_definitions`, `ticket_type_fields` | `item_*` |

- Rename NPL `ticket_*` table/column prefixes to `item_*`.
- Scope uniqueness (global / org / project) must respect mapped org/project IDs.
- **TODO:** slug collisions across NPL+TRP at same scope.

## 6. Queues / stages / iterations

| Source | Tables | Target |
|--------|--------|--------|
| TRP | `item_queues`, `board_stages`, `board_iterations` | same |
| NPL | `ticket_queues` (+ stages/iterations if present) | `item_queues`, `board_stages`, `board_iterations` |

- Map org/project FKs.
- Backfill `projects.default_queue_id` after queues land.

## 7. Items ← tickets

| Source | Tables | Target |
|--------|--------|--------|
| TRP | `items` | `items` |
| NPL | `tickets` | `items` |

- Column rename: **`ticket_type` → `item_type`** (see `02_npl_tickets_to_items.sql`).
- Preserve UUIDs when no collision; else TRP keeps id, NPL maps via `item_id_map`.
- Remap `organization_id`, `project_id`, `queue_id`, `parent_id`, assignee/reporter
  user refs through maps as needed.
- Prefer loading **TRP items first**, then NPL tickets.

## 8. Links, events, rebuild counters

| Source | Tables | Target |
|--------|--------|--------|
| TRP / NPL | item/ticket links, events | `item_links`, item events, `item_entity_links`, … |
| — | counters | `item_number_counters` |

- Remap all item FKs through `item_id_map`.
- **Rebuild counters** from `max(number)` per scope — do not blindly copy counter rows.
- Human keys remain immutable.

## 9. Artifacts, wiki, personas

| Source | Tables | Target |
|--------|--------|--------|
| TRP / NPL (if shared) | artifacts + revisions, wiki spaces/pages, personas + journal/knowledge | `artifacts`, `artifact_revisions`, wiki, personas tables |

- Map org/project/user ownership FKs.
- **TODO:** promote only content that is truly shared (cutover matrix).

## 10. Polymorphic comments / attachments / reactions

| Source | Tables | Target |
|--------|--------|--------|
| TRP / NPL | comments, attachments, reactions on work entities | `pm_comments`, `pm_attachments`, `pm_reactions` |

- Remap polymorphic parent IDs (`item` / legacy `ticket`) through `item_id_map`.
- Map author `user_id` through `user_id_map`.

---

## Post-load

1. Run `03_validate.sql` count templates (source vs target).
2. Spot-check parent/epic graphs and human keys.
3. Dual-MCP validation on staging (NPL + TRP against same `pm_core`).
4. Only then consider `PM_CORE_ENABLED` on non-prod hosts.

## Explicitly out of order / out of scope

Do **not** ETL into `pm_core`:

- NPL-local: work sessions, agent pipes, chat, pubsub, memory, MCP keys, campaigns, …
- TRP-local: goals/OKRs, notifications, recurrence, saved views, voice conversation, …
