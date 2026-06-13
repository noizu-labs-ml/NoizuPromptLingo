# Project Architecture Summary — codefre.sh

## Overview

CodeFresh (`codefre.sh`, NOIZUAI-24) is a behavioral testing framework for AI agents. Conversation scripts are directed graphs with per-node prompts, expectations, and branches. When an agent deviates from all declared branches, the Freeball Protocol hands control to a secondary LLM that improvises follow-up prompts and generates tentative expectations on the fly. Status: active backend implementation — Stages 0–4 shipped (157+ tests green), Stages 5–6 in flight.

Positioning: Playwright for agents. Not observability (Arize, LangSmith), not single-turn compare (Promptfoo), not assertion-style eval (DeepEval).

## Core Components

- **Script Editor** — visual graph editor (GraphCanvas, NodeInspector, NodePalette); YAML/JSON import/export
- **Agent Connector** — 6 adapters (OpenAI, Anthropic, LangChain, HTTP, Bedrock, Vertex) behind `Adapter` behaviour
- **Evaluation Runner** — executes scripts; parallel persona fan-out; streaming (in flight)
- **Freeball Engine** — script runner LLM for off-script deviations; generates tentative nodes (in flight)
- **Scorer** — LLM-as-judge + rubric hybrid for fuzzy expectation matching (in flight)
- **Results Dashboard** — graph visualization, per-node scoring, aggregate metrics, diff view (in flight)
- **CLI** — Elixir escript: login, logout, whoami, run, runs, import, export; JUnit XML output
- **Persona Library** — tag-based lens layering (broken-english, hostile, adversarial, etc.) with starter library
- **Datasets** — versioned eval datasets with entries and flagged captures
- **Autoflag Engine** — rule-based auto-flagging with Oban workers
- **Review Queue** — branch promotion workflow for freeball nodes → permanent script versions
- **Webhooks** — event delivery with Redis-backed DLQ
- **OTel Ingest** — OTLP-shaped span/log ingest with sampling policies; TimescaleDB hypertables
- **Client SDKs** — Python, Elixir, TypeScript API clients (all v0.1.0 stubs)
- **Marketing Site** — public landing page with waitlist, interactive graph demo (Next.js 16, separate from app)

## Data Model

Primary entities: Script, ScriptNode, ScriptEdge, Expectation, Agent, AgentVersion, Persona, PersonaVersion, Prompt, PromptVersion, Rubric, RubricVersion, Dataset, DatasetVersion, DatasetEntry, Dashboard, DashboardVersion, Run, RunStep, RunPersona, FreeballNode, FreeballExpectation, Webhook, WebhookDelivery, ReviewItem, BranchPromotion, SsoConfig, SamplingPolicy. Copy-on-write versioning: head rows + immutable version rows with checksum-based dedup. Scripts normalized as nodes + edges. 54 migrations as of current build.

## Evaluation Flow

1. Runner sends node prompt (persona-mutated) to target agent
2. Response matched against declared branches with confidence scores
3. If match confidence ≥ threshold → traverse to child; else → Freeball Protocol
4. Freeball: script runner LLM improvises next prompt + expectations; path marked tentative
5. Per-step scoring; run-level aggregate; CI gate on threshold

## Infrastructure

Three Docker containers (Next.js frontend, Phoenix backend, nginx proxy) on the incubator's shared `lets-go_default` network with external Postgres and Redis. JWT auth via Guardian; YAML design system via `@the-robot-lives/styleguide`. Kubernetes deployment via Helm chart (v0.1.0, appVersion 1.0.6) with nginx-class ingress, Cloudflare-only access, TLS via Infisical sync. CI/CD via GitHub Actions: format check, compile warnings, test + cover, credo strict, OpenAPI breaking-change detection, rollback-check. Separate marketing site (`web/`, Next.js 16) independent of authenticated app.

## Technology Stack

Next.js 15 + React 19 + Tailwind v4 frontend; Phoenix 1.8 + Bandit backend (Elixir 1.19 / OTP 28); PostgreSQL with pgvector + TimescaleDB; Weaviate for large-scale semantic search; Redis for run queue, streaming, rate limits, webhook DLQ; Oban 2.17 for background jobs; Syn 3.3 for process registry; Guardian JWT + bcrypt auth; GenAI ~> 0.3.0 + Noizu Labs Entities for LLM integration; OpenAPI via open_api_spex; configurable judge models (Haiku-tier for freeball generation, Sonnet-tier for scoring).

## Key Decisions

- Graph-based, not linear — real conversations branch
- Freeball over fail-fast — deviations are data, not errors
- Hybrid LLM-as-judge + rubric scoring (per-expectation config)
- Personas as tag layers multiplying coverage without duplicating scripts
- Elixir backend for OTP-based run fan-out and process-per-run isolation
- Open-core: CLI + runner OSS, editor + freeball + dashboard SaaS
- Scripts as YAML/JSON — diffable in PRs, editor is authoring surface only

## Open Questions

Scoring model for fuzzy matching (hybrid assumed); runner model selection and capability-matching; prompt-injection defense for the runner; marketplace vs. private scripts; OSS/SaaS boundary.

## Status & Next Steps

Stages 0–4 shipped: foundations, prompts, rubrics, personas, scripts+graph, agents. CLI, SDKs, Helm chart, and marketing site scaffolded. In flight: Stage 5 (evaluation runner, freeball engine, scorer) and Stage 6 (results dashboard, CI gates). Next: dataset-driven evals, autoflag rules, webhook reliability, enterprise SSO, CLI/SDK maturity.
