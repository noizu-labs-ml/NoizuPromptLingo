---
id: US-064
title: "Export Analytics Report (Pro)"
slug: "export-analytics-report"
personas: [P-003, P-002]
epic: "Analytics Dashboard"
priority: "could-have"
complexity: "M"
tags: [analytics, export, pro, pdf, report]
---

# US-064: Export Analytics Report (Pro)

## User Story

**As a** content marketing manager (P-003),
**I want to** export my analytics as a shareable PDF report,
**So that** I can present blog performance data to stakeholders and clients without giving them platform access.

## Acceptance Criteria

- [ ] Given I am a Pro user on /dashboard/analytics, when I click "Export Report," then a PDF is generated and downloaded within 10 seconds
- [ ] Given the PDF is generated, when I open it, then it includes: blog name, selected date range, overall score summary, radar chart image, score trend chart image, dimension scores table, and AI suggestions panel
- [ ] Given I am a Free tier user, when I click "Export Report," then a modal explains this is a Pro feature with an upgrade CTA; no download is initiated
- [ ] Given the export is triggered, when the PDF renders, then it uses the currently selected period (US-061) for all data ranges in the report
- [ ] Given the PDF is downloaded, when I open it on any device, then all charts render as embedded images (not interactive) and text is selectable

## Notes

PDF generation runs server-side using headless browser rendering of a print-optimized report page. Client receives a signed download URL. Report branding includes BloggersCompete.com logo and generation timestamp. See US-061 for period selector, US-063 for benchmarking data that may be included.
