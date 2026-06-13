# Anomaly Correlation View

| Field | Value |
|-------|-------|
| **ID** | `anomaly-correlation` |
| **Type** | Primary |
| **Category** | Monitoring & Incidents |
| **User Stories** | US-054 |

## Description

AI-detected anomaly clusters across services with confidence scores, hypothesized root causes, service dependency graph overlay, and promote-to-incident action for confirmed anomalies.

## Key Components

- **Anomaly cluster cards** — Groups of correlated anomalies
- **Confidence score** — AI confidence that anomalies are related
- **Service dependency graph** — Visual graph showing affected services
- **Hypothesized cause** — AI-suggested root cause explanation
- **Promote to incident button** — Escalate anomaly cluster to formal incident
- **Historical match** — Similar past anomaly patterns for reference

## Interactions

- Review anomaly clusters sorted by confidence
- View dependency graph to understand blast radius
- Accept or dismiss AI hypothesis
- Promote to incident if confirmed real
- Compare with historical patterns

## Navigation

- Accessible from: Monitoring nav, alert notifications
- Links to: Incident Detail (on promotion), Uptime Dashboard, Service graph
