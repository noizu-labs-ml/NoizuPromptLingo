---
id: P-001
name: "Maya Chen"
slug: "maya-chen"
archetype: "AI Red Team Lead"
segment: "primary"
tags: [red-teaming, llm-security, offensive-security, team-lead, catalog, defender, academy]
---

# Maya Chen — AI Red Team Lead

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 31–37 |
| **Role** | AI Red Team Lead / Principal AI Security Researcher |
| **Technical Level** | Expert |
| **Industry** | Big Tech / AI-native company |
| **Location** | San Francisco Bay Area or Seattle |

## Bio

Maya leads a 6-person AI red team at a major AI lab, responsible for adversarial testing of internal LLM products before release. She came up through traditional penetration testing, pivoted to AI security in 2022 when her company started shipping LLM-powered products, and now spends her days finding ways to make models do things they shouldn't. She presents at DEF CON AI Village annually and maintains a private repo of jailbreak primitives she's developed over the past three years.

## Goals

1. Systematically catalogue and track novel jailbreak techniques so her team isn't duplicating work or missing known vectors.
2. Automate regression testing against LLM endpoints to catch prompt injection vulnerabilities introduced during fine-tuning or RLHF updates.
3. Build a credible, reproducible disclosure record to support responsible vulnerability reporting to model vendors.

## Frustrations

1. No authoritative taxonomy exists — her team reinvents categorization schemes every engagement, making cross-team knowledge sharing chaotic.
2. Existing tools (Garak, custom scripts) require significant setup and produce inconsistent output formats that are hard to present to product teams.
3. Academic papers lag 6–12 months behind operational reality; she often discovers techniques independently only to find them later in a preprint.

## Behaviors

- Maintains a private Notion database of jailbreak techniques with her own taxonomy, which she'd love to migrate to something collaborative.
- Runs weekly red team sessions using a rotating technique queue; documents findings in JIRA-linked markdown.
- Actively monitors HuggingFace papers, Twitter/X security lists, and private Slack communities for emerging techniques.
- Uses Burp Suite muscle-memory — she reaches for proxy-based thinking when approaching LLM attack surfaces.

## Job to Be Done

> "When I'm scoping an LLM red team engagement, I want to pull a structured, up-to-date list of relevant attack techniques by model family and capability, so I can build a complete test plan in hours instead of days."

## Relationship to Product

Maya discovers JailbreakingSite.com through a DEF CON AI Village talk or a peer referral. She adopts the Catalog immediately as a replacement for her Notion database, then evangelizes Defender to her manager as a way to automate regression testing in CI/CD. She's a power user of the API. Churn risk is low unless the Catalog falls behind the research frontier — she'll notice immediately if techniques she's finding in the wild aren't indexed.

## Scenarios

1. **Pre-engagement scoping** — Maya opens the Catalog, filters by `target-capability: code-execution` and `model-family: GPT-4-class`, exports a structured list of relevant techniques and their mitigations, and drops it into her engagement brief within 20 minutes.
2. **CI/CD regression gate** — After a model fine-tuning run, Maya's pipeline calls the Defender API with a suite of technique IDs; the scan returns a pass/fail with reproduction steps for any regressions, which auto-files a JIRA ticket.
