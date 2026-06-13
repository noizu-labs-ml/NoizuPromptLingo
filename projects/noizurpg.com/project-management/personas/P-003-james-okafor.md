---
id: P-003
name: "Dr. James Okafor"
slug: "james-okafor"
archetype: "The AI Researcher"
segment: "tertiary"
tags: [ml-research, benchmarking, reproducibility, academic, interactive-ai]
---

# Dr. James Okafor — The AI Researcher

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 30–38 |
| **Role** | ML Researcher (Postdoc / Assistant Professor) |
| **Technical Level** | Expert |
| **Industry** | Academia / AI Research |
| **Location** | North America or Europe (university setting) |

## Bio

James researches human-AI interaction and interactive narrative systems, with papers in venues like CHI, AIIDE, and FDG. He builds experimental games not to ship them commercially but to study how players engage with AI-driven characters and how LLM behavior changes across model families. He cares deeply about reproducibility — his experiments must be re-runnable by other researchers — and he's frustrated that most AI game frameworks are too tightly coupled to a single LLM provider or buried in proprietary APIs that disappear when a startup folds.

## Goals

1. Build reproducible experimental game environments with swappable LLM backends
2. Collect structured behavioral data on player-AI interaction for analysis and publication
3. Establish standardized benchmarks for evaluating AI game mechanics across model versions

## Frustrations

1. Most game AI frameworks are not designed for scientific repeatability — they drift with model updates
2. Proprietary game AI tooling produces black-box outputs with no inspection hooks
3. No community standard exists for evaluating AI narrative quality across frameworks or models

## Behaviors

- Builds experiments in Jupyter notebooks backed by Python scripts; version controls everything in Git
- Pins LLM model versions and records prompt templates with experiments
- Uses Ollama or vLLM for local reproducible runs; avoids cloud APIs for controlled experiments
- Publishes code on GitHub alongside papers; expects others to fork and reproduce

## Job to Be Done

> "When I design a study on AI-driven game behavior, I want a framework with observable, inspectable state and swappable LLM backends, so I can run reproducible experiments and publish credible findings."

## Relationship to Product

Discovers NoizuRPG through a cited paper, a GitHub search, or a mention in an AIIDE workshop. Adopts if the components expose clean hooks for logging state transitions and the LLM adapter layer is truly swappable without hidden coupling. High-value features: deterministic seeding, full state serialization, provider-agnostic interfaces. Churns if the framework has undocumented side effects or is too opinionated about game structure to support his experimental designs.

## Scenarios

1. **Controlled Experiment** — Builds identical game sessions backed by GPT-4o and Claude Sonnet, collects player interaction logs, compares narrative coherence scores across model families.
2. **Benchmark Suite** — Publishes a reproducible evaluation harness using NoizuRPG's components to measure NPC dialogue consistency, shared with the AIIDE community as a reference baseline.
