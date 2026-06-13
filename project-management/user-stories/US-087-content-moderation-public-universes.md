---
id: US-087
title: "Content Moderation for Public Universes"
slug: "content-moderation-public-universes"
personas: [P-006]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "L"
tags: [admin, moderation, content, public, safety, trust-and-safety]
---

# US-087: Content Moderation for Public Universes

## User Story

**As a** platform administrator (P-006),
**I want to** review flagged public universes and canon entries, take moderation actions, and communicate decisions to users,
**So that** the platform remains safe and compliant with content policies.

## Acceptance Criteria

- [ ] Given a user reports a public universe or entry, when the report is submitted, then it appears in the admin moderation queue at /admin/moderation with the report reason, reporter identity, and a link to the content.
- [ ] Given I review a flagged item, when I click "Unpublish," then the universe or entry is immediately hidden from public views and the owner receives an automated email with the policy violation cited.
- [ ] Given I click "Dismiss report," when I confirm, then the flag is resolved with a "no action" status and the queue count decrements.
- [ ] Given I take any moderation action, when it is saved, then a permanent audit record is created including the moderator, timestamp, action taken, and any notes.
- [ ] Given AI-generated content is present in a flagged entry, when I review it, then a badge indicates which portions were AI-generated versus user-authored.

## Notes

Related: US-089 (abuse detection), US-090 (moderation policy configuration), US-092 (public universe sharing). Auto-flagging via AI content classifier should be considered as a follow-on to reduce manual queue volume.
