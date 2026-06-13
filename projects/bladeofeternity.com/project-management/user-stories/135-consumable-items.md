# US-135: Consumable Items

**Persona:** Elena — Blind teenager (16, VoiceOver+iOS, social)
**Priority:** P0
**Epic:** Item Framework & Equipment

## Story
As Elena, I want to use potions, food, and bandages during play with clear VoiceOver-accessible prompts so that I can manage my character's survival confidently without worrying about accidentally wasting something valuable.

## Acceptance Criteria
- [ ] Consumable types: potions (health, mana, stamina), scrolls (spell effect, map reveal, teleport), food (stat buff, slow regen), bandages (health over time, requires out-of-combat), and poisons (applied to weapons)
- [ ] Each consumable defines: effect (immediate or over-time), magnitude, duration, cooldown category (health_potion, food, bandage — each category has an independent cooldown), and value tier (common/uncommon/rare)
- [ ] Rare consumables trigger a confirmation prompt before use: "Use [Elixir of the Phoenix] — restores 100% health? Confirm." Prompt is keyboard and VoiceOver dismissable with Yes/No controls
- [ ] Effects delivered via dedicated status ARIA channel (not main narrative): "Health restored: +45 HP (now 78/120)" — channel is polite, does not interrupt combat narration
- [ ] Over-time effects announce on application and completion: "Bandage applied — healing 8 HP per round for 5 rounds." / "Bandage effect fades."
- [ ] Cooldown state announced on rejected use: "You cannot use another health potion for 30 seconds."
- [ ] VoiceOver on iOS: consumables in quick-use slots must have clear action labels — "double-tap to use health potion" not just "health potion button"
- [ ] Stack size displayed with item: "Health Potion (12)" — consuming from a stack decrements count and announces remaining: "11 health potions remaining."

## Notes
Elena uses VoiceOver on iOS, which has different interaction patterns from NVDA/JAWS on desktop. The double-tap gesture for activation and the swipe navigation between elements must be tested on actual iOS VoiceOver, not just ARIA attributes. Mobile accessibility is a separate test surface from desktop.

The confirmation prompt for rare consumables is specifically for Elena's benefit: she has limited resources and a misfire on a Phoenix Elixir in a routine fight would be genuinely upsetting. The threshold for "rare" should be configurable — default to uncommon and above, but allow admin to set per-item.

Cooldown categories (not per-item cooldowns) are important for usability: players should be able to use a bandage and a food item simultaneously, just not two bandages. The category system makes this rule explicit and consistent.

The status ARIA channel is a distinct region from the main narrative channel. It handles mechanical feedback (HP numbers, cooldowns, stack counts) while the narrative channel handles prose. This separation allows screen reader users to prioritize which channel they follow during different play moments.

Poisons applied to weapons (AC-1) require a separate interaction flow: `apply [poison vial] to [weapon]`. Confirmation required, since the poison vial is consumed. Poison effect narrated in combat as part of the weapon's attack description.
