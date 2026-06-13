# US-016: Non-Visual Map and World Navigation

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P1
**Epic:** Core Accessibility / Screen Reader

## Story
As Marcus, I want to navigate the game world and understand my spatial location without a visual map so that I can move efficiently between zones and find objectives without sighted assistance.

## Acceptance Criteria
- [ ] Current location is always available as a persistent, screen-reader-readable element: zone name, sub-area, coordinates or named landmark reference (e.g., "Ashenveil Forest — Near the Ruins Gate, northeast quadrant")
- [ ] A text-based map command (`map` or Alt+M) outputs a structured description of visible exits, nearby landmarks, and points of interest as a navigable list
- [ ] Exits are listed as a `<ul>` with each direction as a link or button (North, South, East, West, Up, Down, custom named exits)
- [ ] Moving through an exit announces the new zone/area immediately via `aria-live="polite"`: "You enter Thornwood Pass. Exits: South, East."
- [ ] Nearby entities (enemies, NPCs, players) are listed in a "surroundings" panel, navigable by screen reader, sorted by proximity
- [ ] A "You are lost" / pathfinding command offers step-by-step directions to quest objectives or towns in text form
- [ ] All map data is equally available to screen reader users as to sighted users with the graphical minimap

## Notes
The graphical minimap (if implemented for sighted users) must have a text equivalent — it is not sufficient to make the visual map keyboard accessible if a screen reader cannot extract meaningful spatial information from it. The text-based navigation system IS the primary map for blind users, not a fallback. Coordinate systems should use compass directions and named landmarks, not raw x/y values.
