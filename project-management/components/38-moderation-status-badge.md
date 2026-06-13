# Moderation Status Badge

| Field | Value |
|-------|-------|
| **ID** | `moderation-status-badge` |
| **Category** | Feedback & Indicators |
| **Used In** | 22-Content Moderation Queue, 07-Laboratory |

## Description

Badge indicating content moderation status (Pending Review, Approved, Rejected). Shown on community-submitted content.

## Size Variants

| Variant | Description |
|---------|-------------|
| Inline | Small badge/chip displayed inline with content |

## Props / Configuration

- `status` — `pending` | `approved` | `rejected`
- `showLabel` — Boolean toggling text label vs icon-only display

## Interactions

- Static display showing current moderation state
- Clicking may reveal moderation details or reason for content owner
