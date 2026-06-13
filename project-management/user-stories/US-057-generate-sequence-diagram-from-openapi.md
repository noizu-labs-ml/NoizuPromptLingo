---
id: US-057
title: "Generate sequence diagram from API spec (OpenAPI)"
slug: "generate-sequence-diagram-from-openapi"
personas: [P-001, P-005]
epic: "Diagram & Rendering Engine"
priority: "should-have"
complexity: "L"
tags: [openapi, sequence-diagram, plantuml, api-spec, architecture]
---

# US-057: Generate Sequence Diagram from API Spec (OpenAPI)

## User Story

**As a** Full-Stack Developer (P-001),
**I want to** pass an OpenAPI spec and receive a sequence diagram showing the request/response flow,
**So that** I can automatically document API interactions without manually authoring PlantUML or Mermaid.

## Acceptance Criteria

- [ ] Given a valid OpenAPI 3.x YAML or JSON spec, when submitted via MCP tool, then a sequence diagram is generated showing actors, endpoints, and response codes
- [ ] Given a spec with multiple tags/groups, when processed, then the user can optionally filter to a specific tag to scope the diagram
- [ ] Given the generated diagram, when returned, then both the rendered image and the raw PlantUML or Mermaid source are included
- [ ] Given an invalid or malformed OpenAPI spec, when submitted, then a validation error is returned specifying the parse failure location

## Notes

Builds on US-052 (PlantUML) and US-053 (Mermaid) rendering infrastructure. The OpenAPI parser runs in the Phoenix backend. Scope filtering is important — real-world specs often have 50+ endpoints.
