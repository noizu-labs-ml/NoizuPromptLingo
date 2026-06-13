# US-123: Procedural NPC Backstory Generation

**Persona:** Jamie — Interactive fiction enthusiast (26, sighted, narrative quality)
**Priority:** P2
**Epic:** LLM & AI Systems

## Story
As Jamie, I want even minor NPCs — the stable hand, the dockworker, the beggar — to have depth that reveals itself when I take time to look or talk to them, so that the world feels populated by people rather than props, and I can stumble into unexpected stories in unlikely places.

## Acceptance Criteria
- [ ] Every named NPC receives a procedurally generated backstory on first player interaction (EXAMINE or TALK), stored permanently after generation — covers origin, motivation, a defining event, and a secret or ambition
- [ ] Backstory is layered: surface layer revealed via EXAMINE (appearance and immediate manner), second layer via dialogue ("Tell me about yourself"), third layer via extended conversation or specific prompt ("You seem troubled by something...")
- [ ] Generated backstories integrate with the world lore graph (US-113): NPCs reference real factions, real places, real historical events — backstory generation prompt includes relevant lore context for the NPC's home region and archetype
- [ ] Backstory elements feed forward into dialogue and quest generation: NPC's defining event and ambition are injected into dialogue context, allowing AI-generated conversation to naturally surface backstory without scripted triggers
- [ ] Backstory secrets can become quest seeds: the EXAMINE NPC system flags certain backstory elements as `quest_potential: true` and reports them to the quest generation system for possible player engagement
- [ ] Backstories are self-consistent across all access methods: EXAMINE, TALK, ASK ABOUT THEMSELVES all draw from the same stored backstory — never contradict
- [ ] Unnamed/ambient NPCs (crowd filler) receive a lighter treatment: a single-sentence character essence ("A dockworker who clearly resents his work and watches ships depart with longing.") used for ambient flavor without full backstory overhead
- [ ] Backstory generation queue handles bulk NPC population: when a new zone opens, all named NPCs in that zone are queued for background backstory generation, completing before any player is likely to encounter them

## Notes
`BladeOfEternity.NPC.BackstoryGenerator` — GenServer handling backstory generation requests. Queue-based, with concurrency limit (5 parallel generation tasks) to control LLM cost. Priority: player-triggered (immediate context needed) > zone-population queue (background).

Backstory data model: `npc_backstories` PostgreSQL table — `{npc_id, origin_region, defining_event, motivation, secret, ambition, surface_description, full_backstory_json, generated_at}`. AGE NPC node updated with references to lore entities mentioned in backstory (faction membership, place of origin, historical event involvement).

Generation prompt structure:
- System: narrative voice spec (US-110), world lore summary for NPC's region (AGE query), NPC archetype description
- User: "Generate a backstory for [name], a [archetype] in [location]. Cover: origin (1-2 sentences), a defining life event (2-3 sentences), their current motivation (1 sentence), a secret or hidden ambition they wouldn't volunteer (1 sentence). Integrate with the following lore: [lore_context]. Surface description for EXAMINE: 1 sentence of appearance and immediate impression."

Layer delivery: `BackstoryDelivery` module maps EXAMINE → surface_description, `TELL ME ABOUT YOURSELF` → origin + motivation + defining_event summary, extended dialogue topic `about_themselves` → full backstory narrative. Layers stored separately in `full_backstory_json` as `{surface, second, third}` keys.

Quest potential flagging: after generation, a lightweight classifier prompt runs: "Does this backstory contain an element that could become a player quest? If yes, describe the quest seed in one sentence." If classifier returns a seed, `quest_seeds` table gets a new entry linked to `npc_id`. Quest generator (US-106) queries `quest_seeds` when generating NPC-initiated quests.

Lore integration: before generation, Cypher query retrieves: all factions present in NPC's assigned region, historical events tied to that region, notable NPCs in the region the NPC archetype would know of. This context injected into prompt — ensures backstory references real world elements, not invented ones. Prevents backstory from contradicting established canon (US-113 lore validation).

Unnamed NPC treatment: ambient NPC records have `named: false` flag. `BackstoryGenerator` detects this and uses a "character essence" micro-prompt (50-token output) instead of full backstory. Stored in `npc_backstories.surface_description` only — no full backstory JSON. Delivers on first EXAMINE; no further layers.

Zone-population queue: triggered by `{:zone_opened, zone_id}` event. `BackstoryGenerator` queries all named NPCs in zone without existing backstories, enqueues them at low priority. Oban job processes queue at up to 5 concurrent workers during off-peak hours (midnight–8 AM UTC), ensuring backstories ready before prime-time player traffic.
