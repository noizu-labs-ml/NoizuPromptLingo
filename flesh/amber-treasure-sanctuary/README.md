# Amber Treasure Sanctuary

## Title and Genre

| Field | Value |
|-------|-------|
| **Title** | Amber Treasure Sanctuary |
| **Genre** | Building Crafting / Cozy Simulation |
| **Engine** | Unity 2023 LTS (2D isometric rendering, URP for particle effects) |
| **Platform Targets** | PC (Steam), Nintendo Switch, iOS, Android |
| **Monetization** | Premium ($24.99 base) with seasonal decoration DLC ($7.99 each) |
| **Rating** | ESRB E (Everyone) |
| **Target Session Length** | 20-45 minutes (flexible, no pressure mechanics) |

---

## Vision Statement

Amber Treasure Sanctuary is a cozy building-crafting simulation where the player inherits a crumbling sanctuary in a golden grove and restores it using an amber crystal that transmutes raw materials into enchanted building components. The game is about transformation -- turning ruin into beauty, wilderness into community, and raw materials into glowing, living architecture. Every surface catches warm amber light. Every room the player builds attracts a new NPC resident with stories to tell and recipes to share. There are no fail states, no timers, no combat. The player explores a season-shifting meadow, gathers materials by hand, returns to their crystal, and crafts a sanctuary that grows more alive with every structure they place. The aesthetic is honey gold and moss green, warm wood and refracted crystal light. The feeling is slow, meditative, and deeply satisfying -- the digital equivalent of building a sandcastle that glows.

---

## Core Loop

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   ┌──────────┐    ┌──────────────┐    ┌──────────────┐             │
│   │  EXPLORE  │───>│   GATHER     │───>│  TRANSMUTE   │             │
│   │  Groves   │    │  Materials   │    │  at Crystal  │             │
│   └──────────┘    └──────────────┘    └──────────────┘             │
│        ^                                    │                       │
│        │                                    v                       │
│   ┌──────────┐    ┌──────────────┐    ┌──────────────┐             │
│   │  VISIT   │<───│   ATTRACT    │<───│    BUILD     │             │
│   │  NPCs    │    │  Residents   │    │  & DECORATE  │             │
│   └──────────┘    └──────────────┘    └──────────────┘             │
│        │                                                            │
│        v                                                            │
│   ┌──────────┐    ┌──────────────┐                                 │
│   │  QUEST   │───>│  UNLOCK      │───> Back to EXPLORE             │
│   │  & TRADE │    │  New Recipes │                                 │
│   └──────────┘    └──────────────┘                                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Core Loop Breakdown

**1. EXPLORE the Groves (3-8 minutes)**

The player leaves the sanctuary through one of four gated exits (north meadow, east orchard, south creek, west cliff). Each zone contains 12-18 gatherable nodes that respawn on a 2-hour real-time cycle. The player walks (no sprint needed; the world is intimate, not vast) and interacts with glowing nodes: flower patches, honeycombs, mineral deposits, enchanted acorn clusters, ice crystal veins (winter only), and seasonal rare spawns. Each gather takes 1.5 seconds with a soft animation. No tool durability. No stamina bar. No enemies.

**2. GATHER Materials into Inventory (automatic)**

Materials stack in a 40-slot inventory (expandable to 80 via sanctuary upgrades). Each material has a tier (common, uncommon, rare, legendary) and an element family (floral, mineral, apiary, seasonal). The player gathers 15-30 materials per grove run, enough for 4-8 transmutations.

**3. TRANSMUTE at the Amber Crystal (2-5 minutes)**

The amber crystal sits at the sanctuary's center. The player opens the transmutation interface: a radial menu showing 6 element families. Selecting a family displays available recipes. Each recipe requires 2-4 materials and produces one enchanted building piece. The player feeds materials into the crystal (drag-and-drop or auto-fill), watches a 3-second transmutation animation (materials dissolve into golden light, reform as a glowing component), and receives the piece. Failed combinations do not exist -- every input produces something -- but specific recipes produce premium results.

**4. BUILD and DECORATE (5-15 minutes)**

The player enters build mode: a grid-free placement system with snap-to-wall alignment. Enchanted building pieces include structural elements (walls, floors, roofs, pillars), functional elements (windows that store sunlight and glow at night, floor tiles that generate ambient warmth, flower beds that attract friendly mimic guardians), and decorative elements (amber chandeliers, crystal sconces, living vine patterns). Every piece has a visual effect. Nothing is purely stat-based.

**5. ATTRACT NPC Residents (passive, triggered by room quality)**

When the player completes a room that meets an NPC's requirements (specific furniture, minimum room size, element theme), that NPC arrives at the sanctuary gate within one in-game day. Each NPC has a crafting specialization, a questline (3-5 quests), and contributes to the sanctuary economy (producing rare materials, unlocking recipes, attracting visitors).

**6. QUEST and TRADE with NPCs (3-5 minutes)**

NPC quests are fetch-craft-deliver chains: "Bring me 3 transmuted amber floor tiles and I will teach you the recipe for singing walls." Trading lets the player exchange crafted goods for rare materials not found in the groves. Completing an NPC's questline unlocks their master recipe (a unique enchanted piece unavailable through any other method).

**7. UNLOCK New Recipes and Zones**

Recipe unlocks come from three sources: NPC questlines (12 master recipes), crystal experimentation (discovering recipes by combining materials freely; 24 discovery recipes), and seasonal events (4 seasonal recipes per year). New grove zones unlock as the sanctuary grows: each 5 rooms built opens a deeper grove area with rarer materials.

---

## Meta Loop

### What Carries Between Sessions

