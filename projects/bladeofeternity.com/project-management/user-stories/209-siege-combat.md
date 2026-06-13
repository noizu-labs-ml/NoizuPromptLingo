# US-209: Siege Combat

**Persona:** Tyler — MMO refugee, sighted, growth/clans focused
**Priority:** P1
**Epic:** Advanced Combat & Tactics

## Story
As Tyler, I want my clan to assault or defend fortifications with siege weapons and coordinated large-scale tactics so that territory control feels like a genuine strategic achievement earned through organized effort.

## Acceptance Criteria
- [ ] Siege encounters support 10–50 players per side; server-side OTP processes handle participant grouping to maintain performance
- [ ] Siege weapons (catapult, battering ram, ballista) operable by players: each has a crew requirement (1–3 players), reload time, accuracy, and area damage
- [ ] Fortification elements (walls, gates, towers) have structural integrity tracked by the physics engine; breach narrated as dramatic environmental change: "The eastern gate splinters — the way is open"
- [ ] Defenders can repair walls, pour boiling oil, drop portcullises; each action has keyboard shortcut and SR confirmation
- [ ] Attackers have objective markers: breach main gate, destroy supply depot, capture the keep — accessible as an ordered list with progress indicators
- [ ] Siege narrated as epic set-pieces at key moments: opening salvo, first breach, gate fall, keep assault, victory/defeat — LLM generates each as a short dramatic paragraph
- [ ] Players receive role-specific narration: siege crew operators hear machinery narration, wall defenders hear impact narration, skirmishers hear close-combat narration
- [ ] Post-siege summary includes clan contribution metrics, territory ownership change, and resource gains — accessible as a structured report

## Notes
This is Tyler's endgame fantasy: leading his clan in a coordinated siege. The scale challenge (50 players) requires Phoenix PubSub channel architecture where each player receives only their relevant narration stream. Siege weapons as crew-operated devices create cooperative micro-roles within the macro battle — Tyler's job as clan leader is coordinating who operates what. The fortification physics is the most demanding engine feature: structural integrity must be consistent and meaningful, not cosmetic. The epic set-piece narrations are the memorable moments Tyler will talk about with his clan after the battle; they justify the LLM integration cost. Role-specific narration prevents a siege from being a wall of undifferentiated text — a siege crew member doesn't need to hear every skirmish, and a melee fighter doesn't need catapult reload times. Accessible objectives list allows blind players to track the strategic picture without visual map dependency.
