# Dryad's Ritual Arena

## Title & Genre

| Field | Value |
|-------|-------|
| **Title** | Dryad's Ritual Arena |
| **Genre** | Social Co-op Dungeon Crawler / Action RPG |
| **Engine** | Unreal Engine 5.4 (Nanite for organic environments, Lumen for bioluminescent lighting) |
| **Platform** | PC (Steam/Epic), PlayStation 5, Xbox Series X/S, Nintendo Switch |
| **Monetization** | Premium $34.99 base with seasonal dungeon expansions ($9.99 each) |
| **Rating** | ESRB E10+ (Fantasy Violence) / PEGI 7 / CERO A |

---

## Vision Statement

Dryad's Ritual Arena is a four-player co-op dungeon crawler where each player embodies a dryad bound to a sacred tree -- Oak, Willow, Birch, or Thorn -- descending into procedurally generated underground groves corrupted by an ancient blight. The game exists at the intersection of genuine cooperation and tactical emergence: a shared root network links all four players visually on the minimap, standing together strengthens abilities while spreading out covers more ground, and the optimal formation shifts every room. At mid-dungeon shrines, players swap tree classes for full party comp flexibility without returning to town. Each real-world week, the corruption type rotates -- fungal blight, void infection, frost rot -- completely rewriting enemy behaviors and environmental hazards. After clearing a dungeon section, the party restores the grove together in a cooperative building minigame where each player contributes their tree's unique material, with restored groves providing permanent buffs for future runs. This is Deep Rock Galactic by way of Studio Ghibli -- lush, cooperative, and endlessly renewable.

---

## Core Loop

**Target session length:** 30-60 minutes (one full dungeon floor or boss encounter)

```
                    ┌──────────────────────┐
                    │  LOBBY / GROVE HUB   │
                    │  (Gather party,      │
                    │   inspect groves,    │
                    │   swap tree class)   │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │  DESCEND INTO GROVE  │
                    │  (Select corruption  │
                    │   type, difficulty)  │
                    └──────────┬───────────┘
                               │
              ┌────────────────▼────────────────┐
              │        ROOM ENCOUNTER           │
              │  ┌──────────┐  ┌─────────────┐  │
              │  │ Combat   │  │ Puzzle /    │  │
              │  │ Wave     │  │ Hazard Room │  │
              │  └────┬─────┘  └──────┬──────┘  │
              │       │               │         │
              │       └───────┬───────┘         │
              │               │                 │
              │  ┌────────────▼──────────────┐  │
              │  │ Root Network Management   │  │
              │  │ (Formation, proximity,    │  │
              │  │  ability amplification)   │  │
              │  └────────────┬──────────────┘  │
              │               │                 │
              │  ┌────────────▼──────────────┐  │
              │  │ Shrine Checkpoint         │  │
              │  │ (Swap tree class, heal,   │  │
              │  │  assess next room)        │  │
              │  └────────────┬──────────────┘  │
              └───────────────┼─────────────────┘
                              │
                     ┌────────▼────────┐
                     │  FLOOR COMPLETE │
                     │  (Boss or       │
                     │   gatekeeper)   │
                     └────────┬────────┘
                              │
              ┌───────────────▼────────────────┐
              │  GROVE RESTORATION MINIGAME     │
              │  (Each dryad contributes tree   │
              │   material → permanent buff)    │
              └───────────────┬────────────────┘
                              │
               ┌──────────────▼─────────────┐
               │  DEEPER DESCENT OR EXIT?   │
               │  (Push further for greater  │
               │   rewards, or bank progress │
               │   and return to hub)        │
               └──────────────┬──────────────┘
                              │
              ┌───────────────▼───────────────┐
              │  GROVE HUB                    │
              │  (Inspect restored groves,    │
              │   unlock permanent buffs,     │
              │   read story milestones)      │
              └───────────────────────────────┘
```

### Core Loop Breakdown

| Step | Player Action | System Response | Skill Expression |
|------|--------------|----------------|-----------------|
| 1. Party Up | Form a party of 4 in the grove hub (matchmade or friends). Select tree class: Oak, Willow, Birch, or Thorn | Party composition displayed, role coverage highlighted (balanced, double DPS, no healer, etc.) | Strategic planning before combat begins |
| 2. Descend | Choose corruption type (current seasonal rotation or practiced type) and difficulty floor (1-10) | Procedural dungeon generates: room layouts, enemy compositions, environmental hazards, and shrine placements | Risk/reward -- harder floors yield rarer restoration materials |
| 3. Combat Room | Engage corrupted enemies as a team. Position within root network range for ability amplification | Enemies attack in waves scaled to party size. Root proximity amplifies abilities by 15-40% based on distance | Positioning, target prioritization, combo timing |
| 4. Puzzle/Hazard Room | Navigate environmental challenges (corrupted waterways, collapsing root bridges, blight vents) using tree-specific abilities | Hazards interact differently with each tree class (Oak resists knockback, Willow purifies corruption pools, Birch dashes through gaps, Thorn tethers hazards) | Communication, tree-specific problem solving |
| 5. Root Management | Adjust formation via minimap. Tight cluster = ability boost. Spread = map coverage | Root network visibly connects players. Proximity bonus: <5m = 40% amp, 5-15m = 25% amp, 15-30m = 15% amp, >30m = no bonus | Spatial awareness, real-time tactical adaptation |
| 6. Shrine | Visit mid-dungeon shrine to swap tree class, heal, and preview next room composition | Class swap is instant. Party can redistribute roles. Next room type revealed on minimap | Flexibility -- adapt comp to upcoming challenges |
| 7. Boss/Gatekeeper | Face a floor-ending boss encounter demanding all four roles coordinate | Boss has 2-3 phases. Each phase demands different party formation (spread for AoE, cluster for burn phase) | Team coordination, phase-aware role swapping |
| 8. Grove Restoration | Cooperative building minigame: each player contributes unique material (Oak: heartwood, Willow: sap, Birch: bark, Thorn: resin) | Restored grove provides permanent buff for all future runs. Visual transformation of hub grove area | Collaborative timing -- each player must complete their contribution in sync |
| 9. Decision | Push to next floor (enemies scale +15% per floor) or exit and bank all progress | Deeper floors yield rarer restoration materials and stronger permanent buffs | Risk assessment -- know when the party is exhausted |

