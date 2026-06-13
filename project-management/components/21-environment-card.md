# Environment Card

| Field | Value |
|-------|-------|
| **ID** | `environment-card` |
| **Category** | Cards & Tiles |
| **Used In** | 28-Environment Dashboard |

## Description

Deployment environment card showing service versions, last deploy info, and drift indicators

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Environment name + status + version count |
| **Expanded** | Full card with per-service versions and drift flags |

## Props / Configuration

- `name` — string (dev|staging|prod)
- `services` — version map
- `lastDeploy` — timestamp
- `deployer` — string
- `driftIndicators` — array

## Interactions

- click drift for diff detail
- click to deploy changelog
- trigger deploy from card
