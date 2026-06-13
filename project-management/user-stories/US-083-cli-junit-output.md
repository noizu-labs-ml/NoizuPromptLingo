---
id: US-083
title: Emit JUnit XML from the CLI
issue_type: story
slug: cli-junit-output
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
  - cicd
  - reports
assignee: null
reporter: null
epic: mvp-cli
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas:
  - marcus-qa-lead
related_stories:
  - US-037
  - US-038
  - US-085
dependencies:
  - US-037
  - US-019
blocks:
  - US-085
  - US-086
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

# Emit JUnit XML from the CLI

## Story

As a **Senior ML Engineer**,
I want **`codefresh run --format=junit` to emit a JUnit XML report**
so that **CI systems like GitHub Actions, GitLab, Jenkins, and CircleCI render results as a familiar test matrix without custom plumbing**.

## Acceptance Criteria

- [ ] `--format=junit` flag writes a JUnit XML doc to `--out=<path>` or stdout
- [ ] Each expectation becomes one `<testcase>` with classname = script node, name = expectation label
- [ ] Failed / warn expectations include `<failure>` / `<skipped>` elements with rationale text
- [ ] Run-level summary mirrored in `<testsuite>` attributes (tests, failures, time)
- [ ] Persona fan-out runs emit one `<testsuite>` per persona

## Notes

- Format is the widely supported JUnit v4 subset; avoid vendor-specific extensions
- XML escaping tested on agent messages that contain `<`, `>`, `&`, quotes

## Out of Scope

- TAP format (Wave 3)
- Allure format (Wave 3)
- Native GitHub annotations (US-085 covers Actions-specific formatting)
