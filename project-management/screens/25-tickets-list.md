# Tickets List

| Field | Value |
|-------|-------|
| **ID** | `tickets-list` |
| **Type** | Primary |
| **Category** | Core Work |
| **User Stories** | US-006, US-013, US-072 |

## Description

Flat, filterable listing of tickets at `/app/[orgId]/tickets`, covering ticket creation with custom type/fields, the queue's recent-activity feed, and filtering by custom field values.

## Key Components

- **Ticket Table** — sortable/filterable list with custom field columns (US-072)
- **Create Ticket Button** — opens the new-ticket form (US-006)
- **New Ticket Form** — type selector with dynamic custom fields (US-006)
- **Custom Field Filter Bar** — filters the table by any custom field value (US-072)
- **Queue Activity Feed** — recent activity across the visible ticket queue (US-013)

## Interactions

- User clicks Create Ticket Button → New Ticket Form renders fields dynamically based on the selected custom type (US-006)
- User adds a filter in the Custom Field Filter Bar → Ticket Table narrows live (US-072)
- User scans the Queue Activity Feed for recent changes without opening individual tickets (US-013)

## Navigation

- Accessible from: Org Dashboard (17), Project Detail (19)
- Links to: Ticket Detail (26), Ticket Board (24)
