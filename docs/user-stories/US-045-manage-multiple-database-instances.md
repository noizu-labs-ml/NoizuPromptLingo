# US-045 - Manage Multiple Database Instances

**ID**: US-045
**Persona**: P-004 - Project Manager
**PRD Group**: coordination
**Priority**: low
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a project manager, I want to switch between different database environments, So that I can test changes in isolation before applying to production.

## Acceptance Criteria

- [ ] Create named database profiles (dev, test, prod)
- [ ] Switch active database via environment variable or CLI flag
- [ ] Clone database to new profile
- [ ] List all database profiles with metadata
- [ ] Archive or delete old profiles
- [ ] Prevent accidental operations on production database

## Technical Notes

Current code uses NPL_MCP_DATA_DIR but no profile abstraction exists. This extends environment management capabilities to support multiple isolated database instances.

## Dependencies

- Related stories: US-005
- Related personas: P-004

## Context

This story extends US-005 (View Session Dashboard) to environment management. The current implementation uses the NPL_MCP_DATA_DIR environment variable but provides no higher-level abstraction for managing multiple database profiles. This capability would enable safer testing and development workflows by providing isolation between different environments.