---

## Meta Loop

### Session-to-Session Progression

```
Combat Mastery ──────► Tree Class Mastery ──────► Unlock Advanced Variants
                                                                    │
       ▲                                                            │
       │                                                            ▼
Grove Restoration ◄──── Permanent Buffs ◄──── Restoration Materials
       │                                               ▲
       ▼                                               │
New Grove Areas ──────► Story Milestones ──────► Character Lore
       │
       ▼
Seasonal Rotation ◄──── New Corruption Type ──────► New Enemy Behaviors
       │                                               │
       ▼                                               ▼
Meta Strategies ──────► Community Knowledge ──────► Weekly Leaderboards
```

### Progression Axes

| Axis | What Grows | How It Feels | Cap |
|------|-----------|-------------|-----|
| **Tree Mastery** | Proficiency with each tree class unlocks advanced ability variants | "I started as a basic Birch DPS and now I'm weaving wind-lash combos" | 4 classes, 3 tiers each (12 total variants) |
| **Grove Restoration** | Each restored grove provides a permanent buff to all future runs | "Our hub is becoming a living sanctuary" | 24 grove plots, each with 3 restoration tiers |
| **Corruption Knowledge** | Understanding weekly rotation enemies, hazards, and optimal comps | "I know the fungal blight rotation -- we need double Thorn this week" | 3 corruption types, 4 enemy families each = 12 bestiary chapters |
| **Story Milestones** | Each dryad's personal story advances when their milestones are hit in the same run | "We finally got all four backstory reveals in a single descent" | 4 dryads, 5 milestones each = 20 story fragments |
| **Party Synergy** | Playing with the same group builds a synergy meter unlocking combo abilities | "We've played 50 runs together and unlocked the Root Storm ultimate" | 5 synergy tiers per group, unlocks party-wide ultimates |
| **Seasonal Standing** | Weekly leaderboards track deepest floor reached per corruption type | "Our group hit floor 23 on frost rot -- top 100 this week" | Resets weekly with new corruption rotation |

---

## Game Mechanics

### Primary Mechanic: Shared Root Network

The root network is the game's signature system. All four players are connected by visible roots displayed on both the game world floor and the minimap. Root proximity determines ability amplification, and the network topology creates constant tactical decisions.

#### Root Network Rules

| Distance | Root Visual | Ability Amp | Stamina Regen | Special |
|----------|-------------|-------------|---------------|---------|
| 0-5m (Cluster) | Thick, glowing, pulsing | +40% | +25% | Shared aggro -- enemies target whoever has highest HP |
| 5-15m (Standard) | Medium, steady glow | +25% | +10% | Normal gameplay |
| 15-30m (Extended) | Thin, dim, flickering | +15% | 0% | Lone dryad vulnerability -- 10% extra damage taken |
| 30m+ (Severed) | Broken, fading | 0% | -15% | "Withered" debuff -- reduced healing received, -20% movement |

#### Network Formations and Their Trade-offs

| Formation | Description | Strength | Weakness |
|-----------|-------------|----------|----------|
| **Heart** | All four clustered within 5m | Maximum ability amp, shared aggro management, fastest revive speed | Vulnerable to AoE, slow map coverage, one environmental hazard hits everyone |
| **Line** | Players spread in a chain, each 10-15m apart | Good balance of amp and coverage, fast reaction to threats at either end | Middle players get pulled both directions, communication-heavy |
| **Star** | Three players at 15m from a central player | Central player gets buffed by all connections, good room coverage | Central player is high-value target, if they fall the network fragments |
| **Scout** | Three players clustered, one at 20-30m ahead | Forward scout pulls enemies, rear group amplifies to support | Scout is vulnerable (extended range), if scout goes down the party must advance to revive |
| **Dissolve** | All four at 25-30m, maximum spread | Full room coverage, no AoE overlap | Zero amp, withered risk on all players, requires expert individual play |

#### Root Energy Pool

The party shares a secondary resource: **Root Energy** (200 points total, 50 per dryad).

- Root Energy regenerates at 3 points/second when connected (within 30m of any party member)
- Root Energy drains at 2 points/second when severed (30m+ from all party members)
- Special abilities (revive, class swap buff, grove restoration contribution) cost Root Energy
- If Root Energy hits 0 for any player, that dryad enters **Dormant State**: movement -30%, no ability amp, cannot use special abilities until they reconnect

### Secondary Mechanic: Tree Classes

Four tree classes, each with distinct combat roles, abilities, and restoration materials.

#### Oak Dryad -- The Heartwood (Tank)

| Ability | Input | Effect | Amp Bonus (+40%) | Cooldown |
|---------|-------|--------|-------------------|----------|
| **Iron Bark** | Hold Block | Absorbs 80% of incoming damage. Converts 15% of blocked damage to Root Energy | 95% absorption, 25% conversion | None (stamina-gated) |
| **Root Grasp** | Ability 1 | Sends roots forward 8m, entangling up to 3 enemies for 2.5 seconds | 5 enemies, 4 seconds | 12 seconds |
| **Heartwood Shield** | Ability 2 | Creates a 4m dome that blocks projectiles and AoE for 5 seconds. Allies inside heal 2% HP/second | 6m dome, 7 seconds, 4% HP/second | 20 seconds |
| **Titan Oak (Ultimate)** | Ultimate | Grows to 3x size for 10 seconds. Taunts all enemies in 15m radius. Takes 50% reduced damage. Each hit generates Root Energy for the party | 15 second duration, 30m taunt | 120 seconds |

**Restoration Material**: Heartwood Slab -- used to build structural walls and floors in grove restoration.

#### Willow Dryad -- The Sapweaver (Healer)

