# Crimson Forge Spellsword

## Title & Genre

| Field | Value |
|-------|-------|
| **Title** | Crimson Forge Spellsword |
| **Genre** | Action RPG / Soulslike with Crafting |
| **Engine** | Unreal Engine 5.4 (Nanite for underworld environments, Lumen for volumetric rift lighting) |
| **Platform** | PC (Steam/Epic), PlayStation 5, Xbox Series X/S |
| **Monetization** | Premium -- $49.99 base, no microtransactions |
| **Rating** | ESRB M (Blood and Gore, Violence, Dark Themes) / PEGI 18 / CERO Z |

---

## Vision Statement

Crimson Forge Spellsword is a methodical action RPG where a spellsword operates across two planes of existence simultaneously -- a physical warrior swinging a crimson grappling cord through discordant underworld tunnels, and a spectral biomancer bending gravity from the rift plane above. The game lives at the intersection of scarcity and intentionality: every kraken bone, every rift-crystal, every soul-fragment is harvested once and spent forever. The underworld does not respawn. Your crafting choices are irreversible, and they do not merely alter stats -- they physically reshape the dungeon around you. Invest in gravity runes and tunnels widen into vertical arenas. Invest in fire mutagens and ice-locked passages melt into new corridors. Your build is the architecture. Meanwhile, every death scars the spellsword permanently, reducing maximum soul capacity but granting a unique passive born from the manner of death. You do not respawn as the same character you were. This is a game about a soul learning to inhabit two bodies, about a forge that floats above an underworld that remembers every resource you took, and about a spellsword who grows stranger and more powerful with every failure. It is Dark Souls meets Into the Breach by way of a crafting system that rewrites the map.

---

## Core Loop

**Target session length:** 45--90 minutes

```mermaid
graph TD
    A[Return to Forge-Sanctuary] --> B[Craft: Weapons, Elixirs, Runes]
    B --> C[Descend into Underworld]
    C --> D[Navigate: Cord Traversal + Biomancer Scouting]
    D --> E[Engage: Dual-Body Combat]
    E --> F{Warrior + Biomancer Sync?}
    F -->|Yes| G[Sync Attack: Grapple + Gravity Well]
    G --> H[High Damage / Control]
    F -->|No| I[Independent Actions]
    I --> J[Warrior Melee / Biomancer Gravity Spells]
    H --> K{Harvest Materials?}
    J --> K
    K -->|Yes| L[Finite Collection -- No Respawn]
    K -->|No| M[Push Deeper]
    L --> N{Death?}
    M --> N
    N -->|Survive| O[Return to Forge with Materials]
    O --> A
    N -->|Die| P[Crimson Consequence: Gain Scar + Passive, Lose Soul Capacity]
    P --> Q[Respawn at Last Rift Anchor]
    Q --> D
```

### Core Loop Breakdown

| Step | Player Action | System Response | Skill Expression |
|------|--------------|----------------|-----------------|
| 1. Craft | At forge-sanctuary, convert harvested materials into weapons, elixirs, and cord runes | Crafting is irreversible -- materials consumed permanently. Choices lock in build direction | Strategic planning, resource budgeting |
| 2. Descend | Drop into underworld via rift anchor | World geometry reflects prior crafting choices (gravity runes widen tunnels, fire mutagens melt ice walls) | Spatial awareness of build-environment interaction |
| 3. Traverse | Warrior swings on crimson cord; biomancer scouts ahead on tactical overlay | Cord physics use rope-sim with momentum. Biomancer overlay reveals enemy positions and gravity anchor points | Timing, momentum management, dual-attention |
| 4. Combat (Warrior) | Melee attacks, cord grapples, dodges in real-time | Standard Soulslike stamina system. Cord acts as weapon, grapple tool, and movement ability | Frame-precise timing, stamina management, positioning |
| 5. Combat (Biomancer) | Place gravity wells, warp local gravity, project barriers on tactical overlay | Gravity wells pull enemies and projectiles. Biomancer acts on a 2-second tick cycle -- commands execute with delay | Tactical foresight, spatial prediction, tempo management |
| 6. Sync Attack | Coordinate warrior grapple-swing into biomancer gravity well during overlapping action windows | Impact force multiplied by gravity multiplier (2x--8x depending on well charge). High risk -- both bodies committed | Dual-body timing, the highest-skill expression in the game |
| 7. Harvest | Extract materials from defeated kraken-spawn and rift flora | Materials are finite. No respawn. Each harvest is a permanent deduction from the world's total inventory | Exploration thoroughness, combat engagement (some materials only drop from specific kill methods) |
| 8. Die | Take lethal damage on either body | Crimson Consequence activates: soul capacity reduced by 5%, gain a Scar passive based on death type. Respawn at last rift anchor | Strategic death management -- dying to specific hazards builds specific passives |
| 9. Return | Activate rift anchor to ascend to forge-sanctuary | Materials banked, sanctuary evolves visually based on trophies and crafting history | Session pacing -- know when to push deeper vs. bank resources |

---

## Meta Loop

### Session-to-Session Progression

```mermaid
graph LR
    A[Combat Mastery] --> B[Material Harvesting]
    B --> C[Crafting Decisions]
    C --> D[Build Definition]
    D --> E[Underworld Geometry Shifts]
    E --> F[New Areas Accessible]
    F --> A

    D --> G[Cord Rune Inscriptions]
    G --> H[New Traversal Abilities]
    H --> F

    A --> I[Crimson Consequence: Scars]
    I --> J[Passive Ability Combos]
    J --> K[Altered Combat Strategies]
    K --> A

    C --> L[Weapon Forging]
    L --> M[New Combat Options]
    M --> A

    F --> N[Lore Fragments from Kraken Bones]
    N --> O[Forge-Sanctuary Narrative Evolution]
    O --> P[Understanding the Discordance]
```

### Progression Axes

| Axis | What Grows | How It Feels | Cap |
|------|-----------|-------------|-----|
| **Weapon Arsenal** | Blade types, cord modifications, alternate attacks | Your toolkit expands. Each weapon opens combat options and traversal paths | 9 weapon archetypes across 3 forging tiers |
| **Cord Runes** | Gravity runes, fire runes, phase runes inscribed on the grappling cord | The cord becomes a multipurpose tool -- weapon, movement system, puzzle key | 12 rune inscriptions (4 per element type) |
| **Elixir Library** | Mutagenic brews: regeneration, gravity immunity, toxin resistance, rage | You prepare for specific challenges. Elixirs are consumed on use -- another finite resource | 8 brewable elixir types, 3 potency tiers each |
| **Scar Passives** | Permanent abilities gained from dying: shock absorption, toxin synthesis, pressure lungs, ember skin | Your failures define you. Each death makes you stranger and more specialized | 15 scar types (5 damage categories x 3 severity tiers) |
| **Biomancer Mastery** | Gravity well placement speed, well charge capacity, overlay range | The spectral body becomes an equal partner, not just a support tool | 5 mastery tiers unlocking at specific soul-capacity thresholds |
| **Forge-Sanctuary** | Visual evolution -- crafting stations upgrade, trophy hall fills, rift viewing platform expands | Your home reflects your journey. Each harvested kraken bone becomes a visible trophy | Evolves through 6 visual stages tied to total materials harvested |
| **Underworld Knowledge** | Map completion, geometry-shift prediction, material location memory | The dungeon becomes readable. You learn which crafting choices open which paths | 5 underworld strata, 3 geometry states per stratum |

