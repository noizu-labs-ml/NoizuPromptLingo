---
id: US-093
title: "Render Non-English Content Correctly in Wiki and Tickets"
slug: "non-english-content-rendering-wiki-tickets"
personas: [P-008]
epic: "Accessibility & Internationalization"
priority: "should-have"
complexity: "S"
tags: [i18n, unicode, wiki, tickets]
---

# US-093: Render Non-English Content Correctly in Wiki and Tickets

## User Story

**As** Tomás Lindqvist, the Evaluating Newcomer (P-008),
**I want to** write and read wiki pages and tickets in my own language, including non-Latin scripts and right-to-left text, without garbled characters or broken layouts,
**So that** I can use the product fluently without translating everything through English first.

## Acceptance Criteria

- [ ] Given Tomás enters ticket or wiki content containing multi-byte UTF-8 characters (CJK, Cyrillic, Arabic, emoji), when the content is saved and reloaded, then it round-trips byte-for-byte with no mojibake.
- [ ] Given content contains right-to-left script, when rendered, then text direction and alignment display correctly without overlapping or clipping adjacent UI chrome.
- [ ] Given a ticket title or wiki heading contains long non-Latin text, when displayed in a fixed-width UI element such as a card title or sidebar, then it wraps or truncates gracefully instead of overflowing the layout grid.
- [ ] Given Tomás searches ticket or wiki content using terms in his own language, when the search runs, then matching results are returned via basic token/substring matching.

## Notes

Scope is rendering/storage correctness, not full localization of UI chrome, which would be a separate i18n epic. Cross-reference US-085 for the same rendering guarantee applied to invite-error copy.
