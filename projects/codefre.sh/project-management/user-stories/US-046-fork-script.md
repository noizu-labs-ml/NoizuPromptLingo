---
id: US-046
title: Fork a published script into a new independent head
issue_type: story
slug: fork-script
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
category: script-authoring
components:
  - backend
  - frontend
labels:
  - wave-2
  - authoring
  - versioning
  - oss
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - alex-oss-maintainer
  - nia-academic
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-006
  - US-044
dependencies:
  - US-006
blocks: []
duplicates: []
schema_refs:
  - script_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Fork a published script into a new independent head

## Story

As an **OSS Framework Maintainer**,
I want to **fork a script into a new head with a different name**
so that **I can derive a specialized variant (e.g. "onboarding-enterprise") without polluting the original's version history**.

## Acceptance Criteria

- [ ] "Fork" action on a published script_version creates a new `scripts` head + `script_versions` v1
- [ ] New head requires a new slug; auto-suggests `<original>-fork` with edit
- [ ] Forked v1 has `parent_version_id` pointing to the source published version
- [ ] Fork lineage queryable: "all forks of script X" resolves via `parent_version_id` chain
- [ ] Source script is unaffected

## Notes

- Useful for template libraries Alex maintains for framework users (Wave 2 marketplace foundation)

## Out of Scope

- Cross-org fork (sharing scripts between orgs) — post-MVP
- Merging fork changes back to upstream (Wave 3)
