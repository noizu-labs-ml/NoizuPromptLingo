# US-263: Content Pipeline & Worldbuilding Tools

**Persona:** Jamie — Interactive fiction enthusiast who wants narrative quality and internal consistency across the world
**Priority:** P1
**Epic:** Admin, GM & Infrastructure

## Story
As Jamie, I want staff tools for adding rooms, NPCs, quests, items, and lore without writing code so that the world can grow quickly and narratively consistently, and so that I can preview and validate new content before players encounter it.

## Acceptance Criteria
- [ ] Content authoring is done through a web-based staff interface (role-gated: Content Editor+); interface provides forms for each content type: Room (name, description, exits, region, flags), NPC (name, description, dialogue tree, combat stats, loot table, faction affiliation), Quest (title, giver NPC, objectives, rewards, narrative text per stage), Item (name, description, type, stats, rarity, loot table weight), Lore Entry (title, category, body text, linked rooms/NPCs)
- [ ] All text fields in the content editor support markdown; preview renders markdown as the game's text output format (plain text with ARIA-appropriate structure, not HTML-rendered); preview mode shows exactly what a screen reader user would hear
- [ ] Content validation runs before publication: checks include exit consistency (Room A exits east to Room B; Room B must have a west exit to Room A unless flagged as one-way), NPC dialogue tree completeness (all branches reach a terminal node), item stat sanity (item level vs. zone level vs. stat ranges within configured bounds), lore reference validity (linked rooms and NPCs exist)
- [ ] Preview mode: content in draft state is accessible in a sandboxed preview environment; staff can walk through new areas, interact with draft NPCs, accept draft quests, and verify the experience before publishing; preview environment resets daily
- [ ] Publishing workflow: Content Editor drafts content → Content Reviewer approves (or requests changes) → Lead Content or GM Lead publishes; all workflow transitions logged with author, reviewer, publisher, timestamps; published content versioned with ability to roll back to previous version
- [ ] Bulk import: rooms, NPCs, and items can be imported from YAML files for large worldbuilding sprints; YAML schema documented and validated on import; import preview shows what would be created/modified before committing; import failures produce a line-numbered error report
- [ ] Content search: staff can search all content by type, text content, region, status (draft/review/published), and author; search results as a navigable list; useful for finding "all NPCs in the Northern Forest region" or "all quests offering Void Dragon scales as reward"
- [ ] Lore consistency checker: automated tool that scans all published lore entries and flags: NPC name inconsistencies (same character referred to by different names), timeline contradictions (event A described as happening before event B in one lore entry, after in another), broken lore links (reference to a deleted NPC or room)

## Notes
Jamie's concern is narrative quality and consistency. A world where one lore entry says the king died in the First Age and another says he ruled during the Second Age is immersion-breaking. The lore consistency checker is the technical tool that enforces narrative discipline — it's not a replacement for good editorial process, but it's a safety net.

The exit consistency validation is the most important technical validation because broken exits are the most common content error and the most disruptive to players (especially blind players navigating by text). A room that says "You can go east" but the eastern neighbor has no western exit creates a navigation dead-end that a sighted player might work around visually but a screen reader user cannot.

The preview environment must be accessible to screen reader users. If Jamie and content editors are running screen readers (and some will be, given the project's values), the preview environment must work with NVDA, JAWS, and VoiceOver. Testing new content via screen reader before publishing is how you catch "this room description says 'you see a map on the wall' which is useless to me."

The YAML bulk import is Dave's tool as much as Jamie's. Large worldbuilding sprints are more efficient as batch imports than as individual web form submissions. The schema should be well-documented with examples and a validation tool that can be run locally before submitting the import. The import preview (show what would change before committing) is the critical safety feature — a bulk import that overwrites existing content without warning is catastrophic.

The publishing workflow (draft → review → publish) is appropriate for a game where published content is immediately seen by players. The review step catches not just errors but tone and consistency issues. The reviewer role should have an editorial checklist: Does this NPC's dialogue match their established personality? Does this room's description match the region's aesthetic? Is the quest's reward proportional to its difficulty?

Version control for content (rollback capability) is the safety net for publishing mistakes. If a quest is published with a broken objective that makes it uncompleat-able, Dave needs to roll back to the previous version and investigate without taking the whole quest system offline. Each content item should have a version history browsable in the staff interface.
