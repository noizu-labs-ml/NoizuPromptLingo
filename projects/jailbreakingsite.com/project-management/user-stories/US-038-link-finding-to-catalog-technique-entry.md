---
id: US-038
title: "Link finding to catalog technique entry"
slug: "link-finding-to-catalog-technique-entry"
personas: [P-001, P-004]
epic: "Defender — Results & Reporting"
priority: "must-have"
complexity: "M"
tags: [defender, results, catalog, cross-reference, traceability]
---

# US-038: Link Finding to Catalog Technique Entry

## User Story

**As a** AI Red Team Lead (P-001),
**I want to** navigate directly from a Defender finding to the corresponding catalog technique entry,
**So that** I can read the full technique description, known variants, and community-contributed context without having to separately search the catalog.

## Acceptance Criteria

- [ ] Given I am viewing a finding detail page, when I see the technique name, then it is a clickable link that opens the full catalog entry for that technique in a new tab.
- [ ] Given I follow a finding link to the catalog, when I view the catalog entry, then I can see the technique ID, MITRE-style classification, description, known variants, and affected model families.
- [ ] Given I view a finding for a custom payload (US-034), when I look for the catalog link, then no catalog link is shown and the finding is labeled "Custom Technique".
- [ ] Given the catalog entry is updated after the scan was run, when I revisit the finding, then the link still resolves to the current catalog state with a note of the technique version at scan time.
- [ ] Given I export a scan report (US-040, US-041), when I view the exported document, then technique IDs are included and, for PDF, rendered as printed URLs to the catalog.

## Notes

Technique versioning in catalog entries is important for audit traceability — the finding should record the technique version at scan time. This story creates the core linkage between Defender and Catalog products.