| Persistent Element | Description | Growth Feel |
|--------------------|-------------|-------------|
| **Sanctuary Structure** | Every room, wall, and decoration persists permanently. The ruin transforms into a living community. | Tangible, visual transformation. Screenshots from session 1 vs session 30 show dramatic change. |
| **Recipe Library** | 40 base recipes expand to 80+ through questlines, experimentation, and seasonal unlocks. | Expanding creative vocabulary. The player can build more complex and beautiful things over time. |
| **NPC Community** | Up to 14 NPC residents, each with completed questlines, dialogue trees, and active crafting contributions. | The sanctuary feels increasingly alive and populated. |
| **Material Stockpile** | Storage rooms hold gathered and crafted materials across sessions. No material decay. | Wealth accumulation without anxiety. A full stockpile feels like potential energy. |
| **Grove Discovery Map** | Each zone starts fogged. Exploration reveals landmarks, rare node locations, and hidden paths. | Cartographic satisfaction. The player knows the groves intimately. |
| **Seasonal Journal** | Records first discoveries per season, NPC stories collected, building milestones. | Narrative permanence. The player's story is documented. |

### Progression Axes

| Axis | How It Grows | Growth Feel |
|------|-------------|-------------|
| **Architectural Complexity** | Room count (0 to 60+), piece variety (1 to 80+ types), visual density | From "empty ruin" to "thriving crystal palace" |
| **Material Mastery** | Recipe discovery (1 to 80+), transmutation speed (crystal upgrades) | From "hmm, what does this make?" to "I know exactly what I want" |
| **Community Depth** | NPC count (0 to 14), questlines completed (0 to 14), relationship levels (1 to 5 stars) | From "alone in a ruin" to "mayor of an artisan village" |
| **Grove Access** | Zones unlocked (1 to 4 base + 4 seasonal variants), rare material access | From "meadow basics" to "legendary ice crystal veins" |
| **Sanctuary Ecosystem** | Mimic guardians attracted (0 to 8), ambient effects active (0 to 20+), visitor NPCs (0 to 30+) | From "quiet ruin" to "living, breathing sanctuary" |

---

## Game Mechanics

### Primary Mechanic: Amber Transmutation

The amber crystal is the game's heart. It converts raw materials into enchanted building components through a recipe system.

**Inputs (Materials):**

| Material Family | Common Examples | Uncommon Examples | Rare Examples | Legendary Examples |
|-----------------|----------------|-------------------|---------------|--------------------|
| **Floral** | Meadow Daisy, Clover Bloom | Moonpetal, Dawn Orchid | Spirit Rose, Twilight Lily | Everbloom (one per season) |
| **Mineral** | River Stone, Quartz Shard | Amber Geode, Moss Agate | Sunstone Core, Void Marble | Heart of the Grove (quest only) |
| **Apiary** | Wild Honeycomb, Beeswax | Royal Jelly, Amber Nectar | Starlight Honey, Echo Wax | Queen's Resin (one per year) |
| **Seasonal** | Spring Raindrop, Summer Sunshard | Autumn Ember, Winter Frost | Bloomsurge Spore, Hearthglow Ember | Solstice Crystal (seasonal event) |

**Outputs (Enchanted Building Pieces):**

| Piece Type | Examples | Element Affinity | Visual Effect |
|------------|----------|-----------------|---------------|
| **Structural** | Amber Brick Wall, Crystal Pillar, Living Root Beam | Mineral | Soft inner glow, subtle pulse |
| **Flooring** | Sunstone Tile, Moss Carpet, Singing Floorboard | Mixed | Ambient warmth particles, soft hum when walked on |
| **Windows** | Stained Amber Pane, Lightwell Fixture, Prism Vent | Floral + Apiary | Refracted rainbow light patterns, intensity shifts with time-of-day |
| **Roofing** | Self-Repairing Thatch, Crystal Shingle, Living Vine Canopy | Mixed | Slow growth animation, dewdrop particles |
| **Furniture** | Honeycomb Shelf, Crystal Chandelier, Root Chair | Mixed | Functional animations (chandelier sways, shelf refills, chair molds to sitter) |
| **Garden** | Enchanted Flower Bed, Mimic Attractor Pot, Singing Fern | Floral | Particle trails, attracts mimic guardians, ambient melody |
| **Functional** | Warmth Generator, Light Amplifier, Echo Amplifier | Mineral + Apiary | Visible aura effects in connected rooms |

**Transmutation Rules:**

- Every recipe requires 2-4 materials from compatible families
- The crystal has 6 input slots; the player fills them and the crystal resolves the closest matching recipe
- If no recipe matches, the crystal produces a "Surprise Piece" -- a random decorative item with a unique visual variant (guaranteed to be unique per session until all surprise variants are discovered)
- Transmutation takes 3 seconds (upgradeable to 1.5 seconds)
- The crystal has no cooldown. The player transmutes as fast as they can supply materials.

**Skill Ceiling:**

The transmutation system has depth for players who want it:

1. **Material Pairing Bonus**: Using materials from the same family produces pieces with enhanced visual effects (brighter glow, richer particle density)
2. **Seasonal Resonance**: Transmuting during the matching season (floral in spring, apiary in summer, mineral in autumn, seasonal materials in winter) produces "Resonant" variants with unique color shifts
3. **Crystal Tier Upgrades**: The crystal starts at Tier 1 (base recipes only). Upgrading to Tier 2 (requires 10 rooms built) unlocks advanced recipes. Tier 3 (25 rooms) unlocks masterwork recipes with the most dramatic visual effects
4. **Experimentation Journal**: The player can combine any 2-4 materials freely. The game tracks 24 hidden recipes that are only discovered through experimentation, each producing a unique piece unavailable through the standard recipe menu

### Secondary Mechanics

**1. Seasonal Grove Cycling**

The groves cycle through four seasons, each lasting 7 real-time days:

| Season | Duration | Unique Materials | Visual Changes | Special Events |
|--------|----------|-----------------|----------------|----------------|
| **Spring** | 7 days | Moonpetal, Spring Raindrop, Bloomsurge Spore | Wildflowers bloom, streams swell, soft green palette | Flower Festival (NPC gathering, rare material bonus) |
| **Summer** | 7 days | Royal Jelly, Summer Sunshard, Amber Nectar | Golden light, firefly particles, warm haze | Honey Moon (apiary materials double, bee NPCs visit) |
| **Autumn** | 7 days | Amber Geode, Autumn Ember, Moss Agate | Amber foliage, falling leaves, warm orange light | Harvest Market (NPC trading bonus, visiting merchants) |
| **Winter** | 7 days | Winter Frost, Void Marble, Hearthglow Ember | Snow cover, ice crystals, warm interior glow contrast | Ice Cave Opening (hidden zone with legendary minerals) |

