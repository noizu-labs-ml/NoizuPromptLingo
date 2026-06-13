# US-103: NPC Conversational Memory

**Persona:** Jamie — Interactive fiction enthusiast (26, sighted, narrative quality)
**Priority:** P0
**Epic:** LLM & AI Systems

## Story
As Jamie, I want NPCs to remember what I've told them in past conversations — my name, my quests, my confessions, my promises — so that returning to an NPC feels like a continuation of a relationship rather than meeting a stranger with the same face.

## Acceptance Criteria
- [ ] Each player-NPC pair maintains a persistent memory graph in Apache AGE with nodes for conversation topics, player-disclosed facts, promises made, emotional moments, and time-stamped interaction history
- [ ] Memory injection pipeline retrieves relevant memories for the current conversation context, ranks by recency and emotional weight, and injects top memories into dialogue prompt within a 400-token budget
- [ ] NPCs reference past interactions naturally in generated dialogue ("Last time you were here, you mentioned you were hunting bandits in the Ashwood — did you find what you sought?")
- [ ] Conversation summaries are generated and stored in AGE at conversation end (when player types GOODBYE, BYE, or idles 5+ minutes), compressing the exchange into 3-5 key facts
- [ ] Memory graph supports a "forget" edge allowing NPC amnesia events (curse, injury, death/resurrection) to mark memories as inaccessible without deleting them (preserving audit trail)
- [ ] Players can query their NPC relationship status via EXAMINE NPC RELATIONSHIP, returning a screen-reader-friendly summary of key memories the NPC holds
- [ ] Memory retrieval uses vector similarity search via pgvector (or AGE property index) to find semantically related memories, not just keyword match
- [ ] Cross-session memory persists across server restarts; memory graph integrity verified at session start via AGE query health check

## Notes
Apache AGE schema: player node `(:Player {player_id})` — NPC node `(:NPC {npc_id, name})` — Memory node `(:Memory {id, content, summary, emotional_weight, created_at, compressed_at})`. Edges: `(:Player)-[:DISCLOSED {at}]->(:Memory)`, `(:Memory)-[:ABOUT {topic}]->(:NPC)`, `(:Memory)-[:REMEMBERED_BY]->(:NPC)`.

Memory injection pipeline (`BladeOfEternity.AI.Memory.Injector`) runs as part of the dialogue context assembler (US-101). It issues a Cypher query to AGE retrieving the 10 most emotionally-weighted memories for the player-NPC pair, then scores each against the current conversation intent (extracted from last player utterance via lightweight embedding), returning top 5 for injection.

Emotional weight computed from NPC mood delta during conversation (US-104), player action type (confession, request, threat, gift), and conversation outcome (quest accepted, trade completed, hostility triggered). Stored as float 0.0–1.0 on Memory node.

Conversation summarization runs as async Task after conversation close event, using a dedicated LLM call with a tight summarization prompt: "Summarize the 3-5 most memorable facts disclosed in this conversation." Result stored as `compressed` Memory node linked from raw transcript.

Memory budget pressure handled by summarization cascade: if player-NPC memory count exceeds 50 nodes, the oldest 25 are batch-summarized into a single "historical" node, freeing graph space while preserving relationship continuity.

EXAMINE NPC RELATIONSHIP command issues AGE query for top 10 memories by weight, formats as a bulleted ARIA-friendly list: "Mirella remembers: You sought the Ashwood bandits. You paid her debt to the tanner. You promised to return with word of her brother."
