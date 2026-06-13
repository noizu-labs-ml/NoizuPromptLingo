# SLO Compliance Dashboard

| Field | Value |
|-------|-------|
| **ID** | `slo-dashboard` |
| **Type** | Dashboard |
| **Category** | Monitoring & Incidents |
| **User Stories** | US-050 |

## Description

SLO definitions with remaining error budget, burn rate trend lines, budget alert thresholds, and historical compliance. Helps teams understand how much error budget remains before action is needed.

## Key Components

- **SLO cards** — One card per SLO with target and current value
- **Error budget gauge** — Visual gauge showing remaining error budget
- **Burn rate chart** — Time-series of error budget consumption rate
- **Alert thresholds** — Configurable alert levels (50%, 25%, 10% remaining)
- **Historical compliance** — Monthly/quarterly compliance history
- **Service filter** — Focus on SLOs for a specific service

## Interactions

- Click SLO card for detailed breakdown
- Configure alert thresholds per SLO
- View burn rate trends to predict exhaustion
- Navigate to related incidents when budget spent
- Export compliance reports

## Navigation

- Accessible from: Monitoring nav, Uptime Dashboard
- Links to: Incident Detail, Uptime Dashboard, Alert configuration
