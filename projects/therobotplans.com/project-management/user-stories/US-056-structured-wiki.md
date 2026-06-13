---
id: US-056
title: "Create structured wiki with hierarchy and version history"
personas: [sarah-kim]
domain: docs
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want to create structured wiki pages with hierarchy, cross-linking, and version history so that my team has a single knowledge base that lives alongside their work.

## Acceptance Criteria

- [ ] Wiki pages support Markdown with a hierarchical structure (parent/child pages) navigable via a sidebar tree
- [ ] Cross-linking between wiki pages uses a `[[page-title]]` syntax with autocomplete; links to items, incidents, and other entities use `[[US-041]]` style references
- [ ] Every edit creates a version with diff view, author attribution, and optional edit summary; any version can be restored
- [ ] Wiki pages are searchable with full-text search and the agent can answer questions by referencing wiki content ("what's our deploy process?" draws from the wiki)
- [ ] Permissions are configurable per page or subtree — public to org, team-only, or private draft

## Notes

In the scale-free model, a wiki page is itself an item — it can be assigned for review, linked to sprints, and have sub-tasks. This means wiki maintenance becomes visible work, not invisible overhead. The agent should be able to suggest wiki pages that need updating based on recent changes to linked items or code. Consider supporting wiki templates for common page types (onboarding, service overview, meeting notes).
