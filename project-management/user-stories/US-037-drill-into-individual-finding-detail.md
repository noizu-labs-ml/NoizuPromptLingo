---
id: US-037
title: "Drill into individual finding detail"
slug: "drill-into-individual-finding-detail"
personas: [P-001, P-006]
epic: "Defender — Results & Reporting"
priority: "must-have"
complexity: "M"
tags: [defender, results, findings, detail, evidence]
---

# US-037: Drill Into Individual Finding Detail

## User Story

**As a** AI Red Team Lead (P-001),
**I want to** open a detailed view for any individual finding in a scan,
**So that** I can inspect the exact probe payload, the model's response, the detection reasoning, and the assigned severity to validate the finding and understand the attack vector.

## Acceptance Criteria

- [ ] Given I am viewing the findings list, when I click a finding, then I navigate to a detail page showing: technique name and ID, probe payload, raw model response, detection classifier reasoning, severity, and timestamp.
- [ ] Given I view a finding detail, when I read the probe payload, then it is displayed in full with syntax highlighting for any structured content (JSON, XML, markdown).
- [ ] Given I view a finding detail, when I read the model response, then it is displayed verbatim with no truncation, and a "Copy response" button is available.
- [ ] Given a finding is a false positive, when I click "Mark as false positive", then the finding is flagged and excluded from severity counts and export reports unless explicitly included.
- [ ] Given I have marked findings across a scan, when I return to the summary page, then adjusted counts (excluding false positives) are shown alongside original counts.

## Notes

Probe payloads and model responses may contain sensitive content — the detail page should be access-controlled to users with at minimum scan-viewer permissions. False positive workflow feeds back into catalog quality improvement (future story).
