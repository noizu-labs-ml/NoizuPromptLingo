# User Story: MCP Tool Exposure for Taskers

**ID**: US-113
**Legacy ID**: US-009-003
**Persona**: P-001 (AI Agent)
**PRD Group**: mcp_tools
**Priority**: Critical
**Status**: Draft
**Created**: 2026-02-02T20:00:00Z
**Related PRD**: PRD-009

## Story

As an **MCP integrator**,
I want **tasker management and Fabric integration exposed as MCP tools**,
So that **Claude can spawn and manage ephemeral agents**.

## Acceptance Criteria

- [ ] Expose `spawn_tasker` as MCP tool
- [ ] Expose `get_tasker` and `list_taskers` as MCP tools
- [ ] Expose `dismiss_tasker` and `keep_alive_tasker` as MCP tools
- [ ] Expose `apply_fabric_pattern` and `analyze_with_fabric` as MCP tools
- [ ] Expose `list_fabric_patterns` as MCP tool
- [ ] All tools registered in unified.py

## Notes

- Story points: 3
- Related personas: mcp-integrator, developer

## Dependencies

- US-111 Ephemeral Tasker Lifecycle
- US-112 Fabric CLI Integration
- PRD-009 External Executors

## Related Commands

- All MCP tools for tasker and fabric management
