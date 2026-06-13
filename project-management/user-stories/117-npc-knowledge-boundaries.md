# US-117: NPC Knowledge Boundaries

**Persona:** Jamie — Interactive fiction enthusiast (26, sighted, narrative quality)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Jamie, I want NPCs to only know what they would realistically know — the blacksmith doesn't know the king's war strategy, the stable hand knows the roads but not the court gossip — so that information has weight and asking the right person feels meaningful rather than every NPC being an omniscient quest marker.

## Acceptance Criteria
- [ ] Each NPC has a knowledge domain graph in Apache AGE defining: what topics they know (professional expertise, local gossip, personal history, faction affiliation, traveled regions), knowledge depth per topic (surface/working/expert), and information they are forbidden to know
- [ ] AI dialogue generation receives a "knowledge constraints" block derived from the NPC's knowledge graph: "WHAT [NPC] KNOWS: local trades (expert), town roads (working), king's court (surface hearsay only), Ashwood dungeon (none — do not invent)"
- [ ] When player asks an NPC about a topic outside their knowledge domain, the NPC expresses plausible ignorance in character: the blacksmith doesn't say "I don't know" — he says "Court matters? I keep my nose in my forge and out of noble business."
- [ ] Knowledge domain assignment implemented at NPC creation: archetype-based defaults applied automatically (blacksmith gets trades/metals/local commerce), with manual overrides for named NPCs via admin panel
- [ ] Knowledge graph supports knowledge propagation: NPCs can learn new facts via world events or player disclosure (with explicit story justification). A blacksmith who witnessed a battle now knows surface information about that battle.
- [ ] Players can assess NPC knowledge indirectly via dialogue ("What do you know about the northern road?") — NPC responds relative to their actual knowledge depth without the system exposing game-mechanical labels
- [ ] Knowledge boundary violations in AI output (NPC knowing something they shouldn't) logged as quality flags and fed back to prompt engineering; habitual violations trigger prompt template review
- [ ] Rare "rumor" knowledge allowed: NPCs can know vague, possibly-wrong information about topics adjacent to their knowledge domain, labeled internally as `:rumor` depth — generates hedged, uncertain dialogue

## Notes
AGE schema for NPC knowledge: `(:NPC)-[:KNOWS {topic, depth, source, acquired_at}]->(:KnowledgeTopic {name, category})`. Depth values: `:none`, `:rumor`, `:surface`, `:working`, `:expert`. KnowledgeTopic categories: `:geography`, `:politics`, `:trade`, `:magic`, `:history`, `:personal`, `:faction`, `:combat`.

Knowledge constraint injection: `BladeOfEternity.AI.KnowledgeConstraints.for_npc/2` issues Cypher query retrieving all knowledge edges for an NPC, formats result as a structured constraint block for the dialogue prompt:
```
KNOWLEDGE CONSTRAINTS FOR ALDRIC THE SMITH:
- EXPERT: metalworking, local trade routes, forge materials
- WORKING: Thornvale town layout, local guild politics
- SURFACE (hearsay): King's war preparations (Aldric has heard soldiers talk)
- RUMOR: Ashwood dungeon ("they say there's old magic in there, but I wouldn't know")
- NONE: Court politics, magical theory, Vasek's criminal connections
```

The "NONE" section is critical — it lists topics the AI must not have the NPC discuss even vaguely. This is the hardest constraint to enforce via prompting and the most important. Few-shot examples in the knowledge constraints prompt template demonstrate the NPC redirecting knowledgeably: not a blank refusal, but a plausible in-character deflection.

Knowledge propagation: world event handlers check if an NPC was in a location during a significant event (battle, festival, crime). If so, `KnowledgeGraph.add_knowledge/3` adds an AGE edge with `depth: :surface, source: :witnessed` for the event topic. Player disclosure: if player explicitly tells an NPC something ("The king plans to march north"), creates a `depth: :surface, source: :player_told` edge — NPC can now reference this in future conversations.

Knowledge violation detection: post-generation validation in `BladeOfEternity.AI.KnowledgeAuditor` (async, sampled at 15% of outputs). Uses an LLM call: "Does this dialogue contain information about topics not in the NPC's knowledge domain? Topics known: [...]. Topics forbidden: [...]." Returns `{:ok}` or `{:violation, topic, severity}`. Violations written to quality log, aggregated per NPC archetype.

Rumor mechanics: `:rumor` depth knowledge generates dialogue with uncertainty markers: "I've heard tell that...", "Word is...", "Mind you, I can't say for certain, but..." — generated via prompt instruction when the queried topic matches a `:rumor` depth edge. Rumors may be intentionally inaccurate (30% chance of a plausible false detail injected by the rumor generation prompt).
