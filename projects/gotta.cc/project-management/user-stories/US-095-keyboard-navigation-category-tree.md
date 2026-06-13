---
id: US-095
title: "Full Keyboard Navigation of Category Tree"
slug: "keyboard-navigation-category-tree"
personas: [P-001, P-003, P-004]
epic: "Accessibility & Performance"
priority: "must-have"
complexity: "M"
tags: [accessibility, keyboard, navigation, a11y, wcag]
---

# US-095: Full Keyboard Navigation of Category Tree

## User Story

**As a** Research Journalist (P-003),
**I want to** navigate the entire category tree using only a keyboard,
**So that** I can browse the directory efficiently without a mouse and in compliance with my organization's accessibility requirements.

## Acceptance Criteria

- [ ] Given I am on any page with the category tree visible, when I press Tab, then focus moves to the first interactive element in the category tree in a logical, predictable order
- [ ] Given focus is on a collapsed category node, when I press Enter or Space, then the subcategory list expands and focus moves to the first subcategory
- [ ] Given focus is on an expanded category node, when I press Escape or the left arrow key, then the subcategory list collapses and focus returns to the parent category
- [ ] Given I am navigating the category tree, when I press the up/down arrow keys, then focus moves between sibling categories at the same level without exiting the tree
- [ ] Given any interactive element in the category tree receives focus, when I observe the element, then it has a clearly visible focus ring that meets WCAG 2.1 AA contrast requirements

## Notes

Implement the tree widget using the ARIA `treeitem` and `tree` roles with the keyboard interaction pattern defined in the ARIA Authoring Practices Guide (APG). This story is foundational for US-096 (screen reader support) — keyboard focus management is a prerequisite for meaningful screen reader announcements.
