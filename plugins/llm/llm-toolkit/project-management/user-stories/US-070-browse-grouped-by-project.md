---
id: US-070
title: "Browse grouped by project"
slug: browse-grouped-by-project
personas: [P-005, P-001]
epic: "Admin & Oversight"
priority: must-have
complexity: medium
tags: [admin, browse]
---

# US-070: Browse Grouped by Project

## User Story

**As an** engineering lead auditing team AI usage (or solo power-user developer)
**I want to** see the Browse view group conversations by project with a per-project conversation count
**So that** I can quickly scan activity across every project in a single weekly pass instead of scrolling one long flat list

## Acceptance Criteria

- **Given** conversations exist across multiple indexed project directories
  **When** I open Browse
  **Then** conversations are grouped into collapsible sections by project, each section header showing the project name and a conversation count (e.g. "acme-api (14)")

- **Given** a project group is collapsed
  **When** I click its header
  **Then** it expands to list its conversations (title, last-active timestamp, message count) without navigating away from Browse

- **Given** I have 6 concurrent client repos indexed (Marcus's typical setup)
  **When** I load Browse
  **Then** every distinct project directory appears as its own group, including projects with only a single conversation

- **Given** a project has zero conversations remaining (e.g. all archived or deleted)
  **When** I load Browse with the default filter
  **Then** that project group is omitted rather than shown empty

## Notes
This is the backbone of Daniel's weekly oversight scan and Marcus's day-to-day recall across client repos — both depend on project-level grouping being accurate and the counts being trustworthy at a glance.
