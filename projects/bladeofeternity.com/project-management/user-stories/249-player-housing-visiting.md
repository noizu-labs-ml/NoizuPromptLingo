# US-249: Player Housing — Visiting

**Persona:** Elena — Blind teenager on VoiceOver/iOS for whom social spaces are the heart of the game
**Priority:** P1
**Epic:** Advanced Social & Governance

## Story
As Elena, I want to visit my friends' homes and have my own home feel like an expression of my character so that housing becomes a social hub rather than just storage, and so I can explore others' spaces without needing to see them.

## Acceptance Criteria
- [ ] Player homes are accessible rooms with a unique address; `/visit [player-name]` teleports to their home entrance if privacy settings allow, with narration: "You arrive at [Player]'s home in the [District] of [City]."
- [ ] Home description is fully text-based and authored by the owner via `/home describe [text]` (up to 300 chars); default description generated from home tier, location, and owner's top achievements if custom description is not set
- [ ] Achievement display: owners can mount up to 10 achievement plaques readable by visitors via `/home achievements`; each plaque narrates achievement name, date earned, and flavor text; ordered by owner's curation preference
- [ ] Guest book in every home: `/home guestbook read` lists last 20 visitors with name, timestamp, and optional message (60 chars, left at time of visit via `/home guestbook sign [message]`); owners can delete individual entries
- [ ] Privacy settings via `/home privacy [open|friends|clan|private]`: Open (anyone can visit), Friends (friend list only), Clan (clan members only), Private (no visitors); default is Friends; current setting narrated in `/home status`
- [ ] Owners can designate a home as "open house" for a time-limited period (1–8 hours) overriding privacy settings; open house homes appear in city directory: `/city homes` lists open houses with owner name, district, and description preview
- [ ] Navigation within a home: homes have 1–5 rooms depending on tier; each room navigable with standard movement commands; room descriptions include items on display, furniture, and any visitors currently present (names listed)
- [ ] Visiting notifications: owner receives ARIA live region announcement when a visitor enters or leaves their home (if owner is online); notification reads: "[Player] has arrived at your home." Can be toggled off via settings

## Notes
Elena's use of VoiceOver on iOS means the visiting flow must work entirely through text commands — no drag-to-navigate graphical floor plans. The room-by-room navigation model (standard movement commands: north/south/east/west/up/down) is the right paradigm because it's the same as the rest of the game. There should be no special "housing navigation mode" — consistency reduces cognitive load.

The achievement display is the key to making homes feel meaningful rather than just storage. When Elena visits Marcus's home and reads his achievement plaques — "Slayer of the Void Dragon, earned on the 14th day of the Storm Season, Year 3" — it tells a story. The plaque system should be the primary personalization mechanic, supplemented by the prose description.

Guest books are a social texture element with low interaction cost. The 60-character message limit is intentional — forces brevity and keeps the guestbook readable as a screen reader list. Messages longer than the limit should be truncated with an error at submission, not silently cut.

The `/city homes` directory for open houses creates serendipitous social discovery: Elena can browse who currently has their home open and decide to drop in. This should be sorted by most recently opened, and include a "new to me" filter showing open houses Elena hasn't visited before.

Home tiers (1–5 rooms) should be earned, not purchased with premium currency. Progression: starter homes (1 room) available to all; additional rooms unlocked via in-game achievements or crafting. This prevents pay-to-flex while still making larger homes meaningful.

The privacy model needs a "friends of friends can visit during open house" option for future consideration — allows organic social expansion without full open access. V1 can ship with the four basic tiers.

One edge case: what happens when a player's account is deleted or banned? Their home should revert to the housing pool, guestbook entries preserved in archive. Visitors who try `/visit [deleted-player]` should receive: "That home is no longer occupied."
