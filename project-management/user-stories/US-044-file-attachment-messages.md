---
id: US-044
title: "File Attachments on Messages"
slug: "file-attachment-messages"
personas: [P-007, P-001, P-002]
epic: "Support & Communication"
priority: "should-have"
complexity: "M"
tags: [messaging, attachments, files, upload]
---

# US-044: File Attachments on Messages

## User Story

**As a** client collaborating in a message thread (P-007),
**I want to** attach files to messages — such as screenshots, specs, or reference documents,
**So that** I can provide context or share materials without needing to send a separate email.

## Acceptance Criteria

- [ ] Given I am composing a message, when I click the attachment button, then I can select one or more files from my device
- [ ] Given I attach a file, when the message is sent, then the file is shown as a thumbnail or named attachment in the thread
- [ ] Given the recipient (Keith or client) clicks an attachment, when they click it, then the file either previews inline (images, PDF) or downloads directly
- [ ] Given I attempt to attach a file larger than 25MB, when I select it, then an error message is shown and the file is not attached
- [ ] Given I attach a file of an unsupported type (e.g. .exe), when I try to attach it, then it is rejected with a clear error message listing supported types

## Notes

Supported types: PDF, PNG, JPG, GIF, DOCX, XLSX, PPTX, CSV, ZIP (no executables). 25MB per file, 5 files per message. Files stored in object storage with access scoped to conversation participants. Attachments also appear in the project's document repository (US-033) tagged as "from message". Consider virus scanning on upload.
