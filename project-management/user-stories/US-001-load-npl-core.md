# User Story: Load NPL Core Components

**ID**: US-001
**Persona**: P-001 (AI Agent)
**PRD Group**: npl_load
**Priority**: Critical
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **load NPL core components (syntax, conventions, agent protocols)**,
So that **I have the foundational context needed to work effectively on any project**.

## Acceptance Criteria

- [ ] `npl_load` tool successfully loads core NPL syntax definitions and returns structured content
- [ ] `npl_load` tool successfully loads agent communication protocols (e.g., agent-orchestration.md)
- [ ] `npl_load` tool successfully loads standard conventions and style guides
- [ ] Loaded content is returned in markdown or JSON format suitable for LLM context injection
- [ ] `npl_load` accepts optional parameters to selectively load specific component types
- [ ] `npl_load` gracefully handles missing optional components without errors

## Notes

- Core components should be cached to avoid repeated loading
- This is typically the first action an agent takes when starting a session
- Should support loading from both local files and remote repositories

## Dependencies

- NPL component files must exist in expected locations
- File system access for local resources

## Open Questions

- What is the default set of core components to load?
- Should there be a "minimal" vs "full" loading option?

## Related Commands

- `npl_load` - Load NPL components (syntax, protocols, conventions)
