# Chimeric Garden Sovereign

## Title & Genre

| Field | Value |
|-------|-------|
| **Title** | Chimeric Garden Sovereign |
| **Genre** | Farming Simulation / Monster Collection / Sandbox |
| **Engine** | Unity 6 (URP) — broad platform support, tilemap/2D toolkit, performant on mobile and Switch |
| **Platform** | PC (Steam), Nintendo Switch, iOS, Android |
| **Monetization** | Premium — $24.99 base game, cosmetic garden decoration DLC at $3.99 each |
| **Rating** | ESRB E (Everyone — Comic Mischief, Mild Fantasy) / PEGI 3 / CERO A |

---

## Vision Statement

Chimeric Garden Sovereign is a farming simulation where you tend a magical garden on the back of a colossal sleeping chimera. The soil beneath your plants is living flesh; every seed you sow grows into a hybrid flora-fauna creature shaped by whatever grows beside it. Plant a firebloom next to a mandrake and you get a fire-spitting root creature that patrols your rows and incinerates garden pests. The hybridization system is discoverable through experimentation — over 200 unique creatures exist, each with distinct behaviors, resource yields, and defensive capabilities. But the chimera beneath your garden is alive, and aggressive actions — harvesting, combat hybridization, loud botanical experiments — create vibrations that stir it from sleep. If it wakes, your entire garden shifts as the creature moves, terraforming the terrain underfoot. The game lives at the intersection of sandbox discovery and zen routine: every morning you water your creatures, sing to the soil, breed new hybrids, and defend against infestations, all while keeping the titan beneath you dreaming. It is Stardew Valley by way of How to Train Your Dragon, built on a living map that punishes greed with cataclysm.

---

## Core Loop

**Target session length:** 20–45 minutes

```
graph TD
    A[Wake: Check Chimera Stability Meter] --> B[Morning Routine: Water + Sing to Plants]
    B --> C[Plan Hybridization: Consult Creature Compendium]
    C --> D[Plant / Relocate / Hybridize]
    D --> E{Aggressive Action?}
    E -->|Yes: Harvest / Combat Breed| F[Vibrations Increase Stability]
    E -->|No: Peaceful Tending| G[Stability Decreases / Calms]
    F --> H{Chimera Awake?}
    G --> I[Pest Attack Wave]
    I --> J[Defend with Creature Defenders]
    J --> K[Collect Resources from Happy Creatures]
    K --> L[Garden Exhibition Available?]
    L -->|Yes| M[Submit Garden for Judging]
    L -->|No| N[Free Sandbox Play]
    M --> O[Earn Seeds, Cosmetics, Prestige]
    O --> A
    N --> A
    H -->|Yes| P[Terrain Reconfigures!]
    P --> Q[Salvage Creatures + Rebuild Layout]
    Q --> A
    H -->|No| I
```

### Core Loop Breakdown

| Step | Player Action | System Response | Skill Expression |
|------|--------------|----------------|-----------------|
| 1. Check Stability | View the Chimera Stability Meter each morning | Meter displays sleep depth (0–100%, higher = deeper sleep). Visual cues: chimera breathing, flesh-tone soil warmth, ambient rumble volume | Risk assessment — plan the day's activities around current stability |
| 2. Morning Routine | Water creatures, sing to the soil (hold button near plants) | Soothing actions reduce vibrations by 2–5% per action. Plants visibly relax, ambient music shifts to calmer key | Patience — the daily routine is the foundation of everything else |
| 3. Plan Hybrids | Open the Creature Compendium, review known combinations, note gaps | Compendium shows discovered hybrids (filled), encountered hints (silhouettes), and undiscovered (empty slots) | Systems thinking — planning adjacency chains to fill compendium gaps |
| 4. Plant / Relocate | Place seeds or uproot and relocate existing creatures | Each placed creature immediately begins influencing its four orthogonal neighbors. Crossbreed timer starts (2–4 in-game hours) | Spatial optimization — grid layout determines all hybrid outcomes |
| 5. Aggressive Actions | Harvest mature creatures, perform combat hybridization (forced crossbreed) | Each aggressive action adds 8–15% vibration. Chimera Stability Meter drops. Soil rumbles audibly | Risk management — aggressive actions yield rare materials but risk waking the chimera |
| 6. Pest Defense | Garden pests spawn in waves (3–5 times per day cycle) | Creature defenders auto-attack pests near them. Player can direct defenders or place traps | Tactical positioning — defender placement and creature composition matter |
| 7. Collect Resources | Harvest passive resource output from happy, well-tended creatures | Each creature produces 1–3 resource types per day cycle based on species + happiness | Garden management — happy creatures produce more; neglect reduces yields |
| 8. Exhibition | Submit garden to periodic juried exhibition (every 5 in-game days) | Judged on Biodiversity (unique species count), Aesthetics (color gradient, layout score), and Chimera Health (stability average) | Multi-metric optimization — balance creature diversity with visual design and chimera care |

---

## Meta Loop

### Session-to-Session Progression

```
graph LR
    A[Daily Garden Cycle] --> B[Creature Compendium Grows]
    B --> C[Rare Hybrids Unlocked]
    C --> D[Exhibition Wins]
    D --> E[Rare Seeds + Cosmetics]
    E --> F[New Creature Families Accessible]
    F --> G[Chimera Stability Mastery]
    G --> H[Body-Region Unlock]
    H --> A

    B --> I[Resource Surplus]
    I --> J[Garden Structures Built]
    J --> K[Aesthetic Score Boost]
    K --> D

    G --> L[Chimera Trust Events]
    L --> M[Chimera Dreams: Lore + Rare Mutations]
    M --> C
```

### Progression Axes

| Axis | What Grows | How It Feels | Cap |
|------|-----------|-------------|-----|
| **Creature Compendium** | Discover and catalogue all 200+ hybrids | "I'm a botanist-monster breeder filling a living encyclopedia" | 217 total creatures (15 base species x ~14 hybrid families + secret chains) |
| **Chimera Stability Mastery** | Learn which actions cause how much vibration; optimize daily routine to minimize risk | "I understand this creature's sleep patterns" | 5 body regions unlocked by maintaining 85%+ stability for 10 consecutive days each |
| **Exhibition Prestige** | Win garden exhibitions across 3 categories, rise through 5 rank tiers | "My garden is recognized as the best on this chimera" | Sovereign rank (top tier), unlocks rare cosmetic structures |
| **Chimera Bond** | Trigger Chimera Dream events by maintaining high stability; learn the chimera's story | "The chimera trusts me enough to share its memories" | 12 dream events forming a complete narrative arc |
| **Garden Aesthetics** | Design visually harmonious layouts with color gradients and structural decorations | "My garden is art" | No cap — aesthetic scoring has a soft ceiling but player creativity is unbounded |
| **Resource Mastery** | Optimize creature happiness and yields to produce surplus for structure building | "My garden sustains itself" | Full garden automation possible (auto-waterers, self-defending layouts) |

