# US-064: NPC Shop Supply and Demand Pricing

**Persona:** Dave — Sighted MUD Veteran
**Priority:** P1
**Epic:** NPC Economy

## Story
As Dave, I want NPC shop prices to fluctuate based on supply and demand so that market speculation and bulk trading are viable economic strategies.

## Acceptance Criteria
- [ ] Each NPC shop maintains a stock level per item that depletes with purchases and restocks over time
- [ ] Buy price rises as stock falls; sell price drops as stock fills — announced transparently (e.g., "Blacksmith's iron supply is low. Current buy price: 18g [+6g above base]")
- [ ] Players can `INSPECT SHOP` to see current stock levels and price trends for key items
- [ ] Screen reader output for shop listings uses a navigable list: item name, price, stock indicator (plentiful/limited/scarce/out), one item per list node
- [ ] Price history for the last 7 in-game days is available via `PRICE HISTORY [item]`
- [ ] Market-wide price indexes are accessible via a `MARKET` command announcing top movers

## Notes
Dave is an economist at heart. The supply/demand system is a key differentiator. Make price trend data richly accessible — blind players should be able to use the same market data as sighted players. Consider ARIA live regions for price ticker updates in the web client.
