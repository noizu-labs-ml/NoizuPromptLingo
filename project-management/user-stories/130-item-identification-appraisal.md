# US-130: Item Identification and Appraisal

**Persona:** Lena — Tabletop RPG player (38, sighted, editorial, short sessions)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Lena, I want to discover the true nature of mysterious dungeon finds through identification and appraisal so that the reveal of a powerful item feels like a genuine narrative moment rather than a mechanical transaction.

## Acceptance Criteria
- [ ] Unidentified items display a generic description: "a heavy iron ring, tarnished and cold — its purpose unknown"
- [ ] Identification routes: (a) NPC sage service (costs gold, instant), (b) player Lore skill (free, skill-gated, may fail), (c) Identify scroll (consumable, always succeeds)
- [ ] Successful identification reveals: true name, all stat modifiers, rarity tier, lore blurb (2–4 sentences, LLM-generated but seeded from item template), and any curse/blessing status (see US-132)
- [ ] Failed identification attempt via Lore skill produces a partial result: true name revealed but one or more stats remain hidden; player may retry after a 24-hour cooldown or use a different method
- [ ] NPC appraisal provides market value estimate in addition to identification; estimate has a ±10% variance based on NPC's Merchant skill
- [ ] Identification reveal is delivered as a prose scene: "The sage turns the ring over in her hands, traces a rune on the inner band, and nods slowly. 'This is the Ring of Quiet Passage — it will muffle your footsteps in shadow.'"
- [ ] Identified items retain their lore text permanently; examining them later shows the same lore that was revealed on identification
- [ ] Unidentified items cannot be sold to player shops or listed on the auction house; NPCs will buy them at a deep discount as "curiosities"

## Notes
Lena plays in short sessions and often logs off in the middle of a dungeon crawl. Unidentified items she carries out should persist across sessions in their unidentified state — she should be able to identify them at her leisure.

The lore blurb is the emotionally important part for Lena. It should be generated with the item's history and zone context as LLM input, so a ring found in a necromancer's tomb reads differently from the same stat ring found in a merchant's safe. This is a meaningful narrative investment that repays short-session players by giving them something to read between sessions.

Partial identification (failed Lore check) is a meaningful design choice: it creates a tension between spending gold on a sage versus risking continued use of a partially-known item that might be cursed. Cursed items that are partially identified should not reveal their curse status — that remains hidden until full identification.

For screen reader users, the identification reveal prose should flow through the main narrative ARIA live channel, not a popup, so it reads naturally in sequence with the scene.

Market value from appraisal is useful for Lena's short sessions: she wants to quickly know if something is worth carrying out before her session ends.
