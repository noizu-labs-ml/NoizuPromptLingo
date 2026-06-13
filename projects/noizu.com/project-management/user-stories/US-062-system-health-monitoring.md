---
id: US-062
title: "System Health Monitoring"
slug: "system-health-monitoring"
personas: [P-007]
epic: "Admin Dashboard"
priority: "could-have"
complexity: "S"
tags: [admin, health, monitoring, uptime, status]
---

# US-062: System Health Monitoring

## User Story

**As a** site administrator,
**I want to** view a system health panel showing application uptime, recent error rates, and background job status,
**So that** I can detect and diagnose platform issues before clients are impacted.

## Acceptance Criteria

- [ ] Given I navigate to `/admin/system`, when the page loads, then I see status indicators for: web server, database connection, file storage, email delivery, and background job queue.
- [ ] Given all systems are operational, when the page loads, then all indicators display green with last-checked timestamp.
- [ ] Given a service check fails (e.g., DB connection timeout), when detected, then the indicator turns red and a notification is sent to the admin email.
- [ ] Given the health page, when I view the "Recent Errors" panel, then I see the last 20 application errors with timestamp, error message, and affected route.
- [ ] Given background jobs are configured (nightly cleanup, overdue checks), when I view the job status panel, then I see last run time and success/failure status for each job.

## Notes

Health checks should be lightweight pings — not deep load tests. External uptime monitoring (UptimeRobot, BetterUptime) is complementary, not replaced by this. Error panel can pull from structured logs. Related: US-051.
