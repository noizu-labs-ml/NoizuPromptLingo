# Genre Checklists

Per-genre quality gates for game concept completeness. Every fleshed-out concept must pass the **Universal Checklist** plus the checklist for its primary genre. Hybrid genres (e.g., "survival horror roguelite") must pass all applicable genre checklists.

---

## Universal Checklist (All Genres)

Every game concept, regardless of genre, must address:

### Core Design
- [ ] Core loop documented with diagram and per-step breakdown
- [ ] Meta loop documented with progression axes and caps
- [ ] Session length target defined with justification
- [ ] Primary mechanic described in enough detail to prototype
- [ ] Secondary mechanics listed with interaction points to primary
- [ ] Difficulty progression table showing complexity curve
- [ ] Onboarding / tutorial design sketched (first 10 minutes of play)

### World & Narrative
- [ ] World bible exists (even if minimal for abstract games)
- [ ] At least one zone/level/stage fully described
- [ ] Story spine (or equivalent narrative structure) defined
- [ ] Tone documented on spectrum (grim↔whimsical, serious↔campy, etc.)
- [ ] Art direction pillars stated (3-5 visual keywords + reference comparisons)
- [ ] Audio direction stated (music genre, SFX philosophy, VO scope)

### Players & Stories
- [ ] 3-4 player personas mapped from library with fit analysis
- [ ] 25+ user stories organized by category
- [ ] User stories tagged with persona IDs
- [ ] Accessibility considerations addressed (colorblind, one-hand, subtitle support)

### Economy & Monetization
- [ ] Revenue model chosen with justification
- [ ] At least one currency fully designed (source, sink, earn rate, spend rate)
- [ ] Price points set (if applicable) with value perception rationale
- [ ] F2P progression path viable without spending (if F2P)

### Production
- [ ] Engine choice justified
- [ ] Platform targets listed with min specs (if PC/console)
- [ ] Team plan: roles × headcount × phase
- [ ] Timeline: pre-prod → alpha → beta → gold → launch → live
- [ ] Budget estimated by category
- [ ] Top 3 technical risks identified with mitigations

### Assets
- [ ] At least 5 media prompts created (key art, protagonist, main environment, UI, one creature/NPC)
- [ ] Mood board or style reference document exists

---

## RPG (Role-Playing Game)

Covers: JRPG, WRPG, action RPG, tactical RPG, idle RPG, dungeon crawler.

### RPG-Specific Requirements
- [ ] Character progression system defined (XP curve, level cap, stat growth per level)
- [ ] Class/job/build system designed (if applicable) with at least 3 distinct archetypes
- [ ] Equipment system defined (slots, rarity tiers, stat ranges, upgrade paths)
- [ ] Skill/ability tree or system mapped with unlock conditions
- [ ] Combat system detailed (turn-based, real-time, hybrid — with action economy)
- [ ] Party system defined (solo, fixed party, recruited, AI companions)
- [ ] NPC interaction system designed (dialogue trees, relationship/reputation)
- [ ] Quest structure defined (main quest length, side quest categories, repeatable content)
- [ ] Loot table design: drop rates by rarity, boss-exclusive items, crafting materials

### RPG Worldbuilding Extras
- [ ] At least 3 factions with relationships and player-facing consequences
- [ ] Magic/ability system with rules, costs, and limitations
- [ ] Bestiary with 10+ creature types across threat tiers
- [ ] Town/hub design: what services are available, how town evolves with progress

### RPG Economy Extras
- [ ] Multiple currencies justified (gold, crafting mats, premium, etc.)
- [ ] Vendor economy: buy/sell ratios, price scaling, rare vendor mechanics
- [ ] Crafting economy: input/output ratios, RNG vs. deterministic, failure states

---

## Roguelike / Roguelite

Covers: traditional roguelike, roguelite, run-based, procedural death labyrinth.

