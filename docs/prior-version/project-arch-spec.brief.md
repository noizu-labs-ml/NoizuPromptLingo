# PROJECT-ARCH Specification Brief

**Location**: `worktrees/main/core/specifications/project-arch-spec.md`

## Overview
Convention specification for structuring architecture documentation with consistent formatting, modular organization, and NPL syntax integration. Enables agents like `gopher-scout` and `project-coordinator` to generate consistent, maintainable architecture docs.

## Design Principles
- **Modularity**: Main file stays 200-400 lines; sections exceeding 50-100 lines split to sub-files
- **Discoverability**: Quick reference sections enable rapid navigation; detailed content lives in dedicated files
- **Consistency**: Standardized directives and section structure across all projects
- **Progressive Detail**: Overview first, drill-down available via sub-file references

## Core Directives
- `⟪📐 arch-overview: style | key-characteristics⟫` - Declares architectural style and characteristics
- `⟪🗺️ layers: layer-1 → layer-2 → [...] → layer-n⟫` - Quick mapping of architectural layers
- `⟪🔧 services: service-list | deployment-context⟫` - Infrastructure services with deployment notes
- `⟪📊 data-flow: source → transforms → sink⟫` - Data movement patterns through system
- `⟪🔒 security-boundary: boundary-name | controls⟫` - Security perimeter with applied controls

## Main File Template Structure (200-400 lines max)
1. Quick Reference (layers, services overview)
2. Architectural Layers (responsibility, key components, dependencies)
3. Domain Model (bounded contexts if DDD)
4. Key Patterns (rationale, implementation, locations)
5. Infrastructure (services, deployment topology)
6. Critical Issues (architecture concerns and mitigations)
7. Summary (strengths, tradeoffs, evolution path)

## Sub-File Specifications (docs/PROJECT-ARCH/)
- `layers.md` - Detailed layer breakdown with component placement and contracts
- `domain.md` - Entity definitions, bounded contexts, aggregates, domain events
- `patterns.md` - Named patterns with rationale, implementation, usage examples, variations
- `infrastructure.md` - Service configuration, deployment, monitoring, scaling
- `authentication.md` - Auth flow, authorization model, token management, security
- `database.md` - Schema overview, tables/collections, indexes, migration strategy
- `api.md` - API structure, endpoints/operations, error handling, rate limiting, versioning

## Example Directives
```
⟪📐 arch-overview: layered-monolith | 3-tier, domain-driven, CQRS read-models⟫
⟪🗺️ layers: web → application → domain → infrastructure⟫
⟪🔧 services: postgres-14, redis-7, elasticsearch-8 | docker-compose local, EKS prod⟫
⟪📊 data-flow: API → validation → domain-events → projections → read-models⟫
⟪🔒 security-boundary: api-gateway | jwt-validation, rate-limiting, cors⟫
```

## Agent Integration
- **gopher-scout**: Identifies architectural style, maps layers, extracts patterns, flags issues
- **project-coordinator**: Generates PROJECT-ARCH.md, monitors section lengths, maintains cross-references

## Key Insight
Architecture documentation serves as the definitive guide to system structure and patterns. By separating overview from details, the main file remains scannable while sub-files support deep dives without overwhelming readers.

## Dependencies
- Requires NPL syntax: `syntax,agent,fences,directive,pumps.intent,pumps.cot,instructing.alg,formatting.template`