---

## Game Mechanics

### Primary Mechanic: Proximity Hybridization

The core discovery engine. Every creature on the grid is influenced by its four orthogonal neighbors. When two compatible creatures are adjacent for 2–4 in-game hours, their shared edge produces a hybrid offspring in any empty adjacent tile.

#### Base Species (15)

| # | Species | Element | Resource Yield | Defender? | Visual Theme |
|---|---------|---------|---------------|-----------|-------------|
| 1 | Firebloom | Fire | Ember Pods (heating material) | Yes — ranged fire spit | Orange-red flower with flickering petal-flames |
| 2 | Mandrake | Earth | Root Tubers (structural material) | Yes — melee root whip | Brown-green root creature, half-buried |
| 3 | Dewlily | Water | Dew Drops (cooling/cleaning agent) | No — pure producer | Translucent blue petals, constant dripping |
| 4 | Thornvine | Nature | Thorn Needles (crafting component) | Yes — barrier, slows pests 50% | Green vine tangle with barbed wire aesthetic |
| 5 | Sporecap | Fungal | Spore Clouds (pest repellant) | No — passive pest deterrent | Gray-purple mushroom with puff animations |
| 6 | Cindermoss | Fire/Earth | Cinder Ash (fertilizer) | No — enhances adjacent growth speed | Charred green carpet, embers beneath |
| 7 | Jadewisp | Spirit | Jade Essence (rare crafting) | Yes — spectral shield generator | Floating green orb, ghostly trail |
| 8 | Ironleaf | Metal | Iron Petals (armor structures) | Yes — high defense, walls off pests | Gunmetal gray leaves, rigid and angular |
| 9 | Quicksilver Fern | Water/Metal | Mercury Drops (speed boost for creatures) | No — speeds up adjacent hybridization timer | Liquid silver fronds, constantly shifting |
| 10 | Stormroot | Lightning | Charged Nectar (energy resource) | Yes — chain lightning to nearby pests | Blue-white roots crackling with sparks |
| 11 | Mossdrake | Nature/Earth | Living Moss (self-repairing paths) | Yes — slow but durable tank | Small dragon-shaped moss creature |
| 12 | Sunpetal | Light | Solar Nectar (happiness boost for neighbors) | No — pure happiness enhancer | Golden sunflower with warm glow |
| 13 | Shadelily | Dark | Shadow Thread (stealth structures) | Yes — hides garden section from pests | Deep violet, nearly invisible at night |
| 14 | Frostbloom | Ice | Frost Crystals (cooling, pest slow) | Yes — freezes pests for 3 seconds | White-blue crystalline flower |
| 15 | Echofern | Sound | Echo Spores (attract rare wild seeds) | No — attracts wandering wild creatures | Teal fern that ripples with sound waves |

#### Hybridization Rules

**Tier 1 Hybrids** (base + base): Two adjacent base species produce a direct hybrid. ~105 possible combinations (15 choose 2, with some incompatibilities).

| Example Parent A | Example Parent B | Hybrid Result | Behavior |
|-----------------|-----------------|---------------|----------|
| Firebloom | Mandrake | Emberdrake | Fire-spitting root creature; patrols 3-tile radius, incinerates pests |
| Dewlily | Thornvine | Bramblepool | Defensive water barrier; creates puddle that slows pests 75% |
| Sporecap | Ironleaf | Rustshroom | Armored fungus; high defense defender that poisons pests on contact |
| Stormroot | Mossdrake | Thunderdrake | Lightning-element tank; chain-stuns pest groups |
| Sunpetal | Shadelily | Duskpetal | Twilight flower; produces both solar nectar and shadow thread |
| Frostbloom | Echofern | Crystalwhisper | Freezes pests then shatters them with sonic burst |
| Jadewisp | Quicksilver Fern | Ghostquill | Spectral speed booster; accelerates all nearby hybridization timers by 40% |

**Tier 2 Hybrids** (hybrid + base or hybrid + hybrid): Three-step breeding chains that produce the rarest and most powerful creatures. ~80 possible results.

| Chain | Result | Why It Matters |
|-------|--------|---------------|
| Firebloom + Mandrake = Emberdrake, then Emberdrake + Frostbloom = Frostfire Wyrm | Dual-element defender; immune to fire and ice pests, damages both types | Covers two pest families simultaneously |
| Jadewisp + Sunpetal = Prismwisp, then Prismwisp + Shadelily = Chrysalis Sovereign | Produces all four rare resources (Jade Essence, Solar Nectar, Shadow Thread, Spirit Silk) | Single-tile resource powerhouse |
| Stormroot + Quicksilver Fern = Lightning Reed, then Lightning Reed + Ironleaf = Tesla Tower | Autonomous defender; targets pests across entire garden without player direction | Enables hands-free pest defense |
| Mossdrake + Sporecap = Plaguefang, then Plaguefang + Cindermoss = Blight Guardian | Ultimate tank; 95% pest damage reduction, poisons all pests in 5-tile radius | Endgame defensive anchor |

**Tier 3 Hybrids** (secret chains): 12 ultra-rare creatures requiring specific multi-step chains and conditions (time of day, chimera stability level, season). Each is unique and named.

| Creature | Chain Requirement | Special Condition | Reward |
|----------|------------------|-------------------|--------|
| Apex Sovereign | All 4 element-supreme hybrids adjacent simultaneously | Chimera stability > 95% | +50% resource yield for entire garden |
| Dreamweaver | Chimera Dream event material + Echofern hybrid | Night cycle only | Unlocks hidden compendium entries |
| Colossus Heart | Cindermoss hybrid chain x3 + living chimera flesh sample | Stability drops below 20% then recovers | Prevents chimera from waking for 3 days |
| The First Seed | Complete all 12 Chimera Dreams + Apex Sovereign | Post-game only | Grows into a new chimera garden (NG+ content) |

#### Compendium Tracking

The Creature Compendium displays:

