---
id: US-026
title: "Share Mockup via Unique Link"
slug: "share-mockup-via-link"
personas: [P-002, P-004]
epic: "Stakeholder Feedback"
priority: "must-have"
complexity: "S"
tags: [sharing, feedback, links, access]
---

# US-026: Share Mockup via Unique Link

## User Story

**As a** product manager (P-002),
**I want to** generate a unique shareable link for a mockup,
**So that** external stakeholders can view and comment without needing an account.

## Acceptance Criteria

- [ ] Given a mockup exists, when I click "Share", then a unique URL is generated and copied to clipboard
- [ ] Given a share link is generated, when an unauthenticated user visits it, then they can view the mockup and leave comments with a display name
- [ ] Given a share link exists, when I revoke it, then the link becomes invalid and returns a 404
- [ ] Given a share link, when it is set to expire, then access is denied after the expiry date

## Notes

Links should support optional password protection and expiry dates. Relates to US-032 for permission levels on shared links.
