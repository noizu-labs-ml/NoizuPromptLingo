# US-224: World Map Navigation Aid

**Persona:** Marcus — Blind power gamer, NVDA+Firefox, PvP focused
**Priority:** P0
**Epic:** World Depth & Exploration

## Story
As Marcus, I want a text-based world map I can navigate efficiently via screen reader so that I can understand the geography, plan routes, and locate objectives without relying on visual map representations.

## Acceptance Criteria
- [ ] World map accessible via W key as a structured ARIA region with location entries as list items; each entry includes: location name, region, type (city/dungeon/landmark/zone), known connections, and approximate distance from current position
- [ ] Map updates dynamically as new locations are discovered; newly discovered locations announced: "New location added to world map: The Sunken Ruins (3 leagues east of Millhaven)"
- [ ] Path-finding assistance available: "Route from current location to [destination]" generates a step-by-step text path: "Head east through the Thornwood, cross Millhaven Bridge, then south 2 leagues to the city gates"
- [ ] Location entries include spatial relationship descriptions: "northeast of Ironhold, southwest of the Dunemarsh" providing relative geography without visual reference
- [ ] Map filterable by: location type, region, visited/unvisited, proximity to current position — filter results read as an updated list
- [ ] Points of interest (quest markers, known enemy territories, player-set markers) shown as sub-items under their parent location
- [ ] Player can set custom map markers with a short label; markers accessible in map list and in room descriptions when nearby: "You are near your marker: 'Elena's spawn spot'"
- [ ] Map data exportable as plain text for screen reader users who want to build external reference notes; copy-to-clipboard action available

## Notes
This is a P0 because the world map is how Marcus — and all blind players — understand where they are and where they're going. A visual map without a text equivalent is a complete accessibility failure. The structured list approach leverages what screen readers do best: linear navigation through items with consistent structure. The pathfinding text route is the killer feature: it gives Marcus the equivalent of turn-by-turn navigation without requiring him to build a mental model of the full geography. Spatial relationship descriptions ("northeast of Ironhold") provide the directional vocabulary that builds geographic intuition over time. The custom markers feature is important for Marcus's PvP use case: he wants to mark where he died in PvP, where a rare enemy spawns, where his clan's rally point is. The plain text export reflects the reality that serious screen reader users often maintain external notes — the game should support rather than fight this behavior. Filter by proximity is particularly useful for "what's nearest to me?" planning.
