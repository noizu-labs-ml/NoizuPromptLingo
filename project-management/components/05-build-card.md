# Build Card

| Field | Value |
|-------|-------|
| **ID** | `build-card` |
| **Category** | Cards & Tiles |
| **Used In** | 07-Laboratory, 12-Clan Hub, 05-Template Gallery, 27-Tier List Builder (within 07) |

## Description

Self-contained card representing a fighter build. Shows creator, archetype, win rate, description, and action buttons. Supports obfuscation for shared builds and report flagging.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Name and archetype chip only; used in list and table contexts |
| **Compact** | Card with key stats (win rate, archetype, creator) and primary action |
| **Expanded** | Full card with graph preview, detailed stats, and all action buttons |

## Props / Configuration

- `build` — Build data object (name, archetype, creator, description, graph snapshot)
- `showStats` — Toggles win rate display visibility
- `obfuscated` — Enables black-box mode hiding internal graph structure
- `reportable` — Shows flag/report button for community moderation
- `draggable` — Enables drag interaction for tier list builder placement

## Interactions

- Click to navigate to full build detail view
- Fork build into Fighter Studio for editing
- Report or flag build for review
- Drag card into tier bracket (when in tier list builder context)
- Deploy build to active fighter slot (in template gallery context)
