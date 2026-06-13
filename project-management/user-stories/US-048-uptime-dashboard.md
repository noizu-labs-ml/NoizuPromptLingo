---
id: US-048
title: "View uptime monitoring dashboard with response time graphs"
personas: [maya-chen]
domain: monitoring
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want to view an uptime monitoring dashboard for all my services with response time graphs so that I can spot degradation before users complain.

## Acceptance Criteria

- [ ] Dashboard shows each monitored endpoint with current status (up/down/degraded), uptime percentage over selectable time ranges (24h, 7d, 30d, 90d), and last check timestamp
- [ ] Response time is graphed per endpoint with p50, p95, and p99 latency lines; anomalous spikes are annotated
- [ ] Downtime events are displayed as a timeline bar (green/yellow/red segments) with hover details showing duration and cause if known
- [ ] Dashboard is keyboard-navigable — arrow keys move between services, Enter drills into detail, Escape returns to overview
- [ ] Monitoring data is ingested via provider adapters (UptimeRobot, Pingdom, custom health checks) or the platform's built-in synthetic monitor

## Notes

For a solo dev, this replaces the "open three tabs to check my services" workflow. The monitor agent should be able to answer natural language queries like "how was auth-service uptime last week?" using this data. Response time graphs should render efficiently even with 90 days of minute-level data — consider downsampling for longer ranges.
