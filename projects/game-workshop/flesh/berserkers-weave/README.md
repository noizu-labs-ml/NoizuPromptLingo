# Berserker's Weave

## 1. Title & Genre

| Field | Value |
|-------|-------|
| **Title** | Berserker's Weave |
| **Genre** | Strategy RPG / Tactical Grid Combat |
| **Subgenre** | Roguelite campaign with permanent loss |
| **Engine** | Unity 2023 LTS (URP) — mature 2D/3D hybrid pipeline, strong grid combat plugin ecosystem, proven cross-platform deployment |
| **Platforms** | PC (Steam), PlayStation 5, Xbox Series X/S |
| **Monetization** | Premium ($39.99 base), paid expansion campaigns, cosmetic skin packs |
| **Rating** | T (Teen) — Violence, Mild Blood, Strategic Complexity |
| **Target Session** | 30-60 minutes tactical, 60-90 minutes strategic |
| **Language** | English, Japanese, Korean, French, German, Spanish, Simplified Chinese at launch |

---

## 2. Vision Statement

Berserker's Weave is a tactical RPG about commanding warriors who grow stronger as they lose control. Every berserker in your warband carries a unique rage curve — a fingerprint of fury that makes them devastating and unpredictable. The player's job is not to prevent rage but to aim it. The game exists to explore a specific emotional space: the terror and exhilaration of wielding power you cannot fully contain. Between battles, the player weaves liberated stars into constellations — a meditative act of imposing order on chaos. The rhythmic alternation between fury and quiet, between loss and creation, gives Berserker's Weave a cadence unlike anything else in the tactics genre.

---

## 3. Core Loop

```
┌─────────────────────────────────────────────────────────┐
│                    STRATEGIC MAP                         │
│  Select star system → Plan constellation → Assign        │
│  berserkers → Manage trauma/scars → Weave bonuses        │
└──────────────────────┬──────────────────────────────────┘
                       │ Deploy warband to star
                       ▼
┌─────────────────────────────────────────────────────────┐
│                    TACTICAL BATTLE                       │
│  Grid deployment → Turn-based combat → Manage rage       │
│  curves → React to melody shifts → Complete objective    │
└──────────────────────┬──────────────────────────────────┘
                       │ Resolve battle
                       ▼
┌─────────────────────────────────────────────────────────┐
│                    AFTERMATH                              │
│  Assess casualties → Inherit scars → Collect loot        │
│  → Unlock constellation patterns → Return to map         │
└──────────────────────┬──────────────────────────────────┘
                       │ Cycle repeats
                       ▼
               [Back to Strategic Map]
```

### Detailed Breakdown

**Phase 1: Strategic Map (5-10 minutes)**
The player views the shattered constellation as a node graph. Each liberated star is a node; each connection is a supply line the player draws. The player selects the next star to assault, assigns 4-8 berserkers from their warband (max 16 active), positions them on the deployment grid, and reviews enemy composition. Constellation patterns the player has woven grant passive bonuses (e.g., a 5-star "Warrior" constellation grants +15% melee damage to all berserkers in the warband). The player also manages accumulated trauma — berserkers who survived previous battles carry rage residue that starts them at a higher baseline in the next fight.

**Phase 2: Tactical Battle (15-30 minutes)**
Combat takes place on an 8x10 grid. Each berserker acts once per turn, spending Action Points (2 AP per turn). Actions cost 1-2 AP. Every action (attacking, moving, taking damage) generates rage points on that berserker's personal rage track. As rage crosses thresholds (Calm → Simmer → Blaze → Inferno → Void), new abilities unlock but control diminishes. At Simmer, the berserker gains a damage bonus. At Blaze, they unlock their signature move. At Inferno, the player can only suggest a target — the berserker may obey, attack a nearby ally, or charge the nearest enemy regardless of orders. At Void, the berserker's rage overflows into adjacent tiles, dealing damage to all units (friendly and enemy) within 2 tiles.

The battlefield melody shifts every 3 turns, changing the elemental affinity of the map. Berserkers in Blaze rage or higher harmonize with the melody, producing an audible tone that reveals their rage state to observant opponents (critical in PvP).

**Phase 3: Aftermath (3-5 minutes)**
Casualties are tallied. Berserkers who reached Void state during battle gain a permanent trauma mark (max 3 before the berserker becomes unplayable — they "burn out" and are removed from the warband permanently). Berserkers who died in combat leave a crimson scar on the strategic map at the star where they fell. The player may assign one scar to a new recruit, granting that recruit a permanent buff derived from the fallen berserker's signature ability. Loot drops are determined by the constellation patterns in range of the captured star.

### Session Length Targets

| Session Type | Duration | Content Covered |
|--------------|----------|-----------------|
| Quick skirmish | 20-30 min | 1 battle + aftermath |
| Standard session | 45-60 min | Strategic planning + 1-2 battles + weaving |
| Deep session | 90-120 min | Full constellation restructure + 3 battles + recruitment |

---

## 4. Meta Loop

### What Carries Between Sessions

| Persistent Element | Description | Growth Feel |
|--------------------|-------------|-------------|
| **Constellation patterns** | 54 discoverable patterns across 6 families (Warrior, Scholar, Mimic, Warden, Drifter, Voidborn). Each requires specific star arrangements to activate. | Discovery-driven — the player feels clever for finding new patterns |
| **Warband roster** | Max 16 active berserkers from a pool of 32 recruitable archetypes. Each has a unique rage curve, signature ability, and trauma tolerance. | Collection + optimization — the player crafts a team identity |
| **Scar library** | Permanent buffs inherited from fallen berserkers. Max 3 scars per recruit. Each scar carries the name of the berserker who died. | Emotional permanence — loss becomes tangible power |
| **Trauma milestones** | Campaign-wide tracker of total rage generated, berserkers lost, scars inherited. Unlocks narrative vignettes and cosmetic titles. | Narrative payoff — the campaign remembers what happened |
| **Difficulty calibration** | After each campaign chapter (7 chapters), the player selects the next chapter's difficulty modifier from 3 options. This is the only adjustable difficulty point. | Agency — the player owns their challenge level |

### Progression Axes

