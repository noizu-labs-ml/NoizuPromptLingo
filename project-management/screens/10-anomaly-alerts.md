# Anomaly Alerts

| Field | Value |
|-------|-------|
| **ID** | `anomaly-alerts` |
| **Type** | Primary |
| **Category** | SafeMCP / Audit |
| **User Stories** | US-025 |

## Description

Alert configuration and history dashboard for anomalous usage patterns. Configure thresholds, view past alerts, investigate incidents.

## Key Components

- **AlertRuleBuilder**
- **AlertHistoryList**
- **AlertDetailPanel**
- **BaselineComparisonChart**
- **AlertStatusBadges**

## Interactions

- Create alert rules
- Acknowledge/resolve/mark false positive
- Click investigate -> pre-filtered audit log
- Configure notification channels

## Navigation

- SafeMCP -> Anomaly Alerts
