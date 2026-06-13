# NOIZUAI-10: AI Fighter

**Domain:** [aifighter.com](http://aifighter.com)

## Project Idea

Mobile game where players train neural-net powered fighters, customize their decision-making graphs, and battle in virtual arenas. Players design and evolve AI-driven fighters by configuring neural network architectures, training strategies, and decision trees. Fighters compete in async PvP battles where their learned behaviors and player-tuned parameters determine combat outcomes.

## Status

Concept / Design Brief Complete

---

## Market Position

### One-Liner

**"Pokémon meets neural networks."** — Collect, train, and battle AI fighters you actually *designed*, not just leveled up.

### Value Proposition

Most mobile battlers give you a roster and a meta. AI Fighter gives you a **blank graph and a training gym**. You don't grind stats — you architect behavior. Your fighter's intelligence is your intelligence, visualized as a living decision network you can watch, tweak, and evolve. Wins feel earned because you *engineered* the strategy, not because you pulled a rare drop.

### Competitive Landscape

| Competitor | What They Do | AI Fighter's Edge |
|---|---|---|
| Pokémon GO / Unite | Collect & battle creatures | Players *build* the intelligence, not just the roster |
| Clash Royale | Real-time card strategy | Fighters learn and adapt between battles — no static decks |
| GLADIABOTS | Program robot behavior | Mobile-native, visual graph editor (not code), social/competitive layer |
| Zachtronics games | Programming puzzles | Accessible to non-programmers; competitive PvP, not solo puzzles |

### Why Now

- AI/ML literacy is mainstream (ChatGPT, Copilot normalized "I can shape AI behavior")
- Mobile gaming audience is 3.2B+ and hungry for depth beyond match-3
- Neural-net visualization tools (TensorBoard, Weights & Biases) proved the "watch the AI learn" dopamine loop
- No major mobile game has made "design your own AI" the core mechanic

---

## Target Audience

### Primary Persona: "The Tinkerer"

**Alex, 24** — Software engineer who plays mobile games on transit. Loved Zachtronics, got bored of gacha. Wants a game that rewards *thinking* about systems, not time spent grinding. Will spend money on cosmetics and advanced training environments if the depth is real.

**Behaviors:** Watches 3Blue1Brown, has opinions about activation functions, shares interesting graphs on Discord, competitive but not toxic.

### Secondary Persona: "The Curious Casual"

**Sam, 19** — College student, plays everything, knows AI from TikTok explainers. Doesn't know what a neural net is *technically* but understands "train the AI to be aggressive" vs "train it to dodge." Will engage if the onboarding makes the graph editor feel like a toy, not a textbook.

**Behaviors:** Screenshot-shares cool moments, watches replays, joins clans, motivated by seasonal ranked ladders.

### Tertiary Persona: "The Creator-Spectator"

**Jordan, 31** — Doesn't play competitively but loves watching AI battles, sharing builds, and theorycrafting on Reddit. Engages with the community/content layer more than the game itself.

---

## Core Features

### 1. Fighter Studio (Build)

The graph editor where you architect your fighter's brain.

- **Visual node editor** — Drag-and-drop nodes representing perceptions (distance to enemy, health%, stamina), decisions (attack, block, dodge, advance, retreat), and modifiers (aggression weight, risk tolerance, combo chaining)
- **Pre-built templates** — "Brawler," "Counter-Puncher," "Evasion Tank" starting graphs for onboarding
- **Complexity tiers** — Beginner (5 nodes max), Intermediate (12 nodes), Advanced (unlimited)
- **Live preview** — Watch your fighter shadowbox against a dummy while you edit

### 2. Training Gym (Evolve)

Where your fighter learns from experience.

- **Sparring sessions** — Run your fighter against AI opponents with different styles
- **Training focus** — Emphasize specific scenarios: "practice against rushdown," "learn to punish whiffs"
- **Evolution tracking** — Time-lapse visualization of how your fighter's behavior changed over training generations
- **Training data** — Post-battle, see decision heatmaps: "your fighter chose BLOCK 73% of the time when health < 30%"

### 3. Arena (Compete)

Async PvP with spectator-friendly replays.

- **Ranked ladder** — Seasonal ELO system, divisions (Bronze → Diamond → Neural)
- **Async battles** — Submit your fighter, battles resolve server-side, watch replay
- **Live tournaments** — Scheduled bracket tournaments with spectator mode
- **Battle replay** — Full playback with decision-graph overlay showing *why* each fighter did what it did
- **Clan wars** — Team-based competitions

### 4. Laboratory (Discover)

Community and meta-game layer.

- **Build sharing** — Export/import fighter graphs (with optional obfuscation)
- **Leaderboards** — Top fighters, most creative builds, highest win streaks
- **Patch notes** — Balance changes to node types, new nodes each season
- **Replay theater** — Curated "fight of the week" community highlights

---

## User Journey

### First Session (0-10 min)

```
Download → Cinematic intro (30s, skippable)
  → "Meet your first fighter" (pre-built template)
  → Tutorial battle (guided, can't lose)
  → "Now make it yours" → Open graph editor with 3 nodes highlighted
  → Add one node (e.g., "dodge when low health")
  → Re-battle same opponent → See the difference
  → "You just taught an AI. Welcome to the arena."
```

### Core Loop (per session, 5-15 min)

```
┌──────────────────────────────────────────────────┐
│                                                  │
│  ┌─────────┐    ┌──────────┐    ┌────────────┐  │
│  │  TWEAK  │───▶│  TRAIN   │───▶│   BATTLE   │  │
│  │  Graph  │    │  Spar    │    │   Arena    │  │
│  └────▲────┘    └──────────┘    └─────┬──────┘  │
│       │                               │          │
│       │         ┌──────────┐          │          │
│       └─────────│  REVIEW  │◀─────────┘          │
│                 │  Replay  │                     │
│                 └──────────┘                     │
│                                                  │
└──────────────────────────────────────────────────┘
```

### Progression Arc

```
Week 1:  Template fighter → first ranked placement
Week 2:  Unlock intermediate nodes → climb ladder
Week 3:  Join clan → clan wars
Week 4+: Advanced graph editing → tournament play → build sharing
```

---

## Key Screens

### Screen 1: Home / Hub

```
┌─────────────────────────────────┐
│  ◉ AI FIGHTER        ⚡ 1247    │  ← Energy / currency
│─────────────────────────────────│
│                                 │
│    ┌───────────────────────┐    │
│    │                       │    │
│    │   [ YOUR FIGHTER ]    │    │  ← 3D fighter model, idle anim
│    │    "VOLT-9"           │    │
│    │    Rank: Gold II      │    │
│    │    W: 47  L: 23       │    │
│    │                       │    │
│    └───────────────────────┘    │
│                                 │
│  ┌──────┐ ┌──────┐ ┌──────┐   │
│  │ARENA │ │ GYM  │ │ LAB  │   │  ← Bento-style quick actions
│  │Battle│ │Train │ │Builds│   │
│  │ Now  │ │ Now  │ │ Feed │   │
│  └──────┘ └──────┘ └──────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 🏆 Season 3: "SYNAPSE" │   │  ← Season banner / event
│  │ 14 days remaining       │   │
│  └─────────────────────────┘   │
│                                 │
│─────────────────────────────────│
│  🏠    ⚔️    🧠    🔬    👤   │  ← Bottom tab bar
│ Home  Arena Studio  Lab  Profile│
└─────────────────────────────────┘
```

### Screen 2: Fighter Studio (Graph Editor)

```
┌─────────────────────────────────┐
│  ← Back    FIGHTER STUDIO  [▶]  │  ← [▶] = live preview toggle
│─────────────────────────────────│
│                                 │
│  ┌─ PERCEPTION ────────────┐   │
│  │ (👁 Distance)──┐        │   │
│  │ (❤ Health%)───┐│        │   │
│  │ (⚡ Stamina)──┐││        │   │
│  └───────────────┘││────────┘   │
│                   │││           │
│         ┌─────────▼▼▼────────┐ │
│  ┌──────┤   DECISION CORE    │ │
│  │      │                    │ │  ← The neural graph, pannable
│  │      │  [Aggression: 0.7] │ │     and zoomable
│  │      │  [Risk Tol:  0.4]  │ │
│  │      │  [Combo:     0.8]  │ │
│  │      └─────────┬──────────┘ │
│  │                │             │
│  │  ┌─ ACTIONS ───▼──────────┐ │
│  │  │ ⚔ Attack  🛡 Block    │ │
│  │  │ 💨 Dodge   🏃 Advance  │ │
│  │  │ ↩ Retreat  ⚡ Special  │ │
│  │  └────────────────────────┘ │
│                                 │
│  ┌─────────────────────────┐   │
│  │ + Add Node    📋 Templates│  │  ← Node palette
│  └─────────────────────────┘   │
│                                 │
│  [ 💾 Save ]    [ ▶ Test Run ] │
│─────────────────────────────────│
│  🏠    ⚔️    🧠    🔬    👤   │
└─────────────────────────────────┘
```

### Screen 3: Battle Replay

```
┌─────────────────────────────────┐
│  ← Back     BATTLE REPLAY      │
│─────────────────────────────────│
│                                 │
│  VOLT-9           vs    RAZR-X  │
│  ████████░░ 64%     ███░░░ 31% │  ← Health bars
│                                 │
│  ┌─────────────────────────┐   │
│  │                         │   │
│  │                         │   │
│  │    [ BATTLE ARENA ]     │   │  ← Animated battle playback
│  │    < fighters dueling > │   │
│  │                         │   │
│  │                         │   │
│  └─────────────────────────┘   │
│                                 │
│  ▶ ██████████░░░░░ 2:34 / 5:00 │  ← Playback scrubber
│  [1x]  [2x]  [Slow]            │
│                                 │
│  ┌─ DECISION OVERLAY ──────┐   │
│  │ VOLT-9 chose: DODGE     │   │  ← Real-time decision trace
│  │ Reason: Health < 40%    │   │
│  │         + Enemy winding  │   │
│  │ Confidence: 0.89        │   │
│  └─────────────────────────┘   │
│                                 │
│  [ 📊 Full Stats ] [ 🔄 Rematch ]│
│─────────────────────────────────│
│  🏠    ⚔️    🧠    🔬    👤   │
└─────────────────────────────────┘
```

### Screen 4: Training Gym

```
┌─────────────────────────────────┐
│  ← Back      TRAINING GYM      │
│─────────────────────────────────│
│                                 │
│  Training Session #847          │
│  ┌─────────────────────────┐   │
│  │ ▎                       │   │
│  │ ▎   PERFORMANCE GRAPH   │   │  ← Win rate over training
│  │ ▎  ╱╲  ╱╲╱╲  ╱──       │   │     generations, live updating
│  │ ▎╱╱  ╲╱     ╲╱         │   │
│  │ ▎────────────────────── │   │
│  │   Gen 1          Gen 50 │   │
│  └─────────────────────────┘   │
│                                 │
│  SPARRING PARTNER:              │
│  ┌──────┐ ┌──────┐ ┌──────┐   │
│  │Brawl │ │Counter│ │Evade │   │  ← Choose opponent archetype
│  │ -er  │ │Punch │ │Tank  │   │
│  │ ●    │ │  ○   │ │  ○   │   │
│  └──────┘ └──────┘ └──────┘   │
│                                 │
│  FOCUS: [Punish Whiffs ▼]      │
│                                 │
│  ┌─ INSIGHTS ──────────────┐   │
│  │ • Blocks 73% when HP<30 │   │  ← Behavioral analytics
│  │ • Never uses Special at │   │
│  │   close range — add node│   │
│  │ • Dodge timing improved │   │
│  │   +12% since Gen 30     │   │
│  └─────────────────────────┘   │
│                                 │
│  [ ▶ Run 10 Generations ]      │
│─────────────────────────────────│
│  🏠    ⚔️    🧠    🔬    👤   │
└─────────────────────────────────┘
```

---

## Design Direction

### Style: Bold Expressive (80%) + Minimal Tech (20%)

**Rationale:** This is a *game about AI* — it needs to feel electric, competitive, and futuristic. Bold Expressive delivers the energy and visual identity that makes a mobile game stand out in app store screenshots. Minimal Tech accents the graph editor and data visualizations, keeping the "build your AI" tools clean and functional.

### Color System

```
PALETTE: "NEURAL NEON"

Background:  #0A0A0F  (Near-black with blue undertone)
Surface:     #14141F  (Elevated cards/panels)
Border:      #2A2A3A  (Subtle structure)

Primary:     #00FFAA  (Electric mint — the "synapse" color)
Secondary:   #FF3366  (Hot pink — aggression/damage)
Tertiary:    #3366FF  (Electric blue — defense/utility)
Accent:      #FFAA00  (Amber — rewards/currency/rank)

Text:        #E8E8F0  (Off-white, easy on dark bg)
Text Muted:  #6B6B80  (Secondary info)

Semantic:
  Win:       #00FFAA  (Primary mint)
  Loss:      #FF3366  (Hot pink)
  Warning:   #FFAA00  (Amber)
  Neutral:   #3366FF  (Blue)
```

### Typography

```
Display / Headlines:  Monument Extended (or Space Grotesk Black)
                      Uppercase, tight tracking, BOLD.
                      Used for: fighter names, arena titles, season banners

UI / Body:            Inter or DM Sans
                      Clean, readable at small sizes on mobile
                      Used for: graph labels, stats, menus

Monospace accent:     JetBrains Mono
                      Used for: node parameters, confidence values, data readouts
```

### Visual Identity Cues

- **Neural pathways** as a recurring motif — glowing lines connecting nodes, used in backgrounds, transitions, loading screens
- **Particle effects** on fighter actions — sparks, energy trails, data-stream particles
- **Glassmorphism** on overlays and modals — frosted dark glass, 60% opacity
- **Decision graph as hero visual** — the player's graph is their identity, displayed prominently on profiles and in replays
- **Neon glow** on interactive elements — buttons, active nodes, selected fighters
- **Scanline / data-stream textures** — subtle CRT-style horizontal lines on backgrounds to reinforce the "inside the machine" feel

### Motion Language

| Interaction | Animation | Duration |
|---|---|---|
| Node connection | Glowing line draws between nodes | 200ms ease-out |
| Battle hit | Screen shake + color flash | 100ms |
| Training generation | Fast counter tick + graph line extends | 300ms per gen |
| Win | Fighter glow pulse + confetti particles | 800ms spring |
| Loss | Desaturation + static grain | 400ms ease-in |
| Menu transition | Horizontal slide with parallax depth | 250ms ease-in-out |

---

## Monetization Model

### Freemium (F2P Core + Cosmetic + Progression Premium)

| Tier | Price | What You Get |
|---|---|---|
| **Free** | $0 | Full graph editor (beginner + intermediate nodes), ranked arena, 3 sparring partners, 1 fighter slot |
| **Fighter Pass** (seasonal) | $9.99 / season | Advanced nodes, 3 extra fighter slots, exclusive cosmetics, bonus training environments, replay analysis tools |
| **Cosmetic Shop** | $0.99-$4.99 | Fighter skins, arena themes, victory animations, graph color themes, profile badges |
| **Booster Packs** | $1.99-$4.99 | Training accelerators (more generations per session), extra energy |

### Revenue Psychology

- **Never pay-to-win** — No purchasable nodes that are strictly better. Cosmetics and convenience only.
- **The graph is sacred** — Winning comes from design skill, not wallet size. This is the #1 community trust principle.
- **Seasonal urgency** — Battle pass / Fighter Pass resets each season with new nodes and cosmetics.
- **Spectator monetization** — Tournament viewers can gift "energy" to favorite fighters (streamer-economy model).

---

## MVP Scope (v0.1)

### In Scope

- [ ] Fighter Studio with beginner-tier graph editor (5 node types)
- [ ] 3 pre-built fighter templates
- [ ] Training gym with 1 sparring partner type
- [ ] Async 1v1 matchmaking (basic ELO)
- [ ] Battle replay with basic decision overlay
- [ ] Single fighter slot per account
- [ ] Account system (email or social auth)

### Out of Scope (v0.2+)

- Advanced/unlimited nodes
- Clans and clan wars
- Live tournaments
- Build sharing / Laboratory
- Cosmetic shop
- Seasonal battle pass
- Spectator mode

### Technical Stack Considerations

| Layer | Candidate | Rationale |
|---|---|---|
| Client | Unity or Godot (mobile export) | Graph editor needs custom UI; battle rendering needs animation pipeline |
| Battle engine | Server-side simulation (Rust or Go) | Deterministic, cheat-resistant, async-compatible |
| Graph storage | JSON-based graph format | Portable, versionable, shareable |
| Backend | Supabase or custom (Postgres + Redis) | Auth, matchmaking, ELO, replays |
| Real-time (future) | WebSocket for spectator/live | Not needed for MVP async model |

---

## Open Questions (Need External Input)

These are things I don't have confident answers on — flagging per the "Is this bullshit?" principle:

1. **Battle simulation fidelity** — How complex should the actual fight physics be? Simple rock-paper-scissors resolution? Frame-based fighting game sim? This dramatically affects both engineering scope and how "meaningful" the graph design feels. *I'd want to look at GLADIABOTS and Screeps for prior art on how much simulation depth creates the most satisfying "my AI did that" moments.*

2. **Graph editor UX on mobile** — Node-and-wire editors on desktop are mature (Unreal Blueprints, ComfyUI). On a phone touchscreen? Genuinely hard. This is the make-or-break UX challenge. *Would benefit from prototyping 3-4 interaction models before committing: pinch-zoom canvas, simplified list-based editing, card-based connections, or radial menus.*

3. **Training time vs. instant feedback** — Do training generations run in real-time (watching the fighter learn over 30 seconds) or batch (tap "train 50 gens" and see results)? The dopamine loop design depends on this. *Reference: idle game genre does "batch and return" well; Tamagotchi-style does "watch it happen" well. Different retention curves.*

4. **Anti-cheat for async PvP** — If battles resolve server-side from graph definitions, the graph format itself becomes the attack surface. Need to validate graph integrity and prevent injection of impossible node configurations. *Security architecture needed before public launch.*
