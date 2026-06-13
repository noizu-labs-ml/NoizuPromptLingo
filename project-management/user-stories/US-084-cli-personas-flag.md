---
id: US-084
title: Run with --personas flag from the CLI
issue_type: story
slug: cli-personas-flag
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
category: cli-and-cicd
components:
  - cli
labels:
  - wave-2
  - cli
  - personas
assignee: null
reporter: null
epic: mvp-cli
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - derek-support-engineer
  - priya-ml-engineer
secondary_personas:
  - yuki-red-teamer
related_stories:
  - US-037
  - US-052
dependencies:
  - US-037
  - US-052
blocks: []
duplicates: []
schema_refs: []
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Run with --personas flag from the CLI

## Story

As a **Support Automation Engineer**,
I want **`codefresh run script.yaml --personas=broken-english,hostile,confused-novice`** so that **CI gates my agent against all my policy-critical personas in one command**.

## Acceptance Criteria

- [ ] `--personas=<comma-list>` accepts org-slug form (resolves to latest version of each)
- [ ] `--personas=@<file>` accepts a newline-delimited list file
- [ ] Resolution failure on any slug aborts before trigger with a clear error
- [ ] Output streams per-persona verdict to stdout as each persona stream terminates
- [ ] Overall exit code follows run-level verdict (US-038) aggregated across personas

## Notes

- Mirrors fan-out from US-052 at the CLI layer
- Large persona counts should stream results progressively to stdout (not buffer entire output)

## Out of Scope

- Parallel persona selection from remote registry (Wave 3)
- Persona priority / ordering (CLI runs all in parallel)
