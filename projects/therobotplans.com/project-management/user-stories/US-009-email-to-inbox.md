---
id: US-009
title: "Email forwarding to inbox"
personas: [diana-kovacs]
domain: inbox
priority: low
mvp_phase: "v0.3"
---

## User Story

As a **Diana Kovacs (Freelance Multi-Client)**, I want to forward emails to a dedicated inbox address that creates items with metadata extraction so that client requests arriving via email automatically become trackable work items.

## Acceptance Criteria

- [ ] Each user receives a unique inbox email address (e.g., `diana+inbox@tobornalp.com`)
- [ ] Forwarded emails create inbox items with: subject as title, body as description, sender as metadata, and attachments preserved
- [ ] The AI triage agent (US-008) processes email-sourced items the same as manually captured items
- [ ] Client/project association is attempted automatically based on sender domain or email content
- [ ] A daily digest option summarizes all email-captured items for review instead of creating them immediately

## Notes

This bridges the gap for freelancers whose clients still communicate primarily via email. The metadata extraction should handle common patterns: "Can you do X by Friday" should extract a due date. Rate-limiting and spam filtering are essential to prevent inbox flooding from forwarded newsletters or spam.
