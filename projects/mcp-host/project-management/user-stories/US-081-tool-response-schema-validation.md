---
id: US-081
title: "System validates tool response schema against declared output type"
slug: "tool-response-schema-validation"
personas: [P-001, P-004]
epic: "Sandbox & Execution"
priority: "should-have"
complexity: "M"
tags: [schema-validation, tool-response, type-safety, json-schema]
---

# US-081: System Validates Tool Response Schema Against Declared Output Type

## User Story

**As an** MCP Tool Developer (P-001),
**I want to** have the platform validate my tool's response payload against its declared output schema,
**So that** callers receive well-structured, predictable responses and schema mismatches are caught before they propagate to consuming agents.

## Acceptance Criteria

- [ ] Given a tool declares an output schema (JSON Schema format) in its manifest, when the tool returns a response from the sandbox, then the platform validates the response payload against the declared schema before forwarding it to the caller
- [ ] Given a tool response fails schema validation, when the validation error is detected, then the platform returns a structured error to the caller indicating which fields failed validation and the expected types, and logs the mismatch for the tool developer
- [ ] Given a tool does not declare an output schema, when a response is returned, then the platform skips validation and passes the response through unchanged
- [ ] Given a tool developer views the tool's invocation logs in JustMCP.it, when schema validation failures are present, then the failures are highlighted with the specific validation errors and suggested fixes

## Notes

Schema validation adds a safety net for the MCP ecosystem where agents consume tool outputs programmatically. The validation should be optional per tool (off by default if no schema is declared) and should not add significant latency to the response path. JSON Schema draft-2020-12 is the target specification. Related to US-095 (malformed tool definition validation) for the input side.
