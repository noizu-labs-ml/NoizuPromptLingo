---
id: US-402
title: "Introspect the Liquibase-managed schema from an MCP tool"
slug: "schema-introspection-mcp-tool"
personas: [P-002]
epic: "Database Access Services"
priority: "must-have"
complexity: "S"
tags: [db, schema, introspection, liquibase]
---

# US-402: Introspect the Liquibase-managed schema from an MCP tool

## User Story

**As an** Autonomous Coding Agent (P-002) composing queries for a Harness Operator (P-001),
**I want to** list tables, columns, and types of the Liquibase-managed schema through a read-only MCP tool,
**So that** I write correct queries against the real schema instead of guessing table or column names from prose.

## Acceptance Criteria

- [ ] Given an authorized caller, when it requests the table listing, then it receives all Liquibase-managed tables with their columns, types, and nullability.
- [ ] Given infrastructure/internal tables that should not be agent-visible, when the listing is produced, then they are excluded per a configurable allow/deny list.
- [ ] Given the introspection tool, when invoked repeatedly, then it never mutates schema or data (read-only catalogs only) and results are deterministically ordered.
- [ ] Given a newly landed Liquibase changelog, when introspection runs afterward, then the new table/column appears without a tool-code change.

## Notes

DDL is owned by Liquibase in this platform (agents must not treat Ecto migrations as the schema source of truth), so introspection reads the live catalog rather than parsing changelogs. Pairs with US-401 (the query tool consumes introspection output) and US-403/US-404 (tenant scoping and credential least-privilege apply here too).
