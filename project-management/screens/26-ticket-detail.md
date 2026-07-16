# Ticket Detail

| Field | Value |
|-------|-------|
| **ID** | `ticket-detail` |
| **Type** | Primary |
| **Category** | Core Work |
| **User Stories** | US-009, US-010, US-014, US-082, US-089, US-093 |

## Description

Single-ticket view at `/app/[orgId]/tickets/[id]` for linking tickets (blocks/relates-to and polymorphic links to non-ticket entities), rolling up a PRD's linked user stories, watching for changes, and rendering non-English content correctly. Degrades gracefully when a polymorphic link target no longer exists.

## Key Components

- **Ticket Link Panel** — blocks/relates-to links to other tickets (US-009)
- **Polymorphic Link Panel** — links to non-ticket entities (wiki pages, artifacts, reviews), with an orphaned-link placeholder state (US-010, US-089)
- **Linked User Stories List** — user_story tickets rolled up under a PRD ticket (US-014)
- **Watch Toggle** — subscribes the user to change notifications for this ticket (US-082)
- **Localized Content Renderer** — correctly renders non-English ticket content (US-093)

## Interactions

- User adds a link via the Ticket Link Panel or Polymorphic Link Panel → link appears immediately; if the target is later deleted, the panel shows an orphaned-link placeholder instead of erroring (US-009, US-010, US-089)
- User on a PRD ticket clicks "link user story" → adds an entry to the Linked User Stories List (US-014)
- User clicks the Watch Toggle → future changes trigger a notification (US-082)

## Navigation

- Accessible from: Tickets List (25), Ticket Board (24)
- Links to: Wiki Browser (28), Artifact Detail (32), other Ticket Detail instances (via links)
