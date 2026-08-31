---
id: US-021
title: "Full-text keyword search"
slug: full-text-keyword-search
personas: [P-001, P-007]
epic: "Search & Discovery"
priority: must-have
complexity: medium
tags: [search, fts5]
---

# US-021: Full-Text Keyword Search

## User Story

**As a** solo power-user developer
**I want to** type keywords into a search bar and get ranked results from across all my indexed Claude Code conversations
**So that** I can quickly find the exact discussion or command I remember without manually paging through project folders

## Acceptance Criteria

- **Given** the FTS5 index has been built by the background indexer
  **When** I type "docker-push --release" into the search bar and submit
  **Then** results are returned ranked by relevance, each showing the matching snippet with the query terms highlighted

- **Given** a search term appears in multiple conversations across different projects
  **When** the results render
  **Then** each result row shows the project name, thread title/date, and the highlighted snippet so I can distinguish matches without opening each thread

- **Given** I search for a term with no matches in the index
  **When** the search completes
  **Then** the UI shows an explicit "no results" state rather than an empty blank panel

- **Given** the corpus contains thousands of messages
  **When** I submit a keyword search
  **Then** results return within a couple seconds, since FTS5 handles the ranking rather than a full linear scan

## Notes
Marcus lives in the CLI (`recent`, `search`, `show`) as much as the web UI — this story covers the core keyword-search behavior that both surfaces depend on; the CLI `search` command and web search bar should return equivalent ranked results from the same FTS5 index. Jamie relies on the plain search bar as their primary (often only) entry point, so the highlighted snippet and clear no-results state matter for a novice who won't dig further.
