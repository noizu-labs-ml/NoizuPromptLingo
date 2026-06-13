---
id: story-009
title: "Detect anomalies in memory system behavior"
persona: persona-the-monitor
priority: should-have
complexity: L
status: draft
---

# Detect anomalies in memory system behavior

**As** The Monitor,
**I want to** detect anomalous patterns across the memory system — unusual ingestion rates, association graph topology changes, recall pattern shifts, and Guardian alert spikes,
**So that** systemic issues (attacks, bugs, degradation) are caught before they corrupt the memory web.

## Acceptance Criteria
- [ ] Ingestion rate anomalies: alerts when memory creation rate deviates >3 sigma from the trailing 7-day average
- [ ] Association topology anomalies: alerts when the average node degree changes by >20% in a 24-hour window
- [ ] Recall pattern anomalies: alerts when recall miss rate (queries returning zero results) exceeds 15% over a 1-hour window
- [ ] Guardian alert correlation: alerts when Guardian blocks/quarantines spike >5x in a 1-hour window
- [ ] Each anomaly produces a structured `AnomalyEvent` with type, severity, metric values, and recommended investigation steps
- [ ] Anomaly detection runs continuously with a check interval of 5 minutes

## Scenario: Sudden ingestion spike from batch import
- **Given** a batch import (story-004) causes memory creation rate to jump from 50/hour to 5,000/hour
- **When** The Monitor's anomaly detection runs
- **Then** an `AnomalyEvent` of type `ingestion_spike` is raised, but with a `likely_cause: batch_import` annotation if a batch job is currently running, downgrading severity to `informational`

## Scenario: Recall degradation after association pruning
- **Given** The Curator runs aggressive pruning (story-015), removing 2,000 weak associations
- **When** recall miss rate climbs to 18% in the following hour
- **Then** The Monitor raises an `AnomalyEvent` of type `recall_degradation` with severity `warning`, correlating the timing with the pruning event

## Technical Notes
- Anomaly detection should be context-aware: known system operations (batch imports, pruning runs, maintenance) should be registered as "expected events" to reduce false positives
- Consider a simple anomaly detection approach first (z-score on sliding windows) before investing in ML-based approaches
- The Monitor should maintain an event log that The Human Operator can query for root cause analysis
- Cross-correlating anomalies (e.g., ingestion spike + Guardian block spike = likely attack) adds significant value

## Related Stories
- story-006: Guardian injection blocking feeds alert data to The Monitor
- story-007: Integrity validation reports are consumed as anomaly signals
- story-008: Mood drift is one dimension of system anomaly
- story-010: Health reporting aggregates anomaly events into dashboards
- story-015: Curator pruning events should be registered to prevent false anomaly alerts
