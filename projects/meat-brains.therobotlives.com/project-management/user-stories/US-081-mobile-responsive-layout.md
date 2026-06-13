---
id: US-081
title: "Mobile Responsive Layout"
slug: "mobile-responsive-layout"
personas: [P-002, P-006, P-008]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "L"
tags: [mobile, responsive, layout, ux, accessibility]
---

# US-081: Mobile Responsive Layout

## User Story

**As an** AI Hobbyist (P-002) or Content Creator (P-006),
**I want to** use the full core functionality of Meat Brains on a mobile device,
**So that** I can browse, vote, and discuss prompts from my phone without a degraded experience.

## Acceptance Criteria

- [ ] Given a viewport width of 375px or less, when any core page (feed, prompt detail, profile, search results) is loaded, then all content is readable and interactive without horizontal scrolling
- [ ] Given the prompt submission form on mobile, when a user fills it out, then all form fields, the tag selector, and the submit button are usable with touch input and no elements are obscured by the mobile keyboard
- [ ] Given the navigation menu on mobile, when the user interacts with it, then a hamburger menu or bottom navigation bar provides access to all primary sections with touch targets at least 44x44px
- [ ] Given long code blocks in prompts on mobile, when rendered, then they are horizontally scrollable within their container without breaking the surrounding page layout

## Notes

Mobile responsiveness should be implemented mobile-first. The bottom navigation bar pattern is preferred over hamburger menus for primary navigation given the community's likely usage patterns (browsing while on the go). This story covers layout breakpoints; interaction-specific mobile UX may warrant separate stories.