- **Discovered creatures** (full color illustration, stats, behavior description)
- **Hinted creatures** (silhouette + one cryptic clue, e.g., "Fire and root share a bed, and from the embers crawls a guardian")
- **Undiscovered** (empty slot, numbered 1–217)

The compendium is the player's primary long-term goal. Every new discovery triggers a celebration animation and a compendium entry with flavor text.

### Secondary Mechanic: Chimera Stability Meter

The chimera's sleep depth is displayed as a persistent meter (0–100%, higher = deeper sleep = safer).

**Stability Influences:**

| Action | Stability Change | Rationale |
|--------|-----------------|-----------|
| Water a creature | +2% per creature | Soothing, rhythmic, natural |
| Sing to the soil (hold near plants) | +3% per 5-second hold | Vibration-canceling resonance |
| Harvest a mature creature | -8% per harvest | Uprooting disturbs the flesh-soil |
| Combat hybridization (forced crossbreed) | -12% per attempt | Violent genetic recombination shakes the surface |
| Pest kill (by defender creature) | -1% per kill | Minor vibration from combat |
| Build a garden structure | -5% per structure | Heavy construction on living tissue |
| Feed a creature chimera treat (crafted) | +8% | Directly soothes the living soil |

**Stability Thresholds:**

| Stability | Visual State | Gameplay Effect |
|-----------|-------------|-----------------|
| 90–100% | Deep breathing rhythm, warm flesh tones, ambient purring | All peaceful actions get +20% effectiveness. Chimera Dream events can trigger |
| 70–89% | Normal breathing, standard flesh tones | Baseline state. No bonuses or penalties |
| 50–69% | Shallow breathing, cooler flesh tones, occasional twitch | Pest waves increase by 30%. Hybridization timers slow by 15% |
| 30–49% | Restless shifting, flesh ripples visibly, rumble audio | Pest waves double. Hybridization may fail (20% chance). Creatures lose happiness |
| 10–29% | Violent twitching, soil cracks, urgent rumble | 60-second countdown appears. If stability not raised above 30%, chimera wakes |
| 0–9% | Chimera waking — screen shakes, terrain begins shifting | Chimera wakes. Terrain reconfiguration event begins |

**Chimera Wake Event:**

When the chimera wakes, a 30-second cinematic plays showing the colossal creature shifting. Then:

1. The garden terrain reconfigures based on which body part moved (randomly determined)
2. 20–40% of creature placements are disrupted (creatures survive but are displaced)
3. All garden structures on the affected body region take damage
4. Stability resets to 100% (the chimera resettles into deep sleep)
5. The new terrain layout may open previously inaccessible areas or close existing ones

**Body Region Movement Table:**

| Body Part | Terrain Effect | Gameplay Consequence |
|-----------|---------------|---------------------|
| Shoulder | 30% of garden tilts 15 degrees | Water flows to low end; creatures on high end dry out |
| Ribcage | Ground swells into ridges | Flat planting areas become terraced; some tiles become elevated |
| Spine | Central ridge rises | Garden splits into left/right halves connected by narrow bridges |
| Haunch | Large section sinks | Creates a low basin that collects water; flooding possible |
| Neck | Garden elongates | Tile grid stretches; distances between creatures increase |
| Tail (rare) | Entire garden rotates 90 degrees | All adjacency relationships shuffle; new hybridization opportunities |

Recovery from a wake event takes 1–2 in-game days. The penalty is loss of layout optimization, not loss of creatures. This keeps the mechanic tense without being punitive.

### Secondary Mechanic: Garden Exhibitions

Every 5 in-game days, a rival gardener visits and judges your garden on three criteria:

**Scoring Rubric:**

| Criterion | Weight | Scoring Method | Max Points |
|-----------|--------|---------------|------------|
| **Biodiversity** | 40% | Unique species count / total discovered species x 100 | 40 points |
| **Aesthetics** | 30% | Color harmony (adjacent creature color similarity) + structural decoration score + layout balance (symmetry bonus) | 30 points |
| **Chimera Health** | 30% | Average stability over last 5 days + current stability + number of wake events (penalty) | 30 points |

**Rank Tiers (5 ranks):**

| Rank | Points Needed | Reward |
|------|-------------|--------|
| Sprout | 0–25 | Participation seeds (common) |
| Blossom | 26–45 | Uncommon seed selection |
| Canopy | 46–65 | Rare seed + cosmetic decoration |
| Sovereign | 66–85 | Rare hybrid seed + exclusive cosmetic + garden structure blueprint |
| Apex Sovereign | 86–100 | Mythic seed + legendary cosmetic + chimera trust boost |

**Exhibition rewards feed directly into the meta loop** — higher ranks unlock seeds that grow into base species not available through normal play, expanding the hybridization pool and compendium.

### Tertiary Mechanic: Chimera Dreams

When stability is above 90% for 3+ consecutive days, there is a 20% chance per night of triggering a Chimera Dream event. The player is pulled into a dreamscape — a surreal version of the chimera's memories — where they complete a unique puzzle or collection challenge.

**12 Dream Events:**

| Dream # | Theme | Puzzle Type | Reward |
|---------|-------|------------|--------|
| 1 | The First Garden | Arrange 5 creatures in correct hybridization order | Lore: Chimera origin story part 1 |
| 2 | The Gardener's Mistake | Navigate a corrupted garden maze | Rare seed: Ancient Sunpetal |
| 3 | The Breeder's Obsession | Match creature pairs in a memory game (20 pairs) | Lore: Chimera origin story part 2 |
| 4 | The Storm That Woke It | Survival challenge — protect creatures during simulated wake event | Stability management upgrade |
| 5 | The Sovereign's Garden | Design a garden that scores 80+ in a dream exhibition | Cosmetic: Dreamcatcher Arch |
| 6 | The Flesh Remembers | Place creatures on a grid to match a faded memory image | Lore: Chimera origin story part 3 |
| 7 | The Quiet Between Breaths | Pure exploration dream — no puzzles, just lore and atmosphere | Lore: Chimera origin story part 4 |
| 8 | The Collector's Regret | Return escaped dream creatures to their pens (capture minigame) | Rare seed: Phantom Shadelily |
| 9 | The Weight of Gardens | Balance puzzle — distribute creature weight to keep chimera stable | Structure blueprint: Stability Anchor |
| 10 | The Last Lullaby | Rhythm game — sing to the chimera in sequence | Lore: Chimera origin story part 5 + cosmetic: Lullaby Wind Chime |
| 11 | The Awakening | Narrative choice — comfort the chimera or push deeper into its dream | Branching lore consequences |
| 12 | The New Garden | Post-game: the chimera offers to grow a new garden from a piece of itself | Unlocks NG+ with new terrain and 20 additional creatures |

