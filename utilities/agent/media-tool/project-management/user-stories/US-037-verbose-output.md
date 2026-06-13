---
id: US-037
title: "Show verbose output for debugging"
slug: verbose-output
personas: [P-001, P-005]
epic: "CLI & UX"
priority: must-have
complexity: low
tags: [cli, verbose, debugging, transparency]
---

# US-037: Show verbose output for debugging

## User Story

**As a** developer troubleshooting a prompt
**I want to** run `--verbose` to see detailed generation information
**So that** I understand what's being sent to the API and what's coming back

## Acceptance Criteria

- **Given** `--verbose` flag
  **When** prompt files are loaded
  **Then** each file's schema version, type, service, and model are shown

- **Given** `--verbose` flag
  **When** an API call is made
  **Then** the prompt text, attachments, and provider options are displayed

## Notes
Verbose mode is for development and debugging. Normal mode should be quiet and minimal.
