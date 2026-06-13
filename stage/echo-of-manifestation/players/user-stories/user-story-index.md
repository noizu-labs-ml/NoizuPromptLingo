# User Story Index

> 32 user stories organized by category. Each story maps to a persona, defines a measurable outcome, and is assigned a priority for implementation sequencing.

---

## Persona Reference

| ID | Persona | Archetype | Core Motivation |
|----|---------|-----------|----------------|
| P-003 | The Strategist | Methodical planner who optimizes loadouts and economy | Wants to master the transmutation system and economy |
| P-006 | The Explorer | Completionist who maps every tile and finds every secret | Wants to discover everything the Zone contains |
| P-008 | The Story Seeker | Narrative-focused player who plays for lore and character | Wants to understand the full story of Amara and the Zone |
| P-009 | The Challenger | Difficulty-seeker who pursues achievements and challenge runs | Wants to prove mastery through constraints and speed |

---

## Core Mechanics (US-001 to US-010)

### US-001: First Transmutation
- **Persona:** P-003 (The Strategist)
- **Category:** Core Mechanics
- **Priority:** Must
- **Story:** As the Strategist, I want to perform my first transmutation within the first 3 rooms of Zone 1 so that I understand the core risk-reward loop (creation spawns chimeras) immediately.
- **Acceptance Criteria:** The player can locate an Alchemy Shrine, select a Tier 1 recipe, spend essence, receive the item, and face the spawned chimera within the first 5 minutes of gameplay.

### US-002: Essence Budgeting
- **Persona:** P-003 (The Strategist)
- **Category:** Core Mechanics
- **Priority:** Must
- **Story:** As the Strategist, I want to see my current essence total, the cost of my next transmutation, and my Resonance level at all times so that I can make informed economic decisions during combat.
- **Acceptance Criteria:** Essence counter and Resonance meter are visible in the HUD at all times. Transmutation cost is shown before confirming any recipe.

### US-003: Chimera Spawn from Transmutation
- **Persona:** P-003 (The Strategist)
- **Category:** Core Mechanics
- **Priority:** Must
- **Story:** As the Strategist, I want each transmutation to spawn a chimera whose threat level corresponds to the recipe's tier so that every act of creation carries proportional risk.
- **Acceptance Criteria:** Tier 1 recipes spawn Lesser chimeras, Tier 2 spawn Greater, Tier 3+ spawn Apex-type variants. Chimera threat modifiers match the recipe catalog.

### US-004: Divination for Hidden Content
- **Persona:** P-006 (The Explorer)
- **Category:** Core Mechanics
- **Priority:** Must
- **Story:** As the Explorer, I want to use the Divination system at an essence cost to reveal hidden rooms, traps, and chimera positions so that I can find content I would otherwise miss.
- **Acceptance Criteria:** Divination costs 5 essence per use. Higher Insight tiers increase range and accuracy. Hidden rooms and environmental traps are revealed within the Divination radius.

### US-005: Recipe Discovery Through Play
- **Persona:** P-003 (The Strategist)
- **Category:** Core Mechanics
- **Priority:** Must
- **Story:** As the Strategist, I want to unlock new transmutation recipes through Insight progression and zone exploration so that my toolkit expands as I demonstrate mastery.
- **Acceptance Criteria:** Recipes unlock at specific Insight thresholds or when discovering recipe scrolls in zones. All 38 recipes are discoverable. The recipe catalog tracks which recipes the player has found.

### US-006: Resonance Risk Management
- **Persona:** P-003 (The Strategist)
- **Category:** Core Mechanics
- **Priority:** Must
- **Story:** As the Strategist, I want the Resonance meter to punish me for hoarding essence so that I am forced to make active spending decisions rather than stockpiling.
- **Acceptance Criteria:** Resonance fills at 1%/sec above 50 essence. At 100+, Guardian chimeras spawn. At 200+, environmental damage ticks. Spending essence immediately reduces Resonance.

### US-007: Loadout Customization via Insight
- **Persona:** P-003 (The Strategist)
- **Category:** Core Mechanics
- **Priority:** Should
- **Story:** As the Strategist, I want to unlock loadout slots (starting items, weapons, essence bonuses) through Insight levels so that each run begins with more strategic options.
- **Acceptance Criteria:** Insight 10 grants Starting Essence (25). Insight 40 grants Iron Dagger. Insight 90 grants Starting Essence+ (50). Insight 99 grants Loadout Slot 3.

