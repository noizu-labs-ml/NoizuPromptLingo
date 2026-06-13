# Architecture Summary

## Overview
NoizuRPG is a composable Python framework for AI-powered RPGs with six independent components. Currently consists of a Next.js 16 landing site and design explorations; the Python framework is pre-development.

## Components
- **Landing Site** — Next.js 16 + React 19 + Tailwind 4 marketing site with waitlist form (implemented)
- **Design System** — Three visual direction explorations + SVG logo suite (implemented)
- **Character System** — Stats, inventory, relationships, knowledge (planned v0.1)
- **World State Manager** — Locations, factions, timeline, world rules (planned v0.1)
- **Narrative Engine** — Context assembly, LLM calls, event parsing, validation (planned v0.1)
- **Quest Engine** — Quest templates, procedural generation, state machines (planned v0.2)
- **Dialogue Manager** — NPC voice profiles, knowledge boundaries, disposition (planned v0.2)
- **Memory System** — Event journal, compression, retrieval (planned v0.1)
- **LLM Provider Interface** — Unified async interface for OpenAI, Anthropic, Ollama (planned v0.1)

## Data Flow
Player action -> ContextBuilder assembles token-budgeted prompt from state + memories -> LLM generates prose + structured events -> EventParser extracts typed GameEvents -> Validator checks against world rules -> State mutated -> Events logged to Memory.

## Infrastructure
Landing site: Docker (Next.js build -> nginx) behind Cloudflare TLS on noizurpg.com. Framework: PyPI distribution, SQLite default storage, PostgreSQL/Redis for production, ChromaDB for vector storage.

## Key Decisions
Python-first (ML ecosystem alignment), independent components (use only what you need), events as ground truth (LLM doesn't own state), token-budgeted context (infinite-context RPGs in finite-context LLMs), LLM-agnostic via ModelProvider, open-source core with commercial cloud services.

## Status
Concept / Pre-development. Next step: validate core loop with minimal Character + World + NarrativeEngine + Ollama prototype.
