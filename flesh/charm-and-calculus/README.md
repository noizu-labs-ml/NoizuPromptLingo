# Charm and Calculus

**Puzzle RPG / Educational**

---

## Title and Genre

| Field | Value |
|-------|-------|
| **Title** | Charm and Calculus |
| **Genre** | Puzzle RPG with educational math mechanics |
| **Sub-genres** | Turn-based combat, creature collection, narrative adventure |
| **Comparable titles** | Pokemon (creature collection), Prodigy (math edutainment), Persona (school life sim), Dragon Quest Monsters (summoner RPG) |
| **Platform** | PC (Steam/Epic), Nintendo Switch 2, iOS, Android |
| **Engine** | Unity (URP) -- cross-platform reach, proven mobile optimization, strong Switch 2 support |
| **Rating** | E10+ (Everyone 10+) -- Fantasy Violence, Mild Suggestive Themes |
| **Monetization** | Free-to-play with seasonal cosmetic battle pass ($9.99/season) and optional cosmetic familiars; no pay-to-win, no content paywalls |

---

## Vision Statement

You are a first-year summoner at the Ethereal Academy, a floating-island school where monsters are summoned through -- and defeated by -- solving puzzles rooted in real mathematical reasoning. Every spell is a problem. Every monster embodies a discipline. Algebraic beasts charge with linear fury, geometric constructs rearrange the battlefield itself, and probabilistic elementals force you to weigh odds under pressure. The game never lets you stagnate: it diagnoses weak areas and feeds you targeted challenges disguised as monster encounters.

Charm and Calculus is a game where math is magic -- literally. Players genuinely learn while playing, but never feel lectured. The academy has secrets worth uncovering: rogue summoners wielding forbidden non-Euclidean geometry, a missing professor who discovered an unsolvable problem, and an ancient construct predating the school that guards a theorem capable of reshaping reality. The story treats mathematics as wonder, not homework.

The core promise: **master the math, master the magic**.

---

## Core Loop

```
Enter Academy Zone -> Encounter Monster -> Read Problem Type -> Solve Under Time Pressure -> Damage / Heal / Summon Based on Accuracy + Speed -> Collect XP + Concept Mastery -> Level Up / Unlock New Disciplines -> Progress Story Beat -> (repeat)
```

**Session target**: 15-25 minutes for a satisfying combat + story beat cycle. Extends to 45-60 minutes during dungeon runs.

### Loop Detail

1. **Explore** -- Navigate the Ethereal Academy's floating island campus. Visit classrooms, the library, dormitories, and the Summoning Arena. NPC classmates roam with their own schedules and dialogue. Exploration is punctuated by wild monster encounters in the Veil (the chaotic space between islands where rogue summons manifest).

2. **Encounter** -- A monster appears. Its visual design immediately signals its mathematical discipline: crystalline polyhedra for geometry, swirling probability clouds for statistics, coiled equation-serpents for algebra. The encounter type determines the puzzle format.

3. **Solve** -- A math problem overlays the combat screen. Solve it accurately and quickly to power your spells. A fireball's area of effect is a geometry calculation. A summoning ritual requires balancing an equation. A probability spell demands you compute expected value. Difficulty scales with your grade level and diagnosed proficiency.

4. **Combat** -- Accuracy determines damage. Speed determines turn order. Solving perfectly grants bonus effects (critical hits, bonus summons, defensive shields). Failing to solve means the monster attacks -- but the game never kills you for not knowing; it teaches and retries with a simpler variant.

5. **Collect** -- Earn XP for character level, Concept Mastery points for each mathematical discipline, and potentially a monster egg if you performed exceptionally.

6. **Progress** -- Level up unlocks new spell types (new math domains). Concept Mastery fills your Summoner's Notebook. Story beats trigger at mastery thresholds, not arbitrary level gates.

### Puzzle Types by Discipline

| Discipline | Monster Family | Puzzle Format | Example Problem |
|-----------|---------------|--------------|-----------------|
| **Arithmetic** (Year 1) | Emberlings | Mental math speed rounds | "7 x 8 + 13 = ?" |
| **Algebra** (Year 1-2) | Equation Serpents | Solve for unknown variables | "3x + 7 = 22. Find x." |
| **Geometry** (Year 2) | Crystal Constructs | Calculate area, perimeter, angles | "A triangle has sides 3, 4, 5. Find its area." |
| **Statistics** (Year 2-3) | Probability Elementals | Compute odds, expected value, mean/median | "A die is rolled twice. P(sum > 9) = ?" |
| **Trigonometry** (Year 3) | Wave Weavers | Sin/cos/tan applications | "A ladder 10m long leans against a wall at 60 degrees. How high?" |
| **Calculus** (Year 4) | Flux Behemoths | Derivatives, integrals, limits | "Find d/dx of x^3 - 4x + 2" |
| **Non-Euclidean** (Year 4 secret) | Forbidden Constructs | Lateral-thinking geometry puzzles | Tessellation paradoxes, Mobius strip topology |

---

## Meta Loop

```
Year Completion (Grades 1-4) -> Final Exam Boss -> Academy Ranking -> New Year with New Disciplines -> Unlock Advanced Zones -> NPC Relationship Milestones -> Discover Academy Secrets -> Thesis Defense Endgame -> (repeat for post-game Prestige Years)
```

### Progression Axes

| Axis | What Grows | How It Feels |
|------|-----------|-------------|
| **Knowledge** | Summoner's Notebook fills with concepts, proofs, and bestiary entries | "I actually understand this math" |
| **Roster** | Collection of summoned companion creatures grows, each tied to a mastered concept | "My team reflects what I've learned" |
| **Rank** | Academy standing rises from unranked to Archmage | "I'm becoming the best summoner" |
| **Story** | Academy mysteries deepen -- missing professor, forbidden geometry faction, ancient construct | "There's something bigger going on here" |
| **NPC Bonds** | Classmates grow from strangers to study partners to friends with personal storylines | "These characters feel real" |
| **Skill** | Problems that took 30 seconds in Year 1 take 3 seconds in Year 3 | "I've genuinely improved" |

### Year System

