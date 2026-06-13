# US-142: Item Socketing and Gems

**Persona:** Tyler — MMO refugee (22, sighted, growth/clans)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Tyler, I want to socket gems into my equipment for stat bonuses so that I have a fine-grained optimization layer beyond base item stats and enchantments.

## Acceptance Criteria
- [ ] Items may have 0–3 gem sockets, determined at creation by item quality (poor: 0, standard: 0–1, fine: 1, masterwork: 1–2, legendary: 2–3) and a quality variance roll at item creation
- [ ] Gem types with distinct bonus profiles: ruby (fire damage/resistance), sapphire (ice/mana), emerald (stamina/poison resistance), topaz (lightning/speed), diamond (all stats small bonus), onyx (shadow/stealth), and pearl (luck/healing)
- [ ] Socketing action: `socket [gem] into [item]` — requires the item to have an empty socket; narrated: "You press the ruby into the sword's setting — it flares briefly and dims to a deep inner glow."
- [ ] Unsocketing gems: requires an Unsocketing Kit (consumable); 70% chance gem is recovered intact, 25% gem is destroyed, 5% both gem and item socket are permanently damaged
- [ ] Socket count displayed in item description: "iron longsword [2 sockets: ruby, empty]"
- [ ] Gem bonuses are additive with enchantments but do not stack with each other (socketing two rubies gives the bonus of the higher-quality ruby, not the sum)
- [ ] Gem quality tiers (rough, cut, polished, flawless) determine bonus magnitude; gems can be cut by players with Gemcutting skill, upgrading from rough → cut → polished
- [ ] Screen reader view of socketed item: `examine [item]` lists sockets as a sublist — "Sockets: [1] Ruby (polished) — +8 fire damage / [2] Empty"

## Notes
The non-stacking rule for same-gem-type (AC-6) prevents trivial optimization of socketing three identical gems. Players must choose between gem types, creating genuine tradeoff decisions. The "higher quality wins" rule is the simplest implementation of this constraint.

The Unsocketing Kit risk (AC-4) is the key economic tension: a flawless ruby is worth far more than a standard one, but the 30% chance of losing it on unsocketing makes players hesitant to experiment. This is intentional friction that makes gem selection a meaningful commitment rather than freely reversible.

Gemcutting as a player skill (AC-7) creates a service profession: players with Gemcutting can upgrade rough gems for others, charging a fee. This integrates with the player economy (US-141) — cut gems are tradeable and have market price distinct from rough gems.

The 5% "both gem and socket damaged" outcome on unsocketing (AC-4) means the item itself can be degraded by a failed unsocket. This is a permanent consequence — the socket does not return. Item description should reflect the damaged socket: "iron longsword [1 socket: damaged (unusable), 1 socket: empty]."

For screen reader users, the socket sublist in examine output (AC-8) must be navigable independently from the main item stats — users should be able to skip directly to the socket section without reading the full stat block.
