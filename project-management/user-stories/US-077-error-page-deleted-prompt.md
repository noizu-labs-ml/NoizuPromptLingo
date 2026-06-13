---
id: US-077
title: "Error Page for Deleted or Removed Prompt"
slug: "error-page-deleted-prompt"
personas: [P-001, P-002, P-003, P-005]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "S"
tags: [error-handling, 404, moderation, prompt-removal]
---

# US-077: Error Page for Deleted or Removed Prompt

## User Story

**As a** Prompt Engineer (P-001) or any community member,
**I want to** see a clear, informative error page when I navigate to a prompt that has been deleted or removed,
**So that** I understand what happened and have a path forward rather than seeing a generic error or broken page.

## Acceptance Criteria

- [ ] Given a prompt URL that previously existed but was deleted by its author, when a user navigates to it, then a 404-style page is shown with messaging indicating the content was removed
- [ ] Given a prompt removed by a moderator for policy violations, when any user navigates to it, then the page indicates the content was removed for community guidelines violations (without revealing moderation details)
- [ ] Given the error page is displayed, when the user views it, then it provides a link back to the home feed and a search bar to find related content
- [ ] Given a logged-in user who authored the deleted prompt visits the URL, when they see the error page, then they receive confirmation that the deletion was successful along with the standard navigation options

## Notes

Distinguishing between author-deleted and moderator-removed prompts in the messaging improves transparency without exposing sensitive moderation data. HTTP response codes must be set correctly (404 for deleted, 410 Gone for permanently removed) to avoid SEO indexing of dead links.
