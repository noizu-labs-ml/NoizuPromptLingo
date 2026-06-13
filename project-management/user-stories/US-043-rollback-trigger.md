---
id: US-043
title: "Trigger rollback from Plans on deploy regression"
personas: [lin-zhao]
domain: cicd
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want to trigger a rollback from within Plans when a deployment causes regressions so that I can respond to production issues without context-switching to external tooling.

## Acceptance Criteria

- [ ] A "Rollback" action is available on any deploy item that has a previous successful version to roll back to
- [ ] Rollback requires confirmation showing: current version, target version, affected services, and estimated impact (linked items that would revert)
- [ ] Rollback execution is audited with initiator, reason (free-text or selected from templates), timestamp, and outcome
- [ ] The rollback action respects the deploy approval workflow (US-047) if configured — production rollbacks can require approval
- [ ] Post-rollback, affected items auto-transition back to their pre-deploy status with a rollback annotation

## Notes

Rollback is executed via the same CI/CD provider adapter that reports pipeline status. The agent governance layer must log this as a high-impact action with full audit trail. Consider a "rollback dry-run" mode that shows what would change without executing. The platform should track rollback frequency as an operational health metric.