### US-008: Companion Combat Warnings
- **Persona:** P-006 (The Explorer)
- **Category:** Core Mechanics
- **Priority:** Should
- **Story:** As the Explorer, I want Echo to provide real-time combat warnings (chimera spawns, HP thresholds, danger zones) so that I have tactical information without breaking immersion.
- **Acceptance Criteria:** Echo delivers HP-threshold dialogue, chimera type identification, and boss approach warnings. Warnings are contextual and do not repeat within the same encounter.

### US-009: The Librarian as Information Economy
- **Persona:** P-003 (The Strategist)
- **Category:** Core Mechanics
- **Priority:** Must
- **Story:** As the Strategist, I want to spend essence at the Librarian for zone previews, chimera data, and lore hints so that I can invest in knowledge as a strategic resource.
- **Acceptance Criteria:** All four exchange types are functional. Prices are 50/75/100/150 essence. The 25% discount activates at 5+ fragments in a single thread. Dialogue chains unlock in sequence.

### US-010: Death and Run Reset
- **Persona:** P-009 (The Challenger)
- **Category:** Core Mechanics
- **Priority:** Must
- **Story:** As the Challenger, I want death to reset my run while preserving meta-progression (Insight XP, unlocks) so that each death is a learning opportunity rather than pure loss.
- **Acceptance Criteria:** On death, the run ends. Insight XP earned during the run is added to the permanent total. Unlocked recipes, zone maps, and loadout slots persist. Carried essence is lost.

---

## Exploration (US-011 to US-018)

### US-011: Zone Progression
- **Persona:** P-006 (The Explorer)
- **Category:** Exploration
- **Priority:** Must
- **Story:** As the Explorer, I want to progress through 8 distinct zones with escalating environmental hazards and visual themes so that each zone feels like a new discovery.
- **Acceptance Criteria:** All 8 zones are accessible in sequence. Each zone has unique hazards, chimera populations, visual identity, and a zone boss. Zone entry triggers Echo's zone-entry dialogue.

### US-012: Secret Room Discovery
- **Persona:** P-006 (The Explorer)
- **Category:** Exploration
- **Priority:** Should
- **Story:** As the Explorer, I want to discover secret rooms through Divination, environmental observation, or transmutation so that thorough exploration is rewarded.
- **Acceptance Criteria:** Each zone contains 1-3 secret rooms. Secrets are revealed by Divination, specific transmutations, or environmental interaction. Secret rooms contain bonus essence, lore fragments, or recipe scrolls.

### US-013: Shortcut Activation
- **Persona:** P-006 (The Explorer)
- **Category:** Exploration
- **Priority:** Should
- **Story:** As the Explorer, I want to activate permanent shortcuts between zones so that subsequent runs can bypass previously cleared content.
- **Acceptance Criteria:** Shortcut anchors exist between zone pairs. Once activated, they persist across all future runs. Activation requires zone-specific challenges (damageless boss, lore thresholds).

### US-014: Full Zone Mapping
- **Persona:** P-006 (The Explorer)
- **Category:** Exploration
- **Priority:** Should
- **Story:** As the Explorer, I want to reveal 100% of a zone's map through exploration so that I can achieve the Cartographer achievement.
- **Acceptance Criteria:** The map fills as rooms are visited. Secret rooms and hidden passages count toward completion. 100% completion triggers achievement tracking.

### US-015: Twisted Dimensional Pockets
- **Persona:** P-006 (The Explorer)
- **Category:** Exploration
- **Priority:** Should
- **Story:** As the Explorer, I want to encounter Twisted Dimensional Pockets (TDPs) that challenge me with spatial puzzles so that I earn bonus essence and Insight XP.
- **Acceptance Criteria:** TDPs appear 1-3 times per zone. Clearing a TDP awards 2-5 essence and 10 Insight XP. The Pocket Sense Insight unlock makes TDPs easier to locate.

### US-016: Zone Boss Encounters
- **Persona:** P-009 (The Challenger)
- **Category:** Exploration
- **Priority:** Must
- **Story:** As the Challenger, I want each zone to culminate in a unique boss encounter with distinct mechanics so that zone completion feels earned.
- **Acceptance Criteria:** 8 zone bosses, each with unique attack patterns, weaknesses, and Echo boss-approach dialogue. Bosses award 100-200 essence and 15-25 Insight XP.

### US-017: Environmental Hazard Variety
- **Persona:** P-006 (The Explorer)
- **Category:** Exploration
- **Priority:** Should
- **Story:** As the Explorer, I want each zone to feature unique environmental hazards (fractured floors, rising water, sound triggers, stone creep, transmutation circles, resonance pulses, mirror inversions, room attacks) so that no two zones play the same.
- **Acceptance Criteria:** Each zone's unique hazard is documented in the zone index. Hazards are visible/telegraphed. Hazards deal damage or impose debuffs.

