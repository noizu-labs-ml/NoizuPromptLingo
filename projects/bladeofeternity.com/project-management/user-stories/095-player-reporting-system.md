# US-095: Player Reporting System

**Persona:** Elena — Blind teenager (16), VoiceOver on iPhone
**Priority:** P1
**Epic:** Content Moderation / Safety

## Story
As Elena, I want to report a player for harassment or inappropriate behavior using only VoiceOver on my iPhone so that I can protect myself without needing sighted help and without leaving the game.

## Acceptance Criteria
- [ ] `/report <playername>` command opens an accessible report dialog without breaking VoiceOver focus
- [ ] Report categories are presented as a radio group with descriptive labels (e.g., "Harassment or threats", "Hate speech", "Spam or scamming")
- [ ] An optional free-text description field is labeled "Describe what happened (optional)" with a 500-character limit announced as remaining characters decrease
- [ ] Report submission confirms success or failure via ARIA live region announcement
- [ ] Recently viewed chat history for the reported player is automatically included in the report payload (server-side, not requiring user action)
- [ ] Reporting does not expose the reporter's identity to the reported player
- [ ] Players can block a user via `/block <playername>`, which immediately suppresses that player's messages from all channels

## Notes
Elena may be reporting during or immediately after an upsetting interaction — the flow must be fast (under 5 steps) and not require extensive typing. Auto-capture of recent chat context reduces burden on the reporter. Block must persist across sessions.
