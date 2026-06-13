---
id: US-059
title: "Consistency History and Audit Log"
slug: "consistency-audit-log"
personas: [P-001, P-003, P-006]
epic: "Consistency Engine"
priority: "should-have"
complexity: "M"
tags: [consistency, audit, history, log, accountability]
---

# US-059: Consistency History and Audit Log

## User Story

**As a** narrative designer (P-003),
**I want to** view a full history of consistency issues — including when they were detected, how they were resolved, and by whom,
**So that** I can audit my team's worldbuilding decisions and understand the rationale behind past resolutions.

## Acceptance Criteria

- [ ] Given a consistency issue has been resolved (by any method: pick side, merge, or mark intentional), when I view the audit log, then I see an entry showing the issue ID, type, severity, detection timestamp, resolution action, resolving user, and any supplied rationale.
- [ ] Given I filter the audit log by date range, when the filter is applied, then only issues detected or resolved within that range are shown, with a count of matching records.
- [ ] Given an issue was resolved via "Mark Intentional," when I view its audit log entry, then the rationale text is displayed in full alongside the suppression timestamp.
- [ ] Given a platform admin (P-006) audits a universe's consistency log, when they export the log, then they receive a CSV with all fields (issue ID, type, severity, detected at, resolved at, resolved by, action, rationale) covering the full history of the universe.

## Notes

Audit log entries are append-only and must not be editable by non-admin users. Depends on US-056 (resolution workflow), US-057 (consistency dashboard). Related: US-058 (batch check).
