---
id: P-008
name: "Simone Adeyemi"
slug: "platform-admin"
archetype: "The Quality Gatekeeper"
segment: "edge-case"
tags: [admin, moderation, internal, content-quality, spam-prevention, trust-and-safety]
---

# Simone Adeyemi — The Quality Gatekeeper

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 28-38 |
| **Role** | Platform Operations / Trust & Safety |
| **Technical Level** | Advanced |
| **Industry** | SaaS / Platform Operations |
| **Location** | Remote (EU or U.S.) |

## Bio

Simone is an early employee at BloggersCompete, wearing the hat of platform integrity, content moderation, and ops. She came from a trust & safety role at a mid-size content platform and was brought in specifically because the founding team knew that any scored ranking system would be gamed the moment it got traction. She's analytical, skeptical by training, and acutely aware that the platform's entire value proposition collapses if the scores and leaderboards stop being credible.

## Goals

1. Detect and remove low-quality, spammy, or AI-generated-without-editing blogs before they pollute the leaderboard
2. Identify systematic gaming behavior (e.g., bloggers creating multiple accounts, submitting the same blog repeatedly with minor changes) before it becomes a user-visible problem
3. Maintain score credibility by ensuring the AI scoring model is regularly audited and not drifting from human judgment

## Frustrations

1. Most content moderation tools are built for social media at scale, not for evaluating long-form blog quality
2. When a high-profile user publicly complains about a score, she's the one who has to investigate and respond — without good audit trails, this is painful
3. The platform's growth creates a tension: more signups = more noise, and the quality signal degrades as bad actors find the platform

## Behaviors

- Monitors a moderation queue dashboard every morning; sets severity thresholds for automated flagging
- Runs weekly queries on the database looking for anomalies: score distributions, sudden rank jumps, duplicate blog fingerprints
- Maintains a private test suite of known-quality and known-low-quality blogs to sanity-check scoring model updates
- Communicates with the ML team quarterly to flag score drift issues and propose rubric refinements

## Job to Be Done

> "When bad actors find ways to game the platform, I want early detection signals and efficient moderation tools, so I can protect leaderboard integrity before the user community notices and trust erodes."

## Relationship to Product

Simone is an internal user — she didn't discover the product, she joined the company to build its integrity layer. She interacts with the platform through an admin dashboard that's not visible to regular users. Her success metric is the absence of visible problems: no viral "these scores are fake" posts, no mass churn events triggered by integrity failures. She's the persona who cares most deeply about score methodology documentation, moderation audit logs, and the appeals process. Her needs directly shape admin tooling requirements.

## Scenarios

1. **Spam Wave Response** — Simone notices a cluster of 40 blog submissions over 3 days, all from newly created accounts, all scoring suspiciously high on Originality despite being thin affiliate sites. She traces them to a single IP range, bulk-flags them, suspends the accounts, and files a retroactive scoring adjustment request with the ML team.
2. **Score Dispute Investigation** — A Pro subscriber with 800 followers publicly tweets that their score dropped 12 points "for no reason" after a scoring model update. Simone pulls the audit log, confirms the model update introduced a new Visual Design signal, drafts a response explaining the change, and uses the incident to push for a model changelog notification feature.
