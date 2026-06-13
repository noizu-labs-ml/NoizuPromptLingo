---
id: US-083
title: "Admin Dashboard Overview"
slug: "admin-dashboard-overview"
personas: [P-008]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "M"
tags: [admin, dashboard, analytics, moderation, overview]
---

# US-083: Admin Dashboard Overview

## User Story

**As a** platform admin (P-008),
**I want to** see a high-level overview of platform health and activity on a single dashboard,
**So that** I can quickly identify problems, monitor growth, and prioritize moderation work.

## Acceptance Criteria

- [ ] Given I am logged in as an admin, when I navigate to `/admin`, then I see a dashboard with KPI cards: Total Users, Active Blogs, Active Competitions, Monthly Revenue (MRR), Flagged Content Count, and New Signups (last 7 days).
- [ ] Given the dashboard loads, when KPI data is fetched, then all cards display within 2 seconds using cached aggregates (updated every 5 minutes).
- [ ] Given flagged content exists, when the Flagged Content KPI card shows a non-zero count, then the card is highlighted in amber and links directly to the moderation queue.
- [ ] Given I view the dashboard, when I look at the activity feed section, then I see the last 20 platform events (new signups, blog submissions, competition entries, flags raised) with timestamps.
- [ ] Given I am not an admin (any user role), when I attempt to access `/admin` or any `/admin/*` route, then I receive a 403 response and am redirected to the home page.
- [ ] Given the admin dashboard, when I click any KPI card, then I am taken to the corresponding detailed management view (e.g., Flagged Content → moderation queue).

## Notes

Admin role must be enforced at the middleware/server level, not just client routing. Dashboard data should come from a dedicated analytics aggregation job, not live DB queries, to avoid performance impact. Relates to US-084 through US-090.