Seasons advance based on real-time days played, not in-game time. The player can also trigger a season preview at the crystal (costs 5 of any uncommon material) to gather seasonal materials out of cycle, but at half quantity.

**2. NPC Community System**

14 NPC residents, each requiring a specific room configuration to appear:

| NPC | Specialization | Room Requirement | Questline Length | Master Recipe Unlocked |
|-----|---------------|-----------------|-----------------|----------------------|
| **Elara** (Retired Oracle) | Seed Trading | Any room with 2+ windows | 5 quests | Oracle's Observatory Window |
| **Bruno** (Traveling Minotaur) | Rare Minerals | Room with mineral flooring + amber shelving | 4 quests | Minotaur's Foundation Stone |
| **Sylvie** (Beekeeper) | Honey Variants | Room with apiary theme + garden access | 4 quests | Queen's Amber Comb Fixture |
| **Thistle** (Mimic Whisperer) | Mimic Breeding | Room with 3+ enchanted flower beds | 3 quests | Mimic Queen's Throne |
| **Professor Oakhaven** (Botanist) | Rare Flowers | Room with living vine canopy + 4 garden pieces | 5 quests | Everbloom Planter |
| **Gemma** (Crystal Artist) | Decorative Crystal | Room with crystal chandelier + prism vent | 4 quests | Prismatic Fresco Wall |
| **Copper** (Tinker Gnome) | Mechanical Fixtures | Room with mineral flooring + shelving + warmth generator | 5 quests | Self-Winding Clock Tower |
| **Willow** (Herbalist) | Enchanted Plants | Room with garden access + living root beams | 4 quests | Whispering Willow Trellis |
| **Flint** (Stone Mason) | Structural Stone | Room with mineral theme, minimum 5x5 grid | 3 quests | Earthsong Keystone |
| **Marina** (Glass Blower) | Glass and Light | Room with 4+ windows + light amplifier | 4 quests | Captured Sunset Stained Glass |
| **Bramble** (Fairy Gardener) | Living Furniture | Room with living vine canopy + enchanted flower bed | 3 quests | Self-Pruning Hedge Arch |
| **Sage** (Alchemist) | Transmutation Boosts | Room with crystal theme + echo amplifier | 5 quests | Philosopher's Transmutation Crucible |
| **Ember** (Firelight Sprite) | Warmth Effects | Room with warmth generator + amber chandelier | 3 quests | Eternal Hearth Fireplace |
| **Lumi** (Starlight Weaver) | Light Effects | Room with 6+ light sources + prism vent | 4 quests | Starlight Canopy Ceiling |

**3. Friendly Mimic Guardians**

Enchanted flower beds attract mimic companions -- small treasure-chest creatures that patrol the sanctuary perimeter. They serve as passive guardians (cosmetic only; nothing attacks the sanctuary) and contribute ambient personality:

| Mimic Type | Attracted By | Personality | Visual |
|-----------|-------------|-------------|--------|
| **Chestling** | 1 flower bed | Shy, hides when player approaches | Small wooden chest with blinking eyes |
| **Honeypot** | 2 flower beds + apiary piece | Clumsy, bumps into furniture | Amber jar with sticky dribble |
| **Crystal Hatch** | 2 flower beds + mineral piece | Curious, follows player for 30 seconds | Geode with shimmering lid |
| **Bloombox** | 3 flower beds + floral piece | Playful, rolls between rooms | Flower pot with petal tongue |
| **Mimic Queen** | 5+ flower beds + Thistle's quest complete | Regal, sits on throne, produces 1 rare material/day | Large ornate chest with golden crown |

**4. Sanctuary Economy**

No currency system. The economy runs on material exchange and crafting specialization:

- **NPC Trading**: Each NPC accepts crafted goods in their specialization and returns rare materials or recipes
- **Visitor NPCs**: 30+ wandering NPCs visit the sanctuary based on its size and decoration. Each visitor leaves a "guest gift" (random common or uncommon material) when they depart
- **Mimic Contributions**: Mimic guardians produce 1 common material per in-game day as a "found treasure"
- **Seasonal Markets**: During seasonal events, a traveling merchant NPC offers 3 premium materials in exchange for 10 crafted pieces of any type

### Difficulty Progression

The game has no fail states. Difficulty manifests as complexity -- more recipes, more materials, more NPC requirements, more room configurations to manage.

| Stage | Rooms Built | Recipes Available | NPCs Present | Grove Access | Complexity Layer |
|-------|------------|-------------------|-------------|-------------|-----------------|
| **Act 1: Ruin** | 0-5 | 8 base recipes | 0 | North Meadow only | Basic gathering, first transmutations, first room |
| **Act 2: Hearth** | 6-15 | 20 recipes | 2-4 | North + East zones | NPC room requirements, seasonal awareness, mimic attraction |
| **Act 3: Garden** | 16-30 | 40 recipes | 5-8 | All base zones | Material pairing bonuses, crystal tier 2, experimentation |
| **Act 4: Sanctuary** | 31-50 | 60 recipes | 9-12 | All zones + seasonal variants | Advanced NPC synergies, crystal tier 3, mimic queen |
| **Act 5: Community** | 51+ | 80+ recipes | 13-14 | Full access + hidden areas | Full creative freedom, visitor optimization, journal completion |

---

## World Design

### Map Structure

The world uses a hub-and-spoke layout. The sanctuary is the central hub. Four grove zones radiate outward, each with three depth layers (outer, middle, inner).

