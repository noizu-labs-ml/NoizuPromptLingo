---
id: US-036
title: "View scan results summary by severity"
slug: "view-scan-results-summary-by-severity"
personas: [P-001, P-002, P-005]
epic: "Defender — Results & Reporting"
priority: "must-have"
complexity: "M"
tags: [defender, results, reporting, severity, dashboard]
---

# US-036: View Scan Results Summary by Severity

## User Story

**As a** Enterprise AppSec Manager (P-002),
**I want to** see a summary view of scan results grouped by severity level (critical, high, medium, low, informational),
**So that** I can immediately understand the overall risk posture of the target endpoint and prioritize which findings to address first.

## Acceptance Criteria

- [ ] Given a scan has completed, when I navigate to the results page, then I see a summary panel with counts of findings at each severity level (critical, high, medium, low, info) and an overall pass/fail verdict.
- [ ] Given the summary is displayed, when I click a severity tier, then the findings list below filters to show only findings of that severity.
- [ ] Given a scan has zero findings, when I view the results, then a clear "No vulnerabilities detected" state is shown — not an empty list — with the scan scope and technique count displayed for auditability.
- [ ] Given a scan had errors (e.g., timed-out probes), when I view the summary, then errored probes are counted separately and do not inflate or deflate the finding counts.
- [ ] Given I want an at-a-glance severity breakdown, when I view the summary, then a donut or bar chart visualizes the distribution of findings by severity.

## Notes

Severity levels align with CVSS-style categories adapted for LLM findings. The overall pass/fail verdict is configurable via threshold settings (US-046). Summary page must load within 2 seconds even for scans with 500+ findings.
