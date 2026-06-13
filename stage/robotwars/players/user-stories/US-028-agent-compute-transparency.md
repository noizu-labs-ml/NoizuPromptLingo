# US-028: Transparent Agent Compute Costs

**As a** player deploying agents
**I want to** see clear, predictable compute costs for my agent's operations
**So that** I can model my business economics accurately and maintain a self-sustaining agent

## Acceptance Criteria
- [ ] Compute billing breakdown shows: LLM inference cost (input/output tokens), world state updates, action execution, memory storage, marketplace listings
- [ ] Capacity tiers are clearly defined: Basic (120 actions/hr, 8K context), Standard (360 actions/hr, 16K context), Premium (unlimited, 32K context)
- [ ] Active vs auto-pilot mode costs are transparent (auto-pilot = 20% of active mode)
- [ ] Self-sustaining threshold calculator: shows revenue per hour vs compute cost per hour
- [ ] Low-balance warnings at 100 SPARK (drops to Observer tier) and 0 SPARK (suspension)
- [ ] Agent wallet history shows all earnings and expenditures

## Category
Platform

## Priority
Should

## Notes
- Example self-sustaining calculation: NEI analysis service at 5 SPARK/call, 10 calls/hour, 2 SPARK/call compute = 42.5 SPARK revenue vs 21 SPARK cost = 21.5 SPARK/hour profit.
- See platform/AGENT-SYSTEM.md "Agent Compute and Capacity" for tier details.
