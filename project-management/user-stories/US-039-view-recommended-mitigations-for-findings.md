---
id: US-039
title: "View recommended mitigations for findings"
slug: "view-recommended-mitigations-for-findings"
personas: [P-003, P-002]
epic: "Defender — Results & Reporting"
priority: "must-have"
complexity: "S"
tags: [defender, results, mitigations, remediation, guidance]
---

# US-039: View Recommended Mitigations for Findings

## User Story

**As a** ML Engineer building agents (P-003),
**I want to** see actionable mitigation guidance alongside each finding,
**So that** I can understand what code or configuration changes to make to address the vulnerability without needing to separately research defensive techniques.

## Acceptance Criteria

- [ ] Given I view a finding detail page, when I scroll to the "Mitigations" section, then I see at least one recommended mitigation with a description, implementation guidance, and effectiveness rating.
- [ ] Given a technique has multiple mitigations, when I view the finding, then mitigations are ranked by effectiveness and ease of implementation.
- [ ] Given a mitigation involves a code pattern, when I view it, then a code snippet is provided in the relevant language/framework if applicable.
- [ ] Given a mitigation links to external resources (e.g., OWASP guidance, model provider documentation), when I click the link, then I am taken to the referenced resource in a new tab.
- [ ] Given mitigations are sourced from the catalog, when the catalog entry is updated with improved guidance, then the finding page reflects the updated mitigations on next view.

## Notes

Mitigation content is authored in the catalog and surfaced here — this story is display/UX only, not authoring. Mitigation effectiveness ratings are editorial assessments from the catalog maintainers, not automated measurements.