---

## Game Mechanics

### Primary Mechanic: Dual-Body Combat

The spellsword's soul is split across two bodies that operate simultaneously. The player controls both in real-time, switching focus between them. The warrior fights in third-person melee. The biomancer operates on a tactical overlay -- a translucent top-down view of the immediate area where the player places gravity commands that execute on a 2-second tick.

**Warrior Body -- The Crimson Cord:**

| Action | Input | Stamina Cost | Effect |
|--------|-------|-------------|--------|
| Light Attack | R1 / Left Click | 8 | Quick slash, 1.0x weapon damage |
| Heavy Attack | R2 / Shift+Click | 18 | Wide arc, 1.8x weapon damage, stagger on hit |
| Cord Grapple | L2 / Right Click | 12 | Extend cord to target (enemy, anchor point, geometry). Pulls warrior toward target |
| Cord Whip | L2+R1 / Right Click+Left Click | 22 | Sweep cord in 180-degree arc, 1.3x weapon damage, pulls light enemies toward warrior |
| Block | L1 / Q | 3/sec | Raise cord in defensive weave. Absorbs 60% of incoming damage. Cord tension drains stamina on hit |
| Dodge | Circle / Space | 10 | Standard iframe dodge, 0.4s invulnerability |
| Sync Trigger | L1+R2 / E | 0 | Signal biomancer to sync. Opens 1.5s sync window where next warrior action links with next biomancer command |

**Biomancer Body -- Gravity Projection:**

| Command | Overlay Action | Charge Cost | Execute Delay | Effect |
|---------|---------------|-------------|--------------|--------|
| Gravity Well | Place point on overlay | 20 charge | 2.0s | 5m radius pull zone. Enemies dragged toward center. Projectiles curve inward. Lasts 8s |
| Gravity Spike | Target enemy on overlay | 30 charge | 1.5s | Single-target upward launch. Enemy airborne for 2.5s. Combo window |
| Gravity Shield | Place on warrior position | 25 charge | 1.0s | 3m dome around warrior. Slows projectiles 70%. Lasts 4s |
| Gravity Swap | Target two points on overlay | 40 charge | 2.5s | Swaps positions of anything at point A with point B (enemies, objects, warrior) |
| Gravity Crush | Target area on overlay | 50 charge | 3.0s | 4m radius crushing zone. 3.0x biomancer base damage over 3s. Channeled -- biomancer cannot act during |

**Biomancer Charge Economy:**
- Base charge: 100 maximum
- Charge regeneration: 8 charge/second
- Charge does not regenerate while a command is executing
- Charge capacity increases with Biomancer Mastery tier (+20 per tier, max 200 at tier 5)

**Sync Attack System:**

| Sync Type | Warrior Action | Biomancer Command | Result |
|-----------|---------------|-------------------|--------|
| **Meteor Drop** | Cord grapple to elevated point | Gravity Spike on warrior | Warrior launched upward then slams down for 4.0x weapon damage in 3m radius |
| **Vortex Pull** | Cord Whip | Gravity Well at whip terminus | All pulled enemies dragged into well center, taking 2.5x weapon + 2.0x biomancer damage |
| **Graviton Swing** | Cord swing through area | Gravity Swap on warrior and far point | Warrior teleports to far point with full swing momentum, hitting everything in the arc |
| **Crush Chamber** | Heavy Attack (downward slam) | Gravity Crush centered on slam point | Crush damage multiplied by 1.5x. Enemies cannot escape the crush zone during animation |
| **Phase Strike** | Light Attack | Gravity Shield on warrior | Attack passes through shield, gaining +50% damage. Shield persists, protecting during recovery frames |

### Secondary Mechanic: Scarce Irreversible Crafting

Every material in the underworld exists once. When harvested, it is gone forever. The underworld does not respawn enemies, resources, or flora. This means:

- **Total kraken bones in the game:** 87
- **Total rift-crystals in the game:** 62
- **Total soul-fragments in the game:** 44
- **Total rift-plant specimens in the game:** 103

**Material Categories:**

| Material | Source | Total Quantity | Primary Use | Secondary Use |
|----------|--------|---------------|-------------|---------------|
| Kraken Bone | Defeated kraken-spawn (enemies) | 87 | Weapon forging (blades, blunt heads) | Cord reinforcement (increases tension/durability) |
| Rift-Crystal | Mineral deposits in walls and floors | 62 | Cord rune inscription | Elixir potency enhancement |
| Soul-Fragment | Dropped by miniboss and boss kills | 44 | Biomancer mastery tier unlocks | Forge-sanctuary station upgrades |
| Rift-Plant | Harvestable flora throughout underworld | 103 | Elixir brewing | Emergency combat consumables (throwable toxins, smoke bombs) |
| Abyssal Pearl | Hidden in underwater sections (5 total) | 5 | Unlock the true final stratum | N/A -- single-use key items |

**Weapon Forging Table (9 Archetypes):**

| Weapon | Bone Cost | Cord Cost | Damage | Speed | Special |
|--------|-----------|-----------|--------|-------|---------|
| Rift Blade | 3 | 0 | 1.0x | Fast | Balanced starter. Can be forged into any tier-2 weapon |
| Kraken Cleaver | 5 | 0 | 1.6x | Slow | Wide arc, innate stagger. Breaks enemy guard on charged heavy |
| Phase Dagger | 4 | 1 | 0.8x | Very Fast | Attacks phase through shields. +50% damage from behind |
| Gravity Hammer | 6 | 2 | 2.2x | Very Slow | Each hit creates micro gravity-pull (1m radius, 0.5s). Ground pounds create shockwaves |
| Spinal Whip | 3 | 3 | 1.2x | Fast | Extended range. Can bind enemies for 1.5s on heavy attack |
| Rift Lance | 5 | 1 | 1.4x | Medium | Thrust-focused. Charge attacks pierce through multiple enemies |
| Bone Reaper | 7 | 0 | 1.8x | Medium | Scythe. Hits in wide arc. Gathers enemies toward warrior on heavy |
| Crimson Fang | 4 | 2 | 1.1x | Fast | Paired weapon (blade + cord). Each cord-whip hit buffs next blade strike by 15% (max 3 stacks) |
| Abyssal Anchor | 8 | 3 | 2.5x | Very Slow | Massive. Cannot dodge while equipped. Each swing generates a 2m gravity disturbance that pulls enemies inward |

**Cord Rune Inscriptions (12 Runes, 4 Per Element):**