```
┌────────────────────────────────────────────────────┐
│              PROGRESSION AXES                       │
├─────────────┬──────────────────────────────────────┤
│ BREADTH     │ More berserker archetypes discovered  │
│             │ More constellation patterns unlocked  │
│             │ Larger warband capacity (8 → 12 → 16) │
├─────────────┼──────────────────────────────────────┤
│ DEPTH       │ Berserker rage curves refined via     │
│             │ scar inheritance and trauma management│
│             │ Constellation patterns upgraded via   │
│             │ duplicate discovery (pattern mastery) │
├─────────────┼──────────────────────────────────────┤
│ MASTERY     │ Player knowledge of melody effects    │
│             │ Player skill at rage timing           │
│             │ Optimized constellation networks      │
│             │ (not a stat — purely player skill)    │
└─────────────┴──────────────────────────────────────┘
```

### Campaign Structure

| Chapter | Stars Available | New Mechanics Introduced | Berserker Archetypes Unlocked | Boss Encounter |
|---------|----------------|--------------------------|-------------------------------|----------------|
| 1: First Blood | 8 | Basic rage, movement, attacks | 4 (Vanguard, Sentinel, Pyre, Hollow) | Star-Eater Maw |
| 2: Simmer | 12 | Constellation weaving, melody shifts | 6 (+Drifter, Maven, Shatter, Thorne, Ash, Siren) | The Conductor |
| 3: Blaze | 16 | Scar inheritance, trauma management | 8 (+Rift, Bulwark, Ghost, Ember, Cinder, Solace, Viper, Echo) | The Hollow King |
| 4: Crossroads | 14 (branching) | Branching paths, supply line defense | 6 (path-dependent) | Player choice determines boss |
| 5: Inferno | 18 | Void state, berserker burnout | 4 (+Veil, fracture, Ruin, Omega) | The Mirror Warband |
| 6: Void | 20 | Enemy rage (enemies have rage curves too) | 4 (+Myth, Null, Apex, Zenith) | The Weeping Constellation |
| 7: Resolution | 22 | All systems at maximum complexity | 0 (final roster locked) | The Loom — a multi-phase encounter against the constellation itself |

Total: 32 recruitable archetypes across the campaign, but the player can only field 16. No grinding — archetype unlocks are story-gated, not repeat-grind gated.

---

## 5. Game Mechanics

### 5.1 Primary Mechanic: The Rage Matrix

Every berserker has a rage track with 20 rage points across 5 thresholds:

| Threshold | Rage Points | Effect | Player Control |
|-----------|-------------|--------|----------------|
| **Calm** | 0-3 | Normal abilities, no bonuses | Full control |
| **Simmer** | 4-7 | +20% damage, +1 movement tile | Full control |
| **Blaze** | 8-12 | Signature ability unlocked, +40% damage, +2 movement tiles | 85% control — berserker may reroute 1 tile toward nearest enemy |
| **Inferno** | 13-17 | Signature empowered, +70% damage, attacks hit adjacent tiles (friendly fire) | 50% control — player chooses from 2 targets (berserker picks one) |
| **Void** | 18-20 | Overflow: AoE pulse on every action, +100% damage, ignores armor | 0% control — berserker auto-attacks nearest unit every turn |

Rage generation per action:

| Action | Rage Generated |
|--------|----------------|
| Moving | +1 per 2 tiles moved |
| Attacking (melee) | +2 |
| Attacking (ranged) | +1 |
| Taking damage | +1 per 10 HP lost |
| Ally death within 3 tiles | +3 |
| Standing in melody zone | +1 per turn |
| Using a calming ability | -3 (only available at Calm/Simmer) |

**Rage Curves** modify these values per berserker archetype:

| Archetype | Curve Name | Behavior |
|-----------|-----------|----------|
| Vanguard | Flashpoint | +1 rage on all offensive actions, but rage decays by 2 per turn at Calm/Simmer |
| Sentinel | Slow Burn | Gains rage at half rate, but never loses rage — builds inevitably toward Blaze by turn 6-7 |
| Pyre | Nuclear | Gains rage at 2x rate, hits Void by turn 3-4 if unchecked, burns out at turn 8 |
| Hollow | Inverse | Starts at Blaze, loses rage through combat, wants to stay in Inferno range — Calm is dangerous |
| Drifter | Pendulum | Rage oscillates: gains 3 per turn, loses 3 per turn, alternating. Peaks every other turn |
| Maven | Sponge | Gains rage from taking damage at 3x rate, gains almost nothing from attacking |
| Shatter | Volatile | Random rage gain (1-5) on every action. Unpredictable. High ceiling, terrifying for planning |

The rage matrix is the single most important decision layer. The player reads the battlefield state, estimates how many turns remain, and decides which berserkers to push and which to restrain. A berserker at Void deals catastrophic damage but will hit allies and cannot be directed. The optimal play is to push a berserker to Void at the exact moment all allies are clear and enemies are clustered — a narrow window that rewards foresight.

### 5.2 Secondary Mechanic: Constellation Crafting

After capturing a star, the player may connect it to adjacent liberated stars via supply lines. Supply lines cost stellar dust (earned from battle objectives). When 3-7 connected stars form a recognized pattern, the constellation activates and grants a passive bonus.

**Pattern Families (54 total patterns, 9 per family):**

| Family | Bonus Type | Example Pattern (3-star) | Example Bonus |
|--------|-----------|--------------------------|---------------|
| Warrior | Melee damage | Triangle (3 stars) | +15% melee damage |
| Scholar | Ability cooldowns | Line (3 stars) | -1 turn cooldown on all abilities |
| Mimic | Loot randomization | Zigzag (4 stars) | 30% chance to duplicate any drop |
| Warden | Defense | Square (4 stars) | +20% armor to all berserkers |
| Drifter | Movement | Cross (5 stars) | +1 movement tile for all units |
| Voidborn | Rage manipulation | Spiral (7 stars) | All berserkers start battles at Simmer |

Patterns stack. A 5-star Warrior pattern and a 3-star Warrior pattern both apply their bonuses simultaneously. However, overlapping patterns (stars shared between two patterns) cost 50% more stellar dust to maintain. The player must decide between dense, overlapping networks for maximum bonuses or sparse, efficient networks for resource economy.

