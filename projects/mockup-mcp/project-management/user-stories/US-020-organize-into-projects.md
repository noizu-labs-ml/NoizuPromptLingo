---
id: US-020
title: "Organize mockups into projects and folders"
slug: "organize-into-projects"
personas: [P-002, P-003, P-006]
epic: "Mockup Management"
priority: "should-have"
complexity: "M"
tags: [mockup-management, projects, folders, organization]
---

# US-020: Organize mockups into projects and folders

## User Story

**As a** product manager (P-002),
**I want to** create named projects and move mockups into them,
**So that** I can keep mockups for different product areas or client engagements separated and easy to find.

## Acceptance Criteria

- [ ] Given I am in the Gallery, when I click "New Project", then I can provide a name and optional description and the project is created immediately
- [ ] Given an existing project, when I drag a mockup card onto the project in the sidebar, then the mockup is moved to that project and disappears from the "All Mockups" view
- [ ] Given I right-click a mockup, when I select "Move to Project", then a searchable project picker dialog appears and the move is applied on selection
- [ ] Given a project is deleted, when I confirm the deletion, then I am prompted to either delete all contained mockups or move them to "All Mockups" before the project is removed

## Notes

Nesting depth is limited to one level (projects only, no sub-folders) for MVP. Mockups can belong to exactly one project at a time. MCP tool calls can optionally pass `project_id` to auto-assign new mockups on creation. Related to US-019, US-021.
