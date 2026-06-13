# Blade of Eternity — User Stories

265 user stories across 13 epics, mapped to 10 personas.

## Epics

| Epic | Stories | Coverage |
|------|---------|----------|
| **Accessibility & Screen Reader** | 001–020 | ARIA live regions, keyboard nav, focus management, skip nav, heading hierarchy, SR compatibility, contrast/typography |
| **Combat, Physics & Mechanics** | 021–040 | PvP, NPC combat, skills, physics-to-text, spatial sim, environmental interaction, dungeon crawling |
| **World, Exploration & Narrative** | 041–060 | AI room descriptions, city navigation, NPC dialogue, emergent quests, branching choices, lore, world events |
| **Economy, Crafting & Social** | 061–080 | Crafting, shops, trading, currency, jobs, clans, housing, crimes, chat, forums, reputation, moderation |
| **Onboarding, Settings & Meta** | 081–100 | Account/character creation, tutorial, settings, mobile, connection state, session management, safety, streaming |
| **LLM & AI Systems** | 101–125 | Context management, fallback/degradation, NPC memory, prompt templates, content safety, narrative voice, observability |
| **Item Framework & Equipment** | 126–150 | Item properties, equipment slots, durability, enchantment, cursed/legendary items, crafting recipes, auction house |
| **Mutable World & Environment** | 151–175 | Destructible objects, fire/water/gas propagation, structural collapse, terrain modification, light/dark, environmental puzzles |
| **Character Progression & Classes** | 176–200 | Attributes, leveling, classes, skill trees, specialization, death/resurrection, pets, mounts, achievements |
| **Advanced Combat & Tactics** | 201–220 | Party combat, boss encounters, stealth, magic, ranged, positioning, siege, summoning, environmental tactics |
| **World Depth & Exploration** | 221–240 | Procedural dungeons, fast travel, secrets, world map, wilderness, random encounters, portals, survival, journal |
| **Advanced Social & Governance** | 241–255 | Player government, justice system, mentorship, partnerships, mail, faction politics, emotes, voice chat |
| **Admin, GM & Infrastructure** | 256–265 | GM tools, event scripting, balance dashboard, anti-exploit, analytics, scalability, backup, content pipeline |

## Story Index

### 001–020: Accessibility & Screen Reader

| # | Title | Persona | Priority |
|---|-------|---------|----------|
| 001 | [ARIA Live Combat Announcements](001-aria-live-combat-announcements.md) | Marcus | P0 |
| 002 | [Keyboard-Only Navigation](002-keyboard-only-navigation.md) | Marcus | P0 |
| 003 | [Skip Navigation & Landmarks](003-skip-navigation-landmarks.md) | Marcus | P0 |
| 004 | [Heading Hierarchy](004-heading-hierarchy.md) | Priya | P0 |
| 005 | [VoiceOver iOS Compatibility](005-voiceover-ios-compatibility.md) | Elena | P1 |
| 006 | [Low-Vision Typography & Contrast](006-low-vision-typography-contrast.md) | Sarah | P0 |
| 007 | [Focus Management & Modal Dialogs](007-focus-management-modal-dialogs.md) | Priya | P0 |
| 008 | [Screen Reader Status Panel](008-screen-reader-status-panel.md) | Marcus | P0 |
| 009 | [Game Log Navigation](009-game-log-navigation.md) | Marcus | P0 |
| 010 | [Command Input Accessibility](010-command-input-accessibility.md) | Marcus | P0 |
| 011 | [JAWS Compatibility](011-jaws-compatibility.md) | Priya | P1 |
| 012 | [Screen Reader Verbosity Settings](012-screen-reader-verbosity-settings.md) | Marcus | P1 |
| 013 | [Reduced Motion Preference](013-reduced-motion-preference.md) | Sarah | P1 |
| 014 | [Accessible Inventory Management](014-accessible-inventory-management.md) | Marcus | P1 |
| 015 | [Cross-Platform Party Play](015-cross-platform-party-play.md) | Elena + Carol | P1 |
| 016 | [Accessible Map Navigation](016-accessible-map-navigation.md) | Marcus | P1 |
| 017 | [AT Compatibility Testing Suite](017-at-compatibility-testing-suite.md) | Priya | P1 |
| 018 | [Accessible Character Creation](018-accessible-character-creation.md) | Elena | P0 |
| 019 | [Screen Reader NPC Dialogue](019-screen-reader-npc-dialogue.md) | Elena + Jamie | P1 |
| 020 | [Accessibility Settings Onboarding](020-accessibility-settings-onboarding.md) | Carol + Elena | P0 |

