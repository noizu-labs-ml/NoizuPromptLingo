---
name: trl-mcp-architect
description: >
  Checklist-driven specification and design for MCP servers. Use this skill when
  the user wants to plan an MCP server, design a tool surface, review security
  posture, choose a transport layer, create a tool manifest, write architecture
  decision records, or audit an existing MCP server design -- even if they don't
  say "architect." Also trigger when users mention MCP specification, MCP
  planning, tool schema design, MCP auth strategy, or MCP hosting decisions.
---

# MCP Architect

Checklist-driven specification and design for Model Context Protocol servers.

## Overview

MCP Architect is the **specification phase** of MCP server development. Before a single line of server code is written, every consequential design decision should be made, documented, and reviewed. This skill provides the structured process to make that happen.

**Outputs:**
- Specification document (all 8 checklist sections resolved)
- Tool manifest (JSON Schema definitions for every tool)
- Architecture Decision Records (one per major design choice)
- Security threat model worksheet

**Position in the pipeline:**
1. **trl-mcp-builder** (parent) -- ecosystem context, SDK reference, protocol facts
2. **trl-mcp-architect** (this skill) -- specification, design, security review
3. **trl-mcp-forge** -- implementation scaffolds, testing, deployment

## Core Philosophy

1. **Ask the right questions first.** A bad specification produces a bad server. The checklist forces you to confront every decision before code exists to bias you.

2. **Checklists prevent disasters.** Aviation safety, surgical safety, and now MCP server design. The specification checklist is a forcing function against the "I'll figure it out later" instinct.

3. **Security is architecture.** Security bolted on after implementation is security theater. Auth patterns, input validation strategy, and threat models are architectural decisions that belong in the spec.

4. **Transport constrains everything.** The choice between stdio and Streamable HTTP cascades into auth, hosting, scaling, discovery, and cost. Make it first.

5. **The tool manifest is the contract.** Tool names, descriptions, and schemas are the API surface that LLMs consume. Designing them well is the difference between a tool that gets used and one that gets ignored.

## When to Use This Skill

- **Designing a new MCP server** -- walk the full specification checklist
- **Auditing an existing design** -- compare against checklist, find gaps
- **Choosing a transport layer** -- focused transport decision workflow
- **Planning authentication and security** -- auth pattern selection, threat modeling
- **Creating tool manifests** -- schema design, naming, annotations
- **Writing ADRs** -- documenting decisions for future maintainers

## The Specification Checklist

The checklist has **8 mandatory sections**. Each section must reach "Done" criteria before the spec is considered complete. Below is the condensed overview; the full checklist with all questions, decision matrices, red flags, and examples lives in `references/specification-checklist.md`.

| # | Section | Key Questions | Done When |
|---|---------|---------------|-----------|
| 1 | Purpose & Scope | What problem? Who consumes it? What's out of scope? | Problem statement, consumer list, tool inventory, and exclusions documented |
| 2 | Transport | stdio or Streamable HTTP? Why? | Transport selected with rationale and migration path noted |
| 3 | Auth & Authz | Who authenticates? How? Per-tool permissions? | Auth pattern selected, token lifecycle defined, permission matrix drafted |
| 4 | Data Stores | What data does the server touch? Who owns it? | Every data source listed with access pattern and ownership |
| 5 | Security | Input validation? Rate limiting? Threat model? | Threat model worksheet completed, validation strategy defined |
| 6 | Hosting & Deployment | Where does it run? What does it cost? | Hosting option selected with cost estimate and scaling plan |
| 7 | Discovery & Registration | How do clients find this server? | Discovery mechanism documented |
| 8 | Versioning & Lifecycle | How do tools evolve? Breaking change policy? | Versioning scheme and deprecation policy defined |

> Full checklist: `references/specification-checklist.md`

## Tool Manifest Design

The tool manifest defines every tool the server exposes. Each tool needs:
- A **verb_noun name** (e.g., `get_user`, `search_documents`)
- A **description** that tells the LLM when and why to use it
- An **inputSchema** using JSON Schema with descriptions on every property
- **Annotations** signaling behavior (read-only, destructive, idempotent)

Key principles:
- Descriptions are for LLMs, not humans. Be explicit about what the tool does, what it returns, and when to prefer it over alternatives.
- Use `required` fields aggressively. Optional fields without defaults confuse models.
- Constrain with enums where possible. `"status": {"enum": ["open","closed"]}` beats `"status": {"type": "string"}`.

