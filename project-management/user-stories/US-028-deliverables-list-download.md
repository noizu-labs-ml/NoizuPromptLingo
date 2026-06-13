---
id: US-028
title: "Deliverables List with Download"
slug: "deliverables-list-download"
personas: [P-007, P-002, P-003]
epic: "Customer Dashboard"
priority: "must-have"
complexity: "M"
tags: [dashboard, deliverables, download, files]
---

# US-028: Deliverables List with Download

## User Story

**As an** active client expecting formal deliverables (P-007),
**I want to** see a list of all project deliverables and download any that are marked complete,
**So that** I can retrieve final artifacts (reports, audits, code exports, documentation) without asking Keith to re-send them.

## Acceptance Criteria

- [ ] Given I am on the project detail page, when I navigate to the Deliverables tab, then I see a list of all deliverables with name, type, status (pending/complete), and due date
- [ ] Given a deliverable is marked complete, when I click the download button, then the file downloads directly to my device
- [ ] Given a deliverable is still pending, when I view the list, then the download button is disabled and the expected delivery date is shown
- [ ] Given a deliverable is a large file (>50MB), when I initiate download, then I see a progress indicator
- [ ] Given I download a file, when the download completes, then the deliverable record shows "last downloaded" date and by whom

## Notes

Files stored in object storage (S3-compatible). Signed URLs with short expiry for security. Deliverables are created/uploaded by Keith via admin. Consider a "request revision" action on completed deliverables (future). Related to US-033 (document repository) which handles working documents vs. final deliverables.
