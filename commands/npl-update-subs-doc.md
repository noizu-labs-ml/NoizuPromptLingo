# SUBS.md — Maintenance Guide

## Purpose

`docs/SUBS.md` maps the repo's **git submodules and subtrees**: path, purpose, stack, and coupling (which other modules it depends on or interacts with). It lets agents and developers answer "where does X live and what does it touch" without opening each repo.

It **supersedes** the "Registered submodule index" table in `Portfolio/OVERVIEW.md` — do not double-maintain that table; OVERVIEW keeps placement policy only.

## Structure

```
docs/
├── SUBS.md               # Main submodule map (grouped tables)
└── SUBS.summary.md       # One-line-per-group index for agents
```

## Sources of Truth

Unlike PROJ-LAYOUT (directory scan), submodule data comes from git metadata:

```bash
git config -f .gitmodules --get-regexp 'submodule\..*\.path'   # registered set
git submodule status                                            # SHA + drift + missing
```

Then enrich each entry with: purpose/stack (repo README, `mix.exs`/`package.json` presence) and coupling (evidence sources below).

## Content Schema

Per module:

| Field | Rule |
|------|------|
| Path | As registered in `.gitmodules`, relative to repo root |
| Purpose | One concise phrase — what it is, not how it works |
| Stack | Only when obvious (Elixir / Next.js / Rust / Swift / static / MCP) |
| Coupling | Other submodules/subtrees it depends on or interacts with. Mark **(D)** documented (OVERVIEW.md, `.infra-config.yaml`, docs/) vs **(I)** inferred |

Group tables by top-level area (Apps, WebApps, Libs, Utilities, Games/…, repo-root subtrees). Maintain the **coupling clusters** list at the top (e.g. NPL ecosystem, Libs→apps, Utilities↔terraform) — these are the high-value navigation hints.

Known-coupling evidence sources, in priority order: `.infra-config.yaml` (shared namespaces/tiers/liquibase targets), `Portfolio/OVERVIEW.md`, `docs/arch/*`, repo READMEs, path/name heuristics (last resort, always (I)).

## Size Limits

| Location | Target Size | Action When Exceeded |
|----------|-------------|----------------------|
| SUBS.md | < 250 lines | Split group tables to `subs/{group}.md`, leave group + summary row |
| Purpose text | 1 line | Details belong in the module's own README |
| Coupling column | ≤ 4 targets | Link to a cluster instead of enumerating |

## When to Update

Run this maintenance pass when any of:

1. `.gitmodules` changed (added/removed/renamed submodule, nested Libs entries)
2. A module's purpose/stack changed materially (graduation, rename, archive)
3. New coupling discovered or documented (reclassify (I) → (D) with source)
4. `git submodule status` shows drift vs this doc (missing, unregistered-on-disk entries)

## Update Process

1. Diff `.gitmodules` + `git submodule status` against current SUBS.md tables.
2. Add/remove/rename rows; keep one-line purposes; never paste README prose.
3. Reclassify coupling with evidence; keep (D)/(I) markers honest.
4. Regenerate `SUBS.summary.md`: one line per group, names in parens — no coupling detail.
5. Check OVERVIEW.md index table hasn't been re-grown; SUBS.md is the index.

## Summary File Sync

`docs/SUBS.summary.md` is the companion quick-reference for agents:

- One bullet per group; module names inline; no paths repeated per-module, no coupling
- Must stay in sync structurally — any group added/renamed in SUBS.md mirrors here
- Delete entries when modules are removed

## Maintenance Checklist

- [ ] Tables match `.gitmodules` (count + paths); drift noted for unregistered-on-disk repos
- [ ] `SUBS.summary.md` in sync
- [ ] Every row has purpose; coupling marked (D)/(I)
- [ ] Coupling clusters list current
- [ ] No duplication with OVERVIEW.md placement policy or index table
