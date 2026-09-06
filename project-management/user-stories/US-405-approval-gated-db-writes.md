---
id: US-405
title: "Gate database writes behind explicit approval"
slug: "approval-gated-db-writes"
personas: [P-003, P-006]
epic: "Database Access Services"
priority: "should-have"
complexity: "L"
tags: [db, writes, approval, safety, audit]
---

# US-405: Gate database writes behind explicit approval

## User Story

**As a** Delivery Lead (P-003) accountable for production data, working with the Platform Administrator (P-006),
**I want to** have any mutating DB tool call require an explicit approval step before it executes,
**So that** an agent's plausible-but-wrong UPDATE or DELETE can never hit production data on its own judgment.

## Acceptance Criteria

- [ ] Given a write operation submitted through the DB tool, when it lacks approval, then it is rejected with a clear "approval required" response that previews the exact statement and affected scope.
- [ ] Given an operator approves a specific write, when the same statement re-executes, then it runs once and the execution is recorded with the approver identity and timestamp.
- [ ] Given an approval that has expired (TTL) or a statement that differs from the approved one, when execution is attempted, then it is rejected.
- [ ] Given an approved write that fails mid-execution, when it errors, then the transaction rolls back and the failure is recorded against the approval record.
- [ ] Given the write path is disabled entirely for a deployment, when a write is submitted, then it is rejected unconditionally regardless of approval state (config kill-switch).

## Notes

Sequencing: the read-only cluster (US-401/402/403/404) ships first; this story adds the mutating surface as a strictly gated follow-on. Approval mechanics should reuse the platform's existing approval-pattern primitives (cf. approval-status flows in the ticket/PRD domain) rather than inventing a parallel mechanism. Every approved execution lands in the US-407 audit log.
