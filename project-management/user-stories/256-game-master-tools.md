# US-256: Game Master Tools

**Persona:** Dave — MUD veteran sysadmin who values deep system access and operational precision
**Priority:** P1
**Epic:** Admin, GM & Infrastructure

## Story
As Dave, I want a comprehensive GM panel that lets me teleport players, spawn items, trigger events, possess NPCs, observe combat, and send in-character messages so that I can run live events, resolve disputes, and maintain world quality without touching the production database directly.

## Acceptance Criteria
- [ ] GM panel accessible via `/gm panel` (role-gated); presents a navigable menu of tool categories: Player Management, World Tools, Event Tools, NPC Tools, Observation Tools, Communication; all navigable via keyboard and screen reader as a structured list
- [ ] Player Management tools: `/gm teleport [player] [room-id]` moves a player with narration; `/gm summon [player]` brings player to GM's location; `/gm freeze [player] [duration]` prevents player actions for up to 60 minutes; `/gm warn [player] [message]` sends private in-character warning; all actions logged with timestamp and GM ID
- [ ] World Tools: `/gm spawn item [item-id] [room-id] [quantity]` creates items in any room; `/gm spawn npc [npc-id] [room-id]` instantiates NPC; `/gm room describe [room-id] [text]` temporarily overrides room description; `/gm weather [region] [type]` sets weather for a region; all spawns and overrides expire on server restart unless committed via content pipeline (US-263)
- [ ] NPC possession: `/gm possess [npc-id]` allows GM to respond as NPC, intercepting player interactions; GM-typed responses are delivered as NPC dialogue; `/gm release` exits possession; during possession, NPC's normal AI is paused; possession is logged
- [ ] Observation mode: `/gm observe [player|room]` enters a silent observation state; GM sees all text in that player's context or room without being visible to players; observe mode is indicated in GM's own interface but hidden from observed parties; observe sessions are logged
- [ ] GM messaging: `/gm broadcast [region|world] [message]` sends a formatted world announcement; `/gm whisper [player] [message]` sends an OOC private message marked as [GM]; `/gm narrate [room-id] [text]` inserts a custom narration line into a room's ARIA live region
- [ ] All GM actions are logged to an immutable audit trail: action type, GM account, target (player/room/npc), parameters, timestamp; log browsable by GM lead and above via `/gm log [filter]`; logs retained for 90 days
- [ ] GM roles are tiered: Observer (observe only), Junior GM (player communication, basic tools), GM (full panel), Senior GM (spawn items, possess NPCs, world tools), Lead GM (audit log access, role assignment); permissions enforced server-side, not trust-client

## Notes
Dave's experience as a MUD sysadmin means he knows exactly what goes wrong when GM tools are poorly designed. The most common failure modes: GMs who accidentally spawn permanent items, GMs who teleport players into broken states (no-exit rooms, combat zones), and GMs who run events that crash the server. Every tool needs guardrails.

The temporary-by-default spawn model is the right guardrail for world tools. GMs can experiment and respond to live situations without creating permanent world state changes. Committing a spawn to persistence requires going through the content pipeline (US-263), which has validation. This prevents "accidental permanence" — the scenario where a GM spawns a test item and it's still there three weeks later because no one remembered to clean it up.

NPC possession is the most powerful and most dangerous tool. A GM who possesses an NPC and gives players bad information (incorrect quest directions, false lore) creates downstream problems that are hard to detect. Possession should have a visible indicator to the GM (not other players) and should log every message sent during the possession session. Senior GM level minimum for this tool.

Observation mode raises privacy questions. Players have a reasonable expectation that their private conversations are private. GM observation should be restricted to: active moderation investigations, live event monitoring, and technical debugging. The audit log's observation sessions should include a required "reason" field. Observation without a logged reason should trigger an automated alert to Lead GM.

The ARIA accessibility of the GM panel itself is important — Priya's story (US-264) addresses this in detail, but the baseline is that every GM tool must work via keyboard. Dave may be sighted, but future GMs may not be. The panel structure should mirror the game's command system: clear commands with documented syntax, tab-completion on player and room IDs, and error messages that explain what went wrong and how to fix it.

Consider a "GM event mode" that temporarily elevates all players in a zone to a special event state: reduced death penalties, enhanced loot, custom win conditions. This reduces the number of individual commands Dave needs to issue to run a live event.
