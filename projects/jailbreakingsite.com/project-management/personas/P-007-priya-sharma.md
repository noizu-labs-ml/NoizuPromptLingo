---
id: P-007
name: "Priya Sharma"
slug: "priya-sharma"
archetype: "DevSecOps Engineer in Regulated Industry"
segment: "tertiary"
tags: [devsecops, ci-cd, regulated-industry, api, defender, compliance, automation, pipeline]
---

# Priya Sharma — DevSecOps Engineer in Regulated Industry

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 29–38 |
| **Role** | Senior DevSecOps Engineer |
| **Technical Level** | Advanced |
| **Industry** | Pharmaceuticals / Life Sciences |
| **Location** | Boston, MA or New Jersey |

## Bio

Priya works in the DevSecOps team at a mid-sized pharmaceutical company that is integrating LLMs into drug discovery workflows, regulatory document summarization, and internal clinical trial management tools. She's responsible for the security of the software delivery pipeline — SAST, DAST, SCA, secrets scanning — and has been tasked with extending that coverage to the three new AI-powered services her company is shipping. She's deeply familiar with regulated industry requirements (21 CFR Part 11, GxP validation, SOC 2) and she knows that AI failures in her industry aren't just PR problems; they're regulatory events.

## Goals

1. Integrate LLM security scanning into the CI/CD pipeline with the same rigor as existing SAST/DAST gates, producing auditable evidence of security testing for regulatory submissions.
2. Automate detection of prompt injection vulnerabilities in AI-powered features before they reach staging, without requiring manual security review of every pull request.
3. Produce scan results in formats compatible with her company's existing GRC tooling (ServiceNow, Archer) and regulatory documentation requirements.

## Frustrations

1. Every CI/CD security tool she evaluates is designed for web app or container security — none have LLM-specific scan capabilities that fit natively into a GitHub Actions / GitLab CI pipeline.
2. Regulated industries require documented evidence of security testing with traceability to requirements; most LLM security tools produce informal output, not audit-ready reports.
3. Her security team doesn't have LLM expertise and she doesn't have budget for external consultants on every release — she needs automation that encodes expert knowledge.

## Behaviors

- Writes YAML pipeline configs in her sleep; evaluates tools primarily by API quality, GitHub Actions integration, and output format compatibility.
- Attends DevSecCon and All Day DevOps; follows the OWASP CI/CD Security Top 10 and NIST SSDF.
- Runs security gates as non-blocking initially, then tightens to blocking after baseline establishment — pragmatic risk management in a high-velocity environment.
- Works closely with her company's validation team (computer system validation for GxP) and needs security artifacts that survive audit scrutiny.

## Job to Be Done

> "When a developer opens a pull request touching an LLM-integrated service, I want automated LLM security scanning to run and produce a structured, traceable report, so I can enforce a security gate without blocking velocity or requiring manual expert review of every change."

## Relationship to Product

Priya discovers the platform via a DevSecCon talk, a GitHub Actions Marketplace listing, or an OWASP community post. She evaluates Defender primarily through the API and CI/CD integration docs. If the Defender API produces structured, machine-readable output with technique IDs she can trace to the Catalog, she'll integrate it into her pipeline within a week and become a quiet, sticky customer. Churn happens if the API is unreliable, output format changes without notice, or the scan results can't be mapped to standard compliance frameworks.

## Scenarios

1. **Pipeline gate implementation** — Priya writes a GitHub Actions step that calls the Defender API on every PR touching the `ai-services/` directory, parses the JSON output for HIGH/CRITICAL findings, and fails the PR with a link to the specific Catalog technique entries. She configures the job to publish scan artifacts to S3 for audit traceability.
2. **Regulatory audit support** — During a 21 CFR Part 11 audit, the auditor asks for evidence that the AI-powered regulatory document summarizer has been tested for adversarial inputs. Priya presents six months of Defender scan results with technique coverage percentages, traceability to the Catalog's versioned technique IDs, and remediation records tied to JIRA tickets.
