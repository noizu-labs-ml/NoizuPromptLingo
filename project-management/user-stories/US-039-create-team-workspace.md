---
id: US-039
title: "Create a Team Workspace"
slug: "create-team-workspace"
personas: [P-004, P-002, P-005]
epic: "Team & Collaboration"
priority: "must-have"
complexity: "M"
tags: [workspace, team, onboarding, organization]
---

# US-039: Create a Team Workspace

## User Story

**As a** startup founder (P-004),
**I want to** create a named team workspace,
**So that** all mockups and collaborators for my product are organized under a single shared environment.

## Acceptance Criteria

- [ ] Given I am authenticated, when I click "Create Workspace" and enter a name, then a new workspace is created and I become its admin
- [ ] Given a workspace exists, when I navigate to it, then I see a dashboard of all mockups belonging to that workspace
- [ ] Given workspace creation, when I submit, then I can optionally upload a workspace logo and set a description
- [ ] Given multiple workspaces, when I switch between them, then the correct mockups and members are scoped accordingly

## Notes

Users should be able to belong to multiple workspaces. Workspace slug should be auto-generated from the name and editable before creation. Free tier should support 1 workspace; paid tiers allow unlimited.
