---
id: US-058
title: "Generate ER diagram from database schema"
slug: "generate-er-diagram-from-schema"
personas: [P-001, P-005]
epic: "Diagram & Rendering Engine"
priority: "should-have"
complexity: "M"
tags: [er-diagram, database, schema, plantuml, architecture]
---

# US-058: Generate ER Diagram from Database Schema

## User Story

**As a** Enterprise Architect (P-005),
**I want to** submit a SQL DDL or Ecto schema definition and receive an ER diagram,
**So that** I can visually communicate data model design without maintaining separate diagram files.

## Acceptance Criteria

- [ ] Given a SQL DDL input (CREATE TABLE statements), when processed, then an ER diagram is generated showing tables, columns, primary keys, and foreign key relationships
- [ ] Given an Ecto schema module (Elixir), when submitted, then the system parses fields and associations and produces an equivalent ER diagram
- [ ] Given the diagram is returned, when inspected, then cardinality notation (one-to-many, many-to-many) is correctly represented
- [ ] Given a schema with more than 30 tables, when rendered, then a table filter parameter is available to scope the diagram to a subset

## Notes

SQL DDL and Ecto are the two primary schema formats used in this stack. Diagram output uses PlantUML entity syntax. Large schemas require scoping to remain readable — the filter parameter is not optional at scale.