### Roguelike-Specific Requirements
- [ ] Run structure defined: start state → zones/floors → boss → end condition
- [ ] Average run length documented (time and zone count)
- [ ] Permadeath rules: what is lost, what persists (roguelite meta-currency)
- [ ] Procedural generation scope: what is randomized, what is hand-crafted, what is templated
- [ ] Item/ability pool size: total items, how many appear per run, selection mechanics
- [ ] Build diversity: at least 5 viable build archetypes from random item combinations
- [ ] Run variance: how different does run #1 feel from run #50?
- [ ] Unlock cadence: what new content becomes available and at what rate
- [ ] Seed system: can players share/replay specific seeds?
- [ ] Daily/weekly challenge system (if applicable)

### Roguelike Progression Extras
- [ ] Meta-progression currencies and unlock tree (if roguelite)
- [ ] Difficulty scaling: optional hard modes, ascension levels, modifiers
- [ ] Achievement/mastery system: goals beyond "win"
- [ ] Unlockable characters/classes with distinct playstyles (if applicable)

### Roguelike Content Extras
- [ ] Boss designs: at least one boss per zone tier with unique mechanics
- [ ] Room/encounter types: combat, treasure, shop, event, rest, mystery
- [ ] Item synergy system: how items interact to create emergent builds

---

## Survival / Survival Horror

Covers: survival crafting, survival horror, extraction shooter, zombie survival.

### Survival-Specific Requirements
- [ ] Resource survival loop: what depletes, how fast, what replenishes it
- [ ] Crafting system: recipe discovery, material gathering, crafting stations
- [ ] Inventory management: capacity limits, weight system, quick-slot design
- [ ] Base building system (if applicable): structures, defenses, upgrades
- [ ] Day/night cycle or equivalent time pressure mechanic
- [ ] Environmental hazards: weather, temperature, disease, radiation, etc.
- [ ] Death penalty: what is lost on death (full wipe, partial, respawn cost)

### Survival Horror Extras
- [ ] Fear mechanics: how the game creates and sustains tension
- [ ] Resource scarcity design: ammo/health/light are intentionally limited
- [ ] Enemy AI behavior: patrol, chase, search, ambush patterns
- [ ] Sound design role: audio as gameplay system (enemy detection, player alerts)
- [ ] Safe room / respite design: where tension deliberately drops
- [ ] Jump scare budget: frequency, escalation, diminishing returns strategy
- [ ] Sanity / stress / fear meter (if applicable): what fills it, what drains it, consequences

### Survival Worldbuilding Extras
- [ ] Map design: open world vs. hub-spoke vs. metroidvania connectivity
- [ ] Ecosystem: how creatures interact with each other, not just the player
- [ ] Shelter/base location design: tradeoffs between safety, resources, risk

---

## Strategy (RTS, Turn-Based, 4X, Tower Defense)

Covers: RTS, TBS, 4X, grand strategy, tower defense, auto-battler.

### Strategy-Specific Requirements
- [ ] Decision space defined: what choices does the player make each turn/cycle?
- [ ] Unit roster: types, costs, counters, upgrade paths (at least 8 units)
- [ ] Resource system: what is gathered, how, and what it's spent on
- [ ] Tech tree or research system: branches, tradeoffs, endgame unlocks
- [ ] Win conditions: all victory types (military, economic, diplomatic, etc.)
- [ ] AI opponent design: difficulty levels, personality archetypes, exploit resistance
- [ ] Map generation or map pool design
- [ ] Fog of war or information asymmetry system

### Tower Defense Extras
- [ ] Wave design: escalation curve, special waves, boss waves
- [ ] Tower types: at least 6 with distinct roles (damage, slow, AoE, support)
- [ ] Pathing: fixed, player-influenced, or fully player-designed
- [ ] Upgrade system: per-tower upgrades, global upgrades, research
- [ ] Maze-building constraints (if applicable)

