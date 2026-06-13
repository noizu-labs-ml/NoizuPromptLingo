---
id: US-067
title: "Editor's Picks Curation Workflow"
slug: "editors-picks-curation-workflow"
personas: [P-005, P-008]
epic: "Collections & Lists"
priority: "could-have"
complexity: "L"
tags: [editorial, curation, workflow, admin, moderation]
---

# US-067: Editor's Picks Curation Workflow

## User Story

**As a** content moderator / editor (P-005),
**I want to** have a dedicated workflow for creating and publishing editorial collections,
**So that** curated "Best of" and seasonal lists can be assembled, reviewed, and scheduled for publication without requiring developer involvement.

## Acceptance Criteria

- [ ] Given I have editor role access, when I navigate to the editorial dashboard, then I can create a new editorial collection with title, description, cover image, and publication date
- [ ] Given I am building an editorial collection, when I search for sites within the editor tool, then I can add sites from the directory to the collection with an optional editorial note per entry
- [ ] Given a collection is ready, when I set its status to "Scheduled", then it is queued for automatic publication at the specified date and time
- [ ] Given an editorial collection is published, when it becomes visible on the site, then it appears in the Collections featured section and can be promoted to the homepage by an admin
- [ ] Given an editor saves a draft collection, when another editor opens the same collection, then they see the current draft state with the last-modified editor's name and timestamp

## Notes

This workflow requires a role-based permission system (editor vs. admin vs. user) not detailed elsewhere in the user stories. The editorial dashboard is an internal tool — it does not need to match the public-facing design exactly but should be functional and audit-logged. Related: US-059 (view editorial lists), US-063 (seasonal collections).
