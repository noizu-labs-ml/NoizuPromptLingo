# Aurora Garden

## Title & Genre

| Attribute | Detail |
|-----------|--------|
| **Title** | Aurora Garden |
| **Genre** | Casual Zen / Puzzle / Simulation |
| **Subgenre** | Color-matching garden simulation with narrative discovery |
| **Engine** | Unity 2023 LTS (2D URP, cross-platform shader graph for aurora effects) |
| **Platforms** | PC (Steam), Nintendo Switch 2, iOS, Android, Apple TV |
| **Monetization** | Premium ($14.99) on PC/Console. Free-to-play on mobile with one-time $4.99 unlock for full content (no ads, no energy system, no gacha). Soundtrack available separately ($7.99). |
| **ESRB Rating** | E (Everyone) |
| **PEGI** | 3 |
| **Target Session Length** | 15-45 minutes |
| **Target Completion** | 12-15 hours main narrative; unlimited sandbox post-game |
| **Max Concurrent Players** | 1 (asynchronous online sharing via migration events) |

---

## Vision Statement

Aurora Garden is a meditative rooftop gardening game where color-matching puzzles paint aurora ribbons across the night sky, attracting celestial creatures from East Asian mythology to make your garden their home. It is the game you play to decompress after a long day: no timers, no fail states, no pressure -- just peaceful cultivation and creative expression through light. The game exists because the world needs more spaces that reward stillness, and because the act of composing something beautiful from simple ingredients satisfies a deep human need that most games ignore entirely.

---

## Core Loop

```
┌─────────────────────────────────────────────────────┐
│                    CORE LOOP                         │
│                                                     │
│  ┌──────────┐    ┌──────────────┐    ┌───────────┐  │
│  │ PLANT &  │───>│  COMPOSE     │───>│ ATTRACT   │  │
│  │ TEND     │    │  AURORAS     │    │ CREATURES │  │
│  │          │    │  (match 3+   │    │           │  │
│  │ Select   │    │   petals by │    │ Kirin,    │  │
│  │ seeds,   │    │   color &   │    │ Phoenix,  │  │
│  │ place in │    │   shape)    │    │ Sylphs,   │  │
│  │ garden   │    │             │    │ etc.      │  │
│  └──────────┘    └──────────────┘    └───────────┘  │
│       ^                                    │        │
│       │           ┌──────────────┐         │        │
│       │           │  RECEIVE     │<────────┘        │
│       └───────────│  GIFTS &     │                  │
│                   │  JOURNAL     │                  │
│                   │  ENTRIES     │                  │
│                   │              │                  │
│                   │ Rare seeds,  │                  │
│                   │ wind chimes, │                  │
│                   │ aurora       │                  │
│                   │ fragments    │                  │
│                   └──────────────┘                  │
└─────────────────────────────────────────────────────┘

Target cycle time: 3-8 minutes per full loop iteration
```

### Loop Breakdown

**Step 1: Plant and Tend**

The player selects seeds from their inventory (earned through creature gifts, seasonal events, or discovered in hidden garden nooks) and places them in open garden plots. Each seed grows through 12 hand-painted bloom states over the course of 2-3 real-time minutes. During growth, the player waters flowers by tapping them (no penalty for missing -- flowers grow regardless, watering just advances the bloom state 15% faster). Fully bloomed flowers reveal their petal color and shape: one of 7 color families (crimson, amber, emerald, azure, indigo, violet, pearl) and one of 5 shape families (round, pointed, star, heart, spiral).

The garden has 36 plots arranged in a 6x6 grid across the rooftop. The player starts with 9 unlocked plots and unlocks 3 more every time they attract a new creature species. By the end of the game, all 36 plots are available.

**Step 2: Compose Auroras**

Once flowers are in full bloom, the player selects 3 or more flowers from the grid to compose an aurora sequence. The matching rules are:

- **Color match**: Selecting 3+ flowers of the same color family creates a color-pure aurora ribbon (strongest creature attraction)
- **Shape match**: Selecting 3+ flowers of the same shape family adds a structural pattern to the aurora (increases gift rarity)
- **Hybrid match**: Selecting 3+ flowers that share both color AND shape creates a resonance aurora (attracts the rarest creatures)
- **Rainbow composition**: Selecting 5+ flowers, one from each of 5+ different color families, creates a rainbow aurora (unlocks seasonal grand sequences)

After selection, the player taps "Compose" and watches their aurora ribbon paint across the night sky in real-time. The composition plays out at the speed the player chose: a quick 5-second burst or a slow 30-second unfolding. The generative ambient soundtrack responds to each match -- a crimson aurora brings warm cello tones, an indigo aurora introduces ethereal choir, a rainbow aurora builds a full orchestral swell.

**Step 3: Attract Creatures**

Each aurora composition has a creature attraction value based on color, shape, and hybrid bonuses. The game checks the attraction table and rolls for creature visits. There is no failure -- every aurora attracts at least one common creature. Higher-quality compositions attract rarer creatures.

When a creature arrives, it lands gently in the garden (a sylph alights on a flower, a phoenix chick perches on a wind chime, a kirin steps delicately across the rooftop). The creature explores for 30-90 seconds of real time, interacts with 1-3 garden elements, and then departs -- leaving behind a gift and a journal entry.

**Step 4: Receive Gifts and Journal Entries**

