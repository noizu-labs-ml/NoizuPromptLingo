---
id: US-033
title: "Schedule recurring scans"
slug: "schedule-recurring-scans"
personas: [P-002, P-007]
epic: "Defender — Scan Configuration"
priority: "could-have"
complexity: "L"
tags: [defender, scan-config, scheduling, automation, cron]
---

# US-033: Schedule Recurring Scans

## User Story

**As a** Enterprise AppSec Manager (P-002),
**I want to** schedule a saved scan template to run automatically on a recurring schedule (daily, weekly, monthly),
**So that** I can maintain continuous security coverage of production LLM endpoints without requiring manual intervention for each test cycle.

## Acceptance Criteria

- [ ] Given I have a saved scan template, when I open its settings, then I see a "Schedule" tab where I can configure recurrence (daily, weekly, monthly) and start time.
- [ ] Given I configure a schedule, when the scheduled time arrives, then the scan is automatically triggered using the saved template configuration and prompts for credentials via a stored secret (not inline).
- [ ] Given a scheduled scan completes, when I view the scan history, then the run is labeled "scheduled" and linked to the originating schedule definition.
- [ ] Given I want to pause a schedule, when I toggle it off, then future runs are suspended without deleting the schedule definition.
- [ ] Given a scheduled scan fails (e.g., connectivity error), when the failure occurs, then I receive a notification (per US-047 email alert settings) and the failure is logged with the error reason.

## Notes

Requires secure credential storage for unattended runs — credentials provided at schedule creation and stored encrypted, never logged. Schedule timezone must be configurable. This feature is a dependency for CI/CD gate workflows described in US-046.