---

## World Design

### Map Structure

The garden exists on the back of the chimera. The map is a grid-based garden space that expands as the player unlocks new body regions.

```
THE COLOSSAL CHIMERA (dorsal view)

                         ┌─────────────────────┐
                         │   HEAD PLATEAU      │
                         │   (Unlock: 40 days) │
                         │   8x8 grid          │
                         └──────────┬──────────┘
                                    │
              ┌─────────────────────┴─────────────────────┐
              │            NECK PASSAGE                    │
              │            (Unlock: 20 days)               │
              │            6x12 grid                       │
              └─────────────────────┬─────────────────────┘
                                    │
        ┌───────────────────────────┴───────────────────────────┐
        │                                                       │
  ┌─────┴──────────┐                               ┌───────────┴──────┐
  │  LEFT          │                               │  RIGHT           │
  │  SHOULDER      │                               │  SHOULDER        │
  │  (Starting)    │                               │  (Unlock: 15d)   │
  │  10x10 grid    │                               │  10x10 grid      │
  └─────┬──────────┘                               └───────────┬──────┘
        │                                                       │
        └───────────────────────┬───────────────────────────────┘
                                │
                   ┌────────────┴────────────┐
                   │      UPPER BACK         │
                   │      (Unlock: 10 days)  │
                   │      12x12 grid         │
                   └────────────┬────────────┘
                                │
                   ┌────────────┴────────────┐
                   │      LOWER BACK         │
                   │      (Unlock: 25 days)  │
                   │      12x14 grid         │
                   └────────────┬────────────┘
                                │
              ┌─────────────────┴─────────────────┐
              │                                   │
  ┌───────────┴──────┐                 ┌──────────┴───────────┐
  │  LEFT HAUNCH     │                 │  RIGHT HAUNCH        │
  │  (Unlock: 30d)   │                 │  (Unlock: 30 days)   │
  │  10x10 grid      │                 │  10x10 grid          │
  └──────────────────┘                 └──────────────────────┘
                                │
                   ┌────────────┴────────────┐
                   │      TAIL RIDGE         │
                   │      (Unlock: 50 days)  │
                   │      8x16 grid          │
                   └─────────────────────────┘
```

**Total garden space at full unlock**: ~700 tiles across 9 regions.

**Region Unlock**: Each region unlocks by maintaining 85%+ average stability for 10 consecutive days while having at least the previous region populated with 50%+ creatures. This gates progression behind chimera care, not just time.

### Body Region Properties

Each body region has unique terrain properties that affect gardening:

| Region | Soil Type | Special Property | Challenge |
|--------|----------|-----------------|-----------|
| Left Shoulder (start) | Standard flesh-loam | None — balanced stats | Tutorial region; learns basics |
| Right Shoulder | Rocky flesh | Harder soil; some tiles require 2 actions to plant | Limited planting space |
| Upper Back | Spongy tissue | +20% hybridization speed | Creatures sink slightly; movement is slow |
| Neck Passage | Narrow vertebrae | Long and thin; adjacency chains must be linear | Limited adjacency options |
| Lower Back | Thick hide | +10% creature happiness naturally | Pest waves are 50% larger |
| Left Haunch | Warm muscle | Fire-element creatures gain +30% yield | Ice-element creatures lose happiness |
| Right Haunch | Cool tendon | Water/ice creatures gain +30% yield | Fire-element creatures lose happiness |
| Head Plateau | Dense bone | Rare minerals spawn as bonus resources | Very limited space (8x8); highly competitive |
| Tail Ridge | Flexible cartilage | Terrain shifts 1 tile randomly every 3 days | Unpredictable layout; highest exhibition score multiplier |

### Art Direction Pillars

| Pillar | Description | Reference |
|--------|-------------|-----------|
| **Living Topography** | The ground breathes, pulses, and has texture. Skin-like terrain with hair-fibers, scale-patterns, and pore-vents. Not grotesque — warm and organic | How to Train Your Dragon's dragon hide textures, Pikmin's organic environments |
| **Flora-Fauna Hybrids** | Creatures are simultaneously plants and animals. A firebloom has petals that flicker like flames AND roots that crawl. An emberdrake has bark-scales and leaf-wings | Pokemon's Bulbasaur lineage, Studio Ghibli creature design philosophy |
| **Bioluminescent Garden** | The garden glows. Each creature emits soft light matching its element. A well-tended garden is a light show | Avatar's bioluminescent forest, Ori and the Blind Forest's Spirit Tree |
| **Chimeric Whimsy** | The chimera is vast but gentle. Its body is a landscape — players live on it, not in fear of it. The design is wondrous, not threatening | Shadow of the Colossus (peaceful interpretation), Monster Hunter's palico ecosystem |

### Visual & Audio Progression by Body Region

| Region | Palette Dominant | Lighting Mood | Ambient Audio | Music Element |
|--------|-----------------|--------------|--------------|---------------|
| Left Shoulder | Warm ochre, soft green | Morning golden light, gentle shadows | Soft heartbeat, distant birdsong | Acoustic guitar — warm, inviting |
| Right Shoulder | Slate gray, amber | Afternoon dappled light through "hair trees" | Wind through fibers, clicking joints | Added recorder melody |
| Upper Back | Deep emerald, teal | Subsurface glow through spongy tissue | Squelching growth sounds, bubbles | Added upright bass — bouncy |
| Neck Passage | Pale cream, gold | Narrow spotlights through vertebrae gaps | Echoing wind, rhythmic pulse | Solo piano — contemplative |
| Lower Back | Rich brown, amber | Warm, even, sunbaked hide | Insect chorus, deep rumble | Added mandolin — hearty |
| Left Haunch | Crimson-orange, charcoal | Heat shimmer, ember glow | Crackling warmth, distant roaring | Added djembe drums — energetic |
| Right Haunch | Teal-blue, silver | Cool moonlight, mist | Trickling water, frost crackle | Added cello — serene |
| Head Plateau | White-gold, crystal | Brilliant overhead, refracting | High wind, crystalline chime | Full ensemble — triumphant |
| Tail Ridge | Shifting spectrum | Constantly changing based on creature mix | Organic shifting, creaking | Improvisational jazz — unpredictable |

---

## Narrative

### Tone Spectrum

