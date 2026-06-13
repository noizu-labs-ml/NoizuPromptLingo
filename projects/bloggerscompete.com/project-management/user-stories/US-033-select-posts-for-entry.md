---
id: US-033
title: "Select Posts for Competition Entry"
slug: "select-posts-for-entry"
personas: [P-001, P-002, P-004]
epic: "Competition Entry"
priority: "must-have"
complexity: "M"
tags: [competitions, entry, posts, selection, submission]
---

# US-033: Select Posts for Competition Entry

## User Story

**As a** blogger entering a competition (P-002),
**I want to** select which of my blog posts to include in my competition entry,
**So that** I can showcase my strongest work rather than having the platform use arbitrary posts.

## Acceptance Criteria

- [ ] Given I am in the competition entry flow, when I reach the post selection step, then I see a list of my recently scored blog posts with their AI scores and publication dates
- [ ] Given the competition has a minimum post requirement (e.g., at least 3 posts), when I have fewer qualifying posts, then I see an inline notice explaining I need more posts and a link to the blog submission guide
- [ ] Given the competition specifies a maximum number of posts for entry, when I have selected the maximum, then additional posts are disabled and a tooltip explains the limit
- [ ] Given I select a post, when I hover over it, then I see a summary of its AI dimension scores to help me choose my best-performing content
- [ ] Given I want to select all eligible posts, when I click "Select All," then all posts within the competition's limit are selected
- [ ] Given the competition restricts posts to a date range (e.g., published within the last 90 days), when I view my post list, then ineligible posts are grayed out with an explanation

## Notes

Post selection is where bloggers strategize. The UI should empower informed choices by surfacing AI scores per post. Related to US-032 (enter competition), US-034 (preview submission). Tech blogger P-002 will carefully optimize post selection based on scores.
