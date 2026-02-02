# User Story: Fabric CLI Integration

**ID**: US-112
**Legacy ID**: US-009-002
**Persona**: P-001 (AI Agent)
**PRD Group**: coordination
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T20:00:00Z
**Related PRD**: PRD-009

## Story

As a **developer**,
I want **integration with Fabric CLI for LLM-based output analysis**,
So that **command outputs can be analyzed and summarized intelligently**.

## Acceptance Criteria

- [ ] Auto-detect fabric installation
- [ ] Apply single or multiple patterns to content
- [ ] Pattern selection heuristics for common tasks
- [ ] Graceful fallback when fabric unavailable
- [ ] Support common patterns: summarize, extract_wisdom, analyze_logs, explain_code

## Notes

- Story points: 5
- Related personas: developer, data-analyst

## Dependencies

- Fabric CLI installed on system
- PRD-009 External Executors infrastructure

## Related Commands

- `apply_fabric_pattern` - Apply fabric pattern to content
- `analyze_with_fabric` - Analyze content with fabric
- `list_fabric_patterns` - List available patterns
