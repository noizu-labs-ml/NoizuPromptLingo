---
id: P-005
name: "Rachel Thompson"
slug: "rachel-thompson"
archetype: "Mid-Market CISO"
segment: "secondary"
tags: [ciso, risk, compliance, enterprise, governance, defender, reporting, procurement]
---

# Rachel Thompson — Mid-Market CISO

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 42–52 |
| **Role** | Chief Information Security Officer |
| **Technical Level** | Intermediate |
| **Industry** | SaaS / Healthcare Tech |
| **Location** | Atlanta, Denver, or Remote (US) |

## Bio

Rachel is the CISO of a 400-person SaaS company that sells workflow software to healthcare organizations. She has a strong background in GRC (governance, risk, and compliance) and has spent the last two years navigating HIPAA, SOC 2 Type II, and an increasing board-level fixation on AI risk. Her company's product team has integrated LLMs into three product features in the last 18 months, and she signed off on each deployment without a clear framework for assessing the adversarial risk surface. Now a competitor's AI feature was jailbroken by a security blogger, and her board wants to know if the same can happen to them.

## Goals

1. Develop and document an AI security governance framework that satisfies the board, regulators, and enterprise customers' security questionnaires.
2. Understand what her company's actual AI risk exposure is before a researcher or adversarial customer discovers it publicly.
3. Select a vendor/tool that gives her organization defensible, documented evidence of LLM security diligence without requiring her to hire an AI security specialist.

## Frustrations

1. She can't answer "are our LLM features secure?" with any confidence — there's no standard she can point to, no tool she knows of, and no budget allocated for a specialist engagement.
2. Enterprise security questionnaires from prospects are starting to include AI security questions she can't answer honestly.
3. Everything she reads about LLM security is either too technical (red team tooling) or too vague (vendor whitepapers) — nothing maps cleanly to business risk.

## Behaviors

- Manages security strategy, not day-to-day tooling — she directs her AppSec lead (persona like James Okafor) who implements.
- Evaluates vendors based on compliance certifications (SOC 2, ISO 27001), pricing model, and reference customers in her industry.
- Reads Gartner, Forrester, Dark Reading, and attends RSA and HIMSS.
- Communicates security posture to the board quarterly; needs metrics and trends, not raw vulnerability data.

## Job to Be Done

> "When my board asks me about our AI security posture, I want to be able to show them documented evidence that we've assessed and mitigated LLM-specific risks using a recognized framework, so I can demonstrate due diligence without hiring an AI security team."

## Relationship to Product

Rachel discovers the platform via a Gartner mention, a peer CISO referral, or her AppSec manager's recommendation. She's the economic buyer but not the primary user — she approves the license and sets the requirement; James (or equivalent) implements. She needs the platform to produce compliance-mappable output (NIST AI RMF, OWASP LLM Top 10) and to be procurable through enterprise channels (security review, MSA, invoiced billing). Churn happens if the tool doesn't produce board-presentable outputs or if it creates compliance liability rather than reducing it.

## Scenarios

1. **Board presentation preparation** — Rachel's AppSec lead runs a Defender scan suite against all three AI features, exports a risk summary, and maps findings to NIST AI RMF subcategories. Rachel presents a one-page "AI Security Posture" slide to the board with coverage percentages and remediation status.
2. **Customer security questionnaire response** — A Fortune 500 healthcare prospect sends a security questionnaire with questions about AI adversarial testing. Rachel's team points to the Defender scan results and the Catalog's technique coverage as evidence of systematic LLM security assessment.
