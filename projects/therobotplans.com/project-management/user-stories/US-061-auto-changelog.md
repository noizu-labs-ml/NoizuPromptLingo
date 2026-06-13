---
id: US-061
title: "Auto-generate changelog from commits and linked items"
personas: [maya-chen]
domain: docs
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want changelogs to be auto-generated from my commits and linked work items so that I can ship release notes without manual bookkeeping.

## Acceptance Criteria

- [ ] System parses conventional commit messages and groups entries by type (feat, fix, chore, docs)
- [ ] Linked items (tasks, bugs, epics) are resolved and included as context in each changelog entry
- [ ] Generated changelog is editable before publish, with AI-suggested rewrites for user-facing clarity
- [ ] Changelog output supports Markdown export and in-app wiki page creation
- [ ] Incremental generation: only new commits since last changelog are processed

## Notes

Should integrate with the scale-free item model so that a commit linked to a todo, bug, or epic all surface identically. Consider supporting both repo-level and project-level changelogs for multi-repo setups. Keyboard shortcut to trigger generation fits Maya's keyboard-first workflow.
