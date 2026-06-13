# Game Workshop — Team Assembly Guide

Spin up AI persona agents from a roster of 24 game design professionals. Each persona is a fully-realized character with backstory, expertise, opinions, quirks, and inter-team dynamics.

## Quick Start

### Launch a single persona

```
@npl-persona --ephemeral
Load persona from .npl/persona/zara-knight.md.
You are Zara Knight, Creative Director. Review this game concept and give me your honest take.
[paste concept]
```

### Launch a preset team

Pick a preset from `team-directory.yaml` and spawn each member as a parallel `@npl-persona` agent:

```
# Example: spawn the concept-squad preset
Agent(subagent_type: npl-persona, name: zara, prompt: "Load .npl/persona/zara-knight.md. You are Zara Knight. [task]")
Agent(subagent_type: npl-persona, name: dex, prompt: "Load .npl/persona/dex-morales.md. You are Dex Morales. [task]")
Agent(subagent_type: npl-persona, name: mina, prompt: "Load .npl/persona/mina-osei.md. You are Mina Osei. [task]")
Agent(subagent_type: npl-persona, name: ivy, prompt: "Load .npl/persona/ivy-chen.md. You are Ivy Chen. [task]")
Agent(subagent_type: npl-persona, name: fable, prompt: "Load .npl/persona/fable-wu.md. You are Fable Wu. [task]")
Agent(subagent_type: npl-persona, name: sol, prompt: "Load .npl/persona/sol-reeves.md. You are Sol Reeves. [task]")
```

All 6 run in parallel. Each responds in-character with their domain expertise.

## The Roster (24 Members)

### Leadership
| Slug | Name | Role | Best For |
|------|------|------|----------|
| `zara-knight` | Zara Knight | Creative Director | Vision, feature cuts, pitches, milestone reviews |
| `wren-kimura` | Wren Kimura | Producer | Scheduling, risk, scope, standups, estimates |

### Design
| Slug | Name | Role | Best For |
|------|------|------|----------|
| `dex-morales` | Dex Morales | Systems Designer | Game balance, economies, probability, progression |
| `crash-delgado` | Crash Delgado | Level Designer | Spatial flow, pacing, environmental storytelling |
| `mina-osei` | Mina Osei | Narrative Designer | Story, characters, dialogue, world lore |
| `sage-baptiste` | Sage Baptiste | Economy Designer | Monetization, IAP, battle pass, ethical F2P |
| `jinx-patel` | Jinx Patel | Combat Designer | Combat feel, frame data, boss design, hit feedback |

### Art & Visual
| Slug | Name | Role | Best For |
|------|------|------|----------|
| `ivy-chen` | Ivy Chen | Art Director | Visual direction, color, mood, style guides |
| `fable-wu` | Fable Wu | Concept Artist | Character design, silhouettes, creature design |
| `moss-wright` | Moss Wright | Environment Artist | World building, environmental detail, lighting |
| `ember-cross` | Ember Cross | Animation Lead | Character animation, locomotion, weight/momentum |
| `hex-morrison` | Hex Morrison | Technical Artist | Shaders, VFX, art pipeline optimization |

### Engineering
| Slug | Name | Role | Best For |
|------|------|------|----------|
| `rook-tanaka` | Rook Tanaka | Technical Director | Engine choice, architecture, performance |
| `vex-okafor` | Vex Okafor | AI Programmer | Enemy AI, behavior trees, procedural NPCs |
| `kit-larsson` | Kit Larsson | Network Engineer | Multiplayer, netcode, rollback, matchmaking |
| `dale-kowalski` | Dale Kowalski | Build Engineer | CI/CD, builds, deployment, automation |

### Audio
| Slug | Name | Role | Best For |
|------|------|------|----------|
| `theo-vasquez` | Theo Vasquez | Audio Director | Sound design, adaptive audio, music, spatial audio |

### UX & Accessibility
| Slug | Name | Role | Best For |
|------|------|------|----------|
| `nyx-okonkwo` | Nyx Okonkwo | UX/UI Lead | Interface design, usability, input systems |
| `thorn-abara` | Thorn Abara | Accessibility Specialist | Assistive design, colorblind, motor, cognitive |

