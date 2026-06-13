---
id: story-027
title: "Monitor memory system health via operator dashboard"
persona: persona-human-operator
priority: must-have
complexity: L
status: draft
---

# Monitor memory system health via operator dashboard

**As** the Human Operator,
**I want to** view a real-time dashboard showing memory web health, emotional baselines, association graph topology, Guardian activity, and anomaly alerts,
**So that** I can observe system behavior, detect issues early, and make informed decisions about tuning and intervention.

## Acceptance Criteria
- [ ] Dashboard displays: total memory count (short-term vs. long-term), ingestion rate (memories/hour with sparkline), association graph summary (total links, average degree, clustering coefficient)
- [ ] Emotional baseline panel shows rolling mood metrics with drift indicators and historical trend lines
- [ ] Guardian activity panel shows: blocks, quarantines, contradiction alerts, and integrity scan results with severity-coded indicators
- [ ] Anomaly alert feed shows active and recent anomaly events with type, severity, and recommended actions
- [ ] All panels auto-refresh at configurable intervals (default: 30 seconds)
- [ ] Dashboard supports time range selection (last hour, last day, last week, last 30 days) for historical analysis
- [ ] Mobile-responsive layout for on-call monitoring

## Scenario: Normal operations monitoring
- **Given** the memory system has been operating normally for 7 days
- **When** the Human Operator opens the dashboard
- **Then** all health indicators show green/stable, the emotional baseline panel shows flat trend lines, the Guardian panel shows low block counts, and no anomaly alerts are active

## Scenario: Active anomaly requiring attention
- **Given** The Monitor has raised a `recall_degradation` anomaly after a pruning cycle
- **When** the Human Operator opens the dashboard
- **Then** the anomaly alert feed shows the active alert with severity "warning", the affected recall miss rate metric is highlighted in amber, and the recommended action "review recent pruning event, consider restoring pruned memories" is displayed

## Technical Notes
- The dashboard should consume The Monitor's health reports (story-010) as its primary data source
- Consider building on an existing observability platform (Grafana, custom Next.js dashboard) rather than building from scratch
- WebSocket or SSE for real-time updates; REST polling as fallback
- The dashboard is read-only in this story — write operations (tuning, manual promotion) are covered in story-028 and other operator stories

## Related Stories
- story-010: Monitor health reports are the data source for the dashboard
- story-008: Mood drift metrics are displayed in the emotional baseline panel
- story-009: Anomaly events are surfaced in the alert feed
- story-028: Weight tuning provides the write-side operator controls complementing this read-side dashboard