### 021–040: Combat, Physics & Mechanics

| # | Title | Persona | Priority |
|---|-------|---------|----------|
| 021 | [PvP Duel Initiation](021-pvp-duel-initiation.md) | Marcus | P0 |
| 022 | [Combat Action Menu Keyboard](022-combat-action-menu-keyboard.md) | Marcus | P0 |
| 023 | [Combat Announcement Batching](023-combat-announcement-batching.md) | Marcus | P0 |
| 024 | [Skill: Longshot](024-skill-longshot.md) | Marcus | P1 |
| 025 | [Skill: Elusion](025-skill-elusion.md) | Sarah | P1 |
| 026 | [Skill: Whirlwind](026-skill-whirlwind.md) | Marcus | P1 |
| 027 | [HP/Damage System Narration](027-hp-damage-system-narration.md) | Elena | P0 |
| 028 | [Battle Tent NPC Combat](028-battle-tent-npc-combat.md) | Tyler | P1 |
| 029 | [Physics-to-Text Pipeline](029-physics-to-text-pipeline.md) | Dave | P0 |
| 030 | [Environmental Interactions (Combat)](030-environmental-interactions-combat.md) | Jamie | P1 |
| 031 | [Turn/Round Resolution](031-turn-round-resolution.md) | Priya | P0 |
| 032 | [Material Properties Narration](032-material-properties-narration.md) | Dave | P1 |
| 033 | [Skill Progression (Combat)](033-skill-progression-combat.md) | Tyler | P1 |
| 034 | [Dungeon Crawl / Catacomb Navigation](034-dungeon-crawl-catacomb-navigation.md) | Marcus | P1 |
| 035 | [PvP Ranked Match System](035-pvp-ranked-match-system.md) | Marcus | P1 |
| 036 | [Kinetic Force / Knockback Narration](036-kinetic-force-knockback-narration.md) | Jamie | P1 |
| 037 | [Combat Log Review](037-combat-log-review.md) | Dave | P1 |
| 038 | [Multiplayer Sighted+Blind Party Combat](038-multiplayer-sighted-blind-party-combat.md) | Elena | P0 |
| 039 | [Status Effects Narration](039-status-effects-narration.md) | Sarah | P1 |
| 040 | [Content Creator Combat Capture](040-content-creator-combat-capture.md) | Raj | P2 |

### 041–060: World, Exploration & Narrative

| # | Title | Persona | Priority |
|---|-------|---------|----------|
| 041 | [AI Room Description Generation](041-ai-room-description-generation.md) | Jamie | P0 |
| 042 | [Screen Reader Room Navigation](042-screen-reader-room-navigation.md) | Marcus | P0 |
| 043 | [Rune City District Navigation](043-rune-city-district-navigation.md) | Elena | P1 |
| 044 | [Mordoon Vault Navigation](044-mordoon-vault-navigation.md) | Marcus | P1 |
| 045 | [Travel Between Cities](045-travel-between-cities.md) | Dave | P1 |
| 046 | [NPC Context-Responsive Dialogue](046-npc-context-responsive-dialogue.md) | Jamie | P0 |
| 047 | [NPC Goals, Routines & Memory](047-npc-goals-routines-memory.md) | Dave | P1 |
| 048 | [Emergent Quest Generation](048-emergent-quest-generation.md) | Tyler | P0 |
| 049 | [Branching Choices / Persistent Consequences](049-branching-choices-persistent-consequences.md) | Jamie | P0 |
| 050 | [Lore Discovery System](050-lore-discovery-system.md) | Lena | P1 |
| 051 | [Time/Weather Room Variation](051-time-of-day-weather-room-variation.md) | Sarah | P1 |
| 052 | [Accessible Text Map / Navigation Aid](052-accessible-text-map-navigation-aid.md) | Elena | P0 |
| 053 | [AI Narrative Voice Consistency](053-ai-narrative-voice-consistency.md) | Jamie | P0 |
| 054 | [Examine Command / Layered Discovery](054-examine-command-layered-discovery.md) | Lena | P1 |
| 055 | [World Events: Economic Shifts & NPC Migration](055-world-events-economic-shifts-npc-migration.md) | Tyler | P1 |
| 056 | [Seasonal Festivals / World Events](056-seasonal-festivals-world-events.md) | Carol | P2 |
| 057 | [Cross-Screen-Reader Output Testing](057-cross-screen-reader-output-testing.md) | Priya | P0 |
| 058 | [Content Creator Accessibility Showcase](058-content-creator-accessibility-showcase.md) | Raj | P2 |
| 059 | [Night at Mordoon Heritage Integration](059-night-at-mordoon-heritage-integration.md) | Jamie | P1 |
| 060 | [Short-Session Narrative Continuity](060-short-session-narrative-continuity.md) | Lena | P1 |

