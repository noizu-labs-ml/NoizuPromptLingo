---
id: US-083
title: "Keyboard Navigation for All Core Flows"
slug: "keyboard-navigation-core-flows"
personas: [P-001, P-003, P-005]
epic: "Accessibility & i18n"
priority: "should-have"
complexity: "M"
tags: [accessibility, keyboard-navigation, wcag, a11y]
---

# US-083: Keyboard Navigation for All Core Flows

## User Story

**As a** Prompt Engineer (P-001) or ML Researcher (P-003),
**I want to** complete all core tasks using only a keyboard,
**So that** power users and users with motor disabilities can use the platform without relying on a mouse.

## Acceptance Criteria

- [ ] Given a sighted keyboard user navigating the feed, when they use Tab to move through the page, then focus moves in a logical reading order through all interactive elements with a visible focus ring
- [ ] Given a keyboard user on a prompt card, when they press Enter or Space on the upvote button, then the vote is registered identically to a mouse click
- [ ] Given a keyboard user in the search bar, when they type a query and use arrow keys, then they can navigate autocomplete suggestions and select one with Enter
- [ ] Given any modal or dropdown opened via keyboard, when it opens, then focus is trapped inside the dialog and pressing Escape closes it and returns focus to the triggering element

## Notes

Focus ring styles must not be suppressed globally (e.g., no `outline: none` without a mouse-use detection fallback). All custom interactive components (vote buttons, tag pills, dropdown menus) must implement correct ARIA roles and keyboard event handlers per WAI-ARIA authoring practices. WCAG 2.1 AA compliance is the target.
