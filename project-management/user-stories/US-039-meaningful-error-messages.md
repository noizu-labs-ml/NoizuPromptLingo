---
id: US-039
title: "Receive meaningful error messages"
slug: meaningful-error-messages
personas: [P-008, P-007]
epic: "CLI & UX"
priority: must-have
complexity: medium
tags: [error-handling, ux, messages, accessibility]
---

# US-039: Receive meaningful error messages

## User Story

**As a** non-technical user
**I want to** see clear, actionable error messages when something goes wrong
**So that** I can fix the problem without consulting documentation

## Acceptance Criteria

- **Given** a YAML parse error in a `.media.prompt` file
  **When** the file is loaded
  **Then** the error shows the file path, line number, and what's wrong in plain language

- **Given** a missing required field
  **When** validation runs
  **Then** the error names the field, explains what's expected, and shows the file path

- **Given** an API auth error (401/403)
  **When** a provider call fails
  **Then** the error names the provider, the missing key, and where to get it

## Notes
Error messages should be structured for both human readability and potential machine parsing.
