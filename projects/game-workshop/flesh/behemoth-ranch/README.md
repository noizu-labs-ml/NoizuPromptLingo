# Behemoth Ranch

## 1. Title & Genre

| Field | Value |
|-------|-------|
| **Title** | Behemoth Ranch |
| **Genre** | Cozy Simulation / Monster Ranching |
| **Sub-genres** | Creature collection, facility management, narrative rehabilitation |
| **Engine** | Unity 2023 LTS (C#) -- chosen for cross-platform reach, 2D/3D hybrid support, and mature mobile pipeline |
| **Platforms** | PC (Steam), Nintendo Switch, iOS, Android |
| **Monetization** | Premium ($24.99 base) + creature DLC packs ($7.99 each) |
| **ESRB** | E (Everyone) |
| **PEGI** | 3 |
| **Target session** | 20-45 minutes |
| **Save system** | Cloud save cross-platform (Steam Cloud / iCloud / Google Play Games) |
| **Languages at launch** | English, Japanese, Simplified Chinese, Spanish, French, German |
| **Offline play** | Full offline supported -- no always-online requirement |

---

## 2. Vision Statement

Behemoth Ranch is a creature-rehabilitation sanctuary sim where the "monsters" of a high-fantasy world arrive traumatized by adventurers and find healing under the player's care. The game exists because the creature-collection genre overwhelmingly frames fantastical beasts as resources to exploit -- captured, battled, and traded. Behemoth Ranch inverts that premise: every creature carries a wound, a fear, a history, and the player's job is to listen, nurture, and eventually set them free or give them a permanent home. It feels like a warm morning routine -- feeding, grooming, observing -- punctuated by moments of genuine emotional breakthrough when a creature that flinched at fire for six in-game weeks finally approaches a campfire on its own. The game targets the same psychological space as Stardew Valley's daily loop and Spiritfarer's emotional beats, but with creature rehabilitation as its mechanical spine.

---

## 3. Core Loop

```
                        +----------------------------------+
                        |                                  |
                        v                                  |
+---------+     +---------------+     +--------------+    |
| Morning |---->|  Check Status |---->|  Prioritize  |    |
|  Wake   |     |   Board &     |     |  Daily Care  |    |
|         |     |   Mailbox     |     |    Tasks     |    |
+---------+     +---------------+     +------+-------+    |
                                              |            |
                                              v            |
                                      +---------------+    |
                                      |  CARE ROUTINE |    |
                                      |  (Primary)    |    |
                                      |               |    |
                                      | 1. Feed       |    |
                                      | 2. Groom      |    |
                                      | 3. Enrichment |    |
                                      | 4. Observe    |    |
                                      +------+--------+    |
                                              |            |
                                              v            |
                                      +---------------+    |
                                      |  Trauma Event |    |
                                      |  (Triggered)  |----+
                                      |               |  Trust gained
                                      | - Flashback   |  Progress saved
                                      | - Breakthrough|
                                      | - Bonding     |
                                      +------+--------+
                                              |
                                              v
                                      +---------------+
                                      |  FACILITY     |
                                      |  MANAGEMENT   |
                                      |               |
                                      | - Build       |
                                      | - Upgrade     |
                                      | - Research    |
                                      +------+--------+
                                              |
                                              v
                                      +---------------+
                                      |  VISITOR      |
                                      |  EDUCATION    |
                                      |               |
                                      | - Tours       |
                                      | - Exhibits    |
                                      | - Reputation  |
                                      +------+--------+
                                              |
                                              v
                                      +---------------+
                                      |  EVENING      |
                                      |  REFLECT      |
                                      |               |
                                      | - Journal     |
                                      | - Plan next   |
                                      | - Release?    |
                                      +---------------+
```

### Core Loop Breakdown

| Phase | Duration | Player Action | System Response |
|-------|----------|---------------|-----------------|
| Morning Wake | 1 min | Review status board, read mail, check creature moods | Game presents daily conditions (weather, visitor schedules, supply deliveries) |
| Prioritize | 2 min | Select which creatures need attention today | Status board highlights creatures with low trust, pending trauma triggers, or hunger |
| Feed | 3-5 min | Prepare species-appropriate meals from pantry or foraged ingredients | Creatures gain satiation (0-100). Correct diet unlocks trust gain. Wrong food causes refusal or trust loss. |
| Groom | 2-3 min | Brush, bathe, or clean creature enclosures | Creatures gain comfort. Some trauma markers (e.g., "touch aversion") require repeated grooming to overcome. |
| Enrichment | 5-10 min | Place enrichment items, trigger activities, observe responses | Creatures interact with enrichment objects. Successful engagement reduces stress and unlocks species-specific behaviors. |
| Observe | 3-5 min | Watch creature behavior, note changes, record in journal | Game reveals behavioral cues that hint at trauma sources and recovery progress. Observation skill unlocks deeper insights. |
| Trauma Event | Variable | Respond to triggered flashback, panic episode, or breakthrough moment | Scripted narrative moment with choice branches. Outcomes affect trust level and unlock story fragments. |
| Facility Mgmt | 5-10 min | Build new enclosures, upgrade existing ones, place decorations | Facility rating changes, affecting creature happiness and visitor satisfaction. New species unlock at facility tier thresholds. |
| Visitor Education | 3-5 min | Design exhibit layouts, lead tours, answer visitor questions | Visitor satisfaction drives reputation, which determines funding level and new creature intake rate. |
| Evening Reflect | 2-3 min | Review journal entries, plan next day, make release/retire decisions | Day summary shows trust changes, breakthroughs, and tips for tomorrow. Save prompt. |

**Target session length: 25-40 minutes per in-game day.** Players can pause at any phase and resume from that point.

---

## 4. Meta Loop

### Session-to-Session Progression Axes

| Progression Axis | What Grows | How It Grows | Growth Feel |
|------------------|-----------|--------------|-------------|
| **Creature Trust** | Each creature's trust meter (0-100) and trauma marker recovery (0-5 markers per creature) | Daily care routines, successful enrichment, correct responses to trauma events | Slow, earned, emotional -- each point feels meaningful because the creature visibly changes |
| **Facility Tier** | Sanctuary rating (Bronze -> Silver -> Gold -> Platinum -> Mythic) | Accumulate creature-success stories, visitor satisfaction scores, complete research milestones | Steady unlocks -- new enclosure types, species permits, and facility decorations at each tier |
| **Knowledge Base** | Bestiary entries (120 total), rehabilitation techniques (36 learned), species lore fragments | Observation, journaling, research station upgrades | Discovery-driven -- each new entry fills in the world's ecology and history |
| **Reputation** | Regional attitude toward "monsters" (5 regions, each 0-100 perception) | Visitor education, release programs, exhibit quality | World-shaping -- high reputation in a region changes NPC dialogue, unlocks new creature rescues from that region |
| **Character Relationships** | Bonds with 8 NPC staff members (0-5 heart levels each) | Conversations, helping with personal quests, collaborative research | Narrative -- each staff member has their own arc about why they work at a monster sanctuary |
| **Financial Stability** | Sanctuary treasury (weekly income vs. expenses) | Visitor revenue, grants (based on reputation), resource sales, DLC expedition rewards | Management tension -- early game is tight, mid-game stabilizes, late-game enables creative freedom |

### Progression Timeline

| Game Week | Milestone | What Unlocks |
|-----------|-----------|--------------|
| 1 | Tutorial: First creature (orphaned griffin cub) | Basic care routines, feeding, grooming |
| 2-3 | Facility Tier 2 (Silver) | Enrichment system, second enclosure slot |
| 4-6 | First rehabilitation complete | Release or retire choice, region 1 perception opens |
| 7-10 | Facility Tier 3 (Gold) | Research station, 3rd species type, visitor center |
| 11-15 | Staff quests begin | Character relationship system, specialized care techniques |
| 16-20 | Facility Tier 4 (Platinum) | Large species permits (dragons, leviathans), cohabitation enclosures |
| 21-30 | Facility Tier 5 (Mythic) | Ancient species, protected wilds expeditions, endgame content |
| 30+ | Post-game | Sandbox mode, new game+ with difficulty modifiers, community challenges |

---

## 5. Game Mechanics

### 5.1 Primary Mechanic: Creature Rehabilitation System

Every creature arrives with **3-5 trauma markers** drawn from a pool of 18. Each marker represents a specific behavioral issue the player must address through targeted care.

**Trauma Marker Catalog (18 types):**

| Marker | Description | Care Requirement | Recovery Stages | Example Creature |
|--------|-------------|------------------|-----------------|------------------|
| Touch Aversion | Flinches from physical contact | Daily grooming (2 min/session), gradual approach minigame | 4 stages: Flees -> Tolerates -> Accepts -> Seeks | Minotaur with trust issues |
| Fire Phobia | Panic response to open flame | Controlled exposure therapy via campfire proximity, fire-free enclosure zones | 5 stages: Panic -> Avoid -> Watch -> Approach -> Warm | Chimera burned by adventurers |
| Eye Contact Fear | Closes eyes around people | Slow approach minigame, speaking gently before eye contact | 3 stages: Eyes shut -> Peeks -> Open | Basilisk conditioned to hide gaze |
| Noise Sensitivity | Startles at loud sounds | Soundproof enclosure upgrade, gradual desensitization via wind chimes | 4 stages: Cower -> Alert but calm -> Curious | Young roc from thunderstorm nest |
| Food Hoarding | Guards food aggressively | Multiple feeding stations, hand-feeding trust minigame | 4 stages: Snatch -> Guard -> Share -> Relaxed | Feral displacer beast |
| Claustrophobia | Distress in enclosed spaces | Open-air enclosures, gradual shelter introduction | 3 stages: Refuse shelter -> Use open shelter -> Den building | Bulette trapped in cave-in |
| Separation Anxiety | Distress when staff leaves | Companion animal pairing, gradual alone-time exposure | 5 stages: Panic -> Vocalize -> Wait -> Settle -> Independent | Orphaned griffin cub |
| Aggression | Attacks when approached | Non-threatening approach patterns, trust-building before contact | 4 stages: Attack -> Threaten -> Tolerate | Aging manticore |
| Self-Harm | Damages own body from stress | Enrichment distraction, healing salves, calm environment | 4 stages: Active -> Intermittent -> Stopped -> Healed | Phoenix pulling own feathers |
| Wanderlust | Paces boundaries, tries to escape | Large enclosure, varied terrain, eventual release candidate | 3 stages: Escape attempts -> Boundary walking -> Settled or released | Wild pegasus |
| Trust Freezing | Stops progressing despite correct care | Requires breakthrough trigger -- specific story event, NPC intervention, or environmental change | 2 stages: Frozen -> Thawed (binary) | Ancient titan tortoise |
| Social Avoidance | Refuses cohabitation with any creature | Solo enclosure, gradual introduction via adjacent enclosures | 4 stages: Isolated -> Observes -> Adjacent -> Cohabits | Solitary sphinx |
| Night Terrors | Panic episodes during sleep cycle | Night-light items, soothing music box, companion assignment | 4 stages: Nightly -> Weekly -> Rare -> Gone | Young nightmare (equine species) |
| Tool Fear | Panics at sight of tools/implements | Hide tools, use hand-only care until desensitized, gradual tool reintroduction | 3 stages: Panic -> Tolerates -> Accepts | Hippogriff speared by hunters |
| Water Avoidance | Refuses bathing, drinks minimally | Shallow water play, misting system, gradual depth increase | 4 stages: Avoid -> Tolerates -> Plays | Desert-dwelling chimera variant |
| Over-Grooming | Excessively grooms self, causing injury | Distraction enrichment, grooming substitute items, stress reduction | 3 stages: Active -> Diminished -> Stopped | Anxious gryphon |
| Echolalia | Repeats same vocalization compulsively | Musical enrichment, counter-singing, environmental sound variety | 4 stages: Constant -> Frequent -> Occasional -> Stopped | Traumatized siren |
| Attachment Disorder | Bonds too quickly, then rejects randomly | Consistent routine without over-attachment, gradual trust building | 4 stages: Clingy -> Inconsistent -> Stable | Rescue kirin |

**Recovery Formula:**

Each trauma marker has a recovery bar (0-100). Daily care actions add points based on:

```
Recovery Gain = Base Action Value x (Trust Level / 100) x Species Affinity x Enrichment Bonus
```

- **Base Action Value**: Feeding = +3, Grooming = +4, Enrichment = +5, Observation = +2
- **Trust Level**: Current creature trust (0-100) -- higher trust = faster recovery
- **Species Affinity**: Each species has 2-3 trauma markers they recover from faster (innate resilience)
- **Enrichment Bonus**: 1.0x (none) to 1.5x (species-preferred enrichment active)

### 5.2 Secondary Mechanics

#### Feeding & Diet System

Each of the 24 species has specific dietary requirements. Food is sourced from the sanctuary garden, purchased from traveling merchants, or foraged during expeditions.

| Food Category | Examples | Source | Species Served |
|---------------|----------|--------|----------------|
| Raw Meat | Venison, fish, rabbit | Merchant, ranch breeding | Griffins, manticores, rocs, dragons (juvenile) |
| Fresh Produce | Berries, melons, roots | Sanctuary garden | Sphinxes, kirin, unicorns, dryads |
| Prepared Meals | Stews, jerky, honey cakes | Kitchen crafting (unlocks week 4) | All species; higher trust gain |
| Mineral Supplements | Iron ore, salt licks, gem dust | Mining expedition, merchant | Dragons, golems, bulettes |
| Specialized | Phoenix ash-cake, basilisk egg substitute | Research station discovery | Species-specific, unlocks late game |

**Kitchen Crafting:** Unlocks at Facility Tier 3. Combines 2-3 raw ingredients into meals with trust bonuses. 48 recipes discovered through experimentation and NPC hints.

#### Enrichment Design System

Players build enrichment objects from a catalog of 36 base items, each customizable with materials and placement:

| Enrichment Type | Base Items | Customization | Species Preference |
|-----------------|------------|---------------|-------------------|
| Climbing | Rope ladders, cliff walls, perch platforms | Height, material (rope/stone/wood), location | Griffins, rocs, dragons, pegasus |
| Puzzle | Feeders, scent trails, logic gates | Difficulty (3 levels), food reward type | Sphinxes, basilisks, displacer beasts |
| Water | Pools, misters, streams | Depth, temperature, flow rate | Leviathans, kirin, hydras |
| Digging | Sand pits, mud wallows, root beds | Depth, soil type, hidden treasures | Bulettes, minotaurs, badger-type |
| Social | Mirror stations, companion dens, call towers | Partner species, proximity, visual barriers | All social species |
| Rest | Heated rocks, nest material, shade canopies | Temperature, material softness, enclosure size | All species |

**Cohabitation Bonuses:** Placing compatible species in adjacent enclosures unlocks emergent interactions. 42 species-pair combinations exist, each with unique synergy bonuses:

| Species A | Species B | Emergent Interaction | Bonus |
|-----------|-----------|---------------------|-------|
| Griffin | Dragon (elder) | "Unlikely Guardians" -- elder dragon watches over griffin cub | +15% trust gain for both, +5% recovery speed |
| Manticore | Sphinx | "Intellectual Rivals" -- puzzle competition behavior | +20% enrichment engagement, unlocks dual enrichment events |
| Basilisk | Gorgon | "Gaze Bonding" -- mutual eye-contact comfort | +25% eye-contact trauma recovery for both |
| Minotaur | Centaur | "Herd Instincts" -- cooperative territory patrol | +10% facility security, -15% night terror incidents |
| Phoenix | Kirin | "Celestial Harmony" -- shared sunbathing | +30% self-harm recovery, passive healing aura for adjacent enclosures |

#### Visitor Education System

The visitor center generates weekly income based on exhibit quality and tour design:

| Exhibit Element | Visitor Appeal Score | Cost | Research Required |
|-----------------|---------------------|------|-------------------|
| Information Plaque | +5 | 50 gold | None |
| Guided Tour Stop | +15 | 200 gold | Education Level 1 |
| Interactive Display | +25 | 500 gold | Education Level 2 |
| Creature Demonstration | +40 | 1,000 gold | Creature trust > 60 |
| Release Celebration Event | +60 | 2,000 gold | Completed rehabilitation |

**Visitor Types and Preferences:**

| Visitor Type | Frequency | Spending | Preference |
|-------------|-----------|----------|------------|
| Local Family | 40% | 10-30 gold | Cute creatures, simple exhibits |
| Scholar | 25% | 40-80 gold | Rare species, detailed plaques |
| Adventurer (reformed) | 15% | 50-120 gold | Predator species, redemption stories |
| Noble Patron | 10% | 100-300 gold | Exotic species, grand demonstrations |
| Foreign Diplomat | 10% | 150-500 gold | Endangered species, cultural exhibits |

#### Journal System

The player maintains a handwritten-style journal that auto-populates with observations. Players add personal notes, sketches, and care plans. The journal serves as both lore repository and mechanical reference:

- **Auto-entries**: Creature behaviors observed, trauma trigger conditions, breakthrough moments
- **Player entries**: Free-text notes, care plans, emotional reflections
- **Sketch mode**: Simple drawing tool for creature portraits (shareable on supported platforms)
- **Bestiary cross-reference**: Journal entries link to bestiary pages as they're discovered

### 5.3 Difficulty Progression

| Phase | Weeks | Creatures Simultaneous | New Trauma Complexity | Resource Pressure | Key Challenge |
|-------|-------|----------------------|----------------------|-------------------|---------------|
| Tutorial | 1 | 1 | 2 markers, simple care | Abundant supplies | Learning the care loop |
| Early | 2-6 | 2-3 | 3 markers, introduced one at a time | Comfortable | Time management between creatures |
| Mid | 7-15 | 4-5 | 4 markers, overlapping triggers | Moderate -- some budgeting required | Prioritization, cohabitation planning |
| Late | 16-25 | 6-8 | 5 markers, trust freezing events | Tight -- grants and reputation critical | Complex scheduling, breakthrough triggers |
| Endgame | 26+ | 8-12 | 5 markers + rare compound traumas | Comfortable (established facility) | Mastery -- full sanctuary optimization |

---

## 6. World Design

### Map Structure

The game world uses a **hub-and-spoke** structure centered on the sanctuary, with expeditions unlocking as outward spokes:

```
                        +------------------+
                        |  Frozen Reaches  |
                        |  (Tier 4 unlock) |
                        +--------+---------+
                                 |
                        +--------+---------+
                        |  Mountain Roosts  |
                        |  (Tier 3 unlock)  |
                        +--------+---------+
                                 |
    +------------------+        |        +------------------+
    |  Sunken Marshes   |--------+--------|  Sky Islands     |
    |  (Tier 2 unlock)  |        |        |  (Tier 3 unlock) |
    +------------------+        |        +------------------+
                                 |
                        +--------+---------+
                        |   SANCTUARY (Hub) |
                        +--------+---------+
                                 |
    +------------------+        |        +------------------+
    |  Ember Wastes     |--------+--------|  Crystal Caverns |
    |  (Tier 2 unlock)  |        |        |  (Tier 3 unlock) |
    +------------------+        |        +------------------+
                                 |
                        +--------+---------+
                        |  Verdant Hollows  |
                        |  (Tier 1 -- first |
                        |   expedition zone) |
                        +------------------+
```

### Sanctuary Expansion (Facility Tiers)

| Tier | Enclosures | Staff | Facilities | Visual Theme |
|------|-----------|-------|------------|--------------|
| Bronze (Start) | 2 basic enclosures | 1 (you) | Feeding station, basic pantry | Weathered wood, patchy grass, handmade signs |
| Silver | 4 enclosures + 1 specialized | 2 (you + groundskeeper) | Enrichment workshop, small garden | Improved fencing, flower beds, painted signs |
| Gold | 6 enclosures + 2 specialized + visitor center | 4 (+ vet, educator) | Research station, kitchen, tour path | Stone paths, hedge borders, visitor amenities |
| Platinum | 8 enclosures + 3 specialized + large creature wing | 6 (+ researcher, handler) | Advanced lab, aquatic wing, aviary | Polished stonework, trained creatures assisting |
| Mythic | 12 enclosures + 4 specialized + ancient wing | 8 (full team) | Sanctuary-wide systems, expedition HQ | Grand architecture, thriving ecosystem, legendary residents |

### Art Direction Pillars

| Pillar | Description | Reference |
|--------|-------------|-----------|
| Watercolor Warmth | Soft-edged textures with visible brush strokes, warm color palette dominated by amber, sage, and terracotta | Studio Ghibli background paintings, cozy game aesthetic |
| Characterful Creatures | Each species has 8-12 emotion animations, readable body language, exaggerated eyes for expressiveness | Pokemon Camp animations, Monster Hunter Palico expressiveness |
| Lived-In World | Sanctuary shows wear, weathering, and player customization. No pristine environments -- everything looks used and loved | Stardew Valley farm progression |
| Seasonal Atmosphere | Four seasons with distinct lighting, weather, and ambient sounds. Each season affects creature behavior differently | Animal Crossing seasonal changes |
| Gentle Lighting | Golden hour lighting default. Dawn/dusk transitions. Warm interior lighting. Night scenes use moonlight, never darkness. | Spiritfarer lighting design |

### Audio Progression

| Game Phase | Music Style | Ambient Sounds | Creature Sounds |
|------------|------------|----------------|-----------------|
| Early (Bronze) | Solo acoustic guitar, simple melodies | Wind, birdsong, creek | Basic vocalizations, timid |
| Mid (Silver-Gold) | Guitar + strings, fuller arrangements | Added visitor chatter, garden sounds | More confident, species-specific calls emerge |
| Late (Platinum) | Full folk ensemble, emotional crescendos | Sanctuary ambiance, distant creatures | Rich vocal range, contented sounds |
| Endgame (Mythic) | Orchestral folk, occasional choir | Living ecosystem, harmony of all species | Unique legendary creature songs |

---

## 7. Narrative

### Story Spine

| Beat | Story Point | Player Experience |
|------|-------------|-------------------|
| **Equilibrium** | You inherit a rundown sanctuary from your grandmother, a legendary creature healer who recently passed. The facility has one occupant: an elderly manticore named Thornveil who your grandmother rehabilitated 30 years ago. | Tutorial phase. Learn care routines with Thornveil as guide. He is already healed but serves as mentor-creature. |
| **Inciting Incident** | A band of adventurers drops off an orphaned griffin cub, heavily injured, explaining they "had no choice" during a dungeon raid. The cub is terrified, malnourished, and has a broken wing. | First real patient. Player feels the stakes -- this creature needs them. Introduces trauma system. |
| **First Complication** | The local adventurer's guild petitions the regional council to shut down the sanctuary, arguing that "monsters should be slain, not coddled." You have 10 in-game weeks to prove the sanctuary's value. | Introduces reputation system and visitor education. Urgency added to facility management. |
| **Rising Action** | As you rehabilitate and release creatures, their stories spread. Reformed adventurers begin visiting. The guild escalates -- they release a captured dragon into the wilds near your sanctuary to "prove" monsters are dangerous. | Mid-game tension. Multiple creature arcs in progress. The dragon becomes a major rehabilitation challenge. |
| **Midpoint Reversal** | You discover your grandmother's journal revealing she was once an adventurer who killed creatures. Her transformation into a healer was born from guilt -- she personally injured Thornveil decades ago. | Emotional pivot. Player questions their own assumptions. Thornveil's full backstory revealed. |
| **Crisis** | The released dragon, still traumatized, attacks a nearby village. The adventurer's guild uses this as proof. The council votes to close the sanctuary in 4 weeks unless you can rehabilitate the dragon and prove it was the guild's mishandling that caused the attack. | Highest stakes. Dragon rehabilitation is the hardest challenge in the game. Player must use every technique learned. |
| **Climax** | The dragon's rehabilitation arc culminates in a public demonstration before the council. The creature, once violent, approaches the player calmly and performs a trust display. The adventurer responsible for the dragon's trauma confesses. | Dramatic payoff of all mechanical and narrative systems. Player's journey mirrors the grandmother's redemption arc. |
| **Resolution** | The sanctuary receives official protection status. The dragon becomes an ambassador creature. The adventurer's guild reforms. Thornveil, now very old, passes peacefully -- surrounded by the sanctuary community he helped build. | Bittersweet ending. Player can continue in sandbox mode. New creatures arrive, world is changed. |

### Tone Spectrum (7 Axes)

| Axis | Value (1-7) | Notes |
|------|-------------|-------|
| Whimsical vs. Grounded | 3 | Magical creatures exist, but their trauma and healing are treated with realistic emotional weight |
| Lighthearted vs. Melancholic | 4 | Predominantly warm, with genuine sadness in creature backstories and Thornveil's passing |
| Cozy vs. Tense | 2 | Care routines are meditative; tension comes from narrative stakes, not gameplay pressure |
| Simple vs. Complex | 5 | Accessible surface mechanics, deep systems underneath for mastery players |
| Peaceful vs. Challenging | 3 | No fail states; challenge is optimization and emotional investment |
| Optimistic vs. Bittersweet | 4 | Overall hopeful arc, but loss and impermanence are real themes |
| Individual vs. Communal | 5 | Strong individual creature stories within a community of staff and visitors |

### Key Characters

| Character | Role | Theme | Story Fragments | Creature Connection |
|-----------|------|-------|-----------------|-------------------|
| Thornveil (Manticore) | Mentor creature, first resident | Redemption, forgiveness, legacy | 12 fragments revealing grandmother's history | Rehabilitated by grandmother 30 years ago; guides player through trauma markers |
| Helene Ashvale | Groundskeeper, former adventurer | Guilt, atonement, quiet strength | 10 fragments about her adventurer past | Shares trauma history with several creatures |
| Dr. Orin Mossfield | Veterinarian, creature biologist | Scientific curiosity vs. empathy | 8 fragments about creature medicine ethics | Develops new rehabilitation techniques with player |
| Pip Whistlebrook | Young educator, idealist | Innocence, hope, generational change | 8 fragments about growing up near the sanctuary | Connects with young creatures; represents the future |
| Commander Rael Darkhollow | Adventurer's guild leader, antagonist-turned-ally | Prejudice, fear, capacity for change | 10 fragments about why adventurers fear creatures | The one who captured and mishandled the dragon |
| Brin | The dragon (unnamed until player names them) | Fear, power, vulnerability, trust | 14 fragments -- the most of any creature | Central rehabilitation arc; mirror of Thornveil's story |
| Grandmother Elara (journals) | Deceased sanctuary founder | Legacy, transformation, unconditional love | 16 fragments discovered throughout the game | Her journal provides care techniques and story context |
| Fenwick | Traveling merchant | Practical kindness, worldly perspective | 6 fragments about seeing creatures across regions | Provides rare creature supplies and regional news |

---

## 8. Player Personas

### P-002: Sarah Chen -- "The Micro-Gamer"

| Aspect | Analysis |
|--------|----------|
| **Why this fits** | Behemoth Ranch's 20-minute daily care loop maps directly to Sarah's play pattern of 15-20 minute bursts. The creature collection aspect satisfies her collection desire for cute, aesthetically appealing characters without the predatory monetization she dislikes in gacha systems. The creature designs are intentionally adorable. |
| **Predicted experience** | Sarah plays 2-3 in-game days per real day, spreading sessions across her breaks. She gravitates toward the cutest creatures (griffin cubs, kirin, phoenix chicks) and invests heavily in their enrichment. She skips the management optimization, preferring to "see how things go." She will likely cry when Thornveil passes. |
| **What she loves** | The creature designs, the daily routine rhythm, the absence of energy systems or timers, the ability to play offline during soccer practice |
| **What she skips** | Min-maxing recovery rates, the research station, budget optimization |
| **Monetization** | Premium purchase. Will buy DLC creature packs if the creatures are cute (kirin, phoenix, unicorn). Will NOT buy if DLC feels essential. |

### P-008: David Park -- "The Achievement Hunter"

| Aspect | Analysis |
|--------|----------|
| **Why this fits** | The game has 120 bestiary entries, 48 kitchen recipes, 42 species-pair cohabitation bonuses, and a 5-tier facility progression. David treats completion as an engineering project. The game's explicit tracking systems (bestiary, journal, facility tier) provide clear progress metrics. |
| **Predicted experience** | David plays one focused 45-minute session daily, systematically working through each progression axis. He creates external spreadsheets tracking creature recovery rates, cohabitation pairings, and optimal feeding schedules. He 100%s the game before moving on. |
| **What he loves** | Clear completion metrics, the 42 cohabitation bonuses as discovery puzzles, the 48 recipes as a crafting completion tracker, journal filling to 100% |
| **What he skips** | The emotional narrative beats (he reads them once and moves on), the visitor education system once optimized |
| **Monetization** | Premium purchase plus all DLC for achievement completion. Specifically motivated by DLC that adds bestiary entries and achievements. |

### P-013: Robert Thompson -- "The Relaxation Player"

| Aspect | Analysis |
|--------|----------|
| **Why this fits** | Robert needs mindless, pressure-free gameplay. The daily care routine in Behemoth Ranch is explicitly meditative -- feeding, grooming, and observing require no competitive thinking. No timers, no fail states, no pressure. The warm art direction and gentle audio reinforce relaxation. |
| **Predicted experience** | Robert plays 1 in-game day per night before sleep. He picks one creature and focuses entirely on it, finding the grooming minigame particularly soothing. He ignores the facility management entirely, letting it develop naturally. He plays for 9+ months. |
| **What he loves** | The grooming minigame, the warm visual palette, the ambient audio, the absence of any countdown or urgency |
| **What he skips** | Reputation management, visitor center, budget tracking, research station |
| **Monetization** | Premium purchase only. Will never buy DLC. One of the rare games he keeps installed permanently. |

### P-015: Jennifer Martinez -- "The Conscious Parent"

| Aspect | Analysis |
|--------|----------|
| **Why this fits** | Jennifer researches games before allowing her children (ages 8 and 11) to play. Behemoth Ranch is E-rated, has no violence, no gambling mechanics, no predatory monetization, and teaches empathy, animal care, and the consequences of prejudice. It is exactly the type of game Jennifer actively seeks out for her family. |
| **Predicted experience** | Jennifer plays the first 2 hours herself to evaluate content. She finds the rehabilitation themes educational and approves it for both children. Her 8-year-old focuses on the creature interactions. Her 11-year-old engages with the facility management. Jennifer herself becomes invested in the story. |
| **What she loves** | E rating, premium model (no surprise purchases), empathy-building themes, educational subtext about prejudice and rehabilitation |
| **What she skips** | Nothing -- she engages as a gatekeeper first, then plays herself |
| **Monetization** | Premium purchase. Will buy family-appropriate DLC. Will recommend to parent groups, driving word-of-mouth sales. |

---

## 9. User Stories

### Exploration

1. As a player (P-002), I want to forage for ingredients in unlocked expedition zones so that I can prepare species-specific meals without spending gold.
2. As a player (P-008), I want a world map showing all expedition zones with completion percentages so that I can track which regions I have fully explored.
3. As a player (P-003), I want to discover hidden areas within each expedition zone by observing creature behavior cues so that I feel rewarded for paying attention.
4. As a player (P-013), I want expedition zones to have no time limits or fail states so that I can explore at my own pace without anxiety.

### Core Mechanics -- Creature Care

5. As a player (P-002), I want to prepare meals for my creatures by dragging ingredients into a cooking pot so that feeding feels interactive and satisfying, not menu-driven.
6. As a player (P-008), I want each of the 48 kitchen recipes to be discoverable through experimentation with clear "new recipe unlocked" feedback so that I can track my cooking completion rate.
7. As a player (P-013), I want the grooming minigame to have no failure condition -- only varying degrees of success -- so that I never feel punished for engaging with it.
8. As a player (P-003), I want creatures to visibly respond to correct care with species-specific animations (a griffin preening, a manticore purring) so that I can read their emotional state without checking menus.
9. As a player (P-002), I want to name each creature and have that name appear in all journal entries and dialogue so that I feel personal ownership of the rehabilitation relationship.
10. As a player (P-008), I want the bestiary to track completion as a fraction (e.g., "47/120 entries discovered") so that I always know how far I am from 100%.

### Core Mechanics -- Trauma and Rehabilitation

11. As a player (P-003), I want trauma markers to have clear visual indicators on the creature's status screen (icons, progress bars) so that I know exactly what care actions to prioritize.
12. As a player (P-008), I want the recovery formula shown in the bestiary so that I can mathematically optimize my care routine for each creature.
13. As a player (P-013), I want trauma events to be skippable without penalty so that I am never forced into emotionally intense moments when I am playing to relax.
14. As a player (P-002), I want breakthrough moments to have celebratory visual effects (particles, music swell) so that I feel emotionally rewarded for my care investment.
15. As a player (P-015), I want the rehabilitation system to teach my children about patience and consistent care by showing that creatures recover faster with daily attention than sporadic bursts so that the game reinforces real-world values.

### Narrative

16. As a player (P-003), I want each creature's backstory revealed through 3-5 journal fragments unlocked during rehabilitation so that I feel motivated to complete each creature's arc.
17. As a player (P-002), I want Thornveil to occasionally offer care advice through animated thought-bubble sequences so that I feel a connection to the mentor creature even during routine gameplay.
18. As a player (P-015), I want the story to address prejudice against "monsters" as a metaphor for real-world discrimination so that my children engage with the theme naturally through play.
19. As a player (P-008), I want to find all 16 of Grandmother Elara's journal fragments so that I can complete the lore collection and understand the full backstory.
20. As a player (P-013), I want the narrative to progress through gentle dialogue that I can read at my own pace without timed choices so that story moments remain relaxing.

### Progression and Facility Management

21. As a player (P-008), I want each facility tier to have a clear checklist of requirements so that I always know exactly what I need to do to reach the next tier.
22. As a player (P-003), I want to unlock new enclosure types at specific facility tiers with a notification showing what species they support so that I can plan my sanctuary layout strategically.
23. As a player (P-008), I want the cohabitation bonuses screen to show discovered and undiscovered pairings (e.g., "14/42 discovered") so that I can treat it as a completion puzzle.
24. As a player (P-013), I want the facility management to have an "auto-suggest" mode that recommends enclosure upgrades so that I do not have to analyze optimization myself.
25. As a player (P-002), I want to place decorative items in enclosures and see creatures interact with them so that I can customize the sanctuary for visual satisfaction.

### Social and Visitor System

26. As a player (P-002), I want to design tour routes through my sanctuary by placing guide flags so that I feel creative ownership over the visitor experience.
27. As a player (P-015), I want the visitor education system to show measurable perception changes in NPC dialogue so that my children can see the impact of empathy on a community.
28. As a player (P-008), I want visitor satisfaction scores broken down by visitor type so that I can optimize my exhibit strategy for maximum income.

### Accessibility

29. As a player (P-018), I want all creature status information presented through both visual icons and text labels so that I can access information regardless of vision level.
30. As a player (P-019), I want the game to be fully playable offline with no online-required features so that I can play in areas with limited connectivity.
31. As a player (P-020), I want full localization in Japanese with culturally appropriate creature names so that I can experience the game in my native language.
32. As a player (P-015), I want a "family mode" toggle that simplifies the financial management so that younger children can focus on creature care without budget stress.

### Release and Endgame

33. As a player (P-002), I want the choice to release or retire a rehabilitated creature to feel emotionally weighty, with a cinematic farewell scene for releases so that the decision matters.
34. As a player (P-008), I want a sanctuary statistics screen showing total creatures rehabilitated, released, and retired so that I can track my overall career achievements.
35. As a player (P-003), I want released creatures to occasionally appear during expedition events so that I feel my past care decisions have lasting impact on the world.

---

## 10. Monetization

### Model: Premium + Creature DLC Packs

**Why premium fits this game:**

- The cozy simulation audience (Stardew Valley, Animal Crossing, Spiritfarer) overwhelmingly prefers premium models over F2P
- The rehabilitation theme is antithetical to predatory monetization -- asking players to pay to speed up creature healing would undermine the game's core message about patience and care
- Sarah (P-002) is actively frustrated by energy systems; Robert (P-013) abandons games with pressure mechanics; Jennifer (P-015) vets games for predatory mechanics before purchase
- Premium allows offline play, which serves P-019 (low bandwidth) and the cozy "play anywhere" ethos

### Pricing

| Product | Price | Contents |
|---------|-------|----------|
| Base Game | $24.99 | Full game: 24 base species, 5 expedition zones, complete story, sandbox mode |
| Creature Pack: Shores and Depths | $7.99 | 4 aquatic species (leviathan, sea serpent, merfolk creature, kraken juvenile), aquatic enclosures, 2 new expedition zones |
| Creature Pack: Sky and Storm | $7.99 | 4 aerial species (thunderbird, cloud drake, sky kirin, wind elemental), aviary expansion, 2 new expedition zones |
| Creature Pack: Ancients | $9.99 | 3 legendary species (tarrasque juvenile, ancient treant, colossus), ancient wing expansion, endgame story epilogue |
| Seasonal Decorations Pack | $4.99 | 48 decorative items themed to 4 seasons, holiday events, no gameplay impact |

### Revenue Projections (4 Scenarios)

| Scenario | Year 1 Units | Year 1 Revenue | Year 2 Units | Year 2 Revenue | DLC Attach Rate | Total 2-Year |
|-----------|-------------|----------------|-------------|----------------|-----------------|--------------|
| Modest | 15,000 | $374,850 | 8,000 | $199,920 | 18% | $655,262 |
| Expected | 45,000 | $1,124,550 | 25,000 | $624,750 | 28% | $2,146,250 |
| Strong | 120,000 | $2,998,800 | 70,000 | $1,749,300 | 35% | $5,641,050 |
| Breakout | 350,000 | $8,746,500 | 200,000 | $4,998,000 | 42% | $16,747,500 |

**Assumptions:** Steam 70% rev share (after 30% platform cut). DLC revenue calculated at weighted average price of $8.32 across packs. Year 2 includes base game + DLC + word-of-mouth tail.

### DLC Release Roadmap

| Timing | Pack | Rationale |
|--------|------|-----------|
| Month 3 post-launch | Shores and Depths | Extends playtime for completionists, adds aquatic content players expect from creature games |
| Month 6 post-launch | Sky and Storm | Second pack maintains engagement, aerial species are highly requested in community feedback |
| Month 9 post-launch | Seasonal Decorations | Low-cost cosmetic pack for holiday season, maintains visibility |
| Month 12 post-launch | Ancients | Premium endgame expansion for dedicated players, extends narrative with epilogue |

---

## 11. Production Plan

### Team

| Role | Count | Phase(s) | Monthly Cost | Notes |
|------|-------|----------|--------------|-------|
| Creative Director | 1 | Pre-prod through launch | $9,500 | Leads vision, narrative, and design reviews |
| Lead Designer | 1 | Pre-prod through launch | $8,500 | Core loop, progression, creature systems |
| Game Designer (Junior) | 1 | Production through launch | $5,000 | Enrichment items, visitor system, balancing |
| Lead Programmer | 1 | Pre-prod through launch | $10,000 | Architecture, performance, cross-platform |
| Gameplay Programmer | 2 | Production through launch | $7,500 each | Creature AI, care systems, UI |
| UI Programmer | 1 | Production through launch | $7,000 | Journal, menus, accessibility features |
| Art Director | 1 | Pre-prod through launch | $8,500 | Watercolor style definition, creature design |
| 2D Artist (Creatures) | 2 | Production through launch | $6,500 each | 24 species x 8-12 animations each |
| 2D Artist (Environments) | 1 | Production through launch | $6,500 | Sanctuary zones, expedition areas |
| UI Artist | 1 | Production through polish | $6,000 | Menus, icons, journal, accessibility |
| Technical Artist | 1 | Production through launch | $7,500 | Animation pipeline, shader work, optimization |
| Composer | 1 | Production through polish | $6,000 | Seasonal music, creature sounds |
| Sound Designer | 1 | Production through polish | $5,500 | Ambient audio, UI sounds, creature vocalizations |
| Narrative Designer | 1 | Pre-prod through production | $7,000 | Story spine, creature backstories, NPC dialogue |
| QA Lead | 1 | Alpha through launch | $5,500 | Test planning, regression, accessibility testing |
| QA Tester | 1 | Alpha through launch | $4,000 | Daily testing, bug reporting |
| Producer | 1 | Full project | $8,000 | Scheduling, scope management, platform relations |
| Community Manager (PT) | 0.5 | Beta through post-launch | $3,000 | Discord, social media, player feedback |

**Total team: 21 FTE | Monthly burn: ~$148,500**

### Timeline

| Month | Phase | Milestone | Deliverables |
|-------|-------|-----------|-------------|
| 1-2 | Pre-Production | Vertical Slice | Core loop prototype, 2 creature species fully playable, art style locked, architecture approved |
| 3-4 | Pre-Production | Design Complete | Full design document, all 24 species designed, trauma catalog finalized, story spine written |
| 5-8 | Production Alpha | Feature Complete | All creatures playable, 5 expedition zones, facility tiers 1-5, visitor system, journal system |
| 9-12 | Production Alpha | Content Complete | All 120 bestiary entries, 48 recipes, 42 cohabitation pairs, full narrative script, all voice/text |
| 13-15 | Beta | Content Lock | Bug fixing, balancing trauma recovery rates, platform certification prep, QA regression |
| 16-17 | Polish | Release Candidate | Performance optimization (30fps Switch, 60fps PC), localization for 6 languages, accessibility audit |
| 18 | Launch | Gold Master | Day-1 patch, marketing push, press copies, console cert complete |
| 19-20 | Post-Launch | Day-1 Patch + DLC 1 | Bug fixes from player reports, begin Shores and Depths DLC |
| 21-24 | DLC Support | 3 DLC Packs | Sky and Storm (Month 21), Seasonal Decorations (Month 23), Ancients (Month 24) |

### Budget Breakdown

| Category | Amount | % of Total | Notes |
|----------|--------|------------|-------|
| Salaries (18 months x 21 FTE) | $2,673,000 | 74.2% | Core team compensation |
| Software and Tools | $36,000 | 1.0% | Unity Pro, Figma, Jira, GitHub, localization tools |
| Art Outsourcing | $120,000 | 3.3% | Additional creature animations, environment detail work |
| Audio Outsourcing | $48,000 | 1.3% | Orchestra session for endgame music, foley recording |
| QA and Testing | $45,000 | 1.2% | Device lab, accessibility audit, platform compliance testing |
| Localization | $60,000 | 1.7% | 5 additional languages (JP, ZH, ES, FR, DE) |
| Marketing | $240,000 | 6.7% | Trailers, PR, influencer outreach, event presence |
| Platform Fees | $35,000 | 1.0% | Steam Direct, console dev kits, age rating submissions |
| Contingency (15%) | $538,500 | 14.9% | Buffer for scope adjustments and unexpected costs |
| **Total** | **$3,795,500** | **100%** | |

**Break-even at approximately 152,000 units** (base game only at $24.99, after platform cut). With DLC attach at 28%, break-even drops to approximately 118,000 units.

---

## 12. Technical Requirements

### Platform Specifications

| Spec | PC (Min) | PC (Rec) | Nintendo Switch | iOS | Android |
|------|----------|----------|-----------------|-----|---------|
| OS | Windows 10 | Windows 10/11 | Switch OS | iOS 15 | Android 11 |
| CPU | Intel i3-6100 | Intel i5-8400 | ARM Cortex-A57 | A12 Bionic | Snapdragon 730 |
| RAM | 4 GB | 8 GB | 4 GB | 3 GB | 4 GB |
| GPU | DirectX 11 any | GTX 1050 | Integrated | GPU Sandbox | Adreno 618 |
| Storage | 4 GB | 4 GB | 3.5 GB | 2.5 GB | 2.5 GB |
| Target FPS | 30 | 60 | 30 | 30 | 30 |
| Resolution | 720p | 1080p | 720p handheld / 1080p docked | Native | Native |
| Input | Keyboard/Mouse | KB/M + Controller | Joy-Con/Pro | Touch | Touch |

### Key Technical Challenges

| Challenge | Risk | Mitigation |
|-----------|------|------------|
| **Creature AI State Machine** | 24 species x 8-12 emotion states = complex behavior matrix. Creatures must respond to environment, player actions, trauma state, and cohabitation simultaneously. | Build a modular behavior tree system per species. Each species inherits from a base creature class and overrides 4-6 species-specific behaviors. Test with 3 species early (month 3) to validate architecture. |
| **Cross-Platform Save Sync** | Players switching between PC and mobile expect seamless progression. Save data includes facility state, creature progress, journal entries, and customization. | Implement cloud save via platform-native APIs (Steam Cloud, iCloud, Google Play Games). Save format is JSON with version migration system. Offline-first design; cloud sync is additive, not required. |
| **Mobile Performance** | 8-12 creatures with independent AI, enrichment interactions, visitor NPCs, weather systems, and particle effects must run at 30fps on mid-range mobile. | Implement aggressive LOD system: creatures outside the camera view reduce to tick-based simulation (no rendering). Limit active creature animations to 4 on-screen. Use sprite atlases for all 2D elements. |
| **Accessibility Across Platforms** | Screen readers, font scaling, colorblind modes, and input remapping must work consistently across 5 platforms. | Use Unity's UI Accessibility Plugin as foundation. Test with VoiceOver (iOS), TalkBack (Android), and NVDA (PC) from month 6. Dedicated accessibility QA pass in months 15-16. |
| **Watercolor Art Pipeline** | Soft-edged, painterly textures at 2x resolution for crisp rendering create large asset bundles, especially with 24 species x 12 animations. | Implement texture streaming: load only visible creature textures. Use ASTC compression for mobile, BC7 for desktop. Sprite atlases batch animations per species. Total texture budget: 1.2 GB. |
| **Switch Port Performance** | Switch has 4 GB shared RAM. With OS overhead, approximately 2.5 GB available. Must fit full sanctuary scene in memory. | Dedicated memory profiling from month 8. Switch runs at reduced texture resolution (half of PC). Creature animations use simplified rigs on Switch. Target: max 1.8 GB active memory. |

### Architecture Overview

```
+-------------------------------------------------------------+
|                    GAME ARCHITECTURE                         |
+-------------------------------------------------------------+
|                                                             |
|  +----------------+  +----------------+  +----------------+ |
|  |  Presentation  |  |  Game Logic    |  |    Data        | |
|  |    Layer       |  |    Layer       |  |    Layer       | |
|  |                |  |                |  |                | |
|  | - Rendering    |  | - Creature     |  | - Save/Load    | |
|  | - UI/UX        |  |   AI/State     |  | - Bestiary     | |
|  | - Audio        |  | - Care         |  |   Database     | |
|  | - Particles    |  |   System       |  | - Config       | |
|  | - Camera       |  | - Facility     |  | - Localization | |
|  |                |  |   Manager      |  | - Journal      | |
|  |                |  | - Visitor      |  |   Records      | |
|  |                |  |   System       |  |                | |
|  |                |  | - Economy      |  |                | |
|  |                |  | - Narrative    |  |                | |
|  |                |  |   Engine       |  |                | |
|  +----------------+  +----------------+  +----------------+ |
|                                                             |
|  +-------------------------------------------------------+ |
|  |              PLATFORM ABSTRACTION                      | |
|  |  - Input (KB/M, Touch, Controller)                    | |
|  |  - Cloud Save (Steam, iCloud, Google Play)            | |
|  |  - Platform Events (Achievements, Notifications)      | |
|  +-------------------------------------------------------+ |
+-------------------------------------------------------------+
```

### Build and Deployment

| Platform | Build System | CI/CD | Certification |
|----------|-------------|-------|---------------|
| PC (Steam) | Unity Cloud Build + Steamworks SDK | GitHub Actions: build on tag, auto-deploy to Steam branches | Steam Direct review (~3 days) |
| Nintendo Switch | Unity Switch module + Nintendo SDK | Local build (Nintendo dev hardware required) | Lotcheck submission (~4 weeks) |
| iOS | Unity Cloud Build + Xcode | GitHub Actions -> TestFlight -> App Store Connect | App Store review (~2 days) |
| Android | Unity Cloud Build + Gradle | GitHub Actions -> Google Play Console | Google Play review (~3 days) |

### Post-Launch Technical Commitments

| Commitment | Duration | Scope |
|-----------|----------|-------|
| Critical bug fixes | 12 months post-launch | Crashes, save corruption, progression blockers |
| Platform compatibility updates | 12 months post-launch | New iOS/Android versions, Steam Deck verification |
| DLC content updates | 12 months post-launch (quarterly) | 3 creature packs + 1 cosmetic pack |
| Community-requested features | 6 months post-launch | Quality-of-life improvements based on player feedback |

---

*Behemoth Ranch -- Creature rehabilitation sim. Because every monster deserves a second chance.*
