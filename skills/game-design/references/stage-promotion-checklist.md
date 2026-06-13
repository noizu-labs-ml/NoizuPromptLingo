# Stage Promotion Checklist

Master checklist for promoting a game concept from `flesh/` (monolithic README) to `stage/` (full directory structure). This checklist combines universal requirements with genre-specific gates.

## How to Use

1. Copy this checklist into `stage/{slug}/CHECKLIST.md`
2. Check off each item as it's completed
3. Add the applicable genre checklist(s) from [genre-checklists.md](genre-checklists.md)
4. A concept is "staged" when all Universal items and all applicable Genre items are checked

---

## Phase 1: Directory Scaffolding

Before writing any content, create the directory structure per [game-concept-directory-spec.md](game-concept-directory-spec.md).

- [ ] `stage/{slug}/` directory created
- [ ] `README.md` — Executive summary (NOT a copy of flesh README)
- [ ] `CHECKLIST.md` — This file, with genre checklists appended
- [ ] `design/` directory with core-loop.md, meta-loop.md, mechanics/, economy/, monetization/
- [ ] `world/` directory with world-bible.md, geography/, factions/, bestiary/, items/, lore/
- [ ] `narrative/` directory with story-spine.md, characters/, quests/, dialogue/
- [ ] `players/` directory with persona-mapping.md, player-journeys/, user-stories/
- [ ] `production/` directory with team-plan.md, milestone-schedule.md, budget-breakdown.md, tech-stack.md, risk-register.md
- [ ] `assets/` directory with art-direction.md, audio-direction.md, prompts/, references/

---

## Phase 2: Design Extraction

Extract and expand content from the flesh README into individual design files.

### Core Design
- [ ] `design/core-loop.md` — Core loop diagram + per-step breakdown with session length
- [ ] `design/meta-loop.md` — Meta progression with axes, caps, and unlock cadence
- [ ] `design/mechanics/primary-mechanic.md` — Full deep dive (inputs, outputs, constraints, edge cases, skill ceiling)
- [ ] `design/mechanics/secondary-mechanics.md` — All supporting systems with interaction points
- [ ] `design/mechanics/difficulty-progression.md` — Complexity curve table across game stages

### Economy
- [ ] `design/economy/currency-design.md` — All currencies with sources, sinks, earn/spend rates
- [ ] `design/economy/progression-pacing.md` — XP curve, level timings, unlock schedule
- [ ] `design/economy/balance-sheet.md` — Filled economy spreadsheet (not a template)

### Monetization
- [ ] `design/monetization/revenue-model.md` — Model choice with justification and projections
- [ ] `design/monetization/iap-catalog.md` — Every purchasable item (if applicable)
- [ ] `design/monetization/battle-pass.md` — Season structure (if applicable)

---

## Phase 3: World Building

Decompose the world section into discrete, referenceable files.

### Foundation
- [ ] `world/world-bible.md` — Setting overview, cosmology, rules, tone
- [ ] `world/geography/world-map.md` — Zone descriptions + connectivity diagram
- [ ] `world/geography/zone-index.md` — Table of all zones with properties

### Inhabitants
- [ ] `world/factions/faction-index.md` — All factions with relationships
- [ ] At least 2 individual faction files: `world/factions/{name}.md`
- [ ] `world/bestiary/creature-index.md` — All creatures with type, habitat, threat
- [ ] At least 1 creature category file: `world/bestiary/{category}.md`

### Objects
- [ ] `world/items/item-index.md` — All items with category, rarity, source
- [ ] At least 1 item category file: `world/items/{category}.md`

### History
- [ ] `world/lore/timeline.md` — Chronological world history
- [ ] At least 1 lore deep-dive: `world/lore/{topic}.md`

### Maps
- [ ] At least 1 map media prompt: `world/geography/maps/{name}.media.prompt`
- [ ] Overworld/zone connectivity represented as diagram or ASCII map

---

## Phase 4: Narrative

Break the narrative section into character sheets, quest outlines, and dialogue direction.

- [ ] `narrative/story-spine.md` — 8-point story structure
- [ ] `narrative/characters/character-index.md` — All named characters
- [ ] At least 3 individual character sheets: `narrative/characters/{name}.md`
- [ ] `narrative/quests/main-quest-outline.md` — Main storyline quest chain
- [ ] `narrative/quests/side-quest-catalog.md` — Side quests by zone/faction
- [ ] `narrative/dialogue/tone-guide.md` — Voice, register, vocabulary constraints

