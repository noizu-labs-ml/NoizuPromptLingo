# NOIZUAI-9: Blade of Eternity

**Domain:** [bladeofeternity.com](http://bladeofeternity.com)

## Vision

An accessibility-first text RPG where blindness isn't a limitation — it's the native medium. Built on Next.js and Elixir, Blade of Eternity uses AI-driven narrative generation and a text-rendered physics engine to create emergent, infinite gameplay that screen readers deliver as naturally as a novel.

The game world — cities, combat, crafting, clans, interactive fiction — has been designed, tested, and operated live with real players. This is the modernization: take everything that worked and rebuild it on a foundation where accessibility IS the product, not a checkbox.

## Heritage

Blade of Eternity was a **live browser-based text MMORPG** (~2013-2014) with:
- Multiple cities (Rune, Mordoon) with districts and economies
- Combat systems (PvP, Battle Tent NPCs, skills like Longshot/Elusion/Whirlwind)
- Crafting, crimes, jobs, housing, clans, quests, donator economy
- Interactive fiction ("Night at Mordoon" — a 40-passage branching Twine story)
- Admin tooling, staff management, community moderation
- Ad campaigns, landing pages, seasonal events (Valentine's, Festival of the Living)

The archive of game systems, world-building, art, database schemas, and interactive stories lives in `assets/`.

## Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **Frontend** | Next.js (App Router) | SSR for screen reader compatibility, semantic HTML as the rendering engine |
| **Backend** | Elixir / Phoenix | OTP processes per player/NPC/physics object, Channels for real-time events, fault tolerance |
| **AI** | ML models (narrative + physics) | Procedural content generation, dynamic NPC behavior, emergent world events |
| **Physics** | Custom engine (Elixir) | Spatial simulation communicated through structured prose and audio cues, not visual rendering |
| **Data** | PostgreSQL | Game state, player data, world persistence |

### Why Elixir

Each player, NPC, room, and physics object runs as an isolated OTP process. When a room collapses in-game, only that process restarts — every other player keeps playing. Phoenix Channels push real-time events (combat, chat, world changes) to the Next.js client, which renders them as ARIA live region updates that screen readers announce naturally.

### Why Next.js

Server-side rendering means the initial page load delivers complete, semantic HTML — screen readers don't wait for client-side JavaScript to paint the game world. The App Router's layout system maps cleanly to game regions (narrative panel, command input, stats sidebar) that persist across navigation.

## Accessibility Architecture

**Design principle:** Blind-first, sighted-compatible. Every feature works without vision. Visual presentation is additive — it enhances but never gates functionality.

### Screen Reader as Game Engine

ARIA live regions are the primary rendering mechanism:

| Channel | ARIA Config | Purpose | Examples |
|---------|-------------|---------|----------|
| **Narrative** | `aria-live="polite"`, `role="log"` | Story, descriptions, dialogue | Room entry, NPC speech, quest updates |
| **Alerts** | `aria-live="assertive"`, `role="alert"` | Critical game events | Damage taken, death, connection loss |
| **Status** | `aria-live="polite"`, `role="status"` | Passive state updates | HP changes, buff/debuff, time of day |

**Rules:**
- Batch related updates into single writes (combat round = one announcement, not five)
- Never stream character-by-character — complete sentences only
- Assertive announcements reserved for genuine urgency (< 5% of events)

### Focus Management

The command input is **home base**. Focus returns here after every resolved action:

```
User types command → Focus stays on input
Game responds → Narrative appends to log (polite announcement)
→ Focus remains on input
Combat alert → Assertive announcement fires
→ Focus remains on input
Modal dialog (confirmation) → Focus traps in dialog
→ On dismiss, focus returns to input
```

### Navigation Structure

Screen reader users navigate by headings and landmarks:

```
<main>                          ← "Game" landmark
  <h1>Rune — Town Square</h1>  ← Current location (H1)
  <section aria-label="Story">  ← Narrative region
    <h2>Story</h2>
    <div role="log" aria-live="polite">...</div>
  </section>
  <section aria-label="Actions">
    <h2>Available Actions</h2>
    ...
  </section>
  <form aria-label="Command input">
    <input id="command-input" aria-label="Enter command" />
  </form>
</main>
<aside aria-label="Character">  ← Stats sidebar
  <h2>Character</h2>
  ...
</aside>
```

Jump between regions with screen reader landmark navigation (D key in NVDA) or heading navigation (H key).

### Keyboard Contract

| Key | Context | Action |
|-----|---------|--------|
| Enter | Command input | Submit command |
| Up/Down | Command input | Command history |
| Arrow keys | Choice menu | Navigate options |
| Enter | Choice menu | Select option |
| Escape | Modal/menu | Close, return focus to input |
| Tab | Global | Move between regions |
| / | Anywhere (not in input) | Focus command input |

### Audio Strategy

Audio is atmospheric, not informational. Screen readers handle all text output. Audio adds:
- Ambient soundscapes per location (Rune market bustle, Mordoon echoes)
- Physics event sounds (impact, fall, splash) synchronized with text descriptions
- Optional spatial audio for directional cues (enemy approaching from left)

Audio is always supplementary — the game is fully playable with audio muted.

## AI Features

### Procedural Narrative Generation

The original game's writing voice (demonstrated in "Night at Mordoon") becomes the training signal. AI generates:
- **Room descriptions** that vary with time, weather, player history, and world state
- **NPC dialogue** that responds to context, not scripted branches
- **Quest narratives** that emerge from world conditions rather than pre-authored chains
- **Combat prose** that describes physics outcomes as readable action ("Your blade catches the brute's shoulder, and the force spins him into the wall — you hear stone crack")

### Dynamic NPC Behavior

Each NPC runs as an Elixir process with AI-driven decision-making:
- NPCs have goals, routines, relationships, and memories
- They react to player actions, world events, and each other
- The guard writing his thesis on pre-Shakespearean ballads? In this version, he's actually writing it — and you can read different pages each visit

### Emergent World Events

AI monitors aggregate world state and generates events:
- Economic shifts when players over-farm a resource
- NPC migrations when a city becomes dangerous
- Seasonal festivals that evolve based on player participation (the Festival of the Living remembers what happened last year)

## Physics Engine

The physics engine simulates spatial relationships, forces, and environmental interactions. The key innovation: **physics are communicated through text, not graphics**.

### What Gets Simulated

| System | Description | Text Output Example |
|--------|-------------|---------------------|
| **Spatial** | 3D positions, distances, line-of-sight | "The brute is seven paces ahead, partially hidden behind a collapsed pillar" |
| **Kinetic** | Force, momentum, collision | "Your slingshot stone ricochets off the wall and strikes the lantern — oil splashes, and the far corner catches fire" |
| **Environmental** | Weather, temperature, light, sound propagation | "Rain hammers the stone above you. The hallway amplifies each drop into a roar. You can barely hear footsteps ahead" |
| **Material** | Object properties, breakability, weight | "The iron gate is rusted but solid. Your knife wouldn't scratch it, but the hinges look ancient" |

### Physics-to-Text Pipeline

```
Physics Engine (Elixir)     →  AI Narrator           →  Client (Next.js)
Simulates forces, collisions    Translates state         Renders to ARIA live region
Updates spatial model            changes to prose         Screen reader announces
Emits structured events          Maintains voice/tone     Focus stays on input
```

The physics engine never outputs numbers to the player. Raw simulation data (force vectors, collision normals) is consumed by the AI narrator, which produces prose that communicates the same information in natural language.

## Core Game Systems

Carried forward from the original, evolved for the new architecture:

### World
- **Cities**: Rune (starter city — Town Square, Financial District, Battle Centre), Mordoon (city of the dead — vaults, festival grounds), and new locations
- **Districts**: Each city has functional zones with shops, services, and NPCs
- **Travel**: Movement between cities with physics-simulated terrain and encounters
- **Housing**: Player-owned spaces with customizable interiors

### Combat
- **PvP**: Real-time duels with physics-based outcomes (positioning, weapon reach, terrain advantage)
- **Battle Tent**: NPC challenges with configurable difficulty
- **Skills**: Longshot (range advantage), Elusion (evasion), Whirlwind (multi-hit) — expanded with physics interactions
- **Catacombs**: Dungeon crawling with emergent encounters

### Economy
- **Currency**: Gold, crystals, tokens
- **Crafting**: Material gathering, recipe-based crafting with quality variance
- **Shops**: NPC merchants with supply/demand pricing
- **Trading**: Player-to-player economy
- **Jobs**: Employment system with rank progression

### Community
- **Clans**: Player organizations with territories, wars, and shared resources
- **Forums & Chat**: In-game communication (real-time via Phoenix Channels)
- **Events**: AI-generated seasonal events that evolve with player participation
- **Crimes**: Risk/reward criminal activities with clan territory implications

### Interactive Fiction
- **Quests**: Branching narratives with consequences that persist in the world
- **Lore**: Discoverable world history woven into room descriptions and NPC dialogue
- **Choice**: Moral decisions that affect reputation, NPC relationships, and available paths (the mask or the knife — and the world remembers which you chose)

## Design Direction

### Style: Editorial (80%) + Minimal Tech (20%)

The game text is the product — it gets the editorial treatment (generous line height, measured line length, reading rhythm). UI chrome gets minimal-tech treatment (recedes, doesn't compete).

| Element | Style | Specification |
|---------|-------|---------------|
| Narrative text | Editorial | 18-20px, line-height 1.75, max-width 65ch |
| System/physics data | Minimal Tech | Monospace, muted color, smaller size |
| UI chrome | Minimal Tech | Dark surface, subtle borders, no decoration |
| Interactive elements | Accent | Violet (#7C3AED) — signals "actionable" |

### Color Palette (Dark Default)

```
Background:     #0A0A0A
Surface:        #111111   (input panel, sidebars)
Text Primary:   #E5E5E5   (narrative — not pure white)
Text Secondary: #A3A3A3   (system messages, timestamps)
Accent:         #7C3AED   (interactive elements, links, current location)
Physics:        #4ADE80   (terminal green — physics/system readouts)
Alert:          #EF4444   (damage, critical warnings)
Border:         #262626   (barely visible separation)
```

Contrast ratios: primary text on background = 17.4:1 (exceeds AAA). Secondary text = 9.2:1 (exceeds AAA).

### Typography

| Role | Font | Fallback |
|------|------|----------|
| Narrative | Literata (variable) | Georgia, serif |
| UI / System | Inter (variable) | system-ui, sans-serif |
| Physics / Code | JetBrains Mono | monospace |

## Project Structure

```
bladeofeternity/
├── README.md                    # This file
├── design/
│   ├── ux-architecture.md       # Screen reader interaction patterns
│   ├── game-systems.md          # Detailed system design docs
│   ├── ai-narrative.md          # AI content generation architecture
│   └── physics-text.md          # Physics-to-text translation framework
├── assets/
│   ├── Documentation/           # Original mind maps, roadmap
│   ├── Graphic Design/          # Original art, banners, landing pages
│   ├── Components/              # Original admin panel, interactive story, schemas
│   ├── Initial Materials/       # Original game docs, guides, designs
│   ├── Load Testing/            # Original colo load test results
│   └── Other Materials/         # Original database dumps
└── src/                         # (future) Application code
    ├── frontend/                # Next.js app
    └── backend/                 # Elixir/Phoenix app
```

## Status

**Design / Pre-development** — Expanded from concept with full UX architecture, accessibility-first design system, and game system specifications. Original game systems validated through live operation (~2013-2014). Next: implementation planning.