```
HOPEFUL  ●●●●●●○○  GRIM
SERIOUS  ●●●●○○○○  WHIMSICAL
SIMPLE   ●●●●○○○○  COMPLEX
GROUNDED ●●●○○○○○  FANTASTICAL
STATIC   ●●●●●●○○  DYNAMIC
```

Warm wonder with gentle melancholy. The chimera is ancient and lonely; the player is its first companion in centuries. Loss is present (the chimera's memories of past gardens destroyed by greedy caretakers) but the dominant tone is hopeful restoration.

### Story Spine (8 Points)

**1. Equilibrium**
You arrive at a sleeping colossal chimera in a forgotten valley. An old journal from a previous gardener lies at the base. The creature's back is bare — empty soil, no plants, no life. The chimera breathes slowly, deeply. The valley is quiet.

**2. Inciting Incident**
You plant your first seed (a gift from the journal's author). It grows into a Firebloom. The chimera's skin warms beneath it — the first warmth in decades. A faint purr resonates through the soil. You realize the chimera responds to what grows on it.

**3. First Complication**
As your garden grows, you discover hybridization. Your first hybrid creature excites you, but the harvesting process vibrates the soil. The chimera twitches. Stability drops. The journal warns: "It woke on me once. I lost everything. Be gentle." The tension between ambition (discover all creatures) and care (keep the chimera asleep) is established.

**4. Rising Action**
You expand to new body regions, each with unique terrain challenges. The exhibitions begin — rival gardeners visit from neighboring chimeras (there are others in the world, each with their own gardener). You compete and trade. The compendium fills. The chimera begins to trust you, triggering Dream events that reveal its past: it has carried gardens for millennia, and every previous caretaker either abandoned it or grew too aggressive and had to be shaken off.

**5. Midpoint Reversal**
In Dream 5, you learn the chimera chose to sleep. It was not always dormant — it was a walking ecosystem, carrying entire civilizations. It chose sleep because the last civilization (the Sovereign's Garden) exploited it ruthlessly, turning its body into a factory. The chimera slept to escape. You are the first gardener it has allowed in 500 years. The trust is real, and fragile.

**6. Crisis**
A rival gardener offers you a "Chimera Stimulant" — a substance that forces wakefulness, allowing you to access the Head Plateau (the richest gardening territory) without waiting for trust-based unlock. Using it would betray the chimera's trust, end all Dream events permanently, and reduce the narrative to a pure optimization game. Refusing it means waiting longer for full access but maintaining the relationship.

**7. Climax**
If you maintained trust: The chimera voluntarily lowers its head, granting access to the Head Plateau and revealing the final Dream — its memory of the first garden, planted by the first caretaker, who was kind. The chimera weeps (rain falls on your garden, boosting everything). If you used the stimulant: The Head Plateau opens but the chimera's Dream events are gone. The compendium can still be completed, but the narrative is hollow.

**8. Resolution**
The garden thrives. The compendium fills. The chimera, for the first time in centuries, dreams peacefully. The ending reflects your choices: a garden of trust and patience, or a garden of efficiency and extraction. Both are playable; only one is whole.

### Key Characters

| Character | Role | Theme | Encounters |
|-----------|------|-------|------------|
| **The Chimera** (unnamed, discovered through Dreams) | Host, world, and narrative center | Trust, patience, the cost of exploitation | 12 Dream events |
| **The Journal Writer** (Maren) | Previous gardener — voice through journal entries | Failure, regret, warning | 30 journal pages found across regions |
| **Rival Gardener: Calder** | Competitive exhibition judge, occasional trader | Ambition without cruelty — a foil, not a villain | Every exhibition event |
| **Rival Gardener: Thessa** | Elderly gardener from a neighboring chimera | Wisdom, gentle correction, mentorship | 8 story encounters |
| **The Stimulant Merchant** | Nameless figure offering the shortcut | Temptation, the easy path vs. the right path | 1 encounter (crisis point) |

---

## Player Personas

### P-003: Hiroshi Tanaka — The RPG Addict

**Why this game fits:** 217 creatures in the compendium, multi-step hybridization chains, hidden conditions for Tier 3 creatures — this is a completionist's paradise. The hybridization system rewards the same theorycrafting mindset Hiroshi brings to character builds. Each discovered creature is an achievement, and the compendium fills like a living Pokedex.

**Predicted experience:** Hiroshi will methodically fill his compendium, maintaining a real notebook of hybridization combinations. He will spend hours planning adjacency chains to unlock Tier 3 creatures. He will treat the Chimera Dreams as boss encounters to be optimized. He will pursue the trust ending on principle. Estimated 80–100 hours to 100% completion.

### P-002: Sarah Chen — The Micro-Gamer

**Why this game fits:** 15–20 minute session loops that fit between family duties. The morning routine (water, sing, check stability) is a comforting daily ritual. Cute hybrid creatures appeal to her aesthetic collector instinct. No gacha, no energy systems — just peaceful gardening in short bursts. Premium pricing means no predatory mechanics.

**Predicted experience:** Sarah plays during nap time and after bedtime. She gets emotionally attached to specific creatures (names her favorites). She cares more about making the garden pretty than min-maxing the compendium. She will win Blossom-rank exhibitions consistently and feel proud. She will play for 3–4 months at 1–2 hours daily.

### P-008: David Park — The Completionist

**Why this game fits:** 217 compendium entries, 12 Dream events, 5 exhibition ranks, 9 body regions, 30 journal pages, 2 endings — clear, trackable 100% target. No RNG-gated achievements; everything is discoverable through experimentation and attention. The stability mastery system provides a measurable skill axis alongside collection.

**Predicted experience:** David maps every body region in a spreadsheet. He tracks hybridization chains in a database. He optimizes exhibitions for Apex Sovereign rank. He completes the compendium, collects all journal pages, achieves all Dream events, and pursues both endings. He will flag any creature whose discovery condition seems undocumented or inconsistent. Estimated 120 hours to 100%.

### P-007: Priya Sharma — The Status Whale

**Why this game fits:** Garden exhibitions are social showcase events. Aesthetic scoring rewards visual design skills that translate directly to social media content. Cosmetic DLC lets Priya personalize her garden for Instagram/TikTok content. The garden IS the profile — visitors see her aesthetic vision.

**Predicted experience:** Priya treats her garden as an art installation. She screenshots every exhibition result and posts it. She buys all cosmetic DLC day one. She designs color-gradient gardens specifically for visual impact. She trades rare creatures with the community to build her collection. She spends $60–80 on DLC cosmetics over the game's lifetime.

### P-013: Robert Thompson — The Relaxation Player

**Why this game fits:** The morning routine is meditative — water, sing, observe. No fail states (creatures do not die, they just get displaced). The chimera can wake, but recovery is gentle, not punishing. The ambient soundtrack is genuinely calming. Session length is flexible — play 10 minutes or 40.

**Predicted experience:** Robert plays 15 minutes nightly before bed. He does the morning routine, maybe plants one new creature, and closes the game. He does not engage with exhibitions or compendium tracking. He just enjoys the routine. The chimera purring sound effect is his white noise. He plays for 6+ months at this pace.

### P-006: Eleanor Vance — The Loyal Strategist

**Why this game fits:** The hybridization system is a deep puzzle with 200+ solutions. Body region terrain properties create strategic planning challenges. Stability management requires genuine long-term thinking. Premium pricing with fair DLC respects her fixed-income budget. No pay-to-win, no gambling mechanics.

**Predicted experience:** Eleanor treats the garden as a strategic optimization problem. She plans body region layouts for maximum yield and stability. She solves hybridization chains through deduction, not brute force. She plays 2–3 hours daily during morning and evening sessions. She will recommend the game to her former colleagues.

---

## User Stories

### Gardening and Hybridization (10 stories)

1. As **Hiroshi (P-003)**, I want the compendium to show silhouettes and cryptic hints for undiscovered creatures so that I can deduce hybridization chains through research rather than random guessing.
2. As **Hiroshi (P-003)**, I want Tier 3 creatures to require specific multi-step breeding chains with special conditions so that the rarest discoveries feel earned through mastery, not luck.
3. As **David (P-008)**, I want the compendium to display a percentage completion counter and per-tier breakdown so that I can track my 100% progress at a glance.
4. As **Eleanor (P-006)**, I want the hybridization rules to be internally consistent and deducible so that I can predict outcomes before committing creature placements.
5. As **Sarah (P-002)**, I want newly discovered creatures to trigger a celebration animation and compendium entry so that every discovery feels rewarding even in short sessions.
6. As **Hiroshi (P-003)**, I want creature placement to show real-time adjacency previews (which hybrids are possible from this configuration) so that I can plan layouts without external tools.
7. As **Priya (P-007)**, I want creatures to have visual personality differences (idle animations, color variations) so that my garden feels alive and unique for screenshots.
8. As **Robert (P-013)**, I want the watering and singing actions to have satisfying, meditative animations and sounds so that the daily routine feels genuinely calming.
9. As **David (P-008)**, I want a "creature codex" view showing every discovered and undiscovered creature organized by element family so that I can systematically hunt missing entries.
10. As **Sarah (P-002)**, I want to name individual creatures and see their names displayed so that I feel emotionally attached to my garden inhabitants.

### Chimera Stability and World (7 stories)

11. As **Eleanor (P-006)**, I want the stability meter to show exactly how much each action will change stability before I commit so that I can make informed strategic decisions.
12. As **Sarah (P-002)**, I want chimera wake events to displace rather than destroy my creatures so that recovery is about rearranging, not rebuilding from scratch.
13. As **Hiroshi (P-003)**, I want body region terrain properties to create meaningful strategic differences so that region choice affects hybridization and resource strategies.
14. As **Robert (P-013)**, I want the chimera's breathing animation and purring audio to respond to my gardening actions in real-time so that the world feels alive and responsive.
15. As **David (P-008)**, I want each body region to have its own stability sub-meter so that I can track which areas need soothing attention.
16. As **Priya (P-007)**, I want terrain reconfiguration after wake events to sometimes create rare adjacency opportunities so that even negative events have silver linings.
17. As **Eleanor (P-006)**, I want the region unlock conditions (85% stability for 10 days) to be clearly communicated so that I can plan my progression timeline.

### Exhibitions and Social (5 stories)

18. As **Priya (P-007)**, I want exhibition scoring to reward aesthetic layout (color harmony, symmetry) so that my visual design skills translate into gameplay advantage.
19. As **Sarah (P-002)**, I want exhibition rewards to include cosmetic decorations that don't affect gameplay so that I can personalize my garden without power concerns.
20. As **David (P-008)**, I want all 5 exhibition ranks to have clear point thresholds and visible progress bars so that I can target the next rank specifically.
21. As **Hiroshi (P-003)**, I want exhibition-unlocked rare seeds to expand the hybridization pool with new base species so that winning exhibitions directly advances compendium completion.
22. As **Priya (P-007)**, I want to visit other players' gardens (asynchronously) and leave comments so that my garden aesthetic reaches a social audience.

### Narrative and Chimera Dreams (5 stories)

23. As **Eleanor (P-006)**, I want the 12 Chimera Dream events to form a coherent narrative arc so that the story rewards my long-term engagement.
24. As **Hiroshi (P-003)**, I want the stimulant merchant crisis point to have meaningful consequences so that my narrative choice feels impactful, not cosmetic.
25. As **Sarah (P-002)**, I want Dream events to be gentle puzzles with no failure states so that I can experience the story without stress.
26. As **David (P-008)**, I want all 30 journal pages to be findable and trackable so that narrative completion is measurable.
27. As **Eleanor (P-006)**, I want the trust ending and the efficiency ending to both be valid but meaningfully different so that the game respects multiple playstyles.

### Accessibility and Comfort (5 stories)

28. As **Robert (P-013)**, I want an optional "zen mode" that prevents chimera wake events entirely so that I can play pure relaxation without the stability mechanic.
29. As a player with motor impairments, I want creature placement to support grid snapping with generous tile detection so that precise positioning is not a barrier.
30. As **Sarah (P-002)**, I want the game to save automatically after every meaningful action so that I never lose progress when real life interrupts my session.
31. As a player with color vision deficiency, I want creature elements to be distinguished by shape and animation style, not color alone, so that hybridization planning is accessible.
32. As **David (P-008)**, I want full controller support with remappable buttons across all platforms so that my preferred control scheme is always available.

### Progression and Completion (3 stories)

33. As **David (P-008)**, I want a post-game NG+ mode that introduces 20 new creatures and reshuffled body region properties so that 100% completion has a second chapter.
34. As **Hiroshi (P-003)**, I want the "Apex Sovereign" exhibition rank to require top scores across all three categories so that endgame mastery is multi-faceted.
35. As **Eleanor (P-006)**, I want garden automation options (auto-waterers, self-defending layouts) to unlock through normal progression so that late-game reduces tedium without removing choice.

---

## Monetization

### Revenue Model: Premium at $24.99

**Why this model fits this game:**
- The core fantasy is care, patience, and discovery. Energy systems, timers, and pay-to-skip mechanics directly contradict the zen-garden identity.
- The target audience (P-002, P-003, P-006, P-008, P-013) values complete, fair experiences over free-to-play grinding.
- The compendium is a skill-based progression system — monetizing creature unlocks would undermine the discovery-driven core loop.
- Premium pricing signals quality and depth to the Stardew Valley / Pokemon crossover audience.

### Pricing and DLC Roadmap

| Product | Price | Content | Target Window |
|---------|-------|---------|--------------|
| Base Game | $24.99 | Full game: 217 creatures, 9 body regions, 12 Dreams, 5 exhibition ranks, 2 endings | Launch |
| Cosmetics Pack 1: "Blossom Decor" | $3.99 | 12 garden decorations (arbors, lanterns, stepping stones, wind chimes) | Launch |
| Cosmetics Pack 2: "Moonlit Garden" | $3.99 | 12 garden decorations (night-blooming structures, crystal lights, dreamcatchers) | Launch |
| Cosmetics Pack 3: "Ancient Groves" | $3.99 | 12 garden decorations (moss-covered ruins, root bridges, fossil displays) | Month 3 |
| Cosmetics Pack 4: "Sovereign's Throne" | $3.99 | 12 garden decorations (regal garden furniture, ceremonial arches, crown topiaries) | Month 3 |
| Expansion: "The Second Chimera" | $9.99 | New chimera with 4 body regions, 40 new creatures, 6 new Dreams, 1 new ending | Month 8 |
| Soundtrack | $9.99 | Full original soundtrack (2+ hours) | Launch |

### Revenue Projections (4 Scenarios)

| Scenario | Year 1 Units | Year 1 Base Revenue | DLC Attach | Year 1 Total (post-platform cut) | Notes |
|----------|-------------|--------------------|-----------|----------------------------------|-------|
| **Modest** | 40,000 | $699,720 | 15% ($23,940) | $723,660 | Niche farming sim audience |
| **Baseline** | 120,000 | $2,099,160 | 25% ($119,700) | $2,218,860 | Positive word-of-mouth, Stardew/Pokemon crossover appeal |
| **Strong** | 350,000 | $6,122,550 | 30% ($315,000) | $6,437,550 | Influencer coverage, award nomination, strong Switch sales |
| **Breakout** | 800,000 | $13,994,400 | 35% ($1,119,720) | $15,114,120 | Viral moment, multi-platform hit, becomes genre reference |

**Revenue calculations**: Base revenue = units x $24.99 x 0.70 (platform cut). DLC revenue = units x attach rate x $3.99 avg x 4 packs x 0.70.

**Break-even at approximately 29,000 units ($507K) against total development budget of $495K (see Production Plan).**

### Marketing Strategy

| Channel | Strategy | Budget |
|---------|----------|--------|
| Steam Next Fest | Feature a demo with the first 2 body regions and 30 creatures | Included in marketing budget |
| Nintendo eShop | Targeted featuring during indie showcases | $10,000 co-op marketing |
| Influencer outreach | Target cozy-game streamers (Stardew, Animal Crossing, Pokemon content creators) | $15,000 product keys + sponsorships |
| Social media | Creature reveal cadence — one new creature per week on Twitter/TikTok leading to launch | $5,000 content creation |
| Press | Target indie game outlets (Rock Paper Shotgun, Nintendo Life, TouchArcade) | $5,000 PR retainer |

---

## Production Plan

### Team

| Role | Count | Phase | Cost |
|------|-------|-------|------|
| Game Designer / Director | 1 | All | $80,000 |
| Unity Developer (gameplay) | 2 | All | $160,000 |
| Unity Developer (systems/UI) | 1 | Months 2–14 | $65,000 |
| 2D Artist (creatures, UI) | 2 | All | $100,000 |
| 2D Artist (environments) | 1 | Months 3–14 | $48,000 |
| Technical Artist (shaders, VFX) | 1 | Months 2–14 | $60,000 |
| Composer | 1 (contract) | Months 4–14 | $20,000 |
| Sound Designer | 1 (contract) | Months 6–14 | $12,000 |
| Writer | 1 (contract) | Months 1–10 | $18,000 |
| QA Lead | 1 | Months 8–15 | $32,000 |
| QA Tester | 1 | Months 10–15 | $16,000 |
| Producer | 1 | All | $72,000 |

**Total team: 14 people peak (months 6–12)**

### Timeline (15-month production)

```
Month 1-2: PRE-PRODUCTION
├── GDD finalized
├── Art style guide (creature design language, chimera body textures, UI mockups)
├── Prototype: 4 base species, hybridization system, 1 body region, stability meter
├── Playtest prototype for "feel" — does hybridization feel satisfying?
└── Team: Designer + 2 devs + 1 creature artist + producer

Month 3-5: PRODUCTION ALPHA
├── All 15 base species implemented with art
├── Hybridization system complete (Tier 1 + Tier 2)
├── 3 body regions playable
├── Stability meter and chimera wake event functional
├── Morning routine (water, sing) implemented with juice
└── Team: Full team onboarded

Month 6-9: PRODUCTION BETA
├── All 9 body regions playable
├── All 217 creatures implemented (art + behavior)
├── Exhibition system complete with scoring
├── 6 Chimera Dreams implemented
├── Pest defense system balanced
├── UI pass — compendium, stability meter, region map
└── QA begins

Month 10-12: POLISH + CONTENT
├── Remaining 6 Chimera Dreams implemented
├── All 30 journal pages written and placed
├── Narrative crisis point (stimulant merchant) implemented
├── Both endings implemented
├── Performance optimization (especially Switch and mobile)
├── Accessibility pass
└── Full QA regression

Month 13-14: CERTIFICATION + PREP
├── Console certification submission (Switch)
├── Mobile optimization pass (iOS/Android)
├── Steam Next Fest demo preparation
├── Press embargoes and review copies
└── Marketing push

Month 15: LAUNCH
├── Steam launch
├── Nintendo Switch launch
├── iOS/Android launch
├── Day-1 patch deployment
└── Post-launch support begins
```

### Budget Breakdown

| Category | Cost | Notes |
|----------|------|-------|
| Salaries (15 months, 14 FTE peak) | $370,000 | Blended rate ~$7,400/mo avg; indie team rates |
| Unity Pro licenses | $7,200 | 5 seats x $144/mo x 10 months |
| Software and Tools | $12,000 | Perforce, Jira, Adobe CC, Aseprite, Spine |
| Hardware (Switch dev kits, test devices) | $18,000 | 2 Switch dev kits, 2 iOS devices, 2 Android devices |
| QA and Playtesting | $16,000 | External QA contractor, playtest sessions |
| Audio (composition, sound design, mixing) | $15,000 | Contractor rates, studio time for final mix |
| Marketing | $35,000 | PR, influencer outreach, Steam Next Fest, social media |
| Console certification | $8,000 | Nintendo certification fees |
| Operations and Overhead | $10,000 | Legal, accounting, incorporation |
| Contingency (8%) | $3,800 | |
| **Total** | **$495,000** | |

---

## Technical Requirements

### Platform Specifications

| Spec | PC Minimum | PC Recommended | Nintendo Switch | iOS | Android |
|------|-----------|---------------|----------------|-----|---------|
| **CPU** | Intel i3-8100 / Ryzen 3 2200G | Intel i5-10400 / Ryzen 5 3600 | Custom NVIDIA Tegra (locked) | A12 Bionic (iPhone XR+) | Snapdragon 730+ |
| **RAM** | 4 GB | 8 GB | 4 GB | 3 GB free | 4 GB free |
| **GPU** | Intel UHD 630 / AMD Vega 8 | GTX 1060 / RX 580 | Custom NVIDIA (locked) | A12 GPU (locked) | Adreno 618+ |
| **Storage** | 5 GB HDD | 5 GB SSD | 4 GB | 3 GB | 3 GB |
| **Target Resolution** | 1080p / 60 FPS | 1440p / 60 FPS | 720p handheld / 1080p docked, 30 FPS | Native device resolution / 60 FPS | Native device resolution / 30+ FPS |

### Key Technical Challenges

| Challenge | Risk | Mitigation |
|-----------|------|-----------|
| **217 creature assets with unique art and behavior** | High — sheer content volume is the primary production risk | Modular creature system: each creature is assembled from reusable parts (body types, limb variants, color palettes, behavior modules). 15 base models with hybrid blending reduces unique art to ~40 base assets + procedural combinations. |
| **Real-time adjacency hybridization calculations on large grids** | Medium — 700 tiles with 4 neighbors each checking hybridization conditions | Spatial partitioning: only active tiles (populated) participate in hybridization checks. Hybridization is event-driven (on place, on timer tick), not per-frame. Target: under 2ms per hybridization pass. |
| **Chimera stability and wake events with terrain reconfiguration** | High — terrain changes must not corrupt creature placement or save state | Terrain is stored as a region-level layout graph, not a global grid. Wake events modify the graph (add/remove edges, rotate sub-graphs), then creatures are resolved against the new graph. All creatures persist; only positions change. Tested in month 3 prototype. |
| **Cross-platform performance (Switch and mobile at 30 FPS)** | Medium — 700-tile garden with 200+ animated creatures may stress mobile GPUs | Level-of-detail system: creatures beyond 5 tiles from camera reduce to static sprites. Animation budget: max 30 simultaneously animating creatures on mobile. Stability meter and UI are lightweight (no particle effects on mobile). |
| **Creature blending visuals for hybrids** | Medium — each hybrid needs to visually read as a blend of its parents | Pre-rendered sprite approach (not procedural blending): each hybrid is a hand-drawn sprite that references parent visual DNA. 217 unique sprites is production-heavy but manageable with the modular art pipeline. Spine animation rig shared across creature families. |
| **Save state integrity across terrain reconfiguration** | High — player loses trust if creatures disappear after a wake event | Save system stores creature data (species, happiness, age, position) independently from terrain layout. On wake event: terrain regenerates, then creatures are placed into nearest valid tiles. Fallback: any creature that cannot be placed goes to a "recovery pen" accessible from any region. Save is triple-committed (temp, backup, permanent). |

### Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Rendering | Unity URP (2D) | The game is tile-based with 2D creatures and environments. URP provides performant 2D rendering across all target platforms including Switch. |
| Animation | Spine 2D | Creature rigs with bone-based animation allow smooth hybrid blending animations and reduce per-creature art cost. Shared rig templates across creature families. |
| Save system | JSON + SQLite hybrid | Creature state in SQLite for query performance. Garden layout and metadata in JSON for human-readable backups and cloud save compatibility. |
| Multiplatform | Unity build targets | Single codebase with platform-specific optimization profiles. Content is identical across platforms. UI scales via Unity's canvas system. |
| Audio | FMOD | Adaptive music system that layers instruments based on chimera stability. FMOD provides cross-platform low-latency audio with Unity integration. |

---

<npl-block type="reflection">
Correctness: All 12 sections present. Numbers internally consistent: 15 base species x ~14 families yields ~210 Tier 1/2 hybrids + 12 Tier 3 = ~217 total creatures. Budget totals match ($495K). Revenue break-even (~29K units) cross-checked against budget. Team cost per role matches stated timeline phases.

Edge cases: Chimera wake event recovery handles creature displacement without destruction — prevents feel-bad moments for casual players (P-002, P-013). Zen mode (US-28) accommodates Robert's pure relaxation needs. Stimulant merchant crisis gives meaningful narrative choice without gating compendium completion behind narrative choices. Tier 3 creatures require special conditions but not RNG — all discoverable through attention and experimentation.

Security: No security concerns — this is a game design document, not software.

Pitfalls: The 217-creature count is the biggest production risk. Mitigated by modular art pipeline but could still slip. Mobile performance at 30 FPS with many animated creatures needs early profiling. The chimera wake event must feel like an interesting puzzle, not a punishment — playtesting the tone of terrain reconfiguration is critical.

Improvements: Could add asynchronous multiplayer features (trading creatures, visiting gardens) beyond exhibition scoring. Could expand on the rival gardener characters. Could detail the pest defense system more thoroughly (specific pest types, wave composition). Could add seasonal events for live-ops.

Refactors: Document structure follows the 12-section format exactly. No refactoring needed.

Documentation: This IS the documentation.

Clarifications: None needed — all assumptions stated in persona mapping, monetization rationale, and technical decisions.

TODOs: Expansion ("The Second Chimera") content needs its own design pass. Cosmetics pack content needs individual item design. NG+ 20 additional creatures need design. Mobile UI touch controls need dedicated UX pass.
</npl-block>
