---
id: US-049
title: "Message Search"
slug: "message-search"
personas: [P-007, P-002]
epic: "Support & Communication"
priority: "could-have"
complexity: "M"
tags: [messaging, search, support, communication]
---

# US-049: Message Search

## User Story

**As a** client with months of message history across multiple projects (P-007, P-002),
**I want to** search across all messages and ticket threads by keyword,
**So that** I can quickly locate specific decisions, commitments, or technical details discussed in past conversations.

## Acceptance Criteria

- [ ] Given I type a search query in the global search bar, when I submit, then results include matching messages and ticket thread entries across all my projects
- [ ] Given search results are returned, when I view them, then each result shows: message snippet with keywords highlighted, sender name, date, and the project/ticket it belongs to
- [ ] Given I click a search result, when I navigate to it, then I land on the specific message in context with surrounding messages visible
- [ ] Given I want to narrow results, when I apply filters (by project, by date range, by sender), then results update to match the filters
- [ ] Given my search returns no results, when the empty state renders, then I see a message confirming no matches and a suggestion to broaden the query

## Notes

Full-text search. At MVP scale (one client, small message volume), client-side filtering may be sufficient. At scale, requires server-side search (PostgreSQL full-text or Elasticsearch). Search index should cover: message body, ticket subject and description, attachment filenames. Exclude archived/deleted content from default results with an option to include it. This is a quality-of-life feature — defer until message volume makes it necessary.
