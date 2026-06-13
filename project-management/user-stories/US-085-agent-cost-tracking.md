---
id: US-085
title: "Track per-agent compute and API costs"
personas: [maya-chen, diana-kovacs]
domain: agents
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)** and **Diana Kovacs (Freelance Multi-Client)**, I want to track per-agent compute and API costs with budget alerts and spend breakdowns so that I can control costs and, for client work, attribute expenses accurately.

## Acceptance Criteria

- [ ] Each agent displays a real-time cost counter showing accumulated spend for the current billing period broken down by API calls, tokens, and compute time
- [ ] Per-agent budget caps can be set with configurable actions when reached: warn, pause agent, or hard-stop
- [ ] A cost dashboard shows spend trends over time with filters by agent, project, client, and date range
- [ ] Budget alert notifications fire at user-configured thresholds (e.g., 50%, 80%, 100% of budget)
- [ ] For multi-client users, costs can be tagged to specific clients or projects for invoicing and attribution

## Notes

Cost visibility is a top-three concern for both indie devs (tight personal budgets) and freelancers (client billing accuracy). The platform should track costs even when using external LLM providers via MCP — not just internal compute. Consider showing cost-per-task-completed as an efficiency metric alongside raw spend. For Diana's freelance workflow, the ability to export cost reports per client in CSV/PDF is essential for invoicing. This feature should degrade gracefully when exact API costs aren't available — show token counts and estimated costs rather than nothing.
