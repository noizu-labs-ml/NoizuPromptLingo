---
id: US-077
title: "Cost Impact Reporting"
slug: "cost-impact-reporting"
personas: [P-002, P-003]
epic: "Insights & Reporting"
priority: "must-have"
complexity: "L"
tags: [reporting, cost, roi, incidents-prevented, energy-savings]
---

# US-077: Cost Impact Reporting

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** see cost impact reports that quantify incidents prevented, MTTR reduction, and energy savings attributed to AI agents,
**So that** I can justify the platform investment and demonstrate ROI to stakeholders.

## Acceptance Criteria

- [ ] Given I open the Cost Impact report, when it loads, then I see estimated dollar values for incidents prevented, hours of MTTR reduction, and energy savings calculated from agent actions
- [ ] Given cost impact is displayed, when I click any metric, then a drill-down shows the underlying agent actions and playbook executions contributing to that figure
- [ ] Given I want to customize the model, when I navigate to report settings, then I can input my organization's cost-per-incident and energy cost-per-kWh to replace default estimates
- [ ] Given the report has been generated, when I click Export, then a PDF summary suitable for executive presentation is downloaded
- [ ] Given cost data is an estimate, when the report is displayed, then a methodology footnote explains how figures are calculated with confidence ranges shown

## Notes

Cost figures must be clearly marked as estimates derived from agent telemetry. Relates to US-076 (outcome dashboard) and US-082 (scheduled report delivery). Default cost models should be configurable at the organization level.
