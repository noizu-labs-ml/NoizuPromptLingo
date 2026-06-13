---
id: US-041
title: "View CI/CD pipeline status per project"
personas: [maya-chen]
domain: cicd
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want to view CI/CD pipeline status for each project with pass/fail/running indicators so that I can monitor build health without leaving my unified workspace.

## Acceptance Criteria

- [ ] Pipeline status (pass, fail, running, queued) displays per-project in a summary view with color-coded indicators
- [ ] Clicking a pipeline entry expands to show stage-level breakdown (build, test, deploy) with individual durations
- [ ] Status auto-refreshes via WebSocket or polling (configurable interval, default 30s) without full page reload
- [ ] Keyboard shortcut (e.g., `g p`) navigates directly to pipeline view from any screen
- [ ] Failed pipelines surface in the unified "Today" view as actionable items with one-click navigation to logs

## Notes

Pipeline data ingested via provider adapters (GitHub Actions, GitLab CI, etc.) through the MCP integration layer. The view should respect the scale-free model — a pipeline run is itself an item that can be linked, commented on, or promoted to an incident. Dark mode must render status colors with sufficient contrast (WCAG AA).