### 4X Extras
- [ ] Exploration mechanics: map reveal, scouting, discovery events
- [ ] Expansion mechanics: city/settlement placement, borders, colonization
- [ ] Exploitation mechanics: tile improvement, resource extraction, trade
- [ ] Extermination mechanics: military conquest, unit maintenance, war weariness
- [ ] Diplomacy system: treaties, alliances, trade agreements, casus belli
- [ ] Cultural/religious systems (if applicable)

---

## Platformer / Metroidvania

Covers: 2D/3D platformer, precision platformer, metroidvania, collectathon.

### Platformer-Specific Requirements
- [ ] Movement kit defined: jump height, run speed, air control, coyote time, walljump
- [ ] Level design philosophy: linear, branching, hub-world, open
- [ ] Obstacle vocabulary: at least 10 distinct obstacle/hazard types
- [ ] Power-up / ability unlock sequence (metroidvania: gates + keys)
- [ ] Collectible design: what to collect, why it matters, completionist scope
- [ ] Boss fight design: at least 3 boss encounters with distinct mechanics
- [ ] Checkpoint / save system: frequency, fairness, speedrun considerations
- [ ] Speedrun-friendliness: intentional or emergent sequence-breaking?

### Metroidvania Extras
- [ ] Interconnected map design with ability-gated shortcuts
- [ ] Backtracking rewards: what new content unlocks in old areas with new abilities
- [ ] Map reveal / cartography system
- [ ] Sequence-break analysis: which locks can be bypassed, is that intended?
- [ ] Fast travel system and when it unlocks

### Precision Platformer Extras
- [ ] Death counter / attempt tracking
- [ ] Level par times and grade system
- [ ] Assist mode / accessibility toggles (slower speed, extra health, skip)

---

## Puzzle

Covers: match-3, merge, logic puzzle, physics puzzle, escape room, hidden object.

### Puzzle-Specific Requirements
- [ ] Core puzzle mechanic fully described with edge cases
- [ ] Level count: how many levels at launch, expansion cadence
- [ ] Difficulty curve: how complexity is introduced (new mechanics per N levels)
- [ ] Hint/help system: what assistance is available, cost, cooldown
- [ ] Star/grade system: how performance is rated (moves, time, score)
- [ ] Level generation: hand-crafted, procedural, or hybrid — with quality controls
- [ ] Undo/retry system: how forgiving is the game?
- [ ] Energy/lives system (if F2P): capacity, regeneration rate, purchase price

### Match-3 / Merge Extras
- [ ] Board size and piece count
- [ ] Special piece combinations and cascading rules
- [ ] Booster catalog: types, earn/buy sources, power level
- [ ] Level objective types: score, clear, collect, boss health, timed, limited moves
- [ ] Social features: lives sharing, score comparison, team events

### Logic / Escape Room Extras
- [ ] Puzzle taxonomy: types of logical reasoning required
- [ ] Hint escalation: vague → specific → solution reveal
- [ ] Narrative integration: how puzzle solutions advance the story

---

## Fighting / Action

Covers: fighting game, beat-em-up, character action, hack-and-slash, souls-like.

### Fighting-Specific Requirements
- [ ] Character roster: at least 8 playable characters with distinct movesets
- [ ] Input system: command notation, buffer window, input complexity tiers
- [ ] Frame data basics: startup, active, recovery for key moves
- [ ] Combo system: how combos work, length limits, damage scaling
- [ ] Defense mechanics: block, parry, dodge, invincibility frames
- [ ] Meter / gauge system: what builds it, what it enables (supers, burst, etc.)
- [ ] Matchmaking / rank system (if competitive)
- [ ] Training mode features: frame display, hitbox viewer, combo trials

### Souls-like Extras
- [ ] Stamina / resource management in combat
- [ ] Boss design: phase transitions, telegraphing, punishment windows
- [ ] Bonfire / checkpoint equivalent: healing, respawn, enemy reset
- [ ] Build variety: weapons, stats, magic, armor sets with distinct playstyles
- [ ] Shortcut / exploration reward loop
- [ ] Difficulty philosophy: what difficulty levers exist (summons, overleveling, items)

