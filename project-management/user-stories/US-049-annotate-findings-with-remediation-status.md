---
id: US-049
title: "Annotate findings with remediation status"
slug: "annotate-findings-with-remediation-status"
personas: [P-002, P-001]
epic: "Defender — Results & Reporting"
priority: "could-have"
complexity: "M"
tags: [defender, results, annotations, remediation, workflow, tracking]
---

# US-049: Annotate Findings with Remediation Status

## User Story

**As a** Enterprise AppSec Manager (P-002),
**I want to** update the remediation status of individual findings and add notes,
**So that** I can track which vulnerabilities are under active remediation, deferred, or accepted as risk, and communicate context to the team directly within the scan results.

## Acceptance Criteria

- [ ] Given I view a finding, when I open the "Remediation" panel, then I can set a status from: Open, In Progress, Fixed (Pending Retest), Accepted Risk, Won't Fix.
- [ ] Given I set a status, when I add an optional free-text note, then the note is saved with my name and timestamp and visible to all team members with scan-viewer access.
- [ ] Given I set a finding to "Accepted Risk" or "Won't Fix", when I view the scan summary, then those findings are visually distinguished from unactioned open findings.
- [ ] Given I filter the findings list, when I select "Open" as the status filter, then only findings with Open status are shown, excluding all annotated ones.
- [ ] Given I export the scan as PDF or JSON, when I include remediation status, then each finding's current status and notes are included in the export.

## Notes

Status annotations are separate from the false-positive flag from US-037 — false positive means "not a real finding"; "Won't Fix" means "real finding, accepted risk." Status history (audit trail of who changed what and when) is a future enhancement for compliance use cases.