> Full guide: `references/tool-manifest-guide.md`

## Quick Start Guides

### Path 1: Spec from Scratch

You have an idea for an MCP server. Walk the full checklist.

1. State the problem the server solves in one sentence
2. Open `references/specification-checklist.md` and work through all 8 sections sequentially
3. For each section, answer every mandatory question
4. Record decisions in `assets/spec-document-template.md`
5. Write ADRs for transport, auth, and hosting decisions using `assets/adr-template.md`
6. Design the tool manifest using `references/tool-manifest-guide.md`
7. Complete the security threat model using `assets/security-threat-model-worksheet.md`
8. Review the completed spec against the checklist "Done" criteria

### Path 2: Audit an Existing Design

You have an MCP server (or a design doc) and want to check for gaps.

1. Load the existing design alongside `references/specification-checklist.md`
2. For each of the 8 sections, check whether the mandatory questions have been answered
3. Flag unanswered questions and missing decisions
4. Pay special attention to Section 5 (Security) -- most audits find gaps here
5. Generate a gap report with recommended actions

### Path 3: Transport Decision Only

You need to decide between stdio and Streamable HTTP.

1. Open `references/specification-checklist.md`, Section 2
2. Answer the 6 transport questions
3. Cross-reference with `references/hosting-decision-matrix.md`
4. Write an ADR documenting the decision using `assets/adr-template.md`

## Reference Guide

| Task | Primary File | Supporting Files |
|------|-------------|-----------------|
| Full specification | `references/specification-checklist.md` | `assets/spec-document-template.md` |
| Tool manifest design | `references/tool-manifest-guide.md` | `assets/tool-manifest-template.md` |
| Transport selection | `references/specification-checklist.md` (Section 2) | `references/hosting-decision-matrix.md` |
| Auth pattern selection | `references/auth-patterns.md` | `references/specification-checklist.md` (Section 3) |
| Security review | `references/specification-checklist.md` (Section 5) | `assets/security-threat-model-worksheet.md` |
| Data store planning | `references/data-store-patterns.md` | `references/specification-checklist.md` (Section 4) |
| Rate limiting design | `references/rate-limiting-patterns.md` | -- |
| Hosting selection | `references/hosting-decision-matrix.md` | `references/specification-checklist.md` (Section 6) |
| Compliance review | `references/compliance-and-licensing.md` | -- |
| Decision documentation | `references/adr-template-guide.md` | `assets/adr-template.md` |
| Worked examples | `references/worked-example-weather-api.md` | `references/worked-example-database-bridge.md` |

## Related Skills

- **trl-mcp-builder** -- Parent skill. Ecosystem overview, SDK reference, protocol facts. Start here if you need orientation on MCP itself.
- **trl-mcp-forge** -- Takes a completed spec and produces implementation scaffolds, tests, and deployment configs.
- **trl-ai-templates** -- If the MCP server is a commercial product, use trl-ai-templates for packaging, pricing, and launch strategy.
- **trl-skill-engineer** -- If the MCP server will be wrapped as a Claude Code skill, use trl-skill-engineer for the skill scaffold.

## Bundled Resources

### References (Guides and Patterns)
- `references/agent-playbook.claude-code.md` -- Agent role definition and workflows
- `references/specification-checklist.md` -- The 8-section specification checklist (core artifact)
- `references/tool-manifest-guide.md` -- Tool manifest design guide
- `references/adr-template-guide.md` -- Architecture Decision Record guide
- `references/auth-patterns.md` -- Authentication and authorization patterns
- `references/data-store-patterns.md` -- Data integration patterns
- `references/rate-limiting-patterns.md` -- Rate limiting strategies
- `references/hosting-decision-matrix.md` -- Hosting options comparison
- `references/compliance-and-licensing.md` -- Legal and compliance considerations
- `references/worked-example-weather-api.md` -- Full spec walkthrough: Weather API
- `references/worked-example-database-bridge.md` -- Full spec walkthrough: PostgreSQL Bridge

### Assets (Templates and Trackers)
- `assets/project-tracker.md` -- Spec tracking template
- `assets/spec-document-template.md` -- Fillable specification document
- `assets/tool-manifest-template.md` -- Fillable tool manifest template
- `assets/adr-template.md` -- Fillable ADR template
- `assets/security-threat-model-worksheet.md` -- Fillable threat model worksheet
