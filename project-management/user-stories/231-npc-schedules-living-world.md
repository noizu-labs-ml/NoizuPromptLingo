# US-231: NPC Schedules and Living World

**Persona:** Jamie — IF enthusiast, sighted, narrative quality focused
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Jamie, I want NPCs to follow daily schedules — shops that open and close, guards that patrol, residents that move through their routines — so that the world feels inhabited by people living lives rather than dialogue dispensers frozen in position.

## Acceptance Criteria
- [ ] Each named NPC has a schedule record: a sequence of location/activity/time entries defining their daily routine (e.g., "Merchant Aldric: market stall 08:00–18:00, inn common room 18:00–22:00, upstairs room 22:00–07:00")
- [ ] Schedule-based NPC availability communicated naturally: entering the market at night finds the stall empty with a note ("Aldric's Goods — returns at dawn"); the inn common room has Aldric at his table in the evening
- [ ] Time of day communicated through environmental narration: "The market square buzzes with morning commerce" vs "Shuttered stalls cast long shadows in the afternoon quiet" — not just a clock display
- [ ] Guards and patrol NPCs move between waypoints on schedule; player can observe patrol patterns through watching; patrol disruption from combat or events adjusts routes dynamically
- [ ] Quest-relevant NPCs update schedule after quest milestones: a rescued merchant returns to their stall; a warned noble leaves town — changes narrated when player next encounters the location
- [ ] Seasonal and weather effects on schedules: rain drives market vendors inside; festivals change NPC locations and dialogue; cold snaps reduce outdoor activity
- [ ] Player actions can shift NPC schedules: establishing a relationship may cause an NPC to visit the player's home; completing a questline may unlock an NPC's private study
- [ ] Schedule metadata accessible via examining an NPC when present: "The blacksmith looks like she's settling in for the evening — she'll probably be at her forge at dawn"

## Notes
Jamie's interactive fiction sensibility is most strongly expressed by the living world feature: a static NPC is a plot device, a scheduled NPC is a person. The schedule system is the infrastructure for emergent gameplay: Jamie might discover that the corrupt guard goes off-duty at midnight and plan accordingly. The "naturally communicated" absence criterion is critical: an empty shop with a note is immersive; a "NPC NOT FOUND AT THIS LOCATION" message breaks the fiction. Time of day through environmental narration rather than a clock display respects the sensory-first design: the market buzz communicates morning better than "08:32" does. Patrol observation creates the stealth gameplay hook (US-203): watching patrol timing before an infiltration is classic IF/tabletop behavior. Quest-contingent schedule changes reward engagement with the story: the world responds to player action in observable ways. For blind players, the natural language schedule hints when examining a present NPC ("settling in for the evening") provide temporal orientation without requiring UI clock access. Seasonal effects tie the schedule system to the weather system (US-232) and day/night cycle (US-233), making all three systems mutually reinforcing.
