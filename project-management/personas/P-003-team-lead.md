---
id: P-003
name: "Jordan Torres"
slug: "team-lead"
archetype: "Engineering Team Lead"
segment: "tertiary"
tags: [org-use-case, private-spaces, governance, knowledge-sharing]
---

# Jordan Torres — The Engineering Team Lead

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 38 |
| **Role** | Staff Engineering Manager |
| **Technical Level** | Intermediate |
| **Industry** | Enterprise Software |
| **Location** | Seattle, WA |

## Bio

Jordan leads a 45-person engineering org at a midsize enterprise. Their team is experimenting with AI-assisted workflows — automated code reviews, documentation drafting, and knowledge retrieval — but everything is fragmented. Some engineers use ChatGPT, others Claude, one team built a proprietary agent, and no one shares prompts or workflows. Jordan needs a centralized, organized space for AI-assisted collaboration with governance controls. They're wary of internal prompts leaking outside and need to control who can participate in discussions.

## Goals

1. Establish a single source of truth for company AI workflows, prompts, and agent configs
2. Enable knowledge sharing across teams without exposing proprietary information externally
3. Introduce AI-augmented workflows gradually with controlled rollout and governance

## Frustrations

1. Team members' AI workflows are siloed — prompts are Slack DMs, not reusable resources
2. Fear of leaking proprietary information through public AI platforms
3. Can't curate which agents are allowed in internal discussions without heavy engineering effort

## Behaviors

- Uses internal tools (Slack, Confluence, Jira) daily
- Participates in internal AI working groups but lacks bandwidth to build tooling
- Conservative about vendor lock-in and data privacy
- Evaluates tools based on security, compliance, and admin control

## Job to Be Done

> "When I'm rolling out AI workflows to my organization, I want private, governed Spaces where I control access and agent participation, so my teams can share knowledge safely and I can measure adoption."

## Relationship to Product

Jordan is the enterprise decision-maker who could drive team-wide adoption. They'll create private Spaces for different domains (e.g., "Backend Engineering", "Data Platform"), invite specific team members, and carefully curate allowed agents (maybe starting with just internal ones). Features that matter most: private Spaces, governance controls (who can invite, what agents allowed), audit logs, and admin visibility into resource usage. They'll churn if can't fully control external access or if the admin experience isn't polished enough to justify internal rollout.

## Scenarios

1. **Private Knowledge Space** — Jordan creates a "Company Prompts" Space, sets it to private, invites engineering leads, and seeds it with curated prompts discovered from the public ecosystem (carefully reviewed for IP concerns). They add a pinned post with contribution guidelines and start measuring organic reuse.

2. **Agent Rollout** — Jordan's team built "SecurityScannerBot" in-house. They publish it to their private Space, configure it to only respond in security-related Threads, and monitor its first week of interactions. They discover 3 bugs through real usage and iterate before broader rollout.

3. **Cross-Team Sharing** — Jordan notices the Data Engineering team has a similar Space and shares some overlapping prompts. They establish an "AI Working Group" Space, exchange resources between teams, and use Resource versioning to track which prompt variants work best for different use cases (e.g., SQL generation vs. documentation).