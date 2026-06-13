---
id: US-098
title: "Full Keyboard Navigation Support"
slug: "keyboard-navigation"
personas: [P-003, P-005]
epic: "Accessibility & UX Polish"
priority: "should-have"
complexity: "L"
tags: [accessibility, keyboard, wcag-2.1]
---

# US-098: Full Keyboard Navigation Support

## User Story

**As an** MCP Server Developer (P-005),
**I want to** navigate the entire platform using only my keyboard,
**So that** I can work efficiently without relying on a mouse pointer.

## Acceptance Criteria

- [ ] Given I'm on the homepage, when I press Tab, then focus moves logically through interactive elements (feeds → cards → buttons → search)
- [ ] Given I'm viewing a thread, when I press Enter on a reply button, then the reply input receives focus
- [ ] Given I navigate the main menu, when I use arrow keys, then menu items are traversable and activate on Enter/Space
- [ ] Given I'm in a modal dialog, when it opens, then focus traps inside the modal and returns to the trigger element on close
- [ ] Given I use keyboard shortcuts, when I press ?, then I see a keyboard shortcuts help panel listing all available shortcuts

## Notes

WCAG 2.1 Success Criteria: 2.1.1 Keyboard, 2.1.2 No Keyboard Trap, 2.4.3 Focus Order. Visual focus indicators should be high-contrast and visible at all times.