---
id: US-043
title: "Auto-detect MIME types for attachments"
slug: auto-detect-mime-type
personas: [P-001]
epic: "Attachments"
priority: must-have
complexity: low
tags: [attachments, mime-type, auto-detect]
---

# US-043: Auto-detect MIME types for attachments

## User Story

**As a** developer attaching files
**I want to** MIME types to be auto-detected from file extensions
**So that** I don't have to manually specify `mime_type` for common formats

## Acceptance Criteria

- **Given** an attachment with `path: ./brand.png` and no `mime_type`
  **When** the file is processed
  **Then** MIME type is resolved as `image/png`

- **Given** an uncommon extension
  **When** MIME detection fails
  **Then** it falls back to `application/octet-stream`

## Notes
Built-in map covers 17+ common extensions. Falls back to `mime_guess` crate, then `application/octet-stream`.
