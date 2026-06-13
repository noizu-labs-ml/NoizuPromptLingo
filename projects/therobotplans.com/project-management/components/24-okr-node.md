# OKR Node

| Field | Value |
|-------|-------|
| **ID** | `okr-node` |
| **Category** | Cards & Tiles |
| **Used In** | 48-OKR Hierarchy, 50-Goal Alignment Viz |

## Description

Tree node representing an Objective or Key Result with progress, visibility badge, and linked item count

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Title + progress percentage inline |
| **Compact** | Node with progress bar and visibility badge |
| **Expanded** | Node with linked items list and check-in history |

## Props / Configuration

- `title` — string
- `type` — objective|key_result
- `progress` — number
- `visibility` — personal|team|org
- `linkedItemCount` — number
- `stale` — boolean

## Interactions

- expand/collapse children
- click for detail
- drag items to link
- inline progress update
