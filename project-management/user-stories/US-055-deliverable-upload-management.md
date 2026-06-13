---
id: US-055
title: "Deliverable Upload and Management"
slug: "deliverable-upload-management"
personas: [P-007]
epic: "Admin Dashboard"
priority: "must-have"
complexity: "M"
tags: [admin, deliverable, upload, file, project]
---

# US-055: Deliverable Upload and Management

## User Story

**As a** site administrator,
**I want to** upload deliverable files to a project and associate them with milestones,
**So that** clients can access finalized artifacts through their dashboard in a secure, organized way.

## Acceptance Criteria

- [ ] Given I am on a project detail page, when I click "Upload Deliverable", then I can select a file (PDF, ZIP, DOCX, MD, PNG — max 50MB), add a title and description, and optionally link it to a milestone.
- [ ] Given a file is uploaded, when the upload completes, then the deliverable appears in the project's deliverable list with name, type icon, upload date, and file size.
- [ ] Given a deliverable exists, when a client views their project, then they can download the file via a time-limited signed URL (expires after 1 hour).
- [ ] Given I delete a deliverable, when I confirm, then the file is removed from storage and the record is soft-deleted (visible in audit log).
- [ ] Given a deliverable is linked to a milestone, when the milestone is viewed, then the deliverable appears under it.
- [ ] Given an upload fails (network error, file too large), when the error occurs, then a clear error message is shown and no partial record is created.

## Notes

Storage backend TBD (S3-compatible). Signed URLs prevent direct hotlinking. Related: US-053, US-054. Client-facing download surface is a separate story in the client dashboard epic.
