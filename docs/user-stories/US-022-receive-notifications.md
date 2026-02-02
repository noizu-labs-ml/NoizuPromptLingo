# User Story: Receive and Manage Notifications

**ID**: US-022
**Persona**: P-002 (Product Manager)
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **product manager**,
I want to **receive notifications when mentioned or when items need my attention**,
So that **I stay informed without constantly checking every room and task**.

## Acceptance Criteria

### Notification Retrieval
- [ ] Can retrieve notifications for a specific persona ID
- [ ] Can filter notifications by read/unread status
- [ ] Can filter notifications by type (mention, share, review, task_assigned, etc.)
- [ ] Notifications returned with timestamp in descending order (newest first)
- [ ] Pagination supported for notification list (limit/offset)

### Notification Content
- [ ] Each notification includes event type (mention, artifact_shared, review_requested, task_assigned, task_completed)
- [ ] Each notification includes context: originating room_id, task_id, or artifact_id
- [ ] Each notification includes actor (who triggered the notification)
- [ ] Each notification includes message preview or summary text
- [ ] Each notification includes deep link to source (room/task/artifact URL)

### Notification Triggers
- [ ] @mention in chat room generates notification to mentioned persona
- [ ] Artifact shared to room generates notification to room participants
- [ ] Review requested generates notification to reviewer
- [ ] Task assigned generates notification to assignee
- [ ] Task completed generates notification to task creator/watchers

### Notification Management
- [ ] Can mark individual notification as read
- [ ] Can mark all notifications as read
- [ ] Can delete/dismiss individual notification
- [ ] Read notifications visually distinguished from unread

### Delivery Channels
- [ ] In-app notification list accessible via API
- [ ] WebSocket/SSE push for real-time notification delivery (optional)
- [ ] Webhook delivery to external URL (configurable per persona, optional)

## Implementation Notes

### Notification Event Types
1. **mention** - @username in chat message
2. **artifact_shared** - Artifact shared to room or direct
3. **review_requested** - Review explicitly requested from persona
4. **task_assigned** - Task assigned to persona
5. **task_completed** - Task completed (for watchers/creators)
6. **room_invited** - Added to new chat room

### Delivery Channel Details
- **In-app**: Primary channel, always available via API
- **Real-time push**: WebSocket/SSE connection for live updates
- **Webhooks**: POST to external URL with notification payload (JSON)
- **Future**: Email digest, Slack/Discord integration

### Aggregation Strategy
- Group similar notifications within time window (e.g., 5 minutes)
- Example: "3 new messages in #dev-chat" instead of 3 separate notifications
- Configurable per persona (immediate vs. batched)

### Performance Considerations
- Index on (persona_id, created_at, read_status)
- Archive notifications older than retention period (default 30 days)
- Limit notification list queries to prevent abuse

## Dependencies

- Persona must exist
- Notification-triggering events (mentions, shares, etc.)

## Open Questions

- ~~How long to retain notifications?~~ → Default 30 days, configurable
- ~~Should there be notification preferences?~~ → Yes, per-persona delivery and aggregation settings
- Should notifications support threading (e.g., "5 replies to your comment")?
- Do agents (AI personas) receive notifications, or only human users?
- Should there be notification priorities (urgent vs. normal)?

## Related Commands

### Primary Commands
- `get_notifications(persona_id, unread_only=False, type=None, limit=50, offset=0)` → Returns notification list
- `mark_notification_read(notification_id)` → Marks single notification as read
- `mark_all_notifications_read(persona_id)` → Marks all notifications as read for persona
- `delete_notification(notification_id)` → Dismisses/deletes notification

### Configuration Commands
- `set_notification_preferences(persona_id, settings)` → Configure delivery channels and aggregation
- `register_webhook(persona_id, url)` → Register webhook URL for external delivery

## Test Scenarios

### Scenario 1: Mention Notification
1. User A sends message "@UserB check this out" in room
2. UserB calls `get_notifications(persona_id=B, unread_only=True)`
3. Response includes notification with type=mention, context=room_id, preview="check this out"

### Scenario 2: Webhook Delivery
1. UserB has webhook configured at `https://example.com/notifications`
2. UserA mentions UserB in chat
3. System POSTs notification JSON to webhook URL
4. Webhook receives payload with type, actor, context, timestamp

### Scenario 3: Notification Aggregation
1. UserA sends 5 messages in room within 3 minutes
2. UserB has aggregation enabled (5 min window)
3. UserB receives single notification "5 new messages in #dev-chat"