Creature gifts include:
- **Rare seeds** (flowers from new color or shape families not yet in inventory)
- **Wind chimes** (garden decorations that passively attract specific creature types)
- **Aurora fragments** (collectible shards -- collect all 12 in a season to unlock the grand aurora sequence)
- **Guest book entries** (1-2 paragraph illustrated journal entries in the creature's voice, describing the garden from their perspective)

Journal entries are the narrative delivery mechanism. Each creature has 4-6 unique entries that reveal their personality, preferences, and -- for some creatures -- fragments of the previous gardener's story.

---

## Meta Loop

```
┌─────────────────────────────────────────────────────────────┐
│                      META LOOP                              │
│                                                             │
│  Session 1: Plant basics ──> Compose simple auroras         │
│       │                  ──> Attract common creatures       │
│       │                  ──> Receive starter seeds          │
│       v                                                     │
│  Session 2-5: Expand garden ──> Unlock new plots            │
│       │                       ──> Discover hybrid matches   │
│       │                       ──> Attract uncommon creatures│
│       │                       ──> Find hidden notes         │
│       v                                                     │
│  Session 6-15: Seasonal cycle ──> Spring > Summer > Autumn  │
│       │                         > Winter                    │
│       │                         ──> Each season ~45 min     │
│       v                                                     │
│  Session 16+: Post-narrative sandbox ──> Diorama mode       │
│              ──> Full creature collection                   │
│              ──> Seed sharing with other gardens             │
│              ──> Aurora gallery                             │
└─────────────────────────────────────────────────────────────┘
```

### Progression Axes

| Axis | What Grows | How It Grows | Growth Feel |
|------|-----------|-------------|-------------|
| **Garden Size** | 9 plots to 36 plots | Unlock 3 plots per new creature species attracted | Steady, tangible expansion visible on screen |
| **Flower Variety** | 7 color families x 5 shape families = 35 base flowers | Rare seeds from creature gifts, seasonal events, hidden discoveries | Collection-driven; each new flower feels like a find |
| **Creature Codex** | 24 creature species across 4 rarity tiers | Aurora quality determines attraction rolls | Completionist itch; guest book fills with personality |
| **Aurora Complexity** | Simple single-color to rainbow resonance to grand seasonal sequences | Player skill and flower variety unlock composition options | Mastery-driven; the sky becomes increasingly spectacular |
| **Narrative Depth** | 47 hidden notes from the previous gardener | Found in ancient tree roots, under stones, behind wind chimes | Quiet discovery; the story is optional but rewarding |
| **Seasonal Unlocks** | 4 grand aurora sequences (one per season) | Collect 12 aurora fragments per season from creature gifts | Long-term goal with a spectacular payoff each season |

### What Carries Between Sessions

- **Garden state**: All planted flowers, their bloom states, and plot layouts persist
- **Creature codex**: Every journal entry and illustration collected permanently
- **Hidden notes**: The previous gardener's letters accumulate in a "Roots" journal
- **Seed inventory**: Unplanted seeds carry over
- **Wind chimes**: Placed decorations and their passive attraction bonuses remain
- **Season progress**: Fragment collection progress persists across the seasonal cycle
- **Aurora gallery**: Screenshots of every aurora composition the player has created, viewable as a slideshow

---

## Game Mechanics

### Primary Mechanic: Aurora Composition System

The aurora composition system is the heart of Aurora Garden. It is a color-matching puzzle with creative expression layered on top.

**Inputs**: 3-12 fully bloomed flowers selected from the garden grid
**Outputs**: An aurora ribbon rendered in the night sky, a creature attraction event, and a visual/audio spectacle

**Detailed Rules**:

| Match Type | Minimum Flowers | Color Requirement | Shape Requirement | Attraction Bonus | Gift Rarity Bonus |
|-----------|----------------|-------------------|-------------------|-----------------|-------------------|
| Color-pure | 3 | All same family | Any | +2 attraction | Common |
| Color-pure (large) | 5+ | All same family | Any | +4 attraction | Uncommon |
| Shape-pure | 3 | Any | All same family | +1 attraction | Uncommon |
| Shape-pure (large) | 5+ | Any | All same family | +3 attraction | Rare |
| Hybrid | 3 | All same family | All same family | +6 attraction | Rare |
| Hybrid (large) | 5+ | All same family | All same family | +8 attraction | Epic |
| Rainbow | 5 | 5+ different families | Any | +5 attraction | Uncommon |
| Rainbow hybrid | 5 | 5+ different families | All same family | +10 attraction | Legendary |

**Constraints**:
- Each flower can only be used in one composition per aurora cycle
- After composing, flowers enter a "rest" state for 60 seconds before they can be used again (no penalty -- they just recharge)
- The garden grid limits which flowers are available simultaneously (spatial constraint)
- There is no timer, no move counter, no failure condition

**Skill Ceiling**:
The composition system rewards planning without punishing mistakes. A beginner matches 3 red flowers and gets a satisfying aurora. An intermediate player sets up hybrid matches by planting specific color+shape combinations in adjacent plots. An expert player fills their entire 36-plot garden with carefully arranged color+shape pairs to compose legendary rainbow hybrid auroras that attract the rarest creatures and unlock grand seasonal sequences.

The skill is in garden planning (which seeds to plant where), not in speed or reaction time.

**Edge Cases**:
- If the player composes with fewer than 3 flowers, the aurora still renders as a faint ribbon -- it just attracts no creatures (a "practice" composition)
- If all garden plots are full and the player has no matching sets, they can "scatter" any flower to replant it with a different seed (no cost)
- If the player leaves a composition unfinished (selected 2 flowers and closed the game), the selection persists on resume

### Secondary Mechanics

**1. Seasonal Breathing Cycle**

| Season | Duration | Focus | Unique Mechanic | Visual Change |
|--------|----------|-------|-----------------|---------------|
| Spring | ~45 min playtime | Planting and matching basics | Seedlings grow 25% faster | Cherry blossoms drift across screen; sky is soft pink and lavender |
| Summer | ~45 min | Aurora storms with bonus scoring | Every 5th composition triggers a "storm" with double attraction | Warm golden light; fireflies in garden; sky shimmers with heat |
| Autumn | ~45 min | Migration events (async sharing) | Creatures depart and return with seeds from other players' gardens | Amber and rust tones; leaves fall; sky deepens to copper |
| Winter | ~45 min | Reflection and diorama arrangement | Garden freezes into a snow globe diorama; arrange decorations freely | Snow blankets garden; sky is deep indigo; stars are brighter |

After completing all four seasons, the cycle repeats with subtle variations (different creature spawn tables, new hidden notes, alternate aurora color palettes). The game never ends -- it breathes.

**2. Creature Guest Book**

Each of the 24 creature species has:
- A unique personality expressed through 4-6 journal entries (120-150 entries total)
- Specific color and shape preferences that affect attraction odds
- A rarity tier determining base appearance chance
- A seasonal preference (some creatures only appear in certain seasons)

| Rarity Tier | Creature Count | Attraction Requirement | Example Creatures |
|------------|---------------|----------------------|-------------------|
| Common (1 star) | 8 | Any composition | Dewdrop Sylph, Moss Sprite, Cloud Rabbit, Petal Moth, Rain Fox, Mist Wren, Snow Poppy, Breeze Beetle |
| Uncommon (2 star) | 8 | Color-pure (large) or Shape-pure | Starlight Squirrel, Ember Newt, Frost Cricket, Moon Toad, Sunbeam Caterpillar, Willow Wisp, Thunder Koi, Cedar Sparrow |
| Rare (3 star) | 5 | Hybrid composition | Kirin, Phoenix Chick, Jade Butterfly, Obsidian Owl, Coral Seahorse |
| Legendary (4 star) | 3 | Rainbow hybrid composition | Celestial Dragon, Aurora Phoenix, Star Weaver |

**3. Hidden Narrative (Roots Journal)**

47 notes are hidden throughout the garden environment. They are found by:
- Tapping ancient trees in the garden (12 notes, revealed after the tree has been adjacent to 5 bloomed flowers)
- Moving wind chimes to reveal notes behind them (8 notes)
- Composing auroras over specific garden plots (15 notes, triggered by composing while standing near certain plots)
- Attracting specific creature combinations (12 notes, unlocked when 3+ rare-tier creatures visit in a single session)

The notes tell the story of the previous gardener -- a woman named Hana who built this rooftop garden as a love letter to her partner, Sora, who could no longer climb the stairs. The story is told entirely through short, poetic letters (each note is 40-80 words). It is quiet, optional, and achingly human.

### Difficulty Progression

| Stage | Sessions | Complexity Introduced | Player Action | Mastery Marker |
|-------|----------|----------------------|---------------|----------------|
| Tutorial (Spring 1) | 1 | Plant seeds, match 3 same-color flowers | Plant, select, compose | First aurora ribbon |
| Early (Spring 2-3) | 2-3 | Shape matching, creature basics | Plan flower placement | First creature visit |
| Mid-Early (Summer 1-2) | 4-6 | Hybrid matching, wind chimes | Arrange garden for hybrids | First rare creature |
| Mid (Summer 3 - Autumn 1) | 7-10 | Large matches, aurora storms | Optimize 15+ plot layouts | First legendary creature attraction |
| Mid-Late (Autumn 2-3) | 11-14 | Rainbow compositions, migration | Plant all 7 color families | First migration seed from another player |
| Late (Winter) | 15-18 | Diorama mode, grand sequences | Arrange full garden diorama | Complete grand aurora sequence |
| Post-Game | 19+ | Seasonal replay, full codex | Free-form sandbox play | 100% creature codex completion |

---

## World Design

### Map Structure

The game takes place on a single rooftop garden -- a flat, elevated space above the clouds. The garden expands outward from a central ancient tree, with new plots unlocking in concentric rings.

```
┌────────────────────────────────────────────┐
│                                            │
│         SKY (aurora canvas -- infinite)     │
│                                            │
│    Ring 3 (plots 25-36)   [Winter unlock]  │
│    ┌──────────────────────────────┐        │
│    │  Ring 2 (plots 10-24)       │        │
│    │  ┌────────────────────┐     │        │
│    │  │  Ring 1 (plots 1-9)│     │        │
│    │  │    ┌──────────┐   │     │        │
│    │  │    │ ANCIENT  │   │     │        │
│    │  │    │  TREE    │   │     │        │
│    │  │    └──────────┘   │     │        │
│    │  │  [Starting area]  │     │        │
│    │  └────────────────────┘     │        │
│    └──────────────────────────────┘        │
│                                            │
│    ┌────────┐  ┌────────┐  ┌────────┐     │
│    │Wind    │  │Guest   │  │Roots   │     │
│    │Chimes  │  │Book    │  │Journal │     │
│    │Area    │  │Stand   │  │Nook    │     │
│    └────────┘  └────────┘  └────────┘     │
│                                            │
└────────────────────────────────────────────┘
```

### Art Direction Pillars

1. **Watercolor Botanicals**: Every flower rendered in hand-painted watercolor frames (12 bloom states per flower = 420 hand-painted frames for 35 base flowers)
2. **Digital Aurora Photography**: Aurora ribbons use procedural generation with artist-directed curves, inspired by real aurora borealis photography
3. **Studio Ghibli Warmth**: Creature designs draw from East Asian mythology with the warmth and softness of Studio Ghibli character design
4. **Generative Serenity**: The ambient sky subtly shifts in response to the player's actions -- composing crimson auroras warms the sky's base tone, composing indigo deepens it

### Visual Progression

| Stage | Garden Appearance | Sky Appearance | Creature Density | Audio Atmosphere |
|-------|------------------|----------------|-----------------|------------------|
| Starting (9 plots) | Bare rooftop with stone tiles; one ancient tree; empty and expectant | Deep navy with faint stars; no aurora history | 0-1 creatures per session | Solo piano, sparse |
| Early (15 plots) | First flowers blooming; moss creeping between tiles; faint glow from plots | First aurora ribbons linger faintly in the sky between compositions | 1-3 creatures per session | Piano + soft strings |
| Mid (24 plots) | Garden feels alive; wind chimes sway; creatures leave visible traces (feathers, scales) | Multiple aurora ribbons visible simultaneously; sky has a permanent warm undertone | 3-5 creatures per session | Full ensemble, gentle |
| Late (30 plots) | Dense, lush garden; every plot filled; ancient tree in full bloom | Sky is a living canvas; aurora history visible as faint, persistent ribbons | 5-8 creatures per session | Full orchestra, generative |
| Post-game (36 plots) | Complete rooftop paradise; snow globe diorama mode unlocked | Grand aurora sequences paint the entire sky; stars form constellations matching the garden layout | 8+ creatures per session; legendary visits common | Full generative ambient system |

### Audio Design

- **Generative ambient music**: A layered system with 6 instrument stems (piano, cello, choir, synth pad, bells, nature sounds). Each aurora composition adds or modifies layers. The music never loops -- it evolves continuously.
- **Creature sounds**: Each creature has a unique vocalization (the kirin produces a soft wind-chime tone, the phoenix chick chirps in a warm major key, the sylph hums a single sustained note).
- **Environmental audio**: Wind through chimes, water drops from watering, soft rustling of flower stems. All spatialized for headphone listening.
- **Accessibility**: Full audio description mode available for visually impaired players. Every visual event has an audio counterpart.

---

## Narrative

### Story Spine

1. **Equilibrium**: You inherit a rooftop garden above the clouds, left behind by a previous gardener named Hana. The garden is dormant -- plots overgrown, the ancient tree bare, no auroras in the sky. A small note tucked into the tree's roots reads: "I couldn't keep climbing the stairs. Will you tend this for me?"

2. **Inciting Incident**: Your first aurora composition attracts a Dewdrop Sylph -- the first celestial visitor the garden has seen in years. The sylph's journal entry reads: "This place remembers light. It has been waiting." You find Hana's first hidden note under a stone: "Sora loved the auroras most. She said they were letters from the sky."

3. **First Complication**: As your garden grows, you attract rare creatures whose journal entries reference Hana by name. The Jade Butterfly's entry: "Hana once composed an entire spring aurora cycle in indigo, just for the kirin. She said it reminded her of someone's eyes." You begin to understand this garden was built for someone specific.

4. **Rising Action**: Hidden notes reveal more of Hana and Sora's story. Hana built the garden after Sora's illness made it impossible for her to climb to the rooftop. Every flower, every wind chime, every aurora composition was a love letter sent upward -- because Sora could see the auroras from her window below, even when she couldn't reach the garden.

5. **Midpoint Reversal**: You find a note that changes everything: "I received Sora's last letter today. She could see the auroras from her room. She could see them until the very end. She wrote: 'Every night, I watched you paint the sky for me. I never told you I could see them. I didn't want you to stop.'" The garden was never one-sided. Sora was watching the entire time.

6. **Crisis**: In Autumn, creatures begin departing for migration. The garden feels emptier. You find Hana's last note: "I planted one final garden before I left. The rarest seeds I had. I never got to compose its aurora. If you're reading this, will you finish what I started?" A special set of 7 legendary seeds appears in your inventory -- one from each color family.

7. **Climax**: You plant all 7 legendary seeds and compose a rainbow hybrid aurora -- the most spectacular composition the garden has ever seen. The sky explodes in color. Every creature you have ever attracted returns simultaneously. The Celestial Dragon appears for the first time, its journal entry reading: "Hana asked me to carry a message. From Sora: 'I saw every single one. They were perfect. You were perfect.'"

8. **Resolution**: The garden enters a permanent state of gentle abundance. All creatures are welcome. The sky remembers every aurora you have composed. The guest book is full. The Roots journal is complete. A new note appears in the ancient tree: "Thank you, gardener. This place needed someone who would love it without being asked. It found you. Now it is yours." The game continues -- seasons cycle, creatures visit, auroras bloom -- but the story is complete. It is yours now.

### Tone Spectrum (7 Axes)

| Axis | Position | Notes |
|------|----------|-------|
| **Light <-----------> Dark** | Light (90%) | The entire palette is luminous. Darkness is only the night sky -- a canvas, not a threat. |
| **Hopeful <-----------> Melancholy** | Bittersweet center (55% hopeful) | The story carries loss, but every loss is met with beauty and remembrance. |
| **Simple <-----------> Complex** | Simple on surface, complex underneath (30/70) | Anyone can match 3 flowers. The depth is in planning and collection. |
| **Quiet <-----------> Dramatic** | Quiet (85%) | Even the climax is understated. The grandest aurora is still peaceful. |
| **Personal <-----------> Epic** | Deeply personal (95%) | The stakes are one garden, two people, and the sky between them. |
| **Structured <-----------> Open** | Open with gentle structure (70% open) | The seasonal cycle provides rhythm, but the player sets their own pace. |
| **Warm <-----------> Cool** | Warm (75%) | Even the coolest indigo auroras carry warmth from the generative music. |

### Creature Table

| Creature | Rarity | Theme | Preferred Colors | Preferred Shapes | Season | Journal Entries |
|----------|--------|-------|-----------------|-----------------|--------|----------------|
| Dewdrop Sylph | Common | Morning dew and renewal | Azure, Pearl | Round | Spring | 5 |
| Moss Sprite | Common | Quiet persistence | Emerald | Star | Spring | 4 |
| Cloud Rabbit | Common | Playful wandering | Pearl, Azure | Round | All | 6 |
| Petal Moth | Common | Gentle attraction | Crimson, Violet | Heart | Spring, Summer | 5 |
| Rain Fox | Common | Gentle persistence | Azure, Indigo | Spiral | All | 4 |
| Mist Wren | Common | Elusive song | Pearl | Pointed | Autumn | 4 |
| Snow Poppy | Common | Quiet endurance | Pearl, White | Round | Winter | 5 |
| Breeze Beetle | Common | Steady movement | Emerald, Amber | Spiral | Summer | 4 |
| Starlight Squirrel | Uncommon | Gathering and storing | Amber, Gold | Star | Autumn | 5 |
| Ember Newt | Uncommon | Warmth in small places | Crimson, Amber | Pointed | Summer | 4 |
| Frost Cricket | Uncommon | Music in cold | Azure, Pearl | Spiral | Winter | 5 |
| Moon Toad | Uncommon | Patient wisdom | Indigo, Violet | Round | All | 6 |
| Sunbeam Caterpillar | Uncommon | Transformation | Gold, Amber | Spiral | Spring, Summer | 4 |
| Willow Wisp | Uncommon | Gentle guidance | Pearl, Emerald | Star | All | 5 |
| Thunder Koi | Uncommon | Power through flow | Indigo, Azure | Spiral | Summer, Autumn | 4 |
| Cedar Sparrow | Uncommon | Home-building | Emerald, Brown | Heart | Spring | 5 |
| Kirin | Rare | Graceful majesty | Indigo, Violet | Spiral | Spring, Winter | 6 |
| Phoenix Chick | Rare | Rebirth and warmth | Crimson, Gold | Star | Summer, Autumn | 6 |
| Jade Butterfly | Rare | Transformation and memory | Emerald, Pearl | Heart | Spring | 5 |
| Obsidian Owl | Rare | Silent wisdom | Indigo, Black | Pointed | Winter | 5 |
| Coral Seahorse | Rare | Oceanic patience | Crimson, Azure | Spiral | Summer | 4 |
| Celestial Dragon | Legendary | Cosmic guardianship | All colors | All shapes | Winter (post-game) | 6 |
| Aurora Phoenix | Legendary | Ultimate rebirth | Crimson, Gold, Violet | Star, Heart | Autumn (post-game) | 5 |
| Star Weaver | Legendary | Creation itself | Pearl, Gold, Indigo | Spiral, Star | All (post-game) | 6 |

---

## Player Personas

### P-002: Sarah Chen -- "The Micro-Gamer"

**Why Aurora Garden fits**: Sarah plays in 15-20 minute bursts between family duties. Aurora Garden's core loop completes in 3-8 minutes, perfectly fitting her fragmented schedule. The one-time $4.99 mobile unlock (no gacha, no energy system) respects her $15/month entertainment budget and gives her the full experience. The creature collection mechanic scratches her collection itch without predatory monetization.

**Predicted experience**: Sarah plays during nap time and before bed. She loves the creature guest book -- reading journal entries gives her the same "aww" reaction she gets from character reveals in her gacha games, but without the anxiety of pulls. She skips the hidden narrative (not enough uninterrupted time to follow a story) but completes the creature codex within 3 weeks. She shows the game to her kids, who love watching the auroras. She considers it the best $4.99 she has spent on a mobile game.

### P-004: James Morrison -- "The Stress Whale"

**Why Aurora Garden fits**: James wants progression without thinking. Aurora Garden delivers -- every session produces visible progress (new flowers blooming, creatures visiting, auroras painted). The premium PC version ($14.99) gives him everything upfront with no further spending required. The generative ambient music and lack of timers make it the perfect 11 PM wind-down game after crisis management days.

**Predicted experience**: James plays on his Steam Deck during commutes and at home before bed. He appreciates that the game respects his time -- no dailies, no FOMO, no pressure. He doesn't optimize compositions; he just plants whatever seeds look pretty and matches whatever is available. He spends 20 minutes a night on it for 4 months straight. He buys the soundtrack separately because the generative music becomes his work focus track. He never completes the creature codex but doesn't care -- the game serves its purpose as pure decompression.

### P-013: Robert Thompson -- "The Relaxation Player"

**Why Aurora Garden fits**: Robert wants mindless repetitive gameplay with no pressure. Aurora Garden's no-timer, no-fail-state design is exactly what he needs. The matching is simple enough to be meditative. The seasonal cycle provides structure without urgency. The game never interrupts his relaxation with ads or pop-ups (he paid the $4.99 unlock immediately).

**Predicted experience**: Robert plays exactly 12 minutes every night before sleep. He replants the same flower layout every session because he finds the repetition soothing. He has attracted the same 5 common creatures 40+ times each and reads every journal entry multiple times because they comfort him. He never discovers the hidden narrative, never creates a hybrid match, and never advances past mid-game. He plays for 9 months straight and considers it one of his favorite games ever. He does not know what a "legendary creature" is.

### P-006: Eleanor Vance -- "The Loyal Strategist"

**Why Aurora Garden fits**: Eleanor wants systems she can master over months. The composition system's skill ceiling -- planning garden layouts for optimal hybrid and rainbow matches -- gives her the strategic depth she craves. The premium pricing model ($14.99 one-time) fits her fixed-income budget perfectly. The creature codex provides a long-term mastery goal.

**Predicted experience**: Eleanor plays 2 hours every morning with her coffee. She maps optimal flower placement in a notebook. She is the first to discover that planting azure-spiral flowers in a ring around the ancient tree produces a hidden composition bonus. She completes the creature codex in 6 weeks, reads every hidden note, and cries at Sora's letter. She then replays the seasonal cycle 3 more times, optimizing for the most spectacular aurora gallery possible. She recommends the game to her entire online strategy forum with a 2,000-word review about the hidden depth of the composition system.

---

## User Stories

### Exploration

1. As a **player (P-002)**, I want to tap on ancient trees to discover hidden notes, so that I can uncover the garden's history at my own pace.

2. As a **player (P-006)**, I want to experiment with different flower placement patterns across the 36-plot grid, so that I can discover optimal layouts for hybrid compositions.

3. As a **player (P-013)**, I want to scroll through my aurora gallery to revisit past compositions, so that I can relax by watching my favorite auroras again.

4. As a **player (P-004)**, I want the garden state to persist exactly as I left it between sessions, so that I never lose progress or feel penalized for taking a break.

5. As a **player (P-006)**, I want to unlock new garden plots by attracting new creature species, so that exploration and collection feel meaningfully connected.

### Core Mechanics

6. As a **player (P-002)**, I want to select 3+ flowers of the same color and tap "Compose" to create an aurora ribbon, so that I can see immediate visual feedback from a simple action.

7. As a **player (P-006)**, I want to match flowers by both color AND shape to create hybrid compositions, so that I can attract rarer creatures through strategic play.

8. As a **player (P-013)**, I want flowers to grow regardless of whether I water them, so that I never feel punished for inattention.

9. As a **player (P-004)**, I want a "Quick Compose" button that auto-selects the best available match, so that I can make progress without planning when I am tired.

10. As a **player (P-006)**, I want to see the attraction value of my composition before confirming it, so that I can make informed strategic decisions.

11. As a **player (P-002)**, I want to scatter a flower and replant its plot with a different seed when I have no useful matches, so that I am never stuck with an unusable garden.

12. As a **player (P-004)**, I want flowers to enter a brief rest state (60 seconds) after composing rather than being consumed, so that my garden feels sustainable rather than depleting.

### Narrative

13. As a **player (P-006)**, I want to collect hidden notes that reveal the story of the previous gardener, so that I can experience the emotional narrative at my own pace.

14. As a **player (P-002)**, I want creature journal entries to be short (40-80 words) and illustrated, so that I can enjoy them in the brief moments between family tasks.

15. As a **player (P-004)**, I want the narrative to be entirely optional and never gated behind gameplay milestones, so that I can skip it without penalty when I just want to decompress.

16. As a **player (P-006)**, I want the hidden notes to be discoverable through different methods (tapping trees, moving chimes, composing near plots, attracting creature combos), so that exploration feels varied and rewarding.

17. As a **player (P-013)**, I want the game to save my place in the narrative automatically, so that I never have to remember where I was in the story.

### Progression

18. As a **player (P-002)**, I want to unlock 3 new garden plots every time I attract a new creature species, so that my garden visibly expands as I play.

19. As a **player (P-006)**, I want a creature codex that tracks which species I have attracted, how many journal entries I have collected per species, and which entries are still missing, so that I can pursue completion systematically.

20. As a **player (P-004)**, I want each seasonal cycle to last approximately 45 minutes of playtime, so that I experience the full rhythm of the garden without it feeling grindy.

21. As a **player (P-006)**, I want to collect 12 aurora fragments per season to unlock the grand aurora sequence, so that I have a clear long-term goal with a spectacular payoff.

22. As a **player (P-002)**, I want to receive rare seeds from creature gifts that unlock flowers from new color or shape families, so that my collection grows naturally through play.

23. As a **player (P-013)**, I want the seasonal cycle to repeat with subtle variations after completing all four seasons, so that the game never ends and I always have something familiar to return to.

### Accessibility

24. As a **player (P-018)**, I want full VoiceOver support for all garden elements, menus, creature journal entries, and narrative notes, so that I can play the entire game without sighted assistance.

25. As a **player (P-018)**, I want audio cues that indicate flower color and shape families through distinct tones and spatialization, so that I can plan compositions through sound alone.

26. As a **player (P-013)**, I want a "zen mode" toggle that removes all UI elements and plays the generative ambient music with no interaction required, so that I can use the game as a sleep aid.

27. As a **player (P-002)**, I want the game to support portrait and landscape orientation on mobile, so that I can play one-handed while holding my child.

28. As a **player (P-018)**, I want a high-contrast mode that increases visual distinction between color families, so that I can distinguish flowers with my remaining 10% vision.

### Social / Sharing

29. As a **player (P-006)**, I want to receive seeds from other players' gardens during the Autumn migration event, so that I can discover flower varieties I have not found yet.

30. As a **player (P-002)**, I want to share aurora screenshots with my friends via the OS share sheet, so that I can show off my most beautiful compositions.

31. As a **player (P-004)**, I want the migration event to be purely asynchronous with no direct player interaction required, so that I benefit from the community without social pressure.

32. As a **player (P-006)**, I want an aurora gallery that displays every composition I have ever created, so that I can review my progression and share my collection.

### Platform-Specific

33. As a **player (P-013)**, I want the Android version to work fully offline after the initial download, so that I can play in bed without using mobile data.

34. As a **player (P-002)**, I want the iOS version to support iCloud save sync, so that my garden carries over if I switch between iPhone and iPad.

35. As a **player (P-006)**, I want the PC version to support keyboard shortcuts for flower selection and composition, so that I can play efficiently during my 2-hour morning sessions.

---

## Monetization

### Revenue Model: Hybrid Premium/F2P

Aurora Garden uses a **split model** that matches the game's philosophy of respecting the player:

| Platform | Model | Price | Justification |
|----------|-------|-------|---------------|
| PC (Steam) | Premium | $14.99 | PC players expect full content upfront. The price reflects the 12-15 hour narrative plus unlimited sandbox. No additional purchases required. |
| Nintendo Switch 2 | Premium | $14.99 | Console players expect ownership. The Switch's portable mode aligns with the game's meditative session design. |
| iOS / Android | Free-to-play with one-time unlock | Free download, $4.99 unlock | Mobile players need to try before buying. The free tier includes the full Spring season (25% of content) with no ads. The $4.99 unlock opens all seasons, all creatures, and the full narrative. |
| Apple TV | Premium (via iOS universal purchase) | $4.99 | Apple TV players already own the iOS version. Universal purchase. |
| Soundtrack (all platforms) | Separate purchase | $7.99 | The generative ambient music has standalone value. Sold as a 90-minute album on Steam and Bandcamp. |

### Why This Model Fits This Game

1. **No gacha, no energy system, no ads**: The game's core philosophy is peacefulness. Predatory monetization contradicts that directly.
2. **One-time unlock on mobile**: The $4.99 price point is an impulse buy. Players like Robert (P-013) will pay it after one session. Players like Sarah (P-002) will pay it because it respects her budget.
3. **Premium on PC/Console**: The 12-15 hour narrative justifies the $14.99 price. Reviews will emphasize the value.
4. **Soundtrack as revenue multiplier**: The generative music is genuinely useful as a focus/sleep aid. Separate sales capture non-gamers.

### Revenue Projections (4 Scenarios)

| Scenario | PC/Console Units (Year 1) | Mobile Unlocks (Year 1) | Soundtrack Units (Year 1) | Gross Revenue | Net Revenue (after 30% platform cut) |
|----------|--------------------------|------------------------|--------------------------|---------------|--------------------------------------|
| **Modest** | 5,000 | 20,000 | 1,000 | $189,850 | $132,895 |
| **Expected** | 15,000 | 80,000 | 5,000 | $614,850 | $430,395 |
| **Strong** | 40,000 | 200,000 | 15,000 | $1,589,850 | $1,112,895 |
| **Breakout** | 100,000 | 500,000 | 50,000 | $3,999,850 | $2,799,895 |

Assumptions for "Expected" scenario: Steam featuring in "Relaxing" category, 15% mobile conversion rate from free to paid, 7% soundtrack attach rate. No paid marketing -- growth driven by organic discovery, word of mouth, and streamer coverage.

### DLC Roadmap (Post-Launch)

| DLC | Timeline | Content | Price |
|-----|----------|---------|-------|
| **Twilight Garden Expansion** | Month 6 | 12 new creatures, new "twilight" color family, 20 new hidden notes (new story arc), 12 new plots | $5.99 (PC/Console) / $2.99 (Mobile) |
| **Soundtrack Volume 2** | Month 8 | 60 minutes of new generative stems themed around twilight | $4.99 |
| **Community Garden** | Month 12 | Shared garden space where players co-tend a single rooftop; migration events become real-time | Free update |

---

## Production Plan

### Team

| Role | Count | Phase | Monthly Cost (avg) | Duration |
|------|-------|-------|--------------------|----------|
| Creative Director / Game Designer | 1 | Full project | $8,000 | 14 months |
| Lead Programmer (Unity) | 1 | Full project | $9,000 | 14 months |
| 2D Artist (watercolor) | 2 | Months 2-10 | $6,500 each | 9 months |
| Technical Artist (aurora shaders, procedural gen) | 1 | Months 3-12 | $8,000 | 10 months |
| Audio Designer / Composer | 1 | Months 4-12 | $6,000 | 9 months |
| Narrative Designer | 1 | Months 2-8 | $5,500 | 7 months |
| QA Tester | 1 | Months 10-14 | $4,000 | 5 months |
| Producer / Project Manager | 1 (part-time, 50%) | Full project | $3,500 | 14 months |
| Localization (contract) | 1 (contract) | Months 12-13 | $8,000 flat | 2 months |
| Platform Certification (contract) | -- | Month 13-14 | $5,000 flat | 2 months |

### Timeline

| Month | Milestone | Deliverables |
|-------|-----------|-------------|
| 1 | **Pre-production** | Finalized game design document, art style guide, technical architecture, prototype of aurora composition system |
| 2 | **Core systems** | Garden grid (36 plots), flower growth system (12 bloom states), seed inventory, basic composition matching (color-only) |
| 3 | **Composition depth** | Shape matching, hybrid matching, rainbow compositions, attraction value system, aurora ribbon rendering (first pass) |
| 4 | **Creature system** | 24 creature definitions, attraction tables, guest book UI, first 40 journal entries, audio design begins |
| 5 | **Seasonal cycle** | Spring/Summer/Autumn/Winter cycle implementation, seasonal mechanics (storms, migration, diorama), generative ambient music (first stems) |
| 6 | **Art production I** | 420 hand-painted flower bloom frames (35 flowers x 12 states), first 8 common creature illustrations |
| 7 | **Art production II** | 16 uncommon/rare creature illustrations, wind chime designs, garden decoration art, aurora shader polish |
| 8 | **Narrative complete** | All 47 hidden notes written and placed, all 120+ journal entries written, narrative trigger system implemented |
| 9 | **Integration** | Full game playable start to finish, all systems connected, generative music fully integrated, aurora gallery functional |
| 10 | **Polish I** | Creature animations (visit sequences), UI polish, accessibility features (VoiceOver, high-contrast, zen mode) |
| 11 | **Polish II** | Visual effects polish (aurora ribbon quality), audio mixing, platform-specific optimizations (mobile battery, Switch performance) |
| 12 | **QA + Localization** | Full QA pass (all platforms), localization into 8 languages (EN, JA, KO, ZH, DE, FR, ES, PT), soundtrack mastering |
| 13 | **Certification + Submission** | Platform certification (Steam, Switch 2, iOS, Android), age rating submissions, store page assets |
| 14 | **Launch** | PC/Console launch, mobile launch (staggered by 2 weeks), soundtrack release, press kit distribution |

### Budget Breakdown

| Category | Total Cost | Notes |
|----------|-----------|-------|
| **Salaries (team)** | $478,000 | 10 roles over 14 months, blended rates |
| **Contract work** | $13,000 | Localization + platform certification |
| **Software licenses** | $8,000 | Unity Pro, Adobe Creative Suite, audio tools |
| **Hardware** | $5,000 | Test devices (Switch 2 dev kit, mid-range Android, iPad) |
| **Art outsourcing buffer** | $15,000 | Additional frames if watercolor pipeline needs scaling |
| **Marketing** | $10,000 | Press kit, trailer production, influencer outreach |
| **Platform fees** | $4,000 | Developer accounts, age rating submissions |
| **Contingency (15%)** | $79,950 | Scope adjustments, delayed milestones, platform changes |
| **Total** | **$612,950** | |

---

## Technical Requirements

### Platform Specifications

| Spec | PC (Min) | PC (Rec) | Switch 2 | iOS | Android (Min) | Android (Rec) |
|------|----------|----------|----------|-----|---------------|---------------|
| **OS** | Windows 10 64-bit | Windows 11 64-bit | Switch 2 OS | iOS 15+ | Android 12+ | Android 14+ |
| **Processor** | Intel i3-8100 | Intel i5-10400 | ARM (native) | Apple A12 | Snapdragon 730 | Snapdragon 8 Gen 2 |
| **RAM** | 4 GB | 8 GB | System shared | 2 GB | 2 GB | 4 GB |
| **GPU** | Intel UHD 630 | NVIDIA GTX 1650 | Custom NVIDIA | Apple A12 GPU | Adreno 618 | Adreno 740 |
| **Storage** | 3 GB HDD | 3 GB SSD | 3 GB | 2 GB | 2 GB | 2 GB |
| **macOS** | macOS 12+ (Apple Silicon or Intel) | macOS 14+ (Apple Silicon) | N/A | N/A | N/A | N/A |

### Key Technical Challenges

| Challenge | Risk | Mitigation |
|-----------|------|-----------|
| **Aurora ribbon rendering on low-end mobile** | High: Procedural aurora shaders with 12+ blend modes can drop below 30 FPS on Adreno 618 GPUs | Implement LOD system for aurora rendering: full shader on rec specs, simplified ribbon geometry on min specs. Pre-bake common aurora patterns as texture atlas fallback. |
| **420 hand-painted frames at 60 FPS** | Medium: 35 flowers x 12 states = 5,040 unique frames to load and display smoothly | Use sprite atlas packing with async loading. Only load frames for flowers currently in the garden (max 36). Bloom animations are 6 FPS (artistic choice) so memory pressure is manageable. |
| **Generative ambient music across platforms** | Medium: Real-time audio stem mixing varies across mobile hardware | Pre-render 64 ambient mood tracks at production time. Layer 2-3 tracks per session based on aurora state. Use FMOD or Wwise for cross-platform audio consistency. |
| **Switch 2 native port** | Low-Medium: Unity 2023 LTS supports Switch 2 natively, but shader graph compatibility needs validation | Allocate 2 weeks in Month 11 for Switch-specific shader testing. Maintain a simplified shader branch for any aurora effects that do not translate. |
| **Offline mobile play with migration events** | Low: Migration events are asynchronous (not real-time), so offline play just queues migration until next connection | Store migration state locally as a queue. Sync when connectivity returns. No gameplay is blocked by being offline. |
| **VoiceOver accessibility on iOS** | Medium: Unity accessibility support requires custom implementation for garden grid elements | Use Unity Accessibility Plugin (UAP) as foundation. Custom-label all garden elements, composition buttons, and journal entries. Test with VoiceOver from Month 10. |

### Save System

- **Format**: JSON save files stored locally
- **Cloud sync**: Steam Cloud (PC), iCloud (iOS), Google Play Games (Android), Switch Online (Switch 2)
- **Save slots**: 3 slots per platform
- **Auto-save**: Every 30 seconds during active gameplay, on composition completion, and on app pause/minimize
- **Save size**: ~200 KB per slot (garden state, inventory, codex, narrative progress, settings)

### Accessibility Features

| Feature | Implementation |
|---------|---------------|
| **VoiceOver / TalkBack** | Full screen reader support for all UI elements, garden plots, creature entries, and narrative notes |
| **High-contrast mode** | Increases color saturation 200%, adds black outlines to all flowers, replaces subtle gradients with solid colors |
| **Audio cues for flower types** | Each color family has a distinct musical note (C through B). Each shape family has a distinct timbre. Players can identify flowers by ear. |
| **Zen mode** | Disables all UI, plays generative music, auto-advances through aurora compositions. Pure relaxation mode. |
| **Scalable text** | All text scales from 80% to 200% without layout breaking |
| **One-handed mode** | Portrait orientation on mobile; all interactions reachable with thumb swipe from bottom |
| **Reduced motion** | Disables particle effects, aurora ribbon animations play as fades instead of unfolds |
| **Colorblind support** | 3 colorblind modes (deuteranopia, protanopia, tritanopia) that remap flower colors to distinguishable alternatives with pattern overlays |

---

*Original concept preserved. Document expanded from seed idea into full game design specification.*
