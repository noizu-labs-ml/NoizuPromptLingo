# US-099: Age-Appropriate Content Controls

**Persona:** Carol — Sighted parent of blind daughter (14) and sighted son (12)
**Priority:** P0
**Epic:** Content Moderation / Safety

## Story
As Carol, I want the game to enforce age-appropriate content boundaries at the account level — not just through optional filters — so that my children cannot accidentally or deliberately access mature content regardless of in-game choices.

## Acceptance Criteria
- [ ] Account age tier is set at registration based on birthdate and is not user-editable after creation
- [ ] Mature content (graphic violence descriptions, sexual themes, explicit language) is gated behind verified 18+ accounts
- [ ] Teen accounts (13–17) can access Teen-tier content: mild combat descriptions, fantasy violence, age-appropriate romance references
- [ ] Family accounts (under 13) are COPPA-compliant: parental consent required, minimal data collection, no public chat
- [ ] Mature-tier game content (quests, lore) is not surfaced to Teen or Family accounts — server enforces this, not just client-side filtering
- [ ] Parents with Family accounts receive a weekly summary email of their child's in-game activity (opt-in)
- [ ] A parental control PIN can lock account tier settings from being changed

## Notes
Unlike the chat filter (US-094), this story covers content that is part of the game itself — mature quest text, lore, NPC dialogue. Server-side enforcement is non-negotiable; client-side filtering alone is bypassable. The weekly activity summary must itself be accessible (plain text email format, not image-heavy HTML).
