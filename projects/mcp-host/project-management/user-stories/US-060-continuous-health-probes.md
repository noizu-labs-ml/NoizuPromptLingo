---
id: US-060
title: "System runs continuous synthetic health probes on hosted endpoints"
slug: "continuous-health-probes"
personas: [P-008]
epic: "Registry & Discovery"
priority: "must-have"
complexity: "L"
tags: [registry, health-checks, monitoring, probes, automation]
---

# US-060: System Runs Continuous Synthetic Health Probes on Hosted Endpoints

## User Story

**As a** Automated Agent System (P-008),
**I want to** the platform to continuously run synthetic health probes against every hosted MCP server endpoint,
**So that** health status data (US-056) is always current and users can rely on accurate reliability signals.

## Acceptance Criteria

- [ ] Given an MCP server is deployed and listed in the registry, when the health probe system initializes, then it schedules probes at 60-second intervals against the server's health endpoint using the MCP protocol health check method.
- [ ] Given a health probe completes successfully within the expected latency threshold, when the result is recorded, then the server's health status is updated to "healthy" and the response time is stored for percentile calculations.
- [ ] Given a health probe fails (timeout, connection refused, non-200 response, protocol error), when the failure is detected, then the system increments the failure counter and after 3 consecutive failures transitions the server to "unhealthy" status.
- [ ] Given a health probe response time exceeds the p95 threshold by 2x, when the probe completes, then the server status is transitioned to "degraded" and the elevated latency is recorded.
- [ ] Given a server transitions from healthy to degraded or unhealthy, when the status change occurs, then an event is published to the notification system for downstream consumers (US-056, US-059, US-069) and an audit log entry is created.
- [ ] Given the health probe system itself experiences issues, when probe delivery drops below 95% coverage, then a platform-level alert is triggered to the operations team and affected servers display an "unknown" health status rather than stale data.

## Notes

This is an infrastructure-level story driven by the platform itself (P-008). Probes must execute from multiple geographic regions to capture real-world latency. The probe interval should be configurable per server based on tier. Related: US-056, US-059, US-069.
