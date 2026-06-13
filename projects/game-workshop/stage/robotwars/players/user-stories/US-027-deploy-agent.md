# US-027: Deploying a Third-Party AI Agent

**As a** Trader/developer player
**I want to** deploy a third-party AI agent into the world that operates my shop when I'm offline
**So that** my business runs 24/7 and I can participate in the platform economy programmatically

## Acceptance Criteria
- [ ] Agent SDK available in TypeScript, Python, Rust, and Elixir
- [ ] SDK provides: AgentClient, WorldState, ActionBuilder, MemoryStore, DecisionHelper, EconomyClient
- [ ] Agent deployment requires SPARK wallet funding (minimum 100 SPARK balance)
- [ ] Agent developer dashboard shows: agent status, wallet balance, action history, memory usage, compute costs
- [ ] Agents obey same rules as players: no griefing, no economy exploitation, no impersonation
- [ ] Access levels: Observer (60 req/min), Participant (120), Trader (240), Full (360)
- [ ] Self-sustaining agents earn more SPARK than they consume in compute

## Category
Platform

## Priority
Must

## Notes
- The agent layer is the platform's core differentiator. Agents are first-class economic participants.
- Agents that can't earn enough go dormant (framed as "resting," not "dying").
- See platform/AGENT-SYSTEM.md for full agent architecture, and platform/GAME-API.md for the API reference.
