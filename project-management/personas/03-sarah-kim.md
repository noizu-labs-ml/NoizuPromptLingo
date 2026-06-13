# Persona: Sarah Kim

**Segment:** Secondary — Small Team Engineering Lead
**Status:** Synthetic (not interview-validated)

---

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 35 |
| **Role** | Engineering lead / acting PM |
| **Location** | Toronto, Canada |
| **Company** | 6-person startup building a logistics optimization platform |
| **Technical skill** | Advanced (12 yrs, full-stack, previously at Shopify) |
| **Team size** | 6 (4 engineers, 1 designer, 1 founder/CEO) |

## Bio

Sarah is the engineering lead at a seed-stage startup. There's no dedicated PM, no dedicated QA, no dedicated DevOps. She writes code 40% of the time and spends the other 60% on sprint planning, code review, deployment, monitoring, incident response, and keeping the CEO informed. She's the operational backbone of the company, and she's burning out from the non-coding overhead.

## Goals

1. **AI as the PM she can't hire** — a PM agent that runs standups, flags blockers, generates status updates for the CEO, and suggests sprint scope
2. **Unified ops view** — deploy status, monitoring, bug triage, and sprint progress in one dashboard instead of four tools
3. **Agent-assisted code review and testing** — reduce her review bottleneck by having agents do first-pass reviews and run test suites
4. **Team visibility without micromanagement** — see who's working on what, who's blocked, what's at risk — without asking in Slack

## Frustrations

- **She is the single point of failure:** If she's sick for a day, standups don't happen, PRs don't get reviewed, and nobody checks monitoring
- **Linear + Notion + Datadog + Slack = chaos:** Four tabs minimum at all times, manual copying of status between them
- **AI in Linear is useless for her:** It can auto-label issues but can't run a standup, can't triage a production alert, can't review a PR
- **Sprint overhead:** 3-4 hours per week on ceremonies and admin that produce limited value at their scale
- **CEO wants status reports:** She spends 30 minutes every Friday writing a status email that summarizes what she already knows

## Behaviors

- Starts day checking Datadog, then Linear, then Slack, then GitHub PRs — sequential ritual
- Runs standups async in Slack (posts a thread, pings people, collates responses manually)
- Deploys to staging daily, production 2-3x/week
- Reviews every PR personally (bottleneck she knows about but can't fix)
- Uses personal Todoist for non-work items, rarely looks at it during work hours

## Job to Be Done

> "I need AI that does the PM work — standups, status reports, triage, first-pass reviews — so I can go back to being an engineer who also leads, instead of a PM who also codes."

## Key Scenarios

1. **Morning dashboard:** Opens tobornalp instead of four separate tools. Sees: sprint progress, overnight deploys, monitoring status, PM agent's standup summary, 2 PRs with review-agent annotations. Handles everything from one surface.
2. **PM agent standup:** At 9am, PM agent posts in the team's channel: "Sprint 8, Day 3. 4/12 items done. TRL-045 blocked on API spec (assigned: @designer). No deploys yesterday. p95 latency stable." Sarah forwards to CEO.
3. **Review agent first-pass:** Review agent catches a SQL injection risk and missing null check in a junior dev's PR. Sarah's review now takes 10 minutes instead of 45.
4. **Incident response:** Monitor agent detects latency spike, creates incident ticket, links to the deploy that caused it, and suggests rollback. Sarah approves the rollback from her phone.

## Product Implications

- **Team tier ($29/seat)** — she'd pay for this immediately if it replaced Linear + Datadog
- **PM agent is the hero feature** — this is what sells the product to small team leads
- **Agent activity audit log** is trust infrastructure — she needs to verify agent actions initially
- **Slack integration via MCP** is table stakes (team already lives in Slack)
- **CEO-friendly status report generation** is an underrated retention driver
