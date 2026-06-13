# US-248: Community Bulletin Board

**Persona:** Lena — Tabletop RPG player who values community infrastructure and efficient information access
**Priority:** P1
**Epic:** Advanced Social & Governance

## Story
As Lena, I want an in-game notice board where I can post trade requests, read recruitment calls, and browse local lore so that I can participate in the community economy during short sessions without relying on real-time chat.

## Acceptance Criteria
- [ ] Bulletin boards are physical objects in major city squares and inns; interaction via `/board read [location]` or examining the board object in the room; boards are navigable without being physically present via `/board browse [city]` for read-only access
- [ ] Posts are categorized into tabs: Trade (WTB/WTS/WTT), Recruitment (guild/party/mentorship), Events (see US-246 integration), Lore (player-written stories, worldbuilding), General (other); category is required field at post creation
- [ ] Post creation via `/board post [city]` opens sequential form: Category (selector), Title (80 chars), Body (500 chars), Expiry (1/3/7/14 days — default 7), Contact preference (reply here / whisper / mail); all fields navigable by screen reader
- [ ] Board browse presents posts as a numbered list sorted by recency within category; user can filter by category: `/board browse [city] trade` shows only Trade posts; each list item reads: number, title, poster name, time posted, expiry
- [ ] Individual post read via `/board read [city] [post-number]`; full body narrated, then contact method; if Trade post, optional quick-reply via `/board reply [post-number]` sends mail to poster with board post title in subject
- [ ] Moderation: posts flagged by 3 or more players are auto-hidden pending GM review; GMs can delete, edit, or restore posts; poster notified of removal with reason; repeat violators lose posting privileges
- [ ] Event system integration (US-246): created events auto-post to the board in the Events category; event post updates in real-time (participant count, status changes) without requiring a new post
- [ ] Board posts survive server restarts; stored in persistent database with full-text search: `/board search [city] [keyword]` returns matching posts across all categories as a numbered list

## Notes
The bulletin board is the town square of the game's economy and community. It needs to work for Lena's 20-minute session as efficiently as it does for players who are online for hours. The key design principle: every action should be completable in under 60 seconds via keyboard commands.

Physical location requirement (boards in inns and city squares) adds atmosphere, but the `/board browse [city]` remote access for reading is essential. Lena shouldn't have to walk her character across the map just to check if anyone posted a response to her commission request. However, *posting* requires physical presence — this creates a reason to visit the city center.

The sequential form UX for posting must not have hidden interactions. A common pitfall: date pickers that require mouse interaction. The expiry field must be a simple selector (1/3/7/14 days) navigable by arrow keys, not a calendar widget. Test the entire posting flow with screen reader only before shipping.

Full-text search is important for Lena's use case: she wants to find "blacksmith" or "healing potion" across all posts without browsing every category. The search should rank results by recency and return a navigable list. Search query should support basic terms (no boolean operators needed at V1).

Lore posts deserve special treatment as a category. They are the board's contribution to worldbuilding — player-written histories, in-character gossip, fictional news. Consider marking high-voted lore posts as "Pinned Lore" visible at the top of the Lore tab, with an in-character framing: "Posted by the town crier: [Title]." This rewards good writing and builds world continuity.

Anti-spam: maximum 5 active posts per player across all boards at once. This forces players to let old posts expire or delete them before posting new ones, keeping boards from being dominated by a single merchant's inventory list.
