---
id: US-010
title: "Site Navigation & Information Architecture"
slug: "site-navigation-structure"
personas: [P-001, P-002, P-003]
epic: "Public Portfolio"
priority: "must-have"
complexity: "S"
tags: [navigation, ia, header, footer, ux]
---

# US-010: Site Navigation & Information Architecture

## User Story

**As a** first-time visitor to noizu.com (any primary persona),
**I want to** understand the site's sections at a glance and navigate between them without confusion,
**So that** I can find what I need — services, projects, papers, or contact — within two clicks.

## Acceptance Criteria

- [ ] Given any page on the site, when the header renders, then the primary nav links (Home, Services, Projects, Research, About, Contact) are visible and functional.
- [ ] Given a visitor is on a page, when they look at the active nav item, then the current page is visually indicated (active state) in the navigation.
- [ ] Given the footer renders, when a visitor scrolls to the bottom of any page, then quick links, copyright, and social/contact links are present.
- [ ] Given a visitor is on a deep page, when they click the site logo, then they are returned to the homepage.
- [ ] Given mobile viewport, when the nav is toggled open, when a user taps a nav link, then the menu closes and the user navigates to the selected page.

## Notes

Navigation labels should be plain language — avoid "Portfolio" when "Projects" is clearer. Footer should include LinkedIn and GitHub links at minimum. This story is foundational; most other public-site stories depend on it. Related: US-006 (mobile), US-008 (accessibility/landmarks).