### 061–080: Economy, Crafting & Social

| # | Title | Persona | Priority |
|---|-------|---------|----------|
| 061 | [Crafting Recipe Discovery](061-crafting-recipe-discovery.md) | Dave | P1 |
| 062 | [Crafting Quality Variance](062-crafting-quality-variance.md) | Dave | P1 |
| 063 | [Material Gathering](063-material-gathering.md) | Tyler | P1 |
| 064 | [NPC Shop Supply & Demand](064-npc-shop-supply-demand.md) | Dave | P1 |
| 065 | [Player Trading](065-player-trading.md) | Marcus | P0 |
| 066 | [Currency Management](066-currency-management.md) | Elena | P0 |
| 067 | [Jobs / Employment System](067-jobs-employment-system.md) | Tyler | P1 |
| 068 | [Clan Creation & Joining](068-clan-creation-joining.md) | Tyler | P0 |
| 069 | [Clan Territories](069-clan-territories.md) | Tyler | P1 |
| 070 | [Clan Wars](070-clan-wars.md) | Marcus | P1 |
| 071 | [Clan Shared Resources](071-clan-shared-resources.md) | Dave | P1 |
| 072 | [Housing Purchase & Customization](072-housing-purchase-customization.md) | Lena | P2 |
| 073 | [Crimes System](073-crimes-system.md) | Tyler | P1 |
| 074 | [Real-Time Chat Channels](074-realtime-chat-channels.md) | Elena | P0 |
| 075 | [Private Messaging](075-private-messaging.md) | Elena | P1 |
| 076 | [Forums](076-forums.md) | Jamie | P2 |
| 077 | [Player Reputation](077-player-reputation.md) | Tyler | P1 |
| 078 | [Clan Politics & Diplomacy](078-clan-politics-diplomacy.md) | Tyler | P1 |
| 079 | [Social Moderation Tools](079-social-moderation-tools.md) | Carol | P0 |
| 080 | [Community Events](080-community-events.md) | Carol | P2 |

### 081–100: Onboarding, Settings & Meta

| # | Title | Persona | Priority |
|---|-------|---------|----------|
| 081 | [Accessible Account Creation](081-account-creation-accessible.md) | Elena | P0 |
| 082 | [Character Creation (Screen Reader)](082-character-creation-screen-reader.md) | Marcus | P0 |
| 083 | [Tutorial / First-Time Experience](083-tutorial-first-time-experience.md) | Carol | P0 |
| 084 | [Command Help System](084-command-help-system.md) | Dave | P1 |
| 085 | [Audio Settings & Controls](085-audio-settings-controls.md) | Marcus | P0 |
| 086 | [Font Size & Contrast Settings](086-font-size-contrast-settings.md) | Sarah | P0 |
| 087 | [Notification Preferences](087-notification-preferences.md) | Lena | P1 |
| 088 | [Mobile VoiceOver (iOS)](088-mobile-voiceover-ios.md) | Elena | P0 |
| 089 | [Mobile TalkBack (Android)](089-mobile-talkback-android.md) | Priya | P1 |
| 090 | [Disconnect / Reconnect Handling](090-disconnect-reconnect-handling.md) | Tyler | P0 |
| 091 | [Session Save & Resume](091-session-save-resume.md) | Lena | P1 |
| 092 | [Performance & Loading States](092-performance-loading-states.md) | Elena | P1 |
| 093 | [Landing Page / Marketing Site](093-landing-page-marketing.md) | Raj | P1 |
| 094 | [Chat Filter & Content Moderation](094-chat-filter-content-moderation.md) | Carol | P0 |
| 095 | [Player Reporting System](095-player-reporting-system.md) | Elena | P1 |
| 096 | [Analytics & Feedback Collection](096-analytics-feedback-collection.md) | Priya | P2 |
| 097 | [Streaming / Content Creation Support](097-streaming-content-creation-support.md) | Raj | P2 |
| 098 | [High-Contrast / Light Mode](098-high-contrast-light-mode.md) | Sarah | P0 |
| 099 | [Age-Appropriate Content Controls](099-age-appropriate-content-controls.md) | Carol | P0 |
| 100 | [Cross-Platform Mixed-Group Play](100-cross-platform-mixed-group-play.md) | Elena | P1 |