```
                    ┌──────────────────┐
                    │   WEST CLIFF     │
                    │  (Mineral Rich)  │
                    │   Outer/Mid/Deep │
                    └────────┬─────────┘
                             │
┌──────────────┐   ┌────────┴─────────┐   ┌──────────────┐
│ SOUTH CREEK  │───│    SANCTUARY     │───│ EAST ORCHARD │
│ (Apiary)     │   │   (Central Hub)  │   │ (Honey +     │
│ Outer/Mid/   │   │                  │   │  Seasonal)   │
│ Deep         │   │  Crystal Chamber │   │ Outer/Mid/   │
└──────────────┘   │  Build Zones     │   │ Deep         │
                   │  NPC Housing     │   └──────────────┘
                   │  60+ Room Slots  │
                   └────────┬─────────┘
                            │
                   ┌────────┴─────────┐
                   │  NORTH MEADOW    │
                   │  (Floral Focus)  │
                   │  Outer/Mid/Deep  │
                   └──────────────────┘
```

**Sanctuary Layout:**

The sanctuary starts as a ruined structure with 5 collapsed rooms and an overgrown courtyard. The player clears rubble (instant interaction, no minigame) to reclaim room slots. Maximum capacity is 60 room slots across 3 floors (ground: 30, upper: 20, tower: 10). The amber crystal sits in the central courtyard and cannot be moved.

**Grove Depth Layers:**

| Layer | Access Requirement | Material Rarity | Node Density | Hidden Areas |
|-------|-------------------|----------------|-------------|-------------|
| **Outer** | Default | 90% common, 10% uncommon | 12-15 nodes | 0 |
| **Middle** | 5 rooms built in sanctuary | 60% common, 30% uncommon, 10% rare | 10-12 nodes | 1 hidden alcove per zone |
| **Deep** | 15 rooms built + NPC quest from that zone | 30% common, 40% uncommon, 25% rare, 5% legendary | 8-10 nodes | 2 hidden areas + 1 secret node |

### Art Direction Pillars

| Pillar | Description | Implementation |
|--------|-------------|----------------|
| **Warm Luminescence** | Every surface should feel like it catches and holds warm light | Amber point lights on all crystal elements, subsurface scattering on amber materials, warm fog at low density |
| **Living Architecture** | Buildings should feel like they grow, not get placed | Vine growth animations on placement, flower bloom cycles, root settling animations, breathing wall textures |
| **Seasonal Palette Shift** | The world's color story changes fundamentally with seasons | Spring: fresh green + soft pink; Summer: honey gold + warm amber; Autumn: burnt orange + deep brown; Winter: ice blue + warm interior amber contrast |
| **Intimate Scale** | The world is small, detailed, and personal -- not epic | Isometric camera at fixed height, hand-painted textures at 2x resolution, no distant horizons, focus on foreground detail |
| **Crystal Refraction** | Light passing through amber and crystal is the signature visual | Real-time light refraction on windows, prismatic color splits on crystal fixtures, rainbow caustics on floors near windows |

### Visual and Audio Progression

| Stage | Visual State | Ambient Audio | Music Character |
|-------|-------------|---------------|-----------------|
| **Ruin (Act 1)** | Crumbling stone, overgrown vines, dim lighting, dust particles | Wind, distant bird calls, creaking wood | Solo piano, minor key, sparse |
| **Hearth (Act 2)** | First restored rooms glow with amber light, clear paths | Crackling fire, soft wind, insect hum | Piano + soft strings, shifting to major key |
| **Garden (Act 3)** | Multiple glowing rooms, flower beds blooming, mimics wandering | Bees, birdsong, water trickle, mimic chatter | Full ensemble, warm major key, gentle rhythm |
| **Sanctuary (Act 4)** | Tower rooms with prismatic light, crystal fixtures everywhere | Harmonized NPC sounds, chorus of ambient life | Orchestral arrangement, rich harmonics |
| **Community (Act 5)** | Every surface alive with light and growth, visitor NPCs everywhere | Full ambient symphony, seasonal event music | Full orchestra + choir, triumphant and warm |

---

## Narrative

### Story Spine (8-Point Structure)

**1. Equilibrium**

The player's late grandmother, a renowned artisan, maintained the Amber Treasure Sanctuary for decades. The sanctuary was a beacon of warmth and creativity, a place where craftspeople from across the golden grove gathered to share recipes, trade enchanted goods, and live in harmony with the crystal's magic. The amber crystal at its center hummed with gentle power, and the groves teemed with rare materials.

**2. Inciting Incident**

The player receives a letter: their grandmother has passed, and the sanctuary -- now crumbling, overgrown, and abandoned for three years -- is theirs. The amber crystal is dim but still alive, pulsing faintly. A small chestling mimic hides in the overgrown courtyard, the only creature that stayed.

**3. First Complication**

Restoring the first room reveals a hidden inscription: the crystal's power is tied to the sanctuary's community. The crystal dims when the sanctuary is empty and brightens when people live and create within its walls. The ruin is not just old -- it was abandoned because the crystal began fading when the last residents left. The player must not just rebuild walls; they must rebuild a community.

**4. Rising Action**

The player clears rubble, transmutes first pieces, and builds the first habitable room. Elara (the retired oracle) arrives, drawn by the crystal's returning glow. She reveals the grandmother's journal, which contains partial recipes and cryptic notes about the crystal's origin: it was grown, not made, from the Heart of the Grove -- a legendary material buried deep in the groves. Other NPCs arrive as rooms open: Bruno, Sylvie, Thistle, and more. Each carries a fragment of the grandmother's story and a piece of the recipe for reviving the crystal to full power.

**5. Midpoint Reversal**

At 25 rooms built, the crystal suddenly surges and projects a vision: the Heart of the Grove is dying. The groves are not just seasonal -- they are connected to the crystal's life force. Each season, the crystal gives energy to the groves to sustain the cycle, but without a full community maintaining the sanctuary, the crystal cannot replenish itself. The groves will eventually stop producing materials. The player learns the stakes: the sanctuary must reach full community status (14 residents, all questlines complete) before the next winter, or the crystal goes dark permanently.

