# User Story: MCP Artifact Management Tools

**ID**: US-114
**Legacy ID**: US-008-030
**Persona**: P-001 (AI Agent)
**PRD Group**: mcp_tools
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T20:00:00Z
**Related PRD**: PRD-010

## Story

As a **developer**,
I want **to create and version artifacts with inline code reviews via MCP tools**,
So that **I can manage code changes and get feedback within the MCP workflow**.

## Acceptance Criteria

- [ ] Can create new artifacts with type classification
- [ ] Can version existing artifacts with change summaries
- [ ] Can initiate code reviews on specific versions
- [ ] Can add line-specific inline comments during reviews
- [ ] Can complete reviews with approval/rejection decisions
- [ ] Can annotate screenshot artifacts with visual markers

## Notes

- Story points: 13
- Related personas: developer, code-reviewer
- Consolidates stories US-008 through US-030 scope

## Dependencies

- PRD-002 Artifact Management
- PRD-010 MCP Tools Implementation

## Related Commands

- `create_artifact` - Create new artifact
- `version_artifact` - Version existing artifact
- `create_review` - Initiate code review
- `add_inline_comment` - Add inline comment
- `complete_review` - Complete review
- `annotate_screenshot` - Annotate screenshot
