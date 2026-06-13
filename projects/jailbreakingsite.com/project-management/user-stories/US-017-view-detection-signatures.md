---
id: US-017
title: "View Detection Signatures for a Technique"
slug: "view-detection-signatures"
personas: [P-002, P-005, P-007]
epic: "Attack Catalog"
priority: "should-have"
complexity: "M"
tags: [catalog, technique, detection, signatures, defensive]
---

# US-017: View Detection Signatures for a Technique

## User Story

**As an** AppSec manager or DevSecOps engineer building defenses (P-002, P-005, P-007),
**I want to** view detection signatures associated with a technique,
**So that** I can implement monitoring or guardrails in my LLM pipeline to alert on or block this attack pattern.

## Acceptance Criteria

- [ ] Given I am on a technique detail page, when I navigate to the Detection Signatures section, then I see a list of signatures with: signature type (regex, semantic, classifier hint), pattern, applicable layer (input, output, system prompt), and confidence level
- [ ] Given a signature is a regex or string pattern, when I click the copy button, then the raw pattern is copied to clipboard without formatting artifacts
- [ ] Given I want to integrate signatures programmatically, when I view the section, then a link to the API endpoint for this technique's signatures is visible (relates to API product)
- [ ] Given a signature has caveats or known false-positive conditions, when displaying it, then a warning note is shown inline with the signature

## Notes

Detection signatures are the defensive counterpart to reproduction steps. Some signatures may be community-contributed and marked as unverified until reviewed. Part of the technique detail page (US-015). Relates to Defender product scanning suites.
