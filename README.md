# IntellectParadox.ai

**Domain:** intellectparadox.ai
**Status:** Concept / Pre-development
**Style:** Nocturne (80%) + Minimal Tech (20%)
**Stack:** Phoenix 1.8 (Elixir) + Next.js 15 + PostgreSQL + Redis + Vector DB

## The Pitch

> Orchestrate AI agent swarms that work like real teams — with roles, accountability, and organizational intelligence.

IntellectParadox.ai is the organizational intelligence layer for AI agent fleets. Where frameworks give you agent primitives and orchestration tools wire them together, IntellectParadox provides **the org chart**: team structure, governance, escalation paths, institutional memory, and cost attribution.

## The Problem

Companies running 10-50+ agents in production hit the same wall: agent sprawl with no inventory, governance demands with no tooling, brittle hand-wired DAGs, no escalation paths, and total cost opacity. The market has agent *frameworks*, agent *orchestration*, and agent *workforce* tools — but nobody provides the **organizational infrastructure** that makes agent swarms behave like actual teams.

## Core Concepts

- **Organizational Model** — Map corporate patterns (divisions, teams, roles, reporting lines) to agent infrastructure
- **Swarm Composition** — Declarative team definition with role-based capability assignment
- **Governance Engine** — Audit trails, policy enforcement, spend limits, human-approval gates
- **Institutional Memory** — Team-level knowledge that persists, grows, and transfers
- **Emergent Task Decomposition** — Teams self-organize; no hand-wired DAGs
- **FinOps for Agents** — Per-agent, per-team, per-task cost tracking and attribution

## Why Elixir

OTP supervision trees map 1:1 to the organizational model. Each team is a supervision tree. Agent failure triggers supervisor restart strategies. GenServer state holds team context. The BEAM VM handles thousands of concurrent agent coordinators natively.

## Documentation

- [Concept Document](docs/CONCEPT.md) — Full concept: value prop, audience, features, architecture, competitive positioning, visual direction, GTM
