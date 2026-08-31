# 35: CLI Install & First-Run Setup

| Field | Value |
|-------|-------|
| ID | SCR-35 |
| Surface | cli-command |
| Type | storyboard |
| Category | Onboarding |
| Route / Entry | package install (`npm install`) → first `llm-toolkit <command>` invocation |
| Primary Personas | P-001, P-007, P-008 |
| User Stories | US-001, US-002, US-006, US-007, US-008, US-009 |

## Description
The end-to-end path from "install the tool" to "first usable index," spanning package install, implicit API bootstrap, and (per the product's onboarding epic) an intended guided setup for embedding-model and index-path configuration. This screen file documents both what ships today and what the Onboarding & Install epic still expects.

## Entry Points
- `npm install` (or equivalent) followed by any `llm-toolkit` invocation

## Key Components (shipped today)
- `ensureApi()` bootstrap — the first command that needs the API (`search`, `list`, `show`, `interactive`, `serve`, etc.) transparently starts the API server if it isn't already running, printing `Started API server on http://localhost:3100` to stderr
- `llm-toolkit recent` — works standalone against the local DB with no API/server dependency at all, usable immediately after install

## Key Components (planned, per Onboarding & Install epic — not yet found in `packages/cli/src`)
- Guided first-run indexing wizard (US-002) — no dedicated `init` subcommand or wizard flow exists in `bin.ts`/`app.tsx` today
- Embedding-model configuration prompt on first run (US-006) — currently only reachable via Settings (SCR-14/27) after the fact, not prompted proactively
- Explicit `llm-toolkit init` command that bootstraps config (US-007) — not present in the command switch (`search | list | show | index | serve | interactive | help`)
- Post-install health check (US-008) — no health-check command/output found
- Defer-indexing prompt for large existing histories (US-009) — indexing behavior on first run is not gated by a size-aware prompt in the current code

## States
- **Today:** first real command auto-starts the API silently/transparently; `recent` needs nothing at all
- **Planned:** an explicit onboarding wizard step between install and first productive use

## Interactions
- Today: none — onboarding is implicit in "run a command"
- Planned: wizard would prompt for watched paths, embedding provider, and defer-vs-index-now for large histories, then hand off to Settings (SCR-14/27) for anything not covered

## Navigation
- **From:** shell (post-install)
- **To:** SCR-16 CLI Explore / SCR-01 Web Explore (first productive screen), SCR-27/14 Settings (deferred configuration)

## Reconciliation Note
US-001, US-002, US-006, US-007, US-008, and US-009 (epic "Onboarding & Install," several `must-have`) describe an explicit guided first-run experience. The current CLI entry point (`packages/cli/bin.ts`, `packages/cli/src/app.tsx`) has no `init` command, no wizard, and no health-check output — the only first-run behavior implemented is the transparent `ensureApi()` auto-start. This screen is documented to keep those stories traceable per the validation checklist, with shipped vs. planned scope called out explicitly rather than presented as one finished flow.