### US-018: The Empty Room Easter Egg
- **Persona:** P-006 (The Explorer)
- **Category:** Exploration
- **Priority:** Could
- **Story:** As the Explorer, I want to discover a hidden room that only appears when I enter a zone carrying zero transmutable items, so that the game rewards curiosity and constraint.
- **Acceptance Criteria:** The Empty Room appears in any zone when the player has zero transmutable materials. Entering it triggers the Secret Keeper or a unique achievement.

---

## Narrative (US-019 to US-023)

### US-019: Lore Fragment Collection
- **Persona:** P-008 (The Story Seeker)
- **Category:** Narrative
- **Priority:** Must
- **Story:** As the Story Seeker, I want to collect 64 lore fragments across 8 zones organized into 4 story threads so that I can piece together the Zone's history through environmental storytelling.
- **Acceptance Criteria:** 64 fragments total (8 per zone). Fragments are organized into 4 threads: First Alchemist's Journal, Amara's Memories, Zone Ecology, Previous Survivors. Each fragment requires a minimum Insight tier to find.

### US-020: Echo's Identity Arc
- **Persona:** P-008 (The Story Seeker)
- **Category:** Narrative
- **Priority:** Must
- **Story:** As the Story Seeker, I want Echo's dialogue to evolve as I collect lore fragments so that I witness her gradual realization that she is Amara.
- **Acceptance Criteria:** Echo's speech patterns shift at 5+ fragments (mid-game) and after the Midpoint Reversal (3+ Thread 2 fragments + Zone 5). Post-reversal, Echo alternates between child and Amara voices.

### US-021: Hollow Alchemist Progression
- **Persona:** P-008 (The Story Seeker)
- **Category:** Narrative
- **Priority:** Must
- **Story:** As the Story Seeker, I want the Hollow Alchemist's 7 encounters to progress from mocking observer to tragic sacrifice so that the antagonist feels like a fully realized character.
- **Acceptance Criteria:** 7 encounters at zone exits. Encounter 1-3 are dialogue-only. Encounter 4 introduces combat. Encounter 5 is psychological warfare. Encounter 6 is full combat. Encounter 7 reveals Caelum's identity and ends with self-sacrifice.

### US-022: Three Distinct Endings
- **Persona:** P-008 (The Story Seeker)
- **Category:** Narrative
- **Priority:** Must
- **Story:** As the Story Seeker, I want three endings (Escape, Sacrifice, Synthesis) that resolve the story differently based on my choices so that the narrative feels responsive to my actions.
- **Acceptance Criteria:** Ending 1 (leave Echo, player escapes). Ending 2 (player stays, Echo escapes). Ending 3 (both escape by breaking the rules). Ending availability is influenced by choices in Encounters 5 and the Crisis Choice.

### US-023: Librarian Dialogue Chains
- **Persona:** P-008 (The Story Seeker)
- **Category:** Narrative
- **Priority:** Should
- **Story:** As the Story Seeker, I want to unlock 9 dialogue chains from the Librarian that reveal Zone history, previous survivors, and his personal story so that the hub NPC deepens the world.
- **Acceptance Criteria:** 9 chains, unlockable at 150 essence each or via story triggers. Chains reveal: the Librarian's origin, Zone nature, chimera origins, the Hollow Alchemist's history, the anchor, the First Alchemist, previous survivors, Margot, and the final revelation about Echo being the door.

---

## Progression (US-024 to US-028)

### US-024: Insight Meta-Progression
- **Persona:** P-003 (The Strategist)
- **Category:** Progression
- **Priority:** Must
- **Story:** As the Strategist, I want permanent Insight progression across runs so that each run contributes to long-term character power even when I die early.
- **Acceptance Criteria:** Insight XP is earned from kills, exploration, transmutations, boss kills, lore fragments, TDPs, and run completion. XP formula: 50 + (N * 25) per level. 99 levels total.

### US-025: Insight Milestone Unlocks
- **Persona:** P-003 (The Strategist)
- **Category:** Progression
- **Priority:** Must
- **Story:** As the Strategist, I want milestone Insight levels to unlock meaningful abilities (recipes, passives, divination tiers, loadout slots, zone maps) so that progression feels rewarding at regular intervals.
- **Acceptance Criteria:** Milestones at levels 5, 10, 15, 20, 30, 33, 35, 38, 40, 43, 45, 48, 50, 57, 60, 64, 67, 70, 73, 75, 77, 80, 82, 85, 87, 90, 92, 94, 96, 99. Each milestone grants a named unlock.

