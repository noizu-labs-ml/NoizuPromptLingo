# US-146: Item Binding Rules

**Persona:** Tyler — MMO refugee (22, sighted, growth/clans)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Tyler, I want clear item binding rules so that I understand which items I can trade and which I'm committing to personally — enabling strategic decisions about when to equip powerful drops versus holding them for trade value.

## Acceptance Criteria
- [ ] Three binding states: Unbound (freely tradeable), Bind-on-Equip (BoE — becomes soulbound when first equipped), Soulbound (permanently bound to the character who owns it; cannot be traded, listed on AH, or mailed)
- [ ] A fourth state: Account-Bound — tradeable between characters on the same account, not between accounts; used for cosmetics and crafting materials
- [ ] Binding state prominently displayed in item description: "[Soulbound]", "[Bind on Equip]", "[Account-Bound]", or "[Tradeable]" — always the first line of item metadata, announced first by screen readers
- [ ] When equipping a BoE item, a confirmation prompt explains the consequence: "Equipping [epic ring of storms] will bind it to your character — you will no longer be able to trade or sell it. Confirm?"
- [ ] Attempting to trade or AH-list a soulbound item fails with a narrated explanation: "Your ring of storms is bound to you — only the void can claim it now."
- [ ] Crafted items default to Tradeable; crafted items of legendary quality default to BoE; this is configurable per item type in the recipe definition
- [ ] Binding status is visible in the item comparison tool (US-137) so that Tyler can factor trade value into gear decisions: "new item is Bind on Equip — equipping will bind it."
- [ ] Admin can set binding rules per item template; existing item instances are not retroactively changed when an admin updates a template's binding rule

## Notes
BoE is the most strategically interesting state for Tyler: a powerful BoE epic has trade value as long as he doesn't equip it. He will explicitly decide "is this an upgrade worth binding, or is it worth more as trade currency?" This decision is rich and meaningful — the confirmation prompt (AC-4) is the moment that crystallizes it.

Soulbound items leave the economy permanently: they cannot be sold, traded, or returned to circulation. This is the intended scarcity mechanism for the most powerful items. Without binding, high-end items would concentrate in the hands of the most active traders rather than the most skilled players.

Account-Bound (AC-2) is essential for alt characters: players who maintain multiple characters on one account should be able to pass cosmetics and crafting materials between them without being taxed by binding. This makes the game friendlier to the casual player who experiments with multiple classes.

Retroactive binding rule changes (AC-8) must not affect existing item instances — if iron longswords are changed from Tradeable to BoE, every existing iron longsword held by players should remain Tradeable. Only new drops/crafts use the new rule. This is a player trust requirement.

The binding state must be indexed in the inventory database for efficient filtering — "show me all tradeable items in my inventory" should be a fast query, not a full scan.
