# US-223: Hidden Areas and Secret Passages

**Persona:** Jamie — IF enthusiast, sighted, narrative quality focused
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Jamie, I want hidden areas and secret passages that reward attentive reading and creative exploration so that discovering a secret feels like genuine detective work, not random button pressing.

## Acceptance Criteria
- [ ] Hidden elements discoverable through multiple methods: examining specific described objects, using a Perception check, applying relevant items (torch in darkness, key on suspicious lock), or following NPC hints
- [ ] Room descriptions contain embedded clues to hidden elements for attentive readers: "The northern wall has an unusual seam where the stones don't quite align" hints at a secret passage without making it explicit
- [ ] Examine action available on any described object; reveals additional detail, may trigger Perception check for hidden element discovery
- [ ] Perception check results narrated without revealing the roll: success reveals the secret ("You run your fingers along the seam and find a hidden mechanism"), failure gives nothing ("The wall seems solid here")
- [ ] Discovery moments narrated as genuine revelations: multi-sentence LLM description that conveys the satisfaction of finding what was hidden
- [ ] Multiple routes to discovery: a puzzle requiring intelligence, a brute-force search requiring time investment, a Perception check requiring high skill, or an NPC rumor requiring social interaction
- [ ] Hidden areas contain unique content: lore items, rare crafting materials, shortcut passages, or encounters unavailable through normal exploration
- [ ] Secret found status tracked in exploration journal (US-237) so Jamie can review what has been found and where; "secrets found: 3/5" per zone without spoiling unfound secrets

## Notes
Jamie approaches the game as interactive fiction — the quality of the prose clue matters as much as the mechanical reward. Embedded description clues are the mark of good IF design: they're honest (the information is there) but not intrusive (a non-attentive reader won't be interrupted by a popup saying "SECRET HERE"). The key design constraint is that blind players must have equal access to secret discovery: clues must be in text descriptions navigable via SR, not in subtle visual details. Multiple discovery paths mean different player types can succeed: Dave finds it with a high Perception roll, Jamie finds it by reading carefully, Tyler finds it by buying a rumor from an NPC. The "secrets found: X/Y" counter in the journal without spoiling what's unfound respects player agency — it tells Jamie whether to keep looking without telling her where to look. Secret area content must justify the effort: if secrets always contain interesting lore or genuinely useful items, players learn to seek them; if secrets are empty rooms, players stop caring.
