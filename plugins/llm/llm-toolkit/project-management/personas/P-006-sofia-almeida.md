---
id: P-006
name: "Sofia Almeida"
slug: sofia-almeida
archetype: "OSS maintainer"
segment: tertiary
tags: [oss, runbooks, operations, multi-project, documentation]
---

# P-006: Sofia Almeida

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 31 |
| Occupation | Maintainer of two mid-size open-source libraries (day job elsewhere) |
| Location | São Paulo, Brazil |
| Tech comfort | high |
| Claude Code usage | Nights/weekends, across many small contributor-facing repos |
| Primary interface | Web UI (Thread Viewer, Convert) + CLI for quick lookups |

## Bio
Sofia maintains her OSS projects in spare hours squeezed between a day job and contributor triage. She uses Claude Code constantly to work through gnarly issues reported by strangers on GitHub, and increasingly those debugging sessions are the best raw material she has for troubleshooting docs — if she can find and reshape them fast, between other obligations.

## Goals
- Turn a Claude Code session that resolved a tricky reported issue into a troubleshooting doc she can link from the GitHub issue and drop into project docs
- Keep conversations organized as her project directory structure evolves (repos get renamed, forked, or reorganized)
- Work efficiently in short bursts — she doesn't have long uninterrupted sessions to spend curating

## Frustrations
- When a repo gets renamed or moved locally, the corresponding Claude Code JSONL directory becomes orphaned under the old encoded path
- Contributor issues often require exploring multiple false leads before the real fix — the useful thread is buried in a much longer, messier conversation
- Limited time means she needs a fast round-trip from "found the relevant conversation" to "published doc snippet," not a multi-day workflow

## Behaviors
- Uses `rehome` to move a conversation's JSONL file to the correct project directory after reorganizing a repo, keeping the index consistent
- Archives conversations from abandoned investigation branches so they stop cluttering `/browse`
- Leans on the Convert wizard's runbook type specifically — she wants step-by-step reproducible docs, not agent definitions
- Clones a conversation before heavily editing it, so she keeps an untouched copy alongside the trimmed public-facing version

## Job to Be Done
> "When a contributor's obscure bug report turns into a 45-minute debugging session that finally nails the root cause, I want to convert just the diagnostic steps into a runbook, so I can paste a clean fix guide into the GitHub issue instead of retyping it from memory."

## Relationship to Product
Claude Assist is her bridge from private debugging sessions to public-facing OSS documentation — she relies on its operations (rehome, archive, clone) to keep a sprawling multi-repo index tidy, and on Convert to turn debugging effort into shareable artifacts quickly.

## Scenarios
- **Scenario 1: Repo reorg cleanup** — After renaming a local clone, uses `POST /api/conversations/:id/rehome` to move the affected sessions' JSONL files to the new project directory so they still show up correctly grouped in `/browse`.
- **Scenario 2: Issue-to-runbook** — Finds the thread that solved a reported bug via keyword search, opens Convert, selects "Runbook," and exports a step-by-step doc to paste into the GitHub issue thread.
- **Scenario 3: Safe editing** — Clones a long investigation thread before trimming it down in the editor, so the original with all false leads stays intact for her own future reference.
