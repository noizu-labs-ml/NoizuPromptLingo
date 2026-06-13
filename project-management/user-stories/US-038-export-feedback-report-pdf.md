---
id: US-038
title: "Export Feedback Report as PDF"
slug: "export-feedback-report-pdf"
personas: [P-002, P-005, P-004]
epic: "Stakeholder Feedback"
priority: "should-have"
complexity: "M"
tags: [export, pdf, reporting, feedback]
---

# US-038: Export Feedback Report as PDF

## User Story

**As a** enterprise architect (P-005),
**I want to** export all feedback for a mockup as a formatted PDF report,
**So that** I can share design review outcomes with stakeholders who do not use the platform.

## Acceptance Criteria

- [ ] Given a mockup with annotations, when I click "Export PDF", then a PDF is generated and downloaded containing the mockup image and all annotation threads
- [ ] Given active filters (US-037), when I export, then only the filtered annotations are included in the report
- [ ] Given the exported PDF, when I open it, then each annotation includes author, timestamp, status, and position reference
- [ ] Given the export, when it completes, then the PDF includes a cover page with mockup title, version, date, and approval status

## Notes

PDF generation should be server-side (Phoenix backend) to ensure consistent rendering. Include mockup thumbnail alongside annotations in the layout. Large mockups with many annotations may require async generation with a download link delivered via email.
