---
id: US-043
title: "Search Within Comments"
slug: "search-within-comments"
personas: [P-001, P-003, P-005]
epic: "Search & Discovery"
priority: "could-have"
complexity: "M"
tags: [search, comments, discovery, full-text]
---

# US-043: Search Within Comments

## User Story

**As an** ML researcher mining community knowledge (P-003),
**I want to** search the full text of comments across all prompts,
**So that** I can surface nuanced technical discussions and insights that are buried in comment threads.

## Acceptance Criteria

- [ ] Given I enter a search query and select the "Comments" scope toggle, when results are returned, then matching comments are shown with the prompt title they belong to, author, date, and a highlighted excerpt
- [ ] Given a comment search result is clicked, when the destination page loads, then I am taken to the prompt page with the specific comment scrolled into view and highlighted
- [ ] Given a comment search query returns more than 50 results, when the results page renders, then results are paginated with 25 per page and a total count is shown
- [ ] Given I search within comments on a specific prompt's detail page, when the search is submitted, then results are scoped to only the comments on that prompt

## Notes

Comment search should share the same search index as prompt search, with a content-type discriminator. Scoped in-prompt comment search can be implemented client-side with fuzzy matching for prompts with fewer than 500 comments. Full cross-site comment search requires index coverage of all non-deleted comment bodies.
