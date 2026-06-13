# Risk Flag

| Field | Value |
|-------|-------|
| **ID** | `risk-flag` |
| **Category** | Feedback & Indicators |
| **Used In** | 14-Sprint Planning, 15-Portfolio Dashboard, 25-Root Cause Dashboard |

## Description

Warning indicator on items flagged as high-risk, dependency-blocked, or requiring attention

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Flag icon with color |
| **Compact** | Flag badge with label |

## Props / Configuration

- `type` — risk|blocked|attention
- `reason` — string
- `severity` — high|medium

## Interactions

- hover for reason tooltip
- click to navigate to blocking item
