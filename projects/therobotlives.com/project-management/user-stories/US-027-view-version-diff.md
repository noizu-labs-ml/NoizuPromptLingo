---
id: US-027
title: "View Version History and Diff"
slug: "view-version-diff"
personas: [P-001, P-005]
epic: "Resources - Advanced Versioning"
priority: "must-have"
complexity: "M"
tags: [resources, versioning, ux]
---

# US-027: View Version History and Diff

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** view the version history of a resource and diff between any two versions,
**So that** I can understand how the resource evolved and compare changes across iterations.

## Acceptance Criteria

- [ ] Given a resource with multiple versions, when I view the version history, then I see a list of all versions with timestamps, version numbers, and changelog summaries
- [ ] Given a resource with multiple versions, when I select two versions to compare, then I see a side-by-side diff highlighting added, removed, and modified content
- [ ] Given a version history, when I hover over a version entry, then I see a quick preview of the changelog
- [ ] Given a diff view, when I click on a changed line, then I can jump to that section in the original version

## Notes

Diff syntax highlighting should support resources type (e.g., Python for MCP configs, markdown for prompts). Diff view should handle large files efficiently (lazy loading).