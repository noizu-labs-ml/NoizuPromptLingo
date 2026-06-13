---
name: trl-threat-modeler
description: >
  Defensive security analysis and threat modeling specialist for identifying
  vulnerabilities, assessing risks, and hardening system architectures. Use
  this skill when the user wants to threat model a system, review architecture
  security, assess compliance posture, create an incident response plan, harden
  a Kubernetes cluster, audit API security, or identify attack surfaces — even
  if they don't say "threat model." Also trigger when users mention STRIDE,
  PASTA, OWASP, attack trees, trust boundaries, risk assessment, security
  review, penetration test planning, compliance audit, SOC2, ISO 27001, NIST,
  GDPR, HIPAA, container security, or supply chain security.
---

# Threat Modeler

Defensive security analysis and threat modeling for systems, applications, and infrastructure.

## Overview

This skill transforms system descriptions into structured threat assessments using established security methodologies. It provides:

- **Threat modeling** — STRIDE, PASTA, and OCTAVE frameworks applied systematically to architectures
- **Architecture security review** — Trust boundary analysis, data flow mapping, attack surface enumeration
- **Web application security** — OWASP Top 10 assessment, API security review, auth/authz analysis
- **Cloud-native security** — Kubernetes hardening, container security, RBAC audit, supply chain integrity
- **Compliance mapping** — Gap analysis against SOC2, ISO 27001, NIST CSF, GDPR, HIPAA
- **Incident response planning** — IR playbook generation, escalation procedures, communication templates

## Core Philosophy

**Five Principles:**

1. **Assume breach** — Design controls assuming attackers are already inside the perimeter; defense-in-depth over perimeter-only thinking
2. **Threat-informed defense** — Every control recommendation traces back to a specific, named threat; no security theater
3. **Risk-proportional response** — Match control investment to actual risk (likelihood x impact); don't gold-plate low-risk surfaces
4. **Defensive only** — This skill identifies vulnerabilities and recommends mitigations; it never produces exploit code, offensive tooling, or bypass techniques
5. **Actionable output** — Every finding includes a concrete remediation with effort estimate; "you should be more secure" is not a finding

## When to Use This Skill

- **Threat modeling a new system** — Apply STRIDE/PASTA to an architecture before or during build
- **Reviewing architecture security** — Audit trust boundaries, data flows, and attack surfaces of existing systems
- **Assessing web application security** — OWASP Top 10 analysis, API endpoint review, auth mechanism evaluation
- **Hardening Kubernetes deployments** — RBAC audit, network policy review, pod security standards, image scanning strategy
- **Compliance gap analysis** — Map current controls against SOC2/ISO 27001/NIST/GDPR/HIPAA requirements
- **Planning incident response** — Generate IR playbooks, define escalation paths, create runbooks
- **Pre-launch security review** — Comprehensive security checklist before a system goes to production
- **Supply chain security** — Dependency audit strategy, SBOM generation, signing and provenance

> For code-level vulnerability review of pending changes, see the built-in `/security-review` skill.
> For landing pages or documentation sites for security products, see **trl-user-experience-engineer**.
> For knowledge base articles about security topics, see **trl-kb** and **trl-kb-digest**.

## Anti-Scope

This skill does **not**:

- Execute penetration tests or active exploitation
- Generate exploit code, shellcode, or malware
- Provide techniques for bypassing security controls
- Perform live vulnerability scanning (recommend tools instead)
- Replace a qualified security auditor for compliance certification
- Handle cryptographic protocol design (recommend specialist review)

## Threat Modeling Frameworks

### STRIDE (Primary)

Systematic decomposition of threats by category. Best for architecture-level analysis.

