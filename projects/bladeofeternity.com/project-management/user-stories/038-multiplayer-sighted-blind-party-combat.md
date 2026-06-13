# US-038: Mixed-Ability Party Combat — Blind and Sighted Players Together

**Persona:** Elena — Blind teenager (16), VoiceOver on iPhone
**Priority:** P0
**Epic:** Combat — Multiplayer

## Story
As Elena, I want to participate fully in party combat alongside my sighted friends so that I can contribute meaningfully, follow group tactics, and share the same narrative experience without relying on my friends to relay information.

## Acceptance Criteria
- [ ] Party combat narration delivered to all members simultaneously via their preferred accessibility settings
- [ ] Elena's VoiceOver on iOS receives same prose content as sighted party members' visual display — no stripped-down mobile fallback
- [ ] Party member HP and status accessible via a dedicated "Party Status" landmark navigable by swipe (iOS) or Tab (desktop)
- [ ] Incoming party member actions announced in polite region: "Sira casts Mending Light — you feel the warmth reach your wounds."
- [ ] Party chat accessible in a separate `role="log"` region that does not interrupt combat narration
- [ ] Target designation in party combat keyboard/gesture accessible: Elena can designate a target by name from a list, not only by clicking
- [ ] Group victory and defeat narrations written for ensemble: "The last of the crypt guardians falls — the silence that follows feels earned."
- [ ] Accessibility onboarding for new party members: game explains how to adjust announcement settings

## Notes
Elena's friends are sighted — they may not know how screen reader timing works. The game should not penalize the party for Elena's longer announcement cycle. Consider "patience mode" where combat round timers extend slightly when a party member with accessibility settings active is present. Party composition should not be discernible from external narration — privacy around disability disclosure.
