---
id: US-021
title: "Rich Text Editing in Canon Entries"
slug: "rich-text-editing"
personas: [P-001, P-008]
epic: "Canon Editor — Core"
priority: "must-have"
complexity: "L"
tags: [canon, editor, rich-text, ux]
---

# US-021: Rich Text Editing in Canon Entries

## User Story

**As an** epic novelist (P-001),
**I want to** write formatted prose in long-form entry fields (biography, description, history),
**So that** I can maintain the narrative quality of my world bible rather than reducing everything to plain text bullets.

## Acceptance Criteria

- [ ] Given a long-form entry field is in edit mode, when I interact with the text area, then a floating toolbar offers: Bold, Italic, Underline, Heading (H2/H3), Bulleted list, Numbered list, Blockquote, and Inline link (US-022).
- [ ] Given I apply formatting using the toolbar, when the entry is saved, then formatting is persisted and rendered correctly in view mode.
- [ ] Given I paste content from an external document (e.g., Google Docs), when the paste lands, then formatting is stripped to plain text with inline formatting preserved (bold/italic only) — block structure from the source is not imported.
- [ ] Given I am editing rich text on a mobile viewport (< 768px), when the keyboard is open, then the toolbar collapses to an overflow menu and the text area remains fully visible.

## Notes

The rich text editor must store content as a portable format (e.g., ProseMirror JSON or Markdown) — not HTML blobs — for export compatibility. Related: US-022 (inline linking), US-019 (import parsing).
