# Game Concept Directory Specification

The canonical directory structure for a fully staged game concept. This spec defines what "done" looks like when a concept graduates from a monolithic README (flesh/) to a production-ready design package (stage/).

## Pipeline Context

```
idea-log/{slug}.md          → Raw seed (1-2 paragraphs)
flesh/{slug}/README.md      → Monolithic design doc (all sections in one file)
stage/{slug}/               → Expanded directory (this spec)
```

The flesh stage proves the concept is worth building. The stage directory proves the concept is *buildable*.

## Canonical Directory Structure

```
stage/{slug}/
├── README.md                          # Executive summary + vision + links to all sections
├── CHECKLIST.md                       # Master checklist (general + genre-specific)
│
├── design/
│   ├── core-loop.md                   # Core loop diagram + breakdown + session design
│   ├── meta-loop.md                   # Run-to-run / session-to-session progression
│   ├── mechanics/
│   │   ├── primary-mechanic.md        # Deep dive on the central system
│   │   ├── secondary-mechanics.md     # Supporting systems and interactions
│   │   └── difficulty-progression.md  # Complexity curve across game stages
│   ├── economy/
│   │   ├── currency-design.md         # Currencies, exchange rates, sources/sinks
│   │   ├── progression-pacing.md      # Level curve, unlock timing, XP tables
│   │   └── balance-sheet.md           # Economy spreadsheet (filled, not template)
│   └── monetization/
│       ├── revenue-model.md           # Model choice + justification + projections
│       ├── iap-catalog.md             # Every purchasable item with price points
│       └── battle-pass.md             # Season structure (if applicable)
│
├── world/
│   ├── world-bible.md                 # Setting overview, cosmology, rules of the world
│   ├── geography/
│   │   ├── world-map.md              # Zone/region descriptions + connectivity
│   │   ├── zone-index.md             # Table of all zones with properties
│   │   └── maps/                     # Map diagrams (ASCII, mermaid, or .media.prompt for visual maps)
│   │       ├── overworld.media.prompt
│   │       └── {zone-name}.media.prompt
│   ├── factions/
│   │   ├── faction-index.md          # All factions: name, type, alignment, relationships
│   │   └── {faction-name}.md         # Per-faction deep dive (one file per major faction)
│   ├── bestiary/
│   │   ├── creature-index.md         # All creatures/enemies: type, habitat, threat level
│   │   └── {creature-category}.md    # Grouped creature entries (e.g., undead.md, beasts.md)
│   ├── items/
│   │   ├── item-index.md             # All items: category, rarity, source
│   │   └── {item-category}.md        # Grouped item entries (e.g., weapons.md, consumables.md)
│   └── lore/
│       ├── timeline.md               # World history as a chronological timeline
│       ├── creation-myth.md          # Origin story / cosmology
│       └── {lore-topic}.md           # Deep dives (e.g., the-great-war.md, magic-system.md)
│
├── narrative/
│   ├── story-spine.md                # 8-point story structure
│   ├── characters/
│   │   ├── character-index.md        # All named characters with role, faction, arc
│   │   └── {character-name}.md       # Per-character sheet (one per major character)
│   ├── quests/
│   │   ├── main-quest-outline.md     # Main storyline quest chain
│   │   └── side-quest-catalog.md     # Side quests organized by zone/faction
│   └── dialogue/
│       └── tone-guide.md             # Voice, register, vocabulary constraints per character
│
├── players/
│   ├── persona-mapping.md            # Which personas from library fit this game + why
│   ├── player-journeys/
│   │   └── {persona-id}-journey.md   # Per-persona predicted play experience
│   └── user-stories/
│       ├── user-story-index.md       # All stories: ID, category, persona, priority
│       ├── exploration.md            # User stories: exploration category
│       ├── core-mechanics.md         # User stories: core mechanics category
│       ├── narrative.md              # User stories: narrative/story category
│       ├── progression.md            # User stories: progression/unlocks category
│       ├── social.md                 # User stories: multiplayer/social category
│       └── accessibility.md          # User stories: accessibility/QoL category
│
├── production/
│   ├── team-plan.md                  # Roles, headcount, phase allocation, cost
│   ├── milestone-schedule.md         # Monthly milestones from pre-prod through live ops
│   ├── budget-breakdown.md           # Per-category budget with contingency
│   ├── tech-stack.md                 # Engine, backend, tools, CI/CD, platform targets
│   └── risk-register.md             # Top risks with mitigation strategies
│
└── assets/
    ├── art-direction.md              # Visual pillars, color palette, style references
    ├── audio-direction.md            # Music style, SFX philosophy, VO scope
    ├── prompts/
    │   ├── characters/
    │   │   ├── {character-name}.media.prompt      # Character portrait/concept art
    │   │   └── {character-name}-sheet.media.prompt # Character turnaround sheet
    │   ├── environments/
    │   │   ├── {zone-name}.media.prompt            # Environment concept art
    │   │   └── {zone-name}-details.media.prompt    # Environmental props/details
    │   ├── creatures/
    │   │   └── {creature-name}.media.prompt        # Creature concept art
    │   ├── items/
    │   │   └── {item-category}.media.prompt        # Item icons or concept art
    │   ├── ui/
    │   │   ├── hud-mockup.media.prompt             # HUD/UI concept
    │   │   ├── main-menu.media.prompt              # Main menu mockup
    │   │   └── inventory-screen.media.prompt       # Inventory/shop UI
    │   ├── marketing/
    │   │   ├── key-art.media.prompt                # Box art / store listing hero image
    │   │   ├── store-screenshots.media.prompt      # App store screenshot concepts
    │   │   └── trailer-storyboard.media.prompt     # Trailer key frames
    │   └── audio/
    │       ├── main-theme.media.prompt             # Music direction for main theme
    │       ├── {zone-name}-ambient.media.prompt    # Per-zone ambient audio
    │       └── sfx-palette.media.prompt            # Core SFX style direction
    └── references/
        └── mood-board.md             # Visual references, comparable game screenshots, style targets
```

