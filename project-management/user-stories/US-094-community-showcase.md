---
id: US-094
title: "Community Showcase Gallery"
slug: "community-showcase"
personas: [P-007, P-001]
epic: "Developer Experience & Community"
priority: "could-have"
complexity: "M"
tags: [community, showcase, discovery, marketing, ecosystem]
---

# US-094: Community Showcase Gallery

## User Story

**As a** community contributor (P-007) and indie game developer (P-001),
**I want to** submit my NoizuRPG-powered project to a public showcase gallery on the website,
**So that** my work is discoverable by other developers, I gain credibility in the community, and the gallery demonstrates real-world use cases to prospective framework users.

## Acceptance Criteria

- [ ] Given the NoizuRPG website, when I navigate to the Showcase page, then I see a filterable gallery of community projects with name, author, genre tags, screenshot/GIF, one-sentence description, and links to repo/live demo
- [ ] Given a developer who wants to submit their project, when they fill out the submission form (project name, description, URL, screenshot, tags), then the submission enters a review queue and they receive a confirmation email within 24 hours
- [ ] Given an approved showcase submission, when it is published to the gallery, then the submitting developer receives an email notification with the live showcase URL
- [ ] Given the showcase gallery, when I filter by tag (e.g., "discord-bot", "web-game", "cli"), then only projects with that tag are displayed and the URL updates to reflect the active filter (linkable filtered views)
- [ ] Given a showcase project entry, when I click on it, then I see an expanded view with full description, all tags, component list (which of the 6 framework components are used), and a "Try in Playground" button if a live demo URL is available

## Notes

The showcase serves dual purposes: social proof for new visitors and inspiration/discovery for existing developers. The "Try in Playground" integration ties into US-083. Showcase submissions are manually reviewed to maintain quality — no automated publishing.
