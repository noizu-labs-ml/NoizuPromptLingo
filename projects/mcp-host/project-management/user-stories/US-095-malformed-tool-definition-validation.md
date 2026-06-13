---
id: US-095
title: "System handles malformed tool definition upload with clear validation errors"
slug: "malformed-tool-definition-validation"
personas: [P-001, P-007]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "M"
tags: [error-states, validation, tool-definition, upload, manifest]
---

# US-095: System Handles Malformed Tool Definition Upload with Clear Validation Errors

## User Story

**As an** MCP Tool Developer (P-001),
**I want to** receive specific, actionable validation errors when I upload a tool definition with schema problems,
**So that** I can quickly fix the issues in my manifest rather than debugging generic "upload failed" errors.

## Acceptance Criteria

- [ ] Given a user uploads a tool definition file that contains malformed JSON, when the platform validates the file, then the error response identifies the specific parse error with the line number and character position (e.g., "Unexpected token at line 14, column 22")
- [ ] Given a user uploads a valid JSON tool definition that violates the MCP manifest schema (missing required fields, invalid field types, unknown fields), when the platform validates it, then the error response lists each violation with the field path (e.g., "tools[2].inputSchema: required field missing"), the expected format, and a link to the relevant documentation section
- [ ] Given a user uploads a tool definition with multiple validation errors, when the platform validates it, then all errors are reported in a single response rather than failing on the first error and requiring repeated upload-fix cycles
- [ ] Given a user is using the MCP Jumpstart template editor, when they edit the tool definition in the Monaco Editor, then real-time validation highlights errors inline with the same specific error messages as the upload flow

## Notes

Validation errors are the first interaction many developers have with the platform's DX -- poor error messages here directly cause frustration and churn. The MCP manifest schema should be versioned and the validator should support multiple schema versions. Related to US-081 (output schema validation) and the MCP Jumpstart template system.
