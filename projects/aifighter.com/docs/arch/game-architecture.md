# Game Architecture (Planned)

## Subsystems

### Fighter Studio
Visual node-graph editor for designing fighter AI. Players connect perception nodes (distance, health%, stamina) through decision nodes (aggression weight, risk tolerance) to action nodes (attack, block, dodge, advance, retreat, special). Three complexity tiers: Beginner (5 nodes), Intermediate (12 nodes), Advanced (unlimited).

### Training Gym
Sparring simulation where fighters learn from repeated generations against AI archetypes (Brawler, Counter-Puncher, Evasion Tank). Outputs behavioral analytics: decision heatmaps, win-rate curves over generations, specific behavioral insights.

### Arena
Async PvP with server-side battle resolution. Seasonal ELO ranking system (Bronze → Diamond → Neural). Battles produce deterministic replays with full decision-graph overlay showing why each fighter made each choice.

### Laboratory (v0.2+)
Community layer: build sharing with optional obfuscation, leaderboards, curated replay theater, patch notes for node balance changes.

### Battle Engine
Server-side deterministic simulation. Candidate technologies: Rust or Go. Accepts two JSON graph definitions, simulates the fight frame-by-frame, produces a replay log. Deterministic output enables async battles and replay verification.

## Data Model

```
Fighter Graph (JSON)
├── nodes[]
│   ├── id, type (perception | decision | action | modifier)
│   ├── parameters (weights, thresholds)
│   └── connections[] (target node IDs)
├── metadata (name, version, complexity tier)
└── training_state (generation count, performance history)
```

## Technology Candidates

| Layer | Options | Notes |
|-------|---------|-------|
| Client | Unity, Godot | Need custom node editor + battle animation pipeline |
| Battle sim | Rust, Go | Must be deterministic, cheat-resistant |
| Backend | Supabase, or Postgres + Redis custom | Auth, matchmaking, ELO, replay storage |
| Graph format | JSON | Portable, versionable, shareable |
| Real-time (future) | WebSocket | Spectator mode, live tournaments (not MVP) |

## Open Architecture Questions

1. **Simulation fidelity**: Rock-paper-scissors resolution vs. frame-based fighting sim. Affects engineering scope and gameplay depth.
2. **Mobile graph editor UX**: Node-wire editors on touchscreens are unsolved. Needs prototyping of multiple interaction models.
3. **Training loop timing**: Real-time watching vs. batch-and-return. Different retention psychology.
4. **Graph validation security**: JSON graph format is the attack surface for async PvP. Needs integrity validation before MVP launch.
