# US-175: Environment Diff for Returning Players

**Persona:** Lena — Tabletop RPG player (38, sighted, editorial, short sessions)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Lena, I want rooms I return to after an absence to greet me with an AI-generated description of what has changed since I was last there — "the bookshelf you remember is gone, toppled across the doorway; scorch marks climb the north wall" — so that returning to familiar spaces is a discovery experience and the world's ongoing life is legible in what has changed.

## Acceptance Criteria
- [ ] Player session state records `last_visited_version` per room: when a player leaves a room, the current room version is stored against their player+room pair
- [ ] On room entry, if the room's current version > `last_visited_version` for this player, a diff is computed: `Room.diff(room_id, last_visited_version, current_version)` returns structured change list
- [ ] Diff is passed to the LLM as structured context alongside room description prompt; the LLM is instructed to integrate changes naturally into the room description, prioritizing notable changes in the opening sentences
- [ ] The generated diff narration anchors to the player's memory: "the bookshelf you remember," "where the fire pit stood," "the passage that was clear when you left" — creating continuity with the player's previous experience
- [ ] Changes are prioritized for narration: structural changes (collapsed walls, blocked passages) are mentioned first; environmental changes (scorch marks, water damage) second; object changes (missing/moved items) third; cosmetic changes (seasonal decoration, new graffiti) last
- [ ] If the player was absent across a major event (fire, flood, siege, seasonal change), the diff narration frames this as the "story of what happened": "In your absence, this quarter burned. What you knew as the guild hall is a shell — roofless, gutted, the stone walls cracked from heat."
- [ ] Diff narration is appropriately scaled to absence duration: a few minutes generates no diff; an hour might generate a brief note; a day produces a sentence; a week produces a paragraph; months produce a full environmental story
- [ ] Players can explicitly request a change summary: `what changed here` or `what happened here` triggers on-demand diff narration even if the automatic diff already fired on entry

## Notes
This feature is the culmination of the versioning system (US-160) and the environmental storytelling system (US-174): the technical infrastructure exists; the question is how to narrate the diff compellingly. The LLM prompt for diff narration is the critical design element.

The prompt should include: the structured diff (list of changes with timestamps and actors), the player's last_visited_version state snapshot (what they remember), and the current state snapshot. The LLM instruction should be: "Narrate the changes as though writing a character's experience of returning to a place they remember. Prioritize changes by significance. Anchor changes to specific details the character would recognize. Express uncertainty where change causes are unknown."

The "anchoring to player's memory" principle is what distinguishes good diff narration from a change log. "The north wall has new scorch marks" is a change log. "The bookcase you leaned against while talking to the innkeeper is gone — in its place, char marks climb the stone, still slightly warm" is a return experience. The LLM must have access to the player's previous experience of the room (from their last_visited_version snapshot) to make this connection.

Absence duration scaling prevents the system from being noisy for players who leave and return quickly, while ensuring that long absences receive appropriately rich contextual narration. The configurable thresholds should default to: < 5 minutes = no diff; 5-60 minutes = brief note if major changes; 1-24 hours = sentence or two; 1-7 days = paragraph; > 7 days = full environmental story.

For Lena's short-session pattern, this feature is particularly valuable: she plays 45 minutes, leaves for several days, returns. The diff narration is her re-entry into the world's ongoing story — it catches her up, reorients her, and immediately gives her something to react to. It should read like the best kind of session recap: specific, evocative, and forward-pointing.