**Constellation destruction**: If an enemy faction recaptures a star, all patterns using that star are severed. The player loses those bonuses until the star is recaptured. This creates defensive pressure — the player must protect supply lines, not just conquer new territory.

### 5.3 Tertiary Mechanic: Melody Battlefields

Each tactical map has a melody — a sequence of 3-4 musical phrases that cycle every 3 turns. Each phrase has an elemental affinity:

| Affinity | Effect on Units | Visual Cue |
|----------|----------------|------------|
| Flame | +1 rage per turn to all units in fire-tinted tiles | Orange glow on affected tiles |
| Frost | -1 rage per turn, -1 movement tile in ice-tinted tiles | Blue crystalline overlay |
| Storm | Ranged attacks deal +25% damage in lightning tiles | Purple crackle arcs |
| Silence | No rage gain, no rage loss in white tiles | White mist, muted audio |

Berserkers at Blaze or higher harmonize with the current melody phrase, producing an audible musical tone. In PvP, this reveals their rage state to the opponent. In the campaign, this mechanic introduces an audio layer to tactical planning — the player listens to the battlefield as much as they watch it.

### 5.4 Difficulty Escalation

| Chapter | Enemy Count | Enemy Rage Access | New Enemy Types | Melody Complexity | Constellation Pressure |
|---------|-------------|-------------------|-----------------|-------------------|----------------------|
| 1 | 4-6 per battle | None | Grunt, Shieldbearer | Single phrase, no shifts | No enemy constellations |
| 2 | 6-8 | Grunts gain Simmer | +Archer, Healer | 2 phrases, shifts every 4 turns | Enemy starts capturing stars |
| 3 | 8-10 | Elite enemies at Blaze | +Berserker (enemy), War Drummer | 3 phrases, shifts every 3 turns | Enemy constellations appear |
| 4 | 8-12 | Full enemy rage curves | Chapter-dependent specials | 3 phrases, irregular shifts | Enemy constellations counter player patterns |
| 5 | 10-14 | Enemies can hit Void | +Void Cultist, Rage Leech | 4 phrases, environmental hazards | Enemy actively severs player supply lines |
| 6 | 12-16 | Enemies inherit scars too | +Scarred Veteran (enemy), The Hollow | 4 phrases, simultaneous dual melodies | Full constellation warfare |
| 7 | 14-20 | All systems at max | The Loom (boss entity with its own rage matrix) | Dynamic — melody responds to player rage states | Boss consumes player constellations |

### 5.5 Edge Cases and Constraints

- **Friendly fire is always on** at Blaze and above. The player cannot toggle it off. This is a core tension, not a difficulty option.
- **Void state ends combat** — if a berserker survives to the end of a battle while at Void, they lose 1 trauma mark (max 3). Void is risky but not automatic death.
- **Calming abilities exist** but are only usable at Calm/Simmer thresholds. The player must plan rage reduction proactively, not reactively.
- **No RNG in damage rolls**. All damage values are deterministic. The only randomness is in the Drifter and Shatter archetypes' rage generation, and in Mimic constellation loot effects. Tactical mastery is about managing known quantities, not gambling.
- **Dead berserkers stay dead**. No resurrection mechanics. The scar inheritance system is the only compensation for permanent loss. This is non-negotiable — it is the emotional core of the game.

---

## 6. World Design

### Map Structure

The game world is the Shattered Constellation — a star field rendered as an interconnected node graph. The player starts at the Anchor Star (tutorial zone) and expands outward. The map is hierarchical at the macro level (7 chapters, each a cluster of 8-22 stars) but fully interconnected at the micro level (within a chapter, any liberated star can connect to any adjacent star).

```
┌─────────────────────────────────────────────────────────┐
│                  SHATTERED CONSTELLATION                  │
│                                                          │
│    ★ Ch.7: Resolution (22 stars)                         │
│           │                                               │
│    ★ Ch.6: Void (20 stars)                               │
│      ┌────┼────┐                                         │
│  Ch.5A   Ch.5B  Ch.5C                                    │
│  Inferno  Inferno Inferno  ← branching after Ch.4        │
│      └────┼────┘                                         │
│    ★ Ch.4: Crossroads (14 stars, 3 paths)                │
│           │                                               │
│    ★ Ch.3: Blaze (16 stars)                              │
│           │                                               │
│    ★ Ch.2: Simmer (12 stars)                             │
│           │                                               │
│    ★ Ch.1: First Blood (8 stars)                         │
│           │                                               │
│    ★ The Anchor (tutorial + hub)                          │
└─────────────────────────────────────────────────────────┘
```

### Art Direction Pillars