| Year | Level Range | Disciplines Unlocked | Zone | Boss Theme |
|------|------------|---------------------|------|------------|
| **Year 1** | 1-15 | Arithmetic, Basic Algebra | Foundation Island | The Arithmetic Archon (speed-based arithmetic gauntlet) |
| **Year 2** | 16-30 | Intermediate Algebra, Geometry, Intro Statistics | Spiralspire Tower | The Geometric Golem (spatial reasoning marathon) |
| **Year 3** | 31-45 | Advanced Algebra, Statistics, Trigonometry | Stormveil Observatory | The Probability Prism (risk/reward decision chains) |
| **Year 4** | 46-60 | Calculus, Advanced Statistics | The Abyssal Archive | The Flux Colossus (multi-stage calculus boss) |
| **Post-game** | 61-99 | Non-Euclidean puzzles, Thesis Defenses | Forbidden Stacks | The Unsolver (requires creative application of all disciplines) |

### Difficulty Scaling Engine

The game maintains a **Mastery Profile** per player, tracking accuracy and speed across every sub-topic:

```
Player Profile:
  Arithmetic:       94% accuracy, 2.1s avg  -> MASTERY
  Linear Equations: 87% accuracy, 4.3s avg  -> PROFICIENT
  Quadratics:       62% accuracy, 8.1s avg  -> STRUGGLING (diagnosed)
  Geometry-Area:    91% accuracy, 3.0s avg  -> MASTERY
  Geometry-Volume:  55% accuracy, 9.2s avg  -> STRUGGLING (diagnosed)
```

When a player is **STRUGGLING**, the engine:
1. Reduces time pressure in encounters using that topic
2. Inserts a "study session" NPC event where a classmate explains the concept with a visual tutorial
3. Provides 2-3 easier variant problems before returning to full difficulty
4. Awards bonus XP for the diagnosed topic to incentivize practice

When a player is **MASTERY**, the engine:
1. Increases time pressure
2. Introduces variant puzzles (word problems, multi-step, "find the error")
3. Offers optional challenge modes (solve without multiple choice, solve mentally)
4. Triggers NPC requests for tutoring (teaching reinforces learning)

---

## Game Mechanics

### Combat Math System

Battles play out in a turn-based format with real-time puzzle solving. Each turn presents a problem from the monster's discipline. Performance determines combat outcomes.

#### Accuracy-Damage Mapping

| Accuracy | Result | Damage Multiplier | Effect |
|----------|--------|-------------------|--------|
| Perfect (correct, first try, fast) | Critical Cast | 1.5x | Bonus: extra turn or party buff |
| Correct (right answer, within time) | Solid Cast | 1.0x | Standard damage |
| Partial (right approach, minor error) | Glancing Cast | 0.5x | Reduced damage, monster does not counter |
| Incorrect (wrong answer) | Fizzle | 0x | No damage, monster attacks next |
| Timeout (no answer in time limit) | Backlash | 0x | Minor self-damage from spell recoil |

#### Time Pressure by Difficulty

| Difficulty | Time Limit | Available At |
|-----------|-----------|-------------|
| Gentle | 30 seconds | Year 1, all STRUGGLING topics |
| Standard | 15 seconds | Default for on-level content |
| Challenging | 8 seconds | MASTERY topics, Year 3+ |
| Extreme | 5 seconds | Thesis Defense dungeons, post-game |

#### Companion Summon System

Players collect companion creatures by excelling in specific disciplines. Each companion provides passive bonuses and can be deployed for special attacks.

| Companion | Discipline | Unlock Condition | Passive Bonus | Active Ability |
|-----------|-----------|-----------------|---------------|----------------|
| Pyra (Emberling) | Arithmetic | Complete Year 1 | +10% accuracy timer | "Number Nova" -- clears all arithmetic problems on screen |
| Serpentina | Algebra | Master 10 algebra problems | Reveals one step of the solution | "Variable Strike" -- auto-solves the current problem |
| Polyhedra | Geometry | Complete 5 area calculations correctly | Shows a visual diagram hint | "Shape Shift" -- rearranges problem into visual form |
| Fortuna | Probability | Win 3 battles using statistics spells | Displays probability of each answer being correct | "Loaded Dice" -- eliminates one wrong answer |
| Sinewave | Trigonometry | Master trigonometry concepts | Auto-computes common trig values | "Resonance" -- doubles damage if answer is correct |
| Flux | Calculus | Complete Year 4 | Graphs the function visually | "Derivative Dash" -- auto-differentiates once per battle |

#### Monster Families

| Family | Visual Theme | Discipline | Signature Move | Weakness |
|--------|-------------|-----------|----------------|----------|
| **Emberlings** | Small flame creatures with number-shaped embers | Arithmetic | Number Barrage (rapid-fire mental math) | High speed, low HP |
| **Equation Serpents** | Coiling snakes with variables on scales | Algebra | Coiled Unknown (hide a variable) | Sequential solving (solve A to reveal B) |
| **Crystal Constructs** | Geometric polyhedra, refracting light | Geometry | Tessellation Trap (rearrange shapes) | Spatial reasoning attacks |
| **Probability Elementals** | Swirling clouds of dice and cards | Statistics | Gambler's Ruin (randomize your options) | Expected value counters |
| **Wave Weavers** | Sinusoidal spectral beings | Trigonometry | Phase Shift (rotate the problem) | Graph-based reasoning |
| **Flux Behemoths** | Massive shape-shifting creatures | Calculus | Derivative Storm (multi-step problems) | Step-by-step breakdown |
| **Forbidden Constructs** | Impossible shapes, Escher-like geometry | Non-Euclidean | Paradox Loop (reverse the problem logic) | Creative lateral thinking |

### Summoner's Notebook

An in-game journal that automatically tracks every concept encountered, combining bestiary and textbook into one reference.

#### Notebook Structure

