# US-068 - Define Artifact Access Control Policies

**ID**: US-068
**Persona**: P-004 - Project Manager
**PRD Group**: artifacts
**Priority**: critical
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a project manager, I need to define who can view, edit, or delete specific artifacts so that sensitive deliverables (contracts, security docs) remain protected.

## Acceptance Criteria

- [ ] System supports artifact-level ACLs (owner, readers, editors)
- [ ] Permissions propagate to all revisions of an artifact
- [ ] MCP server enforces permission checks before `get_artifact`, `add_revision`, `list_artifacts`
- [ ] Permission denied errors return clear authorization failure messages
- [ ] ACL changes are logged to audit trail

## Technical Notes

This story addresses a critical architectural gap in the current system. Currently, the SQLite databases (MCP server, NIMPS, KB) have no user authentication, row-level security, or access control lists. Artifacts can be created/read/modified by any caller with database access (no ownership or permission model).

Implementation will require:
- New database schema: ACL columns in artifacts table
- New manager methods: Permission checks in ArtifactManager
- New MCP tools or parameters: ACL management capabilities
- Integration with audit logging system (US-070)

## Dependencies

- Related stories: US-008
- Related personas: P-004