| Element | Rune | Crystal Cost | Effect |
|---------|------|-------------|--------|
| Gravity | Weight | 4 | Cord pulls warrior 30% faster during grapple |
| Gravity | Anchor | 5 | Grapple point becomes a 3s gravity well (1m pull radius) |
| Gravity | Slingshot | 6 | Release from grapple launches warrior with +50% momentum |
| Gravity | Collapse | 8 | Cord snap creates a 4m gravity crush zone (uses 40 biomancer charge) |
| Fire | Ember | 4 | Cord leaves a 3s fire trail. 0.5x weapon damage per second on contact |
| Fire | Ignite | 5 | Grappled enemies ignite for 4s. 1.0x weapon damage over duration |
| Fire | Meltdown | 6 | Heavy cord attacks melt ice walls and frozen barriers in 2m radius |
| Fire | Supernova | 8 | Detonate cord on grappled target. 3m radius, 2.5x weapon damage, destroys cord for 10s |
| Phase | Ghost | 4 | Warrior becomes intangible during cord grapple travel (0.8s max) |
| Phase | Riftstep | 5 | Grapple endpoint can be a rift-plane anchor -- warrior teleports to that point |
| Phase | Unravel | 6 | Cord passes through shields and armor. Direct damage to enemy health |
| Phase | Disconnect | 8 | Sever cord mid-grapple. Warrior stays, a spectral duplicate travels to target and detonates for 2.0x damage |

**Elixir Brewing (8 Types, 3 Tiers Each):**

| Elixir | Plant Cost (Tier 1 / 2 / 3) | Duration | Effect |
|--------|---------------------------|----------|--------|
| Regeneration Draught | 3 / 6 / 10 | 30s / 45s / 60s | Restores 2% / 4% / 6% HP per second |
| Gravity Immunity Tonic | 4 / 7 / 11 | 20s / 35s / 50s | Immune to gravity wells (enemy and friendly). Prevents knockback from gravity attacks |
| Toxin Neutralizer | 3 / 5 / 8 | Instant | Cures current poison. Tier 2: +30s poison immunity. Tier 3: +60s immunity + reflect 20% poison damage to attackers |
| Rage Mutagen | 5 / 8 / 12 | 15s / 25s / 40s | +30% / +50% / +80% damage. Tier 3: also +20% attack speed |
| Pressure Lungs Extract | 4 / 7 / 10 | 60s / 120s / 180s | Breathe underwater. Tier 2: +30% swim speed. Tier 3: underwater cord attacks deal +50% damage |
| Ember Skin Salve | 5 / 8 / 11 | 20s / 35s / 50s | Melee attackers take 0.3x / 0.6x / 1.0x weapon damage as fire damage |
| Phase Sight Drops | 3 / 6 / 9 | 45s / 90s / 150s | Reveal hidden enemies, traps, and secret passages within 10m / 20m / 30m |
| Rift Bond Elixir | 6 / 10 / 14 | 10s / 20s / 30s | Biomancer commands execute instantly (no tick delay). Tier 2: -25% charge cost. Tier 3: warrior and biomancer share damage reduction 50/50 |

### Secondary Mechanic: Crimson Consequence (Death Scars)

Death is not a reset. Each death permanently reduces maximum soul capacity by 5% (base 100, minimum 40) but grants a Scar passive. The scar type is determined by the damage type that killed you.

**Scar Table:**

| Death Cause | Scar Name | Passive Effect | Visual |
|-------------|-----------|---------------|--------|
| Crushing / Blunt | Stone Heart | -15% stagger buildup from heavy attacks | Cracks along forearms, gray veins |
| Slashing / Piercing | Woven Flesh | +10% dodge iframe duration (0.4s -> 0.44s) | Crisscross scars across torso, visible through armor gaps |
| Fire / Heat | Ember Blood | Fire damage taken reduced by 20% | Glowing orange veins, smoke from wounds during combat |
| Ice / Cold | Frost Lung | Movement speed penalty from chill effects reduced by 50% | Frost patterns on breath, blue lips |
| Poison / Acid | Toxin Gland | Generate toxin on cord attacks after 5 consecutive hits. 0.3x damage over 4s | Green-tinged fingers, faint toxic mist on hands |
| Gravity / Crush | Pressure Body | Gravity well pull effect on warrior reduced by 30% | Warped silhouette, slightly compressed proportions |
| Falling | Hollow Bones | Fall damage reduced by 40% | Elongated limbs, thinner frame |
| Drowning | Abyssal Lungs | Underwater duration before drowning damage increased by 5s | Gilled neck marks, scales along jawline |
| Sync Failure (both bodies die simultaneously) | Rift Scar | Sync attack damage multiplier +25% | Glowing rift-line across face, one eye permanently luminescent |
| Boss Kill | None | No scar. Boss deaths are victories | N/A |

**Scar Stacking:**
- Dying to the same damage type upgrades the scar to the next tier
- Tier 2: double the passive effect
- Tier 3: triple the passive effect + unlock a unique cord attack variant
- Maximum 3 deaths per damage type (9 types x 3 tiers = 27 possible scar events, but minimum soul capacity of 40 caps total deaths at 12)

**Strategic Death Implications:**
- Players planning a gravity-focused build may intentionally die to gravity attacks 2-3 times to maximize Pressure Body
- Players aiming for sync-attack mastery accept that Rift Scar (the rarest death) requires both bodies dying simultaneously -- a high-risk, high-reward playstyle
- The 12-death cap means players cannot max all scars. Choosing which deaths to take and which to avoid is itself a build decision

### Secondary Mechanic: Underground Geometry Shifts

The underworld is not static. Your crafting choices physically alter its layout. This is not procedural generation -- it is a fixed set of deterministic transformations based on what you have crafted.

**Geometry State Rules:**

| Crafted Item | Geometry Effect | Region Affected |
|-------------|----------------|-----------------|
| Any Gravity Rune | Tunnels in the current stratum widen by 20% per gravity rune | All strata |
| Gravity Rune: Collapse | New vertical shafts open in walls (1 per stratum) connecting to hidden chambers | All strata |
| Fire Rune: Meltdown | Ice-locked passages thaw and become traversable | Strata 2-4 (frozen zones) |
| Fire Rune: Supernova | Collapsed rubble in blast zones clears, opening shortcut passages | Strata 1, 3, 5 |
| Phase Rune: Riftstep | Rift-plane mirrors of rooms become accessible -- parallel paths through walls | All strata |
| Phase Rune: Disconnect | Spectral barriers become permeable | Strata 3-5 |
| Any Tier-2+ Weapon | Previously sealed weapon-specific doors open (each weapon archetype opens 1 door) | Varied |
| Abyssal Pearl (key item) | Final stratum descends -- The Discordance Core becomes accessible | Stratum 5 |

**5 Underworld Strata:**

| Stratum | Theme | Base Geometry | Key Materials | Boss |
|---------|-------|---------------|---------------|------|
| 1 -- Chitin Warrens | Organic tunnels, kraken-spawn nests, bioluminescent fungus | Tight corridors, low ceilings, frequent vertical shafts | Kraken Bone (28), Rift-Plant (35) | Brood Matron (kraken-spawn queen, 2-phase) |
| 2 -- Frost Rifts | Frozen crystal caverns, ice-locked chambers, gravity-distorted thermal vents | Wide chambers separated by ice walls. Thermal vents create updrafts | Rift-Crystal (22), Rift-Plant (25) | Glacial Sentinel (animated ice construct, 2-phase with gravity mechanics) |
| 3 -- The Maw | Flesh-walled organic labyrinth, acid rivers, pulsing pressure doors | Maze-like, organic. Walls shift slowly on a 60-second cycle | Kraken Bone (24), Soul-Fragments (12) | Digestive Warden (massive ambush predator, 3-phase) |
| 4 -- Resonance Caverns | Crystalline harmonic chambers, sound-based puzzles, gravity mirrors | Open chambers with floating platforms. Gravity direction shifts per room | Rift-Crystal (25), Soul-Fragments (16) | The Tuning Fork (resonance entity, 3-phase with sync-attack requirements) |
| 5 -- The Discordance Core | Fractured reality, overlapping rift-plane and physical geometry, spatial paradoxes | Non-Euclidean. Rooms connect impossibly. Up becomes down based on rune loadout | Soul-Fragments (16), Abyssal Pearls (5) | The Discordance Itself (manifestation of the rift, 4-phase) |