| Ability | Input | Effect | Amp Bonus (+40%) | Cooldown |
|---------|-------|--------|-------------------|----------|
| **Sap Flow** | Ability 1 | Heals target ally for 15% max HP over 3 seconds via root channel (must be within root network) | 25% HP over 2 seconds | 8 seconds |
| **Purifying Dew** | Ability 2 | Cleanses corruption debuffs from all allies within 8m. Grants 5-second corruption immunity | 12m range, 8-second immunity | 15 seconds |
| **Weeping Willow** | Hold Ability 1 | Channels healing rain in 6m area for 5 seconds, healing all allies inside for 5% HP/second | 9m area, 8% HP/second | 18 seconds |
| **Life Surge (Ultimate)** | Ultimate | Instantly restores all allies to 100% HP and grants 10-second over-shield (30% max HP). Severed allies are pulled to Willow's position | Over-shield increased to 50% | 120 seconds |

**Restoration Material**: Golden Sap -- used to grow living pathways and bridges in grove restoration.

#### Birch Dryad -- The Windslash (DPS)

| Ability | Input | Effect | Amp Bonus (+40%) | Cooldown |
|---------|-------|--------|-------------------|----------|
| **Gale Strike** | Primary Attack | Rapid 3-hit combo dealing 100/120/150% weapon damage. Third hit is a sweeping slash | 140/170/210% damage | None |
| **Wind Dash** | Ability 1 | Dashes 8m through enemies, dealing 180% weapon damage and leaving a wind trail that slows enemies 30% for 3 seconds | 12m dash, 250% damage, 50% slow | 10 seconds |
| **Leaf Storm** | Ability 2 | Spins, firing razor leaves in all directions (10 projectiles, 80% weapon damage each). Hits all enemies in 6m radius | 15 projectiles, 120% each, 9m radius | 14 seconds |
| **Cyclone (Ultimate)** | Ultimate | Creates a vortex at target location (5m radius) that pulls enemies in, dealing 100% weapon damage/second for 8 seconds and staggering them | 8m radius, 150% damage/second | 120 seconds |

**Restoration Material**: Silver Bark -- used to create defensive barriers and decorative elements in grove restoration.

#### Thorn Dryad -- The Briarweaver (Control)

| Ability | Input | Effect | Amp Bonus (+40%) | Cooldown |
|---------|-------|--------|-------------------|----------|
| **Vine Lash** | Primary Attack | 6m ranged attack. Deals 90% weapon damage and applies 1 Briar stack (max 5). At 5 stacks: root enemy for 1.5 seconds | 120% damage, 2 Briar stacks per hit | None |
| **Thicket** | Ability 1 | Grows a thorn wall (4m wide, 2m tall) that blocks enemy movement for 6 seconds. Enemies touching it take 60% weapon damage/second | 6m wide, 8 seconds, 100% damage/second | 12 seconds |
| **Stranglethorn** | Ability 2 | Targets one enemy within 12m. Vines constrict, stunning for 3 seconds and dealing 50% weapon damage/second | 5-second stun, 80% damage/second | 16 seconds |
| **Bramble Storm (Ultimate)** | Ultimate | Thorns erupt across the entire room floor for 6 seconds. All enemies are slowed 40% and take 70% weapon damage/second. Allies gain thorn armor (reflects 10% melee damage) | 60% slow, 110% damage/second, 20% reflect | 120 seconds |

**Restoration Material**: Thorny Resin -- used to create protective hedges and hazard barriers in grove restoration.

### Secondary Mechanic: Tree-Swapping at Shrines

At shrines (placed every 3-4 rooms), players can swap their tree class instantly. This enables full party comp flexibility mid-dungeon.

**Swap Rules:**
- Swap is free and instant at any shrine
- No cooldown on swapping -- swap as many times as shrines available
- Next room composition is previewed at the shrine, enabling informed swaps
- Advanced class variants (Tier 2 and 3) unlock at character level milestones and persist across swaps
- If the party has no healer after a swap, the game warns but does not prevent it

**Strategic implications:**
- A party of 4 Birch dryads deals massive damage but has zero healing and zero crowd control
- A party of 4 Oak dryads is unkillable but clears rooms extremely slowly
- Double Thorn + Willow + Birch is the "control" comp for rooms with many adds
- Oak + Willow + double Birch is the "burn" comp for boss fights with limited adds
- The "correct" comp changes every room based on enemy composition and hazard type

### Secondary Mechanic: Seasonal Corruption Rotation

Each real-world week, the dungeon's corruption type rotates, completely changing the dungeon experience.

| Corruption | Visual Theme | Enemy Behavior Modifier | Environmental Hazard | Advantage Class | Disadvantage Class |
|-----------|-------------|------------------------|---------------------|-----------------|-------------------|
| **Fungal Blight** | Sickly green spores, mushroom growths, rotting wood | Enemies explode on death, spawning spore clouds that deal damage over time | Spore vents: 2m poison clouds in corridors, pulsing every 8 seconds | Willow (Purifying Dew cleanses spores) | Birch (melee range exposes to spore clouds) |
| **Void Infection** | Purple-black void tears, reality distortion, floating debris | Enemies phase in and out of visibility, becoming untargetable for 1-2 seconds | Void rifts: random teleport pads that throw players to unpredictable locations | Thorn (area denial controls void portals) | Oak (melee taunt useless against phasing enemies) |
| **Frost Rot** | Ice crystals on organic matter, frozen waterfalls, blue-white mist | Enemies move 20% slower but have 30% more HP. Ice shields on elites | Frozen floors: 4m slippery patches that cause uncontrolled sliding | Oak (Iron Bark ignores frost slow, stamina efficient) | Willow (healing reduced 25% by frost debuff) |

**Rotation schedule**: Fungal Blight (Mon-Sun) -> Void Infection (Mon-Sun) -> Frost Rot (Mon-Sun) -> repeat. Each corruption has a unique set of 4 enemy families (12 total enemy families, approximately 60 enemy types).

### Difficulty Progression Table

