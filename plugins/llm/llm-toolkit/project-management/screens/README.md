# Screens Index

Extracted from `project-management/user-stories/` (100 stories), `design/SITEMAP.md`, `design/style-guide.md`, and the shipped source (`packages/web/src`, `packages/cli/src`, `skill-manage/src/tui`). Covers all three product surfaces: the web app, the CLI's Ink interactive TUI, and skill-manage's ratatui TUI, plus one-shot CLI command output that isn't part of either interactive surface.

**Total: 43 screens**

## By Surface

| Surface | Count | Description |
|---------|-------|-------------|
| `web` | 15 | `packages/web/src` React app (React Router) |
| `macos` | 1 | Native SwiftUI host that loads the web console (`apps/macos`) |
| `cli-ink` | 14 | `packages/cli/src/interactive` full-screen Ink TUI (`llm-toolkit interactive`) |
| `cli-command` | 8 | One-shot Ink/plain commands with no persistent screen (`recent`, `search`, `list`, `show`, `index`, install/first-run, skill-manage `audit`/`context`) |
| `tui-ratatui` | 5 | `skill-manage/src/tui` ratatui interface (`skill-manage tui`) |

## By Category

| Category | Screens |
|----------|---------|
| Discovery | SCR-01, SCR-16 |
| Discovery / Admin | SCR-02, SCR-03, SCR-17, SCR-18 |
| Core | SCR-04, SCR-05, SCR-06, SCR-07, SCR-08, SCR-09, SCR-10, SCR-11, SCR-19, SCR-20, SCR-21, SCR-22, SCR-23, SCR-24, SCR-25, SCR-30, SCR-31, SCR-32, SCR-33 |
| Admin | SCR-12, SCR-13, SCR-26, SCR-29 |
| Onboarding / Core | SCR-14, SCR-27 |
| Internal / Meta | SCR-15, SCR-28 |
| Desktop | SCR-43 |
| Indexing & Ingestion | SCR-34 |
| Onboarding | SCR-35 |
| skill-manage (core) | SCR-36, SCR-37, SCR-38, SCR-40 |
| skill-manage (audit) | SCR-39, SCR-41, SCR-42 |

## By Type

| Type | When Used | Count | Screens |
|------|-----------|-------|---------|
| `primary` | Main feature screens, most important views | 29 | SCR-01, 03, 04, 05, 07, 08, 10, 11, 15, 16, 17, 18, 19, 20, 21, 23, 24, 25, 28, 30, 31, 32, 33, 34, 36, 37, 41, 42, 43 |
| `dashboard` | Data overview screens, home screens | 4 | SCR-02, 09, 13, 29 |
| `settings` | Configuration, preferences | 4 | SCR-12, 14, 26, 27 |
| `modal` | Overlays, dialogs, drawers | 3 | SCR-38, 39, 40 |
| `storyboard` | Multi-step flows (wizards) | 3 | SCR-06, 22, 35 |

## Reconciliation Notes (SITEMAP.md vs. shipped code)

`design/SITEMAP.md` is the original draft IA (10 web routes). The shipped `packages/web/src/App.tsx` has diverged from it in several concrete ways, reconciled here rather than silently overwritten:

1. **Dashboard + Search + Browse merged into one screen.** All three of SITEMAP's `/`, `/search`, `/browse` routes render the same `Explore` component (`packages/web/src/App.tsx:24-26`). `Dashboard.tsx`, `Search.tsx`, and `Browse.tsx` still exist as files under `packages/web/src/pages/` but are **not imported anywhere** — dead code superseded by `Explore.tsx`. Documented as SCR-01.
2. **`/merge` has no route.** No `Merge.tsx` page exists and `App.tsx` defines no `/merge` route, despite US-066/US-068 depending on it and SITEMAP specifying a full component tree for it. Documented as SCR-08, flagged `status: planned-not-implemented`.
3. **Seven routed pages exist that SITEMAP never specified**: `/safety-watch`, `/thread/:id/continue`, `/prompts`, `/tags`, `/projects`, `/projects/:slug`, `/style-guides(/:slug)`. Documented as SCR-02, SCR-03, SCR-07, SCR-11, SCR-12, SCR-13, SCR-15 — all backed by real, routed page components with real API/service calls (`SafetyWatch.tsx` is an explicit in-code "Monitoring stub").
4. **The Onboarding & Install epic (US-001, US-002, US-006, US-007, US-008, US-009) has no dedicated onboarding UI.** `packages/cli/bin.ts` implements only a transparent `ensureApi()` auto-start; there is no `init` subcommand, wizard, or health-check output. Documented as SCR-35 with shipped-vs-planned scope called out explicitly.

## Non-UI / Backend-Only Stories

A handful of `must-have`/`should-have` stories describe backend or infrastructure properties with no dedicated screen, because there is nothing to render — they're referenced from the screen(s) whose behavior they underpin instead of getting their own file:

| Story | What it covers | Where it surfaces |
|-------|-----------------|--------------------|
| US-010, US-011 | Real-time file watcher, incremental re-index | Background service; effect visible via IndexStatus (CMP-33) on SCR-01/14/16/27 |
| US-014 | Malformed JSONL line handling | Background parsing; effect visible as skipped-message notices on SCR-04/19 |
| US-015 | Fully local indexing and search | Cross-cutting architecture property; stated explicitly on SCR-14/27 (Local-only statement) |
| US-088 | Hono API core endpoints | Backend API surface underlying every screen's data calls |
| US-089, US-090 | Dataset export API, rehome-via-API | API surfaces underlying SCR-10 export controls and SCR-03/04 rehome actions |
| US-091 | API bound to localhost, no unauth remote access | Security property, not user-facing UI |
| US-092, US-093 | Event stream (wont-have), harness import stub (wont-have) | Lowest priority; US-093 is additionally referenced on SCR-07/20 (stubbed transfer targets) |
| US-098 | Low idle resource usage for watcher | Background service characteristic; referenced on SCR-14/27 |

## Screen Type Legend

| Type | When to Use |
|------|------------|
| `primary` | Main feature screens, most important views |
| `dashboard` | Data overview screens, home screens |
| `settings` | Configuration, preferences, profile |
| `modal` | Overlays, dialogs, drawers |
| `storyboard` | Multi-step flows (onboarding, wizards) |

See `project-management/screens/index.yaml` for the machine-readable index (id, surface, type, category, file, linked user stories).
