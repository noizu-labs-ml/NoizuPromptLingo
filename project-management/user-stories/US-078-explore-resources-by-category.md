---
id: US-078
title: "Explore Top Resources by Category"
slug: "explore-resources-by-category"
personas: [P-001, P-005]
epic: "Explore & Homepage"
priority: "must-have"
complexity: "M"
tags: [discovery, resources, categories]
---

# US-078: Explore Top Resources by Category

## User Story

**As an** MCP Server Developer (P-005),
**I want to** browse top resources filtered by category and sorted by forks or favorites,
**So that** I can discover high-quality MCP configs to learn from or use as templates.

## Acceptance Criteria

- [ ] Given I visit the "Explore Resources" page, when the page loads, then I see resource categories with top resources for each
- [ ] Given I select a category (e.g., "MCP Configs", "Prompts", "Skills"), when I filter, then I see resources filtered to that type sorted by fork count
- [ ] Given I view a resource card, when I examine its details, then I see: resource name, type, author, fork count, original creation date, last updated date
- [ ] Given I click on a resource, when I navigate to its detail page, then I see the full content and can fork it
- [ ] Given a category has no resources, when I select it, then I see an empty state inviting users to contribute to that category

## Notes

Categories: Prompts, Skills, MCP Configs. Sort order: primary by forks, secondary by recency.