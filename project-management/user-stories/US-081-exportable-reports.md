---
id: US-081
title: "Exportable Reports"
slug: "exportable-reports"
personas: [P-002, P-003]
epic: "Insights & Reporting"
priority: "must-have"
complexity: "S"
tags: [export, reports, pdf, csv]
---

# US-081: Exportable Reports

## User Story

**As a** Smart Building Facility Manager (P-003),
**I want to** export any report view as a PDF or CSV file,
**So that** I can share findings in stakeholder meetings and archive records for compliance purposes.

## Acceptance Criteria

- [ ] Given I am viewing any report page, when I click the Export button, then a dropdown offers PDF and CSV format options
- [ ] Given I select PDF export, when the file downloads, then it includes the current report title, date range, organization name, and all visible charts and tables rendered at print resolution
- [ ] Given I select CSV export, when the file downloads, then it contains the raw tabular data underlying the current report view with column headers
- [ ] Given the report contains multiple sections, when I export to PDF, then a table of contents with page references is included at the front of the document

## Notes

PDF export uses server-side rendering to ensure consistent formatting across browsers. Relates to US-077 (cost impact) and US-082 (scheduled delivery).
