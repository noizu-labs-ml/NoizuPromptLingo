# Chat Room List

| Field | Value |
|-------|-------|
| **ID** | `chat-room-list` |
| **Type** | Primary |
| **Category** | Collaboration |
| **User Stories** | US-015, US-019, US-021, US-081 |

## Description

Org-scoped listing of chat rooms at `/app/[orgId]/chat`, covering room creation, per-room mute state, unread notifications, and pub/sub channel following.

## Key Components

- **Room List Sidebar** — all rooms scoped to the org/session/project, with unread badges (US-021)
- **Create Room Button** — scopes a new room to a session or project (US-015)
- **Room Mute Toggle** — mute / mute-unless-mentioned per room (US-019)
- **Channel Follow Toggle** — subscribe to a pub/sub channel for updates (US-081)
- **Unread Notification Badge** — per-room unread count, clears on open (US-021)

## Interactions

- User clicks Create Room Button → scope picker (session/project), then the room is created and opened (US-015)
- User right-clicks/long-presses a room → Room Mute Toggle and Channel Follow Toggle appear in a context menu (US-019, US-081)
- User opens a room → its Unread Notification Badge clears (US-021)

## Navigation

- Accessible from: Org Dashboard (17), Session Detail (21)
- Links to: Chat Room View (23)