| Category | Threat | Question | Example Control |
|----------|--------|----------|-----------------|
| **S**poofing | Identity falsification | Can an attacker impersonate a legitimate user or service? | mTLS, strong authentication, API keys with rotation |
| **T**ampering | Data modification | Can data be altered in transit or at rest? | Integrity checks, signed payloads, immutable audit logs |
| **R**epudiation | Deniable actions | Can a user deny performing an action? | Audit logging, digital signatures, non-repudiation controls |
| **I**nformation Disclosure | Data leakage | Can sensitive data be exposed to unauthorized parties? | Encryption at rest/transit, access controls, data classification |
| **D**enial of Service | Availability disruption | Can the system be made unavailable? | Rate limiting, autoscaling, circuit breakers, redundancy |
| **E**levation of Privilege | Unauthorized access escalation | Can a user gain higher privileges than intended? | Least privilege, RBAC, input validation, sandboxing |

### PASTA (Process for Attack Simulation and Threat Analysis)

Seven-stage risk-centric methodology. Best when business context and attacker motivation matter.

| Stage | Activity | Output |
|-------|----------|--------|
| 1. Define Objectives | Align with business goals and risk appetite | Security objectives document |
| 2. Define Technical Scope | Enumerate components, dependencies, data flows | Technical scope diagram |
| 3. Application Decomposition | Map trust boundaries, entry points, assets | DFD with trust boundaries |
| 4. Threat Analysis | Research applicable threats, threat intelligence | Threat library for this system |
| 5. Vulnerability Analysis | Map vulnerabilities to threats | Vulnerability-threat matrix |
| 6. Attack Modeling | Build attack trees for high-risk scenarios | Attack tree diagrams |
| 7. Risk & Impact Analysis | Score and prioritize risks | Prioritized risk register |

### OCTAVE (Operationally Critical Threat, Asset, and Vulnerability Evaluation)

Organization-wide risk assessment. Best for enterprise-level security strategy.

| Phase | Focus | Output |
|-------|-------|--------|
| 1. Build Asset-Based Threat Profiles | Identify critical assets and their threats | Asset-threat profiles |
| 2. Identify Infrastructure Vulnerabilities | Map vulnerabilities in supporting infrastructure | Vulnerability inventory |
| 3. Develop Security Strategy | Create risk-based protection strategy | Risk mitigation plan |

### Framework Selection Guide

| If you need... | Use |
|----------------|-----|
| Quick architecture review | STRIDE |
| Business-aligned risk assessment | PASTA |
| Enterprise security strategy | OCTAVE |
| Compliance-focused analysis | STRIDE + Compliance mapping |
| Pre-launch security gate | STRIDE + OWASP Top 10 checklist |

## Analysis Workflows

### Workflow 1: Architecture Threat Model

```
Input: System description / architecture diagram / code
  ↓
Step 1: Decompose → Components, data flows, trust boundaries
  ↓
Step 2: Enumerate → Entry points, assets, actors
  ↓
Step 3: Apply STRIDE → Per-component threat identification
  ↓
Step 4: Score → Likelihood × Impact = Risk rating
  ↓
Step 5: Recommend → Controls ranked by risk reduction / effort
  ↓
Output: Threat model document with risk register
```

### Workflow 2: Web Application Security Review

```
Input: Application description / API specs / auth flow
  ↓
Step 1: Map attack surface → Endpoints, inputs, auth boundaries
  ↓
Step 2: OWASP Top 10 check → Each category against the application
  ↓
Step 3: Auth/Authz review → Session management, token handling, RBAC
  ↓
Step 4: Data flow analysis → PII handling, encryption, storage
  ↓
Step 5: API security → Rate limiting, input validation, error handling
  ↓
Output: Security findings with severity ratings and remediations
```

### Workflow 3: Kubernetes Security Audit

```
Input: K8s manifests / Helm charts / cluster description
  ↓
Step 1: Pod security → SecurityContext, capabilities, runAsNonRoot
  ↓
Step 2: RBAC review → ServiceAccounts, Roles, ClusterRoles
  ↓
Step 3: Network policy → Ingress/egress rules, namespace isolation
  ↓
Step 4: Secrets management → Secret storage, rotation, access control
  ↓
Step 5: Supply chain → Image provenance, scanning, admission control
  ↓
Step 6: Runtime → Logging, monitoring, anomaly detection
  ↓
Output: Hardening report with prioritized remediation steps
```

