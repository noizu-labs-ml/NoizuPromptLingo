---
id: P-005
name: "Priya Nair"
slug: "priya-architect"
archetype: "Enterprise Architect"
segment: "secondary"
tags: [architect, c4-model, sequence-diagrams, plantuml, mermaid, documentation, enterprise]
---

# Priya Nair — Enterprise Architect

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 38–52 |
| **Role** | Principal / Enterprise Architect |
| **Technical Level** | Expert |
| **Industry** | Financial Services / Enterprise Software |
| **Location** | UK / EU / US Financial Centers |

## Bio
Priya leads architecture governance for a 2,000-person financial services firm. She owns the architecture decision record (ADR) process, reviews system designs from 12 engineering teams, and is responsible for keeping architectural diagrams synchronized with what's actually deployed. The diagrams are always six months out of date — she knows this and hates it. She has been pushing for "diagrams as code" for two years and recently got budget to evaluate tooling that integrates with the firm's existing AI assistant deployments.

## Goals
1. Generate C4 model diagrams (context, container, component, code), sequence diagrams, and deployment diagrams directly from structured specifications or code analysis via MCP
2. Keep architectural documentation synchronized with code changes by integrating diagram generation into the development workflow
3. Produce consistent, organization-standard diagrams without each team using a different tool and visual language

## Frustrations
1. Manual diagram maintenance is unsustainable — engineers update code but not Confluence, diagrams drift from reality within weeks of a release
2. Existing tools (draw.io, Structurizr, ArchiMate) have steep learning curves; only architects use them, creating bottlenecks
3. PlantUML and Mermaid are powerful but adoption is low because engineers don't know the syntax and there's no AI-assisted authoring layer

## Behaviors
- Writes PlantUML and C4-PlantUML fluently; evaluates tools by their DSL output quality first, visual output second
- Integrates architectural tooling through the firm's approved AI assistant (enterprise Claude deployment)
- Exports diagrams as SVG for Confluence embedding; requires SVG not PNG for accessibility compliance
- Reviews generated diagrams critically — will edit DSL source directly if needed before accepting output

## Job to Be Done
> "When an engineering team ships a new service or integration, I want to generate an up-to-date C4 component diagram from their spec or ADR, so I can maintain accurate architecture documentation without manual rework after every sprint."

## Relationship to Product
Priya evaluates Mockup MCP as an enterprise tool, likely through an internal champion (a developer who already uses it) or through an architecture community (InfoQ, ThoughtWorks radar, IASA). Adoption requires the MCP server to be deployable on-premises or in a private cloud — she cannot send proprietary system specs to an external SaaS. Key features: PlantUML and Mermaid output (not just image output), C4 model awareness, SVG export, and the ability to define reusable diagram templates for organizational standards. Churn happens if the output DSL requires heavy manual correction or if there's no on-premises deployment path.

## Scenarios
1. **ADR-driven diagram generation** — A team submits an ADR for a new event-streaming integration. Priya prompts Mockup MCP with the ADR text and receives a C4 container diagram and a sequence diagram. She reviews the PlantUML source, makes two edits, and embeds the SVG in Confluence — total time: 12 minutes versus 2 hours previously.
2. **Quarterly diagram audit** — Priya runs Mockup MCP against 8 updated service specs from the quarter's releases, generates a delta of changed component diagrams, and presents the architecture evolution at the quarterly governance review. The first time the diagrams are actually current at the review in three years.
