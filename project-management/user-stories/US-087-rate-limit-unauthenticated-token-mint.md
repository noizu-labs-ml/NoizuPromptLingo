---
id: US-087
title: "Rate-Limit the Unauthenticated Token-Mint Endpoint"
slug: "rate-limit-unauthenticated-token-mint"
personas: [P-006]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "S"
tags: [rate-limiting, security, auth, abuse-prevention]
---

# US-087: Rate-Limit the Unauthenticated Token-Mint Endpoint

## User Story

**As** Ilya Petrov, the Platform Administrator (P-006),
**I want to** enforce a request-rate ceiling per source on the unauthenticated token-mint endpoint,
**So that** it cannot be used as a free brute-force or resource-exhaustion vector before any credential check happens.

## Acceptance Criteria

- [ ] Given a single source (IP/fingerprint) exceeds the configured threshold within the rolling window, when it sends another token-mint request, then the server responds 429 with a `Retry-After` header instead of processing the request.
- [ ] Given a source has been rate-limited, when the rolling window elapses, then subsequent requests from that source are processed normally again without manual intervention.
- [ ] Given a burst of requests arrives from many distinct sources that each stay under the per-source threshold, when processed, then none are incorrectly rate-limited.
- [ ] Given a rate-limit rejection occurs, when it is logged, then it is tagged distinctly from credential-failure logs so it does not inflate auth-failure metrics.

## Notes

Protects the one endpoint that by design has no auth gate yet. Complements US-084's revocation audit trail with abuse prevention at the mint boundary; shares its rate-limiting primitive conceptually with US-099.
