---
id: US-006
title: "Responsive Mobile Experience"
slug: "responsive-mobile-experience"
personas: [P-001, P-002, P-003]
epic: "Public Portfolio"
priority: "must-have"
complexity: "M"
tags: [responsive, mobile, accessibility, layout]
---

# US-006: Responsive Mobile Experience

## User Story

**As a** startup CTO browsing on my phone between meetings (P-001),
**I want to** navigate the entire site without pinching, zooming, or horizontal scrolling,
**So that** I can evaluate Keith's services and reach out without friction on any device.

## Acceptance Criteria

- [ ] Given any public page, when rendered at 375px viewport width, then no horizontal scrollbar appears and all content is accessible.
- [ ] Given the navigation menu, when viewed on mobile, then a hamburger/drawer pattern collapses the nav links and the menu is operable by touch.
- [ ] Given any CTA button, when rendered on mobile, then the touch target is at least 44×44px per WCAG guidelines.
- [ ] Given any image in the site, when rendered on mobile, then images scale proportionally and do not overflow their containers.
- [ ] Given a user on a mid-range Android device (Moto G equivalent), when navigating between pages, then navigation transitions complete in under 500ms on a 4G connection.

## Notes

Test breakpoints: 375px (mobile), 768px (tablet), 1280px (desktop), 1920px (wide). Lighthouse mobile score target: ≥ 85. Related: US-007 (Core Web Vitals/SEO), US-008 (accessibility).
