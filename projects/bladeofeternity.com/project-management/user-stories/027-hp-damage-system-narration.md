# US-027: HP and Damage System — Prose Health Communication

**Persona:** Elena — Blind teenager (16), VoiceOver on iPhone
**Priority:** P0
**Epic:** Combat — Core Systems

## Story
As Elena, I want my health status communicated in clear, memorable prose language (not just numbers) so that I can gauge my danger level quickly during fast combat without needing to navigate to a separate status panel.

## Acceptance Criteria
- [ ] HP communicated in both numeric and prose-band forms: "147/200 HP — Bloodied"
- [ ] Prose health bands: Uninjured (100%), Scratched (75–99%), Hurt (50–74%), Bloodied (25–49%), Critical (10–24%), Near Death (<10%)
- [ ] Health band transitions announced immediately via assertive live region: "You are now Bloodied."
- [ ] Damage received narrated inline with combat action: not as a separate "you lost X HP" announcement
- [ ] HP panel accessible via keyboard shortcut (e.g., H key) that reads full status without interrupting combat
- [ ] On mobile (VoiceOver/iOS), HP accessible via swipe-navigable status landmark at top of page
- [ ] Healing narrated as prose: "The poultice draws the heat from your wounds — you feel steadier." followed by new HP value
- [ ] Death/defeat state narrated with dignity: not "YOU DIED" but a scene-appropriate narration

## Notes
Elena plays on iPhone with VoiceOver using swipe navigation, not a keyboard. The HP widget must work as a static ARIA region that can be revisited without triggering a live announcement. The death narration is a UX moment — it should feel like the end of a chapter, not a game-over screen. Consider letting players configure their own death narration style (stoic, dramatic, brief).