## File Format Conventions

### README.md (Executive Summary)

The staged README is NOT a copy of the flesh README. It's a short executive summary (under 200 lines) with links to every component:

```markdown
# {Game Title}

> {One-line tagline}

## Vision
{2-3 sentence vision statement}

## Quick Facts
| Field | Value |
|-------|-------|
| Genre | ... |
| Engine | ... |
| Platforms | ... |
| Monetization | ... |
| Target Session | ... |
| Team Size | ... |
| Timeline | ... |
| Budget | ... |

## Design
- [Core Loop](design/core-loop.md)
- [Meta Loop](design/meta-loop.md)
- [Mechanics](design/mechanics/)
- [Economy](design/economy/)
- [Monetization](design/monetization/)

## World
- [World Bible](world/world-bible.md)
- [Geography](world/geography/)
- [Factions](world/factions/)
- [Bestiary](world/bestiary/)
- [Items](world/items/)
- [Lore](world/lore/)

## Narrative
- [Story Spine](narrative/story-spine.md)
- [Characters](narrative/characters/)
- [Quests](narrative/quests/)

## Players
- [Persona Mapping](players/persona-mapping.md)
- [User Stories](players/user-stories/)

## Production
- [Team Plan](production/team-plan.md)
- [Milestones](production/milestone-schedule.md)
- [Budget](production/budget-breakdown.md)
- [Tech Stack](production/tech-stack.md)

## Assets
- [Art Direction](assets/art-direction.md)
- [Audio Direction](assets/audio-direction.md)
- [Media Prompts](assets/prompts/)
```

### .media.prompt File Format

Media prompt files are structured generation requests for AI image/audio/video tools. Each file produces one asset or a coherent set of related assets.

