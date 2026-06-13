# US-047 - View Database Schema Documentation

**ID**: US-047
**Persona**: P-003 - Vibe Coder
**PRD Group**: npl_load
**Priority**: medium
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a vibe coder, I want to view database schema with table relationships, So that I can write correct SQL queries for custom reports.

## Acceptance Criteria

- [ ] Generate ERD diagram from schema (mermaid format)
- [ ] List all tables with column definitions
- [ ] Show foreign key relationships
- [ ] Display indexes and their purposes
- [ ] Include example queries for common operations
- [ ] Export schema as markdown documentation

## Technical Notes

Schema exists in schema.sql but no auto-generated documentation exists. This extends database exploration capabilities to provide developer reference documentation.

## Dependencies

- Related stories: US-025
- Related personas: P-003

## Context

This story extends US-025 (Explore Project Structure) to database exploration. While the schema is defined in schema.sql files, there is no auto-generated documentation that helps developers understand the database structure, relationships, and usage patterns. This capability would provide essential developer reference documentation for working with the database layer.
