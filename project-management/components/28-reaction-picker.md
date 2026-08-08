# Reaction Picker

| Field | Value |
|-------|-------|
| **ID** | `reaction-picker` |
| **Category** | Feedback & Indicators |
| **Used In** | 23-chat-room-view, 28-wiki-browser |

## Description

Emoji reactions on a piece of content — a chat message or a wiki page/comment — with an aggregated reaction summary per target.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Reaction summary strip with counts |
| **Compact** | Summary strip plus an emoji-picker popover to add a reaction |

## Props / Configuration

- `targetId` — the message/page/comment being reacted to
- `reactions` — current reaction summary (emoji → count, current-user state)
- `onReact`

## Interactions

- User picks an emoji → the target's reaction summary updates immediately; picking an already-applied emoji again removes the user's reaction
- Chat variant also supports a "highlight" toggle alongside reactions on a message
