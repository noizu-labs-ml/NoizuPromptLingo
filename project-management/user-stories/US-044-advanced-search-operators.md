---
id: US-044
title: "Advanced Search Operators"
slug: "advanced-search-operators"
personas: [P-001, P-003, P-005]
epic: "Search & Discovery"
priority: "could-have"
complexity: "M"
tags: [search, advanced, operators, power-users]
---

# US-044: Advanced Search Operators

## User Story

**As a** power-user prompt engineer (P-001),
**I want to** use structured search operators like `author:`, `model:`, and `tag:` in the search bar,
**So that** I can construct precise queries without having to navigate multiple filter dropdowns.

## Acceptance Criteria

- [ ] Given I type `author:username` in the search bar, when results are returned, then only prompts and comments submitted by that username are shown
- [ ] Given I type `model:claude` in the search bar, when results are returned, then only prompts tagged with Claude (or any Claude variant) are shown
- [ ] Given I type `tag:summarization` combined with a keyword query, when results are returned, then the tag filter is applied in conjunction with the keyword match
- [ ] Given I type an unrecognized operator (e.g., `foo:bar`), when the query is parsed, then the unrecognized operator is treated as a literal keyword and a warning hint is shown explaining valid operators

## Notes

Supported operators for v1: `author:`, `model:`, `tag:`, `in:comments`, `score:>N`, `before:`, `after:`. Operator parsing should be fault-tolerant and fall back gracefully. A help tooltip listing available operators should be accessible from the search bar.
