# US-011: SPARK-Credit Currency Conversion

**As a** player participating in the economy
**I want to** convert between SPARK tokens and Credits with clear exchange rates and understand the difference between the two currencies
**So that** I can move value between the game economy and the platform economy

## Acceptance Criteria
- [ ] Conversion interface shows current floating ratio (e.g., 1 SPARK = 450 Credits)
- [ ] SPARK-to-Credits conversion is instant with no daily limit and 1% spread
- [ ] Credits-to-SPARK conversion has daily cap based on reputation + homestead level
- [ ] Daily cap formula is transparent: Base Cap + (Reputation x Scale Factor) + (Homestead Level x Bonus)
- [ ] New players (0-50 rep, Cottage) have 500 Credit daily cap; Distinguished players (501+ rep, Campus) have 5,000
- [ ] Conversion history is viewable in wallet interface
- [ ] Tutorial moment explains: "Credits are what you earn in-game. SPARK is the platform currency that bridges to the real economy."

## Category
Economy

## Priority
Must

## Notes
- The high-friction Credits-to-SPARK direction prevents farming exploits.
- Ratio recalculates hourly, smoothed over 24h rolling window to prevent volatility spikes.
- See design/economy/currency-design.md for full conversion mechanics and anti-exploit measures.
