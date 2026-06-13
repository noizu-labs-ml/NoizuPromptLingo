---
id: US-058
title: "Batch Consistency Check"
slug: "batch-consistency-check"
personas: [P-001, P-003, P-004]
epic: "Consistency Engine"
priority: "should-have"
complexity: "M"
tags: [consistency, batch, scan, on-demand]
---

# US-058: Batch Consistency Check

## User Story

**As an** epic novelist (P-001),
**I want to** trigger a full consistency scan across my entire universe on demand,
**So that** I can run a complete health check before a publishing milestone without waiting for incremental saves to surface every issue.

## Acceptance Criteria

- [ ] Given I am on the Consistency Dashboard or universe settings, when I click "Run Full Consistency Check," then the system queues a batch job that evaluates all active check types (timeline, geographic, duplicate names, orphaned references) across all entries.
- [ ] Given a batch check is running, when I remain on the dashboard, then I see a progress indicator showing percentage complete and estimated time remaining, and I can navigate away without cancelling the job.
- [ ] Given the batch check completes, when I return to or remain on the dashboard, then I receive a notification, the issue list refreshes with all new findings, and a "Last full check: [timestamp]" label updates.
- [ ] Given a universe has more than 1,000 entries, when a batch check runs, then it completes within 5 minutes and does not degrade the responsiveness of the Canon Editor for other users in the same universe.

## Notes

Batch checks should be idempotent — re-running should not duplicate existing unresolved issues. Depends on US-057 (consistency dashboard). Batch jobs should be queued server-side, not browser-blocking.
