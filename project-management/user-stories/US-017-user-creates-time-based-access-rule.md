---
id: US-017
title: "User creates a time-based access rule"
slug: "user-creates-time-based-access-rule"
personas: [P-003, P-006]
epic: "Policy Engine"
priority: "could-have"
complexity: "M"
tags: [policy, time-based, access-control, scheduling]
---

# US-017: User Creates a Time-Based Access Rule

## User Story

**As a** Security Engineer (P-003) or Enterprise IT Admin (P-006),
**I want to** create time-based access rules that restrict when specific MCP tools can be invoked (e.g., only during business hours, or only during maintenance windows),
**So that** I can enforce temporal access controls aligned with operational policies and reduce the attack surface during off-hours.

## Acceptance Criteria

- [ ] Given the policy editor, when the user creates a time-based access rule, then the system presents options for: schedule type (recurring, one-time), time zone, allowed hours (e.g., 09:00-17:00 UTC), allowed days (e.g., Monday-Friday), and optional start/end dates for the rule.
- [ ] Given a time-based rule allowing `payment.process` only on weekdays between 09:00-17:00 UTC, when a caller invokes `payment.process` on Tuesday at 14:00 UTC, then the request is allowed.
- [ ] Given the same rule, when a caller invokes `payment.process` on Saturday at 10:00 UTC, then the request is denied with HTTP 403 and the denial reason includes "outside allowed time window."
- [ ] Given a one-time maintenance window rule (e.g., allow `admin.restart` on 2026-06-15 from 02:00-04:00 UTC), when the current time falls within the window, then the tool is accessible; outside the window, it is denied.
- [ ] Given multiple time-based rules at different scopes, when they conflict (e.g., org allows weekdays only, caller allows all days), then the most restrictive rule applies (weekdays only).

## Notes

Time-based rules are evaluated as part of the policy engine's scope chain (US-008). The time zone handling must be explicit -- defaults to UTC with an option for the user's local timezone. Recurring rules support cron-like expressions for complex schedules. This is a Phase 1 feature for SafeMCP. Related to US-008, US-014.
