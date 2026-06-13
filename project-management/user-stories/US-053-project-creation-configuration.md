---
id: US-053
title: "Project Creation and Configuration"
slug: "project-creation-configuration"
personas: [P-007]
epic: "Admin Dashboard"
priority: "must-have"
complexity: "M"
tags: [admin, project, create, configure, engagement]
---

# US-053: Project Creation and Configuration

## User Story

**As a** site administrator,
**I want to** create a new project record and configure its scope, timeline, service type, and associated client,
**So that** each engagement has a structured container for milestones, deliverables, and communications.

## Acceptance Criteria

- [ ] Given I am on the admin projects list, when I click "New Project", then a creation form appears with fields: project name, client (dropdown), service type, start date, estimated end date, description, and status.
- [ ] Given I submit a valid project form, when the record saves, then the project appears in the client's dashboard and in the admin project list.
- [ ] Given an existing project, when I edit its configuration and save, then changes are persisted and an audit entry is logged.
- [ ] Given a project record, when I update its status (Planning → Active → On Hold → Complete), then the status badge updates site-wide wherever the project appears.
- [ ] Given a project, when I set an estimated end date that has passed and status is not Complete, then the project is flagged as "At Risk" in the admin overview.

## Notes

Projects are the top-level container linking milestones (US-054) and deliverables (US-055) to a client. Service types mirror the public services page. Related: US-052, US-054, US-055.
