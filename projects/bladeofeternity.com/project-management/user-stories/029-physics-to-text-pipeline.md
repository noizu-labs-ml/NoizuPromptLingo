# US-029: Physics-to-Text Pipeline — Spatial Simulation Narration

**Persona:** Dave — Sighted MUD veteran, sysadmin, deep systems
**Priority:** P0
**Epic:** Physics — Core Pipeline

## Story
As Dave, I want the physics engine's simulation output translated into precise, information-dense prose so that I understand the mechanical reality of what happened (force vectors, surface interactions, mass effects) through language rather than graphics.

## Acceptance Criteria
- [ ] Physics events (collision, impulse, friction, rebound) each have a prose template registry with 3–5 variant phrasings to prevent repetition
- [ ] Force magnitude expressed in prose bands: glancing, solid, heavy, crushing, catastrophic
- [ ] Surface material communicated through impact sound and texture language: "The blade rings off plate steel," "sinks into boiled leather," "skids across wet flagstone"
- [ ] Mass and momentum differences narrated: a heavy opponent's charge described differently from a lighter opponent's lunge
- [ ] Environmental physics (knockback into wall, falling, pushed into water) narrated with spatial consequence: "The impact drives you back — your shoulders meet the dungeon wall with a hollow thud."
- [ ] Physics debug mode available to sysadmin/tester accounts showing raw simulation values alongside prose
- [ ] Pipeline latency: physics batch → prose → WebSocket → client in <200ms for real-time feel
- [ ] Prose generated server-side (Phoenix); client receives final text only

## Notes
Dave wants to understand the engine, not just feel the outcome. The debug mode satisfies deep curiosity without exposing simulation internals to all players. The prose template registry should be data-driven (YAML/ETS) not hardcoded, so writers can extend it without deploys. Consider exposing a "physics verbosity" slider: cinematic (pure prose) vs. technical (prose + parenthetical values like "(42 N, plate)").
