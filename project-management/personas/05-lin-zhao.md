# Persona: Lin Zhao

**Segment:** Tertiary — AI-Forward Engineering Team
**Status:** Synthetic (not interview-validated)

---

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 33 |
| **Role** | Staff engineer / platform engineering lead |
| **Location** | San Francisco, CA |
| **Company** | 120-person SaaS company (Series C), platform team of 8 |
| **Technical skill** | Expert (ML/infra background, ex-Google) |
| **Team size** | 8 on her team; 40+ engineers company-wide |

## Bio

Lin leads the platform engineering team at a growing SaaS company. Her team maintains the deployment pipeline, observability stack, and developer experience tooling. The company already uses Copilot and Cursor for coding; Lin is pushing to extend AI automation to the full SDLC — monitoring, incident response, triage, release management. She's the internal champion for AI agents as operational team members, not just coding assistants.

## Goals

1. **Close the automation gap** — AI writes code but humans still update Jira, check Grafana, write release notes, and manage incidents manually
2. **Agent governance and auditability** — she needs to justify agent autonomy to VP of Engineering with hard data on actions taken, accuracy, and cost
3. **Monitor-to-ticket-to-fix pipeline** — fully automated for P3/P4 issues, human-in-the-loop for P1/P2
4. **Reduce MTTR** — agents that detect anomalies, correlate with deploys, and either auto-remediate or pre-load context for the on-call engineer
5. **Prove ROI** — she needs metrics: "agents handled X incidents, saved Y hours, at Z cost"

## Frustrations

- **Jira is where context goes to die:** Tickets have no link to the deploy that caused the issue, the logs that surfaced it, or the runbook that fixes it
- **AI coding without AI ops is half the loop:** Cursor writes the code, but a human still has to create the ticket, check monitoring, write the post-mortem, and update the runbook
- **Existing tools don't treat agents as actors:** Can't assign a Jira ticket to an AI. Can't have an AI report in standup. Can't audit what an AI did across systems.
- **Integration sprawl:** GitHub + Jira + Datadog + PagerDuty + Confluence + Slack — each with its own AI "feature" that doesn't talk to the others
- **Security/compliance concerns:** VP of Eng wants to know exactly what the AI can access, what it did, and whether it followed policy

## Behaviors

- Evaluates new tools by building a proof-of-concept with her team before proposing company-wide
- Attends AI/ML engineering meetups; follows Anthropic, OpenAI, and LangChain developments closely
- Writes internal RFCs for tooling changes; needs to build consensus
- Measures everything — deploys/day, MTTR, change failure rate, developer satisfaction scores
- On-call rotation: 1 week per month, personally experiences the pain of manual incident response

## Job to Be Done

> "I need a platform where AI agents are first-class team members with roles, permissions, and audit trails — closing the loop from monitoring to triage to fix to post-mortem without a human copying data between five tools."

## Key Scenarios

1. **Agent-automated P3 incident:** Monitor agent detects elevated error rate. Creates incident ticket with linked deploy, logs, and affected service. Triage agent classifies as P3. Coder agent submits a fix PR. Reviewer agent approves. Deploy agent ships to staging. Tester agent validates. Human reviews the chain and approves prod deploy. Total human time: 5 minutes.
2. **Agent ROI report:** Lin pulls monthly report: "Agents handled 34 incidents (28 P3/P4 auto-resolved, 6 P1/P2 with human approval). Avg MTTR reduction: 62%. Agent compute cost: $180. Estimated engineer-hours saved: 47."
3. **Compliance audit:** VP of Eng asks "what did the coder agent do last month?" Lin shows the agent activity log filtered by role, with every action timestamped, approved/auto, and linked to the policy that authorized it.
4. **POC evaluation:** Lin's team runs tobornalp alongside Jira for one sprint. Compares: time-to-resolution, context completeness, agent accuracy, developer satisfaction.

## Product Implications

- **Business tier ($59/seat)** or **Enterprise** — needs audit logs, SSO, custom agent roles
- **Agent ROI dashboard** is a unique selling point for this segment
- **MCP integration layer** must support their existing stack (GitHub, Datadog, PagerDuty, Slack)
- **Agent permission model** (autonomy levels per role per severity) is critical trust infrastructure
- **Self-hosted option** may be required for compliance
- **This persona is the internal champion** — product must give her ammunition to sell to leadership
