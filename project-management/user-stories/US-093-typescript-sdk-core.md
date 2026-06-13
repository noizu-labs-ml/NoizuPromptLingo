---
id: US-093
title: TypeScript SDK core — install, authenticate, trigger runs
issue_type: story
slug: typescript-sdk-core
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: sdks
components:
  - sdk-typescript
  - docs
labels:
  - wave-2
  - sdk
  - typescript
  - oss
assignee: null
reporter: null
epic: post-mvp-sdks
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - alex-oss-maintainer
  - priya-ml-engineer
secondary_personas: []
related_stories:
  - US-091
  - US-094
  - US-096
dependencies:
  - US-096
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

# TypeScript SDK core — install, authenticate, trigger runs

## Story

As an **OSS Framework Maintainer**,
I want to **`npm install @codefresh/sdk` and drive CodeFresh from Node.js or from a browser-side dev tool**
so that **JS-first agent framework authors (LangChain.js, Vercel AI SDK users) have a first-class integration path**.

## Acceptance Criteria

- [ ] Package published to npm as `@codefresh/sdk` (or equivalent)
- [ ] ESM + CJS dual-publish; TypeScript declarations bundled
- [ ] `new Codefresh({ apiToken })` — reads `process.env.CODEFRESH_API_TOKEN` by default
- [ ] Methods: `client.scripts.list()`, `client.scripts.get(slug)`, `client.runs.create({...})`, `client.runs.get(id)`, `client.runs.waitFor(id)`
- [ ] Typed returns via Zod or native TS types; runtime validation available
- [ ] Works in Node 20+ and in edge runtimes (Cloudflare Workers, Vercel Edge) — no Node-only APIs

## Notes

- Use native `fetch` (no axios) to support edge runtimes
- Auto-retry with exponential backoff on rate-limit / 5xx

## Out of Scope

- React hooks for run state (separate `@codefresh/react` package — Wave 3)
- Deno publish target (add later if demand)
