# Architecture Decision Records

## ADR-001: Dual-Principal Authorization Model

**Status:** Accepted
**Context:** MCP servers act on behalf of both an AI agent (caller) and a human user. Traditional single-principal auth (just the caller's API key) creates privilege escalation risk — a caller could access services the human never authorized.
**Decision:** Every request requires both caller and user identity. Access is the intersection (AND) of both principals' permissions, never the union.
**Consequences:** More complex auth flow, but prevents the most dangerous MCP security failure mode. Requires RFC 8693 token exchange for user identity propagation.

## ADR-002: Phoenix/Elixir Backend

**Status:** Accepted
**Context:** MCP tool invocations are high-volume, concurrent, and often involve long-lived WebSocket connections for streaming transports.
**Decision:** Phoenix 1.8 with Ecto for the backend API.
**Consequences:** Excellent concurrency model (BEAM VM), native WebSocket/SSE support via Channels. Team has Elixir expertise. Smaller hiring pool than Node/Go.

## ADR-003: OPA or Cedar for Policy Engine

**Status:** Under evaluation
**Context:** Need declarative, auditable policy evaluation. Custom DSLs are expensive to maintain; general-purpose code (if/else in handlers) doesn't produce evaluation traces.
**Decision:** Evaluate OPA (Rego) and Cedar (AWS). Both support audit trails and formal verification.
**Consequences:** External dependency for policy evaluation. Both have Kubernetes-native deployment options.

## ADR-004: Firecracker/gVisor for Tool Sandboxing

**Status:** Under evaluation
**Context:** Tools must execute in isolation — no host filesystem, no arbitrary network, strict resource limits. Container namespaces alone are insufficient for untrusted code.
**Decision:** Evaluate Firecracker microVMs (strongest isolation, higher overhead) vs gVisor (lighter, still strong). Decision depends on cold-start latency requirements.
**Consequences:** Firecracker adds ~125ms cold start; gVisor is lower but less isolated. May use both: gVisor for trusted publishers, Firecracker for untrusted.

## ADR-005: YAML-Driven Design System

**Status:** Accepted
**Context:** Multiple domains (justmcp.it, mcpjumpst.art, safemcp.com) need distinct visual identities while sharing components and layout.
**Decision:** Define themes as YAML config files, generate CSS at build time via `@the-robot-lives/styleguide` engine.
**Consequences:** Theme switching is a CSS swap, not a component rebuild. Four themes maintained in parallel. Adds build step but keeps runtime simple.
