# US-065: Player-to-Player Trading

**Persona:** Marcus — Blind Power Gamer
**Priority:** P0
**Epic:** Player Economy

## Story
As Marcus, I want to initiate, negotiate, and complete trades with other players using keyboard commands so that I can buy and sell gear efficiently without losing competitive advantage due to inaccessible trade UIs.

## Acceptance Criteria
- [ ] `TRADE [player]` initiates a trade request; target receives a voiced prompt to accept/decline
- [ ] Trade window is a two-pane text interface: "Your offer:" and "Their offer:" — screen reader navigates between panes with tab
- [ ] `OFFER [item/amount]` and `REMOVE [item/amount]` modify the offer; changes are announced immediately via ARIA live region
- [ ] Both parties must `CONFIRM` before trade executes; a final summary is read aloud before confirmation
- [ ] Trade completion announces both sides of the exchange: "Trade complete. You gave: Masterwork Longsword. You received: 450 gold, 2 crystals."
- [ ] Trades can be cancelled at any point with `CANCEL TRADE`; cancellation is announced to both parties
- [ ] Trade history is accessible via `TRADE LOG` (last 20 trades with partner name, items, value, timestamp)

## Notes
Marcus operates at 90WPM and expects trades to be fast. The trade flow must not require mouse interaction at any step. Keyboard shortcuts for common actions (offer all, clear offer, confirm) should be documented and consistent.
