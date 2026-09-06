---
id: P-009
name: "Quinn Harper"
archetype: "The Endpoint Composer"
segment: "primary"
---

# Persona: Quinn Harper — The Endpoint Composer (P-009)

## Demographics

- **Role**: Semi-technical operator assembling custom MCP endpoints for their team's workflows and agents
- **Tech Savvy**: Medium-high — comfortable with concepts (slugs, tools, endpoints) but not raw config files or the DB
- **Primary Surface**: Web app endpoint manager

## Context

Quinn builds purpose-built MCP endpoints — a curated tool set served under a stable slug — for specific jobs (a support bot that only gets search + ticket tools; an internal reporting hook). They rarely know the full tool catalog by heart and should not have to read every tool description to pick the right ones.

## Goals

1. Create or clone an endpoint in minutes, guided, entirely from the web UI
2. Get a sensible tool set proposed from a plain-language description of the endpoint's job
3. Keep final control: review, toggle, and override anything the system proposes

## Pain Points

1. No user-facing path to clone a built-in template (`tobor`, `core`) — editing one dead-ends in a 403 "copy it to edit" with no copy affordance
2. Manual per-tool selection across a large catalog is slow and error-prone
3. No early feedback on slug validity/uniqueness — problems surface only when create fails

## Behaviors

- Starts from an existing template or endpoint more often than from scratch
- Expects slugs to auto-derive from names, and to hand-fix them when the derivation looks wrong
- Wants a rationale ("why this tool?") before enabling anything

## Quotes

> "Don't make me learn the whole catalog. Ask me what the endpoint is for, show me what you'd enable, and let me tweak it."

## Related Stories

US-105 through US-114 (epic: MCP Endpoint UX Overhaul)