### US-026: Achievement System
- **Persona:** P-009 (The Challenger)
- **Category:** Progression
- **Priority:** Should
- **Story:** As the Challenger, I want 52 achievements across 5 categories (Combat, Exploration, Lore, Challenge, Meta) so that I have long-term goals that reward mastery.
- **Acceptance Criteria:** All 52 achievements have clear, trackable conditions. No achievement depends on RNG. Categories: Combat (15), Exploration (12), Lore (10), Challenge (10), Meta (5). 3 achievements are hidden.

### US-027: Difficulty Curve Across Runs
- **Persona:** P-009 (The Challenger)
- **Category:** Progression
- **Priority:** Should
- **Story:** As the Challenger, I want the game to become more manageable through player knowledge and Insight unlocks rather than numerical difficulty reduction so that mastery feels earned.
- **Acceptance Criteria:** Base difficulty does not decrease with Insight. Player power increases through new recipes, better loadouts, zone maps, and combat passives (dodge frames, movement speed). A skilled player with high Insight can attempt challenge runs (barehanded, no-death, speedrun).

### US-028: Economy Mastery
- **Persona:** P-003 (The Strategist)
- **Category:** Progression
- **Priority:** Should
- **Story:** As the Strategist, I want to master the essence economy over multiple runs so that I can optimize my transmutation spending, Librarian investments, and Resonance management.
- **Acceptance Criteria:** Essence income scales with zone depth. Resonance prevents hoarding. The Librarian's exchange system provides a secondary spending sink. The balance sheet shows a healthy 3.25:1 income-to-expenditure ratio that rewards active spending.

---

## Accessibility (US-029 to US-032)

### US-029: Combat Accessibility
- **Persona:** P-008 (The Story Seeker)
- **Category:** Accessibility
- **Priority:** Should
- **Story:** As the Story Seeker, I want combat to have generous telegraph windows and clear visual indicators so that I can progress through the story even without high mechanical skill.
- **Acceptance Criteria:** All enemy attacks have 1-2 second telegraph animations. Echo provides verbal warnings for dangerous situations. Dodge window can be extended via Insight unlocks (+1 frame at levels 43 and 73).

### US-030: Narrative Accessibility
- **Persona:** P-008 (The Story Seeker)
- **Category:** Accessibility
- **Priority:** Should
- **Story:** As the Story Seeker, I want all lore fragments and dialogue to be accessible from a codex/journal so that I can review the story at my own pace outside of combat.
- **Acceptance Criteria:** All collected lore fragments are viewable in the codex. Dialogue chains with the Librarian are replayable. Echo's key story moments are logged. The codex tracks collection progress (X/64 fragments).

### US-031: Run Duration Flexibility
- **Persona:** P-003 (The Strategist)
- **Category:** Accessibility
- **Priority:** Should
- **Story:** As the Strategist, I want a single run to take 25-40 minutes so that the game fits into standard play sessions without requiring excessive time commitment.
- **Acceptance Criteria:** Average zone clear time is 3-5 minutes. Full run (8 zones) is 25-40 minutes. Shortcuts allow partial runs. The player can exit at any zone transition and keep Insight XP earned.

### US-032: Challenge Run Support
- **Persona:** P-009 (The Challenger)
- **Category:** Accessibility
- **Priority:** Could
- **Story:** As the Challenger, I want the game to recognize and track challenge constraints (no weapons, minimal items, no healing, speed targets) so that I can self-impose difficulty without external tracking.
- **Acceptance Criteria:** Achievements track: Barehanded (no weapons), One Transmutation Run, No-Death Clear, Minimalist (5 items max), Glass Cannon (no armor), Speed Demon (sub-15 min), Iron Stomach (no healing). Challenge achievements are tracked in-run.

---

## Priority Summary

| Priority | Count | Stories |
|----------|-------|---------|
| **Must** | 14 | US-001, US-002, US-003, US-004, US-005, US-006, US-009, US-010, US-011, US-016, US-019, US-020, US-021, US-022, US-024, US-025 |
| **Should** | 14 | US-007, US-008, US-012, US-013, US-014, US-015, US-017, US-023, US-026, US-027, US-028, US-029, US-030, US-031 |
| **Could** | 4 | US-018, US-032 |

---

## Category Summary

| Category | Count | Stories |
|----------|-------|---------|
| Core Mechanics | 10 | US-001 through US-010 |
| Exploration | 8 | US-011 through US-018 |
| Narrative | 5 | US-019 through US-023 |
| Progression | 5 | US-024 through US-028 |
| Accessibility | 4 | US-029 through US-032 |

---

*This document is the canonical user story index for Echo of Manifestation. All sprint planning, feature prioritization, and acceptance testing should reference this document.*
