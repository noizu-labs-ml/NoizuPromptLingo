---
id: US-029
title: "Gantt view with milestone tracking for client projects"
personas: [james-oduya]
domain: projects
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **James Oduya (Agency Owner)**, I want a Waterfall/Gantt view for client projects with milestone tracking so that I can communicate timelines and progress in the format enterprise clients expect.

## Acceptance Criteria

- [ ] Gantt chart renders project items as horizontal bars on a timeline with start/end dates, dependencies shown as connector lines, and milestones as diamond markers
- [ ] Drag-and-drop on the Gantt adjusts item dates and automatically recalculates dependent item dates with conflict highlighting
- [ ] Critical path is visually highlighted, showing which item sequence determines the project's minimum completion date
- [ ] Milestones can be linked to deliverables and have configurable status (upcoming, at risk, completed, missed) with automatic status based on child item completion
- [ ] Gantt view can be exported as PDF or image for inclusion in client reports (see US-032)

## Notes

Many agency clients — especially enterprise — think in Gantt charts and milestones, not sprints. This view must be polished enough to share directly with clients. The underlying data is the same scale-free items; the Gantt is just a temporal projection. Consider resource leveling as a future enhancement. The Gantt should work alongside other views — same data, different lens.
