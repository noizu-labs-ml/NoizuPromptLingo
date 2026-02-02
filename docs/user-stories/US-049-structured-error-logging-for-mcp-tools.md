# US-049 - Structured Error Logging for MCP Tools

**ID**: US-049
**Persona**: P-005 - Dave the Fellow Developer
**PRD Group**: npl_load
**Priority**: critical
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a developer, I need structured error logs from MCP tool invocations so that I can debug integration failures and tool misuse.

## Acceptance Criteria

- [ ] All MCP tool calls logged to `.npl/logs/mcp-tools.jsonl` with: tool name, input parameters, output/error, duration, timestamp
- [ ] Errors include full stack traces and context (session ID, agent ID, task ID)
- [ ] Log retention policy (configurable, default 30 days)
- [ ] Query interface to filter by tool, error type, date range
- [ ] Integration with existing session system (US-005) for session-scoped log views
- [ ] Support for log level filtering (DEBUG/INFO/WARN/ERROR)

## Technical Notes

This story fills a critical architectural gap identified in `docs-summary.md` line 86: "How are cross-cutting concerns (logging, monitoring) implemented?" It provides comprehensive logging infrastructure for MCP tool invocations, enabling debugging of integration failures and tool misuse patterns.

## Dependencies

- Related stories: US-005
- Related personas: P-005
