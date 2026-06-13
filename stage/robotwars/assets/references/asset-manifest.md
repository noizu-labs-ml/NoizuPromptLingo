# Asset Manifest: TheRobotWars

> Complete catalog of media prompt files, their IDs, types, dependencies, and generation status.

---

## Summary

| Category | Count | Types |
|----------|-------|-------|
| Characters | 6 | image |
| Environments | 6 | image |
| UI Mockups | 3 | image |
| Audio | 4 | audio |
| Prototypes | 3 | html |
| Diagrams | 3 | svg |
| Marketing | 2 | image |
| **Total** | **27** | |

---

## Characters

| ID | File | Subject | Type | Service | Depends On | Status |
|----|------|---------|------|---------|------------|--------|
| char-001-adara-voss | `characters/mayor-adara-voss.media.prompt` | Mayor Adara Voss -- Human politician, Hearthfield | image | gemini | -- | pending |
| char-002-bibliotheque | `characters/bibliotheque.media.prompt` | Bibliotheque -- NEI librarian, Hearthfield | image | gemini | -- | pending |
| char-003-cael-meridian-born | `characters/cael-meridian-born.media.prompt` | Cael Meridian-Born -- Synthetic furniture maker | image | gemini | -- | pending |
| char-004-old-hawthorn | `characters/old-hawthorn.media.prompt` | Old Hawthorn -- Fay dryad guardian | image | gemini | -- | pending |
| char-005-mercurial-ash | `characters/mercurial-ash.media.prompt` | Mercurial Ash -- Species-ambiguous merchant | image | gemini | -- | pending |
| char-006-resonance | `characters/resonance.media.prompt` | Resonance -- NEI philosopher, Ashlands | image | gemini | -- | pending |

---

## Environments

| ID | File | Subject | Type | Service | Depends On | Status |
|----|------|---------|------|---------|------------|--------|
| env-001-hearthfield | `environments/hearthfield-meadows.media.prompt` | Hearthfield starter meadow, golden hour | image | gemini | -- | pending |
| env-002-millhaven | `environments/millhaven-market.media.prompt` | Millhaven market square, afternoon bustle | image | gemini | -- | pending |
| env-003-copperwood | `environments/copperwood-forest.media.prompt` | Copperwood forest, Heartwood area | image | gemini | -- | pending |
| env-004-ashlands | `environments/ashlands-servers.media.prompt` | Ashlands Central Core at twilight | image | gemini | -- | pending |
| env-005-thornmere | `environments/thornmere-swamp.media.prompt` | Thornmere bioluminescent night | image | gemini | -- | pending |
| env-006-ironvale | `environments/ironvale-mountains.media.prompt` | Ironvale terraced settlement at dusk | image | gemini | -- | pending |

---

## UI Mockups

| ID | File | Subject | Type | Service | Depends On | Status |
|----|------|---------|------|---------|------------|--------|
| ui-001-hud | `ui/hud-overlay.media.prompt` | In-game HUD overlay | image | gemini | -- | pending |
| ui-002-marketplace | `ui/marketplace-screen.media.prompt` | Marketplace trading interface | image | gemini | -- | pending |
| ui-003-workshop | `ui/workshop-crafting.media.prompt` | Workshop/crafting workbench interface | image | gemini | -- | pending |

---

## Audio

| ID | File | Subject | Type | Service | Depends On | Status |
|----|------|---------|------|---------|------------|--------|
| audio-001-main-theme | `audio/main-theme.media.prompt` | Main title theme, acoustic folk | audio | suno | -- | pending |
| audio-002-copperwood-ambience | `audio/copperwood-ambience.media.prompt` | Copperwood biome music, celtic ambient | audio | suno | -- | pending |
| audio-003-ashlands-ambience | `audio/ashlands-ambience.media.prompt` | Ashlands biome music, minimalist electronic | audio | suno | -- | pending |
| audio-004-workshop-sfx | `audio/workshop-sfx.media.prompt` | Workshop crafting sound effects | audio | suno | -- | pending |

---

## Prototypes

| ID | File | Subject | Type | Service | Depends On | Status |
|----|------|---------|------|---------|------------|--------|
| proto-001-service-loop | `prototypes/service-delivery-loop.media.prompt` | Service economy core loop prototype | html | anthropic | -- | pending |
| proto-002-crafting | `prototypes/crafting-minigame.media.prompt` | Crafting mechanic prototype | html | anthropic | -- | pending |
| proto-003-exploration | `prototypes/zone-exploration.media.prompt` | Zone exploration and mapping prototype | html | anthropic | -- | pending |

---

## Diagrams

| ID | File | Subject | Type | Service | Depends On | Status |
|----|------|---------|------|---------|------------|--------|
| diag-001-economy-flow | `diagrams/economy-flow.media.prompt` | SPARK/Credits economy flow diagram | svg | anthropic | -- | pending |
| diag-002-tech-tree | `diagrams/tech-tree.media.prompt` | Crafting recipe tech tree | svg | anthropic | -- | pending |
| diag-003-faction-relationships | `diagrams/faction-relationships.media.prompt` | Faction relationship map (all species) | svg | anthropic | -- | pending |

---

## Marketing

| ID | File | Subject | Type | Service | Depends On | Status |
|----|------|---------|------|---------|------------|--------|
| mktg-001-key-art | `marketing/key-art-sunrise.media.prompt` | Key art: sunrise over Millhaven with all species | image | gemini | -- | pending |
| mktg-002-species-lineup | `marketing/species-lineup.media.prompt` | Character lineup of all 5 species | image | gemini | char-001, char-002, char-003, char-004 | pending |

---

## Dependency Graph

```
char-001-adara-voss ─────────────────────────┐
char-002-bibliotheque ───────────────────────┤
char-003-cael-meridian-born ─────────────────┼──▶ mktg-002-species-lineup
char-004-old-hawthorn ───────────────────────┘

All other prompts are independent and can be generated in any order.
```

---

## Generation Priority

Recommended generation order for maximum early impact:

1. **Key Art** (`mktg-001-key-art`) -- Establishes the visual identity for all stakeholders
2. **Hearthfield** (`env-001-hearthfield`) -- The player's first view of the world
3. **Character Portraits** (`char-001` through `char-004`) -- Core cast for narrative grounding
4. **Main Theme** (`audio-001-main-theme`) -- Audio identity
5. **Service Loop Prototype** (`proto-001-service-loop`) -- Core mechanic validation
6. **Economy Diagram** (`diag-001-economy-flow`) -- System communication for the team
7. **Remaining environments, UI, audio, prototypes, diagrams** -- Production pipeline

---

*All prompts reference `assets/art-direction.md` for visual specifications and `assets/audio-direction.md` for audio specifications. Update status column as assets are generated.*
