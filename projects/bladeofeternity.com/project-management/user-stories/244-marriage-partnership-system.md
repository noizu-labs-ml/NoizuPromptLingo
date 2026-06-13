# US-244: Marriage & Partnership System

**Persona:** Elena — Blind teenager using VoiceOver on iOS, social-first player
**Priority:** P2
**Epic:** Advanced Social & Governance

## Story
As Elena, I want to form an in-game partnership with a friend that is narrated beautifully and gives us real mechanical benefits so that our bond feels meaningful within the game world, and so the ceremony is something we can both experience fully regardless of how we access the game.

## Acceptance Criteria
- [ ] Partnership proposal initiated via `/propose [player]` command; target receives notification with options to Accept, Decline, or Ask to Wait — all navigable via screen reader without leaving current context
- [ ] Partnership ceremony is AI-generated narrative prose, personalized with partner names, location of ceremony, and any vows typed by players; ceremony text delivered through ARIA live region to both partners simultaneously
- [ ] Mechanical benefits activate upon partnership confirmation: shared housing access (each partner can enter the other's home), shared inventory slot (one shared chest visible to both), and a small stat bonus (+5% to all stats when within the same room)
- [ ] Ceremony location can be any accessible room; players may invite guests up to a configurable cap (default: 20); guests receive ceremony narrative in the room channel
- [ ] Partnership status visible on character profile with partner name as a navigable link to their profile; visible to other players viewing the profile
- [ ] Dissolution available via `/partnership dissolve` requiring both parties to confirm within 24 hours, or via GM intervention for abuse cases; shared chest contents split evenly or by mutual agreement
- [ ] Partnership system is inclusive by design: any two players regardless of character gender may partner; the word "marriage" is one of multiple available ceremony framings (others: bond, alliance, partnership — player selects)
- [ ] Dissolution narrated gracefully with no shame language; shared housing access revoked cleanly, inventory split resolved before access ends

## Notes
Elena cares deeply about the social and emotional texture of the game. The ceremony cannot be a dry form — it has to feel like something worth attending. The AI-generated prose should have a distinct "ceremonial" register: elevated, warm, specific to the players. Prompt engineering should include the location's description, the season, the time of day, and any lore relevant to the city where the ceremony takes place.

The VoiceOver on iOS constraint means all interactions must be fully operable with swipe gestures and no drag-and-drop. The proposal flow should be a simple sequential dialog: "Your friend Alex has proposed a partnership. [Accept] [Decline] [Ask to Wait]" — each as a separately focusable button.

The shared inventory chest is a delicate design: both partners have full read/write access, and this could be abused. Consider a partnership trust duration before the shared chest activates (e.g., 7 real days after ceremony) to reduce scam partnerships. Dissolution should lock the chest immediately and prompt both partners to claim their items within 72 hours before any remainder is split automatically.

Guest experience matters: guests attending the ceremony should hear the same prose as the partners, ideally with a slight delay so it reads as a real-time event rather than a wall of text. Pacing the delivery at paragraph intervals (3–5 seconds) via ARIA live region polite announcements allows screen reader users to follow naturally.

The naming flexibility (marriage/bond/alliance/partnership) is not just inclusion — it accommodates roleplay contexts (two warriors forming a battle-bond has different connotations than a romantic marriage) and makes the system useful for a wider range of players.
