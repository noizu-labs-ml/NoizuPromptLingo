# US-185: Skill Cooldowns & Resource Management

**Persona:** Marcus — Blind power gamer prioritizing competitive viability
**Priority:** P0
**Epic:** Character Progression & Classes

## Story
As Marcus, I want active skills to have accessible cooldown timers and resource costs announced through the status ARIA channel so that I can manage my mana, stamina, and focus resources effectively during combat without missing critical information.

## Acceptance Criteria
- [ ] Three resource types defined: Mana (Intelligence-scaled, regenerates slowly), Stamina (Endurance-scaled, regenerates between actions), Focus (Perception-scaled, builds during combat, resets after); each with distinct identity and class affinity
- [ ] Resource bars represented in status ARIA channel as text: "Mana: 280 of 400. Stamina: full. Focus: 3 of 5 stacks." — updated at action boundaries, not per-tick
- [ ] Each active skill's cost displayed in skill bar tooltip and SR-readable skill description: "Cost: 45 mana. Cooldown: 8 seconds."
- [ ] On skill activation, polite ARIA announces resource expenditure: "Shield Bash used. 30 stamina spent. Skill on cooldown for 6 seconds."
- [ ] Cooldown timers tracked server-side; client renders remaining cooldown in skill bar; SR announces cooldown expiry via polite ARIA: "Shield Bash ready."
- [ ] Attempting to use a skill on cooldown announces reason for failure: "Shield Bash is on cooldown. Ready in 4 seconds."
- [ ] Attempting to use a skill with insufficient resources announces specific shortage: "Insufficient mana for Fireball. Need 45 mana, have 30."
- [ ] Global cooldown (GCD) of 1 second applied after most active skills; GCD state announced only when player attempts action during GCD: "Action not ready yet."

## Notes
Resource management is the heartbeat of real-time combat for SR players — Marcus cannot glance at a resource bar; he needs the status channel to deliver exactly the right information at exactly the right moment. The update-at-action-boundaries rule is critical: per-tick resource announcements during combat would produce an unintelligible flood of ARIA messages. Cooldown ready announcements are polite (non-interrupting) because they are ambient information; only failed action attempts should be assertive. The three-resource design gives each class a distinct feel: Warriors burn Stamina (physical exertion model), Mages drain Mana (magical reserve model), Rogues build Focus (tension and release model). Balance: if a class runs out of resources in normal play, something is wrong with ability costs or regen rates — tune aggressively in beta.
