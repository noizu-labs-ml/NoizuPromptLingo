# US-073 - Enable Multi-User SQLite Access with Row-Level Security

**ID**: US-073
**Persona**: P-005 - Dave the Fellow Developer
**PRD Group**: npl_load
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a senior developer, I want row-level security on SQLite databases so that when multiple users or agents access the same database, they only see artifacts and rooms they're authorized to access.

## Acceptance Criteria

- [ ] Artifacts table includes `owner` and `acl` columns
- [ ] Chat rooms table includes `owner` and `acl` columns
- [ ] Reviews table includes `acl` column
- [ ] Database layer applies WHERE clauses filtering by current persona/user ID
- [ ] ACL columns store JSON arrays of authorized persona/user IDs
- [ ] Manager classes enforce RLS before returning query results

## Technical Notes

This story addresses a critical security gap in the current SQLite-based architecture. The implementation requires:

1. **Schema updates**: Adding owner and ACL columns to core tables
2. **Query filter injection**: Database layer must automatically append WHERE clauses
3. **Context propagation**: Current persona/user identity must be available to all database queries
4. **Manager refactoring**: ArtifactManager, ChatManager, ReviewManager need RLS enforcement

Related to infrastructure/database security concerns.

## Dependencies

- Related stories: None (foundational security story)
- Related personas: P-005 (Dave the Fellow Developer)
