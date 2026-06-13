# Architecture Decision Records

## ADR-001: Static Export Over Server-Side Rendering

**Status:** Accepted  
**Context:** No backend exists yet. The prototype is purely UI/UX exploration.  
**Decision:** Use `next build` static export served by nginx.  
**Consequences:** Simple deployment (no Node runtime in production), CDN-friendly. Dynamic routes require `generateStaticParams`. API integration will require revisiting this decision.

## ADR-002: Mock Data Modules Over API Stubs

**Status:** Accepted  
**Context:** Iterating on UI design before backend architecture is finalized.  
**Decision:** TypeScript modules in `src/data/` export mock data arrays directly. Components import data at build time.  
**Consequences:** Zero network latency during prototyping, type-safe fixtures, trivial to swap for `fetch()` calls later. Risk: UI may assume synchronous data availability that won't hold with a real API.

## ADR-003: D3.js for Knowledge Graph Visualization

**Status:** Accepted  
**Context:** The knowledge graph is a core differentiator — needs custom force simulation, zoom, drag, and interactive node selection.  
**Decision:** Use D3.js (d3-force, d3-zoom, d3-drag, d3-selection) with React integration.  
**Consequences:** Full control over layout and interaction. Higher implementation cost than drop-in libraries (Cytoscape, vis.js). D3 manages its own DOM subtree; React reconciliation must be carefully isolated.

## ADR-004: Tailwind CSS v4

**Status:** Accepted  
**Context:** Rapid prototyping with consistent styling across incubator projects.  
**Decision:** Tailwind v4 via PostCSS plugin.  
**Consequences:** Utility-first approach accelerates UI iteration. Custom design tokens defined as CSS variables in `globals.css`. Consistent with other incubator projects using the styleguide engine.

## ADR-005: Seven Entry-Type Taxonomy

**Status:** Accepted  
**Context:** Need a fixed set of entry categories that covers world-building primitives without over-specialization.  
**Decision:** `character`, `location`, `event`, `faction`, `object`, `concept`, `rule`.  
**Consequences:** Covers the vast majority of creative world-building use cases (fiction, RPGs, game design). Each type has a distinct icon and color treatment. Custom types may be needed eventually — but premature to add extensibility now.
