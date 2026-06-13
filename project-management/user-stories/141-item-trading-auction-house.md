# US-141: Item Trading and Auction House

**Persona:** Tyler — MMO refugee (22, sighted, growth/clans)
**Priority:** P0
**Epic:** Item Framework & Equipment

## Story
As Tyler, I want a fully accessible player marketplace with listings, bidding, and price history so that I can participate in the player economy competitively — and my clan can coordinate to dominate market niches.

## Acceptance Criteria
- [ ] Auction house supports three listing types: auction (bids, configurable duration 1–72 hours), buy-now (fixed price, immediate), and both (buy-now available alongside active bidding)
- [ ] Listing creation: seller specifies item, starting bid (auction) or price (buy-now), duration, and optional reserve price; listing fee charged upfront (non-refundable, scales with item value)
- [ ] Buyer search and filter: by item name, item type, rarity tier, stat ranges (e.g., attack > 20), price range, enchantments, material — all filters accessible via command syntax and form UI
- [ ] Escrow: listed items are immediately removed from seller inventory and held in escrow; gold from buy-now is transferred instantly; auction gold transferred when listing closes
- [ ] Outbid notification delivered via status ARIA channel: "You have been outbid on [item] — current bid is 85 silver."
- [ ] Price history available per item type: last 30 days of completed sale prices, presented as a min/max/average summary table (accessible to screen readers as a data table with column headers)
- [ ] All auction house interactions fully keyboard navigable: browsing listings, placing bids, creating listings, cancelling listings — no mouse-only controls; each action has a keyboard shortcut
- [ ] Listing expiry: unsold auction items returned to seller mailbox with a narrated notification; expired buy-now listings returned similarly
- [ ] Clan coordination feature: clan officers can create a watch list of items; when a matching listing appears, all online clan members are notified via guild channel

## Notes
Tyler's MMO background means he will immediately look for arbitrage opportunities: buy low in one region, sell high in another. The price history (AC-6) directly enables this. Consider whether the auction house is global (one market) or regional (geographic price variation). Regional markets create more interesting economics but more complexity. This is an early design decision.

The escrow model (AC-4) is critical for trust: players will not use an auction house that allows sellers to withdraw items after listing. Escrow must be enforced at the data layer, not just the application layer.

Outbid notifications via ARIA (AC-5) must be polite, not assertive — they should not interrupt combat narration. But they must arrive promptly (within the round that the outbid occurs). Store undelivered notifications for offline players and deliver on next login.

The price history data table (AC-6) is the accessible equivalent of a line chart. Structure it as: Date | Min Sale | Max Sale | Average | Volume. This data should be queryable via command: `ah history [item type]` returns the same data as a text summary.

The listing fee (AC-2) is an important economy sink: it costs gold to list items, discouraging spam listings of worthless items and providing a steady gold drain from the economy. Fee rate is a key economy tuning knob — make it configurable.
