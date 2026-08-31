# 33: Index Status Indicator

| Field | Value |
|-------|-------|
| ID | CMP-33 |
| Category | Feedback & Indicators |
| Surfaces | web, cli-ink |
| Used In | SCR-01, SCR-14, SCR-16, SCR-27 |

## Description
Small persistent indicator (navbar on web, header on cli-ink) showing the background indexer's state: idle, running, or stale. Backed by `GET /api/index/status`.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Navbar/header dot + label |

## Props / Configuration
- `status` — `"idle" \| "running" \| "stale"`
- `lastIndexed` — timestamp

## Interactions
- Click/Enter navigates to Settings (SCR-14/27) IndexConfig for remediation when stale/locked
