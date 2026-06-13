---
id: US-003
title: "Open-Source Projects Showcase"
slug: "open-source-projects-showcase"
personas: [P-001, P-002, P-005]
epic: "Public Portfolio"
priority: "should-have"
complexity: "M"
tags: [portfolio, open-source, github, credibility]
---

# US-003: Open-Source Projects Showcase

## User Story

**As a** startup CTO evaluating technical depth before engaging (P-001),
**I want to** browse Keith's open-source projects with links to GitHub and brief context about each,
**So that** I can assess code quality, technology choices, and domain expertise firsthand.

## Acceptance Criteria

- [ ] Given a visitor navigates to the projects section (page or homepage section), when the page renders, then at least four projects are listed with name, short description, primary technology tags, and a GitHub link.
- [ ] Given a project card is displayed, when a visitor clicks the GitHub link, then it opens in a new tab.
- [ ] Given the page is rendered, when a visitor views it, then each project displays its primary language or stack via visible tags.
- [ ] Given a DevOps/Platform engineer (P-005) views the page, then infrastructure or tooling projects are surfaced if present.
- [ ] Given a mobile visitor, when the project grid renders, then cards reflow to a single column without content overflow.

## Notes

Live GitHub star/fork counts would be a nice-to-have (requires API call or build-time fetch). Static metadata is acceptable for v1. Related: US-004 (research papers), US-007 (SEO metadata).
