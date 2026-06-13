---
id: US-135
title: CLI watch mode for file changes
issue_type: story
slug: cli-watch-mode
status: in-progress
priority: P3
story_points: 3
estimated_scope: S
category: cli-and-cicd
components:
  - cli
labels:
  - wave-3
  - cli
  - developer-experience
  - stretch
assignee: null
reporter: null
epic: mvp-cli
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas: [] 
related_stories:
  - US-037
dependencies:
  - US-037
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

# CLI watch mode for file changes

## Story

As a **Senior ML Engineer**,
I want to **run `codefresh run script.yaml --watch` and have re-runs auto-trigger when I edit the file or any of its prompt references**
so that **iterating on prompts locally has a tight feedback loop without manual re-invocation**.

## Acceptance Criteria

- [ ] `--watch` flag subscribes to file changes on the script YAML + referenced prompt files
- [ ] Debounces: 500ms after last change before triggering
- [ ] Displays "waiting for changes..." between runs; Ctrl+C cleanly exits
- [ ] Run cost accumulated in the watch session, displayed after each run
- [ ] Optional `--watch-agent-config` also reruns when agent config changes

## Notes

- Cost-risk feature: warn user when session cost crosses $10 with "continue watching? y/n"

## Out of Scope

- Remote watch mode (watching a git branch) — Wave 3+