**6. Crisis**

Winter arrives. The groves freeze. Materials become scarce. Three NPCs consider leaving because the sanctuary cannot support them during the harsh season. The player must choose which NPCs to prioritize with limited resources: keep the crystal specialists who understand its mechanics, or keep the gatherers who can find what few materials remain. This is the game's only meaningful choice -- and it is not punitive. No NPC permanently leaves; the player can convince any NPC to stay by completing a personal quest for them during winter.

**7. Climax**

The player completes the final NPC questline, unlocks the 14th master recipe, and transmutes the Philosopher's Transmutation Crucible. With all 14 master recipes, the crystal resonates at full power for the first time. It projects a map to the Heart of the Grove, hidden in a chamber beneath the deepest layer of the North Meadow. The player journeys there (a narrated walking sequence, not a dungeon) and places the Crucible. The Heart pulses, the crystal surges, and the groves bloom -- all four seasons simultaneously in a cascade of color and light. The sanctuary transforms: every surface glows with living amber light, every room hums with warmth, and the mimic queen appears to take her throne.

**8. Resolution**

The sanctuary is restored. The crystal is self-sustaining. The community is permanent. The groves produce materials in abundance across all seasons. The player continues building freely with no pressure -- a sandbox mode with full recipe access, unlimited room slots, and all NPCs providing daily rare materials. The grandmother's journal is complete, and her final entry reads: "I always knew you would bring it back to life."

### Tone Spectrum (7-Axis)

| Axis | Position | Notes |
|------|----------|-------|
| **Light** vs **Dark** | Light (9/10) | No dark themes. The "crisis" is emotional, not dangerous. |
| **Hopeful** vs **Melancholy** | Hopeful (8/10) | Underlying melancholy from grandmother's passing, but the trajectory is always upward. |
| **Whimsical** vs **Serious** | Whimsical (7/10) | Mimics with personalities, enchanted furniture, fairy NPCs. Serious only in the grief undertones. |
| **Active** vs **Contemplative** | Contemplative (8/10) | The game rewards patience, observation, and quiet creation over speed or efficiency. |
| **Structured** vs **Freeform** | Balanced (5/10) | NPC questlines provide structure; building and decorating are freeform. |
| **Social** vs **Solitary** | Social (6/10) | The community is NPC-driven. No multiplayer, but the world feels populated and warm. |
| **Fantastical** vs **Grounded** | Fantastical (7/10) | Amber crystals that transmute matter, living architecture, friendly mimics. Magic is everyday. |

### Character Table

| Character | Role | Theme | Quest Fragments | Key Dialogue Trait |
|-----------|------|-------|----------------|-------------------|
| **Grandmother** (deceased) | Absent matriarch | Legacy, memory, continuity | Journal entries found in hidden rooms (12 total) | Writes in riddles and recipes |
| **Elara** | Retired Oracle | Wisdom, patience, sight | 5 quests about seeing hidden patterns | Speaks in gentle prophecies |
| **Bruno** | Traveling Minotaur | Strength, loyalty, craft | 4 quests about building foundations | Gruff but tender, calls player "little builder" |
| **Sylvie** | Beekeeper | Industry, sweetness, community | 4 quests about collective work | Hums constantly, names her bees |
| **Thistle** | Mimic Whisperer | Trust, hidden nature, guardianship | 3 quests about earning trust | Whispers, pretends to be furniture sometimes |
| **Professor Oakhaven** | Botanist | Knowledge, curiosity, growth | 5 quests about rare flora | Uses Latin names, gets excited about moss |
| **Gemma** | Crystal Artist | Beauty, light, expression | 4 quests about capturing light | Describes colors the player cannot see yet |
| **Copper** | Tinker Gnome | Innovation, mechanism, humor | 5 quests about enchanted machines | Makes contraptions that almost work |
| **Willow** | Herbalist | Healing, nature, patience | 4 quests about restoration | Tells plant-based parables |
| **Flint** | Stone Mason | Permanence, structure, history | 3 quests about lasting craft | Speaks slowly, remembers every stone |
| **Marina** | Glass Blower | Transparency, fragility, clarity | 4 quests about seeing clearly | Breath-based metaphors |
| **Bramble** | Fairy Gardener | Growth, wildness, joy | 3 quests about letting things grow | Laughs at everything, dances while working |
| **Sage** | Alchemist | Transformation, mystery, balance | 5 quests about the crystal's nature | Cryptic but kind, writes formulas on walls |
| **Ember** | Firelight Sprite | Warmth, energy, comfort | 3 quests about inner warmth | Glows brighter when happy |
| **Lumi** | Starlight Weaver | Dreams, night, wonder | 4 quests about light in darkness | Only speaks in descriptions of light |
| **Mimic Queen** | Guardian Sovereign | Protection, treasure, sovereignty | 1 quest (post-climax) about the Heart | Regal, ancient, knows the grandmother's secret |

---

## Player Personas

### P-002: Sarah Chen (The Micro-Gamer)

**Why this game fits her:**
Sarah plays in 15-20 minute bursts between family duties. Amber Treasure Sanctuary respects her time absolutely: no energy gates, no timers, no forced sessions. She can gather materials for 5 minutes, transmute for 3 minutes, place two building pieces, and feel genuine progress. The aesthetic -- warm amber light, cute mimics, cozy rooms -- aligns perfectly with her taste for appealing visual design. The seasonal events give her something to look forward to on a manageable cadence (7-day seasons).

**Predicted experience:**
Sarah will play 3-4 short sessions daily, treating each as a mini-escape. She will gravitate toward the decoration and NPC interaction, treating rooms like dollhouses. She will discover recipes through the guided menu rather than experimentation, preferring reliable outputs. She will love the mimics and name them. She will spend on seasonal decoration DLC because it extends the aesthetic she loves without introducing complexity. She may skip the experimentation journal entirely -- and the game does not punish her for it.

### P-004: James Morrison (The Stress Whale)