### Beat-em-up / Hack-and-slash Extras
- [ ] Enemy variety: at least 8 enemy types with distinct behaviors
- [ ] Crowd control mechanics: how to manage multiple enemies
- [ ] Weapon / style switching system
- [ ] Score / style meter (if applicable)

---

## Simulation / Tycoon / Management

Covers: city builder, tycoon, management sim, farming sim, life sim.

### Simulation-Specific Requirements
- [ ] Core simulation loop: what the player manages, what outcomes they're optimizing
- [ ] Systems interdependency map: how changing one thing cascades
- [ ] Time system: real-time, accelerated, turn-based, or calendar-driven
- [ ] UI information hierarchy: what data the player needs at a glance
- [ ] Failure/recovery: can the player lose? What triggers failure? Is recovery possible?
- [ ] Sandbox vs. scenario: is there an open sandbox, structured scenarios, or both?
- [ ] Automation / delegation: at what point can the player automate tasks?

### City Builder / Tycoon Extras
- [ ] Building catalog: types, costs, prerequisites, upgrade paths (at least 20 buildings)
- [ ] Population / customer system: needs, satisfaction, growth drivers
- [ ] Supply chain design: production chains, logistics, bottlenecks
- [ ] Financial model: income, expenses, loans, bankruptcy
- [ ] Disaster / challenge events: types, frequency, mitigation options

### Farming Sim Extras
- [ ] Crop system: types, seasons, growth timers, quality ratings
- [ ] Animal husbandry: species, care requirements, products
- [ ] Relationship / social system: NPC schedules, friendship levels, romance
- [ ] Seasonal calendar: what events, crops, and activities change per season
- [ ] Tool upgrade progression

---

## Multiplayer / Competitive

Covers: MOBA, battle royale, competitive FPS, arena shooter, esports-designed.

### Multiplayer-Specific Requirements
- [ ] Match structure: team size, match length, win condition
- [ ] Character / class balance: how asymmetry is managed
- [ ] Rank / matchmaking system: skill tiers, placement matches, decay
- [ ] Anti-cheat strategy: client-server authority, input validation
- [ ] Netcode approach: client-side prediction, rollback, tick rate
- [ ] Spectator mode design (if esports-targeted)
- [ ] Social features: friends, clans/guilds, voice chat, ping system
- [ ] Toxicity mitigation: report system, mute, behavior score

### Battle Royale Extras
- [ ] Map design: POI distribution, loot density, zone shrink pattern
- [ ] Loot system: rarity tiers, ground loot vs. air drops
- [ ] Zone/circle mechanics: damage, speed, predictability
- [ ] Squad revival mechanics (if team mode)
- [ ] Early game vs. late game pacing design

### MOBA Extras
- [ ] Lane/map structure and objective layout
- [ ] Hero design framework: roles, counter relationships, scaling curves
- [ ] Item shop: components, recipes, situational builds
- [ ] Creep/minion wave design and jungle camp layout
- [ ] Draft/ban system

---

## Card / Deck-Builder

Covers: TCG, CCG, deck-builder roguelike, autobattler with cards.

### Card Game-Specific Requirements
- [ ] Card pool size: total cards at launch, expansion plan
- [ ] Card types: categories (creature, spell, equipment, etc.) with counts per category
- [ ] Mana / resource system: how cards are paid for, ramp mechanics
- [ ] Deck construction rules: minimum/maximum, copies per card, banned list
- [ ] Rarity distribution: common through mythic, acquisition rates
- [ ] Keyword / mechanic glossary: all card keywords with definitions
- [ ] Win condition: how a game ends (life total, deck out, board state)
- [ ] Draft / arena mode (if applicable): card selection mechanics