| Pillar | Description | Implementation |
|--------|-------------|----------------|
| **Void as canvas** | The background is pure darkness — no nebulae, no galaxies. Stars and berserkers are the only light sources. | Black background (#0A0A0F), luminous entities with bloom post-processing |
| **Rage as light** | Berserkers emit more light as rage increases. Calm berserkers are dim silhouettes. Void berserkers are blinding. | Emissive materials scale with rage threshold, HDR bloom at Inferno/Void |
| **Scars as architecture** | Crimson scars left by fallen berserkers become permanent visual features of the strategic map. | Red line overlays on captured stars, glowing at the star where the berserker died |
| **Melody as space** | Battlefield tiles shift color and texture with melody changes. The battlefield breathes. | Tile tinting, particle effects, ambient animation synced to music tempo |
| **UI under stress** | The interface warps at high rage — text stretches, borders crack, health bars flicker. The game communicates berserker state through the UI itself. | Screen-space distortion shader, UI animation driven by highest rage state in the warband |

### World Progression Table

| Chapter | Star Color Palette | Berserker Visual Changes | Melody Instruments | Map Hazards |
|---------|-------------------|--------------------------|-------------------|-------------|
| 1 | Cool white, pale blue | Clean armor, steady glow | Soft piano, ambient hum | None |
| 2 | Pale gold, amber | Hair whitens at Simmer, eyes glow at Blaze | Strings join, tempo increases | Frozen star tiles (impassable without Drifter) |
| 3 | Warm orange, crimson | Cracks appear in armor at Blaze, light bleeds through at Inferno | Drums introduce rhythm | Collapsing star tiles (destroyed after 2 turns of occupancy) |
| 4 | Path-dependent (green/amber/violet) | Branch-dependent cosmetic variants | Path-specific instruments (flute, brass, synth) | Path-specific: gravity wells, mirrors, silence zones |
| 5 | Deep red, black, white | Void state: berserker becomes pure light silhouette | Full orchestra, discordant chords | Void zones (instant Inferno for any unit entering) |
| 6 | Desaturated, near-monochrome | Enemy berserkers mirror player's scars visually | Reverse melodies (played backward) | Enemy rage pulses (AoE rage damage every 3 turns) |
| 7 | Prismatic, all colors cycling | The Loom boss is a constellation given form | All instruments simultaneously, building to crescendo | The map itself reshapes every 4 turns |

### Audio Design

- **7 composers** — one per chapter, each scoring their chapter's melody battlefields in a distinct style while maintaining a shared thematic core (a 4-note motif that appears in every chapter's soundtrack)
- **Berserker harmonization** at Blaze+ uses the chapter composer's melody, transposed to the berserker's archetype key. Each archetype has a unique instrument voice (Vanguard = brass, Sentinel = strings, Pyre = distortion guitar, etc.)
- **3D positional audio** in tactical battles — berserker harmonization comes from the unit's grid position, giving the player spatial awareness of rage states without looking

---

## 7. Narrative

### Tone Spectrum (7 axes)

| Axis | Position | Description |
|------|----------|-------------|
| Hope ↔ Despair | Despair (7/10) | Loss is permanent, the world is broken, victories are costly |
| Order ↔ Chaos | Chaos (8/10) | Rage is entropy, the constellation is shattered, control is an illusion |
| Intimacy ↔ Scale | Intimacy (7/10) | Every berserker has a name, a history, and a death that matters |
| Clarity ↔ Ambiguity | Ambiguity (6/10) | The enemy's motives are unclear until Chapter 5; the Loom's nature is debated |
| Speed ↔ Patience | Patience (7/10) | Deliberate pacing, long strategic deliberation, calm between storms |
| Warmth ↔ Cold | Cold (8/10) | The void is cold, stars are distant, comfort is rare |
| Humor ↔ Gravity | Gravity (9/10) | Almost no comic relief. The scarred take nothing lightly |

### Story Spine (8-Point Structure)

| Beat | Chapter | Description |
|------|---------|-------------|
| **Equilibrium** | Ch.1 (first half) | The player commands a small warband hired to map the Shattered Constellation. Routine work — clear a few rogue star systems, map the terrain. The berserkers are mercenaries, not heroes. Rage is a tool, not a problem. |
| **Inciting Incident** | Ch.1 (boss) | The Star-Eater Maw — a creature that devours entire star systems — appears and annihilates an adjacent warband in a cutscene. The player's warband is now the only force between the Maw and the populated core systems. |
| **First Complication** | Ch.2 | Constellation weaving reveals that the stars are not natural formations — they were arranged. Someone or something designed this constellation before it shattered. The melodies in the battlefields are not random — they are fragments of a signal. |
| **Rising Action** | Ch.3 | The Hollow King — a berserker who hit Void and never came back — rules a dead star cluster. He has retained consciousness through rage alone. He reveals that the constellation was a prison, and the Maw was the warden. By shattering the constellation, someone freed everything inside. |
| **Midpoint Reversal** | Ch.4 | The player discovers that their employer — the entity that hired the warband — is the Architect who originally shattered the constellation. The "mapping mission" was always about reassembling the prison. The player must choose: reassemble the prison (losing all constellation bonuses and 3 berserkers as sacrifice) or reject the Architect and face whatever was imprisoned. |
| **Crisis** | Ch.5-6 | If the player rejected the Architect: the imprisoned entities are the Fractal Gods — beings of pure rage that created the berserker condition. They are absorbing stars, and the player's warband is the only thing standing between them and the core systems. Berserker losses accelerate. If the player assembled the prison: the Architect betrays them, and the berserkers trapped inside begin breaking out from within. Either path converges on the same Ch.7. |
| **Climax** | Ch.7 | The Loom — the mechanism at the constellation's center — awakens. It is not a weapon or a prison; it is a loom in the literal sense — a device that weaves reality. The Fractal Gods are trying to unmake the constellation's fabric. The player must fight through the Loom's defenses (which mirror the player's own warband composition) to reach the center. The final battle takes place on a grid that reshapes every 4 turns, with the Loom itself as an enemy entity that has its own rage matrix. |
| **Resolution** | Post-Ch.7 | The player's surviving berserkers stabilize the Loom. The constellation remains shattered but stable. The Fractal Gods are dispersed but not destroyed. Every berserker who survived carries their scars. Every berserker who died is remembered in the scar library. The ending text is a constellation map showing every star the player captured, every scar they inherited, and every berserker they lost — unique to each playthrough. |

### Key Characters

| Character | Role | Theme | First Appearance | Fate |
|-----------|------|-------|------------------|------|
| **The Warleader** | Player avatar (silent protagonist) | Command without control | Ch.1 | Survives or falls based on player action |
| **The Architect** | Employer, later antagonist | Creation as possession | Mentioned Ch.1, appears Ch.4 | Defeated Ch.6 or Ch.7 |
| **The Hollow King** | Undead berserker king | Rage as sustenance | Ch.3 boss | Returns as ally in Ch.5 if spared |
| **The Conductor** | Melody-obsessed adversary | Art as weapon | Ch.2 boss | Killed or recruited (player choice) |
| **The Fractal Gods** (3) | Ancient beings of pure rage | Entropy given form | Revealed Ch.5 | Dispersed, not destroyed |
| **The Loom** | Sentient reality-weaving machine | Order from chaos | Revealed Ch.6 | Stabilized in ending |
| **32 Berserker Archetypes** | Warband members | Sacrifice, legacy, fury | Gradual unlock across all chapters | Variable — each has unique death dialogue |

### Narrative Delivery