| Section | Content | Auto-Updates | Player Can |
|---------|---------|-------------|-----------|
| **Concept Index** | Mathematical concepts organized by discipline, with illustrated examples | Yes -- new concepts added on first encounter | Bookmark favorites, add personal notes |
| **Bestiary** | Monster entries explaining the real-world math principle each embodies | Yes -- new monsters added on first defeat | Review strategies, track mastery percentage |
| **Practice Problems** | Generated problem sets tied to each concept, with step-by-step solutions | Yes -- new problems generated based on diagnosed weak areas | Retake for XP, challenge mode for bonus rewards |
| **Spell Compendium** | Every spell unlocked, its mathematical basis, and optimal use cases | Yes -- new spells on unlock | Test in practice arena, customize loadout |
| **Progress Tracker** | Visual dashboard showing mastery across all disciplines | Yes -- updates after every battle | Compare with classmates (NPC and online friends) |
| **Glossary** | Mathematical terms with plain-language definitions and visual examples | Yes -- terms added when first encountered | Search, filter by discipline |

The Notebook **persists between playthroughs** as a genuine reference. A player who reaches Year 3 and starts a New Game Plus keeps their filled Notebook, making subsequent runs faster but still challenging (time pressure increases to compensate).

### Academy Social Layer

NPC classmates form the emotional core of the experience. Each has strengths, weaknesses, and storylines that reinforce learning through social mechanics.

#### Key NPCs

| NPC | Strength | Weakness | Story Arc | Study Group Bonus |
|-----|---------|----------|-----------|-------------------|
| **Luna Ashwood** | Geometry prodigy | Panics under time pressure | Overcoming performance anxiety to compete in the Spell Bee | +15% geometry accuracy when in party |
| **Marcus du Pont** | Algebra savant | Struggles with word problems | Learning to translate real situations into math after a family crisis | Auto-reveals one algebra step per battle |
| **Aria Nakamura** | Statistics intuitive | Imposter syndrome about being "not really smart" | Discovering she thinks in probabilities naturally; her instinct IS mathematical | Highlights the statistically best answer choice |
| **Rex Thorne** | Brute-force arithmetic speed | Hates showing work or understanding "why" | Learning that understanding beats speed after losing to a slower, deeper thinker | +20% battle speed (reduces time pressure) |
| **Professor Elara Voss** | All disciplines | Missing (central mystery) | The professor who vanished after discovering an "unsolvable" problem; her notes guide the player through the main story | N/A (story NPC) |

#### Social Mechanics

**Study Groups**: Form parties with NPCs for dungeon runs. Each NPC provides discipline-specific bonuses. NPCs level up alongside you -- their mastery reflects the concepts you've taught them.

**Teaching Mechanic**: NPCs periodically ask for help with concepts. Teaching requires you to select the correct explanation from options. Correctly teaching a concept:
- Cements your own mastery (bonus Concept XP)
- Improves the NPC's combat performance in future battles
- Advances their personal storyline
- Unlocks unique companion abilities

**Weekly Spell Bee**: A tournament mode where you compete against NPCs and other players' ghosts. Problems are drawn from the week's most-missed concepts across the player base. Rankings award cosmetic titles and classroom decorations.

**Co-op Puzzle Raids**: 2-4 player asynchronous co-op. Each player faces problems from different disciplines simultaneously. Shared HP pool -- if one player struggles, the team takes damage. Requires coordination of complementary strengths.

### Thesis Defense Dungeons (Endgame)

Optional, brutally difficult puzzle sequences for Challenge Seekers. No grading on a curve. Pure mastery gates.

| Dungeon | Disciplines Tested | Problem Count | Time per Problem | Reward |
|---------|-------------------|--------------|-----------------|--------|
| **Algebraic Abyss** | All algebra (linear through polynomial) | 20 | 6 seconds | Title: "Equation Breaker", cosmetic: fractal spell trail |
| **Geometric Labyrinth** | All geometry + trigonometry | 25 | 8 seconds | Title: "Shape Weaver", cosmetic: tessellation battle aura |
| **Statistical Storm** | Probability + statistics + combinatorics | 20 | 7 seconds | Title: "Odds Master", cosmetic: dice particle effects |
| **Calculus Crucible** | Derivatives, integrals, limits, series | 30 | 5 seconds | Title: "Flux Walker", cosmetic: flowing equation cape |
| **The Unsolver** | All disciplines + non-Euclidean | 50 | 4 seconds | Title: "Theorem Sovereign", cosmetic: reality-warping summon animation |

Failing a Thesis Defense shows a detailed breakdown of which sub-topics need improvement. The game generates a personalized practice plan targeting exact weaknesses. Retry after completing the practice plan (minimum 24-hour cooldown to prevent brute-forcing).

---

## World Design

### The Ethereal Academy

A floating island campus suspended above an infinite mathematical void called the Raw -- pure undifferentiated potential that takes form when described by equations. The academy was built to train summoners who give shape to the Raw through mathematical precision.

#### Campus Zones

| Zone | Year Unlocked | Visual Theme | Function | Encounters |
|------|-------------|-------------|----------|-----------|
| **Foundation Island** | Year 1 | Warm sandstone, glowing chalk lines on every surface, levitating abacuses | Tutorial zone, arithmetic/algebra classes, dormitory | Emberlings, basic Equation Serpents |
| **Spiralspire Tower** | Year 2 | Fibonacci spiral architecture, golden ratio proportions in every archway | Geometry/statistics classes, first summoning arena | Crystal Constructs, Probability Elementals |
| **Stormveil Observatory** | Year 3 | Floating in a perpetual aurora, star maps and sine wave railings | Advanced classes, NPC relationship events, co-op raid entrance | Wave Weavers, advanced Probability Elementals |
| **Abyssal Archive** | Year 4 | Infinite recursive library, bookshelves that extend into fractal depths | Calculus classes, forbidden stacks entrance, final exam arena | Flux Behemoths, Forbidden Constructs |
| **The Veil** | All years | Chaotic shimmering void between islands, raw equations visible in the air | Wild encounters, rare monster spawns, exploration challenges | All families, scaled to current year |
| **Forbidden Stacks** | Post-game | Non-Euclidean architecture, staircases that loop, rooms that are larger inside than outside | Thesis Defense dungeons, secret storyline, The Unsolver | Forbidden Constructs only, extreme difficulty |
| **Summoning Arena** | Year 2+ | Colosseum of crystallized equations, crowd of NPC spectators | PvP ghost battles, Spell Bee tournaments, ranked modes | Player-chosen difficulty |

