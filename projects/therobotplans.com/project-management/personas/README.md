# tobornalp — User Personas

7 synthetic personas spanning the four target segments identified in the product README. These are pre-validation — derived from product vision, not user interviews. Use them for design decisions, feature prioritization, and user story generation. Validate with real users before treating as ground truth.

## Persona Map

| # | Name | Segment | Archetype | Target Tier | Key Feature Need |
|---|------|---------|-----------|-------------|-----------------|
| 1 | [Maya Chen](01-maya-chen.md) | Primary | Solo indie hacker | Pro | Unified today view, monitor agent, keyboard-first |
| 2 | [Raj Patel](02-raj-patel.md) | Primary | Side-project builder | Free → Pro | Mobile capture, session prep agent, life OKRs |
| 3 | [Sarah Kim](03-sarah-kim.md) | Secondary | Small team eng lead | Team | PM agent, review agent, CEO status reports |
| 4 | [James Oduya](04-james-oduya.md) | Secondary | Agency owner | Business | Multi-project portfolio, templates, client reports |
| 5 | [Lin Zhao](05-lin-zhao.md) | Tertiary | AI-forward platform eng | Business/Enterprise | Agent governance, ROI metrics, MCP integrations |
| 6 | [Alex Russo](06-alex-russo.md) | Aspirational | Productivity enthusiast | Free → Pro | Planner agent, habit intelligence, weekly review |
| 7 | [Diana Kovacs](07-diana-kovacs.md) | Cross-cutting | Freelance multi-client | Pro | MCP sync from client tools, time tracking, cross-client view |

## Segment Coverage

- **Primary (2):** Maya and Raj represent the solo builder spectrum — full-time indie vs. part-time side-project. Both validate the "personal + professional unified" thesis but with different time budgets and tool expectations.
- **Secondary (2):** Sarah and James represent small teams — internal engineering lead vs. client-facing agency. Both need multi-project visibility and PM agent, but Sarah's pain is operational overhead while James's is client communication.
- **Tertiary (1):** Lin represents the AI-forward enterprise buyer — the internal champion who needs governance, metrics, and executive ammunition.
- **Aspirational (1):** Alex represents the non-developer productivity enthusiast — validates whether the personal layer can stand alone without dev-tool framing.
- **Cross-cutting (1):** Diana surfaces the multi-tool integration story — validates MCP as the connective tissue for users embedded in other ecosystems.

## Adoption Funnel

```
Free tier (personal todos, 1 project, planner agent)
  ├── Raj: starts here, upgrades when side project grows
  └── Alex: starts here, upgrades for full planner + habits

Pro tier ($14/mo — unlimited personal, 3 projects, 3 agents)
  ├── Maya: lands here immediately (2 products + personal)
  └── Diana: lands here (1 project per active client)

Team tier ($29/seat — unlimited projects + agents, full ops)
  └── Sarah: buys for her 6-person team

Business tier ($59/seat — OKR cascade, reporting, audit)
  ├── James: buys for agency (cross-project reporting)
  └── Lin: starts POC here

Enterprise (self-hosted, SSO, compliance)
  └── Lin: graduates here after successful POC
```

## Usage Notes

- Each persona includes a **Product Implications** section — use these to prioritize features by persona coverage
- **Job to Be Done** statements are designed for user story generation (next step: `project-management/user-stories/`)
- Personas are numbered for reference but not ranked — priority comes from segment, not sequence
- All personas are flagged as **synthetic** — schedule user interviews to validate before committing major design decisions
