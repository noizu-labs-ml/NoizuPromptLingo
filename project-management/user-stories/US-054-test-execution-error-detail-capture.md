# US-054 - Test Execution Error Detail Capture

**ID**: US-054
**Persona**: P-005 - Dave the Fellow Developer
**PRD Group**: collaboration
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a developer, I need detailed test failure diagnostics captured automatically so that I can debug without re-running tests manually.

## Acceptance Criteria

- [ ] `mise run test-errors` output captured to `.npl/logs/test-failures.jsonl`
- [ ] Each failure includes: test name, file path, line number, assertion error, full stack trace
- [ ] Side-by-side diff for assertion failures (expected vs. actual)
- [ ] Screenshots for browser-based test failures
- [ ] Automatic linking to related PRD and artifact
- [ ] Retention: last 50 test runs per feature

## Technical Notes

This story extends the TDD workflow described in CLAUDE.md by automatically capturing detailed test failure diagnostics. The system should integrate with the existing `mise run test-errors` command and store structured test failure data in JSONL format for easy querying and analysis.

## Dependencies

- Related stories: (extends TDD workflow from CLAUDE.md)
- Related personas: P-005

## Priority Rationale

**High priority** - This story enables critical debugging workflows for the TDD process by providing detailed, automatically captured test failure diagnostics. This reduces the time required to diagnose and fix failing tests.