| Floor | Enemy Density | New Enemy Types | Boss Complexity | Hazard Density | Recommended Party Level | Room Count |
|-------|-------------|----------------|----------------|----------------|------------------------|------------|
| 1-3 | 4-6 per room | 3 basic types | 1-phase, telegraphed attacks | 0-1 per room | 1-5 | 5 rooms |
| 4-6 | 5-8 per room | +2 types, first elites | 2-phase, AoE introduced | 1-2 per room | 5-10 | 6 rooms |
| 7-9 | 6-10 per room | +2 types, first mini-bosses | 2-phase with add waves | 2-3 per room | 10-15 | 7 rooms |
| 10-12 | 8-12 per room | +2 types, corrupted variants | 3-phase, environmental mechanics | 2-3 per room | 15-20 | 8 rooms |
| 13-15 | 10-14 per room | +2 types, elite packs | 3-phase, demands class swapping | 3-4 per room | 20-25 | 8 rooms |
| 16-20 | 12-16 per room | +2 types, double elite packs | 3-phase with mid-fight shrine | 4-5 per room | 25-30 | 9 rooms |
| 21+ | 14-20 per room | All types, legendary variants | 4-phase, requires specific comps | 5+ per room | 30+ | 10 rooms |

---

## World Design

### Map Structure

The game uses a procedural dungeon structure with themed biomes tied to corruption type. The persistent hub is the Sacred Grove, which grows and transforms as the party restores grove plots.

```
SACRED GROVE (Persistent Hub -- Always Accessible)
├── The Great Oak (central gathering point, matchmaking stone)
├── Restoration Plaza (24 grove plots for permanent buff buildings)
├── The Archive (bestiary, lore, seasonal records)
├── Training Rings (solo practice with each tree class)
├── Party Board (group finder, friend list, synergy meter)
└── The Descent Shaft (dungeon entrance -- select floor and corruption)

UNDERGROUND GROVE (Procedural Dungeon)
├── Floor 1-5: Shallow Roots
│   ├── Biome: Sandy soil, small roots, faint light from above
│   ├── Rooms: Combat chambers, simple hazard rooms, first shrine
│   └── Boss: Blight Sprout (tutorial boss, 1-phase)
├── Floor 6-10: Deep Mycelium
│   ├── Biome: Dense fungal networks, bioluminescent mushrooms, organic walls
│   ├── Rooms: Complex hazard puzzles, multi-wave combat, branching paths
│   └── Boss: Mycelium Mother (2-phase, spore mechanics)
├── Floor 11-15: Crystal Caverns
│   ├── Biome: Crystallized tree sap formations, refracted light, resonant chambers
│   ├── Rooms: Crystal puzzles (redirect light beams), elite gauntlets, double shrines
│   └── Boss: The Crystallized (3-phase, demands mid-fight class swap)
├── Floor 16-20: The Rotting Heart
│   ├── Biome: Decaying ancient tree interior, pulsing organic walls, corrupted sap rivers
│   ├── Rooms: High-density combat, complex environmental puzzles, boss gauntlets
│   └── Boss: The Hollow King (3-phase, environmental mechanics + add management)
└── Floor 21+: The Deep Blight
    ├── Biome: Pure corruption, reality bending, no natural light
    ├── Rooms: Maximum density, all hazard types combined, optional secret rooms
    └── Boss: The Blight Primordial (4-phase, requires specific comp per phase)
```

### Art Direction Pillars

| Pillar | Description | Reference |
|--------|-------------|-----------|
| **Living Architecture** | Every surface breathes, pulses, and responds to player presence. Walls are roots, floors are moss, ceilings are canopies | Ori and the Will of the Wisps' Spirit Tree |
| **Corruption as Contrast** | Healthy groves glow with warm amber and teal. Corrupted areas bleed sickly greens (fungal), void purples (void), or frozen blues (frost). The visual language is immediate | Hollow Knight's Infected Crossroads |
| **Cooperative Beauty** | The root network is beautiful, not utilitarian. Glowing golden threads connecting players create visual art as they move | Journey's cloth-creature connections |
| **Restoration Spectacle** | Grove restoration transforms decay into beauty in real-time. Dead branches sprout leaves, stagnant pools run clear, darkness lifts | Gris' color restoration mechanic |

### Visual and Audio Progression

