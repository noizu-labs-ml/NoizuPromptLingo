# US-221: Procedural Dungeon Generation

**Persona:** Dave — MUD veteran sysadmin, sighted, deep systems focused
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Dave, I want catacombs and wilderness dungeons to be procedurally generated with unique layouts, encounters, and treasure so that I never fully exhaust the game's content and each delve feels like genuine exploration rather than memorized repetition.

## Acceptance Criteria
- [ ] Dungeon generation seeded per dungeon-instance on first player entry; same dungeon seed produces same layout for all players entering that instance, supporting party exploration
- [ ] Room generation uses parameterized templates: room type (chamber, corridor, intersection, dead end), size category (small/medium/large/vast), feature slots (empty, trap, container, enemy group, environmental hazard)
- [ ] Each room narrated on entry with distinct description generated from template parameters + LLM flavor: no two rooms described identically even with same feature set
- [ ] Encounter tables vary by dungeon type (undead catacombs, bandit hideout, ancient ruin), depth level, and player level bracket; enemy groups scaled to challenge
- [ ] Dungeon map represented as a navigable text structure: accessible via M key showing visited rooms as a list with connections: "You are in Chamber B4 — exits: north (corridor to B3, visited), east (unknown), south (locked door)"
- [ ] Treasure distribution follows rarity curves with depth bonus: deeper rooms have higher probability of rare/epic loot
- [ ] Dead ends have a higher probability of containing significant treasure or lore items, rewarding thorough exploration
- [ ] Dungeon state (opened chests, cleared rooms, defeated encounters) persists for 24 hours after last player exit; reset announced on re-entry if reset has occurred

## Notes
Dave is the MUD veteran — he understands that procedural generation done well creates a sense of world that handcrafted content alone cannot sustain. The seed-per-instance design means parties can explore together and have a shared consistent experience while still having unique dungeons from other groups. The text map as a navigable list is the screen-reader-appropriate equivalent of a minimap — Dave should be able to call it up and get his bearings without visual reference. Room description uniqueness is non-trivial: using LLM to add flavor to template-generated rooms prevents the "same room, different label" problem of naive procedural generation. The depth-based loot curve rewards persistence: Dave will push into deeper rooms specifically because the system tells him treasure quality increases with depth. Dungeon state persistence (24 hours) allows multi-session exploration of a single dungeon, important for Lena's short-session persona but relevant to Dave as well who may need to log off mid-delve. Reset notification on re-entry ("This dungeon has been reset — it feels new again") prevents confusing stale map data.
