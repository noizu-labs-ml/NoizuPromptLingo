---
id: US-037
title: "Dashboard Customization"
slug: "dashboard-customization"
personas: [P-007, P-002]
epic: "Customer Dashboard"
priority: "could-have"
complexity: "L"
tags: [dashboard, customization, layout, preferences]
---

# US-037: Dashboard Customization

## User Story

**As a** power user with multiple active projects (P-002, P-007),
**I want to** customize the layout and widget visibility on my dashboard,
**So that** the information most relevant to my workflow is immediately visible without scrolling past content I rarely use.

## Acceptance Criteria

- [ ] Given I am on the dashboard, when I enter "customize" mode, then I can show or hide individual dashboard widgets (project cards, quick actions, billing summary, upcoming meetings)
- [ ] Given I drag a widget to a new position, when I save the layout, then subsequent visits preserve my custom arrangement
- [ ] Given I want to reset to the default layout, when I click "Reset to Default", then the dashboard returns to the standard arrangement
- [ ] Given I access the dashboard from a different device, when the page loads, then my custom layout is applied (server-persisted preferences)
- [ ] Given I hide the billing summary widget, when I view the dashboard, then it is no longer rendered but remains accessible via the navigation

## Notes

Low priority relative to core dashboard functionality — only build after US-026 through US-032 are complete. Drag-and-drop via a library (e.g. dnd-kit). Persist layout as JSON in user preferences. Consider mobile-specific layout options separately. Start with show/hide toggles before adding drag reorder.
