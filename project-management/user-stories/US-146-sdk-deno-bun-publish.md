---
id: US-146
title: SDK publish for Deno and Bun runtimes
issue_type: story
slug: sdk-deno-bun-publish
status: in-progress
priority: P3
story_points: 2
estimated_scope: XS
category: sdks
components:
  - sdk-typescript
labels:
  - wave-3
  - sdk
  - deno
  - bun
  - stretch
assignee: null
reporter: null
epic: post-mvp-sdks
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - alex-oss-maintainer
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

# SDK publish for Deno and Bun runtimes

## Story

As an **OSS Framework Maintainer**,
I want **`@codefresh/sdk` published to JSR for Deno and verified to work on Bun**
so that **users on non-Node TS runtimes aren't second-class citizens**.

## Acceptance Criteria

- [ ] Publish TS SDK to JSR (jsr.io) alongside npm
- [ ] CI test suite runs on Node 20+, Deno 2+, Bun 1+
- [ ] Documentation includes install snippets for all three
- [ ] Verify edge-runtime compatibility (Cloudflare Workers, Vercel Edge) in CI

## Notes

- Low-effort because the TS SDK (US-093) was already built to use native fetch and no Node-only APIs

## Out of Scope

- Platform-specific helpers (e.g. Cloudflare D1 integration) — Wave 3+