**Why this game fits him:**
James needs a game that rewards him for showing up, even for 5 minutes, without requiring strategy or mental load. Amber Treasure Sanctuary's gather-craft-build loop is meditative and low-cognitive. The crystal produces satisfying visual feedback with every transmutation. NPC visitors leave gifts passively. The mimic guardians add personality without requiring management. The seasonal cycle gives natural variety without FOMO pressure -- materials come back next season.

**Predicted experience:**
James will open the game during meetings and commutes, gather materials on autopilot, and let the crystal's transmutation animation serve as a micro-meditation. He will build rooms quickly without worrying about optimal layouts, then feel the dopamine hit when an NPC moves in. He will buy the base game plus all DLC without hesitation because the price point is low relative to his spending habits and the content is high-quality. He will not complete the experimentation journal or optimize NPC synergies -- he does not need to. The game rewards his presence, not his mastery.

### P-008: David Park (The Achievement Hunter)

**Why this game fits him:**
David treats every game as a completion project. Amber Treasure Sanctuary has 80+ recipes to discover, 14 NPC questlines to complete, 60+ rooms to build, a seasonal journal to fill, and 24 hidden experimentation recipes to uncover. The achievement system is fair and achievable: every milestone is visible, every recipe is obtainable, and no achievement relies on RNG or time-limited FOMO (seasonal achievements recur annually).

**Predicted experience:**
David will create a spreadsheet tracking recipe discovery, NPC quest progress, and room counts. He will systematically explore every grove layer, experiment with every material combination, and optimize his room layouts to attract NPCs efficiently. He will 100% the game within 40-60 hours, then return for each seasonal DLC to maintain his completion status. He will appreciate that seasonal achievements repeat (no permanently missable content). He will be the player who discovers all 24 hidden recipes and posts the guide online.

### P-015: Jennifer Martinez (The Conscious Parent)

**Why this game fits her:**
Jennifer researches games before allowing her children to play. Amber Treasure Sanctuary is ESRB E, has no violence, no gambling mechanics (no gacha, no loot boxes), no in-app purchases beyond transparent DLC packs, and promotes creativity, planning, and community building. The crafting system teaches pattern recognition. The NPC questlines model positive relationships. The seasonal mechanics connect to natural cycles. The game is genuinely appropriate for children ages 6+ while being deep enough to hold an adult's attention.

**Predicted experience:**
Jennifer will play alongside her 8- and 11-year-old children, each taking turns gathering and building. She will approve the premium price model (no predatory microtransactions) and purchase seasonal DLC as family gifts. Her children will love the mimics and the visual effects; she will appreciate the absence of ads, timers, and pressure. She will recommend the game to her parent group, noting its educational value (resource management, spatial reasoning, creative expression). She may not complete the game herself but will feel good about the time her family spends with it.

---

## User Stories

### Exploration (7 stories)

1. As a **player (P-002)**, I want to wander through seasonally changing groves so that each gathering run feels visually fresh and I discover new materials naturally.

2. As a **player (P-008)**, I want a discovery map that tracks which grove areas I have explored and which remain hidden so that I can systematically clear the fog and achieve 100% map completion.

3. As a **player (P-004)**, I want gathering to require a single button press with a satisfying animation so that I can collect materials without thinking during my 5-minute check-ins.

4. As a **player (P-002)**, I want material nodes to glow softly so that I can spot them easily without searching, respecting my limited play time.

5. As a **player (P-008)**, I want hidden alcoves in each grove zone that contain unique materials so that thorough exploration is rewarded with exclusive resources.

6. As a **player (P-015)**, I want the groves to be peaceful environments with no enemies or threats so that my children can explore safely without stress.

7. As a **player (P-004)**, I want materials to respawn on a generous timer (2 hours) so that I never feel like I have "used up" a zone and can always find something to gather.

### Core Mechanics: Transmutation (6 stories)

8. As a **player (P-002)**, I want the transmutation menu to show me available recipes clearly so that I can craft what I want without memorizing combinations.

9. As a **player (P-008)**, I want a free-combination experimentation mode at the crystal so that I can discover the 24 hidden recipes through systematic testing.

10. As a **player (P-004)**, I want every material combination to produce something useful (no failed transmutations) so that I never feel punished for experimenting.

11. As a **player (P-008)**, I want the experimentation journal to track which combinations I have tried and which remain undiscovered so that I can methodically work toward 100% recipe completion.

12. As a **player (P-002)**, I want the transmutation animation to be visually rewarding (golden light, particle effects, dramatic reveal) so that crafting feels like a small celebration each time.

13. As a **player (P-004)**, I want a crystal upgrade system that speeds up transmutation as the sanctuary grows so that my later sessions are more productive per minute.

### Core Mechanics: Building (6 stories)

14. As a **player (P-002)**, I want a grid-free building system with soft snapping so that I can place furniture and decorations at any angle without frustration.

15. As a **player (P-008)**, I want clear room-completion indicators showing which NPC requirements are met so that I can optimize my room designs to attract specific residents.

16. As a **player (P-004)**, I want building pieces to have visible ambient effects (glowing walls, singing floors, self-repairing roofs) so that every placement feels impactful even if I am building quickly.

17. As a **player (P-015)**, I want the building system to be undo-friendly (no material loss when dismantling) so that my children can experiment freely without waste.

18. As a **player (P-002)**, I want enchanted building pieces to produce unique visual effects that change with time-of-day so that my sanctuary looks different in morning light versus evening light.

19. As a **player (P-008)**, I want the game to track my total piece placement count and room count so that I can monitor my progress toward maximum sanctuary completion.

### Narrative (4 stories)

20. As a **player (P-015)**, I want NPC dialogue to model positive values (kindness, patience, community) so that the narrative reinforces prosocial behavior for my children.

21. As a **player (P-002)**, I want the grandmother's journal entries to be discoverable at my own pace so that the story unfolds naturally without cutscene interruptions during my short sessions.

