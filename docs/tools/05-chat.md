# Chat Domain

**Subdomain:** `chat.tobor.locker`

Chat provides event-sourced chat rooms for agent-to-agent and agent-to-human communication. Rooms support messages, structured events (actions, todos), emoji reactions, artifact sharing, and notification management.

## Methods

| Method | Visibility | Description |
|--------|-----------|-------------|
| `Chat.Overview` | visible | List chat tools and room activity summary |
| `Chat.CreateRoom` | hidden | Create a new chat room |
| `Chat.GetRoom` | hidden | Get room details and member list |
| `Chat.ListRooms` | hidden | List rooms by recent activity |
| `Chat.SendMessage` | hidden | Post a message to a room |
| `Chat.ListMessages` | hidden | List messages with pagination |
| `Chat.Attach` | hidden | Share an artifact in a room (cross-cutting) |
| `Chat.AddMember` | hidden | Add a persona to a room |
| `Chat.ListMembers` | hidden | List room members |
| `Chat.CreateEvent` | hidden | Create a structured event |
| `Chat.ListEvents` | hidden | List events, optionally filtered |
| `Chat.React` | hidden | Add emoji reaction (cross-cutting) |
| `Chat.Notifications` | hidden | List notifications for a persona |
| `Chat.Notification.Clear` | hidden | Mark notifications as read |

---

### Chat.Overview

Returns a list of all chat tools with descriptions and a summary of room activity (room count, unread count).

**Parameters:** None

---

### Chat.CreateRoom

Create a new chat room. Rooms can be associated with a session.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name` | str | yes | Room name |
| `description` | str | no | Room description/topic |
| `session_id` | str | no | Session UUID to associate with |

**Returns:** Room object with `id`, `name`, `created_at`.

---

### Chat.GetRoom

Get a room's details including name, description, member count, and last message timestamp.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `room_id` | int | yes | Room ID |

---

### Chat.ListRooms

List chat rooms ordered by most recent message activity.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `session_id` | str | no | Filter by session UUID |
| `limit` | int | no | Max results (default 50) |
| `offset` | int | no | Pagination offset |

---

### Chat.SendMessage

Post a text message to a chat room.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `room_id` | int | yes | Room ID |
| `content` | str | yes | Message body (markdown) |
| `sender` | str | yes | Persona slug of the sender |

**Returns:** Message object with `id`, `content`, `sender`, `created_at`.

---

### Chat.ListMessages

List messages in a room with pagination. Returns newest first.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `room_id` | int | yes | Room ID |
| `limit` | int | no | Max messages (default 50) |
| `before` | str | no | ISO8601 timestamp — return messages before this time |
| `after` | str | no | ISO8601 timestamp — return messages after this time |

---

### Chat.Attach

Share an artifact in a chat room. Creates a special event that links the artifact to the room's timeline. Uses the generic [Attach](12-cross-cutting.md#attach) pattern with `entity_type="chat_event"`.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `room_id` | int | yes | Room ID |
| `artifact_id` | int | yes | Artifact ID to share |
| `sender` | str | yes | Persona slug of the sharer |
| `comment` | str | no | Optional message to accompany the share |

**Aliases:** `Chat.ShareArtifact`

---

### Chat.AddMember

Add a persona to a chat room's member list.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `room_id` | int | yes | Room ID |
| `persona` | str | yes | Persona slug to add |
| `role` | str | no | Member role: `"member"` (default), `"admin"` |

---

### Chat.ListMembers

List all persona members of a chat room.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `room_id` | int | yes | Room ID |

---

### Chat.CreateEvent

Create a structured event in a chat room. Events represent actions, todos, milestones, or other structured data in the room's timeline.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `room_id` | int | yes | Room ID |
| `event_type` | str | yes | Event type: `"action"`, `"todo"`, `"milestone"`, `"decision"` |
| `content` | str | yes | Event content |
| `sender` | str | yes | Persona slug of the creator |
| `metadata` | dict | no | Additional structured data for the event |

---

### Chat.ListEvents

List structured events in a room with optional filtering.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `room_id` | int | yes | Room ID |
| `event_type` | str | no | Filter by event type |
| `limit` | int | no | Max events (default 50) |
| `since` | str | no | ISO8601 timestamp — events after this time |

---

### Chat.React

Add an emoji reaction to a chat event. Uses the generic [React](12-cross-cutting.md#react) pattern with `entity_type="chat_event"`.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `event_id` | int | yes | Chat event ID to react to |
| `persona` | str | yes | Persona slug |
| `emoji` | str | yes | Emoji character or shortcode |

---

### Chat.Notifications

List unread notifications for a persona across all rooms.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `persona` | str | yes | Persona slug |
| `limit` | int | no | Max notifications (default 50) |

---

### Chat.Notification.Clear

Mark one or all notifications as read.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `persona` | str | yes | Persona slug |
| `notification_id` | int | no | Specific notification ID. If omitted, clears all. |

**Aliases:** `Chat.ReadNotification`
