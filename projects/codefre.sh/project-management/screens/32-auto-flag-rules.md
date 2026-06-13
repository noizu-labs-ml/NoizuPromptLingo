# Auto-Flag Rules

| Field | Value |
|-------|-------|
| **ID** | `auto-flag-rules` |
| **Type** | Settings |
| **Category** | Flagged Captures |
| **User Stories** | US-147 |

## Description

Configuration page for automatic flagging rules that detect interesting production interactions without manual review. Rules match on regex, attribute equality, latency, or token count thresholds.

## Key Components

- **Rule list** — Active rules with type, pattern, default reason, tags, match count
- **New Rule form** — Rule type picker, pattern/threshold config, reason, tags
- **Enable/disable toggle** — Per-rule on/off
- **Match count stats** — How many captures each rule has generated

## Interactions

- Create rules with type-specific configuration
- Enable/disable individual rules
- View match counts for tuning
- Delete (soft) rules

## Navigation

- Accessible from: Flagged Captures Library (rules link), Organization Settings
- Links to: Flagged Captures Library (view matches)
