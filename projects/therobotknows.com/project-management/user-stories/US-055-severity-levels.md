---
id: US-055
title: "Consistency Issue Severity Levels"
slug: "severity-levels"
personas: [P-001, P-002, P-003, P-005]
epic: "Consistency Engine"
priority: "must-have"
complexity: "S"
tags: [consistency, severity, triage, ux]
---

# US-055: Consistency Issue Severity Levels

## User Story

**As a** hobbyist worldbuilder (P-005),
**I want to** see consistency issues grouped by severity (error, warning, suggestion),
**So that** I can triage my worldbuilding problems and fix the critical ones first without feeling overwhelmed.

## Acceptance Criteria

- [ ] Given consistency issues exist in a universe, when I view the Consistency Dashboard, then issues are visually distinguished into three severity tiers: "error" (red, blocking contradictions), "warning" (amber, likely problems), and "suggestion" (blue, style/quality hints) — each with an icon, color, and label.
- [ ] Given I filter the dashboard by severity, when I select "errors only," then only error-severity issues are displayed and the count badge updates to reflect the filtered total.
- [ ] Given a new issue is created by any consistency check, when the issue is written, then it carries exactly one severity value from the set {error, warning, suggestion} and that value is immutable by the system (only user override via mark-intentional can suppress it).
- [ ] Given the Consistency Dashboard summary panel, when I load it, then I see three count badges — one per severity — updated in real time as issues are resolved or new ones are detected.

## Notes

Severity definitions: "error" = logically impossible (character dead before event), "warning" = probable mistake (near-duplicate name), "suggestion" = optional improvement (orphaned concept with no connections). Depends on US-057 (consistency dashboard). Related: US-056 (resolution workflow).