---

## Phase 5: Player Research

Formalize player personas and user stories into discrete files.

### Personas
- [ ] `players/persona-mapping.md` — 3-4 personas from library with fit analysis
- [ ] At least 2 player journey files: `players/player-journeys/{persona-id}-journey.md`

### User Stories
- [ ] `players/user-stories/user-story-index.md` — All stories indexed by ID, category, persona, priority
- [ ] At least 25 user stories distributed across category files
- [ ] `players/user-stories/exploration.md`
- [ ] `players/user-stories/core-mechanics.md`
- [ ] `players/user-stories/narrative.md`
- [ ] `players/user-stories/progression.md`
- [ ] `players/user-stories/accessibility.md`
- [ ] `players/user-stories/social.md` (if multiplayer/social features exist)

---

## Phase 6: Production Planning

Formalize production estimates into discrete documents.

- [ ] `production/team-plan.md` — Roles × headcount × phase × cost
- [ ] `production/milestone-schedule.md` — Monthly milestones with deliverables
- [ ] `production/budget-breakdown.md` — Per-category budget with contingency
- [ ] `production/tech-stack.md` — Engine, backend, tools, CI/CD, platform targets
- [ ] `production/risk-register.md` — Top 5+ risks with probability, impact, mitigation

---

## Phase 7: Asset Direction

Create art/audio direction and seed media prompts for key assets.

### Direction Documents
- [ ] `assets/art-direction.md` — Visual pillars, color palette, style references, comparable games
- [ ] `assets/audio-direction.md` — Music style, SFX philosophy, VO scope, reference tracks
- [ ] `assets/references/mood-board.md` — Curated visual references and style targets

### Media Prompts (Minimum Set)
- [ ] `assets/prompts/marketing/key-art.media.prompt` — Hero image for store/marketing
- [ ] `assets/prompts/characters/{protagonist}.media.prompt` — Main character concept
- [ ] `assets/prompts/environments/{first-zone}.media.prompt` — Tutorial/starting area
- [ ] `assets/prompts/ui/hud-mockup.media.prompt` — Core gameplay HUD
- [ ] `assets/prompts/creatures/{first-enemy}.media.prompt` — First enemy encounter
- [ ] `assets/prompts/audio/main-theme.media.prompt` — Main theme music direction

### Media Prompts (Extended — for Medium+ concepts)
- [ ] At least 3 additional environment prompts for key zones
- [ ] At least 3 additional character prompts (NPCs, antagonist, companion)
- [ ] At least 3 additional creature prompts across threat tiers
- [ ] `assets/prompts/ui/main-menu.media.prompt`
- [ ] `assets/prompts/ui/inventory-screen.media.prompt`
- [ ] `assets/prompts/marketing/store-screenshots.media.prompt`
- [ ] At least 1 zone-specific ambient audio prompt

---

## Phase 8: Genre-Specific Gate

Append the applicable genre checklist(s) from [genre-checklists.md](genre-checklists.md) below this line.

> Example: For a "survival horror roguelite," append both the **Roguelike/Roguelite** and **Survival/Survival Horror** checklists.

---

## Phase 9: Final Review

- [ ] README.md links to every file in the directory (no dead links)
- [ ] All tables contain real data (no "TBD" or placeholder rows)
- [ ] Numbers are internally consistent (budget matches team × timeline × rates)
- [ ] Art direction is consistent across all media prompts
- [ ] User stories reference existing persona IDs, not invented ones
- [ ] Mechanics are described in enough detail to prototype
- [ ] Document stands alone — no references to external docs not included in the directory
- [ ] Genre-specific checklist(s) fully completed

---

## Completion Summary

| Phase | Status | Notes |
|-------|--------|-------|
| 1. Scaffolding | ☐ | |
| 2. Design | ☐ | |
| 3. World | ☐ | |
| 4. Narrative | ☐ | |
| 5. Players | ☐ | |
| 6. Production | ☐ | |
| 7. Assets | ☐ | |
| 8. Genre Gate | ☐ | Genre(s): ___ |
| 9. Final Review | ☐ | |
