# Status Badge

| Field | Value |
|-------|-------|
| **ID** | `status-badge` |
| **Category** | Feedback & Indicators |
| **Used In** | 05-Projects Dashboard, 24-Agent Development, 25-Agent Dashboard, 20-Mockup Viewer |

## Description

Colored badge indicating entity status. Adapts color and icon per context (agent status, story status, approval status). Includes non-color indicator (icon/text) for WCAG compliance.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Pill badge (icon + text) |
| **Compact** | Badge with tooltip on hover |

## Props / Configuration

- `status` — String (Idle/Working/Waiting/Error/Queued/In Progress/In Review/Approved/Rejected/Pending)
- `variant` — agent | story | approval
- `showIcon` — Boolean (default true for accessibility)

## Interactions

- Hover reveals tooltip with expanded description
- Pulsing animation on "Working" / "In Progress" states
