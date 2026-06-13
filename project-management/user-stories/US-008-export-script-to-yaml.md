---
id: US-008
title: Export a script to YAML
issue_type: story
slug: export-script-to-yaml
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: script-authoring
components:
  - backend
  - frontend
  - cli
labels:
  - mvp
  - wave-1
  - authoring
  - yaml
  - oss
assignee: null
reporter: null
epic: mvp-authoring
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - alex-oss-maintainer
  - nia-academic
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-007
  - US-037
dependencies:
  - US-006
blocks:
  - US-037
duplicates: []
schema_refs:
  - prompt_versions
  - prompts
  - script_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Export a script to YAML

## Story

As an **OSS Framework Maintainer**,
I want to **export any published script version to YAML**
so that **I can commit it to git, share it with users, and reproduce runs offline**.

## Acceptance Criteria

- [ ] Editor exposes a "Download YAML" action on the script version detail
- [ ] CLI supports `codefresh export <script-slug>@<version> --out=<file>`
- [ ] YAML output matches the canonical form stored in `script_versions.yaml_source`
- [ ] Export includes referenced prompts, personas, rubrics by slug + version (not deep-copied)
- [ ] Checksum of the re-imported export equals the original checksum (round-trip is lossless)

## Notes

- Round-trip equivalence is a load-bearing invariant for the OSS workflow and academic reproducibility

## Out of Scope

- Deep-copy export that inlines referenced entities (Wave 3 — `codefresh bundle`)
- JSON export format (Wave 2)
