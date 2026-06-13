---
id: US-042
title: "Generation Queue Management"
slug: "generation-queue-management"
personas: [P-003, P-007]
epic: "Generation Engine"
priority: "should-have"
complexity: "L"
tags: [generation, queue, async, status, management]
---

# US-042: Generation Queue Management

## User Story

**As a** narrative designer running long generation sessions (P-003),
**I want to** view and manage a queue of pending, active, and completed generation jobs,
**So that** I can monitor progress, cancel unnecessary jobs, and review results without waiting for each job to finish synchronously.

## Acceptance Criteria

- [ ] Given I have submitted one or more generation requests, when I open the Generation Queue panel, then I see all jobs with statuses: pending, processing, completed, or failed.
- [ ] Given a job is in pending or processing state, when I click "Cancel", then the job is cancelled and any consumed tokens are noted but not billed if generation did not complete.
- [ ] Given a job completes while I am on a different page, when I return to the Generation Studio, then a badge or notification indicates newly completed results are available.
- [ ] Given I view the queue, when I click on a completed job, then the generated draft is opened for review.
- [ ] Given the queue has more than 20 jobs, when I view it, then older completed jobs are paginated or collapsed with a "Show History" option that links to generation history (US-045).

## Notes

Depends on US-036. Essential for async and bulk generation flows (US-041). Queue state should persist server-side so that browser refreshes or tab closures do not lose in-progress jobs. Related: US-041, US-045.
