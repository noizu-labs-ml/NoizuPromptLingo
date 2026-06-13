# US-237: Exploration Journal

**Persona:** Lena — Tabletop RPG player, sighted, editorial, short sessions
**Priority:** P0
**Epic:** World Depth & Exploration

## Story
As Lena, I want a persistent exploration journal that automatically records my travels, discovered lore, quest progress, and NPC relationships so that I can return after a week away and quickly re-orient without relying on external notes.

## Acceptance Criteria
- [ ] Journal accessible via J key as a dedicated accessible document region; organized with heading hierarchy: Locations, Lore, Quests, NPCs, Achievements
- [ ] Location entries auto-populated on first visit with: zone name, region, type, brief description snippet, first visit date — no manual action required from player
- [ ] Lore entries auto-added when player reads inscriptions, examines lore items, or completes lore-revealing interactions; each entry shows source location and date found
- [ ] Quest progress section mirrors active quest log with completed quests archived; each quest shows: title, giver, current step, known objectives, and player notes field
- [ ] NPC relationship section: named NPCs the player has interacted with, current relationship status (neutral/friendly/hostile/allied), last interaction summary, and known facts about the NPC
- [ ] Player notes field available on every journal entry: free-text annotation that SR reads as part of the entry; Lena can write "She mentioned the key is in the north tower" against an NPC entry
- [ ] Journal search: full-text search across all entries with results listed by section and entry; keyboard-navigable result list
- [ ] Session summary auto-generated at logout: "This session: visited 3 new locations, completed 1 quest, found 2 lore items, earned 1,200 XP" — delivered as a brief structured summary and added to journal archive

## Notes
Lena plays in short sessions and may return days later not remembering exactly where she was or what she was doing. The journal is her continuity device — it must be comprehensive enough that she can rely on it instead of external notes. Auto-population on first visit is the critical design decision: if Lena has to manually record things, she won't, and the journal will be incomplete. The player notes field is the editorial feature Lena specifically needs: she thinks like a GM who annotates their campaign notes. The NPC section is the relationship tracker — knowing that the blacksmith is "friendly" and "mentioned the key is in the north tower" is the kind of detail Lena maintains obsessively in tabletop play. Journal search is what makes the journal a reference tool rather than a log: Lena should be able to search "key" and find every journal entry mentioning a key. The session summary at logout gives her a sense of accomplishment and a starting point for next session. P0 priority reflects that without the journal, short-session players like Lena cannot maintain continuity and will disengage. All journal content must be SR-navigable with heading structure — NVDA and VoiceOver both handle heading navigation efficiently, making the journal fast to skim even with many entries.