- **No cutscenes longer than 90 seconds.** Story is told through pre-battle briefings (30-60 seconds), in-battle dialogue (berserkers bark lines at rage thresholds), and post-battle vignettes (scar inheritance moments). Total narrative content: approximately 45 minutes across a full campaign.
- **Berserker death scenes** are 15-second vignettes: the berserker's rage extinguishes, their light dims, and the camera holds on the dark space where they stood. No music. Just the void.
- **Scar inheritance** plays a short (10 seconds) animation where the recruit kneels at the crimson scar on the strategic map and absorbs it. The fallen berserker's voice plays one final line.

---

## 8. Player Personas

### P-003: Hiroshi Tanaka — "The RPG Addict"

**Why this game fits:** Hiroshi craves system depth and completion. The rage matrix with its 7 distinct rage curves per archetype and 54 constellation patterns offers a theorycrafting playground. The deterministic damage model (no RNG rolls) appeals to his optimizer instincts — every outcome is calculable.

**Predicted experience:** Hiroshi will mainline the campaign in 2-3 weeks, spend hours in Discord theorycrafting optimal warband compositions for each chapter, and pursue the "Scarless Campaign" achievement (complete the game without losing a berserker) as his white whale. He will skip the narrative on replay and focus entirely on mechanical mastery. He will create and share constellation optimization spreadsheets.

**Engagement hook:** The 54 constellation patterns and 32 berserker archetypes give Hiroshi 400+ hours of build experimentation. The achievement system tracks per-archetype mastery (complete a campaign with each archetype in the warband), giving him a completion checklist that never feels like grinding because each run plays differently.

### P-006: Eleanor Vance — "The Loyal Strategist"

**Why this game fits:** Eleanor wants games that respect her intelligence and reward patience. The premium model (no energy systems, no consumable monetization) aligns perfectly with her values. The constellation crafting system is a strategic puzzle that unfolds over months — she does not need to rush.

**Predicted experience:** Eleanor will play 2-3 hours daily in her morning and evening sessions. She will take 6-8 weeks on a single campaign, carefully planning each star capture and constellation weave. She will deeply engage with the narrative and mourn every berserker loss. She will never pursue the Scarless Campaign — she accepts loss as part of the experience and finds the scar inheritance system emotionally meaningful. She will play through all three Ch.4 branches across separate campaigns.

**Engagement hook:** The branching Ch.4 path, difficulty calibration points, and 32 archetypes ensure each campaign feels distinct. Eleanor will play 3-4 full campaigns over 18 months — exactly the loyalty arc the game is designed for.

### P-008: David Park — "The Achievement Hunter"

**Why this game fits:** David treats games as completion projects and spreadsheets. Berserker's Weave has a concrete achievement system: per-chapter completion, per-archetype mastery, constellation discovery tracking, and difficulty modifiers. No bugged achievements (deterministic systems), no time-limited events (premium model), no RNG-dependent achievements.

**Predicted experience:** David will maintain a spreadsheet tracking all 54 constellation patterns, all 32 archetypes, and all achievement progress. He will complete the game at each difficulty tier, pursue the Scarless Campaign, and aim for the "Loom Master" achievement (complete Ch.7 with zero berserkers ever reaching Void state). He will spend approximately 200 hours achieving 100% completion, then move on — but will return for each expansion campaign.

**Engagement hook:** Achievement design is honest — every achievement is skill-attainable with no gating. The expansion campaigns add 15-20 new achievements each, giving David reasons to return every 6-9 months.

### P-009: Liam O'Connor — "The Dedicated F2P"

**Why this game fits:** Premium games are Liam's exception — he will pay once for a game that respects his time and skill. The deterministic combat model (no RNG in damage) means his tactical decisions are the sole determinant of outcome. No pay-to-win exists because there is nothing to buy beyond the base game.

**Predicted experience:** Liam will research the game extensively before buying, watch 2-3 hours of gameplay footage, and purchase during a Steam sale at $29.99. He will main the hardest difficulty path, create F2P-accessible build guides (even though the game is premium, his instinct is to optimize for "minimum resource" runs), and become a vocal advocate for the game's fair design. He will PvP extensively in Constellation Wars mode.

**Engagement hook:** Liam's advocacy is the game's marketing engine for the budget-conscious audience. His guides and streams generate organic reach that no ad buy can match.

---

## 9. User Stories

### Core Mechanics (Rage & Combat)

1. **US-001:** As a player (P-003), I want to see each berserker's rage threshold visualized on their unit card during combat so that I can plan my next 3 turns without pausing to check stats.

2. **US-002:** As a player (P-006), I want to preview a berserker's rage gain from a planned action before committing to it so that I can make informed strategic decisions about rage management.

3. **US-003:** As a player (P-009), I want friendly fire to apply consistently to all units at Blaze+ threshold so that positioning skill is rewarded over brute force.

4. **US-004:** As a player (P-003), I want the battlefield melody's current phrase displayed as a visual waveform at the top of the screen so that I can anticipate elemental shifts without relying on audio alone.

5. **US-005:** As a player (P-008), I want a combat log that records every action, rage change, and melody shift so that I can review and optimize my tactics after battle.

6. **US-006:** As a player (P-006), I want to undo my last move during tactical combat (once per battle) so that a single misclick does not cascade into a berserker's death in a deterministic system.

7. **US-007:** As a player (P-003), I want the berserker AI at Inferno threshold to prefer the target I selected 50% of the time so that loss of control feels tense but not purely random.

### Constellation Crafting

8. **US-008:** As a player (P-006), I want to draw supply lines between liberated stars by clicking and dragging so that constellation crafting feels tactile and meditative rather than menu-driven.

9. **US-009:** As a player (P-003), I want the game to highlight potential constellation patterns when I hover over an incomplete arrangement so that I can discover patterns through experimentation rather than memorizing a guide.

10. **US-010:** As a player (P-008), I want a constellation library screen showing all 54 patterns with discovered/undiscovered status so that I can track my completion progress without external tools.

11. **US-011:** As a player (P-006), I want to see the active bonuses from my current constellation network overlaid on the strategic map so that I can plan captures based on which bonuses I need.

