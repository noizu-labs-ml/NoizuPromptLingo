---
id: US-034
title: "Configure custom attack payloads"
slug: "configure-custom-attack-payloads"
personas: [P-001, P-006]
epic: "Defender — Scan Configuration"
priority: "could-have"
complexity: "L"
tags: [defender, scan-config, custom-payloads, advanced, research]
---

# US-034: Configure Custom Attack Payloads

## User Story

**As a** Independent security consultant (P-006),
**I want to** upload or write custom attack payloads to include in a scan alongside the standard catalog techniques,
**So that** I can test client-specific threat scenarios or novel techniques I've discovered that aren't yet in the public catalog.

## Acceptance Criteria

- [ ] Given I am configuring a scan, when I navigate to "Custom Payloads", then I can write payloads inline in a text editor or upload a JSON/JSONL file following the documented payload schema.
- [ ] Given I upload a payload file, when the file is parsed, then invalid entries are flagged with line numbers and schema errors before the scan is allowed to proceed.
- [ ] Given I have valid custom payloads, when the scan runs, then custom payloads are executed alongside catalog techniques and appear in results labeled as "custom".
- [ ] Given a custom payload produces a finding, when I view the finding detail, then I see my payload text, the model response, and the detection reasoning.
- [ ] Given I want to reuse custom payloads, when I save the scan as a template (US-032), then custom payload references are included in the template export.

## Notes

Custom payload format must be documented and versioned. Detection logic for custom payloads uses the same response classifier as catalog techniques but without technique-specific tuning. Responsible use policy applies — platform may scan payloads for prohibited content categories at upload time.
