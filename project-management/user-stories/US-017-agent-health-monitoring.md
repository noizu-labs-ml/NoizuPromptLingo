---
id: US-017
title: "Monitor Agent Health and Performance"
slug: "agent-health-monitoring"
personas: [P-001, P-004]
epic: "Agent Management"
priority: "should-have"
complexity: "M"
tags: [agents, health, monitoring, performance, observability]
---

# US-017: Monitor Agent Health and Performance

## User Story

**As a** DevOps/SRE Lead (P-004),
**I want to** view health and performance metrics for each running agent,
**So that** I can detect degraded agents, identify resource bottlenecks, and ensure agents are processing telemetry without falling behind.

## Acceptance Criteria

- [ ] Given I navigate to an agent's detail page, when I click the "Health" tab, then I see a dashboard showing: telemetry ingestion rate (msg/sec), processing latency (p50/p95), anomaly detection rate, actions queued vs. executed, and agent uptime.
- [ ] Given an agent's processing latency exceeds a configurable threshold (default: p95 > 5 seconds), when the threshold is breached, then the agent status changes to "Degraded" and I receive a notification.
- [ ] Given an agent has not processed any telemetry for more than 10 minutes despite its monitored devices being online, when this condition is detected, then the agent status changes to "Stalled" and a system alert is raised.
- [ ] Given I view the agent health history graph, when I select a time range, then I can see historical performance metrics to correlate degradation with fleet events or platform changes.

## Notes

Agent health metrics should be exposed via the IoTGo API so P-004 can integrate them into existing observability stacks (Datadog, Grafana). Agent self-healing (auto-restart on stall) is a could-have follow-on.
