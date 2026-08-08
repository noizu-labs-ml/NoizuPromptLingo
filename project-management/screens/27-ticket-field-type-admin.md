# Ticket Field/Type Admin

| Field | Value |
|-------|-------|
| **ID** | `ticket-field-type-admin` |
| **Type** | Settings |
| **Category** | Core Work |
| **User Stories** | US-011, US-012, US-104 |

## Description

Configuration screen at `/app/[orgId]/ticket-fields` and `/app/[orgId]/ticket-types` for defining project-scoped custom fields, org-scoped custom ticket types, and outbound webhooks fired on ticket state changes.

## Key Components

- **Custom Field Editor** — project-scoped field definitions with type/validation (US-011)
- **Custom Ticket Type Editor** — org-scoped type definitions with allowed field sets (US-012)
- **Field/Type Usage Indicator** — shows how many tickets use a field or type before editing/deleting it
- **Webhook Configuration Panel** — registers an outbound webhook for ticket state-change events (US-104)

## Interactions

- User defines a new field in the Custom Field Editor and scopes it to a project → available immediately on that project's ticket forms (US-011)
- User defines a new type in the Custom Ticket Type Editor and scopes it to the org → selectable from any project's New Ticket Form (US-012)
- User adds a target URL in the Webhook Configuration Panel and selects state-change triggers → webhook fires on matching transitions (US-104)

## Navigation

- Accessible from: Tickets List (25), Project Detail (19)
- Links to: none (terminal settings screen)
