---
id: US-048
title: "Anomaly Investigation View"
slug: "anomaly-investigation-view"
personas: [P-006, P-004, P-002, P-008]
epic: "Anomaly Detection"
priority: "must-have"
complexity: "L"
tags: [anomaly-detection, investigation, dashboard, telemetry, root-cause]
---

# US-048: Anomaly Investigation View

## User Story

**As a** DevOps/SRE Lead (P-004),
**I want to** open a dedicated investigation view for any anomaly that shows the triggering telemetry, surrounding context, device state, and any playbooks that fired in response,
**So that** I can quickly understand what happened, why, and what was done about it without correlating data from multiple screens.

## Acceptance Criteria

- [ ] Given I click on any anomaly event, when the investigation view opens, then I see: anomaly score timeline, the specific metric(s) that deviated, a ±30-minute telemetry context window, and the device's baseline at that time
- [ ] Given the anomaly triggered one or more playbooks, when I view the investigation page, then each triggered playbook execution appears in a timeline panel with its outcome (success/failure/pending)
- [ ] Given the anomaly is part of a correlation cluster (US-045), when I view it, then I see the cluster panel listing all affected devices with links to their individual investigation views
- [ ] Given I am investigating an anomaly, when I add an investigation note, then the note is attached to the anomaly event with my identity and timestamp, visible to all team members
- [ ] Given a correlated anomaly cluster has a suggested root cause (US-045), when I view it, then the suggestion appears with supporting metadata evidence and I can confirm, dismiss, or override it

## Notes

This is the central triage surface for all personas. The ±30-minute context window should be configurable. Investigation notes contribute to institutional knowledge and can be used to seed runbooks. Deep-link URLs should be shareable for async collaboration.
