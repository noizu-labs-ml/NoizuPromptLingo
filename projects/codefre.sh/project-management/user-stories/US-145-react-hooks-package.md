---
id: US-145
title: React hooks package for run state
issue_type: story
slug: react-hooks-package
status: in-progress
priority: P3
story_points: 5
estimated_scope: M
category: sdks
components:
  - sdk-typescript
labels:
  - wave-3
  - sdk
  - react
  - stretch
assignee: null
reporter: null
epic: post-mvp-sdks
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - alex-oss-maintainer
  - priya-ml-engineer
secondary_personas: [] 
related_stories:
  - US-093
dependencies:
  - US-093
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

# React hooks package for run state

## Story

As an **OSS Framework Maintainer**,
I want **a `@codefresh/react` package with hooks like `useRun(id)`, `useRuns(filter)`, `useLiveRun(id)`**
so that **agent-evaluation dashboards inside my users' apps are a handful of hooks rather than a custom state management layer**.

## Acceptance Criteria

- [ ] Package published to npm as `@codefresh/react`
- [ ] Hooks: `useRun`, `useRuns`, `useLiveRun` (streaming), `useRunScores`, `useReviewQueue`
- [ ] Context provider `<CodefreshProvider client={...}>` wires auth
- [ ] SWR-style caching semantics (stale-while-revalidate)
- [ ] TypeScript strict-mode compatible

## Notes

- Built on top of `@codefresh/sdk` (US-093); re-uses typed models

## Out of Scope

- Vue / Svelte packages (demand-driven; Wave 3+)
