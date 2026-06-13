---
id: US-059
title: "Public Site Content Management"
slug: "content-management"
personas: [P-007]
epic: "Admin Dashboard"
priority: "should-have"
complexity: "L"
tags: [admin, cms, content, services, testimonials]
---

# US-059: Public Site Content Management

## User Story

**As a** site administrator,
**I want to** update services descriptions, testimonials, and featured projects on the public site through an admin interface,
**So that** I can keep the portfolio current without requiring a code deployment for every content change.

## Acceptance Criteria

- [ ] Given I navigate to `/admin/content/services`, when I edit a service's title, description, or bullet points and save, then the public services page reflects the change within 60 seconds (via revalidation or cache flush).
- [ ] Given I navigate to `/admin/content/testimonials`, when I add a new testimonial with client name, quote, role, and optional avatar, then it appears on the public site in the testimonials section.
- [ ] Given I edit an existing testimonial, when I set it to "Hidden", then it is removed from the public display without being deleted.
- [ ] Given I navigate to `/admin/content/projects`, when I update a featured open-source project's description or link, then the change appears on the public projects section.
- [ ] Given I make any content change, when it saves, then an audit log entry records what was changed, the previous value, and the new value.
- [ ] Given the content management interface, when I preview a change, then a preview mode shows me the public page with the proposed content before publishing.

## Notes

This is a lightweight CMS — not a full headless CMS integration. Target: fast edits for solo admin. If content grows complex, a headless CMS (Contentlayer, Sanity) can replace this. Related: US-051, US-063.
