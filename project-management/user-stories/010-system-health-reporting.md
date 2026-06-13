---
id: story-010
title: "Generate system health reports"
persona: persona-the-monitor
priority: should-have
complexity: M
status: draft
---

# Generate system health reports

**As** The Monitor,
**I want to** generate periodic health reports summarizing memory web statistics, emotional baselines, association graph metrics, Guardian activity, and anomaly history,
**So that** the Human Operator has a consolidated view of system health without needing to query individual subsystems.

## Acceptance Criteria
- [ ] Health reports are generated at configurable intervals (default: hourly summary, daily digest)
- [ ] Each report includes: total memory count, new memories (period), active associations, pruned memories, Guardian blocks/quarantines, anomaly events, mood drift summary
- [ ] Reports include trend indicators (up/down/stable) compared to the previous period
- [ ] Reports are stored as structured data (JSON) and can be rendered as human-readable markdown
- [ ] Critical health thresholds trigger immediate out-of-band alerts rather than waiting for the next report cycle
- [ ] Historical reports are retained for 90 days for trend analysis

## Scenario: Normal hourly health report
- **Given** the system has been operating normally for the past hour with 120 new memories, 340 new associations, 0 Guardian blocks, 0 anomalies
- **When** The Monitor generates the hourly health report
- **Then** all metrics show "stable" trends, no alerts are raised, and the report is stored and available on the operator dashboard

## Scenario: Health report during active incident
- **Given** The Guardian has blocked 15 memories in the last hour (5x normal) and an anomaly event is active
- **When** The Monitor generates the hourly health report
- **Then** the report highlights the Guardian block spike with a "critical" trend indicator, cross-references the active anomaly event, and an immediate alert is sent to the operator

## Technical Notes
- Health reports should be lightweight aggregations, not full data dumps
- Consider using a time-series database (or at minimum, a metrics table) for efficient trend computation
- The daily digest should include sparkline-style trend data for the past 7 days
- Reports feed into the Human Operator's dashboard (story-025) — design the JSON schema to be dashboard-friendly

## Related Stories
- story-008: Mood drift metrics are included in health reports
- story-009: Anomaly events are summarized in health reports
- story-007: Integrity validation results are included in health reports
- story-025: Human Operator dashboard consumes health reports for visualization
