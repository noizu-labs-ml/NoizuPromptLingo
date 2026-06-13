---
id: US-087
title: "Efficient base64 encoding for large attachments"
slug: efficient-base64-encoding
personas: [P-003, P-001]
epic: "Performance & Scale"
priority: should-have
complexity: low
tags: [performance, base64, memory, attachments]
---

# US-087: Efficient base64 encoding for large attachments

## User Story

**As a** developer attaching large reference images
**I want to** memory-efficient attachment encoding
**So that** batch generation doesn't exhaust memory

## Acceptance Criteria

- **Given** multiple prompts with large attachments
  **When** batch generation runs
  **Then** attachments are encoded one at a time and freed after the API call

- **Given** an attachment exceeds 20MB
  **When** the file is processed
  **Then** a warning suggests optimizing the file size

## Notes
Stream attachment encoding rather than loading all into memory. Rust handles this well with ownership.
