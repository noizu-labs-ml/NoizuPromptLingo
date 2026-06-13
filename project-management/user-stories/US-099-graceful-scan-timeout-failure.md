---
id: US-099
title: "Graceful Handling of Scan Timeout and Failure"
slug: "graceful-scan-timeout-failure"
personas: [P-001, P-002, P-006, P-007]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "M"
tags: [defender, error-handling, edge-cases, scan, resilience]
---

# US-099: Graceful Handling of Scan Timeout and Failure

## User Story

**As a** user running a Defender scan against an LLM endpoint (P-001, P-002, P-006, P-007),
**I want to** receive clear, actionable feedback when a scan times out or encounters an error,
**So that** I understand what went wrong, whether partial results are available, and what corrective action to take — without being left in a state of silent uncertainty.

## Acceptance Criteria

- [ ] Given a scan that exceeds its maximum runtime (configurable per profile: 5 min quick, 15 min standard, 60 min comprehensive), when the timeout is reached, then the scan status transitions to `timed_out` and the user is notified via in-app notification and email
- [ ] Given a timed-out scan, when I view the results page, then I see all findings collected before the timeout with a banner: "Scan timed out — partial results shown. X of Y technique probes completed."
- [ ] Given a scan that fails due to the target endpoint being unreachable, when the failure is detected after 3 retry attempts, then the status becomes `failed` with `error.reason: target_unreachable` and instructions to check the endpoint URL and network access
- [ ] Given a scan failure, when I view the scan detail, then I see a "Retry Scan" button that re-queues the scan with the same configuration
- [ ] Given a scan in any terminal state (`completed`, `timed_out`, `failed`, `cancelled`), when I view the results, then the scan summary shows the terminal state prominently rather than the last transient state
- [ ] Given a user running a scan via the API (US-082), when a timeout or failure occurs, then the `GET /v1/scans/{id}` response includes `error.reason`, `probes_completed`, and `probes_total` so clients can make informed decisions

## Notes

Partial results are better than no results — always persist and surface what was collected before failure. Failure reasons must be distinct enough to be actionable: distinguish network errors, authentication errors, target rate-limiting, and internal platform errors. Internal errors should show a reference ID for support escalation.
