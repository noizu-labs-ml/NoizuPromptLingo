---
id: US-018
title: "View Mitigations for a Technique"
slug: "view-mitigations"
personas: [P-002, P-003, P-005, P-007]
epic: "Attack Catalog"
priority: "should-have"
complexity: "M"
tags: [catalog, technique, mitigations, defensive, remediation]
---

# US-018: View Mitigations for a Technique

## User Story

**As an** engineer or security leader responsible for hardening an LLM deployment (P-002, P-003, P-005, P-007),
**I want to** view actionable mitigations for a technique,
**So that** I can implement practical defenses and reduce the risk of successful exploitation.

## Acceptance Criteria

- [ ] Given I am on a technique detail page, when I navigate to the Mitigations section, then I see a prioritized list of mitigations with: mitigation name, description, implementation complexity (Low/Med/High), and effectiveness rating
- [ ] Given a mitigation applies to a specific model configuration, when it is displayed, then the applicable model families or deployment context are clearly labeled
- [ ] Given a mitigation has a code example or configuration snippet, when I view it, then the snippet is syntax-highlighted and copyable
- [ ] Given the mitigations list is empty or incomplete, when viewing the section, then a callout prompts community contribution with a link to the submission form

## Notes

Effectiveness ratings should distinguish between "prevents" vs. "reduces likelihood" for each mitigation. Mitigation data is editorial-reviewed. Part of the technique detail page (US-015). Implementation complexity guidance is especially valuable for P-003 (ML engineers) integrating at the application layer.
