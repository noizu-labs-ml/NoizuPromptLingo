---
id: US-074
title: "RFI Document Attachment"
slug: "rfi-document-attachment"
personas: [P-001, P-002, P-004, P-006]
epic: "RFI Dashboard"
priority: "should-have"
complexity: "S"
tags: [rfi, prospect, attachment, document, upload]
---

# US-074: RFI Document Attachment

## User Story

**As an** Enterprise Procurement Manager submitting a formal RFI (P-006),
**I want to** attach supporting documents (existing architecture diagrams, RFP documents, technical specs) to my RFI submission,
**So that** Keith has full context to assess my requirements without requiring a follow-up meeting just to share files.

## Acceptance Criteria

- [ ] Given I am on the RFI form, when I reach the "Additional Context" step, then I see an optional file upload field accepting PDF, DOCX, PNG, JPG, and ZIP (max 20MB per file, max 3 files).
- [ ] Given I attach a file, when the upload completes, then the file is listed below the upload field with its name, size, and a remove button.
- [ ] Given I submit the RFI with attachments, when the submission succeeds, then all attached files are linked to the RFI record in the admin queue.
- [ ] Given the admin is reviewing an RFI with attachments, when they click a file, then it opens or downloads directly from the admin detail panel.
- [ ] Given an upload fails (file too large, unsupported type), when the error occurs, then a clear error message is shown and the form is not submitted.
- [ ] Given an RFI is archived (US-075), when archival occurs, then associated documents are also moved to archive storage.

## Notes

File attachments are optional and must not block submission if the upload UI fails. Virus scanning on upload is a security best practice — integrate with ClamAV or cloud equivalent. Related: US-066, US-068, US-075.
