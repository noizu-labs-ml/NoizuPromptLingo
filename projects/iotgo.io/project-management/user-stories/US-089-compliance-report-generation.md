---
id: US-089
title: "Compliance Report Generation"
slug: "compliance-report-generation"
personas: [P-005, P-003]
epic: "Security & Compliance"
priority: "could-have"
complexity: "M"
tags: [compliance, reporting, audit, security]
---

# US-089: Compliance Report Generation

## User Story

**As an** IT Security Director (P-005),
**I want to** generate structured compliance reports covering access events, agent autonomy changes, and data retention status,
**So that** I can satisfy auditor requests for SOC 2, ISO 27001, or internal security reviews without manually extracting audit data.

## Acceptance Criteria

- [ ] Given I navigate to Compliance Reports, when I select a report template (Access Review, Agent Action Audit, Data Retention Status), then a report is generated covering the selected period
- [ ] Given a report is generated, when it downloads, then it includes a cover page with organization name, report type, date range, and the name of the user who generated it
- [ ] Given the Access Review template is selected, when the report generates, then it includes all user login events, role changes, and failed authentication attempts for the period
- [ ] Given data retention limits are configured, when the Data Retention Status report runs, then it shows current retention age, oldest retained event, and confirms compliance with the configured retention window

## Notes

Compliance report templates should be reviewed by a compliance consultant before GA release. Relates to US-084 (audit log) and US-081 (exportable reports). Future versions may include pre-built SOC 2 Type II evidence packages.