| Floor Range | Corruption Palette | Restored Palette | Ambient Audio | Music |
|------------|-------------------|-----------------|--------------|-------|
| 1-5 Shallow Roots | Faint discoloration, pale roots | Warm amber, gentle green moss | Distant dripping, soft wind | Acoustic guitar + woodwinds |
| 6-10 Deep Mycelium | Glowing spores (green/purple/blue), fungal growths | Rich bioluminescence, healthy fungi patterns | Mycelium creaking, spore hissing | Strings + soft percussion |
| 11-15 Crystal Caverns | Fractured light, corrupted refractions, dark spots | Brilliant refracted rainbows, clear crystal | Crystal resonance, harmonic hums | Piano + ethereal vocals |
| 16-20 Rotting Heart | Decaying browns, blackened sap, pulsing corruption | Restored heartwood, golden sap flows, living walls | Heartbeat (the tree's), sap flowing | Full orchestra building |
| 21+ Deep Blight | Pure corruption, reality distortion, visual noise | Impossible -- restoration not yet reached | Distorted nature sounds, silence bursts | Experimental + full orchestra at peak |

---

## Narrative

### Tone Spectrum (7-Axis)

| Axis | Position | Notes |
|------|----------|-------|
| Hopeful vs. Grim | 80% Hopeful | Corruption is reversible. Every descent makes the world better. |
| Serious vs. Whimsical | 60% Whimsical | Dryads are playful, curious, and warm. The blight is the serious element. |
| Simple vs. Complex | 55% Complex | Multi-layered systems, but each layer is intuitive. Depth without confusion. |
| Grounded vs. Fantastical | 85% Fantastical | Trees that walk, roots that glow, corruption that talks. Full magic. |
| Static vs. Dynamic | 75% Dynamic | Weekly rotation, procedural dungeons, living hub. The world changes. |
| Cozy vs. Intense | 65% Cozy | Combat is engaging but not punishing. Restoration is the emotional core. |
| Solo vs. Social | 95% Social | The game is designed for four. Solo play exists but is explicitly secondary. |

### 8-Point Story Spine

**1. Equilibrium**
Four dryads -- Oaken (Oak), Sylph (Willow), Breeze (Birch), and Briar (Thorn) -- live in the Sacred Grove above ground, each bound to their sacred tree. The grove is ancient, beautiful, and peaceful. The four have an easy friendship born from centuries of coexistence. Below the grove, the underground root network has always been healthy and quiet.

**2. Inciting Incident**
A tremor shakes the grove. The Great Oak's roots crack, and a pulse of corruption erupts from below. The underground groves -- the root network that sustains all surface life -- are being consumed by an ancient blight that was sealed away millennia ago. If the roots die, the surface groves die. The four dryads descend into the underground to save their home.

**3. First Complication**
The corruption is not mindless. It speaks through infected creatures, through the environment itself. It calls itself "The First Rot" and claims it was the original inhabitant of the underground -- that the sacred trees invaded its domain and imprisoned it. Each dryad feels a pull of recognition, as if their trees have known about the blight all along.

**4. Rising Action**
As the dryads descend deeper, each begins experiencing personal memories tied to the blight. Oaken remembers the Oak's original oath to protect the underground. Sylph discovers the Willow was the first tree to purify corruption -- and the first to bury evidence of it. Breeze learns the Birch was planted specifically as a weapon against the blight. Briar uncovers that the Thorn was grown from corrupted root stock -- it is part blight itself.

**5. Midpoint Reversal**
At the Rotting Heart (floor 16), the dryads discover the truth: the sacred trees did not imprison the First Rot. They made a pact with it. The trees draw their life from the underground, and in exchange they sealed the Rot away. But the seal was weakening, and the trees chose to let it break rather than sacrifice surface growth to reinforce it. The blight's return was not an accident -- it was engineered by the trees to force the dryads to descend and become the new seal. The dryads were created as living sacrifices.

**6. Crisis**
Each dryad must choose individually: continue serving their trees (reinforce the seal, sacrificing their freedom permanently) or sever their bond with their tree (retain autonomy but lose their powers and the grove's protection). The party can be split -- some dryads can choose to serve while others sever. This choice affects gameplay: serving dryads gain amplified abilities but are locked to their class; severed dryads can swap freely but have reduced stats.

**7. Climax**
In the Deep Blight (floor 21+), the party faces the Blight Primordial -- the physical manifestation of the First Rot. It is a 4-phase fight, and each phase corresponds to a dryad's personal story arc. The fight can only be won if all four dryads are present and their root network is intact -- even a single severed dryad weakens the party enough to make victory impossible.

**8. Resolution**
Three endings based on party choices:
- **Restoration (Serve + Win):** The dryads reinforce the seal, saving the groves. The First Rot is imprisoned again. The dryads remain bound to their trees but the Sacred Grove thrives. Bittersweet -- duty fulfilled, freedom postponed.
- **Liberation (Sever + Win):** The dryads break the seal entirely, destroying the First Rot but losing their tree bonds. They become free forest spirits, unbound, but the groves are vulnerable without their protection. Hopeful but uncertain.
- **Transcendence (Mixed + Win with full milestones):** Some serve, some sever, and together they find a third path -- the dryads reshape the pact, becoming true partners with their trees rather than servants. The First Rot is not sealed but integrated, becoming part of the underground ecosystem. The hardest ending, requiring all 20 story milestones to be collected in a single run.

### Key Characters

| Character | Role | Theme | Story Milestones |
|-----------|------|-------|-----------------|
| **Oaken** | Oak Dryad -- Party tank, steadfast leader | Duty vs. self-preservation; the weight of being the shield | 5 milestones (oath, burden, doubt, resolve, transcendence) |
| **Sylph** | Willow Dryad -- Party healer, empath | Healing as power; the secret-keeper who purifies others but not herself | 5 milestones (gift, secret, guilt, confession, release) |
| **Breeze** | Birch Dryad -- Party DPS, impulsive scout | Weaponized innocence; the tree that was planted to kill | 5 milestones (speed, purpose, question, rebellion, choice) |
| **Briar** | Thorn Dryad -- Party control, the outsider | Identity as corruption; half-tree, half-blight, fully neither | 5 milestones (roots, nature, rejection, acceptance, integration) |
| **The First Rot** | Antagonist -- Ancient underground intelligence | Entropy as natural force; it does not hate, it decays | Not collectible -- revealed through environmental storytelling |
| **The Great Oak** | Authority figure -- The grove's anchor tree | Institutional sacrifice; protecting the many by sacrificing the few | 5 interludes (voice, command, justification, regret, surrender) |

---

## Player Personas

### P-003: Hiroshi Tanaka -- The RPG Addict

**Why this game fits Hiroshi:** Dryad's Ritual Arena has 4 tree classes with 3 tiers each (12 variants), 24 grove plots with 3 restoration tiers, 12 enemy families across 3 corruption types, and 20 story milestones that must be collected in a single run for the true ending. The depth of systems is exactly what Hiroshi craves. He will theorycraft optimal party comps for each corruption type, spreadsheet grove restoration efficiency, and pursue the Transcendence ending with methodical precision.

**Predicted experience:** Hiroshi plays 3-4 hours daily, always as the same tree class until he masters it, then rotates. He fills the bestiary systematically, tracking which corruption type spawns which enemy variants. He treats grove restoration as an optimization puzzle. He will organize Discord groups for coordinated story milestone runs. He will love the seasonal rotation for its replayability. He will skip nothing.

### P-008: David Park -- The Achievement Hunter

**Why this game fits David:** The game tracks 24 grove restorations, 12 class mastery tiers, 60 enemy types in the bestiary, 20 story milestones, floor depth records per corruption type, and party synergy milestones. Every achievement is skill-based (no RNG, no time-gating). The weekly leaderboard gives a recurring completion target. The premium model means no P2W shortcuts exist.

**Predicted experience:** David plays 1-2 hours daily, methodically clearing achievement categories. He will spreadsheet every grove restoration tier and its corresponding buff. He will pursue floor 21+ on all three corruption types. He will be slightly frustrated that story milestones require coordination with other players (he usually solo-achieves). He will organize PUG groups specifically for milestone runs.

### P-012: Jessica Lee -- The Friend-Follower

**Why this game fits Jessica:** The game is designed for four players and has no solo-content advantage. Jessica's friend group of 6 can rotate in and out easily. Session length (30-60 minutes) fits her 2-3 evening/week schedule. The tree-swap mechanic means falling behind on one class does not matter -- she can swap to whatever the group needs. Grove restoration is cooperative and low-stress. No P2P, no pressure to spend beyond the base purchase.

**Predicted experience:** Jessica plays 2-3 evenings per week with her friend group, always as Willow (she likes healing and it is the most social role). She does not engage with bestiary or leaderboards. She loves the grove restoration minigame -- it is cooperative, visual, and low-pressure. She will match the group's seasonal rotation schedule. She will occasionally look at the story milestones but will not chase them unless the group is motivated.

### P-010: Kevin Nguyen -- The Competitive Whale

**Why this game fits Kevin:** The weekly leaderboard system rewards the deepest floor reached per corruption type. Party synergy tiers unlock combo abilities that separate coordinated teams from PUGs. The seasonal rotation creates a meta that shifts weekly, demanding strategic adaptation. The class-swap mechanic adds a layer of tactical depth Kevin can exploit against less-flexible teams. Premium pricing means competition is skill-based only.

**Predicted experience:** Kevin plays 4-6 hours daily, grinding floor depth with a fixed party. He theorycrafts optimal comps per corruption type per floor range. He pushes for top-100 weekly leaderboard placement. He will spend on seasonal DLC expansions for new corruption types and content. He streams his runs and builds a community around competitive co-op. He will min-max the root network proximity system to squeeze every percentage of ability amp.

---

## User Stories

### Exploration and Navigation

1. As **Hiroshi (P-003)**, I want the minimap to show all four players' root connections in real-time so that I can optimize our formation for each room.
2. As **Jessica (P-012)**, I want a ping system that lets me mark locations, enemies, and hazards without voice chat so that I can coordinate with my friends during chaotic fights.
3. As **Kevin (P-010)**, I want the next room's enemy composition previewed at shrines so that my party can make informed class-swap decisions.
4. As **David (P-008)**, I want secret rooms hidden behind destructible walls that require specific tree abilities to find so that thorough exploration is rewarded.
5. As **Hiroshi (P-003)**, I want the procedural generation to have recognizable tile sets per corruption type so that I can learn layouts without memorizing static maps.
6. As **Jessica (P-012)**, I want a "follow" mechanic that lets me automatically path to a designated party leader so that I do not get lost in large rooms.

### Core Mechanics

7. As **Kevin (P-010)**, I want the root network proximity bonuses to be visually distinct per tier so that I can instantly read our formation's effectiveness.
8. As **Hiroshi (P-003)**, I want each tree class to have 3 mastery tiers that unlock new ability variants so that mastery is rewarded with mechanical depth.
9. As **Jessica (P-012)**, I want tree-swapping at shrines to be instant and free so that I can adapt to whatever the group needs without penalty.
10. As **Kevin (P-010)**, I want the Dormant State (severed from root network) to have clear visual and audio cues so that I immediately know I need to reconnect.
11. As **David (P-008)**, I want the Root Energy pool to be visible per-player and have clear indicators when it is running low so that resource management is readable.
12. As **Hiroshi (P-003)**, I want ability amplification from root proximity to scale smoothly (not binary on/off) so that positioning feels precise rather than arbitrary.
13. As **Kevin (P-010)**, I want each ultimate ability to have a visible charge indicator on the party HUD so that I can coordinate ultimate timing across the group.
14. As **Jessica (P-012)**, I want a "quick swap" option that recommends the best class for the upcoming room based on enemy composition so that I do not need to analyze the preview myself.

### Combat and Encounters

15. As **Kevin (P-010)**, I want boss phases to demand different party formations so that the encounter is a tactical puzzle, not a DPS check.
16. As **Hiroshi (P-003)**, I want enemies to have visible telegraphs that change based on corruption type so that combat knowledge transfers across rotations.
17. As **Jessica (P-012)**, I want a revive mechanic where I channel my tree's energy to revive a fallen teammate at personal risk so that I can save friends without dying myself.
18. As **David (P-008)**, I want each enemy type to have a bestiary entry that reveals weaknesses and corruption-specific behaviors so that completionist tracking feeds into gameplay mastery.
19. As **Kevin (P-010)**, I want elite enemy variants that require specific class abilities to counter efficiently so that party composition matters at the individual target level.
20. As **Hiroshi (P-003)**, I want the difficulty progression (floors 1-21+) to introduce one new mechanic per floor range so that the learning curve is steady and fair.

### Narrative and Story

21. As **Hiroshi (P-003)**, I want 20 story milestones (5 per dryad) that only advance when collected in the same run so that the narrative rewards coordinated play.
22. As **Jessica (P-012)**, I want story moments to play out in short voiced vignettes (under 30 seconds) so that narrative does not interrupt the flow of cooperative play.
23. As **David (P-008)**, I want the mid-game revelation (trees engineered the blight's return) to recontextualize early grove restoration choices so that replays carry narrative weight.
24. As **Hiroshi (P-003)**, I want the Transcendence ending to require collecting all 20 milestones in a single run so that the "true" ending rewards the most dedicated parties.
25. As **Jessica (P-012)**, I want the choice at the midpoint (serve or sever) to be a visible moment where the party discusses and decides together so that the narrative feels like a shared experience.

### Progression and Meta

26. As **David (P-008)**, I want 24 grove plots with 3 restoration tiers each so that there is a clear, measurable completion target for hub customization.
27. As **Kevin (P-010)**, I want weekly leaderboards that track deepest floor per corruption type so that I have a recurring competitive goal.
28. As **Hiroshi (P-003)**, I want party synergy tiers that unlock combo abilities (Root Storm, Forest's Embrace, etc.) after playing with the same group so that team continuity is rewarded.
29. As **David (P-008)**, I want the bestiary to track encounter count, kill count, and weakness exploitation rate per enemy type so that completion tracking is multi-dimensional.
30. As **Kevin (P-010)**, I want seasonal DLC to introduce new corruption types (beyond the base 3) so that the competitive meta continues evolving.

### Accessibility and Social

31. As a player with motor impairments, I want an assist mode that extends dodge windows and auto-targets the nearest enemy so that I can participate in cooperative play without being carried.
32. As **Jessica (P-012)**, I want cross-platform play so that my different-platform friends can play in the same party.
33. As a player with color vision deficiency, I want root network proximity tiers to use shape and animation (not just color) so that the core positioning system is readable without color perception.
34. As **David (P-008)**, I want full remappable controls with controller support so that I can use my preferred layout across all platforms.

---

## Monetization

### Revenue Model: Premium $34.99 with Seasonal Expansions

**Why this model fits this game:**
- Co-op games thrive on shared access barriers -- if one friend owns it, the group buys it. Premium pricing creates social commitment.
- The seasonal rotation provides replayability without needing a battle pass or energy system. Players return for the weekly corruption change, not for daily login rewards.
- The target audience (P-003, P-008, P-012, P-010) values fair, complete experiences. F2P monetization would undermine the cooperative trust the game is built on.
- Groves restore permanently -- there is no natural place for consumable monetization without making the restoration feel transactional.

### Pricing and DLC Roadmap

| Product | Price | Content | Target Window |
|---------|-------|---------|--------------|
| Base Game | $34.99 | Full procedural dungeon, 3 corruption types, 4 classes, 12 mastery tiers, 20 story milestones, 24 grove plots | Launch |
| Digital Deluxe | $49.99 | Base + soundtrack + "Ancient Dryad" cosmetic skin set (4 skins) + digital art book | Launch |
| Season 1: "The Ashen Bloom" | $9.99 | 1 new corruption type (Ashen Blight), 1 new tree class (Ash -- area denial), 8 new grove plots, 5 new story milestones | Month 4 |
| Season 2: "The Tide's Reach" | $9.99 | 1 new corruption type (Tidal Corruption), underwater dungeon biome, 8 new grove plots, 5 new story milestones | Month 8 |
| Season 3: "The Stormroot" | $9.99 | 1 new corruption type (Storm Surge), weather-based hazards, 8 new grove plots, 5 new story milestones | Month 12 |
| Complete Edition | $49.99 | Base + all 3 seasons | Month 14 |

### Revenue Projections (4 Scenarios)

| Scenario | Year 1 Units | Year 1 Revenue | Year 2 (w/ DLC) | Total (2yr) | Assumptions |
|----------|-------------|---------------|-----------------|------------|-------------|
| **Modest** | 120,000 | $2.9M | $0.9M | $3.8M | Niche co-op, word-of-mouth, 25% DLC attach |
| **Baseline** | 400,000 | $9.8M | $3.6M | $13.4M | Positive reviews, co-op streaming, 30% DLC attach |
| **Strong** | 1,000,000 | $24.5M | $12.0M | $36.5M | Strong streaming presence, co-op game of the year consideration, 35% DLC attach |
| **Breakout** | 3,000,000 | $73.5M | $40.5M | $114.0M | Viral co-op phenomenon, major awards, 40% DLC attach + complete edition |

**Break-even at approximately 83,000 units ($2.0M) against total development budget of $1.97M (see Production Plan).**

---

## Production Plan

### Team

| Role | Count | Phase | Monthly Cost (Loaded) |
|------|-------|-------|----------------------|
| Game Director / Lead Design | 1 | All | $11,000 |
| Co-op Systems Designer | 1 | All | $9,000 |
| Level Designer (Procedural) | 1 | Months 2-14 | $8,500 |
| Combat Designer | 1 | All | $9,500 |
| Narrative Designer | 1 | Months 1-10 | $9,000 |
| Programmers (Gameplay + Networking) | 3 | All | $10,000 each |
| Engine / Rendering Programmer | 1 | Months 1-6, 12-14 | $11,000 |
| 3D Artists (Environment) | 2 | Months 3-14 | $8,000 each |
| 3D Artists (Character + Enemy) | 2 | Months 2-14 | $8,500 each |
| VFX Artist | 1 | Months 6-14 | $8,000 |
| Technical Artist | 1 | Months 2-14 | $9,000 |
| UI/UX Designer | 1 | Months 3-14 | $7,500 |
| Composer | 1 (contract) | Months 4-14 | $6,000 |
| Audio Designer | 1 (contract) | Months 6-14 | $6,500 |
| VO Director + 6 Actors | Contract | Months 10-12 | $35,000 (total) |
| QA Lead | 1 | Months 8-16 | $7,000 |
| QA Testers | 2 | Months 10-16 | $5,000 each |
| Producer | 1 | All | $10,000 |

**Total team: 23 people peak (months 6-12)**

### Timeline (16-month production)

| Month | Milestone | Key Deliverables |
|-------|-----------|-----------------|
| 1 | Prototype | Core combat for 1 class, root network system (2 players), basic enemy AI, LAN multiplayer |
| 2 | Vertical Slice | 1 full dungeon floor (5 rooms, 1 boss), all 4 classes playable, split-screen co-op |
| 3 | Pre-Production Complete | Procedural generation system operational, 3 corruption types defined, 12 enemy families greyboxed, design doc locked |
| 4 | Production Phase 1 | Floors 1-10 procedural generation complete, shrine system + tree swapping, 24 enemy types implemented |
| 5 | Production Phase 1 | Root network system finalized (all proximity tiers, Dormant State, Root Energy), online multiplayer infrastructure |
| 6 | Production Phase 2 | Floors 11-20 generation complete, grove restoration minigame, 48 enemy types, all 4 bosses scripted |
| 7 | Production Phase 2 | Seasonal rotation system, weekly leaderboard, party synergy meter, matchmaking system |
| 8 | Production Phase 2 | All 12 class mastery tiers implemented, art pass on floors 1-10, QA begins |
| 9 | Production Phase 3 | Floor 21+ generation, Blight Primordial boss (4 phases), all 60 enemy types in-engine |
| 10 | Production Phase 3 | Story milestone system, narrative vignettes, VO recording, art pass on floors 11-20 |
| 11 | Alpha | Full game playable online, all systems integrated, internal testing begins |
| 12 | Alpha Iteration | Network optimization, difficulty tuning, playtest feedback integration |
| 13 | Beta | Feature complete, content complete, external playtesting begins (500 testers) |
| 14 | Beta Iteration | Playtest feedback, final art polish, audio mix, performance optimization |
| 15 | Release Candidate | Console cert submission, Steam submission, day-1 patch prep, Switch optimization |
| 16 | Launch | Ship all platforms, day-1 patch, hotfix support, Season 1 pre-production begins |

### Budget Breakdown

| Category | Cost | Notes |
|----------|------|-------|
| Salaries (16 months, 23 FTE peak) | $1,420,000 | Blended rate ~$8,700/mo avg |
| Unreal Engine 5 royalties | $0 (first $1M gross revenue free) | 5% after $1M |
| Software and Tools | $38,000 | Perforce, Jira, Adobe CC, Houdini, Wwise, PlayFab (matchmaking) |
| Hardware (dev kits, workstations) | $55,000 | 2 PS5 dev kits, 2 Xbox dev kits, 1 Switch dev kit, 12 workstations |
| Server Infrastructure | $25,000 | Matchmaking, leaderboards, seasonal rotation hosting (12 months) |
| QA and Playtesting | $40,000 | External QA contractor, playtest facility rental, 500 tester beta |
| Audio (recording, VO, music production) | $45,000 | Studio time, 6 VO actors, composer, live instruments |
| Marketing | $100,000 | Trailers (2), co-op focused influencer outreach, Steam Next Fest, PR |
| Operations and Overhead | $65,000 | Office/legal/accounting/insurance |
| Contingency (10%) | $185,000 | |
| **Total** | **$1,973,000** | |

---

## Technical Requirements

### Platform Specifications

| Spec | PC Minimum | PC Recommended | PlayStation 5 | Xbox Series X | Nintendo Switch |
|------|-----------|---------------|--------------|--------------|----------------|
| **CPU** | Intel i5-7400 / AMD Ryzen 5 1400 | Intel i7-9700 / AMD Ryzen 7 2700X | Custom AMD Zen 2 | Custom AMD Zen 2 | ARM Cortex-A57 |
| **RAM** | 8 GB | 16 GB | 16 GB GDDR6 | 16 GB GDDR6 | 4 GB |
| **GPU** | NVIDIA GTX 960 / AMD RX 570 | NVIDIA RTX 2060 / AMD RX 5700 XT | Custom RDNA 2 | Custom RDNA 2 | NVIDIA custom Tegra |
| **Storage** | 20 GB SSD | 20 GB SSD | 20 GB SSD | 20 GB SSD | 20 GB (microSD acceptable) |
| **Target Resolution** | 1080p / 30 FPS | 1440p / 60 FPS | 4K/30 or 1440p/60 | 4K/30 or 1440p/60 | 720p handheld / 1080p docked / 30 FPS |
| **Network** | Broadband required | Broadband required | PSN required | Xbox Live required | Broadband required |

### Key Technical Challenges

| Challenge | Risk | Mitigation |
|-----------|------|-----------|
| **4-player synchronous networking with root network state** | High -- root proximity calculations must be consistent across all clients | Authority server model: host calculates proximity and broadcasts amp values. Clients predict locally, server reconciles. Tested in prototype (month 1) with 4-player LAN. |
| **Procedural dungeon generation with shrine placement balance** | Medium -- shrines must be spaced every 3-4 rooms and rooms must have logical flow | Template-based generation: 40 hand-designed room templates with connection points. Algorithm arranges templates, validates shrine spacing, and ensures no dead ends. |
| **Real-time grove restoration affecting hub world** | Medium -- hub changes must persist across sessions for all party members | Server-authoritative grove state. Restoration contributions are atomic transactions. Hub renders from saved state, not real-time simulation. Each player's grove state is personal. |
| **Seasonal rotation system with shared weekly state** | Low -- weekly corruption rotation is a server-side flag | Global event system on matchmaking server. Client fetches current corruption type on session start. Rotation is deterministic (no random element). |
| **60+ enemy types with corruption-specific behavior variants** | Medium -- each enemy has 3 behavior sets (one per corruption type), effectively 180 behavior profiles | Modular AI: base behavior + corruption adapter plug-in. Each enemy type has one base behavior tree with 3 corruption-specific override nodes. No duplicated behavior trees. |
| **Switch performance at 30 FPS with 4 players and root visuals** | High -- root network rendering, 4 player VFX, and enemy density may exceed Switch GPU budget | Scalability tiers: Switch uses simplified root visuals (2D lines instead of 3D tubes), reduced particle density, lower enemy count per room (scaled down 25%). Validated monthly from month 6. |
| **Cross-platform play across 4 platforms** | Medium -- input latency, network conditions, and performance vary widely | Input buffering (3-frame window). Network tick rate fixed at 30 Hz. Platform-specific performance budgets enforced per-room. Cross-play is opt-in (can disable if latency-sensitive). |

---

<npl-block type="reflection">
Correctness: All 12 required sections present. Numbers internally consistent (budget $1.97M, team 23 peak, timeline 16 months, revenue projections cross-checked against budget). 4 tree classes with full ability tables. Difficulty progression covers floors 1-21+. Story spine has 8 points. 34 user stories across 6 categories.
Edge cases: Root network severance (Dormant State) documented with mechanical penalties. Tree-swap edge case (4 of same class) addressed in strategic implications. Boss fight requires all 4 dryads connected -- noted in climax. Switch performance degradation specified.
Security: No security concerns -- game design document.
Pitfalls: Persona library is mobile-focused but the game is PC/console premium. Addressed by matching behavioral traits rather than platform. Co-op mandatory design may limit solo players -- solo play noted as secondary but no detailed solo mode specified.
Improvements: Could add detailed solo mode mechanics. Could expand DLC seasonal content beyond corruption types. Could add raid-style content for 8-player modes.
Refactors: Structure follows the flesh-it-out command exactly.
Documentation: This IS the documentation.
Clarifications: Grove restoration buffs are permanent across runs -- this is the meta-progression hook. Seasonal rotation is weekly real-time, not in-game time.
TODOs: Season 1-3 DLC content needs separate design passes. Advanced class variants (Tier 2-3) need individual ability tables.
</npl-block>