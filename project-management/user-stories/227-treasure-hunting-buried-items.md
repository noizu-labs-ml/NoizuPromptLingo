# US-227: Treasure Hunting and Buried Items

**Persona:** Elena — Blind teenager, VoiceOver+iOS, social focused
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Elena, I want to follow treasure maps and hunt for buried caches so that exploration has a specific goal-directed layer that feels like a real adventure, and the moment of discovery is genuinely exciting to share with friends.

## Acceptance Criteria
- [ ] Treasure maps obtainable via quest rewards, NPC purchase, dungeon loot, or player trading; each map is an item readable via SR: "Worn Parchment: 'Three paces north of the old millstone, in the shadow of the broken oak, something waits for those who dig'"
- [ ] Map clues use environmental landmarks described in room narration; landmarks must match the described location when physically visited
- [ ] Digging action available in outdoor rooms using shovel or appropriate tool; physics engine determines if terrain is diggable (soft earth, beach sand) vs impossible (stone, frozen ground)
- [ ] Digging without a treasure at that location yields: "Your shovel turns up cold earth and stones — nothing here" — not a system error, a narrative result
- [ ] Successful discovery narrated as a multi-sentence revelation: "Your shovel strikes something solid. You clear the dirt with growing excitement — a weathered iron chest, sealed with a design you don't recognize, emerges from the earth"
- [ ] Chest contents revealed as a structured list after the discovery narration; items added to inventory with confirmation
- [ ] Treasure hunting milestones tracked (caches found: X) with achievement announcements; milestone narration unique to treasure-finding context
- [ ] Treasure maps shareable with party members: viewing a shared map in party shows the same clues to all; group discovery moment narrated to all present

## Notes
Elena's social motivation means the shared discovery moment matters as much as the loot. The group map sharing and simultaneous discovery narration creates a "we found it!" moment she can share with friends. Map clues as pure prose (not coordinates or system references) are the interactive fiction tradition applied to this game: "in the shadow of the broken oak" requires reading the environment. The broken oak must actually be described in the room where the treasure is buried — this requires the map clue generation to reference real room description content, which is a design constraint on the treasure placement system. Digging without result must give a narrative non-result ("cold earth and stones") rather than a system message — maintaining fiction even in failure. The physics engine diggability check prevents jarring "you can't dig here" messages in inappropriate terrain; the game should instead say "The cobblestones are solid beneath your feet — there's no way to dig here." Chest contents as a structured list after the discovery narration respects the emotional arc: first the revelation (narrative), then the accounting (structured data). Treasure maps as readable items with actual prose text requires the item system to support rich text content for some items.
