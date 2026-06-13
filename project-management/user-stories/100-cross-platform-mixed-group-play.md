# US-100: Cross-Platform Mixed-Ability Group Play

**Persona:** Elena — Blind teenager (16), VoiceOver on iPhone, playing with sighted friends
**Priority:** P1
**Epic:** Mobile / Onboarding

## Story
As Elena, I want to party with my sighted friends regardless of the device or input method they are using so that accessibility accommodations are invisible to the group and we all experience the same game world together.

## Acceptance Criteria
- [ ] Party formation, invitation, and acceptance flows work identically for screen reader and sighted users — no divergent UI paths
- [ ] Group chat output is formatted identically regardless of each member's rendering settings (font size, contrast, theme are local; content is shared)
- [ ] Party members can join from desktop (Next.js web client) and mobile (same web client, responsive) in the same session
- [ ] A sighted party leader can perform group actions (set destination, initiate group combat) that are fully announced to screen reader users via ARIA live regions
- [ ] Screen reader users can perform all party leadership actions via command interface: `/party lead`, `/party invite <name>`, `/party kick <name>`, `/party follow`
- [ ] Party status panel (member health, positions, buffs) is available as both a visual sidebar and a `/party status` command output
- [ ] No game mechanic requires simultaneous coordination that would disadvantage users with higher screen reader latency

## Notes
Elena plays with sighted school friends who may not have accessibility awareness. The experience must be seamless enough that they do not feel slowed down by her access needs, and Elena must not feel like a liability. This story validates that the game's core promise — accessibility-first is universal-first — holds in multiplayer.
