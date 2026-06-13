# US-143: Item Transmutation and Salvage

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Dave, I want to salvage items into component materials and transmute materials between types so that the item economy has proper sinks that prevent material flooding and maintain crafting scarcity.

## Acceptance Criteria
- [ ] Salvage action: `salvage [item]` destroys the item and returns a set of component materials based on the item's material, quality, and complexity — with variance
- [ ] Salvage yield table: a fine iron longsword yields 2–4 iron ingots; a poor one yields 1–2; a masterwork yields 3–5 plus a small chance of a rare component (tempered iron shard)
- [ ] Salvage requires confirmation for items of uncommon rarity or above: "Salvaging [fine iron longsword] will destroy it permanently. Confirm?"
- [ ] Transmutation: convert material type A into material type B at a defined conversion rate and cost (gold + reagent); rate always less than 1:1 to create an economic loss that acts as a sink — e.g., 3 iron ingots → 1 steel ingot (plus 5 silver + flux)
- [ ] Transmutation recipes in config; admin can adjust rates and add new conversion paths without code deploy
- [ ] Salvaging enchanted items has a small chance (scales with Enchanting skill) of recovering a magical component (resonant dust, enchant shard) usable as an enchanting reagent — narrated as: "As the blade dissolves in your salvager, a faint glow condenses into a small crystal."
- [ ] Salvage and transmutation events logged to the economy audit log (same schema as loot drops in US-138) for monitoring material injection/sink balance
- [ ] Broken items (durability 0) salvage for 50% normal yield — worth doing but not optimal; narrated: "The battered blade yields less than it might have in better days."

## Notes
Transmutation as a sink (AC-4) is critical for long-term economy health: without sinks, material supply grows unboundedly as players mine and loot. The conversion rate loss (3:1 for iron→steel) means transmutation is a last resort, not a primary production path. Players who want steel should mine steel or buy it; transmutation is for converting surplus iron when steel is scarce.

The rare component from enchanted item salvage (AC-6) creates a secondary market: players who collect and salvage large volumes of enchanted items can harvest magical components that are otherwise hard to obtain. This is an emergent profession Dave will likely discover and exploit.

The 50% yield from broken items (AC-8) is a meaningful design signal: players who let their gear shatter lose half the material value. Combined with the repair system (US-129), this creates a clear economic hierarchy: repair > salvage > shatter.

Dave will want the economy audit log (AC-7) to distinguish between salvage events and transmutation events so he can track each type of sink separately. Ensure the event_type field in the log makes this distinction explicit.

Salvage variance (AC-1) should use the same seeded RNG approach as crafting quality (US-140): seed from event timestamp + player_id for auditability.
