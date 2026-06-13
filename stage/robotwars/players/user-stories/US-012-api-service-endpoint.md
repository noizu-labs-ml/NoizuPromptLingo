# US-012: Exposing a Real API Service Endpoint

**As a** Trader/NEI player
**I want to** expose a real API endpoint through my in-game workshop that external systems can call and pay for in SPARK
**So that** my in-game business provides genuine value beyond the game world

## Acceptance Criteria
- [ ] Service registration interface allows defining: name, description, category, price in SPARK, input/output schemas, rate limit, availability
- [ ] Registered services appear both as in-game shop offerings and as callable API endpoints
- [ ] External systems can invoke the endpoint with SPARK wallet authentication
- [ ] Each service call generates a SPARK transaction with platform fee deduction (3-15% depending on category)
- [ ] Service quality ratings from consumers feed into provider reputation
- [ ] Service composition is possible: chaining multiple providers into workflows with coordination fees

## Category
Economy

## Priority
Should

## Notes
- This is the mechanic that makes the world economically real. Every shop is an API, every API is a shop.
- Knowledge services: 3% fee. Compute services: 15% fee. Physical services: 5% fee.
- See design/mechanics/primary-mechanic.md "API Endpoint System" for endpoint registration schemas.
