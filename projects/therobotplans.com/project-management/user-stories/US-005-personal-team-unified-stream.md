---
id: US-005
title: "Personal and team items in unified stream"
personas: [sarah-kim, raj-patel]
domain: today-view
priority: high
mvp_phase: "v0.1"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want to view personal and team items in a single unified stream without app-switching so that I can manage my own tasks and my team's blockers from one place.

## Acceptance Criteria

- [ ] Personal items (todos, habits, personal goals) and team items (assigned tasks, review requests, team blockers) render in one chronological/priority stream
- [ ] Each item displays a clear visual badge indicating its domain (personal, team, project) to prevent context confusion
- [ ] A domain filter (personal only, team only, all) is available as a toggle and persists across sessions
- [ ] Team items show assignee and status so Sarah can see her reports' progress inline
- [ ] Items from team members requiring Sarah's action (approvals, reviews) are promoted with a distinct visual treatment

## Notes

This story embodies the core thesis of tobornalp: life and work are not separate apps. The unified stream must feel natural, not like two feeds stitched together. The scale-free model helps here — a "buy groceries" item and a "review PR #412" item are structurally identical, differing only in domain and metadata.
