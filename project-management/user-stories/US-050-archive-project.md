---
id: US-050
title: "Archive a Project Without Deleting"
slug: "archive-project"
personas: [P-002, P-004, P-005]
epic: "Team & Collaboration"
priority: "should-have"
complexity: "S"
tags: [archive, project, lifecycle, organization]
---

# US-050: Archive a Project Without Deleting

## User Story

**As a** product manager (P-002),
**I want to** archive a completed project without permanently deleting it,
**So that** the workspace remains uncluttered while historical mockups and feedback remain accessible for reference.

## Acceptance Criteria

- [ ] Given an active project or mockup collection, when I click "Archive", then it is removed from the active dashboard but remains accessible via an "Archived" filter
- [ ] Given an archived project, when I navigate to it, then all mockups, annotations, and version history are readable but no new edits or annotations are accepted
- [ ] Given an archived project, when I click "Unarchive", then it returns to active status with all data intact
- [ ] Given the workspace dashboard, when I toggle "Show archived", then archived projects appear with a visual badge distinguishing them from active ones

## Notes

Archived projects should not count toward active mockup limits on quota-restricted plans. Archiving should be reversible with no data loss. Only workspace admins and the project owner should be able to archive.
