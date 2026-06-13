# US-206: Combat Positioning and Terrain

**Persona:** Dave — MUD veteran sysadmin, sighted, deep systems focused
**Priority:** P0
**Epic:** Advanced Combat & Tactics

## Story
As Dave, I want the physics engine to model meaningful positional advantages — high ground, cover, flanking, chokepoints — and communicate them clearly so that tactical positioning is a genuine skill expression, not a sighted-player advantage.

## Acceptance Criteria
- [ ] Physics engine tracks 3D relative positions of all combatants; position data used to compute advantage modifiers applied to attack, defense, and skill rolls
- [ ] High ground advantage: attacks from elevated positions gain +15% accuracy and +10% damage; narrated: "You strike from the ridge above — your blow carries the weight of gravity"
- [ ] Flanking: attacking an enemy engaged with an ally from opposite side grants Flanking bonus; announced when achieved: "You've flanked the Warlord — he can't watch both of you"
- [ ] Cover computed per-target: full cover (blocked), partial cover (damage reduction), exposed (no benefit); cover source named in narration
- [ ] Chokepoint detection: system identifies narrow passages and informs players: "The corridor narrows to single file here — only one can attack at a time"
- [ ] Position summary accessible via P key: lists all combatants, their relative positions (north, south, elevated, behind cover), and current positional modifiers
- [ ] Movement in combat costs action or bonus action with movement range displayed; repositioning outcome narrated immediately
- [ ] Blind players receive identical positional information as sighted players — no information withheld due to assumed visual access

## Notes
This is the deepest integration point between the physics engine and the accessibility layer. Dave's MUD background means he understands spatial combat from text descriptions alone — the challenge is that the physics engine computes positions in 3D coordinates that must be translated to meaningful text in real time. The translation layer needs a vocabulary: compass directions for horizontal position, elevation language for vertical, cover language using named objects from the room description. The Position summary (P key) is the crucial accessibility feature — it gives blind players a spatial snapshot equivalent to what a sighted player sees on a visual map. The chokepoint detection is a tactical gift to players who engage with it; the system should describe it organically the first time it occurs, not as a system message. High ground is particularly important to narrate vividly — the physics computes the modifier, the LLM narrates why it matters in that moment.