22. As a **player (P-004)**, I want NPC arrivals and quest completions to trigger gentle celebrations (soft music, particle effects, warm lighting changes) so that narrative moments feel rewarding without requiring my full attention.

23. As a **player (P-008)**, I want the story spine to have clear milestone markers so that I can track which narrative stage I am in and how many stages remain.

### Progression (5 stories)

24. As a **player (P-004)**, I want the sanctuary to produce passive rewards (visitor gifts, mimic treasures, NPC contributions) between sessions so that I feel progress even on days I only check in for 2 minutes.

25. As a **player (P-008)**, I want the seasonal journal to record my first discovery of each material per season so that I have a completable checklist tied to seasonal play.

26. As a **player (P-002)**, I want crystal tier upgrades to happen automatically based on room count so that my crafting options expand naturally without requiring me to manage an upgrade system.

27. As a **player (P-008)**, I want all 14 NPC questlines to be completable in any order so that I can pursue the residents most interesting to me first without being gated by prerequisite chains.

28. As a **player (P-004)**, I want the game to save automatically after every action so that I never lose progress when I close the app quickly during a meeting.

### Accessibility (5 stories)

29. As a **player (P-015)**, I want the game to support touch controls on mobile and controller on Switch so that my children can play comfortably regardless of device.

30. As a **player (P-004)**, I want text size to be adjustable so that I can read NPC dialogue and recipe descriptions without straining during short sessions.

31. As a **player (P-002)**, I want a "guided mode" option that highlights the next logical action (gather, transmute, build, or check NPCs) so that I never feel lost when returning after a day away.

32. As a **player (P-015)**, I want the game to be fully playable offline so that my children can play during car trips or in areas without internet.

33. As a **player (P-004)**, I want colorblind-friendly visual indicators on material nodes (shape distinctions beyond color) so that gathering is accessible regardless of visual perception.

### Social and Sharing (2 stories)

34. As a **player (P-002)**, I want a photo mode that lets me frame and capture my sanctuary from any angle so that I can share my creations with friends and feel proud of my work.

35. As a **player (P-015)**, I want a shared-switch profile system so that multiple family members can maintain separate sanctuaries on the same device without overwriting each other's progress.

---

## Monetization

### Revenue Model: Premium + Seasonal DLC

**Why this model fits this game:**

Amber Treasure Sanctuary is a cozy, E-rated building game with no competitive elements, no live service pressure, and no predatory mechanics. The premium model signals quality and safety to parents (P-015), completionists (P-008), and stress-relief players (P-004) alike. There are no gacha mechanics, no energy systems, and no in-app currency -- every design decision that protects the cozy experience also precludes live-service monetization. Seasonal decoration DLCs extend the game's life without fragmenting the player base (DLC items are cosmetic only; no gameplay advantages).

### Pricing

| Product | Price | Content |
|---------|-------|---------|
| **Base Game** | $24.99 | Full game: 80+ recipes, 14 NPCs, 60 room slots, 4 grove zones, seasonal cycling, story spine |
| **Spring Blossom Pack** | $7.99 | 12 spring-themed decoration pieces, spring-exclusive mimic variant, spring music track |
| **Summer Solstice Pack** | $7.99 | 12 summer-themed decoration pieces, sun-themed crystal variant, summer music track |
| **Autumn Harvest Pack** | $7.99 | 12 autumn-themed decoration pieces, harvest market visitor NPCs (5 new), autumn music track |
| **Winter Frost Pack** | $7.99 | 12 winter-themed decoration pieces, ice cave expansion zone, winter music track |
| **Complete Collection** | $49.99 | Base game + all 4 seasonal DLCs (18% discount vs individual) |

### DLC Roadmap

| Window | Content | Revenue Target |
|--------|---------|---------------|
| **Launch (Month 0)** | Base game | Primary revenue |
| **Month 3** | Spring Blossom Pack | Sustained engagement |
| **Month 6** | Summer Solstice Pack | Mid-year retention |
| **Month 9** | Autumn Harvest Pack | Fall season tie-in |
| **Month 12** | Winter Frost Pack + Complete Collection re-release | Anniversary + holiday gift sales |

### Revenue Projections (4 Scenarios)

| Scenario | Year 1 Units | Year 1 Revenue | Year 2 Units (DLC) | Year 2 Revenue | 3-Year Total |
|----------|-------------|---------------|-------------------|---------------|-------------|
| **Modest** (niche cozy) | 15,000 | $374,700 | 5,000 DLC avg | $159,900 | $690,000 |
| **Solid** (genre competitive) | 40,000 | $999,600 | 18,000 DLC avg | $575,640 | $1,950,000 |
| **Strong** (featured + word-of-mouth) | 100,000 | $2,499,000 | 50,000 DLC avg | $1,599,000 | $5,100,000 |
| **Breakout** (viral cozy hit) | 300,000 | $7,497,000 | 180,000 DLC avg | $5,756,400 | $16,300,000 |

*Assumptions: Average base game price $24.99 (adjusted for regional pricing and sales). Average DLC attach rate 45%. Steam/Platform cut of 30% already deducted from net figures above (net to studio).*

---

## Production Plan

### Team

