---
id: US-082
title: "Create Space Categories and Tags"
slug: "create-space-categories-tags"
personas: [P-003, P-007]
epic: "Spaces - Advanced"
priority: "could-have"
complexity: "M"
tags: [spaces, organization, taxonomy]
---

# US-082: Create Space Categories and Tags

## User Story

**As an** Engineering Team Lead (P-003),
**I want to** categorize and tag spaces with topics and themes,
**So that** community members can discover relevant spaces through filtering and search.

## Acceptance Criteria

- [ ] Given I am a space owner, when I edit space settings, then I can add multiple topic tags from a predefined list or create custom tags
- [ ] Given I add "AI/ML", "Prompt Engineering", and "LangChain" tags to my space, when I save, then the tags appear on the space's card and header
- [ ] Given I'm browsing spaces, when I filter by tag, then I see all spaces tagged with that topic
- [ ] Given I attempt to create a tag that already exists, when I type the tag name, then the system suggests the existing tag
- [ ] Given I remove a tag from a space, when I save changes, then the tag no longer appears on the space and the space disappears from that tag's filter results

## Notes

Predefined tags: AI/ML, Generative AI, Prompt Engineering, LangChain, MCP, LLMOps, Data Science, NLP. Allow custom tags with admin approval workflow (future).