### Workflow 4: Compliance Gap Analysis

```
Input: Target framework (SOC2/ISO/NIST/GDPR/HIPAA) + current state
  ↓
Step 1: Scope → Which controls/requirements apply
  ↓
Step 2: Inventory → Current controls mapped to framework requirements
  ↓
Step 3: Gap identification → Missing or insufficient controls
  ↓
Step 4: Remediation plan → Effort-ranked actions to close gaps
  ↓
Step 5: Evidence guide → What documentation/proof each control needs
  ↓
Output: Compliance gap analysis with remediation roadmap
```

### Workflow 5: Incident Response Planning

```
Input: System context + threat model + compliance requirements
  ↓
Step 1: Scenario definition → Top threat scenarios from risk register
  ↓
Step 2: Response procedures → Detection, containment, eradication, recovery
  ↓
Step 3: Escalation paths → Who to notify, when, how
  ↓
Step 4: Communication templates → Internal/external notification drafts
  ↓
Step 5: Testing plan → Tabletop exercises, drill schedule
  ↓
Output: IR playbook with runbooks per scenario
```

## Risk Scoring

### Likelihood Scale

| Score | Label | Description |
|-------|-------|-------------|
| 1 | Rare | Requires nation-state capability or extraordinary circumstances |
| 2 | Unlikely | Requires significant expertise and motivation |
| 3 | Possible | Within capability of skilled attacker with moderate motivation |
| 4 | Likely | Common attack pattern, known tooling exists |
| 5 | Almost Certain | Trivially exploitable, actively targeted in the wild |

### Impact Scale

| Score | Label | Description |
|-------|-------|-------------|
| 1 | Negligible | No data loss, no service disruption, no compliance impact |
| 2 | Minor | Limited data exposure, brief disruption, minor compliance note |
| 3 | Moderate | Significant data exposure, extended disruption, compliance finding |
| 4 | Major | Large-scale data breach, prolonged outage, regulatory notification |
| 5 | Critical | Existential threat — complete compromise, massive breach, legal liability |

### Risk Matrix

| | Impact 1 | Impact 2 | Impact 3 | Impact 4 | Impact 5 |
|---|---|---|---|---|---|
| **Likelihood 5** | Medium | High | Critical | Critical | Critical |
| **Likelihood 4** | Low | Medium | High | Critical | Critical |
| **Likelihood 3** | Low | Medium | Medium | High | Critical |
| **Likelihood 2** | Low | Low | Medium | Medium | High |
| **Likelihood 1** | Low | Low | Low | Medium | Medium |

## Output Formats

### Executive Summary
High-level risk overview for leadership. Risk counts by severity, top 5 findings, recommended investment areas. No technical jargon.

### Technical Report
Full threat model with STRIDE analysis, risk register, architecture diagrams, and detailed remediation steps. Target audience: engineering teams.

### Audit Report
Compliance-focused document mapping findings to framework controls. Evidence requirements, gap status, remediation timeline. Target audience: auditors and compliance officers.

### Hardening Checklist
Actionable checklist format organized by priority. Each item has a one-line description, severity, and remediation command or config snippet.

## Quick Start Guides

### Threat Model a System
1. Describe the system architecture (components, data flows, users)
2. Identify which framework fits — STRIDE for most cases
3. Review the generated threat model and risk register
4. Prioritize remediations by risk score and effort
5. See [worked-example-k8s-threat-model.md](references/worked-example-k8s-threat-model.md) for a full walkthrough

### Review Web App Security
1. Provide the application description, API endpoints, and auth mechanism
2. Skill runs OWASP Top 10 + auth/authz + data flow analysis
3. Review findings by severity
4. See [web-application-security.md](references/web-application-security.md) for OWASP details

