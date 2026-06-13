---
id: US-083
title: "Cloud Playground Free Tier"
slug: "cloud-playground"
personas: [P-004, P-002, P-008]
epic: "Cloud & Commercial Services"
priority: "should-have"
complexity: "L"
tags: [cloud, playground, onboarding, no-code, free-tier]
---

# US-083: Cloud Playground Free Tier

## User Story

**As a** tabletop GM (P-004), interactive fiction author (P-002), and CS educator (P-008),
**I want to** experiment with NoizuRPG's core components through a browser-based UI without installing Python or providing an API key,
**So that** I can evaluate the framework's capabilities and prototype ideas before committing to a technical setup.

## Acceptance Criteria

- [ ] Given an unauthenticated visitor to the Cloud Playground, when they load the page, then they can immediately interact with a demo scenario using pre-configured components without signing up
- [ ] Given a signed-in free-tier user, when they create a session, then they receive 50 free LLM calls per day against a managed model with no API key required
- [ ] Given a free-tier session, when the user exhausts their daily quota, then a clear in-UI message explains the limit, shows reset time, and presents upgrade options without crashing the session
- [ ] Given a playground session with a configured Character, World, and Narrative Engine, when the user clicks "Run Dialogue Turn", then the result renders within 10 seconds and shows the LLM output alongside the structured state diff
- [ ] Given a playground session, when the user clicks "Export to Code" (US-089), then a Python code snippet is generated that reproduces the session configuration locally
- [ ] Given a mobile browser, when a user loads the Cloud Playground, then the UI is usable on a 375px-wide viewport with all core controls accessible without horizontal scrolling

## Notes

The playground is the primary acquisition funnel for P-004 and P-002 who are non-developers. Pairs with US-089 (export to code) and US-090 (share via URL). The $9/mo upgrade unlocks higher daily quotas and session persistence.
