---
id: US-084
title: "Admin User Management"
slug: "admin-user-management"
personas: [P-006]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "M"
tags: [admin, users, moderation, account, roles]
---

# US-084: Admin User Management

## User Story

**As a** platform administrator (P-006),
**I want to** search, view, and manage user accounts including roles, plan status, and suspension,
**So that** I can respond to support requests, enforce policies, and maintain platform integrity.

## Acceptance Criteria

- [ ] Given I am on /admin/users, when I search by email or username, then results appear within 500ms and show account status, plan, creation date, and last login.
- [ ] Given I open a user's detail view, when I click "Suspend account," then the user is immediately logged out, their sessions are invalidated, and they cannot log in until reinstated.
- [ ] Given I change a user's plan (e.g., free → pro), when I save, then the change takes effect immediately and is reflected in the user's own account settings.
- [ ] Given I grant a user the admin role, when I confirm, then that user gains access to /admin/* and an audit log entry is created recording who made the change and when.
- [ ] Given I view a user's detail page, when I look at their activity section, then I see a list of their last 50 actions (logins, generations, universe edits) with timestamps.

## Notes

Depends on US-083 (admin dashboard). All role and suspension changes must be written to an immutable audit log. Bulk user export (CSV) should be considered a follow-on under this story.
