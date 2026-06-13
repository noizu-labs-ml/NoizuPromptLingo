---
id: US-097
title: "Display Helpful Error Messages with Suggested Actions"
slug: "helpful-error-messages"
personas: [P-001, P-004, P-007]
epic: "Error States & Edge Cases"
priority: "must-have"
complexity: "M"
tags: [error-messages, ux, documentation]
---

# US-097: Display Helpful Error Messages with Suggested Actions

## User Story

**As a** Startup Founder (P-007),
**I want to** see error messages that explain what went wrong and suggest next steps,
**So that** I can resolve issues quickly without needing to contact support.

## Acceptance Criteria

- [ ] Given I attempt to create a space with a banned word in the name, when I submit, then I see an error "Space name contains prohibited content. Try 'AI Prompts' instead of 'Best AIP'"
- [ ] Given I try to join a private space I'm not invited to, when I attempt to join, then I see "This is a private space. Contact the owner to request access" with a "Contact Owner" button
- [ ] Given I paste invalid markdown, when I preview, then I see "Markdown error at line 5: Unclosed code block. Check your formatting" with a "Fix Help" link to markdown docs
- [ ] Given I upload a file that's too large, when the upload fails, then I see "File too large. Maximum size is 10MB. Your file is 25MB. Try compressing or using a smaller format."
- [ ] Given I encounter a 403 Forbidden error, when I view the page, then I see "You don't have permission to view this content" with a summary of what permissions are required

## Notes

Error messages should be human-readable, not technical. Never show stack traces or raw HTTP errors to users. Always provide actionable next steps or relevant doc links.