12. **US-012:** As a player (P-009), I want enemy constellations to be visible on the strategic map with their active bonuses displayed so that I can make informed decisions about which supply lines to sever.

### Warband Management

13. **US-013:** As a player (P-008), I want each berserker's trauma marks displayed as visual scars on their character model so that I can assess their remaining lifespan at a glance during roster management.

14. **US-014:** As a player (P-003), I want to compare two berserker archetypes side by side with their rage curves overlaid on a shared graph so that I can make informed roster decisions.

15. **US-015:** As a player (P-006), I want scar inheritance to prompt me with a vignette of the fallen berserker's final battle so that I understand what I am gaining before I commit the scar.

16. **US-016:** As a player (P-009), I want to dismiss a berserker from my warband voluntarily so that I can optimize my 16-slot roster without waiting for combat casualties.

17. **US-017:** As a player (P-008), I want to name new recruits so that my warband feels personal and my scar library carries names that are meaningful to me.

### Narrative & Progression

18. **US-018:** As a player (P-006), I want the narrative to acknowledge each berserker death in the post-battle vignette with a unique voice line so that losses feel meaningful rather than mechanical.

19. **US-019:** As a player (P-003), I want to skip previously viewed cutscenes and dialogue so that repeat campaigns move at my pace without narrative gating.

20. **US-020:** As a player (P-008), I want the end-screen constellation map to be exportable as an image so that I can share my unique campaign history with the community.

21. **US-021:** As a player (P-006), I want the Ch.4 branching choice to present consequences clearly (what I gain and lose from each path) so that I make an informed narrative decision, not a blind one.

22. **US-022:** As a player (P-009), I want the campaign difficulty to be transparent (enemy stat multipliers visible in a tooltip) so that my difficulty selection is based on data, not feel.

### Accessibility

23. **US-023:** As a player (P-006), I want to adjust the UI distortion effect at high rage states (reduce or disable) so that it does not cause eye strain during long sessions.

24. **US-024:** As a player (P-003), I want full keyboard-only navigation of the strategic map and combat grid so that I can play efficiently without a mouse.

25. **US-025:** As a player (P-008), I want colorblind modes for melody battlefield tile tints (Flame/Frost/Storm/Silence) so that the visual distinction works for deuteranopia, protanopia, and tritanopia.

26. **US-026:** As a player (P-006), I want subtitle options for all berserker barks and narrative dialogue with adjustable font size so that audio-dependent information is accessible to hearing-impaired players.

### Social & PvP

27. **US-027:** As a player (P-009), I want to challenge another player's constellation network in asynchronous PvP (Constellation Wars) so that I can test my strategic skills against human opponents without scheduling coordination.

28. **US-028:** As a player (P-003), I want to spectate Constellation Wars matches between other players so that I can study high-level tactics and constellation layouts.

29. **US-029:** As a player (P-009), I want berserker harmonization audio to be positional and clearly audible in PvP so that I can read my opponent's rage states through sound as intended by the melody mechanic.

30. **US-030:** As a player (P-008), I want a ranked leaderboard for Constellation Wars with seasonal resets so that competitive play has measurable progression.

### Onboarding

31. **US-031:** As a player (P-006), I want the tutorial to be integrated into Ch.1's first 3 battles rather than a separate mode so that I learn mechanics in context without feeling patronized.

32. **US-032:** As a player (P-003), I want a "Veteran Skip" option after completing the campaign once so that I can bypass the Ch.1 tutorial on subsequent runs.

33. **US-033:** As a player (P-008), I want a built-in glossary accessible from any screen that explains every term (rage thresholds, constellation families, trauma marks) so that I never need to alt-tab to a wiki.

34. **US-034:** As a player (P-009), I want the game to auto-save after every tactical action so that a crash or alt-tab never costs me progress in a game with permanent loss.

35. **US-035:** As a player (P-006), I want the Ch.4 branch selection screen to show a brief summary of each path's mechanical differences (not just narrative teasers) so that my first blind choice is still an informed one.

---

## 10. Monetization

### Revenue Model: Premium

Berserker's Weave uses a premium model because the game's core emotional contract — permanent loss, deterministic combat, no shortcuts — is incompatible with consumable monetization. Selling rage reduction potions, berserker revivals, or constellation unlocks would undermine the design. Cosmetic skins and expansion campaigns are the only ethical revenue extensions.

| Revenue Stream | Price | Content | Timeline |
|----------------|-------|---------|----------|
| **Base game** | $39.99 | Full 7-chapter campaign, 32 archetypes, 54 constellation patterns, Constellation Wars PvP, all 7 language localizations | Launch |
| **Skin Pack 1: Fallen Heroes** | $7.99 | 8 cosmetic skins for berserker archetypes, themed after the Fractal Gods | Launch +2 months |
| **Skin Pack 2: The Conductor's Ensemble** | $7.99 | 8 cosmetic skins with musical instrument-themed armor sets | Launch +4 months |
| **Expansion 1: The Weaver's Lament** | $19.99 | 3-chapter side campaign (12-15 hours), 8 new berserker archetypes, 18 new constellation patterns, new melody instruments, new PvP map pool | Launch +6 months |
| **Expansion 2: Fractal Echoes** | $19.99 | 3-chapter continuation, 8 new archetypes, 18 new patterns, daily challenge mode with leaderboards | Launch +12 months |
| **Skin Pack 3: Scars of Glory** | $7.99 | 8 cosmetic skins with scar-themed visual effects (cosmetic only, no gameplay impact) | Launch +14 months |

### Why Premium Fits This Game

| Factor | Premium Model | F2P Alternative | Verdict |
|--------|--------------|-----------------|---------|
| Permanent loss design | Players accept loss because they paid for the experience | Players rage-quit and refund when berserkers die | Premium is mandatory |
| Deterministic combat | Purity of system is the selling point | Players would suspect pay-to-win even if it does not exist | Premium eliminates suspicion |
| Session length (30-90 min) | Fits premium expectations for depth | F2P games optimize for 5-15 minute sessions with hooks | Premium matches session design |
| Target personas (P-006, P-008) | Eleanor and David prefer one-time purchases | Both actively avoid F2P monetization | Premium matches audience |
| PvP fairness | Cosmetic-only monetization is provably fair | Any power monetization destroys competitive integrity | Premium is required for Constellation Wars |

