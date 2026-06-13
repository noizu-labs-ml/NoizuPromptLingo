---
id: US-046
title: "Set severity thresholds for pass/fail in CI"
slug: "set-severity-thresholds-for-pass-fail-in-ci"
personas: [P-007, P-002]
epic: "Defender — Results & Reporting"
priority: "could-have"
complexity: "M"
tags: [defender, results, cicd, pass-fail, thresholds, gates]
---

# US-046: Set Severity Thresholds for Pass/Fail in CI

## User Story

**As a** DevSecOps engineer in a regulated industry (P-007),
**I want to** configure severity thresholds that determine whether a scan produces a pass or fail exit code,
**So that** I can use Defender as a quality gate in CI/CD pipelines that blocks deployments when the target endpoint has findings above an acceptable severity level.

## Acceptance Criteria

- [ ] Given I am configuring a scan or scan template, when I open "CI Gate Settings", then I can set a fail threshold (e.g., fail if any Critical, or fail if Critical + High count > 0).
- [ ] Given a threshold is configured, when a scan completes via the API, then the scan result object includes a `passed: true/false` field based on the threshold evaluation.
- [ ] Given I use the Defender CLI or API in a CI pipeline, when the scan fails the threshold, then the process exits with a non-zero exit code that a CI system interprets as a build failure.
- [ ] Given the scan passes the threshold, when I view the result, then a "PASSED" badge is shown alongside the finding counts so passing is not confused with "zero findings".
- [ ] Given a scan has false-positive-marked findings at or above the threshold level, when the CI gate evaluates, then false positives are excluded from the threshold calculation.

## Notes

This story requires the Defender CLI to be available as a dependency (or API-driven) — CLI tooling scope is separate but must be coordinated. Threshold options should include: severity level cutoffs, total count limits, and category-specific rules (e.g., fail on any prompt injection regardless of severity).
