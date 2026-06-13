# US-147: Ammunition and Consumable Stacking

**Persona:** Marcus — Blind power gamer (28, NVDA+Firefox, PvP)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Marcus, I want arrows and throwing weapons to stack cleanly with auto-consumption in combat and a low-ammo warning so that I never unexpectedly run out mid-fight or waste cognitive load tracking small consumables.

## Acceptance Criteria
- [ ] Stackable ammunition types: arrows, bolts (crossbow), throwing knives, javelins, sling stones — each stacks up to a configurable maximum (default: 200 per stack)
- [ ] Stack splitting: `split [item] [quantity]` divides a stack into two — required for partial trades; result announced: "Stack split: 50 arrows / 150 arrows."
- [ ] Auto-consumption in combat: equipped ranged weapon automatically draws from the equipped ammo stack; player does not manually trigger ammo consumption — it is an automatic consequence of using ranged attacks
- [ ] Low-ammo threshold warning (default: 10% of stack maximum, i.e., 20 arrows out of 200): delivered once per stack per session via status ARIA channel (polite): "Warning: only 18 arrows remain."
- [ ] Zero-ammo failure narrated: "You reach for another arrow and find your quiver empty — your longbow is useless without ammunition."
- [ ] Multiple stacks of the same ammo type consolidate automatically on pickup if the existing stack is not full; excess goes to a new stack; consolidation announced: "Arrows consolidated: now 145."
- [ ] Stack count displayed with item at all times: "iron arrows (145)" — updated immediately after each combat round in which ammo is consumed
- [ ] Ammo type must match weapon: attempting to use crossbow bolts with a longbow fails with a narrated error; the mismatch is caught at equip time, not at attack time

## Notes
Auto-consumption (AC-3) is critical for screen reader users: manually triggering ammo consumption in a screen-reader environment would add cognitive overhead during combat that sighted users don't face. The asymmetry should not exist. Ammo management is inventory management (restocking) not combat management (triggering).

The low-ammo warning once-per-session-per-stack (AC-4) prevents notification spam: if Marcus has 20 arrows and they deplete by 2 per combat, the warning fires once when he first crosses the threshold and doesn't repeat for that stack. When he restocks and crosses the threshold again, the warning fires once more.

Stack count visible in real time (AC-7) is essential for Marcus's PvP planning: he needs to know exactly how many arrows he has before entering an arena match. The count must update after each combat round, not batched at end of combat.

The ammo type mismatch caught at equip time (AC-8) prevents a frustrating failure mode: equipping the wrong quiver and not discovering it until the first ranged attack miss. Catching at equip time with a clear narrated error ("Crossbow bolts cannot be used with your longbow — equip bolts when using a crossbow") is the correct UX.

Stacking with consumables (potions, food): the same stacking mechanics apply. Potion stacks should auto-consolidate on pickup if the existing stack has room. This reduces the "17 separate health potion items" inventory clutter that plagues RPG inventory management.
