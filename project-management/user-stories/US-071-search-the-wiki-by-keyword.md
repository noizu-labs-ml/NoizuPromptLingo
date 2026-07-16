---
id: US-071
title: "Search the Wiki by Keyword"
slug: "search-the-wiki-by-keyword"
personas: [P-001]
epic: "Search & Discovery"
priority: "should-have"
complexity: "S"
tags: [wiki, search, keyword, documentation]
---

# US-071: Search the Wiki by Keyword

## User Story

**As a** Harness Operator (Jordan Vance, P-001),
**I want to** search the project wiki by keyword,
**So that** I can quickly find existing documentation instead of re-asking a question that's already answered somewhere in a Space.

## Acceptance Criteria

- [ ] Given one or more wiki Spaces containing Pages with text content, when a keyword search is run, then matching Pages are returned ranked by relevance, showing the Space and Page title for each result.
- [ ] Given a keyword that appears only in a Page's title and not its body, when that keyword is searched, then the Page is still returned as a match.
- [ ] Given a keyword search run within the current project, when executed, then results from other projects' wiki Spaces are excluded.

## Notes

Keyword-only per current product scope (no semantic mode specified for wiki search, unlike ToolSearch in US-067); revisit if semantic wiki search is scoped in a later epic.
