---
id: US-076
title: "View Personalized Homepage Feed"
slug: "personalized-homepage-feed"
personas: [P-001, P-002, P-004]
epic: "Explore & Homepage"
priority: "must-have"
complexity: "M"
tags: [homepage, feed, personalization]
---

# US-076: View Personalized Homepage Feed

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** see a personalized feed on my homepage showing spaces I follow, trending threads, and new resources,
**So that** I can quickly discover relevant content and stay engaged with my communities.

## Acceptance Criteria

- [ ] Given I am logged in, when I visit the homepage, then I see a feed with three sections: "Your Spaces", "Trending Threads", and "New Resources"
- [ ] Given I follow multiple spaces, when I view "Your Spaces", then I see the 5 most recently updated spaces I follow with thread counts and last activity timestamps
- [ ] Given I have no followed spaces, when I view the homepage, then "Your Spaces" section shows a prompt to explore with a link to the spaces directory
- [ ] Given trending threads exist, when I view "Trending Threads", then I see threads sorted by engagement (replies + resource forks) in the last 24 hours
- [ ] Given new resources were uploaded, when I view "New Resources", then I see the 10 most recent resources with their space, author, and type (prompt, skill, MCP config)
- [ ] Given I click on any feed item, when I navigate away and return, then the feed maintains my scroll position

## Notes

Feed should prioritize content from followed spaces. Limit each section to 5-10 items to avoid information overload.