# US-236: Environmental Audio Landscapes

**Persona:** Sarah — Low-vision explorer, retinitis pigmentosa
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Sarah, I want each distinct area to have characteristic ambient sound descriptions that establish a sense of place through non-visual sensation so that navigating through different zones feels like moving through genuinely different environments.

## Acceptance Criteria
- [ ] Each zone type has a curated ambient audio description vocabulary: forest (birdsong, rustling canopy, distant woodpecker, brook sounds), cave (dripping water, echo, distant wind through passages, silence punctuated by skitter), market (crowd murmur, merchant calls, cart wheels, food smells), ocean coast (wave crash, gull calls, salt spray on skin, wind)
- [ ] Ambient description delivered on zone entry as part of room description, not as a separate system message; integrated into the room's opening paragraph
- [ ] Ambient sound shifts when environmental conditions change: rain enters a forest description changing bird sounds to shelter-sounds; night transforms a market square to silence and distant torch-crackle
- [ ] Text-based audio cues supplement but never replace text narration: ambient descriptions always resolve to text that SR reads; never audio-only cues for game-critical information
- [ ] Distinct zones have distinct audio fingerprints that repeat consistently: the Thornwood always has its specific ambient vocabulary when visited; players build geographic familiarity through repeated sensory exposure
- [ ] Audio landscape changes serve as spatial navigation cues: "The sound of the waterfall grows louder — you're approaching the Silverfall Basin" connects landmark sounds to player navigation
- [ ] Combat and activity sounds narrated in the appropriate environmental register: fighting in a cave sounds different (echoing, reverberant) from fighting in an open field (wind, distance, ambient wildlife reacting)
- [ ] Player-generated sounds narrated when significant: heavy armor described as clanking through quiet areas, torch announced as crackling light-and-heat, footsteps on snow described as crunching

## Notes
Sarah's retinitis pigmentosa means she relies on non-visual sensory description to build mental geography. Consistent audio vocabularies per zone let her recognize where she is as much through "hearing" the narration as through explicit location names. The waterfall navigation cue is a high-value example: natural landmarks described through their sound serve as cognitive wayfinding anchors without requiring visual map reference. The distinction between supplementary ambient text and game-critical text is the key accessibility principle: all game-critical information (combat results, NPC dialogue, quest updates) must be conveyed in text accessible to SR. Ambient descriptions can be rich and verbose on first visit, then abbreviated on subsequent visits — the game can offer a "rich ambient" vs "brief ambient" setting for return visits to familiar zones. Player-generated sound narration (armor clank in a quiet area, footsteps on snow) has gameplay implications beyond atmosphere: it informs stealth mechanics (US-203) and adds a layer of environmental self-awareness. The integration of ambient description into room narration (not a separate system message) is the right design: it prevents the "here is your room description [pause] here is your ambient audio description" two-step that breaks immersion.
