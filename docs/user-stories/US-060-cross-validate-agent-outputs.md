# US-060 - Cross-Validate Agent Outputs

**ID**: US-060
**Persona**: P-005 - Dave the Fellow Developer
**PRD Group**: collaboration
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a senior developer, I want to cross-validate outputs from one agent using another specialized agent so that I can catch errors without creating circular dependencies.

## Acceptance Criteria

- [ ] Specify "validator" agent for a given task output
- [ ] Validator agent has read-only access to original agent's output
- [ ] Validation results include pass/fail and detailed critique
- [ ] Original agent can optionally revise based on validation feedback
- [ ] Validation chain depth is configurable (prevent infinite loops)
- [ ] Validation reports are versioned alongside artifacts

## Technical Notes

Current system has `npl-grader` for quality assessment but no explicit agent-to-agent validation protocol.

## Dependencies

- Related stories: US-034
- Related personas: P-005

## Background

Question: How can agents validate outputs from other agents without creating circular dependencies?

This story addresses agent-to-agent validation, extending the code review capabilities (US-034) to allow one specialized agent to validate another agent's output. The validation must be read-only to prevent circular dependencies, with configurable chain depth to avoid infinite validation loops.

## Key Gap

While npl-grader exists for quality assessment, there's no structured protocol for one agent to validate another agent's output with feedback loops.