#### World Aesthetics

**Visual Language**: The world is built from mathematical visual motifs. Buildings follow geometric principles (the Spiralspire is a literal golden spiral). The Raw manifests as floating equations that dissolve into particles. Monster designs incorporate their discipline -- Crystal Constructs are literally polyhedra, Probability Elementals flicker between states.

**Color Palette**:

| Discipline | Primary Color | Accent | Aura Effect |
|-----------|-------------|--------|-------------|
| Arithmetic | Warm orange (#E8944A) | Bright yellow (#FFD166) | Ember particle trail |
| Algebra | Deep blue (#1A5276) | Cyan (#5DADE2) | Flowing equation ribbons |
| Geometry | Emerald green (#1E8449) | Gold (#F4D03F) | Rotating shape outlines |
| Statistics | Purple (#7D3C98) | Silver (#D5D8DC) | Dice and card particle effects |
| Trigonometry | Teal (#148F77) | Wave white (#E8F8F5) | Sine wave ripples |
| Calculus | Crimson (#C0392B) | Flux orange (#E67E22) | Flowing derivative curves |
| Non-Euclidean | Void black (#17202A) | Impossible pink (#E91E9C) | Reality-glitch distortion |

**Audio Design**: The soundtrack integrates mathematical patterns. Time signatures follow Fibonacci sequences. Chord progressions use mathematical intervals. Correct problem solutions trigger harmonic resonance -- the world literally sounds better as you solve problems correctly. The Summoning Arena has crowd reactions keyed to streak performance.

---

## Narrative

### Story Structure

```
Prologue: Enrollment -> Year 1-4 Academy Life (with escalating mysteries) -> Missing Professor Thread -> Forbidden Geometry Faction -> Ancient Construct Discovery -> Final Exam Crisis -> The Unsolver Revelation -> Epilogue: What Math Becomes
```

### Act Breakdown

**Prologue: Enrollment**
You arrive at the Ethereal Academy as a first-year summoner. The enrollment test -- a simple arithmetic evaluation -- determines your starting difficulty calibration. You meet your first classmates (Luna, Marcus, Aria, Rex) and Professor Voss, who runs the introductory seminar.

**Act 1: Foundation (Year 1-2)**
Standard academy life. Classes, battles, social events. Beneath the surface: Professor Voss acts increasingly distracted, spending late nights in restricted sections of the library. You discover she is researching something called "The Zero Theorem" -- a mathematical construct that, if proven, would collapse the distinction between the Raw and structured reality. Luna confides that she saw Voss arguing with a hooded figure near the Veil edge.

**Act 2: Spiral (Year 2-3)**
Professor Voss vanishes. The official explanation is "sabbatical research," but her office is cleared out overnight. Her teaching assistant, the enigmatic graduate student Kai Morrow, takes over her classes -- and pushes students harder than Voss ever did. You find fragments of Voss's research notes hidden in monster encounters (they appear as bonus pages in your Notebook). The notes suggest she found the Zero Theorem -- and it found her back.

A faction called the Topologists reveals itself: rogue summoners who believe the Raw should not be constrained by conventional mathematics. They use forbidden non-Euclidean summoning to create impossible monsters that defy standard problem-solving approaches.

**Act 3: Storm (Year 3-4)**
The Topologists grow bolder, attacking academy events. Kai is revealed to be a former Topologist who defected after witnessing the cost of their methods -- summoners who channel non-Euclidean math lose the ability to think linearly, becoming trapped in paradoxical reasoning.

You discover that the academy itself is built on top of an ancient construct -- The Primordial Proof -- a self-evident theorem given physical form millennia ago. The Topologists want to overwrite it. Voss discovered it could be used to unite the Raw and reality rather than destroy the boundary.

**Act 4: Abyss (Year 4 + Post-game)**
The final exam is interrupted by a Topologist assault on the Primordial Proof. The exam boss becomes real -- a massive Flux Behemoth empowered by the destabilizing construct. You must defeat it using everything you've learned across all four years.

Post-game: Find Professor Voss in the Forbidden Stacks, where she has been voluntarily trapped within a non-Euclidean space, maintaining the stability of the Zero Theorem from inside. The Thesis Defense dungeons are her challenges to prove you are ready to understand what she discovered: that the Raw and reality were never separate -- every mathematical truth is both a description and a creation.

**Epilogue**: The academy continues. You graduate. Your Summoner's Notebook is complete -- a genuine reference document. The NPC classmates go their separate ways but remain accessible for co-op play. The post-game opens Prestige Years with harder variants of all content.

### Narrative Delivery Methods

| Method | Frequency | Purpose |
|--------|----------|---------|
| **In-combat dialogue** | Every battle | Monster flavor text hints at world lore; NPC party members comment on problems |
| **Cutscene vignettes** | Major story beats (8-10 per act) | Character development, plot advancement |
| **Notebook entries** | Continuous | Professor Voss's hidden notes, discovered progressively |
| **NPC conversations** | Between classes, at dorms | Relationship building, side quests, character arcs |
| **Environmental storytelling** | Always | Architecture encodes mathematical history; the campus itself is a textbook |
| **Classroom lectures** | Weekly in-game | Delivered by Kai (and later guest lecturers), these are interactive mini-lessons that advance understanding and story simultaneously |

### Tone and Themes

| Theme | Expression |
|-------|-----------|
| **Math is magic** | Every spell is a proof. Every summon is an equation given life. The world reinforces this constantly. |
| **Learning is social** | The best learning happens through teaching, collaboration, and friendly competition. The social mechanics mirror real study group dynamics. |
| **Struggle is growth** | Getting problems wrong is never punished -- it's diagnosed. The game treats confusion as the first step to understanding. |
| **Wonder over drill** | The goal is not rote fluency but genuine appreciation. The story makes mathematical discovery feel like uncovering cosmic secrets. |
| **Accessibility of genius** | Every NPC character arc reinforces that mathematical ability is developed, not innate. Rex learns depth. Luna learns calm. Aria learns confidence. |

---

## Player Personas

### P-002: Sarah Chen -- "The Micro-Gamer"

| Attribute | Relevance |
|-----------|----------|
| **Archetype** | Casual puzzle mom |
| **Session pattern** | 15-20 minute bursts, 4-5x daily |
| **Spend tier** | $10-15/month micro-transactions |
| **Why Charm and Calculus fits** | Puzzle combat sessions are exactly 3-5 minutes. The game pauses gracefully between problems. Gacha-style companion collection without predatory rates. She can play during nap time and feel genuine progress. |
| **Retention hooks** | Daily login streak for companion treats. Short daily challenge (5 problems). Seasonal battle pass with cosmetic familiars. Companion affection system that rewards consistent play. |
| **Risk** | Energy systems would alienate her immediately. Must offer generous energy or none at all. |

### P-003: Hiroshi Tanaka -- "The RPG Addict"

| Attribute | Relevance |
|-----------|----------|
| **Archetype** | Teen RPG achiever / completionist |
| **Session pattern** | 3-4 hours daily, concentrated during breaks |
| **Spend tier** | $5-15/month, occasional $50-100 splurge |
| **Why Charm and Calculus fits** | Deep RPG progression systems (years, disciplines, companions, NPCs). Achievement system tied to genuine mastery. Theorycrafting optimal companion loadouts by discipline. The Thesis Defense dungeons are exactly the challenge he craves. |
| **Retention hooks** | 60-level year system with Prestige. Achievement system with rare titles. Companion optimization through synergy. PvP ghost leaderboards. |
| **Risk** | If content is perceived as "educational" rather than "a real game," he will bounce. The game must never break the fiction to lecture. |

### P-006: Eleanor Vance -- "The Loyal Strategist"

| Attribute | Relevance |
|-----------|----------|
| **Archetype** | Retired strategist |
| **Session pattern** | 2-3 hours/day, consistent morning and evening |
| **Spend tier** | $10/month, one-time purchases only |
| **Why Charm and Calculus fits** | Strategy and planning in companion loadouts and study group composition. Deep systems that reward patience. No twitch mechanics -- time pressure is configurable. Intellectual depth without condescension. |
| **Retention hooks** | Mastery Profile that tracks long-term improvement. Notebook as a genuine reference she values. Co-op raids where her experience helps newer players. |
| **Risk** | Any pay-to-win mechanic or energy gate will trigger immediate deletion. Must offer a one-time "premium unlock" purchase option. |

### P-008: David Park -- "The Achievement Hunter"

| Attribute | Relevance |
|-----------|----------|
| **Archetype** | Completionist |
| **Session pattern** | 1-2 hours/day across 5 games |
| **Spend tier** | $20-40/month on time-savers and DLC |
| **Why Charm and Calculus fits** | Dense achievement system tied to mathematical mastery. Clear 100% completion path (all notebooks, all companions, all Thesis Defenses). Trackable progress that satisfies spreadsheet tendencies. |
| **Retention hooks** | Per-discipline mastery achievements. Companion collection completion. NPC relationship milestones. Thesis Defense clear times. Seasonal challenge achievements. |
| **Risk** | Bugged achievements will generate immediate negative reviews. All achievements must be attainable through skill, not RNG. |

### P-011: Maria Rodriguez -- "The Commuter Gamer"

| Attribute | Relevance |
|-----------|----------|
| **Archetype** | Commuter |
| **Session pattern** | 30-45 minutes daily during commute |
| **Spend tier** | Under $20 annually |
| **Why Charm and Calculus fits** | Full offline mode for all solo content. Combat sessions fit commute length. Puzzle format works well on mobile. No required online checks for core gameplay. |
| **Retention hooks** | Reliable offline-first design. Daily challenges cached locally. Notebook accessible without connection. |
| **Risk** | If offline mode is limited or if online checks interrupt commute play, she will delete within one session. |

### P-015: Jennifer Martinez -- "The Conscious Parent"

| Attribute | Relevance |
|-----------|----------|
| **Archetype** | Parent buyer / gatekeeper |
| **Session pattern** | Researches for children (ages 8, 11) |
| **Spend tier** | $15-60/month on educational content |
| **Why Charm and Calculus fits** | Genuine educational value wrapped in engaging gameplay. E10+ rating. No gambling mechanics. No violent content. No predatory monetization. Parent dashboard showing child's mathematical progress. |
| **Retention hooks** | Progress reports showing which concepts the child has mastered. Parental controls for session time. Educational alignment with school curriculum. |
| **Risk** | If the game disguises gambling as gacha (even cosmetic), Jennifer will research, discover it, and post a negative review in parent groups. Companion summoning must use a deterministic pity system with visible rates. |

---

## User Stories

### Combat and Puzzle Solving

**US-001**: As a player, I want to solve arithmetic problems during combat so that my spells deal damage to monsters, and I want to see a damage number that scales with my accuracy and speed.

**US-002**: As a player, I want the game to diagnose which math topics I struggle with so that it gives me targeted practice problems disguised as monster encounters, rather than repeating content I have already mastered.

**US-003**: As a player, I want a visual indicator of how much time remains on each problem so that I can decide whether to attempt a quick answer or think carefully.

**US-004**: As a player, I want my companion creatures to provide discipline-specific bonuses in combat so that I can strategize which companions to bring against specific monster families.

**US-005**: As a player, I want to see a clear accuracy-damage mapping on the results screen after each battle so that I understand exactly how my problem-solving performance translates to combat outcomes.

**US-006**: As a player, I want the game to offer an easier variant when I get a problem wrong, rather than simply failing me, so that I learn the concept before facing the full-difficulty version again.

### Progression and Mastery

**US-007**: As a player, I want my Concept Mastery to fill across distinct mathematical disciplines so that I can track my growth in algebra separately from geometry or statistics.

**US-008**: As a player, I want to advance through a four-year academy system where each year introduces new mathematical disciplines and zones so that the game continuously expands in complexity.

**US-009**: As a player, I want a visible Mastery Profile dashboard showing my accuracy and speed for every sub-topic so that I can identify and improve my weak areas.

**US-010**: As a player, I want to unlock new companion creatures by demonstrating proficiency in specific disciplines so that my collection reflects the math I have actually learned.

**US-011**: As a player, I want the difficulty to scale automatically based on my demonstrated ability so that I am always challenged but never overwhelmed or bored.

### The Summoner's Notebook

**US-012**: As a player, I want an in-game Notebook that automatically records every mathematical concept I encounter, with illustrated examples, so that I can review material I have already seen.

**US-013**: As a player, I want the Notebook to double as a bestiary where each monster entry explains the real-world math principle it embodies so that learning happens naturally through engagement with the game world.

**US-014**: As a player, I want the Notebook to generate practice problems targeted at my diagnosed weak areas so that I can improve without needing to replay story content.

**US-015**: As a player, I want my Notebook to persist between playthroughs as a genuine reference document so that the knowledge I build has lasting value beyond a single save file.

### Social and NPC Interactions

**US-016**: As a player, I want to form study groups with NPC classmates who provide discipline-specific combat bonuses so that party composition feels strategic and educational simultaneously.

**US-017**: As a player, I want to teach concepts to NPC classmates by selecting the correct explanation from multiple choices so that teaching reinforces my own mastery and advances the NPC's storyline.

**US-018**: As a player, I want to compete in weekly Spell Bee tournaments against NPC and player ghosts so that I have a recurring competitive event that tests my broad mathematical fluency.

**US-019**: As a player, I want to participate in co-op puzzle raids with 2-4 other players where each of us faces problems from different disciplines simultaneously so that teamwork requires complementary strengths.

**US-020**: As a player, I want NPC classmates to have personal storylines that unfold through interaction so that the academy feels populated by real people rather than quest dispensers.

### World Exploration

**US-021**: As a player, I want to explore distinct campus zones that unlock progressively across the four-year system so that each year feels visually and mechanically different.

**US-022**: As a player, I want the world architecture to encode mathematical principles (golden spiral towers, tessellated floors, fractal bookshelves) so that exploration itself reinforces mathematical thinking.

**US-023**: As a player, I want to encounter wild monsters in the Veil between islands so that I have a space for unstructured practice outside of story-mandated encounters.

**US-024**: As a player, I want the Summoning Arena to host PvP ghost battles and ranked modes so that I can test my mastery against other players' performance records.

### Narrative

**US-025**: As a player, I want to uncover the mystery of Professor Voss's disappearance through fragments hidden in monster encounters and the Notebook so that the narrative rewards sustained engagement.

**US-026**: As a player, I want to encounter the Topologist faction as antagonists who use forbidden non-Euclidean summoning so that the story introduces advanced mathematical concepts as dramatic plot elements.

**US-027**: As a player, I want the final exam boss to require mastery of all disciplines I have learned across four years so that the climax feels like a genuine culmination of my growth.

### Accessibility and Session Design

**US-028**: As a commuter player, I want full offline access to all solo content including combat, Notebook review, and story progression so that I can play reliably during my train commute without internet.

**US-029**: As a parent, I want a dashboard showing my child's progress across mathematical disciplines so that I can verify the game's educational value and track improvement over time.

**US-030**: As a player with visual impairments, I want problems presented in both visual and text-based formats with adjustable font sizes and screen reader compatibility so that I can solve problems comfortably.

**US-031**: As a time-constrained player, I want combat sessions that resolve in 3-5 minutes with clean save states between encounters so that I can make meaningful progress in short sessions.

### Monetization and Fairness

**US-032**: As a free-to-play player, I want access to all story content and mathematical disciplines without spending money so that I can complete the entire game through skill and effort alone.

**US-033**: As a parent, I want clear disclosure of companion summon rates and a deterministic pity system so that I can verify there are no gambling mechanics disguised as gameplay.

**US-034**: As a player, I want the seasonal battle pass to contain only cosmetic items (familiar skins, spell effects, titles) so that spending money never confers a gameplay advantage.

### Endgame

**US-035**: As a completionist player, I want Thesis Defense dungeons that test extreme mastery across all disciplines so that I have clear, difficult, measurable goals after completing the main story.

---

## Monetization

### Revenue Model: Fair F2P with Cosmetic Monetization

| Revenue Stream | Price | What Players Get | P2W? |
|---------------|-------|-----------------|------|
| **Seasonal Battle Pass** | $9.99/season (4 seasons/year) | 50 tiers of cosmetic rewards: familiar skins, spell trail effects, classroom decorations, titles, summon animations | No |
| **Cosmetic Familiars** | $2.99-$7.99 each | Visual-only companion skins that do not affect stats or abilities | No |
| **Cosmetic Spell Packs** | $4.99/pack | Alternative visual effects for spell animations (no mechanical change) | No |
| **Parent Progress Pack** | $4.99/month | Access to parent dashboard, detailed progress reports, curriculum alignment data, session time controls | No (utility) |
| **One-Time Premium Unlock** | $14.99 | Permanent 2x XP boost, ad removal (if any), exclusive cosmetic title "Early Scholar" | No (QoL) |
| **Expansion Years** | $9.99 each | Post-launch Year 5+ content with new disciplines (linear algebra, number theory, topology) | No (content) |

### Companion Acquisition (No Gacha Gambling)

Companions are earned through demonstrated mastery, not random pulls:

| Acquisition Method | Companions Available | Deterministic? |
|-------------------|---------------------|----------------|
| **Discipline Mastery** | 6 base companions (one per discipline) | Yes -- unlock at specific mastery thresholds |
| **Achievement Completion** | 6 variant companions (alternate designs of base 6) | Yes -- tied to specific achievements |
| **Thesis Defense Clear** | 5 prestige companions (one per dungeon) | Yes -- guaranteed on first clear |
| **Seasonal Battle Pass** | 1 seasonal cosmetic skin per season | Yes -- reach tier 40 |
| **NPC Relationship Max** | 4 unique companions (tied to NPC storylines) | Yes -- complete NPC arcs |
| **Post-game Secret** | 1 hidden companion (The Unsolver reward) | Yes -- clear all Thesis Defenses |

Total companions: 22 base + cosmetic skins. Every companion is earnable through gameplay. Cosmetic skins are the only monetized element.

### ARPU Projections

| Segment | Monthly ARPU | % of Player Base | Revenue Contribution |
|---------|-------------|-----------------|---------------------|
| **Free-only players** (P-009, P-011) | $0.00 | 60% | 0% |
| **Micro-spenders** (P-002, P-005) | $5-15 | 20% | 30% |
| **Mid-tier spenders** (P-003, P-008) | $15-40 | 12% | 35% |
| **Whales / Parents** (P-004, P-007, P-015) | $40-100 | 5% | 25% |
| **One-time purchasers** (P-006, P-013) | $15 (lifetime) | 3% | 10% |

### Break-Even Analysis

| Metric | Value |
|--------|-------|
| Development cost (18-month cycle) | $1.2M |
| Monthly operating cost (servers, support) | $15,000 |
| Target MAU at launch | 500,000 |
| Blended ARPU target | $2.50/month |
| Monthly revenue at target MAU | $1,250,000 |
| Break-even point | Month 2 post-launch |
| Payback period | 3 months |

---

## Production Plan

### Team Composition

| Role | Count | Responsibility |
|------|-------|---------------|
| Game Designer / Lead | 1 | Systems design, balance, math curriculum integration |
| Math Education Consultant | 1 (contract) | Curriculum alignment, problem generation rules, pedagogy review |
| Programmers | 3 | Combat system, difficulty engine, UI, mobile optimization |
| Technical Artist | 1 | Shader work (bioluminescence, equation visual effects), VFX |
| 2D Artist | 2 | Character art (NPCs, companions), UI art, notebook illustrations |
| 3D Artist | 1 | Monster models, environment assets |
| Narrative Designer | 1 | Story, dialogue, NPC arcs, environmental storytelling |
| Sound Designer / Composer | 1 | Mathematically-patterned music, SFX, adaptive audio |
| QA / Playtest Lead | 1 | Testing, difficulty calibration, educational efficacy testing |
| Community Manager | 1 (post-launch) | Player feedback, parent outreach, content updates |
| **Total** | **14** | |

### Development Phases

| Phase | Duration | Milestone | Deliverables |
|-------|----------|-----------|-------------|
| **Pre-Production** | Months 1-2 | Concept Lock | GDD final, art bible, technical design doc, math curriculum map (Grades 5-12 alignment), prototype of combat math system |
| **Prototype** | Months 3-4 | Vertical Slice | Playable Year 1 combat loop (3 monster families, 1 companion), basic difficulty engine, Notebook prototype, 1 NPC with teaching mechanic |
| **Production Alpha** | Months 5-10 | Feature Complete | Full Year 1-2 content (4 disciplines, 25 monster types, 4 NPCs), complete Notebook system, social layer (study groups, Spell Bee), campus zones (Foundation Island, Spiralspire) |
| **Production Beta** | Months 11-14 | Content Complete | Year 3-4 content (3 more disciplines, remaining monsters and NPCs), full narrative (all 4 acts), Thesis Defense dungeons, co-op raids, mobile optimization |
| **Polish and QA** | Months 15-16 | Release Candidate | Difficulty calibration pass (using playtest data), accessibility audit, localization (EN, JA, ES, FR, DE, KO, ZH), performance optimization, age rating certification |
| **Launch** | Month 17 | Gold Master | Submit to Steam, App Store, Google Play, Nintendo eShop |
| **Post-Launch Live Ops** | Months 18+ | Seasonal Updates | New battle pass every 3 months, Expansion Year content every 6 months, seasonal events, community-requested features |

### Content Pipeline

| Content Type | Count | Production Rate | Pipeline |
|-------------|-------|----------------|----------|
| **Mathematical problems** | 5,000+ (dynamic generation) | Generated by algorithm, curated by education consultant | Authoring tool -> difficulty engine -> playtest -> ship |
| **Monster designs** | 30+ unique types | 1 per week during production | Concept art -> 3D model -> rig -> animate -> integrate |
| **NPC story arcs** | 5 major, 10 minor | 1 major arc per production phase | Narrative doc -> dialogue script -> voice direction (text only for launch) -> integration |
| **Campus zones** | 7 zones | 1 zone per 6 weeks | Concept -> blockout -> art pass -> encounter placement -> lighting -> polish |
| **Companion creatures** | 22 base + skins | 2 per month | Concept -> 2D art -> animation -> stat/balance -> integration |
| **Spell effects** | 40+ unique | 3-4 per month | Technical art -> shader -> particle system -> performance test |

### Playtest Schedule

| Phase | Playtest Type | Participants | Focus |
|-------|-------------|-------------|-------|
| Prototype | Internal + 10 external teens | 10-15 | Is combat fun? Is math integration invisible or intrusive? |
| Alpha | 100 external (50 teens, 30 adults, 20 parents) | 100 | Difficulty calibration, session length comfort, educational efficacy (pre/post math test) |
| Beta | 1,000 external across all target platforms | 1,000 | Platform-specific issues, progression pacing, social feature testing |
| Polish | 200 external focus groups | 200 | Accessibility, parent dashboard, localization quality |

### Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| "Educational game" stigma reduces player acquisition | High | High | Marketing emphasizes RPG depth first, learning second. Trailers show combat, story, companions -- never classroom vibes. |
| Math difficulty calibration is wrong for target age range | Medium | High | Education consultant reviews all generated problems. Playtest with actual students. Pre/post math tests to verify learning. |
| Content generation cannot keep up with player consumption | Medium | Medium | Procedural problem generation engine. Difficulty scaling handles most replay. Expansion Years as planned content drops. |
| Mobile performance issues on budget devices (P-006, P-011) | Medium | Medium | URP for lightweight rendering. Budget device testing from Alpha. Scalable quality settings. |
| Parents discover and criticize any gacha-adjacent mechanic | Low | High | Deterministic companion acquisition only. Fully transparent pity/skin system. Parent advisory board during Beta. |

---

## Technical Requirements

### Platform Specifications

| Platform | Minimum Spec | Recommended Spec | Target FPS |
|----------|-------------|-----------------|-----------|
| **PC (Windows)** | Windows 10 64-bit, Intel i3-8100, 4 GB RAM, Intel UHD 630, 3 GB storage | Windows 11 64-bit, Intel i5-12400, 8 GB RAM, NVIDIA GTX 1650, 5 GB SSD | 60 FPS |
| **iOS** | iOS 15, iPhone 8 / A11 Bionic, 2 GB RAM | iOS 17, iPhone 13 / A15 Bionic, 4 GB RAM | 60 FPS (30 FPS on min spec) |
| **Android** | Android 12, Snapdragon 730, 4 GB RAM, Mali-G76 | Android 14, Snapdragon 8 Gen 2, 8 GB RAM, Adreno 740 | 60 FPS (30 FPS on min spec) |
| **Nintendo Switch 2** | Standard hardware | Standard hardware | Docked: 60 FPS, Handheld: 30 FPS |

### Engine and Architecture

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| **Game Engine** | Unity 6 (URP) | Cross-platform reach, strong mobile optimization, Nintendo Switch 2 support, shader graph for math-visual effects |
| **Rendering** | Universal Render Pipeline (URP) | Lightweight for mobile budget devices, sufficient for the art style (stylized, not photorealistic) |
| **Problem Generation** | Custom procedural engine (C#) | Algorithmic generation of math problems from templates, difficulty-parameterized, with deterministic validation |
| **Backend Services** | PlayFab (Azure) | Free tier covers launch scale, leaderboards, player data, cloud saves, analytics built-in |
| **Multiplayer (ghost battles, co-op)** | PlayFab + custom relay | Asynchronous ghost data for PvP, small relay servers for 4-player co-op raids |
| **Offline Mode** | Local SQLite + asset bundles | Full solo content cached locally. Cloud sync when online. Conflict resolution via timestamp. |
| **Localization** | Unity Localization package | String tables, right-to-left support, dynamic font sizing for CJK characters |
| **Analytics** | PlayFab + custom educational analytics | Track problem accuracy, time-to-solve, mastery progression, session length, drop-off points |

### Problem Generation Engine Architecture

```
ProblemTemplate (discipline, difficulty, topic)
    |
    v
ParameterGenerator (randomizes numbers, constraints)
    |
    v
ProblemInstance (specific numbers, correct answer, distractors)
    |
    v
Validator (ensures exactly one correct answer, reasonable values)
    |
    v
DifficultyAdjuster (modifies time limit, hint availability, distractor quality based on player Mastery Profile)
    |
    v
Presentation Layer (formats for display -- visual, text, or interactive widget)
```

### Data Budget

| Asset Type | Estimated Size | Compression |
|-----------|---------------|-------------|
| Textures (stylized, atlas-based) | 600 MB | ASTC (mobile), BC7 (desktop) |
| 3D Models (low-poly stylized) | 200 MB | Mesh compression, LODs |
| Audio (music + SFX) | 300 MB | OGG Vorbis (streamed) |
| UI and 2D Art | 150 MB | PNG atlas, SVG for resolution-independent elements |
| Problem Generation Templates | 50 MB | JSON definitions |
| Localization Strings | 30 MB | 7 languages, string tables |
| **Total Base Install** | **1.3 GB** | |
| **Post-Launch Content** | **+500 MB** | Downloadable asset bundles |

### Accessibility Requirements

| Feature | Implementation | Priority |
|---------|---------------|----------|
| **Font scaling** | Dynamic font sizing from 12pt to 32pt | Must |
| **High contrast mode** | Alternate UI color scheme, problem text always meets WCAG AA | Must |
| **Screen reader support** | All UI elements and problem text exposed to VoiceOver / TalkBack | Must |
| **Problem format options** | Each problem available in visual, text, and audio-read formats | Must |
| **Time pressure toggle** | "Relaxed mode" removes all timers, problems untimed, combat remains turn-based | Must |
| **Colorblind support** | Discipline colors use distinct shapes and patterns in addition to hue | Must |
| **Configurable controls** | Remappable inputs, touch and controller support on all platforms | Should |
| **Text-to-speech for problems** | Audio readback of problem text on tap | Should |

### Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Boot to gameplay** | Under 15 seconds | Cold start on minimum spec device |
| **Battle load** | Under 2 seconds | Transition from exploration to combat |
| **Problem render** | Under 200ms | From battle start to problem fully displayed |
| **Memory usage (mobile)** | Under 500 MB RAM | On minimum spec Android device during combat |
| **Battery drain (mobile)** | Under 12% per hour | Measured on iPhone 13, 50% brightness |
| **Offline functionality** | 100% of solo content | No internet check for story, combat, notebook |
| **Cloud save sync** | Under 5 seconds | When transitioning from offline to online |
| **Dynamic difficulty recalculation** | Under 100ms | After each battle, Mastery Profile update |

### Security and Integrity

| Concern | Solution |
|---------|----------|
| **Leaderboard manipulation** | Server-side score validation. Problem answers verified server-side when online. Ghost data signed with device keys. |
| **Save data tampering** | Cloud saves as authoritative source. Local saves encrypted. Offline progress validated on reconnect. |
| **Problem answer leaking** | Problem instances generated server-side with session tokens. Correct answers never stored client-side before submission. |
| **Companion unlock spoofing** | Companion unlocks tied to server-verified mastery thresholds. Client displays state; server owns state. |

---

## Appendix: Curriculum Alignment

The mathematical content in Charm and Calculus aligns with standard curricula for educational accountability and parent confidence.

| Discipline | Grade Level Equivalent | Standard Alignment |
|-----------|----------------------|-------------------|
| Arithmetic (Year 1) | Grades 4-6 | Common Core 4.OA - 6.NS |
| Basic Algebra (Year 1) | Grades 6-8 | Common Core 6.EE - 8.EE |
| Intermediate Algebra (Year 2) | Grades 8-10 | Common Core 8.EE - HSA.REI |
| Geometry (Year 2) | Grades 7-10 | Common Core 7.G - HSG.CO |
| Statistics and Probability (Year 2-3) | Grades 6-11 | Common Core 6.SP - HSS.IC |
| Trigonometry (Year 3) | Grades 10-12 | Common Core HSF.TF |
| Calculus (Year 4) | Grades 11-12, AP | AP Calculus AB/BC alignment |
| Non-Euclidean (Post-game) | University level | Exposure only, not assessed |
