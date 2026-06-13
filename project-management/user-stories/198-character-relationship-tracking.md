# US-198: Character Relationship Tracking

**Persona:** Elena — Blind teenager using VoiceOver on iOS, social and expressive
**Priority:** P1
**Epic:** Character Progression & Classes

## Story
As Elena, I want to track my character's relationships with friends, rivals, mentors, and clan-mates — with history that affects AI social interactions — so that my social connections feel meaningful and persistent across sessions.

## Acceptance Criteria
- [ ] Relationship types tracked: Friend, Rival, Mentor (you are the student), Protege (you are the mentor), Clan-mate, Neutral (default), and Blocked; player assigns relationship type manually or accepts system suggestions based on interaction history
- [ ] Relationship panel accessible via character menu: keyboard-navigable list organized by relationship type; SR reads each entry: "Kira — Friend — 14 shared adventures — last seen: yesterday"
- [ ] Interaction history tracked per relationship: shared quests completed, PvP encounters, items traded, times resurrected each other, chat interactions; history summarized in relationship detail view
- [ ] LLM NPC interactions reference active relationships when contextually relevant: NPCs may comment on player's known companions ("I hear you travel with the Guardian Elena"), rivalries ("Word of your conflict with Sable has reached us"), or mentor bonds
- [ ] Relationship changes (new friend, rivalry declared, mentor bond formed) trigger polite ARIA: "Kira has accepted your friend request. You are now friends."
- [ ] Rival relationship declaration requires mutual consent or is auto-established after repeated PvP encounters (minimum 3); rival status visible to both parties in inspection panels
- [ ] Relationship panel fully operable via iOS VoiceOver: all swipe gestures, double-tap activations, and rotor navigation supported; no hover-dependent interactions
- [ ] Relationship data feeds social features: friends appear highlighted in area player lists, mentor/protege pairs receive shared XP bonus when adventuring together (5% bonus XP for both parties)

## Notes
Elena's social motivation is the strongest of all personas — she plays with friends, forms bonds, and cares about the human layer of the game deeply. The relationship tracking system makes those bonds visible and mechanically meaningful rather than just social conventions. The mentor/protege XP bonus is a designed incentive for the Elena–Carol dynamic (parent teaching child) or veteran–newcomer relationships. The LLM referencing relationships in NPC dialogue is the highest-value integration here: when an NPC mentions your rival by name, the world feels alive. The mutual consent requirement for Rival status prevents harassment via forced rivalry labeling. Privacy: relationship data is visible to both parties but not broadly public — inspection panels show Friend status but not full relationship history. Elena must be able to manage all relationships from her iPhone with VoiceOver without needing a desktop.
