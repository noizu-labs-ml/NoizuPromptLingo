---
id: US-047
title: "Require approval before production deploys"
personas: [sarah-kim, lin-zhao]
domain: cicd
priority: high
mvp_phase: "v0.4"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want to require human or agent approval before deploying to production so that my team has a safety gate preventing unreviewed changes from reaching users.

## Acceptance Criteria

- [ ] Approval gates are configurable per environment — e.g., staging auto-deploys, production requires 1+ approvals
- [ ] Approvers can be humans (by role or named user) or agents (with defined approval criteria such as "all tests pass and no high-severity items open")
- [ ] Pending approvals surface in the approver's "Today" view and trigger notifications with a deploy summary (changelog, linked items, test results)
- [ ] Approval/rejection is recorded with timestamp, approver identity, and optional comment; the full approval chain is visible on the deploy item
- [ ] Approval timeout is configurable — unapproved deploys expire after N hours and require re-trigger

## Notes

Agent-as-approver is a key differentiator: Lin Zhao's governance requirements mean agent approvals must go through the same audit trail as human ones. The approval workflow should integrate with the deploy changelog (US-044) so approvers see a rich summary, not just a SHA. Consider "conditional auto-approve" rules — e.g., auto-approve if only docs changed.
