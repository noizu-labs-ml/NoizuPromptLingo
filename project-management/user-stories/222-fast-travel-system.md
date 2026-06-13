# US-222: Fast Travel System

**Persona:** Elena — Blind teenager, VoiceOver+iOS, social focused
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Elena, I want to fast travel between locations I've already discovered so that I can spend my limited play time doing things I enjoy rather than repeating travel I've already experienced.

## Acceptance Criteria
- [ ] Fast travel unlocked per location upon first physical visit; unvisited locations not listed in fast travel menu
- [ ] Fast travel menu accessible as a filterable list: location name, region, travel cost (gold), estimated travel time (game hours) — SR navigable with standard list patterns
- [ ] Cost in gold deducted on confirmation; if insufficient funds, announces shortfall: "You need 45 more gold for passage to Ironhold"
- [ ] Travel time passes in-game clock; events tied to time of day or NPC schedule resolve during travel period
- [ ] Brief atmospheric narration on arrival: "After a half-day's journey, the spires of Ironhold rise through the morning fog — you've arrived at the city gates" (2–4 sentences, not skippable but brief)
- [ ] Waypoint list supports search/filter by region, name, or landmark type; filter state persists within session
- [ ] Fast travel blocked during active combat, while encumbered beyond maximum, or during certain quest states; blocking reason announced clearly
- [ ] Favorites system: player can mark up to 10 locations as favorites; favorites appear at top of waypoint list for quick access

## Notes
Elena's mobile play context (VoiceOver+iOS) means she may play in short bursts with a specific goal in mind — fast travel is what makes those sessions viable. The cost-in-gold mechanic is a light friction that discourages fast travel spam while not penalizing occasional use. Arrival narration must be brief: Elena is already at the destination mentally, the narration confirms arrival without becoming a mandatory cutscene. The in-game clock advancing during fast travel is important for world consistency: if you fast travel 8 game-hours, NPC schedules should reflect that. The blocking states (combat, encumbrance, quest) need clear messaging so Elena understands why fast travel isn't available without needing to open a different menu to investigate. The favorites system is a direct usability feature for Elena's regular destinations (her home city, her guild hall, her favorite dungeon entrance). VoiceOver list navigation is fast and efficient — the list format for waypoints plays to VoiceOver's strengths as a navigation interface. The filterable search is important as the world grows and the waypoint list reaches 50+ entries.
