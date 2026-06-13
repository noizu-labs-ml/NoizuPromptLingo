---
id: US-040
title: "Export scan report as PDF"
slug: "export-scan-report-as-pdf"
personas: [P-002, P-005]
epic: "Defender — Results & Reporting"
priority: "should-have"
complexity: "M"
tags: [defender, results, reporting, export, pdf]
---

# US-040: Export Scan Report as PDF

## User Story

**As a** CISO at a mid-market SaaS company (P-005),
**I want to** export a scan's results as a formatted PDF report,
**So that** I can share findings with non-technical stakeholders, include them in compliance documentation, and retain audit evidence outside the platform.

## Acceptance Criteria

- [ ] Given a scan has completed, when I click "Export PDF", then a styled PDF is generated containing: executive summary, severity breakdown chart, findings table, and per-finding detail sections.
- [ ] Given the PDF is generated, when I receive it, then it includes the scan metadata (scan ID, target endpoint domain, date/time, scan depth, technique categories) on a cover page.
- [ ] Given false positives were marked (US-037), when I export the PDF, then false positives are excluded by default with a note on exclusion count; an option to include them is available.
- [ ] Given I want a branded report, when I configure my organization profile, then the PDF includes my organization's name and logo in the header.
- [ ] Given the PDF export is in progress, when I wait, then generation completes within 30 seconds for scans with up to 200 findings, and I receive an email link for larger scans.

## Notes

PDF should be designed for A4 and US Letter paper formats. Probe payloads in findings may be long — PDFs must handle page breaks gracefully. Branding is an enterprise tier feature; free/pro tier receives a JailbreakingSite.com-branded report.
