---
id: US-023
title: "Create a Resource"
slug: "create-resource"
personas: [P-001, P-002, P-005]
epic: "Resources - Basic"
priority: "must-have"
complexity: "M"
tags: [resources, creation, versions]
---

# US-023: Create a Resource

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** create a resource (prompt, skill, MCP config) with title, content, and metadata,
**So that** I can share reusable assets with the community and track versions over time.

## Acceptance Criteria

- [ ] Given an authenticated user, when they click "Create Resource" and select a type (Prompt, Skill, MCP Config), then they see a form with name (5-100 characters), description (10-500 characters), and content (10-10000 characters, markdown supported)
- [ ] Given a user is creating a resource, when they enter content and submit, then a new resource is created with version v1.0.0 and the user as owner
- [ ] Given a user is creating a resource, when they submit the form without filling required fields, then they receive inline validation errors
- [ ] Given a resource is created, when the user is redirected to the resource detail, then they see options to attach it to spaces, edit content, or create a new version
- [ ] Given a user is creating a resource of type "Prompt", when they specify the model compatibility (e.g., GPT-4, Claude), then that metadata is stored and displayed

## Notes

Depends on US-003 for user profile. Resources are versioned; each edit increments the version number (major.minor.patch). Versioning follows semantic versioning (user-controlled).