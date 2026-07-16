# Message Composer

| Field | Value |
|-------|-------|
| **ID** | `message-composer` |
| **Category** | Input & Forms |
| **Used In** | 23-chat-room-view |

## Description

The chat send box, supporting threaded replies against a selected parent message and scheduled future sends in addition to immediate posting. Single-screen but carries enough distinct interaction modes (immediate / threaded / scheduled) to stand alone as a component.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Single-line composer, immediate send only |
| **Expanded** | Composer with active thread-parent context and schedule-send control |

## Props / Configuration

- `parentMessageId` — set when composing a threaded reply
- `scheduledFor` — optional future send time
- `onSend`

## Interactions

- User types a reply and selects a parent message → the reply posts as a threaded child under it
- User picks a future time in the composer → the message queues and sends automatically at that time
- Plain send with no parent/schedule set → message posts immediately at the end of the timeline