### 101–125: LLM & AI Systems

| # | Title | Persona | Priority |
|---|-------|---------|----------|
| 101 | [LLM Context Window Management](101-llm-context-window-management.md) | Dave | P0 |
| 102 | [LLM Fallback and Graceful Degradation](102-llm-fallback-degradation.md) | Dave | P0 |
| 103 | [NPC Conversational Memory](103-npc-conversational-memory.md) | Jamie | P0 |
| 104 | [NPC Emotional State and Mood System](104-npc-emotional-state-mood.md) | Jamie | P1 |
| 105 | [AI-Generated Item Descriptions](105-ai-generated-item-descriptions.md) | Lena | P1 |
| 106 | [Procedural Quest Coherence](106-procedural-quest-coherence.md) | Jamie | P0 |
| 107 | [LLM Prompt Template Registry](107-llm-prompt-template-registry.md) | Dave | P1 |
| 108 | [AI Content Safety Filtering](108-ai-content-safety-filtering.md) | Carol | P0 |
| 109 | [Multi-Turn NPC Dialogue](109-multi-turn-npc-dialogue.md) | Elena | P0 |
| 110 | [AI Narrative Voice Calibration](110-ai-narrative-voice-calibration.md) | Jamie | P1 |
| 111 | [LLM Response Sentence Buffering](111-llm-response-sentence-buffering.md) | Marcus | P0 |
| 112 | [AI NPC Relationship Web](112-ai-npc-relationship-web.md) | Tyler | P1 |
| 113 | [Procedural Lore Generation](113-procedural-lore-generation.md) | Lena | P1 |
| 114 | [AI Dungeon Master for Catacombs](114-ai-dungeon-master-catacombs.md) | Dave | P1 |
| 115 | [LLM Cost and Token Budget Management](115-llm-cost-token-budget.md) | Dave | P1 |
| 116 | [AI Ambient World Narration](116-ai-ambient-world-narration.md) | Sarah | P1 |
| 117 | [NPC Knowledge Boundaries](117-npc-knowledge-boundaries.md) | Jamie | P1 |
| 118 | [AI Quest Reward Balancing](118-ai-quest-reward-balancing.md) | Tyler | P1 |
| 119 | [LLM Model Switching and A/B Testing](119-llm-model-switching-ab-testing.md) | Dave | P2 |
| 120 | [AI Help and Hint System](120-ai-help-hint-system.md) | Elena | P1 |
| 121 | [NPC Adaptive Teaching](121-npc-adaptive-teaching.md) | Carol | P1 |
| 122 | [AI World State Summarization](122-ai-world-state-summarization.md) | Lena | P1 |
| 123 | [Procedural NPC Backstory Generation](123-procedural-npc-backstory.md) | Jamie | P2 |
| 124 | [AI Player Content Moderation](124-ai-player-content-moderation.md) | Priya | P0 |
| 125 | [LLM Observability and Quality Metrics](125-llm-observability-quality-metrics.md) | Dave | P1 |

### 126–150: Item Framework & Equipment

