---
id: US-003
title: "Drag to reorder daily priorities"
personas: [alex-russo]
domain: today-view
priority: medium
mvp_phase: "v0.1"
---

## User Story

As an **Alex Russo (Productivity Enthusiast)**, I want to drag items to reorder my daily priorities in the today view so that I can manually sequence my day based on energy, context, and importance.

## Acceptance Criteria

- [ ] Items in the today view support drag-and-drop reordering with smooth animation
- [ ] Reordered position persists across page reloads and is stored as a daily priority rank
- [ ] Keyboard-based reordering is available (e.g., Alt+Up/Down) for accessibility and power users
- [ ] Reordering within the today view does not alter the item's priority in its parent project or list
- [ ] A "reset to default order" action restores AI-suggested or priority-based sorting

## Notes

The today view priority order is a daily ephemeral layer on top of the item's intrinsic priority. This supports the "plan your day" ritual without polluting the global priority model. Consider snapping items into time-block slots if US-017 (time blocking) is also active.
