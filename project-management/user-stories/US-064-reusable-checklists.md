---
id: US-064
title: "Create reusable checklists attachable to any item type"
personas: [james-oduya]
domain: checklists
priority: medium
mvp_phase: "v0.2"
---

## User Story

As a **James Oduya (Agency Owner)**, I want to create reusable checklists that can be attached to any item type so that my teams follow consistent processes without recreating checklists from scratch each time.

## Acceptance Criteria

- [ ] Checklists are first-class items in the scale-free model: taggable, linkable, versionable
- [ ] A checklist template can be attached to any item (todo, task, bug, epic, goal) with one action
- [ ] Attaching a checklist creates an independent instance (editing the instance does not mutate the template)
- [ ] Checklist items support assignees, due dates, and nested sub-items (one level deep)
- [ ] Checklist completion percentage is visible on the parent item's card and detail view

## Notes

Key to the scale-free philosophy: checklists are not a special-case feature but items composed with other items. James needs this for agency-wide processes (client onboarding, launch checklist, QA pass). Consider bulk-attach: apply a checklist template to all items matching a filter.
