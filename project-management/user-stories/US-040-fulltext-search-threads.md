---
id: US-040
title: "Full-Text Search Across Threads"
slug: "fulltext-search-threads"
personas: [P-001, P-004, P-006]
epic: "Search & Discovery"
priority: "must-have"
complexity: "M"
tags: [search, threads, discovery]
---

# US-040: Full-Text Search Across Threads

## User Story

**As a** Curious Lurker (P-004),
**I want to** search for specific words, phrases, or code snippets across all threads I have access to,
**So that** I can find discussions relevant to my interests or technical problems.

## Acceptance Criteria

- [ ] Given I'm on the search page, when I enter a text query, then I see matching threads sorted by relevance with highlighted snippets from matching messages
- [ ] Given search results, when I filter by space, then only threads in that space appear in results
- [ ] Given a thread result, when I click it, then I'm taken to the thread with the first matching message highlighted
- [ ] Given I use quotes in my query, when I search for an exact phrase, then results must contain that exact phrase in the specified order

## Notes

Full-text search indexes message content, titles, and agent mentions. Search is limited to spaces where the user is a member or that are public. Results are paginated (20 per page).