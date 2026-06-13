---
id: P-002
name: "James Okafor"
slug: "james-okafor"
archetype: "Enterprise AppSec Manager"
segment: "secondary"
tags: [appsec, enterprise, risk-management, defender, catalog, team-management, compliance]
---

# James Okafor — Enterprise AppSec Manager

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 38–46 |
| **Role** | Application Security Manager |
| **Technical Level** | Advanced |
| **Industry** | Financial Services / Insurance |
| **Location** | Chicago, New York, or London |

## Bio

James manages a team of 8 AppSec engineers at a mid-large financial institution. He spent the first decade of his career in traditional web application security — OWASP Top 10, SAST/DAST tooling, secure code review — and has been watching the LLM adoption wave roll through his organization with a mixture of urgency and anxiety. His company's product teams are integrating GPT-4 into customer-facing applications and internal tooling faster than his team can assess them, and his VP is asking him monthly what the AI risk posture looks like. He doesn't have AI security expertise on his team yet.

## Goals

1. Establish a repeatable, defensible process for assessing LLM-integrated applications before they go to production.
2. Give his team enough LLM security context to conduct basic assessments without waiting for a specialist engagement.
3. Produce executive-ready risk reports that map LLM vulnerabilities to business impact and compliance frameworks (SOC 2, NIST AI RMF).

## Frustrations

1. His team knows AppSec deeply but LLM attack surfaces are alien — there's no standard checklist equivalent to OWASP for LLM risks his team can execute against.
2. Consultant engagements for AI red teaming cost $40K+ and take 6 weeks to schedule; his product teams are shipping every two weeks.
3. His CISO keeps asking if they're covered for "prompt injection attacks" and he doesn't have a confident answer.

## Behaviors

- Runs weekly AppSec triage meetings; assigns findings by severity using CVSS-equivalent scoring he's adapted.
- Evaluates new security tools based on integration with existing stack (Jira, ServiceNow, Splunk) and license model compatibility with enterprise procurement.
- Reads OWASP LLM Top 10, NIST AI RMF, and attends 1-2 security conferences per year (RSA, AppSec Global).
- Makes buying decisions based on POC results, not demos — he'll run a 30-day trial before presenting to his VP.

## Job to Be Done

> "When my team needs to assess an LLM-powered application for security risks, I want a structured tool that gives junior AppSec engineers a repeatable testing methodology, so I can scale assessments without hiring a specialist for every engagement."

## Relationship to Product

James discovers the platform via an OWASP community post, a Gartner mention, or a peer recommendation at a conference. He evaluates Defender as a tool his team can use to run LLM assessments with a guided methodology. The Catalog gives his team reference material. He's the economic buyer for an enterprise seat; he'll require SSO, audit logging, and a security review before procurement. Churn risk is high if onboarding requires deep LLM expertise he doesn't have — the tool needs to meet his team where they are.

## Scenarios

1. **New application risk assessment** — James's team receives a security review request for an internal chatbot built on Azure OpenAI. An engineer uses the Catalog's technique browser filtered by OWASP LLM Top 10 categories to build a test checklist, then runs Defender against the staging endpoint; the report maps findings to CWE IDs James can attach to the risk register.
2. **Executive reporting** — James exports a Defender scan summary with technique coverage percentages and risk ratings, maps it to NIST AI RMF categories, and presents it to his CISO as evidence of LLM risk governance posture.
