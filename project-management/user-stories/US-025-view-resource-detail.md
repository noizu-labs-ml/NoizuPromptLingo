---
id: US-025
title: "View Resource Detail with Metadata"
slug: "view-resource-detail"
personas: [P-001, P-002, P-003, P-004, P-005]
epic: "Resources - Basic"
priority: "must-have"
complexity: "S"
tags: [resources, metadata, viewing]
---

# US-025: View Resource Detail with Metadata

## User Story

**As a** Curious Lurker (P-004),
**I want to** view a resource's detail page with full metadata and content,
**So that** I can understand its purpose, version history, and creator before deciding to use it.

## Acceptance Criteria

- [ ] Given any user, when they click on a resource, then they see the resource's name, description, type (Prompt/Skill/MCP Config), current version, owner, creation date, and last updated timestamp
- [ ] Given a user views a resource detail, when they scroll to the content section, then the full markdown-rendered content is displayed with syntax highlighting for code blocks
- [ ] Given a user views a resource detail, when they view the metadata section, then they see custom tags, model compatibility (if applicable), and space attachments list
- [ ] Given a user is not the resource owner, when they view the detail page, then they see "Copy Content" and "Fork" buttons but no edit/delete controls
- [ ] Given a user is the resource owner, when they view the detail page, then they see "Edit", "New Version", and "Delete" buttons in addition to everyone else's controls

## Notes

Depends on US-023 for resource creation. Forking creates a new resource owned by the forker (not covered in this story). Version history shows only current version in MVP (full history in future). Metadata is searchable (see separate search story if added).