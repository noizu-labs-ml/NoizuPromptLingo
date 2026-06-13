---
id: US-039
title: "Semantic Search Across All Public Resources"
slug: "semantic-search-resources"
personas: [P-001, P-002, P-005]
epic: "Search & Discovery"
priority: "must-have"
complexity: "L"
tags: [search, semantic-embeddings, discovery]
---

# US-039: Semantic Search Across All Public Resources

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** perform semantic search across all public resources,
**So that** I can find relevant prompts, skills, and MCP configs even if they use different terminology than I searched for.

## Acceptance Criteria

- [ ] Given I'm on the resources page, when I enter a natural language query, then I receive results ranked by semantic similarity to my query
- [ ] Given search results, when I view them, then each result shows a relevance score and highlights the most similar content sections
- [ ] Given I perform a semantic search, when I refine with a specific resource type (prompt vs skill vs MCP config), then results are re-ranked within that type
- [ ] Given a search with no exact matches, when semantic search finds related resources, then I see a "Did you mean?" section with conceptually similar resources

## Notes

Semantic search uses embeddings; requires embedding pipeline that updates on resource changes. Relevance scores are normalized 0-100. Search query length limited to 500 characters.