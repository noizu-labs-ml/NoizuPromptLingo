---
id: US-086
title: Publish a GitLab CI template for CodeFresh
issue_type: story
slug: gitlab-ci-template
status: in-progress
priority: P1
story_points: 2
estimated_scope: XS
category: cli-and-cicd
components:
  - cli
  - docs
labels:
  - wave-2
  - cli
  - cicd
  - gitlab
assignee: null
reporter: null
epic: mvp-cli
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas: []
related_stories:
  - US-037
  - US-083
  - US-085
dependencies:
  - US-037
  - US-083
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

# Publish a GitLab CI template for CodeFresh

## Story

As a **Senior ML Engineer**,
I want **a GitLab CI template I can `include:` in my `.gitlab-ci.yml`**
so that **GitLab-native teams can adopt CodeFresh with the same low-friction experience GitHub users get**.

## Acceptance Criteria

- [ ] Published template file (e.g. `codefresh/codefresh-ci@v1`) at a stable URL
- [ ] Template exposes inputs as CI variables (`$CF_SCRIPT`, `$CF_AGENT`, `$CF_THRESHOLD`, etc.)
- [ ] JUnit report published via `artifacts.reports.junit` so GitLab renders the test matrix natively
- [ ] MR comment bot posts failure summary on merge requests

## Notes

- GitLab's include supports remote + project templates; ship both patterns

## Out of Scope

- GitLab custom widget / review-app integrations — Wave 3
- Jenkins shared library — Wave 3 (treat separately if demand emerges)
