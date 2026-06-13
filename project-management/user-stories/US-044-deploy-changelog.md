---
id: US-044
title: "Auto-generate deploy changelogs from linked items"
personas: [maya-chen]
domain: cicd
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want deploy changelogs to be auto-generated from linked items and commits so that I have a clear record of what shipped without manually writing release notes.

## Acceptance Criteria

- [ ] On each deploy, a changelog is generated listing all linked items (with title, ID, and type) grouped by category (feature, fix, chore, etc.)
- [ ] Commit messages between the previous and current deploy SHA are included, de-duplicated against linked items
- [ ] Changelog format is configurable (Markdown, plain text, or structured JSON) and can be exported or copied
- [ ] An agent can enrich the raw changelog with human-readable summaries — transforming commit-speak into user-facing release notes
- [ ] Changelogs are stored as items themselves, linked to the deploy item, and searchable in the wiki/docs system

## Notes

The changelog generator should handle the common case where a solo dev doesn't meticulously link every commit to an item — it falls back to commit message parsing with conventional-commit awareness. For team use, changelogs should attribute changes to team members. Consider a "draft changelog" that appears before deploy for review.
