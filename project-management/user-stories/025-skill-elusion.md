# US-025: Elusion Skill — Evasion with Kinetic Feedback

**Persona:** Sarah — Low-vision player (retinitis pigmentosa, VoiceOver)
**Priority:** P1
**Epic:** Combat — Skills

## Story
As Sarah, I want the Elusion skill to narrate my character's evasive movement with enough kinetic and spatial detail that I feel the physicality of the dodge whether I am using VoiceOver or reading the high-contrast visual text.

## Acceptance Criteria
- [ ] Elusion activates as a reaction skill: triggers automatically or manually on incoming attack declaration
- [ ] Narration conveys direction of dodge, surface conditions underfoot, and proximity of the miss: "You pivot hard left — the cobblestones slick beneath your boot — and the blade clips air a hand's width from your ribs."
- [ ] Failed evasion (partial or full hit) narrated with equal physicality: "Your weight shifts too late; the strike catches your left shoulder and drives you back two steps."
- [ ] Visual text version uses same prose (not stripped-down fallback) at minimum 14px, high-contrast
- [ ] Elusion success/fail state announced in assertive live region immediately, before round summary
- [ ] Stamina cost visible as numeric value AND prose equivalent ("costs moderate stamina")
- [ ] Elusion unavailable states explained: "Elusion blocked — you are stunned" not just `aria-disabled`
- [ ] Toggle available to suppress kinetic detail for experienced players who want brevity

## Notes
Sarah uses both visual and audio modes; the prose must work without audio enhancement. Avoid directional descriptions that assume left/right orientation unless the game has established a compass bearing. Use egocentric frame ("your left") not allocentric ("north"). VoiceOver on macOS announces live region updates differently than NVDA — test both.
