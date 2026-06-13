# US-184: Stat Allocation on Level-Up

**Persona:** Marcus — Blind power gamer prioritizing competitive viability
**Priority:** P0
**Epic:** Character Progression & Classes

## Story
As Marcus, I want to allocate attribute points on level-up with a screen reader announcing my current stats, class recommendations, and effect previews so that I can make optimal build decisions without visual reference.

## Acceptance Criteria
- [ ] Each level-up grants a configurable number of attribute points (default: 3) displayed and announced in the level-up flow: "You have 3 attribute points to allocate."
- [ ] Stat allocation panel presents all six attributes (US-176) with current value, pending allocation, and projected value; SR reads each attribute row as "{Attribute}: {current value} → {projected value} (+{allocated})"
- [ ] Effect preview announced in real time as points are allocated before confirmation: "Strength 14 → 15: melee damage increases from +42% to +45%, carry weight increases from 210 to 225 lbs."
- [ ] Class recommendation displayed per attribute: each attribute shows whether it is primary, secondary, or tertiary for the player's class; SR reads recommendation as "Primary stat for Warrior — strongly recommended"
- [ ] Point allocation via keyboard: arrow keys on focused attribute increase/decrease allocation (capped at available points and attribute maximum); Tab moves between attributes
- [ ] Confirmation required before committing allocation; confirmation dialog reads full summary of all pending changes before acceptance
- [ ] Respec of individual allocation within the same level-up session allowed freely (decrease allocated points before confirming); once confirmed, allocation is locked until respec item or gold cost at NPC
- [ ] Allocation state preserved server-side if player dismisses panel mid-session; pending points available next login with reminder announcement on login

## Notes
Marcus will optimize every point — this is not casual character building for him. The real-time effect preview is the single most important feature in this flow: it eliminates the mental math that makes stat allocation inaccessible for blind players in most RPGs. The formula must be correct and synchronous — if Marcus hears "melee damage +45%" and the actual in-combat number differs, trust collapses. Class recommendations are guardrails, not rails: Marcus should be able to dump points into Charisma on a Warrior if he wants to, with the system noting the unorthodox choice without blocking it. The pending point persistence across sessions is essential for Lena's short-session play style — she may need to research optimal allocation before committing.