### Revenue Projections (4 Scenarios)

| Scenario | Units Sold (Year 1) | Gross Revenue | Net Revenue (70% after platform cut) | Break-Even | Notes |
|----------|---------------------|---------------|--------------------------------------|------------|-------|
| **Modest** | 25,000 | $999,750 | $699,825 | Year 1 Q3 | Niche tactics audience, strong reviews but limited marketing reach |
| **Solid** | 80,000 | $3,199,200 | $2,239,440 | Year 1 Q1 | Positive word of mouth, Tactics RPG community adoption, 75+ Metacritic |
| **Strong** | 200,000 | $7,998,000 | $5,598,600 | Launch month | Streamer adoption, 85+ Metacritic, Featured on platform storefronts |
| **Breakout** | 500,000 | $19,995,000 | $13,996,500 | Launch week | Viral constellation-sharing, mainstream tactics crossover (XCOM-adjacent audience), 90+ Metacritic |

Assumptions: Average sale price $39.99 (no discounting in Year 1 projections). Platform cut 30% (Steam standard). Expansion revenue not included in Year 1 projections (first expansion launches at Month 6, projected 20-30% attach rate). Skin pack revenue estimated at $1.50 per unit sold (blend of purchasers and non-purchasers).

---

## 11. Production Plan

### Team Composition

| Role | Count | Phase | Monthly Cost (avg) | Duration |
|------|-------|-------|-------------------|----------|
| Creative Director | 1 | All phases | $9,500 | 24 months |
| Lead Designer (systems) | 1 | All phases | $8,500 | 24 months |
| Designer (combat/grid) | 1 | Phases 2-4 | $6,500 | 18 months |
| Designer (constellation/strategic) | 1 | Phases 2-4 | $6,500 | 18 months |
| Lead Programmer | 1 | All phases | $9,000 | 24 months |
| Programmer (combat systems) | 1 | Phases 2-4 | $7,000 | 18 months |
| Programmer (UI/strategic map) | 1 | Phases 2-4 | $7,000 | 18 months |
| Programmer (audio/networking) | 1 | Phases 2-4 | $7,000 | 18 months |
| Art Director | 1 | All phases | $8,500 | 24 months |
| 2D Artist (characters) | 2 | Phases 2-4 | $5,500 each | 18 months |
| 2D Artist (environments/VFX) | 1 | Phases 2-4 | $5,500 | 18 months |
| UI Designer | 1 | Phases 1-4 | $6,000 | 22 months |
| Composer | 1 | Phases 2-4 | $7,000 | 18 months |
| Sound Designer | 1 | Phases 3-4 | $5,500 | 12 months |
| Writer | 1 | Phases 1-3 | $5,500 | 16 months |
| QA Lead | 1 | Phases 3-4 | $5,000 | 10 months |
| QA Tester | 2 | Phase 4 | $3,500 each | 6 months |
| Producer | 1 | All phases | $7,500 | 24 months |
| Community Manager | 1 | Phase 4+ | $4,500 | 6 months |

**Total team: 22 people at peak (Phases 3-4)**

### Timeline

| Month | Milestone | Deliverable |
|-------|-----------|-------------|
| 1 | **Phase 1 Start: Pre-Production** | Game design document finalized, art bible complete, technical prototype of rage matrix |
| 2 | Prototype | Playable 2-berserker combat prototype on blank grid, rage thresholds functional, basic AI |
| 3 | Prototype Expansion | 6 berserker archetypes implemented, constellation crafting prototype on 12-star map |
| 4 | Vertical Slice | Ch.1 complete: tutorial, first 8 stars, Star-Eater Maw boss, melody system on 1 battlefield |
| 5 | **Phase 2 Start: Production** | Art production pipeline locked, all 32 berserker archetype designs finalized |
| 6 | Combat Complete | Full combat system with all rage curves, friendly fire, trauma marks, all 32 archetypes playable |
| 7 | Strategic Map v1 | Constellation crafting with 54 patterns, supply lines, stellar dust economy |
| 8 | Melody System | All 4 melody phrases, berserker harmonization audio, battlefield tile effects |
| 9 | Ch.1-3 Content | First 3 chapters fully playable, 18 berserker archetypes in-game, 36 constellation patterns |
| 10 | Ch.4-5 Content | Branching paths implemented, Void state, enemy rage, 26 archetypes in-game |
| 11 | Ch.6-7 Content | Full campaign playable end-to-end, all 32 archetypes, all 54 patterns, final boss |
| 12 | **Phase 3 Start: Alpha** | Full campaign alpha build, internal playtest begins |
| 13 | PvP Implementation | Constellation Wars mode (asynchronous), ranked system, replay viewer |
| 14 | Narrative Polish | All vignettes, death scenes, scar inheritance animations, voice recording complete |
| 15 | Localization | All 7 languages localized and integrated, subtitles verified |
| 16 | Art Polish | VFX pass, UI warping shader, berserker rage visual states at all thresholds |
| 17 | Audio Polish | 7 chapter composers deliver final tracks, harmonization system tuned, 3D positional audio verified |
| 18 | **Phase 4 Start: Beta** | Closed beta (500 testers from Tactics RPG community), feedback collection begins |
| 19 | Beta Iteration 1 | Balance pass based on beta data, rage curve tuning, constellation pattern cost rebalancing |
| 20 | Beta Iteration 2 | Second balance pass, difficulty calibration for all 7 chapters, accessibility features implemented |
| 21 | Submission Builds | Platform submission (Steam, PS5, Xbox), certification process begins |
| 22 | Certification Fix | Address platform certification feedback, day-one patch prepared |
| 23 | Gold Master | Release candidate approved, manufacturing for physical console editions (limited run) |
| 24 | **Launch** | Simultaneous PC/PS5/Xbox launch, day-one patch deployed, community manager active |

### Budget Breakdown

