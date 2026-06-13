# US-122: AI World State Summarization

**Persona:** Lena — Tabletop RPG player (38, sighted, editorial typography, short sessions)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Lena, I want to log back in after a few days away and immediately know what I've missed — what happened in the world, how my clan is doing, which NPCs I care about have changed — so that I can pick up exactly where I left off without spending my limited session time piecing together what happened.

## Acceptance Criteria
- [ ] On login after an absence of more than 4 hours, the system generates a personalized "What You Missed" summary delivered before the player enters the game world
- [ ] Summary is personalized to player's known relationships: only includes world events involving NPCs the player has interacted with, zones the player has visited, quests the player has active, and clans the player belongs to
- [ ] Summary covers: world events (battles, political changes, disasters), NPC relationship changes (deaths, promotions, mood shifts), clan activity (members' achievements, clan quests completed), and market changes for items the player trades
- [ ] Delivery format optimized for screen readers: structured as a bulleted ARIA list with sections (World Events, Your Companions, Clan News, Market Update), each section a navigable heading, maximum 300 words total
- [ ] Summary generation completes within 3 seconds of login; if generation takes longer, player enters game normally and summary is delivered as a secondary announcement within 10 seconds
- [ ] Players can request the summary again during session via RECAP command — retrieves cached summary from session start (no re-generation)
- [ ] Summary tone matches narrative voice (US-110) and feels like a bard's chronicle rather than a system report: "In your absence, the garrison at Thornvale has fallen to the northern raiders. Aldric's forge stands cold."
- [ ] Absence threshold configurable by player: some players may want summary after only 1 hour away; default 4 hours, range 1–72 hours, saved to profile

## Notes
Summary generation implemented as `BladeOfEternity.AI.WorldSummarizer` — called as async Task on login when absence duration exceeds threshold. Player session start is non-blocking; summary is delivered via PubSub to player's channel when ready.

World event query: `SELECT * FROM world_events WHERE occurred_at > last_login AND relevance_scope && player_scope` — relevance_scope is a PostgreSQL array of zone_ids/npc_ids/faction_ids; player_scope is computed from player's `visited_zones`, `interacted_npcs`, `faction_memberships`. Efficient because world_events stores scope as GiST-indexed array for overlap operator performance.

NPC changes query: AGE Cypher query — for each NPC in player's interaction graph, retrieve events since last_login: `MATCH (p:Player {id: $pid})-[:INTERACTED]->(n:NPC) MATCH (n)-[:EXPERIENCED]->(e:Event) WHERE e.occurred_at > $last_login RETURN n, e`. Events: `:died`, `:relocated`, `:promoted`, `:mood_shift`, `:quest_given_to_another`.

Clan activity: `SELECT * FROM clan_activity_log WHERE clan_id = player.clan_id AND created_at > last_login ORDER BY significance DESC LIMIT 10`. Significance scored by: quest completion > member death/join > achievement > market transaction.

Summary prompt structure: assembles the world event list, NPC change list, clan activity list, and market deltas into a structured JSON context block. Prompt instructs: "Write a 200–300 word summary in the style of a bard's chronicle — second person, narrative voice, past tense. Organize by: World News, Your Companions, Clan Report, Market Shifts. Each section 1–3 sentences. Only include sections with content. Omit technical game terminology."

Structured ARIA delivery: the AI-generated prose summary is post-processed by `BladeOfEternity.AI.SummaryFormatter` which identifies section headers ("World News:", etc.) and wraps them as ARIA heading levels in the React frontend. The AI is prompted to use specific section header strings that the formatter pattern-matches against.

RECAP command: stores summary in ETS per player session (`{player_id, :session_summary}`). RECAP retrieves and re-delivers. Summary expires from ETS on logout or session end (8 hours max).

Absence threshold setting: stored in `player_preferences` table. Retrieved at login to determine whether summary should fire. 0 means never summarize; useful for power users who log in frequently and find it redundant.