```markdown
---
type: image | audio | video | 3d
style: concept-art | pixel-art | painterly | photorealistic | flat-vector | low-poly
aspect: 16:9 | 1:1 | 9:16 | 4:3 | 2:1
resolution: 1024x1024 | 1920x1080 | ...
tool: midjourney | dall-e | stable-diffusion | suno | udio | runway
tags: [character, portrait, hero, fantasy]
---

# {Asset Name}

## Context
{Where this asset appears in the game. What it needs to communicate to the player.}

## Subject
{Detailed description of what to generate. Be specific about composition, pose, expression, environment, lighting.}

## Style Notes
{Art direction constraints: color palette, line weight, level of detail, comparable references.}

## Negative Constraints
{What to avoid: wrong tone, anachronistic elements, visual noise that conflicts with readability.}

## Variants (optional)
- Variant A: {description — e.g., day version}
- Variant B: {description — e.g., night version}
- Variant C: {description — e.g., corrupted/damaged version}
```

### User Story Format

```markdown
## {Category}: {Subcategory}

### US-{NNN}: {Title}
- **As a** {persona ID + name}
- **I want** {specific goal}
- **So that** {concrete benefit}
- **Priority:** Must / Should / Could / Won't
- **Acceptance Criteria:**
  - [ ] {Testable criterion 1}
  - [ ] {Testable criterion 2}
```

### Character Sheet Format

```markdown
# {Character Name}

| Field | Value |
|-------|-------|
| Role | Protagonist / Antagonist / Companion / NPC / Boss |
| Faction | {faction name or Independent} |
| First Appearance | {zone or quest} |
| Arc | {one-line arc summary} |

## Personality
{2-3 sentences: voice, motivation, quirks}

## Gameplay Function
{What this character does mechanically: quest giver, vendor, combat ally, boss fight}

## Visual Design
{Brief description: build, silhouette, key visual motifs, color association}

## Relationships
| Character | Relationship | Tension |
|-----------|-------------|---------|
| ... | ... | ... |

## Key Dialogue Beats
1. {First meaningful line / reveal}
2. {Midpoint shift}
3. {Resolution / final line}
```

### Zone Description Format

```markdown
# {Zone Name}

| Field | Value |
|-------|-------|
| Biome | {terrain type} |
| Depth/Level | {where in progression} |
| Connections | {adjacent zones} |
| Threat Level | {1-10} |
| Primary Resource | {what the player gathers here} |

## Description
{3-4 sentences: atmosphere, key landmarks, emotional tone}

## Gameplay Role
{Why this zone exists mechanically: what the player does here, what it teaches}

## Encounters
| Enemy | Frequency | Behavior | Drops |
|-------|-----------|----------|-------|
| ... | ... | ... | ... |

## Points of Interest
1. {Landmark}: {description + gameplay function}
2. ...

## Environmental Hazards
| Hazard | Effect | Avoidance |
|--------|--------|-----------|
| ... | ... | ... |

## Audio/Visual Notes
{Ambient sound, lighting, color temperature, weather}
```

## Minimum File Counts by Concept Complexity

| Concept Size | Total Files | Characters | Zones | User Stories | Media Prompts |
|-------------|-------------|------------|-------|-------------|---------------|
| **Small** (mobile casual) | 25-35 | 3-5 | 3-5 | 25-35 | 8-12 |
| **Medium** (indie/mid-core) | 40-60 | 8-15 | 5-10 | 35-50 | 15-25 |
| **Large** (AA/console) | 60-100 | 15-30 | 10-20 | 50-80 | 25-40 |
| **Massive** (AAA/MMO) | 100+ | 30+ | 20+ | 80+ | 40+ |

## Promotion Criteria (flesh → stage)

A concept is ready for stage promotion when:

1. The flesh README has all 12 required sections filled with real data
2. The concept has a clear, differentiated identity (not a clone of an existing game)
3. Core loop is mechanically sound (playable in reader's head)
4. Monetization model is justified and internally consistent
5. At least 25 user stories exist
6. Budget and timeline are realistic for the stated team size