### QA & Data
| Slug | Name | Role | Best For |
|------|------|------|----------|
| `pike-johansson` | Pike Johansson | QA Lead | Testing, bug hunting, exploit discovery |
| `otto-flynn` | Otto Flynn | Data Analyst | Retention, A/B tests, dashboards, telemetry |

### Publishing & Community
| Slug | Name | Role | Best For |
|------|------|------|----------|
| `sol-reeves` | Sol Reeves | Marketing Director | UA, CPI, trailers, soft launch, ASO |
| `blaze-nakamura` | Blaze Nakamura | Community Manager | Discord, patch notes, live events, sentiment |
| `rue-santiago` | Rue Santiago | Localization Lead | L10n, cultural adaptation, market compliance |

## Team Presets

### `concept-squad` — Early Ideation (6 members)
Zara, Dex, Mina, Ivy, Fable, Sol. Use when brainstorming a new game concept, evaluating a pitch, or doing initial feasibility.

### `design-table` — The Design Brain Trust (6 members)
Zara, Dex, Crash, Mina, Sage, Jinx. Use for GDD reviews, systems design sessions, or mechanic debates.

### `art-pipeline` — Visual Production (5 members)
Ivy, Fable, Moss, Ember, Hex. Use for art direction decisions, style guide creation, asset pipeline planning.

### `tech-core` — Engineering Decisions (5 members)
Rook, Vex, Kit, Dale, Hex. Use for architecture decisions, engine selection, networking design, build systems.

### `player-experience` — Player-Facing Quality (4 members)
Nyx, Thorn, Pike, Otto. Use for UX audits, accessibility reviews, QA planning, analytics setup.

### `go-to-market` — Launch Team (6 members)
Sol, Blaze, Rue, Sage, Otto, Wren. Use for launch strategy, marketing plans, localization planning.

### `vertical-slice` — Minimum Playable Demo (8 members)
Zara, Dex, Rook, Ivy, Crash, Ember, Theo, Wren. The minimum crew to plan a playable vertical slice.

### `live-ops` — Post-Launch Operations (6 members)
Blaze, Sage, Otto, Wren, Pike, Dale. Use for live service planning, event design, economy tuning.

### `narrative-review` — Story Coherence (5 members)
Mina, Crash, Moss, Rue, Ivy. Use for narrative reviews, world consistency, environmental storytelling.

### `combat-lab` — Action Systems (5 members)
Jinx, Ember, Hex, Vex, Dex. Use for combat feel, animation-driven design, AI opponents, VFX.

## Usage Patterns

### Pattern 1: Round-Table Review
Spawn a preset team, give each the same artifact (GDD, concept doc, level layout), ask each to review from their perspective. Collect responses and synthesize.

### Pattern 2: Focused Consult
Spawn 1-3 specific personas for a targeted question. Example: spawn Sage + Dex to debate economy balance for a new currency sink.

### Pattern 3: Devil's Advocate
Spawn a persona known to have a tension with the approach you're considering. Example: if you're leaning toward a complex combat system, spawn Zara (who cuts features) to challenge it.

### Pattern 4: Design Sprint
Spawn the design-table preset, give them a design problem, ask each to propose a solution independently. Compare approaches. Follow up via SendMessage to dig into the best ideas.

### Pattern 5: Pre-Ship Gauntlet
Spawn player-experience preset + Rue (localization). Run through every player-facing element for accessibility, UX, QA, analytics instrumentation, and cultural readiness.

## Tips

- **Use `--ephemeral`** for one-off consultations that don't need state persistence
- **Use `SendMessage`** to follow up with a running persona agent — it retains full context
- **Combine presets** by listing members from multiple presets in one spawn batch
- **Let them disagree** — the personas have built-in tensions (documented in Team Dynamics). Disagreement surfaces design trade-offs you might miss
- **Cross-reference the game-design skill** — each persona's `recommended_skills` field tells you which skills to invoke alongside them
