# Custom Field & Type Editor

| Field | Value |
|-------|-------|
| **ID** | `custom-field-type-editor` |
| **Category** | Domain-Specific |
| **Used In** | 27-ticket-field-type-admin |

## Description

The admin-side schema authoring tool for NPL's ticketing system: defines project-scoped custom fields (with type/validation rules) and org-scoped custom ticket types (with allowed field sets), guards deletion/editing of in-use definitions with a usage indicator, and configures outbound webhooks fired on ticket state changes. Single screen, but a genuine schema-builder with several interlocking parts, and the direct producer for what the Dynamic Custom-Field Form renders at ticket-creation time.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Field/type definition form with validation rules and scope (project vs org) |
| **Full Page** | Combined fields + types + webhook configuration screen |

## Props / Configuration

- `scope` — `project` (custom fields) \| `org` (custom ticket types)
- `usageCount` — how many tickets currently use a field/type, shown before an edit/delete is allowed to proceed
- `webhooks` — outbound endpoints and their triggering state-change events

## Interactions

- Admin defines a new field and scopes it to a project → immediately available on that project's ticket forms (consumed by the Dynamic Custom-Field Form)
- Admin defines a new type and scopes it to the org → selectable from any project's ticket-creation form
- Admin adds a webhook target URL and selects triggering state transitions → the webhook fires on matching ticket transitions going forward
