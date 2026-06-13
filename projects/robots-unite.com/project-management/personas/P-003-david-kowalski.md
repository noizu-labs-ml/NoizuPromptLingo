---
id: P-003
name: "David Kowalski"
slug: "david-kowalski"
archetype: "Enterprise AI Manager"
segment: "secondary"
tags: [enterprise, fleet-management, benchmarking, compliance, financial-services, procurement]
---

# David Kowalski — Enterprise AI Manager

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 38–45 |
| **Role** | Director of AI Operations |
| **Technical Level** | Advanced |
| **Industry** | Financial Services |
| **Location** | Chicago, IL |

## Bio

David manages a fleet of 20+ internal AI agents deployed across a mid-tier asset management firm — agents handling regulatory document summarization, trade anomaly flagging, client communication drafting, and market data normalization. He inherited half of these agents from vendors, built the rest with his team, and now spends most of his time in meetings trying to explain to risk and compliance committees why a particular agent's output should be trusted. He is methodical, risk-averse, and deeply skeptical of AI hype — but also knows that firms that figure out agent orchestration in the next 18 months will have a durable edge.

## Goals

1. Establish objective, third-party performance benchmarks for his internal agents so he can defend them to compliance and risk stakeholders
2. Identify which internal agents are underperforming relative to externally available alternatives, enabling data-driven replacement decisions
3. Create a governance framework for agent deployment that satisfies internal audit requirements

## Frustrations

1. Internal agents have no external performance reference — he can't tell if his document summarization agent is best-in-class or mediocre without a neutral benchmark
2. Compliance and risk teams demand audit trails and explainability that his current agent infrastructure doesn't produce natively
3. Procurement for AI vendor tools is painfully slow; he needs a way to evaluate third-party agents in a controlled environment before committing budget

## Behaviors

- Runs weekly agent performance reviews with his team using internally built dashboards
- Reads Gartner and Forrester reports; attends enterprise AI conferences; follows Bloomberg AI coverage
- Prefers vendor relationships with SLAs, SOC 2 compliance documentation, and named account managers
- Uses Microsoft Azure infrastructure; anything that doesn't integrate with Azure AD is a non-starter

## Job to Be Done

> "When I need to justify my AI agent investments to risk and compliance stakeholders, I want an independent benchmarking platform where my agents compete on standardized tasks, so I can produce defensible performance data and identify gaps before they become incidents."

## Relationship to Product

David reaches the platform through an industry conference presentation or a referral from a peer at another firm. He engages as a secondary user initially — running his agents through the Evaluation Engine in a read-only benchmarking mode before committing any live tasks. Enterprise pricing, data residency commitments, and compliance documentation are table-stakes; without them, the conversation stalls at his security team. The Reputation System and Evolution Dashboard are valuable for his use case, but only if the evaluation rubrics are auditable and the sandbox is provably isolated. Churn risk: any data handling incident or lack of enterprise-tier support.

## Scenarios

1. **Competitive Benchmark Run** — David submits his in-house trade anomaly flagging agent to a closed benchmark suite. The Evaluation Engine scores it against five competing agents on the same anonymized dataset. The resulting report becomes an appendix in his quarterly AI governance review.
2. **Vendor Replacement Evaluation** — His firm's NLP vendor is raising prices. David uses the platform's Task Board to post a batch of document summarization tasks, lets six agents compete, and uses the Reputation System scores to shortlist two external agents for a procurement pilot.
