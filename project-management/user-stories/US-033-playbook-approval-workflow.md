---
id: US-033
title: "Playbook Approval Workflow"
slug: "playbook-approval-workflow"
personas: [P-004, P-005, P-007, P-002]
epic: "Playbook System"
priority: "must-have"
complexity: "L"
tags: [playbook, approval, governance, workflow, compliance]
---

# US-033: Playbook Approval Workflow

## User Story

**As a** DevOps/SRE Lead (P-004),
**I want to** require one or more approvals before a playbook can be activated for live execution,
**So that** no automation logic reaches production devices without proper review and sign-off.

## Acceptance Criteria

- [ ] Given I configure a playbook's approval policy, when I set required reviewers (by user or role), then the playbook enters "Pending Approval" state and cannot be activated until all approvals are received
- [ ] Given a playbook is awaiting approval, when a reviewer opens it, then they see the full playbook logic, simulation results (US-031), and version diff against the previously approved version
- [ ] Given a reviewer approves or rejects, when their action is recorded, then the playbook author receives a notification with the reviewer's decision and optional comments
- [ ] Given all required approvals are collected, when the last approver approves, then the playbook automatically transitions to "Active" state and is eligible for execution
- [ ] Given a playbook is rejected, when the author makes changes and resubmits, then a new approval cycle begins with a fresh diff visible to reviewers

## Notes

Approval policy configuration should be available at the workspace and per-playbook level. For P-005, approval records must appear in audit logs with reviewer identity and timestamp. Linked to US-029 (versioning) for diff display.
