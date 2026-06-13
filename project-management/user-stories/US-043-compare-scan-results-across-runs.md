---
id: US-043
title: "Compare scan results across runs"
slug: "compare-scan-results-across-runs"
personas: [P-001, P-002]
epic: "Defender — Results & Reporting"
priority: "should-have"
complexity: "L"
tags: [defender, results, comparison, diff, regression]
---

# US-043: Compare Scan Results Across Runs

## User Story

**As a** AI Red Team Lead (P-001),
**I want to** compare the results of two scans run against the same endpoint at different points in time,
**So that** I can determine whether security posture improved or regressed after model updates, prompt changes, or mitigation deployments.

## Acceptance Criteria

- [ ] Given I have two or more completed scans against the same endpoint, when I select them for comparison, then I see a diff view showing: new findings (introduced), resolved findings (fixed), and unchanged findings (persisting).
- [ ] Given a comparison is displayed, when I view the diff, then each category (new/resolved/unchanged) is visually distinct with counts and color coding.
- [ ] Given I click a "new" finding in the diff, when I navigate to its detail, then I can see the full finding detail without leaving the comparison context.
- [ ] Given a scan used a different technique selection than the baseline, when I view the comparison, then a warning is shown that scope differences may account for new or missing findings.
- [ ] Given I want to share the comparison, when I click "Share", then a shareable link is generated that renders the comparison for any team member with scan-viewer access.

## Notes

Comparison logic must account for technique version changes between scans — a finding for the same technique but different variant should be noted as changed, not new. This feature is a precondition for meaningful trend tracking in US-048.
