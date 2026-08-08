# Session Detail

| Field | Value |
|-------|-------|
| **ID** | `session-detail` |
| **Type** | Primary |
| **Category** | Core Work |
| **User Stories** | US-002, US-003, US-005 |

## Description

Single-session workspace at `/app/[orgId]/sessions/[id]` where a user resumes a session and sees its linked rooms, tickets, and artifacts, updates its status/title/description, and tailors its tool descriptions to the target model/runner.

## Key Components

- **Session Header Card** — title/status/description with inline edit (US-003)
- **Linked Rooms/Tickets/Artifacts Panel** — cross-entity summary for this session (US-002)
- **Tool Description Tailor Panel** — per-model/runner tool-description customization (US-005)
- **Session Status Selector** — active/paused/completed control (US-003)

## Interactions

- User edits title/description inline on the Session Header Card → autosaves (US-003)
- User opens the Tool Description Tailor Panel and selects a target model/runner → tailored description preview updates (US-005)
- User clicks an entry in the Linked Rooms/Tickets/Artifacts Panel → routes to that entity's screen (US-002)

## Navigation

- Accessible from: Sessions List (20)
- Links to: Chat Room View (23), Ticket Detail (26), Artifacts List (31)
