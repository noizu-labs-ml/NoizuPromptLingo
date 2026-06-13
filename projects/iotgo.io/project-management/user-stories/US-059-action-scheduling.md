---
id: US-059
title: "Action Scheduling"
slug: "action-scheduling"
personas: [P-003, P-007]
epic: "Action Execution & Remediation"
priority: "should-have"
complexity: "M"
tags: [scheduling, cron, maintenance, automation]
---

# US-059: Action Scheduling

## User Story

**As a** Smart Building Facility Manager (P-003),
**I want to** schedule playbook actions to run at specific times or on a recurring cron schedule,
**So that** routine maintenance tasks (restarts, health checks, config syncs) happen automatically during low-traffic windows without requiring manual triggering.

## Acceptance Criteria

- [ ] Given I am creating a scheduled action, when I configure it, then I can set a one-time datetime or a cron expression, select a target device group, and optionally set a maintenance window (e.g., "only between 02:00–04:00 local time").
- [ ] Given a scheduled action is due, when the trigger fires, then the action is queued and executes per the same execution pipeline as manually triggered actions (including safety limits and approval gates if applicable).
- [ ] Given I have multiple scheduled actions, when I view the schedule calendar, then I see a timeline view of upcoming actions with device group, playbook name, and estimated impact.
- [ ] Given a scheduled action is missed (e.g., system downtime), when the system recovers, then the missed run is logged as "Skipped" with the reason, and the next scheduled run proceeds normally.
- [ ] Given I want to temporarily suspend a recurring schedule, when I toggle the schedule to "Paused", then no further runs fire until I re-enable it, without deleting the schedule.

## Notes

Maintenance windows respect per-org timezone settings. Connects to US-054 (safety limits) and US-055 (approval queue) — scheduled actions still traverse those gates.
