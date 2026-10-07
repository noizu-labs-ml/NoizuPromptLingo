---
id: US-406
title: "Search knowledge and memory via pgvector similarity from MCP"
slug: "pgvector-similarity-search-mcp"
personas: [P-002]
epic: "Database Access Services"
priority: "should-have"
complexity: "M"
tags: [db, pgvector, embeddings, search, memory]
---

# US-406: Search knowledge and memory via pgvector similarity from MCP

## User Story

**As an** Autonomous Coding Agent (P-002),
**I want to** run similarity searches over embedding-backed knowledge and memory content through a dedicated MCP tool backed by pgvector,
**So that** I retrieve semantically relevant context with bounded, indexed latency instead of dumping raw tables through the generic query tool.

## Acceptance Criteria

- [ ] Given an embedding-backed corpus (knowledge base entries, memory records), when the tool is queried with a text or vector input, then it returns the nearest matches with similarity scores and their source entity references.
- [ ] Given the caller's tenant/session scope, when the search executes, then results are confined to content the caller may see (per US-403 scoping).
- [ ] Given a query input that is not a valid embedding (wrong dimensions, malformed), when submitted, then it is rejected with a structured error.
- [ ] Given an empty or unindexed corpus, when searched, then an empty result set is returned — not an error.
- [ ] Given a large corpus, when searched, then latency remains bounded (index-backed ANN path, top-k limited) and the tool documents its latency budget.

## Notes

The shared Elixir platform Postgres already ships with pgvector (and PostGIS). This story is the purpose-built tool over that column type — it exists precisely so agents don't abuse the raw US-401 SELECT tool to hand-roll `ORDER BY embedding <=> $1` queries that bypass row limits and scope conventions. Keep the vector math server-side; the tool takes text (embedding done in-service) or a pre-computed vector.
