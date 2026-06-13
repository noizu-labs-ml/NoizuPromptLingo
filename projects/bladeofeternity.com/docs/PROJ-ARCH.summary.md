# Project Architecture — Summary

Blade of Eternity: accessibility-first text RPG. Screen readers are the primary rendering engine. Next.js 16 SSR frontend + Elixir/Phoenix 1.8 backend with OTP process isolation per game entity.

## Core Components

- **Next.js Frontend** — SSR semantic HTML, ARIA live regions, keyboard command interface
- **Phoenix API** — REST auth (Guardian/JWT), character management, health checks
- **Phoenix Channels** — WebSocket real-time events (combat, chat, world updates)
- **OTP Process Tree** — Isolated processes per player/NPC/room/physics object
- **GenAI Pipeline** — Narrative generation translating simulation state to prose
- **TimescaleDB** — PostgreSQL 17 + TimescaleDB + Apache AGE (relational + time-series + graph)
- **Redis** — Session cache, pub/sub, rate limiting

## Accessibility

Three ARIA live region channels: Narrative (polite, role=log), Alerts (assertive, role=alert), Status (polite, role=status). Focus always returns to command input. Navigation via landmarks and headings (max h3). Audio is atmospheric, never informational.

## Data Flow

Command input -> Phoenix Channel -> OTP process (simulate) -> structured event -> GenAI narrator (prose) -> Channel push -> ARIA live region -> screen reader announcement.

## AI and Narrative

GenAI (Noizu library) drives procedural room descriptions, NPC dialogue, combat prose, quest narratives, and emergent world events. Physics data is never exposed as numbers — the AI narrator translates simulation state to natural language.

## Physics Engine

Custom Elixir-based spatial simulation: positions, forces, collisions, materials, environment. Each room/object is an OTP GenServer. Output flows through AI narrator as structured prose — no raw numbers reach the player.

## Infrastructure

Next.js 16.1 / React 19.2 / Tailwind 4 | Elixir 1.15+ / Phoenix 1.8 / Ecto 3.13 | Guardian JWT auth | TimescaleDB pg17.9 + AGE | Redis 7 | GenAI 0.2.4 | Cypress + Cucumber BDD testing | Docker Compose for local dev.

## Key Decisions

- Screen-reader-first: prose is the primary rendering format, not a fallback
- Elixir/OTP: fault-tolerant process isolation per game entity
- SSR: complete semantic HTML on first paint for screen readers
- TimescaleDB + AGE: relational + time-series + graph in one engine
- GenAI over scripted content: scales prose quality to infinite replayability
- Physics-to-text pipeline: no raw numbers, only narrated prose
- Guardian JWT: stateless auth across REST and WebSocket
- Cypress + Cucumber BDD: accessibility behavior verified through full-stack integration tests

## Game Systems

World (cities, districts, travel, housing), Combat (PvP, Battle Tent, skills, catacombs), Economy (currency, crafting, shops, trading, jobs), Community (clans, chat, events, crimes), Interactive Fiction (quests, lore, branching choices with persistent consequences).