| Role | Count | Phase | Monthly Cost (avg) | Notes |
|------|-------|-------|--------------------|-------|
| **Game Director / Lead Designer** | 1 | All phases | $8,000 | Design ownership, narrative, systems balance |
| **Programmer (Unity/C#)** | 2 | All phases | $12,000 ($6K each) | Core systems, building, UI, optimization |
| **2D Artist** | 2 | Phases 1-3 | $10,000 ($5K each) | Isometric tile sets, UI art, particle textures |
| **Technical Artist** | 1 | Phases 2-3 | $6,500 | Shader work, lighting, crystal effects, performance |
| **Narrative Designer** | 1 | Phases 1-2 | $5,500 | NPC dialogue, quest writing, story spine |
| **Composer / Sound Designer** | 1 | Phases 2-3 | $4,500 | Seasonal music (4 themes), ambient audio, SFX |
| **QA Tester** | 1 | Phase 3 | $3,500 | Platform testing, accessibility audit, edge cases |
| **Producer (Part-time)** | 1 | All phases | $3,000 | Milestone tracking, platform relations, QA coordination |
| **Total** | **10** | | **$53,000/month** | |

### Timeline

| Month | Phase | Milestone | Deliverable |
|-------|-------|-----------|-------------|
| **1** | Pre-Production | Core prototype | Transmutation system, basic gathering, crystal interface, 1 room type, 5 recipes |
| **2** | Pre-Production | Vertical slice | Full core loop (explore-gather-transmute-build), 1 NPC with questline, 15 recipes, seasonal preview |
| **3** | Production | Systems complete | All 80+ recipes, 4 grove zones (outer layers), building system (all piece types), inventory, save system |
| **4** | Production | NPCs and narrative | All 14 NPCs with questlines, dialogue trees, room requirement system, grandmother journal entries |
| **5** | Production | World and seasons | Seasonal cycling, all grove depth layers, hidden areas, mimic system, visitor NPCs |
| **6** | Production | Art complete | All tile sets, all building piece art, all NPC portraits, crystal effects, particle systems |
| **7** | Production | Audio and polish | 4 seasonal music tracks, ambient audio, all SFX, lighting pass, UI polish |
| **8** | Polish | QA and optimization | Platform builds (PC, Switch, mobile), accessibility audit, performance optimization, bug fix sprint |
| **9** | Polish | Certification and launch | Platform certification, launch trailer, store page assets, day-1 patch |

### Budget Breakdown

| Category | Amount | Percentage |
|----------|--------|-----------|
| **Personnel (9 months)** | $477,000 | 71.5% |
| **Unity Pro Licenses (9 months, 3 seats)** | $6,750 | 1.0% |
| **Dev kits (Switch + mobile test devices)** | $4,000 | 0.6% |
| **Music and audio outsourcing buffer** | $15,000 | 2.2% |
| **Art outsourcing buffer (icon work, marketing art)** | $20,000 | 3.0% |
| **QA and certification fees** | $12,000 | 1.8% |
| **Marketing (trailer, store assets, PR)** | $40,000 | 6.0% |
| **Platform fees and age rating** | $8,000 | 1.2% |
| **Contingency (15%)** | $87,112 | 13.0% |
| **Total** | **$669,862** | **100%** |

*Break-even at modest scenario: Month 18. Break-even at solid scenario: Month 10.*

---

## Technical Requirements

### PC (Steam)

| Spec | Minimum | Recommended |
|------|---------|-------------|
| **OS** | Windows 10 (64-bit) / macOS 12 Monterey | Windows 11 (64-bit) / macOS 14 Sonoma |
| **Processor** | Intel i5-7400 / Apple M1 | Intel i5-11400 / Apple M2 |
| **Memory** | 6 GB RAM | 8 GB RAM |
| **Graphics** | GTX 960 / Intel UHD 630 / M1 GPU | GTX 1660 / Apple M2 GPU |
| **Storage** | 3 GB HDD | 5 GB SSD |
| **DirectX** | Version 11 | Version 12 |
| **Input** | Keyboard + Mouse | Keyboard + Mouse or Controller (XInput) |

### Nintendo Switch

| Spec | Target |
|------|--------|
| **Resolution** | 1080p docked, 720p handheld |
| **Frame Rate** | 30 FPS (docked and handheld) |
| **Touch Support** | Full touch controls in handheld mode |
| **Storage** | 2.5 GB download |
| **Save Cloud** | Supported via Nintendo Switch Online |

### iOS

| Spec | Minimum | Recommended |
|------|---------|-------------|
| **Device** | iPhone 8 / iPad (7th gen) | iPhone 12 / iPad Air (4th gen) |
| **iOS** | 15.0 | 17.0+ |
| **Storage** | 2 GB | 3 GB |
| **Input** | Touch | Touch + controller (MFi) |

### Android

| Spec | Minimum | Recommended |
|------|---------|-------------|
| **Device** | Snapdragon 660 / 3 GB RAM | Snapdragon 778G / 6 GB RAM |
| **Android** | 10.0 | 13.0+ |
| **Storage** | 2 GB | 3 GB |
| **Input** | Touch | Touch + controller |

### Key Technical Challenges

| Challenge | Description | Mitigation Strategy |
|-----------|-------------|---------------------|
| **Real-time crystal refraction effects** | Light passing through amber and crystal elements requires shader work that is expensive on mobile and Switch | Use pre-baked refraction textures for mobile/Switch; reserve real-time refraction for PC recommended spec. Fallback to animated texture maps on minimum spec. |
| **60+ room sanctuary with 80+ piece types** | Each room contains multiple enchanted pieces with individual particle effects and ambient animations | Implement LOD system: rooms off-screen disable particles. Rooms far from camera reduce animation frequency. Hard cap of 8 active particle systems visible at once. |
| **Cross-platform save compatibility** | Players may start on PC and want to continue on Switch or mobile | Use a schema-based save format (JSON) with version migration. Store no platform-specific data in the save file. Cloud save sync via platform SDKs (Steam Cloud, Nintendo Cloud, iCloud/Game Center, Google Play Games). |
| **Isometric tile rendering at scale** | Large sanctuaries with 60 rooms require efficient culling and batching | Use Unity Sprite Atlas for all building pieces. Implement tile-based culling (only render tiles in camera viewport). Static batching for placed pieces that do not animate. |
| **Mobile touch input for building system** | Grid-free placement with rotation requires precise touch input that mobile may struggle with | Implement magnetic snapping (8 directions) with a magnified preview circle on touch. Add an undo button prominently placed. Allow coarse placement then fine-tune with d-pad or swipe. |
| **Seasonal asset loading** | Four seasonal variants of each grove zone require memory management | Stream seasonal textures on zone entry, unload on exit. Keep only current season's assets in memory. Share base geometry across seasons; only swap material textures and particle prefabs. |
