---
id: US-051
title: "Search MCP registry by keyword"
slug: "search-registry-by-keyword"
personas: [P-001, P-004, P-007]
epic: "Registry & Discovery"
priority: "must-have"
complexity: "M"
tags: [registry, search, discovery, meilisearch]
---

# US-051: Search MCP Registry by Keyword

## User Story

**As a** MCP Tool Developer (P-001),
**I want to** search the MCP registry by keyword across tool names, descriptions, and tags,
**So that** I can quickly find existing MCP servers that solve a problem I am working on without browsing the entire catalog.

## Acceptance Criteria

- [ ] Given the user is on any MCP Host page with the global search bar, when they type a keyword and press enter, then the system returns matching MCP servers ranked by relevance within 500ms.
- [ ] Given the user enters a keyword query, when results are returned, then each result displays the server name, short description, category badge, health status indicator, and trust score.
- [ ] Given the search query matches terms in tool names, server descriptions, or publisher-defined tags, when results are displayed, then matched terms are highlighted in the result snippets.
- [ ] Given the search returns more than 20 results, when the user scrolls to the bottom of the results page, then the next page of results loads automatically via infinite scroll.
- [ ] Given the search query produces zero results, when the results page renders, then the system displays a "No results found" message with suggestions for broadening the query and links to browse by category (US-052).
- [ ] Given the user has a search query active, when they click a result, then they are navigated to the detailed tool page (US-054) and the search context is preserved for back-navigation.

## Notes

Search is powered by Meilisearch (per architecture decision). Indexes should cover tool name, description, tags, publisher name, and category. Typo tolerance and prefix search should be enabled by default. Related: US-052 (category browse), US-053 (filtering), US-054 (detail page).
