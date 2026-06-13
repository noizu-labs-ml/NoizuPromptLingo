---
id: US-088
title: "Admin: Manage Technique Triage Queue"
slug: "admin-technique-triage-queue"
personas: [P-001]
epic: "Settings & Administration"
priority: "must-have"
complexity: "L"
tags: [admin, triage, catalog, editorial, workflow]
---

# US-088: Admin: Manage Technique Triage Queue

## User Story

**As a** catalog editor and platform administrator (P-001 acting as admin),
**I want to** manage an editorial triage queue for new, updated, and flagged techniques,
**So that** the catalog maintains taxonomic consistency, severity accuracy, and timely publication of new threat intelligence.

## Acceptance Criteria

- [ ] Given the triage queue, when I view it, then items are grouped by type (new submission, update request, community flag, automated detection) with age, current status, and assigned reviewer
- [ ] Given an unassigned queue item, when I claim it, then it is assigned to me and removed from the "available" pool visible to other admins
- [ ] Given a technique under triage, when I edit classification fields (category, subcategory, severity, model targets, MITRE mapping), then changes are saved as a draft pending final publish
- [ ] Given a draft edit, when I click "Publish", then the technique record is updated, a version history entry is created, and watchers of that technique are notified
- [ ] Given I disagree with a severity rating, when I change it and add an editorial note, then the note appears on the technique's public page as a "Severity adjusted by editorial team" annotation
- [ ] Given the queue, when items have been waiting more than 72 hours, then they are highlighted with an overdue indicator and a digest alert is sent to all admin-role users

## Notes

Version history for each technique must store who changed what and when — essential for the catalog's credibility as a security reference. Triage queue items sourced from community submissions (US-087) should be pre-linked. Consider Kanban-style column view as an enhancement.
