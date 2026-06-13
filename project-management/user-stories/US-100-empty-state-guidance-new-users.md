---
id: US-100
title: "Empty State Guidance for New Users with No Data"
slug: "empty-state-guidance-new-users"
personas: [P-002, P-005, P-008]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "S"
tags: [onboarding, empty-state, ux, new-user, edge-cases]
---

# US-100: Empty State Guidance for New Users with No Data

## User Story

**As a** newly registered user encountering an empty dashboard or feature section for the first time (P-002, P-005, P-008),
**I want to** see helpful context and clear next steps instead of a blank screen,
**So that** I understand what the section does, what I need to do to populate it with data, and feel confident rather than confused about where to begin.

## Acceptance Criteria

- [ ] Given a new user with no scan history, when they visit the Defender dashboard, then they see an illustrated empty state with the heading "No scans yet", a 1-sentence explanation of what Defender does, and a primary CTA button "Run Your First Scan"
- [ ] Given a new user with no bookmarks, when they visit the Bookmarks section, then they see an empty state with guidance: "Bookmark techniques as you browse the catalog — they'll appear here", and a link to the catalog
- [ ] Given a new user who has not enrolled in any labs, when they visit the Academy dashboard, then they see an empty state with a "Get Started" CTA, a brief description of the CTF format, and a suggested beginner lab
- [ ] Given a user with no API keys, when they visit the API keys settings page, then the empty state includes inline documentation explaining key scopes and a single prominent "Generate API Key" button
- [ ] Given any empty state, when it renders, then the illustration or icon is relevant to the section context (not a generic "no data" image) and copy is written in an encouraging, non-apologetic tone
- [ ] Given an empty state with a CTA, when I click the CTA, then I am taken directly to the most relevant next action (no intermediate landing pages)

## Notes

Empty states are first impressions for key features — they directly impact activation rate. Illustrations should be consistent with the platform's visual identity. Copy should follow the pattern: [What this section is for] + [Why it's empty] + [What to do next]. Avoid the word "oops" and passive-voice apologies.
