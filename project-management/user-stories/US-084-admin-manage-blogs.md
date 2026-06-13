---
id: US-084
title: "Admin: Manage Blogs (Approve/Flag/Remove)"
slug: "admin-manage-blogs"
personas: [P-008]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "M"
tags: [admin, moderation, blogs, approve, flag, remove]
---

# US-084: Admin: Manage Blogs (Approve/Flag/Remove)

## User Story

**As a** platform admin (P-008),
**I want to** review, approve, flag, and remove blog submissions from a management interface,
**So that** only quality, policy-compliant blogs are listed on the platform.

## Acceptance Criteria

- [ ] Given I am on the admin blog management page, when I load the list, then I see all blogs with columns: Blog Name, Owner, Submitted Date, Status (Pending/Active/Flagged/Removed), AI Score (if scored), and action buttons.
- [ ] Given a blog is in "Pending" status, when I click "Approve," then the blog status changes to "Active," the owner receives a notification email, and the blog becomes visible in discovery.
- [ ] Given a blog is in "Active" or "Pending" status, when I click "Flag," then I am prompted to select a reason (Spam, Inappropriate Content, Broken URL, Other) and optionally add a note before confirming.
- [ ] Given I flag a blog, when the flag is saved, then the blog is hidden from public discovery, its status changes to "Flagged," and the flagged content count on the admin dashboard increments.
- [ ] Given a blog is in any non-removed status, when I click "Remove," then a confirmation modal appears; upon confirmation, the blog is soft-deleted, the owner notified, and the blog removed from all leaderboards and competitions.
- [ ] Given I am on the blog management page, when I use the status filter, then the list filters to show only blogs matching the selected status (All / Pending / Active / Flagged / Removed).
- [ ] Given I search by blog name or owner email, when results are returned, then matching blogs are shown within 500ms.

## Notes

Soft delete: set `deleted_at` timestamp; never hard-delete. Removed blogs should be excluded from all public queries. Owner notification emails for flag and remove actions should include the reason. Relates to US-083, US-087 (bulk moderation), US-088 (flagged content queue).
