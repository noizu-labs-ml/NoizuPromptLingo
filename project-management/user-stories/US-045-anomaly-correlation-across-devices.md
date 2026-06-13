---
id: US-045
title: "Anomaly Correlation Across Devices"
slug: "anomaly-correlation-across-devices"
personas: [P-006, P-002, P-004]
epic: "Anomaly Detection"
priority: "should-have"
complexity: "L"
tags: [anomaly-detection, correlation, fleet, root-cause, grouping]
---

# US-045: Anomaly Correlation Across Devices

## User Story

**As a** Data Scientist/ML Engineer (P-006),
**I want to** have the anomaly engine automatically identify when similar anomalies are occurring across multiple devices simultaneously or in rapid succession,
**So that** I can distinguish fleet-wide systemic issues from isolated individual device problems and prioritize accordingly.

## Acceptance Criteria

- [ ] Given anomalies are being generated across a fleet, when multiple devices in the same group exhibit the same anomaly type within a configurable time window (default: 5 minutes), then they are grouped into a correlated anomaly cluster event
- [ ] Given a correlated cluster is formed, when I view it, then I see the list of affected devices, the common metric(s) involved, and a timeline showing when each device entered the anomalous state
- [ ] Given a correlated cluster, when I open its investigation view, then I see suggested common causes (shared firmware version, same network segment, same power circuit) based on device metadata attributes
- [ ] Given a correlated cluster is linked to a playbook, when the cluster crosses a device count threshold I configure, then the playbook fires at the cluster level rather than once per device
- [ ] Given a device anomaly is part of a cluster, when I view individual device anomaly details, then I see a link back to the parent cluster event

## Notes

Cluster-level playbook triggers prevent alert storms on mass fleet events. The common-cause suggestion engine uses device metadata from the fleet connection layer. Depends on US-039 and US-043 for individual anomaly events as input.
