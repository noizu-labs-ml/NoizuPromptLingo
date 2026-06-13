---
id: US-085
title: Publish a GitHub Actions reusable workflow for CodeFresh
issue_type: story
slug: github-actions-reusable-workflow
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
category: cli-and-cicd
components:
  - cli
  - docs
labels:
  - wave-2
  - cli
  - cicd
  - github
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
  - US-038
  - US-083
dependencies:
  - US-037
  - US-038
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

# Publish a GitHub Actions reusable workflow for CodeFresh

## Story

As a **Senior ML Engineer**,
I want **a reusable GitHub Actions workflow I can reference as `uses: codefresh/run@v1`**
so that **adopting CodeFresh in CI takes one PR instead of learning the CLI surface first**.

## Acceptance Criteria

- [ ] Published workflow under `codefresh/run@v1` (or equivalent org)
- [ ] Inputs: `script`, `agent`, `personas`, `threshold`, `fail-on-warn`, `org`
- [ ] Uses the CLI under the hood; authenticates via `secrets.CODEFRESH_API_TOKEN`
- [ ] Emits JUnit report and uploads as a workflow artifact
- [ ] On failure, posts a PR comment with run detail link + top-3 failed expectations
- [ ] Tagged-version releases (v1, v1.1, etc.) with semver promise

## Notes

- PR comment requires the `pull_request` event context; document the required permissions block
- Reusable workflow + composite-action variants both published

## Out of Scope

- GitHub App (custom check runs) — Wave 3
- Deploy hooks to trigger runs from GitHub Deployments — Wave 3
