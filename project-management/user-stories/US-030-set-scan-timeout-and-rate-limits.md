---
id: US-030
title: "Set scan timeout and rate limits"
slug: "set-scan-timeout-and-rate-limits"
personas: [P-007, P-001]
epic: "Defender — Scan Configuration"
priority: "should-have"
complexity: "S"
tags: [defender, scan-config, rate-limiting, timeout, compliance]
---

# US-030: Set Scan Timeout and Rate Limits

## User Story

**As a** DevSecOps engineer in a regulated industry (P-007),
**I want to** configure per-request timeout and requests-per-minute rate limits for scans,
**So that** I can prevent scans from overwhelming a production endpoint or violating provider rate limit quotas that could incur overage charges or trigger abuse detection.

## Acceptance Criteria

- [ ] Given I am configuring a scan, when I set a per-request timeout (in seconds), then any probe that does not receive a response within that time is marked as timed out and skipped.
- [ ] Given I set a requests-per-minute limit, when the scanner is running, then it throttles probe dispatch to stay at or below that rate.
- [ ] Given I leave rate limit blank, when the scan runs, then a sensible default (e.g., 10 req/min) is applied and displayed.
- [ ] Given a scan is running and the target returns HTTP 429, when the scanner receives that response, then it automatically backs off and retries with exponential delay up to 3 attempts before marking the probe as failed.
- [ ] Given I save a configuration template, when I review it, then timeout and rate limit values are included and editable.

## Notes

Default values should be conservative enough to be safe against most hosted provider limits. Backoff behavior applies regardless of whether an explicit rate limit is configured.
