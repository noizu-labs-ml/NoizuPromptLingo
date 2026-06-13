---
id: US-062
title: "Full-text search across wiki, docs, runbooks, and ADRs"
personas: [diana-kovacs]
domain: docs
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **Diana Kovacs (Freelance Multi-Client)**, I want full-text search across all wiki pages, docs, runbooks, and ADRs so that I can quickly find relevant documentation across my client projects without remembering where things live.

## Acceptance Criteria

- [ ] Search indexes all document types: wiki pages, runbooks, ADRs, and uploaded docs
- [ ] Results are ranked by relevance with snippet previews showing matched context
- [ ] Search supports filtering by document type, project/workspace, author, and date range
- [ ] Cross-client search respects workspace access boundaries (no leaking between clients)
- [ ] Search results are available within 2 seconds for corpora up to 10,000 documents

## Notes

Diana works across multiple clients via MCP-connected workspaces, so search must be scope-aware. Consider semantic search as a v0.4 enhancement (embedding-based similarity) but v0.3 should deliver solid full-text search with trigram or inverted index. Results should deep-link to the exact document section.
