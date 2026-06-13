---
id: US-042
title: "Publish Competition"
slug: "publish-competition"
personas: [P-003, P-005]
epic: "Competition Hosting"
priority: "must-have"
complexity: "S"
tags: [competitions, hosting, publish, visibility, launch]
---

# US-042: Publish Competition

## User Story

**As a** competition host who has finished configuring my competition (P-005),
**I want to** publish my competition to make it visible to all bloggers on the platform,
**So that** bloggers can discover it, browse its details, and enter if they're eligible.

## Acceptance Criteria

- [ ] Given I have a completed draft competition with all required fields, when I click "Publish Competition," then a confirmation dialog summarizes key settings and asks me to confirm
- [ ] Given I confirm publication, when the competition is published, then it appears immediately in the Competitions listing page with "Upcoming" or "Open" status based on its configured start date
- [ ] Given my competition is published and the start date is in the future, when the start date arrives, then the competition status automatically transitions from "Upcoming" to "Open" and entry becomes available
- [ ] Given I publish a competition, when I return to my host dashboard, then the competition shows "Published" status with quick-access links to manage entries and view analytics
- [ ] Given I publish a competition, when the publication completes, then a shareable competition URL is provided so I can promote it on social media or email lists
- [ ] Given I want to unpublish a competition after publishing but before it starts, when I click "Unpublish," then the competition is hidden from public listing and all settings can still be edited

## Notes

Publishing is irreversible once the first entry is received — only unpublishing before entries are received should be allowed. After first entry, only specific fields (deadline extension, description) can be edited. The shareable URL should be clean and SEO-friendly (e.g., `/competitions/{slug}`). Related to US-039 (create), US-041 (deadlines), US-043 (manage entries).
