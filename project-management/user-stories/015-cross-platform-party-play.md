# US-015: Cross-Platform Party Play Between Blind and Sighted Users

**Persona:** Elena — Blind teenager (16), VoiceOver on iPhone; Carol — Parent of blind daughter (14) and sighted son (12)
**Priority:** P1
**Epic:** Core Accessibility / Screen Reader

## Story
As Elena, I want to join and play in a party with my sighted friends so that I am a full participant in group content, not a spectator or a burden on the group.

## Acceptance Criteria
- [ ] Party invitation, acceptance, and formation is fully accessible via screen reader and keyboard
- [ ] Party chat (voice-to-text equivalent: typed group chat) is presented in a dedicated live region with `aria-label="Party chat"` separate from the main game log
- [ ] Party member HP/status can be reviewed on demand via keyboard shortcut (e.g., Alt+P to read party status panel)
- [ ] Party member status changes (HP drops, deaths, status effects) are announced in a polite live region for the group leader role
- [ ] Group coordination commands (e.g., "follow [player]", "assist [player]") are available via keyboard command input with full autocomplete
- [ ] The UI clearly distinguishes party-origin from world-origin messages in the screen reader announcement (e.g., "[Party] Sarah: Need heals")
- [ ] Sighted party members see no degraded experience when playing with screen reader users — no latency or feature gaps

## Notes
This story captures the social dimension that Carol cares deeply about — her blind daughter being able to play alongside her sighted son without a segregated experience. Elena's iPhone VoiceOver constraint means party features must work on mobile Safari. Cross-AT testing (NVDA desktop + VoiceOver iOS simultaneously in same party) is required.
