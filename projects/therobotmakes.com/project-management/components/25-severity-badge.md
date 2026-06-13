# Severity Badge

| Field | Value |
|-------|-------|
| **ID** | `severity-badge` |
| **Category** | Feedback & Indicators |
| **Used In** | 24-Agent Development, 27-Review Gate |

## Description

Colored badge indicating issue severity (critical/warning/info/suggestion) used in code review, security scan, and test results. Groups with count provide summary overviews.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Small colored dot or pill |
| **Compact** | Badge with count (e.g., "3 Critical") |

## Props / Configuration

- `severity` — critical | warning | info | suggestion
- `count` — Number of issues at this severity (for summary badges)
- `label` — Optional text override

## Interactions

- Click grouped badge → filters list to that severity
- Critical badges pulse/animate for attention
- Tooltip shows severity definition
