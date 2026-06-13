---
id: US-041
title: "Attach style reference images"
slug: attach-style-reference
personas: [P-001, P-002]
epic: "Attachments"
priority: must-have
complexity: medium
tags: [attachments, style, reference, base64]
---

# US-041: Attach style reference images

## User Story

**As a** developer generating brand-consistent assets
**I want to** attach reference images to guide generation
**So that** the output matches our established visual style

## Acceptance Criteria

- **Given** an `attachments` section with a `role: style` image
  **When** the API call is made
  **Then** the image is base64-encoded and sent as a reference

- **Given** an attachment path that doesn't exist
  **When** the prompt is validated
  **Then** an error lists the missing file and the prompt is skipped

## Notes
Attachments are validated before any API calls. Paths are relative to the `.media.prompt` file.