### Difficulty Progression Table

| Stratum | Enemy Density | New Enemy Types | Boss Complexity | Geometry Shifts Active | Biomancer Mastery Tier | Sync Attack Windows |
|---------|-------------|----------------|----------------|----------------------|----------------------|-------------------|
| 1 -- Chitin Warrens | 3--5 per encounter | Kraken Hatchlings, Bone Crawlers, Spore Blooms | 2-phase (Brood Matron) | None (tutorial stratum) | Tier 1 | 2.0s |
| 2 -- Frost Rifts | 4--6 per encounter | +Frost Shards, Thermal Geysers, Ice Wraiths | 2-phase with gravity wells (Glacial Sentinel) | Fire runes melt ice, gravity runes widen thermal vents | Tier 1--2 | 1.8s |
| 3 -- The Maw | 5--8 per encounter | +Acid Drifters, Flesh Walkers, Pressure Traps | 3-phase (Digestive Warden) | Phase runes open spectral bypasses, weapon-specific doors appear | Tier 2 | 1.5s |
| 4 -- Resonance Caverns | 6--10 per encounter | +Harmonic Wisps, Crystal Guardians, Gravity Mirrors | 3-phase with sync requirements (The Tuning Fork) | Full gravity/fire/phase geometry shifts, platform floating | Tier 3 | 1.2s |
| 5 -- The Discordance Core | 8--12 per encounter | All types + Elite variants + Rift Phantoms | 4-phase (The Discordance Itself) | Non-Euclidean, player-influenced spatial warping | Tier 4--5 | 1.0s |

---

## World Design

### Map Structure

The underworld is a 5-strata descent connected by rift anchors (checkpoints). The floating forge-sanctuary sits above, accessible from any rift anchor. The world is not open -- it is gated by crafting choices. You cannot access stratum 3 without either a fire rune to melt the frost barrier OR a phase rune to bypass it. Multiple paths exist, but each requires specific build investments.

```
                     ┌─────────────────────────┐
                     │   FORGE-SANCTUARY        │
                     │   (Floating Hub)         │
                     │   Crafting, Lore, Trophies│
                     └────────────┬────────────┘
                                  │ Rift Anchor
                     ┌────────────┴────────────┐
                     │   STRATUM 5              │
                     │   The Discordance Core   │
                     │   (Non-Euclidean Final)  │
                     └────────────┬────────────┘
                                  │
                ┌─────────────────┴─────────────────┐
                │                                    │
       ┌────────┴────────┐               ┌──────────┴─────────┐
       │  STRATUM 4       │               │  STRATUM 4          │
       │  Resonance Caverns│               │  (Phase Path)       │
       │  (Gravity Path)  │               │  Mirror route        │
       └────────┬─────────┘               └──────────┬──────────┘
                │                                     │
                └─────────────────┬───────────────────┘
                                  │
                     ┌────────────┴────────────┐
                     │   STRATUM 3              │
                     │   The Maw                │
                     │   (Organic Labyrinth)    │
                     └────────────┬────────────┘
                                  │
                ┌─────────────────┴─────────────────┐
                │                                    │
       ┌────────┴────────┐               ┌──────────┴─────────┐
       │  STRATUM 2       │               │  STRATUM 2          │
       │  Frost Rifts     │               │  (Meltdown Path)    │
       │  (Standard Path) │               │  Fire rune only     │
       └────────┬─────────┘               └──────────┬──────────┘
                │                                     │
                └─────────────────┬───────────────────┘
                                  │
                     ┌────────────┴────────────┐
                     │   STRATUM 1              │
                     │   Chitin Warrens         │
                     │   (Starting Area)        │
                     └─────────────────────────┘
```

**Shortcuts:** 19 shortcut passages connect strata. Each requires specific crafting investment to open (e.g., Meltdown rune opens the fire path through Stratum 2; Riftstep rune opens the phase path through Stratum 4).

### Art Direction Pillars

| Pillar | Description | Reference |
|--------|-------------|-----------|
| **Biomechanical Horror** | The underworld is alive -- walls pulse, floors breathe, kraken-spawn architecture merges bone and chitin with geometric precision | Scorn's organic environments, HR Giger's biomechanical art |
| **Gravity Distortion** | Reality bends -- objects float at angles, water flows sideways, crystals grow in spirals | Control's Oldest House, Inception's folding city |
| **Rift Duality** | The physical world and rift plane coexist visually -- ghostly overlays, doubled architecture, translucent spectral geometry visible through rift tears | Dishonored's Void, Destiny's Ascendant Plane |
| **Crimson Industry** | The forge-sanctuary is warm, mechanical, alive with crafting -- glowing forges, grinding wheels, elixir bubbling in glass. Stark contrast to the cold underworld below | Shadow of the Colossus's shrine, Dark Souls 3's Firelink Shrine |

### Visual & Audio Progression

| Stratum | Palette Dominant | Lighting Mood | Ambient Audio | Music Intensity |
|---------|-----------------|--------------|--------------|----------------|
| 1 -- Chitin Warrens | Bone white, amber fungus glow, deep brown | Low bioluminescence, pools of amber light | Chitin scraping, dripping moisture, distant kraken calls | Sparse -- solo bass flute |
| 2 -- Frost Rifts | Ice blue, crystal white, thermal orange vents | Sharp crystalline reflections, cold fog | Ice cracking, wind howling through rifts, harmonic hum from crystals | Strings enter -- pizzicato violin |
| 3 -- The Maw | Flesh pink, acid green, arterial red | Pulsing organic glow, acidic luminescence | Wet squelching, heartbeat rhythm, acid hissing | Industrial percussion layered in |
| 4 -- Resonance Caverns | Deep violet, gold resonance lines, silver crystal | Harmonic light pulses, gravity-distorted light beams | Sustained musical tones, crystal resonance, gravity hum | Full chamber ensemble -- strings, brass, woodwinds |
| 5 -- Discordance Core | All colors shifting, static, pure white void zones | Reality breaking -- light sources overlap, shadows point wrong directions | Silence broken by discordant tones, then silence again | Full orchestra with prepared piano and extended techniques |
| Forge-Sanctuary | Warm copper, forge orange, dark steel, crimson cord | Warm hearth glow, consistent and safe | Forge bellows, grinding wheels, elixir bubbling, wind outside | Solo acoustic guitar -- the only "safe" music |

---

## Narrative

### Tone Spectrum (7-Axis)

| Axis | Position | Notes |
|------|----------|-------|
| Hope <-> Despair | 65% Despair | The forge is warm. The underworld is not. Craft while you can. |
| Order <-> Chaos | 70% Chaos | The Discordance is entropy given form. The underworld unravels with every resource taken. |
| Human <-> Monster | 60% Monster | Each scar makes you less human. The biomancer body is already spectral. |
| Sound <-> Silence | 55% Sound | The underworld is never silent -- chitin scraping, acid hissing, gravity humming |
| Past <-> Present | 50% Split | The Discordance exists outside time. Past and present collapse in Stratum 5. |
| Science <-> Sorcery | 70% Sorcery | Gravity magic is not understood -- it is channeled. The forge works by ritual, not engineering. |
| Unity <-> Fragmentation | 80% Fragmentation | You are literally two bodies. The soul that binds them is cracking. |