| # | Title | Persona | Priority |
|---|-------|---------|----------|
| 126 | [Item Properties Material System](126-item-properties-material-system.md) | Dave | P0 |
| 127 | [Equipment Slots and Restrictions](127-equipment-slots-restrictions.md) | Marcus | P0 |
| 128 | [Item Durability Degradation](128-item-durability-degradation.md) | Tyler | P1 |
| 129 | [Item Repair System](129-item-repair-system.md) | Tyler | P1 |
| 130 | [Item Identification and Appraisal](130-item-identification-appraisal.md) | Lena | P1 |
| 131 | [Enchantment System](131-enchantment-system.md) | Dave | P1 |
| 132 | [Cursed and Blessed Items](132-cursed-blessed-items.md) | Jamie | P1 |
| 133 | [Legendary Items with Living History](133-legendary-items-history.md) | Jamie | P1 |
| 134 | [Item Sets and Set Bonuses](134-item-sets-bonuses.md) | Tyler | P1 |
| 135 | [Consumable Items](135-consumable-items.md) | Elena | P0 |
| 136 | [Inventory Weight and Capacity](136-inventory-weight-capacity.md) | Marcus | P0 |
| 137 | [Item Comparison Tool](137-item-comparison-tool.md) | Marcus | P1 |
| 138 | [Loot Tables and Drop Rates](138-loot-tables-drop-rates.md) | Dave | P1 |
| 139 | [Item Crafting Recipes](139-item-crafting-recipes.md) | Dave | P0 |
| 140 | [Crafted Item Quality Tiers](140-crafted-item-quality-tiers.md) | Dave | P1 |
| 141 | [Item Trading and Auction House](141-item-trading-auction-house.md) | Tyler | P0 |
| 142 | [Item Socketing and Gems](142-item-socketing-gems.md) | Tyler | P1 |
| 143 | [Item Transmutation and Salvage](143-item-transmutation-salvage.md) | Dave | P1 |
| 144 | [Equipment Loadouts](144-equipment-loadouts.md) | Marcus | P1 |
| 145 | [Container Items](145-container-items.md) | Lena | P1 |
| 146 | [Item Binding Rules](146-item-binding-rules.md) | Tyler | P1 |
| 147 | [Ammunition and Consumable Stacking](147-ammunition-consumable-stacking.md) | Marcus | P1 |
| 148 | [Item Visual Descriptions for Sighted and Low-Vision Players](148-item-visual-description-sighted.md) | Sarah | P1 |
| 149 | [Item and Quest Integration](149-item-quest-integration.md) | Jamie | P1 |
| 150 | [Item Economy Balancing Tools](150-item-economy-balancing-tools.md) | Dave | P2 |

### 151–175: Mutable World & Environment

| # | Title | Persona | Priority |
|---|-------|---------|----------|
| 151 | [Destructible Objects](151-destructible-objects.md) | Jamie | P0 |
| 152 | [Persistent World State Changes](152-persistent-world-state-changes.md) | Dave | P0 |
| 153 | [Fire Propagation System](153-fire-propagation-system.md) | Dave | P1 |
| 154 | [Structural Integrity Collapse](154-structural-integrity-collapse.md) | Dave | P1 |
| 155 | [Water & Liquid Physics](155-water-liquid-physics.md) | Jamie | P1 |
| 156 | [Environmental Hazard Narration](156-environmental-hazard-narration.md) | Marcus | P0 |
| 157 | [Player-Built Barricades](157-player-built-barricades.md) | Tyler | P1 |
| 158 | [Terrain Modification](158-terrain-modification.md) | Tyler | P1 |
| 159 | [Environmental Traps](159-environmental-traps.md) | Dave | P1 |
| 160 | [Room State Versioning](160-room-state-versioning.md) | Dave | P0 |
| 161 | [Weather & Environmental Effects](161-weather-environment-effects.md) | Sarah | P1 |
| 162 | [Seasonal World Transformation](162-seasonal-world-transformation.md) | Lena | P2 |
| 163 | [Light & Darkness Mechanics](163-light-darkness-mechanics.md) | Marcus | P0 |
| 164 | [Sound Propagation & Eavesdropping](164-sound-propagation-eavesdropping.md) | Jamie | P1 |
| 165 | [Temperature System](165-temperature-system.md) | Dave | P1 |
| 166 | [Gas & Smoke Propagation](166-gas-smoke-propagation.md) | Dave | P1 |
| 167 | [Vegetation Growth & Decay](167-vegetation-growth-decay.md) | Lena | P2 |
| 168 | [Environmental Puzzles](168-environmental-puzzles.md) | Jamie | P1 |
| 169 | [NPC Environment Reactions](169-npc-environment-reactions.md) | Jamie | P1 |
| 170 | [Clan Territory & Environmental Control](170-clan-territory-environmental-control.md) | Tyler | P1 |
| 171 | [Environment Restoration & Healing](171-environment-restoration-healing.md) | Lena | P1 |
| 172 | [Underground Environment](172-underground-environment.md) | Marcus | P1 |
| 173 | [Magical Environment Effects](173-magical-environment-effects.md) | Jamie | P1 |
| 174 | [Environmental Storytelling](174-environmental-storytelling.md) | Lena | P1 |
| 175 | [Environment Diff for Returning Players](175-environment-diff-returning-players.md) | Lena | P1 |

