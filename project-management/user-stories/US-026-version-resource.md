---
id: US-026
title: "Version a Resource"
slug: "version-resource"
personas: [P-001, P-002]
epic: "Resources - Advanced Versioning"
priority: "must-have"
complexity: "S"
tags: [resources, versioning, core]
---

# US-026: Version a Resource

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** create a new version of a resource with a changelog,
**So that** I can iterate on and track the evolution of my prompts, skills, and MCP configs.

## Acceptance Criteria

- [ ] Given a resource I own, when I click "Create Version" and provide a version number and changelog, then a new version is created with the current content preserved
- [ ] Given a resource with multiple versions, when I view the resource, then I can see the version history with timestamps and version numbers
- [ ] Given a versioned resource, when I attempt to create a new version, then I must provide a changelog describing what changed
- [ ] Given a versioned resource, when I create a new version, then the previous version remains immutable and accessible

## Notes

Version numbers must be semantic (e.g., v1.0.0, v1.1.0). Depends on US-001 (Create Resource). Changelog supports markdown.