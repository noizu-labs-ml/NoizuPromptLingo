---
id: US-057
title: "Client Activity Monitoring"
slug: "client-activity-monitoring"
personas: [P-007]
epic: "Admin Dashboard"
priority: "should-have"
complexity: "M"
tags: [admin, monitoring, activity, client, engagement]
---

# US-057: Client Activity Monitoring

## User Story

**As a** site administrator,
**I want to** see a per-client activity feed showing their recent dashboard logins, file downloads, message reads, and milestone acknowledgments,
**So that** I can gauge engagement levels and proactively reach out to clients who have gone quiet.

## Acceptance Criteria

- [ ] Given I open a client record, when I navigate to the "Activity" tab, then I see a chronological feed of the client's tracked events (login, download, message read, milestone viewed) with timestamps.
- [ ] Given the activity feed, when a client has had no activity in 14+ days, then a "Low Engagement" badge is shown on their record in the client list.
- [ ] Given the admin dashboard overview, when I view the "Client Health" section, then clients are grouped by engagement tier: Active (activity in 7d), Quiet (8–21d), Dormant (22d+).
- [ ] Given a client downloads a deliverable, when the download is recorded, then the event appears in both the client's activity feed and the admin's recent activity log.
- [ ] Given I click a "Send Check-in" shortcut from the Low Engagement badge, when clicked, then a pre-filled email compose window opens addressed to that client.

## Notes

Activity tracking should be lightweight — page-level events and explicit user actions only, no keystroke or mouse tracking. GDPR/privacy considerations apply; disclose in privacy policy. Related: US-051, US-052, US-063.
