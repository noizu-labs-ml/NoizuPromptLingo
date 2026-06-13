---
id: US-136
title: TAP and Allure output formats from CLI
issue_type: story
slug: cli-tap-allure-formats
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
  - reports
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
  - US-083
dependencies:
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

# TAP and Allure output formats from CLI

## Story

As a **Senior ML Engineer**,
I want **`codefresh run --format=tap` and `--format=allure`** so that **my CI with non-JUnit-native reporting tools ingests results natively**.

## Acceptance Criteria

- [ ] `--format=tap` emits TAP 13 output
- [ ] `--format=allure` emits Allure JSON bundle (zip of `results/*.json`)
- [ ] Both formats represent expectations as individual test cases
- [ ] Documentation clearly states which CI systems benefit most from each

## Notes

- TAP is a tiny spec; Allure is heavier but renders richer

## Out of Scope

- xUnit (different XML dialect from JUnit — Wave 3+)
- HTML report format (Wave 3+)
