# US-052 - Browser Automation Timeout & Retry Handling

**ID**: US-052
**Persona**: P-001 - AI Agent
**PRD Group**: browser
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an AI agent running browser automation, I need configurable timeouts and automatic retry logic so that transient network failures don't block tasks.

## Acceptance Criteria

- [ ] Browser tools (navigate, screenshot, form-fill) accept timeout parameter (default 30s)
- [ ] Automatic retry on timeout (max 3 retries with exponential backoff)
- [ ] Failed retries logged to MCP tool log with full diagnostic info (URL, screenshots, console errors)
- [ ] User-configurable retry policy in session config
- [ ] Manual override to skip retry and fail fast
- [ ] Integration with existing browser checkpoint system (US-024)

## Technical Notes

This story extends US-021 (Browser Navigation) and US-024 (Manage Browser State) by adding robust timeout and retry handling for browser automation tasks. It prevents transient network failures from blocking agent workflows by implementing configurable retry policies with exponential backoff.

## Dependencies

- Related stories: US-021, US-024
- Related personas: P-001
