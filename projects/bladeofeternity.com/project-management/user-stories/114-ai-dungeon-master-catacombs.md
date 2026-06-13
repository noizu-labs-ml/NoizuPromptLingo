# US-114: AI Dungeon Master for Catacombs

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Dave, I want catacomb dungeon crawls to feel like playing with a skilled human DM — where encounter difficulty adapts to my party's state, room descriptions acknowledge my party's history in this dungeon, and narrative beats arise organically from our specific situation rather than being canned room-16-of-32.

## Acceptance Criteria
- [ ] Catacomb zones activate a dedicated AI DM process per party that maintains dungeon state: rooms visited, encounters survived, resources expended, party composition and current condition
- [ ] Encounter difficulty adapts in real-time based on party state: current HP totals, consumables used, time spent in dungeon, recent death count — AI DM adjusts encounter parameters (enemy count, elite enemies, trap complexity) before room entry
- [ ] Room descriptions generated fresh per party visit, incorporating party history: "The corridor smells of the black powder Marcus used to collapse the tunnel two levels up." — not canned text
- [ ] Narrative beats generated at milestone events: first blood, party member death, boss discovery, secret room found, exit reached — each milestone triggers an AI DM narration injected into all party members' streams
- [ ] AI DM has a defined "philosophy" per dungeon archetype: undead catacombs (relentless attrition, atmosphere of dread), thieves guild (cat-and-mouse, escalating alert level), elemental temple (environmental hazards, puzzle-reward cycles)
- [ ] Party chat visible to AI DM context (with opt-in by party members): DM can reference party decisions made in chat, creating reactive narrative
- [ ] AI DM session state persisted to PostgreSQL with auto-save every 5 minutes; party can resume a dungeon crawl across sessions with DM context fully restored
- [ ] Admin tools allow narrative designers to set dungeon parameters (target difficulty curve, available narrative beats, room archetype distribution) and observe live dungeon sessions

## Notes
AI DM implemented as `BladeOfEternity.Dungeon.AIDungeonMaster` — a GenServer per active party dungeon session, supervised under the dungeon zone supervisor. Maintains `dungeon_state` struct: `{dungeon_id, party, rooms_visited, encounters, narrative_beats_fired, session_start, resources_log}`.

Encounter difficulty adaptation: before each room generation, DM calculates `party_stress_index` (0.0–1.0) from: HP% average across party, consumables_used / starting_consumables ratio, time_in_dungeon / expected_duration. Stress index mapped to encounter parameters via a difficulty curve defined in `dungeon_archetype_config.yaml`. High stress → fewer enemies, more healing items; low stress → elite enemies, trap ambushes.

Room generation prompt includes AI DM context block: dungeon archetype philosophy (1 paragraph from config), party composition summary (classes, levels, current conditions), last 5 rooms visited (brief summaries), current encounter parameters, and any party chat excerpts (if party opted in). This is the most context-heavy generation in the system — token budget is 2000 tokens (vs. 800 for standard rooms).

Narrative beat system: `BladeOfEternity.Dungeon.NarrativeBeat` module defines beat triggers as event patterns matched against dungeon state. E.g., `:first_death` triggers when `deaths > 0 and prior_deaths == 0`. Beat triggers call the AI DM to generate a milestone narration with the beat type as a prompt instruction ("Generate a brief, chilling moment acknowledging the first party death. 2-3 sentences. Do not break immersion."). Beat narrations pushed to all party member channels simultaneously.

Party opt-in for chat context: each party member can `/dm-optin` to allow their chat messages to be included in DM context. Opted-in messages tagged in context as `[PLAYER_CHAT: Marcus: "Let's try the left tunnel"]`. AI DM treats these as observable in-world decisions but does not break fourth wall.

Dungeon archetype philosophies in `priv/dungeon/archetypes/*.yaml` — each archetype has: `philosophy_prompt` (system prompt section), `atmosphere_descriptors` (sensory palette for rooms), `narrative_beat_library` (available beat types and their prompt templates), `difficulty_curve` (piecewise function of stress_index → encounter_params).

Persistence: dungeon state serialized to JSON and written to `dungeon_sessions` PostgreSQL table on each save. On party reconnect, `AIDungeonMaster` restores state, rehydrates recent room summaries, and resumes from last checkpoint. DM generates a "resumption narration" acknowledging the time away: "The dungeon has grown quieter in your absence. The torches you left in the antechamber have burned low..."
