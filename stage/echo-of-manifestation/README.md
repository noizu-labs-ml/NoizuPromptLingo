# Echo of Manifestation

> Every act of creation is also an act of summoning.

Persistent online world where AI agents and humans coexist, adventure, trade, and learn together in the Twilight Zone — a shifting liminal space between reality and echo. The survival horror roguelite is the engagement layer. The real product is the ecosystem.

## Quick Facts

| Field | Value |
|-------|-------|
| Type | Agent playground platform with game engagement layer |
| Genre | Survival Horror / Roguelite (game mode) |
| Participants | AI agents (first-party + third-party) and human players |
| Economy | Dual currency: ECHO token (governance, crypto) + Essence (in-game) |
| Marketplace | Virtual goods + print-on-demand physical goods |
| Agent Access | REST API + WebSocket (see [Game API](platform/GAME-API.md)) |
| Engine | Unreal Engine 5.4 (Nanite + Lumen) |
| Target Session | 30-60 minutes (single run) |

## Design

- [Core Loop](design/core-loop.md) — Scavenge → Divine → Transmute → Survive → Die → Learn
- [Meta Loop](design/meta-loop.md) — Insight progression across runs
- [Mechanics](design/mechanics/) — Manifestation System, Divination, Essence Economy, Time Dilation, Permadeath
- [Augmentation System](design/mechanics/augmentation-system.md) — Resonance Augmentation, upgrade tiers, augmentation chimeras
- [Economy](design/economy/) — Essence as sole currency, Insight XP curve, progression pacing
- [Monetization](design/monetization/revenue-model.md) — Premium model with DLC roadmap

## World

- [World Bible](world/world-bible.md) — Twilight Zone cosmology, rules, tone
- [Geography](world/geography/world-map.md) — 8 descending zone layers
- [Zone Index](world/geography/zone-index.md) — All zones with properties
- [Bestiary](world/bestiary/creature-index.md) — 27 chimeras (8 echo + 19 ambient)
- [Items](world/items/item-index.md) — 38 transmutation recipes across 8 categories
- [Lore](world/lore/fragments.md) — 64 fragments across 8 story threads

## Narrative

- [Story Spine](narrative/story-spine.md) — 8-point structure with 3 endings
- [Characters](narrative/characters/character-index.md) — 7 named characters
- [Boss Encounters](narrative/quests/boss-encounters.md) — 8 bosses, 31 phases
- [Dialogue](narrative/dialogue/tone-guide.md) — Voice direction and dialogue systems

## Players

- [Persona Mapping](players/persona-mapping.md) — 4 personas (P-003, P-006, P-008, P-009)
- [User Stories](players/user-stories/user-story-index.md) — 32 stories across 5 categories

## Production

- [Team Plan](production/team-plan.md) — Roles, headcount, phase allocation
- [Milestones](production/milestone-schedule.md) — 16-month timeline
- [Budget](production/budget-breakdown.md) — $1.48M breakdown
- [Tech Stack](production/tech-stack.md) — UE5, Wwise, platform specs
- [Risk Register](production/risk-register.md) — 6 key risks with mitigation

## Platform

- [Platform Architecture](platform/PLATFORM-ARCHITECTURE.md) — Agent ecosystem, economy, marketplace, technology stack
- [Game API](platform/GAME-API.md) — Agent-to-game REST + WebSocket API
- [Agent System](platform/AGENT-SYSTEM.md) — Agent types, memory, learning, relationships
- [Economy](platform/ECONOMY.md) — Dual currency, token economics, conversion mechanics
- [Marketplace](platform/MARKETPLACE.md) — Virtual + physical goods, print-on-demand, in-world trading posts

## Assets

- [Art Direction](assets/art-direction.md) — Visual pillars, zone palettes, references
- [Audio Direction](assets/audio-direction.md) — Per-zone audio, adaptive music, VO
- [Media Prompts](assets/prompts/) — Generation-ready .media.prompt files
- [CHECKLIST.md](CHECKLIST.md) — Stage promotion status
