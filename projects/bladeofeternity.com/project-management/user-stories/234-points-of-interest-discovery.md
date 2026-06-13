# US-234: Points of Interest Discovery

**Persona:** Elena — Blind teenager, VoiceOver+iOS, social focused
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Elena, I want to discover notable locations — ruins, sacred groves, ancient mines, hidden towers — that unlock lore, quests, and resources so that exploration has a reward structure beyond combat loot and each discovery feels like a genuine find.

## Acceptance Criteria
- [ ] Points of interest (POIs) defined by type: Ruin, Grove, Mine, Tower, Shrine, Cave, Shipwreck, Battlefield — each type has unique discovery narration vocabulary and associated content type
- [ ] Discovery triggered by entering a POI zone for the first time; discovery announcement delivered as a distinct assertive live region: "Discovered: The Shattered Colossus — an ancient ruin of the Eld Empire" before the room description
- [ ] Each POI has at least one lore item, accessible in-zone via examine interactions; lore text added to exploration journal automatically on read
- [ ] POI discovery may unlock: a related quest, a crafting resource (unique to that zone), an NPC encounter, or a landmark fast travel point
- [ ] Discovered POIs logged in exploration journal with: name, type, region, discovery date, lore summary (if found), and associated quest status
- [ ] "What's nearby?" query (? key) lists known POIs within current region accessible by a half-day's travel, with distance and type: "Within half a day: Shattered Colossus (ruin, northeast), Saltmarsh Cave (cave, west)"
- [ ] Elena's discovery announced in party chat if in a group: "Elena has discovered The Shattered Colossus!" creating a shared social moment
- [ ] Total POI discovery progress visible in journal: "Ruins discovered: 4/12 in this region" without listing undiscovered names — encourages exploration without spoiling surprises

## Notes
Elena's social focus means discovery is partly a performance for her party: finding something first is a social win. The party announcement of her discovery creates that moment. The "What's nearby?" query is a navigation tool for mobile play: Elena can check if anything interesting is within reach in her current session without opening the full world map. The discovery announcement using assertive live region prevents the anticlimactic experience of walking into an important location and not registering it while SR was reading something else. The POI type vocabulary helps Elena orient to what content to expect: ruins have lore and dungeon encounters; groves have foraging and druid-type NPCs; mines have resources and underground encounters. Lore text auto-added to journal on read is a QoL feature Elena will appreciate: she doesn't need to manually save lore she reads in-zone. The "X/Y discovered in this region" counter without revealing names respects the exploration arc: Elena knows there's more to find but has to find it herself. POI discovery as quest unlock is the content hook — Elena finding a shipwreck triggers a ghost story quest she can pursue in future sessions.
