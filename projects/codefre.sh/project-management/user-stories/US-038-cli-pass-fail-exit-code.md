---
id: US-038
title: Get a pass/fail exit code from the CLI
issue_type: story
slug: cli-pass-fail-exit-code
status: in-progress
priority: P0
story_points: 2
estimated_scope: XS
category: cli-and-cicd
components:
  - cli
labels:
  - mvp
  - wave-1
  - cli
  - cicd
assignee: null
reporter: null
epic: mvp-cli
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas: []
related_stories:
  - US-037
  - US-019
dependencies:
  - US-037
  - US-019
blocks: []
duplicates: []
schema_refs:
  - api_tokens
  - runs
  - scores
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Get a pass/fail exit code from the CLI

## Story

As a **Senior ML Engineer**,
I want **`codefresh run` to exit with 0 on PASS and non-zero on WARN/FAIL**
so that **CI pipelines can gate merges on it without custom parsing**.

## Acceptance Criteria

- [ ] Exit 0 when run verdict is PASS (per US-019)
- [ ] Exit 1 when verdict is FAIL
- [ ] Exit 2 when verdict is WARN (distinguishable; CI config chooses whether to treat as blocking)
- [ ] Exit 10 on run-execution errors (network, auth, invalid YAML) — distinct from test-failure exits
- [ ] `--threshold=<0-1>` override of default 0.85 threshold
- [ ] `--fail-on-warn` flag promotes WARN to exit 1

## Notes

- Exit codes must be stable and documented — CI configs depend on them
- `--fail-on-warn` default off so freeball-heavy runs don't block builds by default

## Out of Scope

- JUnit XML output (Wave 2, US-041 candidate)
- GitHub Actions annotations (Wave 2)
