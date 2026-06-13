---
id: US-057
title: "Link docs to code so changes flag docs for review"
personas: [maya-chen]
domain: docs
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want documentation linked to code so that code changes automatically flag related docs for review so that my docs stay accurate without me constantly remembering to update them.

## Acceptance Criteria

- [ ] Wiki pages and docs can be linked to specific files, directories, or code symbols (function, class, module) via a link declaration in the doc frontmatter or inline annotation
- [ ] When linked code changes (detected via commit/PR), the associated doc is flagged as "potentially stale" with a summary of what changed
- [ ] Stale-flagged docs appear as review tasks in the author's "Today" view with a diff showing the code changes that triggered the flag
- [ ] The agent can draft suggested doc updates based on the code diff, presented as a proposed edit the author can accept, modify, or dismiss
- [ ] A dashboard shows all code-linked docs with their staleness status, last reviewed date, and coverage gaps (code areas with no linked docs)

## Notes

This addresses the universal problem of docs rotting. The linking mechanism should be lightweight — linking a doc to a directory means any file change in that directory triggers a review flag. For Maya's solo workflow, the agent-drafted updates are the killer feature: she reviews a suggested edit rather than writing from scratch. False positives (cosmetic code changes flagging docs) should be minimized by allowing ignore patterns.