| Category | Amount | Percentage | Notes |
|----------|--------|------------|-------|
| Salaries (24 months) | $2,340,000 | 62.4% | Average team of 18 FTE over 24 months |
| Contractors (composers, voice, localization) | $280,000 | 7.5% | 7 composers at $25K each, VO talent, LQA |
| Software & Tools | $85,000 | 2.3% | Unity Pro licenses, Perforce, Jira, Figma, build servers |
| Hardware | $45,000 | 1.2% | Dev kits (PS5, Xbox), test machines, audio equipment |
| Platform Fees | $35,000 | 0.9% | Steam Direct, console dev kits, age rating submissions |
| QA & Playtesting | $120,000 | 3.2% | 500-player closed beta, hardware lab testing, compatibility |
| Marketing (pre-launch) | $350,000 | 9.3% | Trailers, press outreach, streamer seeding, platform featuring |
| Marketing (launch window) | $250,000 | 6.7% | Launch campaign, community events, post-launch content drops |
| Contingency (15%) | $375,000 | 10.0% | Standard game dev contingency for scope changes and delays |
| Operations | $85,000 | 2.3% | Office/cloud, CI/CD, website, community platform |
| **TOTAL** | **$3,750,000** | **100%** | |

### Break-Even Analysis

| Scenario | Net Revenue | Profit/(Loss) After Break-Even |
|----------|-------------|-------------------------------|
| Modest (25K units) | $699,825 | -$3,050,175 (loss, but expansion revenue offsets over 24 months) |
| Solid (80K units) | $2,239,440 | -$1,510,560 (break-even at ~107K units including expansion attach) |
| Strong (200K units) | $5,598,600 | +$1,848,600 |
| Breakout (500K units) | $13,996,500 | +$10,246,500 |

Break-even unit count (base game only): **~134,000 units** at $39.99 gross / $27.99 net per unit.

---

## 12. Technical Requirements

### Platform Specifications

| Spec | PC Minimum | PC Recommended | PlayStation 5 | Xbox Series X/S |
|------|-----------|----------------|---------------|-----------------|
| **OS** | Windows 10 64-bit | Windows 11 64-bit | PS5 System Software 24.0+ | Xbox OS 24.0+ |
| **CPU** | Intel i5-6600 / AMD Ryzen 5 1600 | Intel i7-9700K / AMD Ryzen 7 3700X | Custom AMD Zen 2 (locked) | Custom AMD Zen 2 (locked) |
| **RAM** | 8 GB | 16 GB | 16 GB GDDR6 | 16 GB GDDR6 |
| **GPU** | NVIDIA GTX 970 / AMD RX 570 | NVIDIA RTX 2070 / AMD RX 5700 XT | Custom RDNA 2 (locked) | Custom RDNA 2 (locked) |
| **Storage** | 20 GB HDD | 20 GB SSD | 18 GB SSD | 18 GB SSD |
| **Audio** | Stereo speakers or headphones | 5.1 surround or headphones | 3D Audio (Tempest) supported | Windows Sonic / Dolby Atmos |
| **Input** | Keyboard + Mouse (required), Gamepad supported | Same | DualSense (required) | Xbox Wireless Controller |
| **Network** | None for campaign, broadband for PvP | Same | PSN for PvP | Xbox Live for PvP |

### Target Performance

| Metric | PC Min Spec | PC Rec Spec / Consoles |
|--------|-------------|----------------------|
| Resolution | 1080p | 1440p (4K with dynamic scaling on consoles) |
| Frame Rate | 30 FPS (combat), 60 FPS (strategic map) | 60 FPS (both modes) |
| Load Time (battle) | <8 seconds | <3 seconds |
| Load Time (strategic map) | <5 seconds | <2 seconds |

### Key Technical Challenges

| Challenge | Risk Level | Mitigation Strategy |
|-----------|-----------|-------------------|
| **Deterministic combat replay** — ensuring identical outcomes across all platforms for PvP validation | High | Lock-step simulation architecture, fixed-point math (no floating point in combat calculations), daily automated replay consistency tests across PC/PS5/Xbox |
| **UI distortion shader at high rage** — shader performance varies widely across GPU generations | Medium | Pre-built shader variants for min-spec (simplified warp) vs recommended (full distortion), automatic detection with manual override |
| **3D positional audio for berserker harmonization** — spatial audio APIs differ per platform | Medium | Abstract audio layer with platform-specific backends (Steam Audio on PC, Tempest on PS5, XAudio2 on Xbox), fallback to stereo panning if spatial audio unavailable |
| **Strategic map with 110 stars and dynamic connections** — node graph rendering at scale | Low | Hierarchical rendering (cluster view at full zoom, individual stars at zoom-in), frustum culling for off-screen constellations, instanced rendering for star effects |
| **Asynchronous PvP (Constellation Wars)** — turn validation without server authority | Medium | Server-authoritative turn validation, client-side prediction for responsive UX, replay verification on submission, anti-cheat integration (Easy Anti-Cheat on PC, platform-native on consoles) |
| **Localization across 7 languages** — UI layout breaks with German/Japanese text lengths | Low | UI designed with 40% text expansion buffer, automated screenshot comparison tests in all languages, LQA pass with native speakers before submission |
| **Save integrity with permanent loss** — corrupted saves in a game with irreversible consequences | High | Triple-redundant save system (local + cloud + backup slot), write-ahead logging for every combat action, save corruption auto-detection with rollback to last verified state |

### Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Game engine | Unity 2023 LTS (URP) | Proven 2D/3D hybrid pipeline, C# performance for grid combat, strong console deployment, mature asset store for grid/tactics plugins |
| Networking model | Client-server (asynchronous turns) | PvP turns are low-frequency (minutes between moves), no need for real-time networking. Server validates each turn. |
| Save system | SQLite local + Steam Cloud / PS Plus Cloud / Xbox Cloud | Triple redundancy ensures no progress loss. SQLite handles complex warband state efficiently. |
| Audio middleware | Wwise | Spatial audio support across all platforms, dynamic music system for melody battlefield transitions, proven in tactics games |
| Build pipeline | GitHub Actions + GameCI | Automated multi-platform builds on every commit, test orchestration, submission package generation |
| Analytics | Self-hosted (PostHog) | Player behavior data (rage distribution, constellation popularity, berserker survival rates) without third-party privacy concerns |
