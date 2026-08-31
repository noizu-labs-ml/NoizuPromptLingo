---
id: P-003
name: "Elena Vasquez"
slug: elena-vasquez
archetype: "ML / fine-tuning engineer"
segment: primary
tags: [core-user, datasets, fine-tuning, semantic-search, export]
---

# P-003: Elena Vasquez

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 29 |
| Occupation | ML Engineer, internal tooling team at a mid-size startup |
| Location | Berlin, Germany |
| Tech comfort | high |
| Claude Code usage | Uses it herself daily; primary interest is mining others' sessions |
| Primary interface | Web UI (Datasets, Search) |

## Bio
Elena is building a fine-tune of a smaller model to replicate the coding-agent behavior her team relies on Claude Code for. She spends most of her Claude Assist time not writing code but curating training examples — hunting for high-quality reasoning traces buried across hundreds of archived conversations.

## Goals
- Assemble a fine-tuning dataset of real multi-turn coding sessions, not synthetic examples
- Rate example quality consistently (gold/silver/bronze) so downstream training can weight or filter examples
- Export in the exact format her training pipeline expects (OpenAI chat format today, may switch to Anthropic format later)

## Frustrations
- Most conversations are mediocre training material — false starts, verbose tool noise, or off-topic detours — and she needs a fast way to separate signal from noise across a large corpus
- Semantic search sometimes surfaces topically similar but low-quality examples that still need manual review before tagging
- Re-exporting a dataset after relabeling a handful of entries used to mean redoing the whole pipeline by hand

## Behaviors
- Runs broad semantic searches ("debugging a race condition," "refactoring for testability") to surface candidate conversations across the whole corpus, not just her own project
- Creates topic-scoped datasets (e.g., "error-handling-patterns") and tags message ranges into them directly from the thread viewer's dataset-tagging mode
- Triages entries in `/datasets/:name` using the quality selector, favoring gold for clean single-pass solutions and bronze for examples with useful mistakes-then-correction arcs
- Re-exports frequently as the dataset grows, checking the gold/silver/bronze stacked-bar breakdown before each export run

## Job to Be Done
> "When I need another 200 clean examples of an agent recovering from a failed test run, I want to semantically search the whole conversation corpus and tag the good ones straight into a dataset, so I don't have to hand-curate transcripts from scratch."

## Relationship to Product
Claude Assist is her dataset-curation pipeline front end — semantic search is her discovery tool, the dataset entry list with quality labels is her labeling workbench, and the export panel is the last step before her training run.

## Scenarios
- **Scenario 1: Corpus mining** — Runs a semantic search across all projects for "recovered from a failing test," reviews the ranked results, and opens promising threads to check quality before tagging.
- **Scenario 2: Quality triage** — In `/datasets/error-handling-patterns`, walks through entries in `EntryPreview`, marking clean single-shot fixes as gold and multi-attempt-but-correct examples as silver.
- **Scenario 3: Pipeline export** — Once a dataset crosses a target entry count, exports via `GET /api/datasets/{name}/export?format=openai` and feeds the JSONL directly into her fine-tuning job.