### 176–200: Character Progression & Classes

| # | Title | Persona | Priority |
|---|-------|---------|----------|
| 176 | [Character Attributes System](176-character-attributes-system.md) | Tyler | P0 |
| 177 | [Experience & Leveling System](177-experience-leveling.md) | Tyler | P0 |
| 178 | [Character Class Selection](178-character-class-selection.md) | Marcus | P0 |
| 179 | [Skill Tree System](179-skill-tree-system.md) | Tyler | P0 |
| 180 | [Passive Abilities & Talents](180-passive-abilities-talents.md) | Tyler | P1 |
| 181 | [Class Specialization](181-class-specialization.md) | Tyler | P1 |
| 182 | [Multi-Class Dabbling](182-multi-class-dabbling.md) | Dave | P2 |
| 183 | [Prestige & Advanced Classes](183-prestige-advanced-classes.md) | Tyler | P2 |
| 184 | [Stat Allocation on Level-Up](184-stat-allocation-level-up.md) | Marcus | P0 |
| 185 | [Skill Cooldowns & Resource Management](185-skill-cooldowns-resource-management.md) | Marcus | P0 |
| 186 | [Character Biography & Backstory](186-character-biography-backstory.md) | Jamie | P1 |
| 187 | [Reputation & Faction Standing](187-reputation-faction-standing.md) | Tyler | P1 |
| 188 | [Achievement System](188-achievement-system.md) | Elena | P1 |
| 189 | [Title System](189-title-system.md) | Tyler | P1 |
| 190 | [Character Death & Resurrection](190-character-death-resurrection.md) | Marcus | P0 |
| 191 | [Rest & Recovery Mechanics](191-rest-recovery-mechanics.md) | Lena | P1 |
| 192 | [Character Aging & Legacy System](192-character-aging-legacy.md) | Jamie | P2 |
| 193 | [Pet & Companion System](193-pet-companion-system.md) | Elena | P1 |
| 194 | [Mount System](194-mount-system.md) | Tyler | P1 |
| 195 | [Crafting Specialization & Mastery](195-crafting-specialization-mastery.md) | Dave | P1 |
| 196 | [Character Stat Inspection](196-character-stat-inspection.md) | Marcus | P1 |
| 197 | [Buff & Debuff Tracking](197-buff-debuff-tracking.md) | Marcus | P0 |
| 198 | [Character Relationship Tracking](198-character-relationship-tracking.md) | Elena | P1 |
| 199 | [Seasonal Event Rewards](199-seasonal-event-rewards.md) | Carol | P2 |
| 200 | [Character Export & Stats Summary](200-character-export-stats-summary.md) | Raj | P2 |

### 201–220: Advanced Combat & Tactics

| # | Title | Persona | Priority |
|---|-------|---------|----------|
| 201 | [Party Combat System](201-party-combat-system.md) | Marcus | P0 |
| 202 | [Boss Encounter Mechanics](202-boss-encounter-mechanics.md) | Tyler | P1 |
| 203 | [Stealth and Ambush System](203-stealth-ambush-system.md) | Jamie | P1 |
| 204 | [Magic Spell System](204-magic-spell-system.md) | Lena | P0 |
| 205 | [Ranged Combat Mechanics](205-ranged-combat-mechanics.md) | Marcus | P1 |
| 206 | [Combat Positioning and Terrain](206-combat-positioning-terrain.md) | Dave | P0 |
| 207 | [Combo Attack System](207-combo-attack-system.md) | Tyler | P1 |
| 208 | [Defensive Abilities](208-defensive-abilities.md) | Marcus | P1 |
| 209 | [Siege Combat](209-siege-combat.md) | Tyler | P1 |
| 210 | [Summoning and Minions](210-summoning-minions.md) | Lena | P1 |
| 211 | [Environmental Combat Tactics](211-environmental-combat-tactics.md) | Jamie | P1 |
| 212 | [Weapon Proficiency and Mastery](212-weapon-proficiency-mastery.md) | Tyler | P1 |
| 213 | [Combat Flee and Retreat](213-combat-flee-retreat.md) | Elena | P0 |
| 214 | [Area of Effect Abilities](214-area-of-effect-abilities.md) | Dave | P1 |
| 215 | [PvP Arena Tournaments](215-pvp-arena-tournaments.md) | Marcus | P2 |
| 216 | [Combat Stance System](216-combat-stance-system.md) | Marcus | P1 |
| 217 | [Mounted Combat](217-mounted-combat.md) | Tyler | P2 |
| 218 | [Dual Wielding](218-dual-wielding.md) | Marcus | P1 |
| 219 | [Combat Taunts and Morale](219-combat-taunts-morale.md) | Tyler | P1 |
| 220 | [Post-Combat Summary and Rewards](220-post-combat-summary-rewards.md) | Elena | P0 |

