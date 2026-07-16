---
id: US-099
title: "Queue and Rate-Limit Bulk Creative-Asset Generation"
slug: "queue-rate-limit-bulk-creative-asset-generation"
personas: [P-005]
epic: "Performance & Scale"
priority: "could-have"
complexity: "M"
tags: [performance, queueing, rate-limiting, creative-assets]
---

# US-099: Queue and Rate-Limit Bulk Creative-Asset Generation

## User Story

**As** Renee Okafor, the Growth Operator (P-005),
**I want to** submit a batch of creative-asset generation requests and have them queued and throttled automatically,
**So that** a large campaign batch doesn't overwhelm generation capacity or get silently dropped.

## Acceptance Criteria

- [ ] Given Renee submits a bulk generation request such as 50 assets at once, when submitted, then the requests are enqueued and processed at a bounded concurrency/rate rather than fired all at once.
- [ ] Given a bulk batch is queued, when Renee views its status, then she can see counts of queued, in-progress, completed, and failed items without polling each asset individually.
- [ ] Given the generation backend is at capacity, when new bulk requests arrive, then they wait in queue with a visible position or ETA instead of failing outright.
- [ ] Given an individual asset in a batch fails generation, when the rest of the batch completes, then the failure is reported per-item so Renee can retry just that item rather than the whole batch failing.

## Notes

Could-have — valuable for Renee's campaign workflows but not blocking core platform usage. Should reuse the rate-limiting primitive introduced in US-087 where feasible, even though the trigger surface differs.
