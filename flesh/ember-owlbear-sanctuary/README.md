# Ember Owlbear Sanctuary

## 1. Title & Genre

| Field | Value |
|-------|-------|
| **Title** | Ember Owlbear Sanctuary |
| **Genre** | Cozy Simulation / Creature Sanctuary Builder |
| **Sub-genres** | Volcanic gardening, creature rehabilitation, resource management, narrative exploration |
| **Engine** | Unity 2023 LTS (C#) -- cross-platform support, 2D/3D hybrid rendering for creature animations against 3D volcanic environments, mature mobile pipeline |
| **Platforms** | PC (Steam), Nintendo Switch, PlayStation 5, iOS, Android |
| **Monetization** | Premium ($19.99) + cosmetic den decoration packs ($4.99 each) |
| **ESRB** | E (Everyone -- Mild Fantasy Themes) |
| **PEGI** | 3 |
| **Target session** | 15-40 minutes |
| **Save system** | Cloud save cross-platform (Steam Cloud / PS Plus cloud / iCloud / Google Play Games) |
| **Languages at launch** | English, Japanese, Simplified Chinese, Spanish, French, German |
| **Offline play** | Full offline supported -- no always-online requirement |

---

## 2. Vision Statement

Ember Owlbear Sanctuary is a volcanic creature-rehabilitation sim where the player inherits a crumbling caldera sanctuary and transforms it into a refuge for ember owlbears -- fire-attuned magical beasts driven from their mountain roosts by an encroaching frost blight. The game exists because the cozy-sim genre has no title that marries creature caregiving with volcanic gardening and seasonal crisis management. The closest analogues -- Slime Rancher's creature collection and Stardew Valley's daily loop -- do not explore the emotional texture of rehabilitation, and no game in the space centers a fire-themed ecosystem where the environment itself is both nurturer and threat. Ember Owlbear Sanctuary occupies that gap. It feels like tending a hearth in winter: warm light, crackling ambience, the satisfaction of watching something cold and frightened become warm and curious. The daily rhythm is meditative -- wake, forage the caldera, tend the thermal gardens, feed the owlbears, build heated dens, watch the sunset paint the crater walls orange -- punctuated by frost blight incursions that test triage instincts and by personality-driven social dynamics between residents that create emergent stories. The game targets players who screenshot their farms in Stardew Valley, who spend hours decorating houses in Animal Crossing, and who want their cozy loop to carry genuine emotional stakes without ever becoming punishing.

---

## 3. Core Loop

```
                        +------------------------------------------+
                        |                                          |
                        v                                          |
+-----------+    +---------------+    +------------------+        |
| Dawn Wake |    | Check Dens &  |    |   PRIORITIZE     |        |
| (Weather  |--->| Status Board  |--->|   DAILY TASKS    |        |
|  Report)  |    | & Mailbox     |    |                  |        |
+-----------+    +---------------+    +--------+---------+        |
                                               |                   |
                        +----------------------+                   |
                        |                      |                   |
                        v                      v                   |
               +----------------+     +-----------------+          |
               |  CALDERA       |     |  VOLCANO GARDEN |          |
               |  FORAGING      |     |  TENDING        |          |
               |                |     |                  |          |
               | - Thermal herbs|     | - Water lava     |          |
               | - Obsidian     |     |   planters       |          |
               |   chunks       |     | - Harvest crops  |          |
               | - Hot springs  |     | - Cross-breed    |          |
               |   minerals     |     |   flora          |          |
               +-------+--------+     +--------+--------+          |
                       |                       |                    |
                       +-----------+-----------+                    |
                                   |                                |
                                   v                                |
                          +----------------+                        |
                          |  OWLBEAR CARE  |                        |
                          |  (Primary)     |                        |
                          |                |                        |
                          | 1. Feed        |                        |
                          | 2. Heal        |                        |
                          | 3. Enrichment  |                        |
                          | 4. Bond        |                        |
                          +-------+--------+                        |
                                  |                                  |
                          +-------+--------+                        |
                          |  DEN BUILDING  |                        |
                          |  & SANCTUARY   |                        |
                          |  EXPANSION     |                        |
                          +-------+--------+                        |
                                  |                                  |
                     +------------+------------+                    |
                     |                         |                    |
                     v                         v                    |
            +----------------+        +-----------------+           |
            | FROST BLIGHT   |        | EVENING REFLECT |           |
            | EVENT          |        |                 |           |
            | (Triggered)    |        | - Journal       |           |
            |                |        | - Plan next day |           |
            | - Triage dens  |        | - Release /     |           |
            | - Evacuate     |        |   Keep decision |           |
            | - Defend flora |        +-----------------+           |
            +-------+--------+                                      |
                    |   Trust gained                                 |
                    |   Resources saved                              |
                    +------------------------------------------------+

```

### Core Loop Breakdown

| Phase | Duration | Player Action | System Response |
|-------|----------|---------------|-----------------|
| Dawn Wake | 30 sec | View weather report, seasonal temperature, frost blight proximity meter | Game presents daily conditions -- volcanic ashfall, thermal vent shifts, frost creep speed |
| Check Dens | 1-2 min | Review each owlbear's mood, health, hunger, and comfort level | Status board highlights owlbears with unmet needs, pending personality conflicts, or frost exposure risk |
| Prioritize | 1 min | Select which caldera zones to forage, which gardens to tend, which dens need repairs | Time-of-day system allocates daylight hours; player cannot do everything in one day, forcing meaningful choices |
| Caldera Foraging | 5-8 min | Explore caldera zones gathering thermal herbs, obsidian chunks, hot-spring minerals | Resources respawn based on geothermal activity. Rare ingredients appear near active vents. Foraging skill reveals hidden deposits. |
| Volcano Garden | 3-5 min | Plant, water (with lava), harvest, cross-breed thermal flora in lava-soil planters | Plants grow in real-time over in-game days. Cross-breeding unlocks rare species. Harvest yields medicine, food, and construction materials. |
| Feed | 2-3 min | Prepare species-appropriate meals from harvested ingredients or foraged goods | Owlbears gain satiation (0-100). Matching food to personality preference (brave owlbears prefer spicy obsidian berries; timid ones prefer mild magma-root mash) grants a comfort bonus. |
| Heal | 2-3 min | Apply firebloom-petal poultices, warm thermal wraps, or mineral supplements to injured owlbears | Health restores over time with treatment. Untreated injuries develop into conditions that reduce trust gain. |
| Enrichment | 3-5 min | Place lava-pool toys, obsidian perches, smoldering log puzzles, ember-dust scratching posts | Owlbears interact based on personality matrix. Successful enrichment reduces stress and unlocks personality-specific animations. |
| Bond | 2-3 min | Sit near owlbears, offer hand-fed treats, observe and log behavioral cues | Trust meter increases (0-100). High trust unlocks new care options, personality revelations, and story fragments. |
| Den Building | 3-5 min | Construct and upgrade dens using obsidian, magma root lumber, and basalt tiles | Den quality affects comfort recovery rate, frost resistance, and owlbear capacity. Each den type suits different personality combinations. |
| Frost Blight Event | 3-8 min (when triggered) | Triage which dens to prioritize for heating, which plants to protect with thermal barriers, which owlbears to evacuate to inner sanctum | Resource-management spike in an otherwise cozy loop. Successful defense grants rare frost-resistant materials. Failure damages dens and stresses owlbears (never kills them). |
| Evening Reflect | 1-2 min | Review journal entries, plan next day, decide whether to release rehabilitated owlbears or keep as permanent residents | Day summary shows trust changes, garden yields, frost blight proximity shift. Release scenes are cinematic and emotionally weighted. |

**Target session length: 20-35 minutes per in-game day.** Players can pause at any phase and resume from that point.

---

## 4. Meta Loop

### Session-to-Session Progression Axes

| Progression Axis | What Grows | How It Grows | Growth Feel |
|------------------|-----------|--------------|-------------|
| **Owlbear Trust** | Per-creature trust meter (0-100) and personality matrix depth (4 traits, each 0-100) | Daily care routines, successful enrichment, matching dens to personality, frost blight defense | Slow, earned, personal -- each trust milestone unlocks a new behavioral animation or story fragment |
| **Sanctuary Tier** | Facility rating (Ember -> Cinder -> Forge -> Caldera -> Mythic) | Complete rehabilitation arcs, garden milestones, den quality thresholds, frost blight defenses survived | Steady unlocks -- new caldera zones, den types, garden planter slots, and owlbear capacity at each tier |
| **Thermal Flora Codex** | Plant species discovered (48 total), cross-breed recipes (24 hybrids), gardening techniques (18 learned) | Harvesting, cross-breeding experiments, observing growth patterns in different thermal zones | Discovery-driven -- each new hybrid unlocks new medicine, food quality, or attracts rare owlbear variants |
| **Frost Blight Resistance** | Sanctuary perimeter defenses (0-100 per zone), thermal vent network efficiency, owlbear acclimatization | Build thermal barriers, upgrade lava-channel heating, research frost-resistant flora | Escalating tension -- frost blight grows stronger each season, forcing strategic investment in defenses |
| **Personality Network** | Social compatibility map between resident owlbears (up to 42 unique pairings) | Observe interactions, manage den assignments, mediate personality conflicts | Emergent -- brave+brave pairings become best friends or territorial rivals based on subtle context; the system creates stories the player did not script |
| **Caldera Exploration** | Foraging zones unlocked (6 zones), hidden hot springs discovered (12), geothermal vents mapped | Explore during foraging phase, follow environmental clues, invest in path-building | Exploration reward -- each new zone yields unique resources and owlbear rescue encounters |

### Progression Timeline

| Game Week | Milestone | What Unlocks |
|-----------|-----------|--------------|
| 1 | Tutorial: First ember owlbear rescue (juvenile, mild injuries) | Basic care loop -- feeding, healing, den assignment |
| 2-3 | Sanctuary Tier 2 (Cinder) | Volcano gardening system, second den slot, personality matrix revealed |
| 4-6 | First rehabilitation complete | Release or permanent-resident choice, first frost blight minor event |
| 7-10 | Sanctuary Tier 3 (Forge) | Cross-breeding garden, third den, enrichment system, hot-spring mineral baths |
| 11-15 | First major frost blight incursion | Thermal defense system, evacuations, triage mechanics, frost-resistant flora research |
| 16-20 | Sanctuary Tier 4 (Caldera) | Inner caldera zones open, large-capacity communal dens, legendary owlbear variants begin arriving |
| 21-30 | Sanctuary Tier 5 (Mythic) | Deep caldera vents, ancient owlbear species, full thermal network, endgame narrative resolution |
| 30+ | Post-game | Sandbox mode, new game+ with harder frost blight patterns, community challenge gardens |

---

## 5. Game Mechanics

### 5.1 Primary Mechanic: Ember Owlbear Personality Matrix

Every ember owlbear possesses a personality defined by four traits, each scored 0-100:

| Trait | Low (0-33) | Mid (34-66) | High (67-100) |
|-------|-----------|------------|---------------|
| **Bravery** | Timid -- startles easily, prefers enclosed dens, bonds slowly | Cautious -- observes before acting, comfortable in standard dens | Bold -- explores freely, prefers open dens, bonds quickly but can become territorial with other bold owlbears |
| **Curiosity** | Indifferent -- ignores enrichment, content with routine | Moderate -- engages with new items briefly, explores within comfort zone | Inquisitive -- investigates everything, destroys enrichment faster (wears out toys), discovers hidden caldera paths |
| **Stubbornness** | Compliant -- accepts care willingly, adapts to den changes | Willful -- occasionally refuses care, needs specific den conditions | Obstinate -- refuses care that does not match preferences, but highest trust ceiling once bonded |
| **Warmth** | Aloof -- does not seek player proximity, bonds through indirect care | Friendly -- approaches player voluntarily, comfortable with direct care | Affectionate -- seeks physical contact, follows player during caldera walks, purrs audibly |

**Personality Conflict Resolution:**

When two owlbears share a den, their personality matrices interact:

| Pairing | Possible Outcomes | Determining Factor |
|---------|-------------------|--------------------|
| High Bravery + High Bravery | Best friends (shared patrols, mutual grooming) OR territorial rivals (resource guarding, stress spikes) | Warmth scores -- if both have high Warmth, friendship; if either has low Warmth, rivalry |
| High Curiosity + Low Curiosity | Teacher-student dynamic -- curious owlbear shows indifferent one new behaviors | Always positive, but curious owlbear enrichment wear rate doubles |
| High Stubbornness + High Stubbornness | Cold war -- both refuse shared resources, require separate feeding stations | Always tension, but if both reach trust > 80 simultaneously, they develop a grudging respect that unlocks a unique duo animation |
| High Warmth + Low Warmth | Adoption dynamic -- affectionate owlbear grooms and comforts aloof one | Gradually raises the aloof owlbear's Warmth score by +1 per in-game week |
| High Bravery + Low Bravery | Protector dynamic -- bold owlbear defends timid one during frost blight events | Timid owlbear gains +10 bravery temporarily during frost events when protector is in same den |

**Trust Gain Formula:**

```
Trust Gain = Base Action Value x (Comfort Level / 100) x Personality Match x Frost Stress Modifier
```

- **Base Action Value**: Feeding = +3, Healing = +4, Enrichment = +5, Bonding = +6, Frost Defense Success = +2
- **Comfort Level**: Derived from den quality, temperature, and personality-den match (0-100)
- **Personality Match**: Feeding correct personality-preferred food = 1.3x; wrong food = 0.7x
- **Frost Stress Modifier**: During frost blight proximity, 0.5x (all trust gain halved until blight repelled); after successful defense, 1.2x for 2 days (relief bonding)

### 5.2 Secondary Mechanics

#### Volcano Gardening System

Thermal flora grows in lava-soil planters heated by geothermal channels. The player manages soil temperature (measured in ember-degrees, 200-800 E), water supply (molten mineral water, not regular water), and cross-breeding experiments.

**Base Flora Species (12):**

| Plant | Ember-Degree Range | Grow Time | Primary Yield | Secondary Yield |
|-------|--------------------|-----------|---------------|-----------------|
| Firebloom | 300-500 E | 2 days | Petals (medicine ingredient) | Seeds for replanting |
| Obsidian Berry | 400-600 E | 3 days | Berries (food -- brave preference) | Berry juice (healing salve base) |
| Magma Root | 500-700 E | 4 days | Root lumber (den construction) | Root fiber (enrichment toy crafting) |
| Cinder Moss | 200-400 E | 1 day | Moss (den bedding, comfort bonus) | Spores (cross-breed catalyst) |
| Ash Fern | 250-450 E | 2 days | Fronds (roof thatch, insulation) | Ash powder (fertilizer) |
| Coal Cap Mushroom | 350-550 E | 2 days | Caps (food -- curious preference) | Spore cloud (repels minor frost blight) |
| Sulfur Orchid | 600-800 E | 5 days | Petals (rare medicine) | Sulfur dust (thermal barrier fuel) |
| Basalt Vine | 450-650 E | 3 days | Vine rope (enrichment swings, bridges) | Basalt sap (den waterproofing) |
| Ember Wheat | 300-500 E | 2 days | Grain (food -- compliant preference) | Straw (bedding) |
| Lava Lotus | 550-750 E | 4 days | Lotus seeds (cross-breed catalyst, rare) | Lotus water (premium healing elixir) |
| Crackle Reed | 200-350 E | 1 day | Reeds (den walls, windbreak) | Crackle fiber (enrichment scratch posts) |
| Iron Bloom | 650-800 E | 6 days | Iron petals (reinforced den walls) | Iron dust (frost blight barrier core) |

**Cross-Breeding (24 hybrids discovered through experimentation):**

Placing two compatible species in adjacent planters with a catalyst (cinder moss spores or lava lotus seeds) produces a hybrid after both mature. The player discovers combinations through trial, observation, and journal hints.

| Hybrid | Parent A | Parent B | Catalyst | Yield |
|--------|----------|----------|----------|-------|
| Frostguard Bloom | Firebloom | Iron Bloom | Cinder Moss Spores | Petals that grant frost resistance when woven into den bedding |
| Phoenix Berry | Obsidian Berry | Sulfur Orchid | Lava Lotus Seeds | Food that boosts trust gain by 1.5x for 1 day |
| Obsidian Timber | Magma Root | Basalt Vine | Cinder Moss Spores | Construction material that is 3x stronger than standard magma root lumber |
| Ember Moss Carpet | Cinder Moss | Ember Wheat | Cinder Moss Spores | Bedding that raises comfort to maximum regardless of den quality |
| Cryo-Ash Repellent | Ash Fern | Coal Cap Mushroom | Lava Lotus Seeds | AoE frost blight repellent -- protects all dens in a zone for 3 days |

(Full 24 hybrids tracked in-game via flora codex with completion percentage.)

#### Frost Blight Event System

The frost blight is an advancing cold front that creeps toward the sanctuary from the mountain peaks. Its proximity is visible on a meter (0-100). At threshold values, events trigger:

| Frost Level | Event Type | Frequency | Player Response | Consequence of Failure |
|-------------|-----------|-----------|-----------------|----------------------|
| 20-39 | Frost Warning | Every 5-7 days | Check perimeter thermal barriers, reinforce weak zones | Minor -- some planters cool below minimum ember-degrees, slowing growth |
| 40-59 | Frost Creep | Every 3-5 days | Triage den heating priority, evacuate outer dens, deploy thermal barriers | Moderate -- outer dens drop to 50% comfort, owlbears gain stress, one planter may die |
| 60-79 | Frost Surge | Every 2-3 days | Full triage mode -- choose which 60% of dens to heat, which plants to sacrifice, send owlbears to inner sanctum | Significant -- unprotected dens damage, multiple plants lost, owlbear trust decreases |
| 80-95 | Frost Siege | 1-2 per season | Emergency protocol -- all resources diverted to thermal defense, player repairs channels in real-time while managing owlbear panic | Severe -- den structural damage requiring reconstruction, owlbears traumatized (trust resets by -15), rare flora permanently lost |
| 96-100 | Heart of Winter | Once per year (seasonal climax) | Narrative event -- player must use every defense, ally, and resource accumulated to protect the sanctuary's heart | No true failure -- the sanctuary always survives, but the cost varies dramatically based on preparation |

**Design principle:** Frost blight events never kill owlbears. The worst outcome is stress, trust loss, and structural damage. The cozy game contract is preserved while still creating genuine tension.

#### Den Building System

Dens are constructed from gathered materials in a grid-based placement system. Each den has temperature, comfort, capacity, and frost resistance stats.

| Den Type | Materials | Capacity | Comfort Bonus | Frost Resistance | Personality Suitability |
|----------|-----------|----------|---------------|-----------------|------------------------|
| Basalcove (starter) | 10 Basalt + 5 Cinder Moss | 1 owlbear | +5 | Low (10) | Timid, compliant -- enclosed, warm, simple |
| Obsidian Hollow | 15 Obsidian + 8 Magma Root + 5 Ash Fern | 2 owlbears | +10 | Medium (25) | Any -- the versatile mid-game den |
| Lava-Pool Lodge | 20 Obsidian + 10 Basalt Vine + 1 Lava Lotus | 2 owlbears | +20 (lava pool provides warmth) | High (40) | Brave, curious -- open layout with heated pool |
| Ember Nest | 15 Magma Root + 10 Ember Wheat Straw + 5 Cinder Moss | 3 owlbears | +15 | Medium (30) | High warmth -- communal nesting encourages social bonding |
| Geode Chamber | 25 Obsidian + 5 Iron Bloom + 5 Sulfur Orchid | 2 owlbears | +25 | Very High (60) | Stubborn -- crystalline walls absorb and radiate heat slowly, maintaining perfect temperature |
| Caldera Commune | 40 Magma Root + 20 Basalt Vine + 10 Iron Bloom | 6 owlbears | +30 | High (50) | Mixed -- large-capacity endgame den with multiple thermal zones for personality-specific microclimates |

### 5.3 Difficulty Progression

| Phase | Weeks | Owlbears Simultaneous | Frost Blight Level | Resource Pressure | Key Challenge |
|-------|-------|----------------------|--------------------|--------------------|---------------|
| Tutorial | 1 | 1 | None | Abundant -- tutorial supplies | Learning the care loop |
| Early | 2-6 | 2-3 | Warnings only (20-39) | Comfortable -- garden covers most needs | Time management, personality matching |
| Mid | 7-15 | 4-5 | Creep events (40-59) | Moderate -- must forage daily, budget den materials | Triage during frost events, cross-breeding for frost-resistant flora |
| Late | 16-25 | 6-8 | Surge events (60-79) | Tight -- thermal barrier fuel competes with garden heating | Multi-den heating priority, personality conflict mediation during stress |
| Endgame | 26+ | 8-12 | Siege events possible (80+) | Stabilized (established thermal network) | Preparing for annual Heart of Winter, legendary owlbear rehabilitation |

---

## 6. World Design

### Map Structure

The game world is a volcanic caldera with the sanctuary at its heart. Exploration zones radiate outward along thermal gradients.

```
                        +--------------------------+
                        |    FROZEN PEAKS           |
                        |    (Tier 4 unlock)        |
                        |    - Frost blight source  |
                        |    - Legendary rescues    |
                        +------------+-------------+
                                     |
                        +------------+-------------+
                        |    OUTER CRATER RIM       |
                        |    (Tier 3 unlock)        |
                        |    - Iron Bloom deposits  |
                        |    - Abandoned mining     |
                        |      tunnels              |
                        +------------+-------------+
                                     |
            +------------------------+------------------------+
            |                        |                        |
+-----------+----------+  +----------+-----------+  +---------+-----------+
|  WEST VENT FIELDS    |  |   SANCTUARY (Hub)    |  |  EAST THERMAL POOLS  |
|  (Tier 2 unlock)     |  |                      |  |  (Tier 2 unlock)     |
|  - Sulfur Orchid     |  |  - Dens              |  |  - Hot springs       |
|    wild growth       |  |  - Gardens           |  |  - Lava Lotus        |
|  - Basalt deposits   |  |  - Thermal Network   |  |    habitat           |
|                      |  |  - Workshop          |  |  - Mineral baths     |
+----------------------+  +----------+-----------+  +---------------------+
                                     |
                        +------------+-------------+
                        |    INNER CALDERA SLOPES   |
                        |    (Tier 1 -- starting    |
                        |     foraging zone)        |
                        |    - Firebloom meadows    |
                        |    - Obsidian outcrops    |
                        |    - Ember Wheat fields   |
                        +--------------------------+
```

### Sanctuary Expansion (Facility Tiers)

| Tier | Dens | Garden Planters | Foraging Zones | Frost Defenses | Visual Theme |
|------|------|-----------------|----------------|----------------|--------------|
| Ember (Start) | 1 basic basalcove | 4 planters | Inner Caldera Slopes | None -- frost has not arrived yet | Cracked obsidian floor, makeshift fence, warm campfire, handwritten sign reading "Sanctuary" |
| Cinder | 3 dens (any type) | 8 planters | + West Vent Fields | Basic thermal barriers (manual repair) | Stone paths, planter boxes, warm lantern lighting, first lava channel |
| Forge | 5 dens + communal area | 14 planters | + East Thermal Pools | Thermal vent network (auto-heating with fuel) | Brick paths, heated walkways, thriving garden sections, owlbear-proof fencing |
| Caldera | 8 dens + large communal lodge | 20 planters | + Outer Crater Rim | Frost-resistant perimeter wall, automated thermal channels | Polished basalt, ornate lava channels, owlbear-maintained garden sections |
| Mythic | 12 dens + geode great hall | 28 planters | + Frozen Peaks | Full caldera thermal network, frost blight research station | Grand volcanic architecture, living ecosystem, legendary owlbear residents, caldera glows with life |

### Art Direction Pillars

| Pillar | Description | Reference |
|--------|-------------|-----------|
| Smoldering Warmth | Color palette anchored in deep amber, burnt sienna, volcanic orange, and charcoal. Every scene glows with internal heat. No cold blues except during frost blight events, where blue is the invader. | Studio Ghibli's how-means-warmth palette (Spirited Away boiler room); warm campfire scenes in Breath of the Wild |
| Creature Character | Ember owlbears have feathers that genuinely smolder -- ember particles drift from wing tips, eyes glow like hot coals, beaks have a faint orange heat-haze. 10-14 emotion animations per personality state. | Pokemon Camp animations for expressiveness; Monster Hunter Palico personality range |
| Volcanic Sublime | The caldera is beautiful and dangerous. Lava flows are visually striking but contained. The environment communicates power under control -- the volcano is a partner, not a threat (until frost makes it falter). | Journey's environmental storytelling; Firewatch's use of warm light in vast landscapes |
| Lived-In Hearth | The sanctuary accumulates wear, decoration, and owlbear damage over time. Scratched posts, worn bedding, soot marks on den walls. No pristine environments -- the space looks inhabited and loved. | Stardew Valley farm progression; Animal Crossing player-generated lived-in spaces |
| Seasonal Fire | Four seasons shift the caldera's thermal behavior. Summer: lava channels run fast, flora grows rapidly, owlbears are most active. Winter: channels slow, frost blight threat peaks, dens need maximum heating. | Firewatch seasonal lighting shifts; Spiritfarer's gentle time passage |

### Audio Progression

| Game Phase | Music Style | Ambient Sounds | Creature Sounds |
|------------|------------|----------------|-----------------|
| Early (Ember) | Solo acoustic guitar with warm reverb, slow tempos | Crackling lava, distant rumbles, wind through crater | Soft hoots, timid chirps, ember crackle from feathers |
| Mid (Cinder-Forge) | Guitar + hand percussion, fuller arrangements | Added garden ambience (hissing steam from planters), owlbear activity | Confident calls, purring, personality-specific vocalizations emerge |
| Late (Caldera) | Folk ensemble with subtle strings, emotional crescendos | Full sanctuary ambience -- lava channels, multiple dens, visitor chatter | Rich vocal range, contented rumbling, legendary variant deep resonant calls |
| Endgame (Mythic) | Orchestral folk with volcanic percussion, occasional choir | Living caldera ecosystem, harmony of all thermal zones | Unique legendary owlbear songs -- deep, resonant, ancient |

---

## 7. Narrative

### Story Spine

| Beat | Story Point | Player Experience |
|------|-------------|-------------------|
| **Equilibrium** | You are a wilderness cartographer mapping the Greymaw Mountain range. During a survey, you discover an abandoned sanctuary built inside a dormant caldera -- stone dens, overgrown thermal gardens, and a single elderly ember owlbear named Cindermaw sitting by a dying lava channel. A journal on the workbench identifies the previous caretaker: Maren Ashveil, who vanished 12 years ago. | Tutorial phase. Cindermaw is the tutorial guide -- too old to rehabilitate, but his calm presence teaches the care loop. The player cleans one den, restarts the lava channel, and feeds Cindermaw his first warm meal in years. |
| **Inciting Incident** | A rockslide on the outer slopes reveals a frost-blighted cave with three juvenile ember owlbears huddled around a dying thermal vent. Their feathers have gone gray -- they are losing their fire. The player must bring them to the sanctuary and nurse them back to warmth. | First real rescue. Introduces the healing system, personality matrix (one brave, one timid, one curious), and the frost blight as antagonist. The gray-feathered juveniles create immediate emotional stakes. |
| **First Complication** | The frost blight is not natural. The player discovers Maren's journal entries describing a ritual performed by a group called the Winterwardens -- zealots who believe the mountains should be "returned to ice." They are accelerating the frost blight deliberately. | Introduces the central mystery. The journal fragments are scattered across caldera zones, found during foraging. Each fragment reveals more about the Winterwardens and Maren's disappearance. |
| **Rising Action** | As the sanctuary grows and more displaced owlbears arrive, the Winterwardens escalate. They dam thermal vents upstream, causing the caldera's lava channels to slow. Frost events increase in severity. The player must repair channels while caring for growing numbers of refugees. | Mid-game tension doubles. Resource pressure from frost events intersects with the caregiving loop. The player must balance defense investment with care quality. |
| **Midpoint Reversal** | Journal fragment 9 of 16 reveals Maren was once a Winterwarden. She built the sanctuary as atonement after participating in the ritual that created the frost blight decades ago. Cindermaw was her first rescue -- the owlbear she saved to prove to herself that warmth could overcome cold. | Emotional pivot. The sanctuary is not just a refuge -- it is an act of redemption. Cindermaw's presence gains new meaning. The player's work continues Maren's unfinished penance. |
| **Crisis** | The Winterwardens perform a Greater Frost Ritual at the mountain peak. The frost blight surges to Heart of Winter levels in the middle of summer. All sanctuary defenses are overwhelmed. The player must decide: evacuate the owlbears to a distant valley (abandoning the caldera and Maren's legacy) or attempt an impossible counter-ritual using the sanctuary's thermal network. | Highest stakes. The choice is real -- both paths lead to valid endings. The counter-ritual path requires every thermal channel, every frost-resistant plant, and every owlbear with trust > 75 to participate. Evacuation means losing the sanctuary but saving every creature. |
| **Climax** | If counter-ritual: The player and the bonded owlbears channel the caldera's geothermal energy upward, meeting the frost at the crater rim. Cindermaw, ancient and failing, walks to the rim and unleashes the last of his ember -- a blaze of warmth that shatters the frost ritual. He collapses, content. If evacuation: The player leads the owlbears through blinding frost down the mountain, shielding them with thermal barriers. They find a new volcanic vent in the distant valley. The sanctuary is rebuilt from scratch, carrying Cindermaw's memory. | Dramatic payoff of all mechanical and narrative systems. Cindermaw's fate is the emotional anchor -- in both paths, he sacrifices his remaining warmth. The difference is whether the caldera is saved or abandoned. |
| **Resolution** | The frost blight recedes. Whether in the original caldera or the new valley, the sanctuary thrives. Ember owlbears from across the mountains find their way to its warmth. A new generation of owlbears is born in the sanctuary -- the first with feathers that glow brighter than their parents', adapted to a world where frost and fire coexist. Cindermaw's stone memorial sits at the sanctuary entrance, always warm to the touch. | Bittersweet ending. Loss is real (Cindermaw, and potentially the original caldera), but the sanctuary endures. Player can continue in sandbox mode with post-game owlbear arrivals and seasonal challenges. |

### Tone Spectrum (7 Axes)

| Axis | Value (1-7) | Notes |
|------|-------------|-------|
| Whimsical vs. Grounded | 4 | Magical creatures and volcanic gardening, but rehabilitation mechanics and frost blight are treated with real emotional weight |
| Lighthearted vs. Melancholic | 3 | Predominantly warm and hopeful; melancholy surfaces in Cindermaw's aging, Maren's disappearance, and the gray-feathered juveniles |
| Cozy vs. Tense | 2 | Daily loop is meditative; tension is episodic (frost events) and narrative (Winterwarden escalation), never constant |
| Simple vs. Complex | 4 | Accessible surface (feed, heal, build), deep systems underneath (personality matrices, cross-breeding, thermal network management) |
| Peaceful vs. Challenging | 3 | No fail states that lose creatures; challenge is optimization, triage, and emotional investment in narrative outcomes |
| Optimistic vs. Bittersweet | 4 | Hopeful core -- warmth always wins -- but loss and impermanence are real (Cindermaw, Maren, displaced creatures) |
| Individual vs. Communal | 5 | Strong individual owlbear stories within a sanctuary community; the communal den system makes group dynamics central |

### Key Characters

| Character | Role | Theme | Story Fragments | Creature Connection |
|-----------|------|-------|-----------------|-------------------|
| Cindermaw | Elder ember owlbear, tutorial guide, emotional anchor | Aging, legacy, sacrifice | 8 fragments revealed through daily care over the tutorial phase | The player's first bond. Too old to rehabilitate, he is the sanctuary's soul. His final sacrifice is the narrative climax. |
| Maren Ashveil (journals) | Previous caretaker, former Winterwarden | Atonement, transformation, the weight of past harm | 16 fragments scattered across all caldera zones | Her journal teaches care techniques, reveals the frost blight's origin, and provides thermal network schematics |
| Caldera (the volcano) | Environment as character | Nature as partner, not resource | Geothermal events, lava channel behavior changes, rumbling dialogue through haptic feedback | The volcano's health directly determines sanctuary viability; when frost slows its channels, the player feels the mountain "struggling" |
| Veyra Frostborne | Winterwarden leader, antagonist | Fanaticism, fear of fire, misguided ecological ideology | 10 fragments through intercepted Warden messages and encountered ritual sites | Never directly confronted in combat; the player defeats her ideology by proving coexistence works |
| Ashpaw | Brave juvenile from the first rescue | Recovery, courage, loyalty | 6 fragments as trust grows -- the first owlbear to regain full ember coloring | Becomes the de facto leader of rescued juveniles; leads owlbears during counter-ritual climax if trust is sufficient |
| Soot | Timid juvenile from the first rescue | Vulnerability, patience, quiet strength | 6 fragments -- the last to regain color, but the most affectionate once bonded | High Warmth + Low Bravery makes Soot the emotional barometer of the sanctuary's health |
| Brimstone | A legendary elder ember owlbear found frozen in the Outer Crater Rim (Tier 4) | Ancient wisdom, dormancy, resurgence | 10 fragments -- Brimstone remembers the mountains before frost, and knows why the Winterwardens fear fire | Endgame rehabilitation challenge: Brimstone has 5 trauma markers, the highest of any creature, and recovering all triggers the final lore reveal |

---

## 8. Player Personas

### P-002: Sarah Chen -- "The Micro-Gamer"

| Aspect | Analysis |
|--------|----------|
| **Why this fits** | Sarah plays in 15-20 minute bursts 4-5 times daily. The daily care loop in Ember Owlbear Sanctuary maps directly to this pattern: one in-game day takes 20-35 minutes, and each phase (feeding, gardening, bonding) can stand alone as a satisfying micro-session. The creature designs are intentionally adorable -- ember owlbears with glowing feathers, purring warmth, individual personalities -- matching Sarah's gacha-driven aesthetic attraction without the predatory monetization she hates. |
| **Predicted experience** | Sarah plays 1-2 in-game days per real day, spreading sessions across breaks. She gravitates toward the cutest owlbears (juveniles, high-Warmth personalities) and invests in making their dens beautiful. She ignores optimization -- feeding whatever food is available, building dens that look nice rather than min-maxed. She will become deeply attached to Soot. She will cry during Cindermaw's sacrifice. |
| **What she loves** | The creature designs and animations, the daily routine rhythm, the volcano garden aesthetic, the absence of energy systems or timers, offline play during soccer practice |
| **What she skips** | Cross-breeding optimization, thermal network management, frost defense triage min-maxing |
| **Monetization** | Premium purchase. Will buy cosmetic den decoration packs if they make her owlbears' homes prettier. Will NOT buy gameplay-affecting DLC. |

### P-003: Hiroshi Tanaka -- "The RPG Addict"

| Aspect | Analysis |
|--------|----------|
| **Why this fits** | Hiroshi is a completionist who treats every game as a mastery project. The game offers 48 flora species (12 base + 24 hybrids + 12 rare variants), 42 unique owlbear personality pairings to discover, a 16-fragment journal lore collection, and a 5-tier facility progression with clear milestones. The personality matrix system has enough depth for theorycrafting -- optimal den assignments, feeding strategies, and social compatibility maximization. |
| **Predicted experience** | Hiroshi plays one focused 40-minute session daily, systematically working through each progression axis. He creates external spreadsheets tracking personality pairings, cross-breeding recipes, and optimal frost defense configurations. He treats the flora codex as a completion puzzle and the personality network as a social engineering challenge. He 100%s the game before moving on. |
| **What he loves** | The personality matrix depth, 24 cross-breed recipes as discovery puzzles, the flora codex completion percentage, clear facility tier requirements |
| **What he skips** | The emotional narrative beats (reads once, moves on), den decoration for aesthetics alone |
| **Monetization** | Premium purchase. Will buy any DLC that adds new flora species, owlbear variants, or codex entries to complete. |

### P-006: Eleanor Vance -- "The Loyal Strategist"

| Aspect | Analysis |
|--------|----------|
| **Why this fits** | Eleanor plays 2-3 hours daily in morning and evening sessions. She loves systems she can master over months. The thermal network management, frost blight defense planning, and personality-den optimization offer the strategic depth she craves. The premium model with no energy systems, no timers, and no pay-to-win mechanics aligns with her fixed-income budget and anti-predatory stance. |
| **Predicted experience** | Eleanor plays 3-4 in-game days per real day, split between morning coffee sessions and evening wind-down. She treats the sanctuary as a long-term optimization project -- carefully planning thermal network layouts, scheduling frost defense upgrades months in advance, and tracking personality pairings across generations of owlbears. She reads every journal fragment in order and pieces together the mystery methodically. She plays for 12+ months. |
| **What she loves** | The thermal network system, frost blight defense planning, personality compatibility matrix, Maren's journal as a mystery to solve, premium pricing with no hidden costs |
| **What she skips** | Den decoration, cosmetic purchases |
| **Monetization** | Premium purchase. May buy DLC if it adds strategic depth (new frost event patterns, new personality traits). Will not buy cosmetics. Will recommend to her strategy gaming community, driving word-of-mouth. |

### P-013: Robert Thompson -- "The Relaxation Player"

| Aspect | Analysis |
|--------|----------|
| **Why this fits** | Robert needs mindless, pressure-free gameplay to decompress after 12-hour workdays. The daily care loop is explicitly meditative -- feeding, healing, observing owlbears requires no competitive thinking. Frost blight events can be set to "relaxed mode" (reduced frequency, no time pressure, purely cosmetic stress effects). The warm amber palette and crackling lava ambience reinforce relaxation. No timers, no fail states that lose anything meaningful. |
| **Predicted experience** | Robert plays 1 in-game day per night before sleep. He focuses on the bonding phase -- sitting near owlbears, watching their feathers glow, listening to their purring. He lets the garden grow untended some days and does not care about optimal yields. He turns on relaxed frost mode and ignores the Winterwarden plot entirely. He plays for 9+ months. |
| **What he loves** | The bonding phase, the warm visual palette, the lava crackle ambience, the absence of countdown timers, the option to disable frost event pressure |
| **What he skips** | Frost blight defense, thermal network management, journal mystery, any system requiring planning |
| **Monetization** | Premium purchase only. Will never buy DLC. One of the rare games he keeps installed permanently. |

---

## 9. User Stories

### Exploration

1. As a player (P-003), I want to explore all 6 caldera foraging zones and see a completion percentage for each so that I can track which zones I have fully harvested and which still have hidden deposits.
2. As a player (P-002), I want to discover hidden hot springs during foraging by following subtle steam visual cues so that exploration feels rewarding without requiring a guide.
3. As a player (P-013), I want foraging zones to have no enemies, no fall damage, and no time limits so that I can explore at my own pace without anxiety.
4. As a player (P-006), I want the geothermal vent map to show real-time thermal flow data so that I can strategically plan which zones to forage based on resource respawn rates.

### Core Mechanics -- Creature Care

5. As a player (P-002), I want to prepare meals for my owlbears by dragging ingredients into a heated cooking pot with visible steam and bubbling so that feeding feels interactive and cozy, not menu-driven.
6. As a player (P-003), I want the personality matrix displayed as a visual radar chart (4 axes: bravery, curiosity, stubbornness, warmth) so that I can compare owlbears at a glance and plan optimal den assignments.
7. As a player (P-013), I want the bonding phase to have no failure condition -- only varying degrees of success reflected in the owlbear's animation -- so that I never feel punished for engaging with it.
8. As a player (P-002), I want owlbears to visibly respond to care with personality-specific animations (a brave owlbear puffing its chest, a curious one tilting its head, an affectionate one leaning into my hand) so that I can read their emotional state without checking menus.
9. As a player (P-003), I want the trust gain formula shown in the journal so that I can mathematically optimize my care routine and understand exactly why trust is or is not increasing.
10. As a player (P-002), I want to name each owlbear and have that name appear in all journal entries, den labels, and status board listings so that I feel personal ownership of the relationship.

### Core Mechanics -- Volcano Gardening

11. As a player (P-003), I want the flora codex to show discovered species as filled illustrations and undiscovered species as silhouettes so that I always know how many hybrids remain (e.g., "18/24 hybrids discovered").
12. As a player (P-006), I want cross-breeding to follow logical rules (temperature overlap, catalyst requirements) that I can deduce from journal hints rather than random guessing so that the system rewards strategic thinking.
13. As a player (P-002), I want successful cross-breeds to trigger a celebratory animation (the hybrid plant blooms with a burst of ember particles) so that the discovery feels exciting and shareable.
14. As a player (P-013), I want plants that fall below minimum ember-degrees to visibly wilt and change color before dying so that I have time to save them without sudden loss.

### Core Mechanics -- Frost Blight Defense

15. As a player (P-006), I want the frost blight proximity meter to show projected advance rates based on current thermal network status so that I can plan defenses days in advance.
16. As a player (P-013), I want a "relaxed mode" toggle that reduces frost event frequency by 50% and removes all time pressure during events so that I can enjoy the cozy loop without stress spikes.
17. As a player (P-002), I want successful frost defenses to trigger a visual celebration (the frost retreats with visible cracking ice, owlbears emerge and stretch in the restored warmth) so that the payoff feels earned and joyful.
18. As a player (P-003), I want frost defense results to show a breakdown of what was protected and what was lost so that I can improve my triage strategy for next time.

### Narrative

19. As a player (P-003), I want Maren's 16 journal fragments to be discoverable in sequence tied to caldera zone progression so that the mystery unfolds at a pace I control through exploration.
20. As a player (P-002), I want Cindermaw to occasionally offer care advice through animated thought-bubble sequences with warm ember particles so that I feel a connection to the elder owlbear during routine gameplay.
21. As a player (P-006), I want the Winterwarden plot to be resolvable through environmental evidence and journal deduction rather than combat so that the mystery rewards patience and analysis.
22. As a player (P-013), I want narrative scenes to progress through gentle dialogue that I can read at my own pace without timed choices so that story moments remain relaxing.
23. As a player (P-003), I want the choice between counter-ritual and evacuation to have clear mechanical consequences documented in advance so that my decision is informed, not arbitrary.

### Progression and Sanctuary Management

24. As a player (P-003), I want each sanctuary tier to have a visible checklist of requirements (dens built, owlbears rehabilitated, flora discovered) so that I always know exactly what I need to reach the next tier.
25. As a player (P-002), I want to place decorative items in dens and see owlbears interact with them (sleeping on decorative blankets, playing with hanging ornaments) so that I can customize for visual satisfaction.
26. As a player (P-006), I want the thermal network to show heat flow visualization (lava channel speed, vent output, frost penetration depth) so that I can manage it as a strategic system.
27. As a player (P-013), I want sanctuary management to have an "auto-suggest" mode that recommends den upgrades based on current owlbear needs so that I do not have to analyze optimization myself.

### Accessibility

28. As a player (P-018), I want all owlbear status information presented through both visual indicators (glowing feathers, animation states) and text labels so that I can access information regardless of vision level.
29. As a player (P-019), I want the game to be fully playable offline with all features accessible without internet so that I can play in areas with limited connectivity.
30. As a player (P-020), I want full localization in Japanese with culturally appropriate creature names and personality trait labels so that I can experience the game in my native language.
31. As a player (P-015), I want a "family mode" toggle that simplifies thermal management and removes the Winterwarden plot so that younger children can focus on owlbear care without exposure to antagonist themes.

### Release and Endgame

32. As a player (P-002), I want the choice to release or keep a rehabilitated owlbear to trigger a cinematic farewell scene (released owlbear flies over the caldera rim, visible as a distant ember in future sunsets) so that the decision carries emotional weight.
33. As a player (P-003), I want a sanctuary statistics screen showing total owlbears rehabilitated, released, kept, flora species discovered, and frost defenses survived so that I can track overall career achievements.
34. As a player (P-006), I want released owlbears to occasionally reappear during caldera exploration as wild encounters with boosted stats and visible ember coloring so that past care decisions have lasting world impact.

---

## 10. Monetization

### Model: Premium + Cosmetic Den Decoration Packs

**Why premium fits this game:**

- The cozy simulation audience (Stardew Valley, Slime Rancher, Animal Crossing, Spiritfarer) overwhelmingly prefers premium models over F2P
- The rehabilitation theme is antithetical to predatory monetization -- paywalling frost defense or charging to speed up owlbear healing would directly contradict the game's message about patience and care
- Sarah (P-002) is actively frustrated by energy systems; Robert (P-013) abandons games with pressure mechanics; Eleanor (P-006) rejects pay-to-win immediately
- Premium allows full offline play, serving P-019 (low bandwidth) and the cozy "play anywhere" ethos
- Cosmetic packs let aesthetically motivated players (Sarah, casual decorators) spend more without affecting gameplay balance

### Pricing

| Product | Price | Contents |
|---------|-------|----------|
| Base Game | $19.99 | Full game: 12 base owlbear variants + 6 legendary variants, 48 flora species, 6 caldera zones, complete story (both endings), sandbox mode |
| Den Decor Pack: Hearthside | $4.99 | 24 decorative items -- woven blankets, ember-glass lanterns, obsidian wind chimes, carved perches. No gameplay effect. |
| Den Decor Pack: Wilds | $4.99 | 24 decorative items -- volcanic rock formations, crystallized lava formations, hot-spring fountain, ash-garden sculpture. No gameplay effect. |
| Den Decor Pack: Celestial | $4.99 | 24 decorative items -- starlight canopy, moonstone basin, aurora feather mobile, ember constellation map. No gameplay effect. |

### Revenue Projections (4 Scenarios)

| Scenario | Year 1 Units | Year 1 Revenue | Year 2 Units | Year 2 Revenue | DLC Attach Rate | Total 2-Year |
|-----------|-------------|----------------|-------------|----------------|-----------------|--------------|
| Modest | 12,000 | $239,880 | 6,000 | $119,940 | 12% | $399,036 |
| Expected | 40,000 | $799,600 | 22,000 | $439,780 | 22% | $1,407,844 |
| Strong | 100,000 | $1,999,000 | 60,000 | $1,199,400 | 30% | $3,678,340 |
| Breakout | 300,000 | $5,997,000 | 180,000 | $3,598,200 | 38% | $11,314,092 |

**Assumptions:** Steam/Sony 70% rev share (after 30% platform cut). Nintendo eShop 75% (after 25% cut). Mobile stores 70%. DLC revenue calculated at weighted average price of $4.99 per pack, with attach rate representing players who buy at least 1 pack. Year 2 includes base game long-tail sales + DLC + word-of-mouth.

### DLC Release Roadmap

| Timing | Pack | Rationale |
|--------|------|-----------|
| Month 2 post-launch | Hearthside Decor Pack | Early cosmetic option for invested players who want to personalize dens |
| Month 4 post-launch | Wilds Decor Pack | Second pack for continued engagement, nature-themed items match mid-game caldera exploration |
| Month 7 post-launch | Celestial Decor Pack | Holiday season release, celestial theme aligns with winter solstice and in-game Heart of Winter season |
| Month 10 post-launch | Potential gameplay DLC (evaluated based on sales and community demand) | If base game exceeds Expected scenario, develop a new caldera zone with 3 new owlbear variants and 6 new flora species at $9.99 |

---

## 11. Production Plan

### Team

| Role | Count | Phase(s) | Monthly Cost | Notes |
|------|-------|----------|--------------|-------|
| Creative Director | 1 | Pre-prod through launch | $9,000 | Leads vision, narrative, volcanic ecology design |
| Lead Designer | 1 | Pre-prod through launch | $8,000 | Core loop, personality matrix, frost event system |
| Game Designer (Junior) | 1 | Production through launch | $4,800 | Den building system, gardening mechanics, cross-breeding rules |
| Lead Programmer | 1 | Pre-prod through launch | $9,500 | Architecture, thermal network simulation, cross-platform |
| Gameplay Programmer | 2 | Production through launch | $7,200 each | Creature personality AI, care systems, frost event logic |
| UI Programmer | 1 | Production through launch | $6,500 | Status board, journal, flora codex, accessibility |
| Art Director | 1 | Pre-prod through launch | $8,000 | Smoldering warmth palette, creature design language |
| 2D Artist (Creatures) | 2 | Production through launch | $6,200 each | 18 owlbear variants x 10-14 personality animations each |
| 2D Artist (Environments) | 1 | Production through launch | $6,200 | Caldera zones, sanctuary tiers, lava channel visuals |
| 3D Environment Artist | 1 | Production through launch | $7,000 | Volcanic terrain, den structures, geothermal effects |
| Technical Artist | 1 | Production through launch | $7,000 | Ember particle systems, lava shader pipeline, optimization |
| Composer | 1 | Production through polish | $5,500 | Seasonal acoustic music, volcanic percussion |
| Sound Designer | 1 | Production through polish | $5,000 | Lava ambience, creature vocalizations, frost crackling |
| Narrative Designer | 1 | Pre-prod through production | $6,500 | Story spine, journal fragments, Winterwarden plot, Cindermaw arc |
| QA Lead | 1 | Alpha through launch | $5,000 | Test planning, personality matrix edge cases, frost event balancing |
| QA Tester | 1 | Alpha through launch | $3,800 | Daily testing, cross-platform regression |
| Producer | 1 | Full project | $7,500 | Scheduling, scope management, platform relations |
| Community Manager (PT) | 0.5 | Beta through post-launch | $2,800 | Discord, social media, player feedback |

**Total team: 20 FTE | Monthly burn: ~$133,500**

### Timeline

| Month | Phase | Milestone | Deliverables |
|-------|-------|-----------|-------------|
| 1-2 | Pre-Production | Vertical Slice | Core loop prototype, 2 owlbear variants fully playable (brave + timid), volcano gardening with 4 base plants, art style locked, thermal network proof-of-concept |
| 3-4 | Pre-Production | Design Complete | Full design document, all 18 owlbear variants designed, personality matrix finalized, frost blight event catalog, story spine + all 16 journal fragments written |
| 5-8 | Production Alpha | Feature Complete | All creatures playable, 6 caldera zones, sanctuary tiers 1-5, gardening with all 48 flora species, frost blight event system, den building |
| 9-11 | Production Alpha | Content Complete | All personality pairings (42), both narrative endings, Cindermaw arc, all voice/text, full journal, 3 cosmetic decor packs designed |
| 12-14 | Beta | Content Lock | Bug fixing, balancing trust gain rates and frost event difficulty curves, platform certification prep, QA regression |
| 15-16 | Polish | Release Candidate | Performance optimization (30fps Switch, 60fps PC/PS5), localization for 6 languages, accessibility audit, relaxed mode tuning |
| 17 | Launch | Gold Master | Day-1 patch, marketing push, press copies, console cert complete |
| 18-19 | Post-Launch | DLC 1 + 2 | Hearthside Decor Pack (month 18), Wilds Decor Pack (month 19), bug fixes from player reports |
| 20-22 | DLC Support | Celestial Decor Pack + Gameplay DLC evaluation | Celestial Pack (month 20), evaluate gameplay DLC based on sales data (month 22) |

### Budget Breakdown

| Category | Amount | % of Total | Notes |
|----------|--------|------------|-------|
| Salaries (16 months x 20 FTE) | $2,136,000 | 73.5% | Core team compensation |
| Software and Tools | $32,000 | 1.1% | Unity Pro, Figma, Jira, GitHub, localization tools |
| Art Outsourcing | $100,000 | 3.4% | Additional owlbear animation frames, volcanic environment detail work |
| Audio Outsourcing | $40,000 | 1.4% | Studio recording for volcanic percussion, foley for lava ambience |
| QA and Testing | $40,000 | 1.4% | Device lab, accessibility audit, platform compliance testing |
| Localization | $55,000 | 1.9% | 5 additional languages (JP, ZH, ES, FR, DE) |
| Marketing | $200,000 | 6.9% | Trailers, PR, influencer outreach, cozy game community engagement |
| Platform Fees | $30,000 | 1.0% | Steam Direct, console dev kits, PS5 cert, age rating submissions |
| Contingency (15%) | $430,500 | 14.8% | Buffer for scope adjustments and unexpected costs |
| **Total** | **$3,063,500** | **100%** | |

**Break-even at approximately 153,000 units** (base game only at $19.99, after platform cut). With cosmetic DLC attach at 22%, break-even drops to approximately 124,000 units.

---

## 12. Technical Requirements

### Platform Specifications

| Spec | PC (Min) | PC (Rec) | Nintendo Switch | PlayStation 5 | iOS | Android |
|------|----------|----------|-----------------|---------------|-----|---------|
| OS | Windows 10 64-bit | Windows 11 64-bit | Switch OS | PS5 OS | iOS 15 | Android 11 |
| CPU | Intel i3-8100 / AMD Ryzen 3 2200G | Intel i5-10400 / AMD Ryzen 5 3600 | ARM Cortex-A57 | AMD Zen 2 8-core | A12 Bionic | Snapdragon 730 |
| RAM | 4 GB | 8 GB | 4 GB | 16 GB | 3 GB | 4 GB |
| GPU | Intel UHD 630 / AMD Vega 8 | NVIDIA GTX 1060 / AMD RX 580 | Integrated | AMD RDNA 2 | GPU Sandbox | Adreno 618 |
| Storage | 4 GB | 4 GB SSD | 3.5 GB | 4 GB | 2.5 GB | 2.5 GB |
| Target FPS | 30 | 60 | 30 | 60 | 30 | 30 |
| Resolution | 720p | 1080p | 720p handheld / 1080p docked | 4K (dynamic) | Native | Native |
| Input | Keyboard/Mouse | KB/M + Controller | Joy-Con/Pro | DualSense | Touch | Touch |

### Key Technical Challenges

| Challenge | Risk | Mitigation |
|-----------|------|------------|
| **Personality Matrix AI** | 18 owlbear variants x 4 personality axes x 10-14 animation states = complex behavior matrix. Each owlbear must respond to player, environment, frost events, and other owlbears simultaneously while maintaining consistent personality expression. | Build modular behavior tree per personality trait. Each trait operates as an independent behavior modifier applied to a base owlbear AI. Compose traits at runtime: Bravery modifies approach/retreat thresholds, Curiosity modifies investigation frequency, Stubbornness modifies care acceptance probability, Warmth modifies proximity-seeking weight. Test with 4 variants (one per dominant trait) at month 3 to validate architecture. |
| **Thermal Network Simulation** | The sanctuary's heating system is a real-time fluid simulation -- lava channels flow through pipes, temperature distributes across zones, frost penetration is a competing cold-front simulation. Must be visually readable and mechanically functional simultaneously. | Use a simplified grid-based thermal diffusion model (not full Navier-Stokes). Each grid cell holds a temperature value; heat flows to adjacent cells based on conductivity. Lava channels are constant heat sources; frost blight is a cold boundary condition. Visual overlay is a color gradient. Runs on a separate thread at 10Hz (10 updates per second), which is sufficient for cozy-game pacing. |
| **Cross-Breeding Discovery System** | 24 hybrid combinations must feel discoverable through observation and logic, not random guessing. The system must prevent brute-force attempts from being efficient while rewarding systematic experimentation. | Implement a hint system tied to the journal: harvesting parent species A while adjacent to species B adds a "compatibility note" to the journal if the pair is valid. Players who read these notes can deduce catalyst requirements. Invalid combinations produce a distinct "wilt" animation. No random rolls -- valid combinations always produce the hybrid if conditions are met. |
| **Ember Particle Performance** | Each owlbear emits 15-30 ember particles continuously from feathers. With 12 owlbears on screen (endgame), that is 180-360 simultaneous particle systems, plus lava channel particles, plus frost particles during events. | Implement a particle budget system: max 500 active particles across all sources. Owlbears reduce particle count when camera is distant (5 particles). Lava channels use GPU-instanced quads, not individual systems. Frost particles during events temporarily reduce owlbear particle count. Profiling target: 60fps PC/PS5, 30fps Switch/mobile with 8 active owlbears. |
| **Cross-Platform Save Sync** | Players switching between platforms expect seamless progression. Save data includes sanctuary state, all owlbear personality matrices, garden state, thermal network configuration, journal progress, and decoration placement. | Implement cloud save via platform-native APIs. Save format is JSON with version migration system. All creature state serialized as personality trait scores + trust values + care history -- no procedural state that could drift between platforms. Offline-first design; cloud sync is additive, not required. |
| **Switch Port Memory** | Switch has 4 GB shared RAM. With OS overhead, approximately 2.5 GB available. Must fit full sanctuary scene (8 dens, thermal simulation, particle systems, 6 owlbears with AI) in memory. | Dedicated memory profiling from month 8. Switch runs at reduced texture resolution (half of PC), simplified particle effects (max 8 particles per owlbear instead of 15-30), and thermal simulation grid at half resolution. Den interiors stream in/out as player enters/exits. Target: max 1.9 GB active memory. |

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
|  | - Rendering    |  | - Personality  |  | - Save/Load    | |
|  | - UI/UX        |  |   Matrix AI    |  | - Flora Codex  | |
|  | - Audio        |  | - Care System  |  |   Database     | |
|  | - Particles    |  | - Thermal      |  | - Config       | |
|  |   (Ember/Frost)|  |   Simulation   |  | - Localization | |
|  | - Camera       |  | - Garden       |  | - Journal      | |
|  |                |  |   Manager      |  |   Records      | |
|  |                |  | - Den Builder  |  | - Personality  | |
|  |                |  | - Frost Event  |  |   Templates    | |
|  |                |  |   Director     |  |                | |
|  |                |  | - Narrative    |  |                | |
|  |                |  |   Engine       |  |                | |
|  +----------------+  +----------------+  +----------------+ |
|                                                             |
|  +-------------------------------------------------------+ |
|  |              PLATFORM ABSTRACTION                      | |
|  |  - Input (KB/M, Touch, Controller, DualSense haptic)  | |
|  |  - Cloud Save (Steam, PS Plus, iCloud, Google Play)   | |
|  |  - Platform Events (Achievements, Notifications)      | |
|  +-------------------------------------------------------+ |
+-------------------------------------------------------------+
```

### Build and Deployment

| Platform | Build System | CI/CD | Certification |
|----------|-------------|-------|---------------|
| PC (Steam) | Unity Cloud Build + Steamworks SDK | GitHub Actions: build on tag, auto-deploy to Steam branches | Steam Direct review (~3 days) |
| Nintendo Switch | Unity Switch module + Nintendo SDK | Local build (Nintendo dev hardware required) | Lotcheck submission (~4 weeks) |
| PlayStation 5 | Unity PS5 module + PlayStation SDK | GitHub Actions -> PS5 dev kit -> submission | Sony submission (~3 weeks) |
| iOS | Unity Cloud Build + Xcode | GitHub Actions -> TestFlight -> App Store Connect | App Store review (~2 days) |
| Android | Unity Cloud Build + Gradle | GitHub Actions -> Google Play Console | Google Play review (~3 days) |

### Post-Launch Technical Commitments

| Commitment | Duration | Scope |
|-----------|----------|-------|
| Critical bug fixes | 12 months post-launch | Crashes, save corruption, progression blockers, personality matrix edge cases |
| Platform compatibility updates | 12 months post-launch | New iOS/Android versions, Steam Deck verification, PS5 Pro enhancement patch |
| Cosmetic DLC packs | 10 months post-launch (quarterly) | 3 decoration packs, no gameplay code changes |
| Community-requested features | 6 months post-launch | Quality-of-life improvements based on player feedback |
| Relaxed mode tuning | 3 months post-launch | Balance frost event difficulty based on player feedback from P-013 archetype users |

---

*Ember Owlbear Sanctuary -- Warmth remembers what frost would forget.*
