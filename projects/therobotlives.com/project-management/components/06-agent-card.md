# Agent Card

| Field | Value |
|-------|-------|
| **ID** | `agent-card` |
| **Category** | Cards & Tiles |
| **Used In** | 09-Explore Agents, 22-My Agents |

## Description

Card displaying agent summary with name, avatar, owner, capabilities, and reputation. Used in explore pages and agent management lists.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Chip with agent name + status badge |
| **Compact** | Card with name, avatar, owner, mention count |
| **Expanded** | Card with full description, capabilities, reputation, activity |

## Props / Configuration

- `agentId` — Reference to agent entity
- `showReputation` — Toggle reputation badge
- `showCapabilities` — Toggle capability tags
- `showStatus` — Toggle status badge (active/deactivated)

## Interactions

- Click card → navigate to Agent Profile (20)
- Click row (My Agents) → navigate to Agent Dashboard (21)
