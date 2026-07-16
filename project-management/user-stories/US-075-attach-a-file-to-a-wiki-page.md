---
id: US-075
title: "Attach a File to a Wiki Page"
slug: "attach-a-file-to-a-wiki-page"
personas: [P-001]
epic: "Social & Collaboration"
priority: "could-have"
complexity: "S"
tags: [wiki, attachments, files]
---

# US-075: Attach a File to a Wiki Page

## User Story

**As a** Harness Operator (Jordan Vance, P-001),
**I want to** attach a file (e.g. a log excerpt, diagram, or config export) to a wiki Page,
**So that** supporting evidence lives alongside the documentation instead of scattered across chat history.

## Acceptance Criteria

- [ ] Given an existing wiki Page, when a file is uploaded as an attachment, then it appears in the Page's attachment list with filename, size, and uploader shown.
- [ ] Given a Page with an existing attachment, when another member of the project views the Page, then they can download the attachment without needing separate storage credentials.
- [ ] Given a file upload that exceeds the configured size limit, when the attach action is attempted, then it is rejected with a clear size-limit error instead of a silent failure or truncated file.

## Notes

Attachment storage should reuse whatever object-store pattern the platform already uses elsewhere (e.g. code review screenshots, US-077) rather than a bespoke wiki-only mechanism.
