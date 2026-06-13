# US-112: AI NPC Relationship Web

**Persona:** Tyler — MMO refugee (22, sighted, growth/agency/clans)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Tyler, I want NPCs to have their own social network of alliances, rivalries, family bonds, and trade relationships so that the world feels politically complex — where impressing the blacksmith's ally has ripple effects, and undermining a merchant's rival earns me the merchant's trust.

## Acceptance Criteria
- [ ] Apache AGE graph stores NPC-NPC relationships as typed edges: ALLY, RIVAL, FAMILY, TRADE_PARTNER, DEBTOR, EMPLOYER, SWORN_ENEMY — each with strength (0.0–1.0) and history properties
- [ ] NPC dialogue generation includes relevant relationship context from AGE: when player asks an NPC about another NPC, the relationship type and strength shape the response tone and information willingness
- [ ] Relationship web affects quest generation: NPC quest-givers offer missions related to their relationships (help my ally, investigate my rival, collect a debt, deliver to my trade partner)
- [ ] Players can query relationship information via dialogue ("What do you think of Aldric the smithy?") and receive relationship-appropriate responses from NPCs who know that relationship
- [ ] Relationship changes propagate through the graph: player actions affecting one NPC (helping them, harming them) trigger relationship-weighted notifications to connected NPCs via game event system
- [ ] World events create relationship changes at scale: a war declaration creates RIVAL edges between faction-affiliated NPCs on opposing sides; festivals strengthen ALLY edges between town NPCs
- [ ] Players can VIEW RELATIONSHIPS as a text-accessible summary: "In this town: Mirella and Aldric are trade partners. Vasek and the innkeeper are rivals. The tanner family are kin to the stable master."
- [ ] Relationship web visualization available in admin panel as a rendered graph (AGE Cypher to JSON, rendered via D3 or similar) for narrative design and QA purposes

## Notes
AGE schema for NPC relationships: `(:NPC {npc_id, name, faction, archetype})-[:RELATION {type, strength, established_at, notes}]->(:NPC)`. Direction is meaningful: `A-[:EMPLOYER]->B` means A employs B; `B-[:DEBTOR]->A` means B owes A. Bidirectional relationships (ALLY, RIVAL) stored as two directed edges.

Relationship injection in dialogue prompt: AGE Cypher query retrieves all relationships for the conversant NPC within 2 hops (direct and indirect connections), ranked by strength. Top 10 relationships injected as a "SOCIAL CONTEXT" block in the dialogue prompt: "ALDRIC'S RELATIONSHIPS: [TRADE_PARTNER → Mirella (strong)], [RIVAL → Vasek (moderate)], [FAMILY → Petra (strong)], [DEBTOR → Innkeeper (weak)]."

Relationship-based information willingness: a lookup table in `npc_interaction_config.yaml` maps `{relationship_type, strength_tier}` to information willingness modifiers. A strong RIVAL relationship means the NPC will share negative information about the rival freely but refuse to share positive. A strong ALLY means the NPC protects the ally's secrets.

Relationship propagation: `BladeOfEternity.NPC.RelationshipPropagator` subscribes to `npc_events` PubSub. On `{:player_helped, npc_id}` event: AGE query retrieves all NPCs with ALLY edges to `npc_id`, triggers positive disposition delta toward player for each (weighted by relationship strength). On `{:player_harmed, npc_id}`: RIVAL edges trigger positive disposition for rivals (enemy of my enemy), ALLY edges trigger negative.

Quest generation integration: `BladeOfEternity.Quest.Generator` queries the quest-giver NPC's top 5 relationships before generating a quest, passing relationship context to the prompt. This produces quests that reference real NPC relationships rather than invented ones, supporting coherence (US-106).

VIEW RELATIONSHIPS command: Cypher query returns all NPC pairs in current zone with relationship edges. Formatted as a bulleted accessible list grouped by relationship type. Result cached per zone with 5-minute TTL (relationships change slowly).
