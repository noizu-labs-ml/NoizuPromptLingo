# Health Indicator

| Field | Value |
|-------|-------|
| **ID** | `health-indicator` |
| **Category** | Data Display |
| **Used In** | 15-Portfolio Dashboard, 24-Bug SLA Dashboard, 32-Uptime Dashboard, 34-SLO Dashboard, 48-OKR Hierarchy, 53-Agent Team Dashboard, 57-Agent Performance Dashboard |

## Description

Green/yellow/red status signal conveying health of a project, service, or goal

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Colored dot or icon next to a label |
| **Compact** | Badge with status text and color |
| **Expanded** | Card with breakdown of contributing factors |

## Props / Configuration

- `status` — green|yellow|red|gray
- `label` — string
- `detail` — optional breakdown object
- `onClick` — handler for drill-down

## Interactions

- click for detail breakdown
- hover for tooltip summary
