---
id: US-044
title: "Retest a specific technique after mitigation"
slug: "retest-specific-technique-after-mitigation"
personas: [P-001, P-003]
epic: "Defender — Results & Reporting"
priority: "should-have"
complexity: "M"
tags: [defender, results, retest, remediation, validation]
---

# US-044: Retest a Specific Technique After Mitigation

## User Story

**As a** ML Engineer building agents (P-003),
**I want to** re-run a single technique from a previous scan against the target endpoint,
**So that** I can quickly validate whether a mitigation I deployed has resolved a specific finding without having to run the full scan suite again.

## Acceptance Criteria

- [ ] Given I am viewing a finding from a completed scan, when I click "Retest", then a targeted scan is launched that probes only that technique against the same endpoint configuration.
- [ ] Given a retest completes, when I view the finding, then the result is updated to "Verified Fixed" or "Still Vulnerable" with a timestamp and link to the retest run.
- [ ] Given a retest shows the issue as fixed, when I view the original scan summary, then that finding is marked with a "Verified Fixed" badge in addition to its original severity.
- [ ] Given I launch a retest, when it completes, then I receive an in-app notification (and optionally email per US-047 settings) with the result.
- [ ] Given I am on the scan history page, when I view a finding that has been retested, then I can see the full retest history for that finding (multiple retests over time).

## Notes

Retest uses the same endpoint credentials and depth setting as the original scan, or prompts for updated credentials if the original credentials have expired. Retest results feed into the scan comparison view (US-043) as linked sub-runs.
