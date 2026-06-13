# Server Detail

| Field | Value |
|-------|-------|
| **ID** | `server-detail` |
| **Type** | Primary |
| **Category** | JustMCP Deployment |
| **User Stories** | US-029, US-031, US-032, US-033, US-034, US-035, US-036, US-038, US-060, US-076, US-077, US-078, US-079, US-081, US-093 |

## Description

Comprehensive server management page with tabs: Status, Metrics, Performance, Scaling, Versions, Activity, Domain Settings. Shows real-time health and controls.

## Key Components

- **ServerStatusHeader**
- **MetricsTimeSeriesChart**
- **ErrorRateChart**
- **LatencyPercentileChart**
- **ToolBreakdownTable**
- **ScalingControls**
- **VersionHistoryList**
- **RollbackDialog**
- **ActivityLog**
- **CustomDomainConfig**
- **DeleteConfirmation**

## Interactions

- View real-time metrics
- Switch time ranges
- Drill into error spikes
- Adjust scaling sliders
- Enable auto-scaling
- Rollback to version
- Delete/decommission
- Configure custom domain

## Navigation

- Dashboard -> Server Detail