### 221–240: World Depth & Exploration

| # | Title | Persona | Priority |
|---|-------|---------|----------|
| 221 | [Procedural Dungeon Generation](221-procedural-dungeon-generation.md) | Dave | P1 |
| 222 | [Fast Travel System](222-fast-travel-system.md) | Elena | P1 |
| 223 | [Hidden Areas and Secret Passages](223-hidden-areas-secret-passages.md) | Jamie | P1 |
| 224 | [World Map Navigation Aid](224-world-map-navigation-aid.md) | Marcus | P0 |
| 225 | [Wilderness Zones](225-wilderness-zones.md) | Lena | P1 |
| 226 | [Random Encounter System](226-random-encounter-system.md) | Tyler | P1 |
| 227 | [Treasure Hunting and Buried Items](227-treasure-hunting-buried-items.md) | Elena | P1 |
| 228 | [Underwater Exploration](228-underwater-exploration.md) | Jamie | P2 |
| 229 | [Portal and Teleportation Network](229-portal-teleportation-network.md) | Dave | P1 |
| 230 | [Room Puzzle System](230-room-puzzle-system.md) | Lena | P1 |
| 231 | [NPC Schedules and Living World](231-npc-schedules-living-world.md) | Jamie | P1 |
| 232 | [Weather System Depth](232-weather-system-depth.md) | Sarah | P1 |
| 233 | [Day-Night Cycle and Gameplay](233-day-night-cycle-gameplay.md) | Marcus | P1 |
| 234 | [Points of Interest Discovery](234-points-of-interest-discovery.md) | Elena | P1 |
| 235 | [Wilderness Survival Mechanics](235-wilderness-survival-mechanics.md) | Dave | P1 |
| 236 | [Environmental Audio Landscapes](236-environmental-audio-landscapes.md) | Sarah | P1 |
| 237 | [Exploration Journal](237-exploration-journal.md) | Lena | P0 |
| 238 | [Rideable Transport](238-rideable-transport.md) | Tyler | P1 |
| 239 | [Instanced Zones](239-instanced-zones.md) | Dave | P1 |
| 240 | [Exploration XP and Discovery Rewards](240-exploration-xp-discovery-rewards.md) | Elena | P1 |

### 241–255: Advanced Social & Governance

| # | Title | Persona | Priority |
|---|-------|---------|----------|
| 241 | [Player Government Elections](241-player-government-elections.md) | Tyler | P2 |
| 242 | [Justice System — Player Trials](242-justice-system-player-trials.md) | Jamie | P2 |
| 243 | [Mentorship Program](243-mentorship-program.md) | Carol | P1 |
| 244 | [Marriage & Partnership System](244-marriage-partnership-system.md) | Elena | P2 |
| 245 | [In-Game Mail System](245-in-game-mail-system.md) | Lena | P1 |
| 246 | [Player-Run Events & Storytelling](246-player-run-events-storytelling.md) | Raj | P1 |
| 247 | [Faction System & Political AI](247-faction-system-political-ai.md) | Tyler | P1 |
| 248 | [Community Bulletin Board](248-community-bulletin-board.md) | Lena | P1 |
| 249 | [Player Housing — Visiting](249-player-housing-visiting.md) | Elena | P1 |
| 250 | [Guild Alliances & Confederations](250-guild-alliances-confederations.md) | Tyler | P1 |
| 251 | [Social Emote System](251-social-emote-system.md) | Elena | P1 |
| 252 | [Player Reputation & Reviews](252-player-reputation-reviews.md) | Tyler | P1 |
| 253 | [Cross-Ability Social Features](253-cross-ability-social-features.md) | Priya | P0 |
| 254 | [Voice Chat Integration](254-voice-chat-integration.md) | Raj | P2 |
| 255 | [Community Content Curation](255-community-content-curation.md) | Carol | P1 |