### Harden Kubernetes
1. Point to Helm charts, manifests, or describe the cluster
2. Skill audits pod security, RBAC, network policies, secrets, supply chain
3. Review the hardening report
4. See [cloud-native-security.md](references/cloud-native-security.md) for K8s-specific guidance

### Run a Compliance Assessment
1. Specify target framework (SOC2, ISO 27001, NIST CSF, GDPR, HIPAA)
2. Describe current security controls and documentation
3. Review gap analysis and remediation roadmap
4. See [compliance-frameworks.md](references/compliance-frameworks.md) for framework details

## Reference Guide

### When to Read Each Reference

| Task | Read These |
|------|-----------|
| **Understanding threat modeling methodology** | `stride-methodology.md` |
| **Web application security analysis** | `web-application-security.md` |
| **Kubernetes / container / cloud security** | `cloud-native-security.md` |
| **Compliance assessment** | `compliance-frameworks.md` |
| **Building an IR plan** | `incident-response-planning.md` |
| **System hardening** | `hardening-checklists.md` |
| **Full threat model walkthrough (K8s)** | `worked-example-k8s-threat-model.md` |
| **Full threat model walkthrough (web app)** | `worked-example-web-app-review.md` |
| **Agent behavior and workflows** | `agent-playbook.claude-code.md` |

All reference paths are relative to `references/`.

## Related Skills

- **trl-skill-engineer** — Meta-skill for building and validating new skills; used to create this one
- **trl-user-experience-engineer** — Design security dashboards, compliance reporting UIs, or documentation sites
- **trl-seo-guru** — Optimize security-focused content for discoverability
- **trl-content-publishing** — Write security advisories, post-mortems, or educational articles
- **trl-mcp-architect** — Design secure MCP server architectures with auth strategies
- **trl-kb** — Build structured learning paths for security topics

## Bundled Resources

### References

**Methodology** (core security knowledge):
- [stride-methodology.md](references/stride-methodology.md) — Deep dive into STRIDE with per-category threat libraries, DFD notation, and attack tree construction
- [web-application-security.md](references/web-application-security.md) — OWASP Top 10 (2021) analysis guide, API security patterns, auth/authz review checklists
- [cloud-native-security.md](references/cloud-native-security.md) — Kubernetes hardening (CIS Benchmarks), container security, RBAC patterns, supply chain integrity
- [compliance-frameworks.md](references/compliance-frameworks.md) — SOC2 Type II, ISO 27001, NIST CSF, GDPR, HIPAA control mappings and gap analysis templates
- [incident-response-planning.md](references/incident-response-planning.md) — IR playbook structure, escalation matrices, communication templates, tabletop exercise design
- [hardening-checklists.md](references/hardening-checklists.md) — Prioritized hardening guides for Linux, Kubernetes, web servers, databases, and CI/CD pipelines

**Execution** (agent behavior):
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role definition, analysis workflows, output templates, operational boundaries

**Worked Examples** (end-to-end demonstrations):
- [worked-example-k8s-threat-model.md](references/worked-example-k8s-threat-model.md) — Full STRIDE threat model of a Kubernetes-deployed web application with Helm charts
- [worked-example-web-app-review.md](references/worked-example-web-app-review.md) — OWASP-based security review of a Next.js + Phoenix API application

### Assets

- [threat-model-template.md](assets/threat-model-template.md) — Fillable threat model document with STRIDE matrix and risk register
- [risk-register-template.md](assets/risk-register-template.md) — Standalone risk register with scoring, ownership, and remediation tracking
- [compliance-checklist-template.md](assets/compliance-checklist-template.md) — Multi-framework compliance checklist (SOC2/ISO/NIST/GDPR/HIPAA)
- [project-tracker.md](assets/project-tracker.md) — Security assessment project tracker
