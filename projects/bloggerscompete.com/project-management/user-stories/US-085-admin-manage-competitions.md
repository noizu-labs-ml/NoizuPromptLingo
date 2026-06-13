---
id: US-085
title: "Admin: Manage Competitions (Feature/Close)"
slug: "admin-manage-competitions"
personas: [P-008]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "M"
tags: [admin, competitions, feature, close, moderation]
---

# US-085: Admin: Manage Competitions (Feature/Close)

## User Story

**As a** platform admin (P-008),
**I want to** feature high-quality competitions and force-close problematic ones,
**So that** the competition catalog remains curated and safe for all users.

## Acceptance Criteria

- [ ] Given I am on the admin competitions page, when I load the list, then I see all competitions with columns: Title, Host, Status (Draft/Active/Closed), Entry Count, Start Date, End Date, Featured (yes/no), and action buttons.
- [ ] Given a competition is Active, when I click "Feature," then the competition is tagged as Featured, appears first in the public competition browse list, and a "Featured" badge is shown to users.
- [ ] Given a competition is Featured, when I click "Unfeature," then the Featured tag is removed and the competition returns to standard sort order.
- [ ] Given a competition is Active and violates platform policy, when I click "Force Close," then I am prompted to enter a reason; upon confirmation, the competition status changes to "Closed (Admin)" and the host receives a notification email with the reason.
- [ ] Given a competition is force-closed by an admin, when participants view that competition, then they see a banner: "This competition was closed by platform administrators" without revealing admin notes.
- [ ] Given I filter competitions by status, when I select "Active," then only currently running competitions are shown; selecting "All" shows every competition regardless of status.

## Notes

Force-close is distinct from a host's normal close action (US-089 admin create competition). Competition entries submitted before force-close remain in the historical record. Relates to US-083, US-089.
