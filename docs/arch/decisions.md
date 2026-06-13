# Architecture Decision Records

## ADR-001: Screen-Reader-First Design

**Decision**: Build the game for blind users first, then add visual presentation as enhancement.

**Context**: Most "accessible" games bolt accessibility onto a visual product. The game's native medium is text — prose is the primary rendering format, not a fallback.

**Consequence**: Every feature is designed around screen reader announcement patterns (ARIA live regions, focus management, landmark navigation) before visual layout is considered. The game is fully playable with no visual rendering at all.

## ADR-002: Elixir/OTP for Game Simulation

**Decision**: Use Elixir with OTP process isolation for all game entities.

**Context**: Each player, NPC, room, and physics object needs independent state and fault isolation. A crashing room process must not affect other players.

**Consequence**: OTP supervisors restart failed processes transparently. Phoenix Channels provide natural real-time event distribution. The BEAM VM handles thousands of concurrent lightweight processes efficiently.

## ADR-003: SSR via Next.js App Router

**Decision**: Server-side render all game content with Next.js App Router.

**Context**: Screen readers need complete semantic HTML on first paint. Client-side-only rendering creates a gap where screen readers encounter empty or loading states.

**Consequence**: Initial page load delivers complete, semantic HTML. App Router layouts persist game regions (narrative, command input, stats) across navigation. Client-side hydration adds interactivity without content flash.

## ADR-004: TimescaleDB + Apache AGE

**Decision**: Use a PostgreSQL 17 image with TimescaleDB and Apache AGE extensions.

**Context**: The game needs relational data (accounts, characters), time-series data (telemetry, event logs), and graph data (NPC relationships, faction networks, quest chains).

**Consequence**: Single database engine handles all three data models. TimescaleDB hypertables for temporal queries, AGE for Cypher-based graph traversal, standard PostgreSQL for ACID relational operations.

## ADR-005: AI Narrative over Scripted Content

**Decision**: Use GenAI for procedural content generation instead of hand-authored scripts.

**Context**: The original game (~2013-2014) proved that rich, varied prose makes the text RPG experience. Hand-authoring content doesn't scale to the variety needed for infinite replayability.

**Consequence**: The AI narrator generates room descriptions, NPC dialogue, combat prose, and quest narratives from simulation state. The original game's writing voice (e.g., "Night at Mordoon") serves as the style reference. Trade-off: requires careful voice consistency management and output quality monitoring.

## ADR-006: Physics-to-Text Pipeline (No Raw Numbers)

**Decision**: The physics engine never exposes numerical data to the player. All simulation output is translated to prose by the AI narrator.

**Context**: Screen reader users consume text linearly. Announcing "force: 47.3N, angle: 23 degrees" breaks immersion and is meaningless without spatial visualization.

**Consequence**: The AI narrator translates physics events to natural language. Players get "The brute stumbles backward three steps" instead of knockback values. Requires a well-defined contract between the physics engine's structured events and the narrator's prose templates.

## ADR-007: Guardian JWT Authentication

**Decision**: Use Guardian for JWT-based stateless authentication.

**Context**: The game client communicates via both REST (auth, character management) and WebSocket (real-time gameplay). JWT works cleanly across both transports.

**Consequence**: Tokens are issued on login, validated per-request via Guardian pipeline, and passed as channel params for WebSocket authentication. No server-side session store needed for auth state.

## ADR-008: BDD Testing with Cypress + Cucumber

**Decision**: Use Cypress with Cucumber/Gherkin for end-to-end testing.

**Context**: Accessibility behavior (screen reader announcements, focus management, keyboard navigation) is best verified through integration tests that exercise the full stack. Gherkin specs make accessibility requirements readable by non-developers.

**Consequence**: Feature files in `web/e2e/` describe user journeys in natural language. Co-located `.cy.yaml` sidecar files document test selectors per page. The `cyAttrs()` utility generates data-cy attributes for reliable element targeting.