### 8-Point Story Spine

**1. Equilibrium**
The spellsword Kael Drenna serves the Riftbinding Order -- an organization of dual-souled warriors trained to operate across physical and spectral planes simultaneously. Kael's warrior body wields a crimson grappling cord; the spectral biomancer body channels gravity magic from the rift plane. The Order dispatches Kael to investigate a Discordance -- a reality fracture deep beneath the Karst Highlands where the physical and rift planes have begun to overlap. Kael descends through a rift anchor into the Chitin Warrens. The forge-sanctuary activates, floating above the fracture point.

**2. Inciting Incident**
During the first descent, Kael's rift anchor destabilizes. The return path collapses. The forge-sanctuary is now the only surface connection -- and it is locked to the fracture site, drifting above an underworld that goes deeper than any survey predicted. Kael is not exploring a fracture. Kael is inside the Discordance itself -- a living entity that consumes reality. The kraken-spawn are not native fauna. They are what remains of a previous civilization that was absorbed by the Discordance millions of years ago, their bone and chitin repurposed as the entity's immune system.

**3. First Complication**
Kael discovers that harvesting materials from the underworld damages the Discordance's structural integrity. Every kraken bone taken, every rift-crystal mined, every plant pulled from the soil -- these are parts of a living system. Harvesting is not collection. It is surgery on a sleeping god. The geometry shifts that follow harvesting are not rewards. They are wounds. The Brood Matron in Stratum 1 is not a boss. She is a guardian trying to prevent Kael from harming the entity further.

**4. Rising Action**
Kael pushes deeper through the Frost Rifts and into the Maw, harvesting increasingly rare materials and forging increasingly powerful weapons. The Discordance responds with more aggressive defenses -- the Digestive Warden in Stratum 3 is the entity's equivalent of a white blood cell. Kael's deaths accumulate scars, and each scar makes the spellsword more attuned to the entity. The biomancer body begins receiving fragmented visions: memories of the absorbed civilization, their final moments, their realization that the Discordance does not destroy -- it preserves, forever, in bone and crystal.

**5. Midpoint Reversal**
In the Resonance Caverns, Kael finds the Harmonic Archive -- a crystalline library containing the memories of the absorbed civilization. The truth: they were not destroyed by the Discordance. They invited it. Their civilization had reached the end of entropy, and the Discordance offered permanence -- existence without decay. They accepted. The kraken-spawn are their descendants, still serving the entity willingly. The Riftbinding Order knew this. They sent Kael not to investigate but to weaken the Discordance from within, harvesting its substance so that the Order could claim its power. Kael is a mining operation, not an explorer.

