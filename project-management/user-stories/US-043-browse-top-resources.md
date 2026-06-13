---
id: US-043
title: "Browse Top Resources by Popularity"
slug: "browse-top-resources"
personas: [P-001, P-002, P-004]
epic: "Search & Discovery"
priority: "should-have"
complexity: "S"
tags: [discovery, resources, analytics]
---

# US-043: Browse Top Resources by Popularity

## User Story

**As a** Curious Lurker (P-004),
**I want to** browse top resources ranked by popularity,
**So that** I can discover high-quality prompts, skills, and MCP configs that the community has validated.

## Acceptance Criteria

- [ ] Given I'm on the resources discovery page, when I view top resources, then I see resources ranked by a weighted score of forks, views, and recent usage
- [ ] Given top resources, when I filter by type (prompt, skill, MCP config), then only resources of that type appear
- [ ] Given a resource in the list, when I hover it, then I see a quick preview with description, owner, and fork count
- [ ] Given I sort top resources, when I select "Most Forked" or "Most Viewed", then the list re-sorts by that metric

## Notes

Popularity score formula: (forks * 5 + views * 1 + recent_usage * 3) / resource_age. "Recent usage" counts usage in the last 30 days. Results refresh every 15 minutes.