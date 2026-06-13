---
id: US-063
title: "Admin Audit Log"
slug: "audit-log"
personas: [P-007]
epic: "Admin Dashboard"
priority: "should-have"
complexity: "S"
tags: [admin, audit, log, security, compliance]
---

# US-063: Admin Audit Log

## User Story

**As a** site administrator,
**I want to** review a chronological log of all admin actions taken in the system,
**So that** I can trace changes, diagnose problems, and maintain accountability for all data modifications.

## Acceptance Criteria

- [ ] Given any admin action occurs (create/edit/delete on clients, projects, milestones, deliverables, content, permissions), when the action completes, then an audit entry is written with: actor, action type, target entity, old value (if applicable), new value, and timestamp.
- [ ] Given I navigate to `/admin/audit`, when the page loads, then I see the last 200 audit entries in reverse-chronological order.
- [ ] Given the audit log, when I filter by actor, action type, or entity type, then the log updates to show matching entries.
- [ ] Given I search the audit log by keyword, when results are returned, then matching entries are highlighted.
- [ ] Given an audit entry, when I click it, then a detail drawer shows the full before/after diff for that change.
- [ ] Given audit entries older than 365 days, when the archival job runs, then they are moved to cold storage but remain queryable via an "Archives" view.

## Notes

Audit log is append-only — no admin should be able to delete or alter audit entries. This is the source of truth for "what happened and when." Related: US-051, US-052, US-053, US-059, US-061.