### Deck-Builder Roguelike Extras
- [ ] Starting deck composition
- [ ] Card reward selection: how many options, remove/upgrade options
- [ ] Relic / artifact system: persistent run bonuses
- [ ] Enemy intent system: how player reads upcoming enemy actions
- [ ] Archetype diversity: at least 4 viable deck archetypes

---

## Narrative / Visual Novel / Adventure

Covers: visual novel, point-and-click, interactive fiction, walking simulator.

### Narrative-Specific Requirements
- [ ] Branching structure: linear, branching, hub-and-spoke, open network
- [ ] Choice consequence design: cosmetic, short-term, long-term, ending-affecting
- [ ] Ending count and conditions: how many endings, what triggers each
- [ ] Route structure (if VN): which characters have routes, unlock conditions
- [ ] Script length estimate: word count, average playthrough time, full completion time
- [ ] Voice acting scope: full, partial, barks-only, text-only
- [ ] CG / illustration count: key art pieces per route/chapter
- [ ] Save system: manual save, bookmark, chapter select, flowchart

### Point-and-Click Extras
- [ ] Puzzle inventory: types of puzzles (use-item, combine-items, logic, dialogue)
- [ ] Hotspot design: density, red herrings, look/use/talk interactions
- [ ] Walkthrough-resistant design: hints before solutions, no dead ends

---

## Sandbox / Open World

Covers: open-world RPG, creative sandbox, survival sandbox, exploration.

### Sandbox-Specific Requirements
- [ ] World scale: size in meaningful units (km², zone count, biome variety)
- [ ] Content density philosophy: Ubisoft-dense vs. Breath-of-the-Wild sparse
- [ ] Fast travel: when it unlocks, limitations, cost
- [ ] Dynamic events: what happens in the world without player input
- [ ] Emergent gameplay: what systems combine to create unscripted moments
- [ ] Player housing / base: building, decoration, functional value
- [ ] Map design: how the player discovers and orients (compass, markers, landmarks)

### Creative Sandbox Extras (Minecraft-type)
- [ ] Block/material vocabulary: types, properties, interactions
- [ ] Crafting depth: recipe count, automation potential
- [ ] Redstone / logic system equivalent (if applicable)
- [ ] Multiplayer creation: shared worlds, permissions, grief protection
- [ ] Mod support: API, scripting language, workshop integration

---

## Rhythm / Music

Covers: rhythm game, music-based action, DJ/mixing sim.

### Rhythm-Specific Requirements
- [ ] Input system: button press, swipe, touch, motion — timing windows per difficulty
- [ ] Song list: track count at launch, genre mix, licensing strategy
- [ ] Difficulty tiers: per-song difficulty with distinct chart patterns
- [ ] Scoring system: perfect/great/good/miss thresholds, combo multiplier
- [ ] Music licensing: original, licensed, community-created, or hybrid
- [ ] Note/chart editor (if UGC): creation tools, sharing, curation
- [ ] Calibration: audio/visual offset adjustment for hardware latency

---

## Racing / Sports

Covers: racing sim, arcade racer, sports sim, sports arcade.

### Racing-Specific Requirements
- [ ] Vehicle roster: types, stats, unlock conditions (at least 10 vehicles)
- [ ] Track design: count, themes, length, hazards (at least 8 tracks)
- [ ] Physics model: sim vs. arcade vs. hybrid — handling feel description
- [ ] Boost/nitro system: earn, spend, risk/reward
- [ ] Career mode structure: season, championship, progression
- [ ] Multiplayer: lobbies, matchmaking, ghost racing, leaderboards
- [ ] Vehicle customization: visual, performance, or both

### Sports-Specific Requirements
- [ ] Rules implementation: which real-world rules are modeled, which are simplified
- [ ] Team management: roster, trades, drafts, contracts (if applicable)
- [ ] Season mode: schedule, playoffs, awards
- [ ] Player attributes: stat categories, growth, regression
- [ ] Commentary/presentation: broadcast-style, minimal, player-POV