**6. Crisis**
Kael must choose: continue harvesting (completing the Order's mission, gaining maximum crafting materials, but killing the entity and the preserved civilization within it) or cease harvesting and find another way to escape (limited materials, harder combat, but preserving a civilization that chose eternal stillness over annihilation). The forge-sanctuary begins to malfunction -- the deeper conflict within Kael's split soul is manifesting physically. The biomancer body starts dissolving.

**7. Climax**
Kael descends into the Discordance Core (Stratum 5) for the final confrontation. The Discordance Itself manifests as a 4-phase entity that attacks using every damage type simultaneously. Each phase represents a layer of the absorbed civilization's memory: their art, their science, their warfare, their acceptance. The fight is not about defeating the Discordance -- it is about whether Kael can convince a sleeping god to release them, or whether Kael must wound it enough to escape.

**8. Resolution**
Three endings based on total materials harvested and choice at the crisis point:
- **The Harvest:** Kael continues harvesting, kills the Discordance, escapes through the dying fracture. The kraken-spawn go silent. The absorbed civilization is truly destroyed. Kael returns to the Order as a weapon, the biomancer body stabilizing only through the Discordance's absorbed power. The scars remain. The Order gets what it wanted.
- **The Accord:** Kael ceases harvesting after the crisis. Enters the Core with limited materials and no max-tier gear. The Discordance recognizes Kael's restraint and negotiates -- it will create a stable exit rift in exchange for Kael becoming its new guardian, replacing the Brood Matron. Kael's soul remains split between both planes permanently. The forge-sanctuary becomes a waypoint for future travelers. The underworld survives. Kael does not leave.
- **The Transcendence:** Kael harvests nothing after the crisis point AND has collected all 5 Abyssal Pearls (the Discordance's own memories of its creation). Kael enters the Core understanding the entity completely. The Discordance is not an enemy or a resource -- it is a being that exists in a state Kael's split soul already partially inhabits. Kael does not fight, flee, or negotiate. Kael harmonizes. The Discordance opens a stable rift not to the surface but to a new plane of existence where physical and rift realities coexist naturally. The absorbed civilization is offered release or continued preservation. The forge-sanctuary becomes a permanent bridge between worlds. This is the hardest ending (requires all 5 Abyssal Pearls, no scars from Stratum 4-5 deaths, and Sync Attack mastery tier 5).

### Key Characters

| Character | Role | Theme | Lore Fragments |
|-----------|------|-------|---------------|
| **Kael Drenna** | Protagonist -- Split-soul Spellsword | Unity through division; a soul that exists in two places cannot be whole but can be more | N/A (player character) |
| **The Discordance** | Antagonist / Victim / Environment | Entropy given form; it does not destroy, it preserves -- forever and against your will | 18 resonance fragments across all strata |
| **Forge-Master Orin** | Mentor -- Voice from the Riftbinding Order (radio contact) | Institutional loyalty vs. moral awakening; Orin knows what the Order planned | 12 transmission logs (Order instructions, gradually revealing the truth) |
| **Brood Matron** | Guardian -- Stratum 1 Boss | Maternal protection on a cosmic scale; she is not evil, she is defending her home | 6 kraken-memory fragments |
| **The Harmonic Archive** | Lore Repository -- Stratum 4 | The voice of the absorbed civilization, preserved in crystal resonance | 22 crystal-memory sequences |
| **Architect Venn** | Ghost -- Last survivor of the absorbed civilization | The one who invited the Discordance; understands that permanence has a cost | 8 personal logs, found near Abyssal Pearls |
| **The Riftbinding Order** | Faction -- Betrayer | Institutions that sacrifice individuals for power; the Order knew what the Discordance was | Revealed through Orin's transmissions and Order artifacts |

---

## Player Personas

### P-003: Hiroshi Tanaka -- The RPG Addict

**Why this game fits:** Crimson Forge Spellsword is a completionist's structural puzzle. 9 weapon archetypes, 12 cord runes, 8 elixir types at 3 tiers each, 15 scar types, 5 strata with geometry shifts, 3 endings, 62 lore fragments, and a crafting system where every choice is permanent. Hiroshi will build spreadsheets. The finite resource system means optimal play requires planning the entire run before the first harvest. The Transcendence ending is the ultimate completion goal.

**Predicted experience:** Hiroshi will spend 2-3 hours in the forge before his first descent, mapping out material allocation. He will restart twice after realizing his first build path locks him out of specific shortcuts. He will maintain a death planning sheet -- which scars to take, which to avoid, which to stack. He will love the lore; he will find the irreversible crafting anxiety-inducing and compelling in equal measure.

### P-006: Eleanor Vance -- The Loyal Strategist

**Why this game fits:** Eleanor values depth, planning, and fair systems. The crafting system is the deepest strategic layer -- it is a 40-hour optimization problem played out through combat and exploration. No gambling, no gacha, no energy timers. The geometry-shift system rewards careful planning (invest in fire runes now to open the meltdown path later). The Crimson Consequence system rewards strategic thinking about death itself.

**Predicted experience:** Eleanor will play methodically, clearing each stratum fully before descending. She will rarely die unintentionally because she over-prepares. When she does die, she will treat the scar as a strategic outcome, not a punishment. She will complete the game once, thoroughly, and consider the Accord ending the most satisfying. She will appreciate the premium model with no predatory monetization.

### P-008: David Park -- The Achievement Hunter

**Why this game fits:** The game offers clear, trackable completion metrics: all 9 weapons forged, all 12 runes inscribed, all 24 elixir tiers brewed, all 15 scars collected, all 5 strata cleared, all 3 endings achieved, all 62 lore fragments found, all 5 Abyssal Pearls collected. Every achievement is skill-based and deterministic -- no RNG, no time-gating.

**Predicted experience:** David will plan 3 playthroughs: one for The Harvest ending (maximum harvesting), one for The Accord (limited harvesting), and one for The Transcendence (the 100% run). He will track every material in a spreadsheet. He will appreciate that achievements are permanent and skill-locked. He will flag the 12-death cap as a design constraint that makes "collect all scars" impossible in a single run -- a constraint he will learn to accept.

### P-010: Kevin Nguyen -- The Competitive Whale

**Why this game fits:** The dual-body combat system is a skill ceiling with no upper bound. Sync attacks require frame-precise coordination between two independent action streams. The tightening sync windows (2.0s to 1.0s across strata) create a measurable skill ladder. The 4-phase final boss is a combat endurance test. No P2W shortcuts exist because no microtransactions exist.

**Predicted experience:** Kevin will mainline the critical path, optimize for damage output, and grind the dual-body sync system until he can execute Meteor Drops consistently. He will post sync-attack combo videos. He will challenge himself with no-scar runs and no-elixir runs. He will wish the game had a leaderboard or replay sharing feature.

---

## User Stories

### Exploration (8 stories)

1. As **Hiroshi (P-003)**, I want the forge-sanctuary to display a top-down map of the underworld that updates in real-time as geometry shifts occur, so that I can plan my descent route based on my current build.
2. As **David (P-008)**, I want each stratum to contain secret chambers only accessible through specific crafting combinations, so that thorough exploration with the right build is rewarded with unique materials.
3. As **Eleanor (P-006)**, I want the biomancer overlay to reveal enemy positions and material deposits within a configurable radius, so that I can scout before committing to a path.
4. As **Hiroshi (P-003)**, I want the geometry shift system to be deterministic and documented in-game through the Harmonic Archive, so that I can predict which crafting choices open which passages.
5. As **Kevin (P-010)**, I want cord traversal to support momentum-based movement (swing, release at apex, chain to next grapple point), so that skilled traversal is faster and more satisfying than walking.
6. As **David (P-008)**, I want the 5 Abyssal Pearls to be hidden behind the most obscure geometry-shift combinations, so that finding all 5 requires deep understanding of the crafting-world interaction.
7. As **Eleanor (P-006)**, I want underwater sections that require the Pressure Lungs elixir to explore, so that preparation and planning are rewarded with optional content.
8. As **Kevin (P-010)**, I want rift anchors (checkpoints) to be placed at strategic decision points, not evenly spaced, so that route optimization is part of the skill expression.

### Core Mechanics (8 stories)

9. As **Kevin (P-010)**, I want sync attack windows to tighten from 2.0s to 1.0s across strata, so that mastery of dual-body coordination is continuously tested and escalated.
10. As **Hiroshi (P-003)**, I want 9 weapon archetypes with genuinely different movesets (not stat swaps), so that each weapon changes how combat feels and how I approach encounters.
11. As **Eleanor (P-006)**, I want the biomancer tick system (2-second command delay) to be visible on the overlay as a countdown ring, so that I can time sync attacks with precision.
12. As **David (P-008)**, I want the 15 scar types to have 3 visual tiers each, so that my character's appearance reflects my specific death history and is visually trackable.
13. As **Kevin (P-010)**, I want the cord grapple to be usable on enemies, terrain, and anchor points with physics-based momentum, so that combat and traversal merge into a single skill.
14. As **Hiroshi (P-003)**, I want the finite resource system to display total remaining quantities for each material type, so that I can budget without manual tracking (though manual tracking should be more efficient).
15. As **Eleanor (P-006)**, I want elixirs to be consumable (used on activation, not permanent buffs), so that each elixir use is a tactical decision about when and where to deploy a limited resource.
16. As **Kevin (P-010)**, I want the Gravity Swap biomancer command to work on the warrior body, so that creative repositioning during combat is a high-skill movement option.

### Narrative (5 stories)

17. As **Hiroshi (P-003)**, I want 62 lore fragments that tell the story of the absorbed civilization across all strata, so that exploration rewards narrative understanding proportional to effort invested.
18. As **Eleanor (P-006)**, I want Forge-Master Orin's transmissions to gradually reveal the Riftbinding Order's true intentions, so that the narrative twist is earned through gameplay, not cutscenes.
19. As **Hiroshi (P-003)**, I want the 5 Abyssal Pearls to contain Architect Venn's personal logs, so that the hardest-to-find lore fragments tell the most important story (the Discordance's origin).
20. As **Kevin (P-010)**, I want all cutscenes to be skippable after first viewing, so that replays for different endings are not slowed by narrative I have already seen.
21. As **David (P-008)**, I want the 3 endings to be determined by gameplay actions (materials harvested after crisis point, Abyssal Pearls collected, scar count) rather than dialogue choices, so that the ending reflects how I played.

### Progression (6 stories)

22. As **David (P-008)**, I want 48 achievements covering combat (sync attack mastery, boss no-hit), exploration (all strata, all secrets), crafting (all weapons, all runes, all elixirs), and lore (all fragments, all endings), so that 100% completion is a multi-faceted goal.
23. As **Hiroshi (P-003)**, I want the biomancer mastery tiers to unlock at specific soul-capacity thresholds (which decrease as scars accumulate), so that engaging with the Crimson Consequence system directly improves the dual-body combat.
24. As **Kevin (P-010)**, I want each stratum boss to have a challenge condition (no elixirs, no scars gained in that stratum, under X minutes) that rewards a unique weapon variant, so that mastery has tangible, equippable rewards.
25. As **Eleanor (P-006)**, I want the forge-sanctuary to visually evolve through 6 stages as I harvest more materials, so that my base of operations reflects my progress without relying on UI counters.
26. As **David (P-008)**, I want a New Game+ that randomizes material locations while keeping total quantities fixed, so that replays maintain the strategic planning element without being identical.
27. As **Hiroshi (P-003)**, I want the Transcendence ending to require all 5 Abyssal Pearls, no Stratum 4-5 scars, and Biomancer Mastery Tier 5, so that the true ending rewards the most thorough and skillful players.

### Accessibility (4 stories)

28. As a player with motor impairments, I want an assist mode that extends sync attack windows to 3.0s (from 1.0s minimum) and slows the biomancer tick to 4 seconds, so that dual-body coordination is achievable without trivializing the strategic layer.
29. As **David (P-008)**, I want fully remappable controls with separate binding sets for warrior actions and biomancer overlay commands, so that my preferred control layout is supported.
30. As **Eleanor (P-006)**, I want all lore fragments available as text transcripts in addition to audio, so that no narrative content is audio-only and I can read at my own pace.
31. As a player with color vision deficiency, I want the biomancer overlay to use shape and pattern (circles for gravity wells, triangles for spikes, squares for shields) in addition to color, so that the tactical layer is readable without color perception.

### Social & Community (4 stories)

32. As **Kevin (P-010)**, I want a replay viewer that records combat inputs for both warrior and biomancer simultaneously, so that I can share dual-body combat sequences with the community.
33. As **David (P-008)**, I want build-sharing via a code system that encodes weapon, runes, elixirs, and scar loadout, so that players can compare and discuss crafting strategies.
34. As **Eleanor (P-006)**, I want asynchronous messages (like Dark Souls soapstones) that other players can find in the underworld, so that the community helps each other with geometry-shift hints and material locations.
35. As **Kevin (P-010)**, I want no microtransactions whatsoever, so that I can champion the game as a pure skill experience where money does not override mastery.

---

## Monetization

### Revenue Model: Premium at $49.99

**Why this model fits this game:**
- The irreversible crafting system is inherently strategic -- no monetizable shortcut exists without destroying the core tension
- Finite resources that do not respawn are incompatible with boost potions, stamina refills, or material packs
- The target audience (P-003, P-006, P-008, P-010) values fair, complete, premium experiences
- Soulslike and strategy players expect and prefer premium pricing -- it signals quality and design intentionality
- The dual-body combat system is a pure skill expression -- monetizing it would undermine the game's identity

### Pricing & DLC Roadmap

| Product | Price | Content | Target Window |
|---------|-------|---------|--------------|
| Base Game | $49.99 | Full campaign, 5 strata, 9 weapons, 12 runes, 3 endings | Launch |
| Digital Deluxe | $64.99 | Base + art book + soundtrack + "Rift Forerunner" cord skin | Launch |
| DLC 1: "The Forgotten Stratum" | $14.99 | 1 new stratum between 3-4, 2 weapons, 3 runes, 1 ending, 14 lore fragments | Month 6 |
| DLC 2: "Architect's Fall" | $14.99 | Prequel campaign (play as Architect Venn during the civilization's absorption), 2 weapons, new scar types | Month 12 |
| Complete Edition | $64.99 | Base + both DLCs | Month 14 |

### Revenue Projections (4 Scenarios)

| Scenario | Year 1 Units | Year 1 Revenue | Year 2 (w/ DLC) | Total (2yr) | Assumptions |
|----------|-------------|---------------|-----------------|------------|-------------|
| **Modest** | 70,000 | $2.8M | $1.0M | $3.8M | Niche appeal, word-of-mouth only, 12% DLC attach |
| **Baseline** | 200,000 | $8.0M | $3.2M | $11.2M | Moderate marketing, positive reviews, 22% DLC attach |
| **Strong** | 500,000 | $20.0M | $8.5M | $28.5M | Strong reviews, influencer coverage, 28% DLC attach |
| **Breakout** | 1,200,000 | $48.0M | $22.8M | $70.8M | Viral, award nominations, 32% DLC attach + complete edition |

**Break-even at ~56,000 units ($2.2M) against total development budget of $2.4M (see Production Plan).**

---

## Production Plan

### Team

| Role | Count | Phase | Monthly Cost (Loaded) |
|------|-------|-------|----------------------|
| Game Director / Lead Design | 1 | All | $12,000 |
| Combat Designer (Dual-Body Specialist) | 1 | All | $10,000 |
| Systems Designer (Crafting + Geometry) | 1 | All | $9,500 |
| Level Designer | 2 | Months 3--16 | $8,500 each |
| Narrative Designer | 1 | Months 1--14 | $9,000 |
| Programmers (Combat + AI) | 2 | All | $10,000 each |
| Programmers (Crafting Systems + Geometry) | 1 | Months 2--16 | $9,500 |
| Programmer (Biomancer Overlay + UI) | 1 | Months 2--16 | $9,500 |
| Engine / Rendering Programmer | 1 | Months 1--6, 14--16 | $11,000 |
| 3D Artists (Environment -- Underworld) | 2 | Months 3--14 | $8,000 each |
| 3D Artists (Environment -- Forge-Sanctuary) | 1 | Months 3--14 | $8,000 |
| 3D Artists (Character + Enemy) | 2 | Months 2--16 | $8,500 each |
| VFX Artist (Gravity + Rift Effects) | 1 | Months 6--16 | $8,500 |
| Technical Artist | 1 | Months 2--16 | $9,000 |
| Audio Designer / Composer | 1 | Months 4--16 | $7,500 |
| QA Lead | 1 | Months 8--18 | $7,000 |
| QA Testers | 2 | Months 10--18 | $5,000 each |
| Producer | 1 | All | $10,000 |

**Total team: 23 people peak (months 6--14)**

### Timeline (18-month production)

| Month | Milestone | Key Deliverables |
|-------|-----------|-----------------|
| 1 | Prototype | Warrior combat + cord physics, biomancer overlay placeholder, basic dual-body sync trigger |
| 2 | Prototype Extended | Sync attack system (3 sync types), crafting system skeleton, first geometry shift test |
| 3 | Vertical Slice | Stratum 1 (Chitin Warrens) playable end-to-end, 1 boss (Brood Matron), forge-sanctuary functional |
| 4 | Pre-Production Complete | All 5 strata greyboxed, 28 enemy types finalized, design doc locked, geometry-shift rules documented |
| 5 | Production Phase 1 | Strata 1--2 art pass, 10 enemy types implemented, cord rune system (gravity element) online |
| 6 | Production Phase 1 | Weapon forging complete (all 9 archetypes), elixir brewing system online, biomancer mastery tier 1--2 |
| 7 | Production Phase 2 | Strata 3--4 greybox complete, 20 enemy types implemented, cord runes (fire + phase elements) online |
| 8 | Production Phase 2 | Geometry-shift system fully operational across all strata, Crimson Consequence system integrated |
| 9 | Production Phase 3 | Strata 1--4 art pass, all tier 1--3 systems functional, QA begins |
| 10 | Production Phase 3 | Boss fights 1--3 fully scripted and tuned, Stratum 5 greybox complete |
| 11 | Production Phase 3 | Boss fights 4--5 fully scripted, all 12 cord runes implemented, all 24 elixir tiers brewable |
| 12 | Alpha | Full game playable, all systems integrated, internal testing begins, geometry-shift QA matrix |
| 13 | Alpha Iteration | Dual-body combat tuning, sync window timing calibration, biomancer tick consistency pass |
| 14 | Beta | Feature complete, content complete, external playtesting begins, forge-sanctuary visual evolution pass |
| 15 | Beta Iteration | Playtest feedback integration, difficulty curve tuning across strata, performance optimization |
| 16 | Release Candidate | Cert submission (PlayStation, Xbox), Steam submission, day-1 patch prep |
| 17 | Launch | Game ships, day-1 patch deployed, hotfix support begins |
| 18 | Post-Launch | Hotfixes, community engagement, DLC 1 pre-production begins |

### Budget Breakdown

| Category | Cost | Notes |
|----------|------|-------|
| Salaries (18 months, 23 FTE peak) | $1,780,000 | Blended rate ~$8,900/mo avg |
| Unreal Engine 5 royalties | $0 (first $1M gross revenue free) | 5% after $1M |
| Software & Tools | $48,000 | Perforce, Jira, Adobe CC, Houdini, Wwise |
| Hardware (dev kits, workstations) | $72,000 | 2 PS5 dev kits, 2 Xbox dev kits, 18 workstations |
| QA & Playtesting | $55,000 | External QA contractor, playtest facility rental, dual-body control focus groups |
| Audio (recording, VO, music production) | $62,000 | Studio time, 4 VO actors, live ensemble for Stratum 4--5 music |
| Marketing | $140,000 | Trailers (3 -- combat, crafting, story), convention presence (2), influencer outreach, PR firm retainer |
| Operations & Overhead | $85,000 | Office/incorporation/legal/accounting/insurance |
| Contingency (10%) | $228,000 | |
| **Total** | **$2,470,000** | |

---

## Technical Requirements

### Platform Specifications

| Spec | PC Minimum | PC Recommended | PlayStation 5 | Xbox Series X |
|------|-----------|---------------|--------------|--------------|
| **OS** | Windows 10 64-bit | Windows 11 64-bit | PS5 system software | Xbox OS |
| **CPU** | Intel i5-9600K / AMD Ryzen 5 3600 | Intel i7-11700K / AMD Ryzen 7 5800X | Custom AMD Zen 2 (locked) | Custom AMD Zen 2 (locked) |
| **RAM** | 16 GB | 32 GB | 16 GB GDDR6 | 16 GB GDDR6 |
| **GPU** | GTX 1070 / RX 5700 | RTX 3080 / RX 6800 XT | Custom RDNA 2 (locked) | Custom RDNA 2 (locked) |
| **Storage** | 45 GB SSD | 45 GB NVMe SSD | 45 GB SSD | 45 GB SSD |
| **Target Resolution** | 1080p / 30 FPS | 1440p / 60 FPS | 4K/30 or 1440p/60 | 4K/30 or 1440p/60 |

### Key Technical Challenges

| Challenge | Risk | Mitigation |
|-----------|------|-----------|
| **Dual-body real-time + overlay rendering** | High -- rendering two simultaneous perspectives (third-person warrior + top-down overlay) doubles draw call pressure | Overlay renders at reduced resolution (720p upscaled) using a separate scene capture camera. Overlay updates at 30 FPS while warrior renders at 60 FPS. Profiled monthly from month 2. |
| **Physics-based cord simulation in combat** | High -- rope physics interacting with enemies, terrain, and gravity wells creates unpredictable edge cases | Pre-simulated cord states for common actions (grapple, whip, block). Real-time rope sim only during swing traversal. Cord damage uses capsule collision, not per-segment. Tested with 200+ edge cases in month 3. |
| **Geometry-shift system with deterministic state** | Medium -- the underworld must track which geometry is open/closed based on crafting history and maintain this consistently across sessions | Geometry state stored as a bitfield per stratum (128 bits covers all possible states). Loaded at stratum entry. No procedural generation -- all states are hand-authored. Validation tool runs in-editor to verify all reachable states. |
| **Biomancer tick system timing consistency** | Medium -- the 2-second command delay must be frame-rate independent | Tick timer uses unscaled delta time, not frames. Commands queue in a fixed-rate simulation step (30 Hz). Visual feedback (countdown ring) interpolates for smooth display. Tested at 30, 60, and 120 FPS. |
| **Non-Euclidean geometry in Stratum 5** | High -- impossible spaces (rooms larger on inside, connections that should not exist) break standard spatial culling and streaming | Stratum 5 uses portal-based rendering (each doorway is a separate render pass). No continuous space -- rooms are isolated scenes connected by portals. Streaming loads only the current room + visible portals. Custom tech, prototyped in month 1. |
| **Nanite/Lumen on minimum spec (GTX 1070)** | High -- UE5 features may not maintain 30 FPS on minimum spec hardware | Scalability tiers: Low uses traditional LOD + baked lighting + no Nanite. Minimum spec target validated monthly from month 3. Separate Low-spec art pipeline maintained. |
| **Finite world state persistence** | Medium -- tracking which enemies are dead, which materials are harvested, which geometry is shifted across the entire game | World state saved as a structured JSON document (enemies: array of GUIDs with alive/dead, materials: array of GUIDs with harvested/not, geometry: bitfield per stratum). Save file ~200 KB. Loaded fully at game start. No dynamic streaming of world state. |
| **Sync attack input detection across two control schemes** | Low -- detecting simultaneous inputs from warrior and biomancer with correct timing | Input buffer of 150ms on sync trigger. Both warrior and biomancer input windows overlap for the sync duration. Input history log for debugging. Playtested with 50+ players in month 8. |

---

<npl-block type="reflection">
Correctness: All 12 sections present. Numbers internally consistent -- budget ($2.47M) matches break-even calculation (56,000 units x $49.99 = $2.8M gross, ~$2.2M net after platform cut). Material totals (87 bone, 62 crystal, 44 soul-fragments, 103 plants, 5 pearls) are finite and tracked. Scar system has a hard cap (12 deaths before soul capacity floor of 40). Revenue projections use realistic DLC attach rates.
Edge cases: Dual-body death (both bodies simultaneously) handled via Rift Scar. Geometry-shift determinism documented -- no procedural generation, all states hand-authored. Cord physics edge cases noted with mitigation strategy. The 12-death cap means not all 15 scars can be collected in one run, which is intentional design (forces choice).
Security: No security concerns -- this is a game design document, not software.
Pitfalls: The dual-body combat system is the highest design risk -- it requires players to manage two simultaneous action streams which may be overwhelming. Mitigated by the biomancer tick system (2s delay reduces real-time pressure) and the sync trigger buffer (1.5s--1.0s window). Persona selection is mobile-oriented but behavioral fit is strong -- all four personas value depth, fair systems, and skill expression regardless of platform.
Improvements: Could expand NG+ mechanics beyond material randomization. Could add cooperative dual-body play (two players controlling one spellsword). Could detail the 28 enemy types with full AI behavior trees. Could add a standalone accessibility section beyond the 4 user stories.
Refactors: Document structure follows the established 12-section format from the cursed-paladin-bayou reference.
Documentation: This IS the documentation.
Clarifications: The absorbed civilization's lore draws from the premise's kraken-spawn and rift-plane concepts. The Discordance as a living entity resolves the "why does the dungeon not respawn" question with narrative justification.
TODOs: DLC 1 and 2 content would need separate design passes post-launch. Enemy AI behavior trees need detailed specification during pre-production (month 4). Stratum 5 portal rendering system needs a dedicated technical prototype (month 1).
</npl-block>