### 256–265: Admin, GM & Infrastructure

| # | Title | Persona | Priority |
|---|-------|---------|----------|
| 256 | [Game Master Tools](256-game-master-tools.md) | Dave | P1 |
| 257 | [Event Scripting Engine](257-event-scripting-engine.md) | Dave | P1 |
| 258 | [Game Balance Dashboard](258-game-balance-dashboard.md) | Dave | P1 |
| 259 | [Anti-Exploit & Cheat Detection](259-anti-exploit-cheat-detection.md) | Dave | P0 |
| 260 | [Player Analytics & Funnel](260-player-analytics-funnel.md) | Priya | P1 |
| 261 | [Server Scalability Architecture](261-server-scalability-architecture.md) | Dave | P0 |
| 262 | [Backup, Recovery & Data Safety](262-backup-recovery-data-safety.md) | Dave | P0 |
| 263 | [Content Pipeline & Worldbuilding Tools](263-content-pipeline-worldbuilding-tools.md) | Jamie | P1 |
| 264 | [Accessible Admin Interface](264-accessible-admin-interface.md) | Priya | P1 |
| 265 | [Live Operations & Maintenance Mode](265-live-operations-maintenance-mode.md) | Dave | P1 |

## Persona Coverage

| Persona | Stories (001–100) | Stories (101–265) | Total |
|---------|-------------------|-------------------|-------|
| **Marcus** (blind power gamer) | 001-003, 008-010, 012, 014, 016, 021-024, 026, 034-035, 042, 044, 065, 070, 082, 085 | 111, 127, 136-137, 144, 147, 156, 163, 172, 178, 184-185, 190, 196-197, 201, 205, 208, 215-216, 218, 224, 233 | ~43 |
| **Sarah** (low-vision) | 006, 013, 025, 039, 051, 086, 098 | 116, 148, 161, 232, 236 | ~12 |
| **Dave** (MUD veteran) | 029, 032, 037, 045, 047, 061-062, 064, 071, 084 | 101-102, 107, 114-115, 119, 125-126, 131, 138-140, 143, 150, 152-154, 159-160, 165-166, 182, 195, 206, 214, 221, 229, 235, 239, 256-259, 261-262, 265 | ~46 |
| **Priya** (a11y advocate) | 004, 007, 011, 017, 031, 057, 089, 096 | 124, 253, 260, 264 | ~12 |
| **Jamie** (IF enthusiast) | 019, 030, 036, 041, 046, 049, 053, 059, 076 | 103-104, 106, 110, 117, 123, 132-133, 149, 151, 155, 164, 168-169, 173-174, 186, 192, 203, 211, 223, 228, 231, 242, 263 | ~33 |
| **Tyler** (MMO refugee) | 028, 033, 048, 055, 063, 067-069, 073, 077-078, 090 | 112, 118, 128-129, 134, 141-142, 146, 157-158, 170, 176-177, 179-181, 183, 187, 189, 194, 202, 207, 209, 212, 217, 219, 226, 238, 241, 247, 250, 252 | ~44 |
| **Elena** (blind teenager) | 005, 015, 018, 020, 027, 038, 043, 052, 066, 074-075, 081, 088, 092, 095, 100 | 109, 120, 135, 188, 193, 198, 213, 220, 222, 227, 234, 240, 244, 249, 251 | ~31 |
| **Raj** (content creator) | 040, 058, 093, 097 | 200, 246, 254 | ~7 |
| **Lena** (tabletop RPG) | 050, 054, 060, 072, 087, 091 | 105, 113, 122, 130, 145, 162, 167, 171, 175, 191, 204, 210, 225, 230, 237, 245, 248 | ~24 |
| **Carol** (parent) | 015, 020, 056, 079-080, 083, 094, 099 | 108, 121, 199, 243, 255 | ~13 |

## Priority Summary

| Priority | Count | Meaning |
|----------|-------|---------|
| **P0** | ~73 | Must-have for launch — game is broken without these |
| **P1** | ~161 | Should-have — core depth and polish |
| **P2** | ~31 | Nice-to-have — community, content creation, events |
