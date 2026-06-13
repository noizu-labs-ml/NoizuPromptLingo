# US-129: Item Repair System

**Persona:** Tyler — MMO refugee (22, sighted, growth/clans)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Tyler, I want to repair my worn equipment at blacksmiths or through player crafting so that gear maintenance is an economic activity with meaningful quality tradeoffs — not just a gold-sink tax.

## Acceptance Criteria
- [ ] NPC blacksmiths offer repair services at dynamic prices based on item level, material, and current durability; price narrated before confirmation: "Repairing your iron kite shield will cost 45 silver. Confirm?"
- [ ] Player characters with sufficient Smithing skill can repair items using raw materials (iron ingots, leather strips, etc.) from their inventory
- [ ] Repair quality determined by: repairer's skill level, quality of materials used, tool quality (improves with higher-tier anvil/forge access), and a small variance roll
- [ ] A botched repair (low skill, poor materials) permanently reduces the item's `max_durability` by 5–15%; narrated as: "The repair holds, but the metal is not what it was — your shield feels slightly less solid."
- [ ] A masterwork repair (high skill, fine materials, good tools) restores full `max_durability` and may add 1–5 bonus points above original maximum
- [ ] Repair interactions are narrated as workshop scenes lasting one to three prose sentences; scene varies by material (forging iron vs. re-stringing leather armor vs. polishing crystal)
- [ ] Clan workshops with high-quality forges provide a bonus to repair quality, incentivizing clan infrastructure investment
- [ ] Repair history is recorded on the item: "Repaired 3 times; last repaired by Ironhand Durgin in Ashford" — visible via `examine` command

## Notes
Repair history on items (see acceptance criterion 7) feeds into the legendary item history system (US-133). A weapon that has been repaired dozens of times by different smiths has a richer story than a fresh-from-the-forge blade.

The max durability reduction on botched repair is the key design tension: it means cheap/fast repairs are a long-term loss, and investing in quality repair (either finding a skilled NPC or leveling the Smithing skill yourself) has real value. Tyler will min-max this immediately.

NPC repair prices should scale such that it is always economically rational to repair rather than replace common items, but the crossover point shifts for rare/epic items where crafting replacements is difficult. This is an economy tuning concern.

Workshop prose should reference the environment: a roadside forge in a frontier village produces different scene text than the famous smithy of Ashford. LLM narrative context should include the location when generating repair prose.

For screen reader users (Marcus, Elena), the repair confirmation prompt must be a clear modal with keyboard dismissal — not a floating tooltip. The price and consequence must be readable before committing.
