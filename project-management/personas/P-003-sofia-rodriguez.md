---
id: P-003
name: "Sofia Rodriguez"
slug: "sofia-rodriguez"
archetype: "ML Engineer Building Agents"
segment: "tertiary"
tags: [ml-engineering, llm-agents, developer, api, catalog, defense-in-depth, prompt-engineering]
---

# Sofia Rodriguez — ML Engineer Building Agents

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 26–33 |
| **Role** | Senior ML Engineer / LLM Platform Engineer |
| **Technical Level** | Advanced |
| **Industry** | SaaS / AI-native startup |
| **Location** | Austin, TX or remote (US) |

## Bio

Sofia is two years into building LLM-powered product features at a Series B SaaS company — first a document Q&A system, now a multi-step agent that reads, writes, and executes code on behalf of customers. She thinks about adversarial inputs the way she thinks about SQL injection: a real threat she needs to engineer around, not a theoretical concern. She doesn't have a security background but she's technically rigorous, and she's been burned once by a customer jailbreaking the company's system prompt out of a customer-facing chatbot, which made it onto Twitter.

## Goals

1. Understand the current landscape of prompt injection and jailbreak techniques that could be weaponized against her agent in production.
2. Harden system prompts and tool-call logic against the most common attack patterns before the next product launch.
3. Integrate some form of LLM security testing into her CI/CD pipeline without adding significant latency or complexity.

## Behaviors

- Writes Python, reaches for LangChain and LlamaIndex, tests with pytest; her mental model of security is threat modeling from an engineering perspective.
- Actively follows the LLM security community on Twitter/X, reads Simon Willison's blog and the OWASP LLM project.
- Iterates on system prompts using a prompt eval framework she built internally; she'd integrate external test cases if they were structured and machine-readable.
- Participates in internal threat modeling sessions but isn't the security owner — she's the implementor.

## Frustrations

1. She can't find a comprehensive, current list of prompt injection and jailbreak patterns to test against — resources are scattered across papers, blog posts, and CTF write-ups with no unified structure.
2. Security scanning tools feel like they're built for traditional AppSec engineers, not ML engineers — the abstractions don't match her mental model.
3. She has to choose between security and velocity; there's no lightweight way to run continuous LLM security checks in a CI/CD pipeline without a major integration lift.

## Job to Be Done

> "When I'm shipping a new agent capability to production, I want to run a quick scan against known jailbreak patterns relevant to my agent's tool access, so I can ship with confidence that I haven't left obvious attack vectors open."

## Relationship to Product

Sofia discovers the platform via a Hacker News post, Simon Willison's blog, or a peer referral at a LangChain/LlamaIndex community event. She adopts the Catalog as a reference when threat modeling and uses the API to pull structured technique data into her prompt eval pipeline. She may or may not engage with Academy unless she's trying to level up her security knowledge. Churn risk is medium — she'll stay if the API stays reliable and the Catalog stays current, but will deprioritize if she gets absorbed in product work.

## Scenarios

1. **Pre-launch hardening** — Before shipping an agent with file system access, Sofia queries the Catalog API for techniques tagged `target-capability: tool-use` and `target-capability: code-execution`, reviews the top 10 highest-severity items, and writes defensive assertions into her system prompt and tool-call validation layer.
2. **Incident retrospective** — After a red teamer finds a jailbreak on the company's chatbot, Sofia cross-references the technique against the Catalog, finds it's a known variant of a multi-turn context manipulation attack, and implements the documented mitigation pattern within the day.
