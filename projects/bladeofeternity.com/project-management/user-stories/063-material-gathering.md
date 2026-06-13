# US-063: Material Gathering with Accessibility-First Feedback

**Persona:** Elena — Blind Teenager, VoiceOver on iPhone
**Priority:** P1
**Epic:** Crafting System

## Story
As Elena, I want to gather crafting materials from the world using simple commands so that I can participate in the crafting economy alongside my sighted friends without needing visual cues to find resources.

## Acceptance Criteria
- [ ] `GATHER` or `FORAGE` in a resource zone announces available materials and yield range before committing (e.g., "This clearing holds wild herbs. You could gather Nightshade (common) or Silverleaf (rare). Time: ~3 rounds.")
- [ ] Gathering progress is announced in round-by-round text, not silent timers
- [ ] On mobile (VoiceOver), gather commands are accessible from a command palette with swipe navigation
- [ ] Resource zones announce their type when entered: "You enter the Ashwood Grove. Materials here: timber, resin, fungi."
- [ ] Failed gathers (empty node, skill check fail) give meaningful feedback, not silence
- [ ] Material inventory is accessible via `MATERIALS` command with quantity, grade, and weight announced

## Notes
Elena plays on iPhone with VoiceOver. Gathering should not rely on visual minimap markers. Zone entry announcements are the primary discovery mechanism. Consider a `SENSE MATERIALS` command that describes the resource landscape of the current zone in tactile/atmospheric prose.
