# US-042 - Audit Schema Version Compatibility

**ID**: US-042
**Persona**: P-004 - Project Manager
**PRD Group**: coordination
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a project manager, I want to verify schema compatibility across deployments, so that I can prevent breaking changes when agents run different versions.

## Acceptance Criteria

- [ ] Check current schema version against expected version
- [ ] Warn when schema is ahead/behind expected version
- [ ] Block operations if schema version is incompatible
- [ ] Report which migrations created version mismatch
- [ ] Suggest upgrade/downgrade path

## Technical Notes

Migration system tracks version but no compatibility checking exists. This story adds version validation to prevent agents with mismatched schema versions from corrupting each other's data.

## Dependencies

- Related stories: US-031
- Related personas: P-004

## Context

In distributed or multi-deployment scenarios, different instances may run different code versions. Schema version compatibility checking prevents data corruption from version mismatches and provides clear upgrade paths.
