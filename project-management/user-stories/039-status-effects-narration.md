# US-039: Status Effects — Application, Duration, and Removal Narration

**Persona:** Sarah — Low-vision (retinitis pigmentosa), toggles visual and VoiceOver
**Priority:** P1
**Epic:** Combat — Core Systems

## Story
As Sarah, I want status effects (poison, stun, bleed, chill, etc.) applied to me or my opponent narrated clearly at application and persisted in a queryable status panel so that I can track debuffs without relying on visual icon displays.

## Acceptance Criteria
- [ ] Status effect application announced immediately via assertive live region: "Gareth's blade finds the gap — you are bleeding. You will lose health each round until treated."
- [ ] Status panel accessible as a persistent ARIA landmark showing all active effects with: name, prose description, duration (rounds remaining), and removal method
- [ ] Status effects on opponents also tracked in a separate "Opponent Status" panel
- [ ] Duration decrements announced in polite region: "The bleeding slows — two rounds remain."
- [ ] Expiration announced in polite region: "The poison runs its course — you are no longer poisoned."
- [ ] Stacking effects narrated distinctly: "A second dose of poison compounds the first — your condition worsens."
- [ ] Visual display of status effects (for Sarah's visual mode) uses high-contrast badges with text labels, not icon-only
- [ ] Status effect removal via item or skill narrated: "You apply the styptic — the wound closes. Bleeding removed."

## Notes
Sarah toggles between visual and audio modes depending on fatigue and lighting. The status panel must work equivalently in both modes: icons with text labels visually, prose list via VoiceOver. Never use color alone to convey status — "poison" badge must say "Poison" not just show green. Duration countdown should be queryable on demand (navigate to status panel) not constantly announced (would clog the audio stream).
