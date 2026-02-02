# US-075 - Implement Review Access Control for Sensitive Artifacts

**ID**: US-075
**Persona**: P-002 - Product Manager
**PRD Group**: artifacts
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a product manager, I need to restrict who can view reviews and inline comments on sensitive artifacts so that proprietary feedback doesn't leak to unauthorized personas.

## Acceptance Criteria

- [ ] Reviews inherit ACL from parent artifact
- [ ] Only personas in artifact ACL can view review sessions
- [ ] Only authorized personas can add inline comments
- [ ] Review completion requires reviewer to be in ACL
- [ ] `get_review` MCP tool enforces permission checks
- [ ] Permission denied errors clearly indicate authorization failure

## Technical Notes

This story extends the review system with access control by inheriting permissions from parent artifacts. Key implementation points:

1. **ACL inheritance**: Reviews automatically inherit their parent artifact's ACL at creation time
2. **Permission checks**: Add authorization layer to all review operations (view, comment, complete)
3. **MCP tool updates**: `get_review`, `add_review_comment`, `complete_review` must check permissions
4. **Error messages**: Clear 403 Forbidden responses with specific authorization context
5. **Cascade behavior**: Consider what happens when artifact ACL changes after reviews exist

Related to existing stories US-010 (artifact creation with reviews) and US-023 (review workflows).

## Dependencies

- Related stories: US-010, US-023
- Related personas: P-002 (Product Manager)
