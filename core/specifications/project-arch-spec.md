# PROJECT-ARCH Specification
Convention for structuring architecture documentation with consistent formatting, modular organization, and NPL syntax integration.

## NPL Dependencies

You must run the following command to proceed:

```bash
npl-load c "syntax,agent,fences,directive,pumps.intent,pumps.cot,instructing.alg,formatting.template" --skip {@npl.def.loaded}
```

### See Also
- `npl-load c "fences"` - Fence type reference
- `npl-load c "directive"` - Directive patterns
- `npl-load c "pumps"` - Reasoning pump documentation

---

## Purpose
This specification defines the standard structure for `PROJECT-ARCH.md` files, enabling agents (gopher-scout, project-coordinator) to generate consistent, maintainable architecture documentation across projects.

## Design Principles

**modularity**
: Main file stays concise (200-400 lines); sections exceeding 50-100 lines split to sub-files

**discoverability**
: Quick reference sections enable rapid navigation; detailed content lives in dedicated files

**consistency**
: Standardized directives and section structure across all projects

**progressive-detail**
: Overview first, drill-down available via sub-file references

---

## Directive Reference

### Architecture Directives

**arch-overview**
: `⟪📐 arch-overview: style | key-characteristics⟫`
: Declares architectural style and primary characteristics

```example
⟪📐 arch-overview: layered-monolith | 3-tier, domain-driven, event-sourced⟫
```

**layers**
: `⟪🗺️ layers: layer-list⟫`
: Quick reference mapping of architectural layers

```example
⟪🗺️ layers: presentation → application → domain → infrastructure⟫
```

**services**
: `⟪🔧 services: service-list | deployment-context⟫`
: Infrastructure services with deployment notes

```example
⟪🔧 services: postgres, redis, elasticsearch | docker-compose local, k8s prod⟫
```

**data-flow**
: `⟪📊 data-flow: source → transforms → sink⟫`
: Data movement patterns through system

```example
⟪📊 data-flow: API → validation → domain-events → projections → read-models⟫
```

**security-boundary**
: `⟪🔒 security-boundary: boundary-name | controls⟫`
: Security perimeter with applied controls

```example
⟪🔒 security-boundary: api-gateway | jwt-validation, rate-limiting, cors⟫
```

### Cross-Reference Syntax

**sub-file-reference**
: `→ See: relative/path/to/file.md`
: Links to detailed sub-file documentation

```example
→ See: docs/PROJECT-ARCH/layers.md
```

**section-anchor**
: `⟪📂: {section-id}⟫`
: Marks section for cross-referencing

```example
⟪📂: {auth-flow}⟫
## Authentication Flow
[...]
```

---

## Main File Template

```format
# PROJECT-ARCH: <project-name>
Architecture documentation for <project-name|brief description>.

⟪📐 arch-overview: <style> | <key-characteristics>⟫

## Quick Reference

⟪🗺️ layers: <layer-1> → <layer-2> → [...] → <layer-n>⟫

| Layer | Purpose | Key Components |
|:------|:--------|:---------------|
| <layer-name> | [...1s|purpose] | `<component>`, `<component>` |
| [...|additional layers] |||

⟪🔧 services: <service-list> | <deployment-notes>⟫

---

## Architectural Layers

```diagram
┌─────────────────────────────────────────────────┐
│                  <top-layer>                    │
├─────────────────────────────────────────────────┤
│                 <middle-layer>                  │
├─────────────────────────────────────────────────┤
│                 <bottom-layer>                  │
└─────────────────────────────────────────────────┘
```

### <Layer-Name>
**responsibility**
: [...1-2s|layer purpose]

**key-components**
: `<component-1>`, `<component-2>`, ...

**dependencies**
: <downstream-layer>, <external-service>

[...repeat for each layer, or:]
→ See: docs/PROJECT-ARCH/layers.md

---

## Domain Model

{{if has_domain_model}}
⟪📂: {domain-model}⟫

### Bounded Contexts

**<context-name>**
: [...1-2s|context responsibility]
: Entities: `<Entity1>`, `<Entity2>`, ...
: Events: `<Event1>`, `<Event2>`, ...

[...additional contexts, or:]
→ See: docs/PROJECT-ARCH/domain.md
{{else}}
(note: [Domain model section omitted for non-DDD architectures])
{{/if}}

---

## Key Patterns

### <Pattern-Name>
**rationale**
: [...1-2s|why this pattern]

**implementation**
: [...1-2s|how applied]

**locations**
: `path/to/usage`, `another/path`

[...additional patterns, or:]
→ See: docs/PROJECT-ARCH/patterns.md

---

## Infrastructure

⟪🔧 services: <complete-service-list>⟫

| Service | Purpose | Config Location |
|:--------|:--------|:----------------|
| <service> | [...1s|purpose] | `<config-path>` |
| [...] |||

### Deployment Topology
```diagram
[...ASCII or mermaid diagram showing deployment]
```

→ See: docs/PROJECT-ARCH/infrastructure.md

---

## Critical Issues

🎯 **<Issue-Category>**: [...2-3s|issue description and impact]
- Affected: `<component>`, `<component>`
- Mitigation: [...1s|current approach]

[...additional critical issues]

---

## Summary

**architecture-strengths**
: [...2-3s|key architectural advantages]

**known-tradeoffs**
: [...1-2s|intentional compromises]

**evolution-path**
: [...1-2s|planned architectural changes]
```

---

## Sub-File Specifications

Sub-files are created in `docs/PROJECT-ARCH/` when main file sections exceed 50-100 lines.

### layers.md

```format
# Architectural Layers
Detailed breakdown of system layers for <project-name>.

## Layer Overview

```diagram
[...detailed ASCII diagram with component placement]
```

---

## <Layer-Name>

⟪📂: {layer-<name>}⟫

**responsibility**
: [...2-3s|complete layer purpose]

**boundaries**
: [...1-2s|what belongs/doesn't belong in this layer]

### Components

**<Component-Name>**
: [...1-2s|component purpose]
: Location: `path/to/component`
: Dependencies: `<dep1>`, `<dep2>`

```example
[...code snippet showing component usage pattern]
```

[...additional components]

### Layer Contracts

**inbound**
: [...interfaces this layer exposes]

**outbound**
: [...interfaces this layer consumes]

---

[...repeat for each layer]
```

### domain.md

```format
# Domain Model
Entity and bounded context documentation for <project-name>.

## Context Map

```diagram
┌─────────────────┐      ┌─────────────────┐
│   <Context-A>   │──────│   <Context-B>   │
│                 │      │                 │
│  <entities>     │      │  <entities>     │
└─────────────────┘      └─────────────────┘
         │
         ▼
┌─────────────────┐
│   <Context-C>   │
└─────────────────┘
```

---

## <Bounded-Context-Name>

⟪📂: {context-<name>}⟫

**purpose**
: [...2-3s|context responsibility and boundaries]

**ubiquitous-language**
: Key terms specific to this context

### Entities

**<Entity-Name>**
: [...1-2s|entity purpose]

| Attribute | Type | Description |
|:----------|:-----|:------------|
| `<attr>` | `<type>` | [...1s|purpose] |
| [...] |||

**invariants**
: [...business rules this entity enforces]

**lifecycle**
: [...state transitions if applicable]

### Value Objects

**<ValueObject-Name>**
: [...1s|purpose and immutability rationale]

### Domain Events

**<EventName>**
: Trigger: [...when this event occurs]
: Payload: `<field1>`, `<field2>`, ...
: Consumers: `<Consumer1>`, `<Consumer2>`

### Aggregates

**<AggregateName>**
: Root: `<RootEntity>`
: Members: `<Entity1>`, `<ValueObject1>`, ...
: Consistency boundary: [...what this aggregate protects]

---

[...repeat for each bounded context]
```

### patterns.md

```format
# Code Patterns
Named patterns and conventions used in <project-name>.

## Pattern Catalog

| Pattern | Category | Usage Locations |
|:--------|:---------|:----------------|
| <Pattern> | <category> | `<path>`, `<path>` |
| [...] |||

---

## <Pattern-Name>

⟪📂: {pattern-<name>}⟫

**category**
: <structural|behavioral|creational|architectural>

**rationale**
: [...2-3s|why this pattern was chosen]

**when-to-use**
: [...conditions that warrant this pattern]

**when-not-to-use**
: [...antipatterns or inappropriate contexts]

### Implementation

```<language>
[...canonical code example]
```

### Usage Examples

**<use-case-1>**
: Location: `path/to/example`

```<language>
[...actual usage from codebase]
```

### Variations

**<variation-name>**
: [...how pattern is adapted for specific contexts]

---

[...repeat for each pattern]
```

### infrastructure.md

```format
# Infrastructure
Service configuration and deployment documentation for <project-name>.

## Service Inventory

⟪🔧 services: <complete-list>⟫

| Service | Version | Port | Health Check |
|:--------|:--------|:-----|:-------------|
| <service> | <ver> | <port> | `<endpoint>` |
| [...] ||||

---

## <Service-Name>

⟪📂: {service-<name>}⟫

**purpose**
: [...1-2s|why this service is used]

**configuration**
: Primary: `<config-file-path>`
: Secrets: `<secrets-location>`

### Connection Details

| Environment | Host | Port | Notes |
|:------------|:-----|:-----|:------|
| local | `<host>` | `<port>` | [...] |
| staging | `<host>` | `<port>` | [...] |
| production | `<host>` | `<port>` | [...] |

### Key Configuration

```<format>
[...relevant config snippet]
```

### Monitoring

**metrics**
: [...key metrics to watch]

**alerts**
: [...alert conditions]

---

## Deployment

### Local Development

```bash
[...commands to start local environment]
```

### Staging/Production

```diagram
[...deployment topology diagram]
```

**deployment-method**
: [...CI/CD pipeline, manual, etc.]

**scaling-policy**
: [...horizontal/vertical scaling rules]
```

### authentication.md

```format
# Authentication & Authorization
Security model documentation for <project-name>.

⟪🔒 security-boundary: <primary-boundary> | <controls>⟫

## Authentication Flow

```diagram
┌──────┐    ┌─────────┐    ┌──────────┐    ┌─────────┐
│Client│───▶│  Auth   │───▶│  Token   │───▶│Protected│
│      │◀───│ Service │◀───│Validation│◀───│Resource │
└──────┘    └─────────┘    └──────────┘    └─────────┘
```

### Auth Methods

**<method-name>**
: [...1-2s|when and how used]
: Implementation: `<path-to-code>`

---

## Authorization Model

**model-type**
: <RBAC|ABAC|ACL|custom>

### Roles

| Role | Permissions | Assignment |
|:-----|:------------|:-----------|
| <role> | [...] | [...] |

### Permission Checks

**location**
: [...where authorization is enforced]

```<language>
[...code example of permission check]
```

---

## Token Management

**token-type**
: <JWT|opaque|session>

**lifetime**
: Access: <duration>
: Refresh: <duration>

**storage**
: Client: <storage-location>
: Server: <storage-location>

### Token Structure

```json
{
  [...token payload structure]
}
```

---

## Security Considerations

🎯 **<Security-Concern>**: [...description and mitigation]

[...additional security notes]
```

### database.md

```format
# Database Architecture
Schema and data layer documentation for <project-name>.

## Database Overview

| Database | Type | Purpose |
|:---------|:-----|:--------|
| <db-name> | <type> | [...1s|purpose] |
| [...] |||

---

## <Database-Name>

⟪📂: {db-<name>}⟫

**type**
: <PostgreSQL|MySQL|MongoDB|Redis|...>

**version**
: <version>

**connection**
: Location: `<connection-string-config>`

### Schema Overview

```diagram
[...ER diagram or schema visualization]
```

### Tables/Collections

**<table-name>**
: Purpose: [...1s|what this table stores]

| Column | Type | Constraints | Description |
|:-------|:-----|:------------|:------------|
| `<col>` | `<type>` | `<constraints>` | [...] |
| [...] ||||

**indexes**
: [...index definitions and rationale]

**relationships**
: [...foreign keys and references]

---

## Extensions/Plugins

{{if has_extensions}}
| Extension | Purpose | Configuration |
|:----------|:--------|:--------------|
| <ext> | [...] | `<config>` |
{{/if}}

---

## Migration Strategy

**tool**
: <migration-tool>

**location**
: `<migrations-path>`

**naming-convention**
: [...migration file naming pattern]

---

## Performance Considerations

**indexing-strategy**
: [...approach to index creation]

**query-patterns**
: [...common query patterns and optimizations]

**connection-pooling**
: [...pool configuration]
```

### api.md

```format
# API Architecture
API structure and contract documentation for <project-name>.

## API Overview

| API | Type | Base Path | Auth |
|:----|:-----|:----------|:-----|
| <api-name> | <REST|GraphQL|gRPC> | `<path>` | <auth-method> |
| [...] ||||

---

## <API-Name>

⟪📂: {api-<name>}⟫

**type**
: <REST|GraphQL|gRPC|WebSocket>

**version**
: <current-version>

**base-url**
: `<base-url-pattern>`

### Endpoints/Operations

{{if REST}}
| Method | Path | Purpose | Auth |
|:-------|:-----|:--------|:-----|
| `GET` | `<path>` | [...] | <required|optional|none> |
| [...] ||||
{{/if}}

{{if GraphQL}}
**queries**
: `<query1>`, `<query2>`, ...

**mutations**
: `<mutation1>`, `<mutation2>`, ...

**subscriptions**
: `<subscription1>`, ...
{{/if}}

### Request/Response Patterns

**<operation-name>**

```<format>
[...request example]
```

```<format>
[...response example]
```

---

## Error Handling

**error-format**
: [...standard error response structure]

```json
{
  "error": {
    "code": "<error-code>",
    "message": "<human-readable>",
    "details": [...]
  }
}
```

**common-errors**
: [...list of standard error codes and meanings]

---

## Rate Limiting

**strategy**
: [...rate limiting approach]

**limits**
: [...specific limits by endpoint or tier]

---

## Versioning

**strategy**
: <URL|header|query-param>

**deprecation-policy**
: [...how deprecated endpoints are handled]
```

---

## Sub-File Creation Guidelines

### When to Create Sub-Files

**threshold**
: Create sub-file when main file section exceeds 50-100 lines

**indicators**
: - Multiple detailed subsections needed
: - Code examples exceed 20 lines
: - Tables have more than 10 rows
: - Diagrams require extensive explanation

### Directory Structure

```diagram
project-root/
├── PROJECT-ARCH.md              # Main file (200-400 lines max)
└── docs/
    └── PROJECT-ARCH/
        ├── layers.md            # Detailed layer breakdown
        ├── domain.md            # Entity details, contexts
        ├── patterns.md          # Code patterns with examples
        ├── infrastructure.md    # Service configs, deployment
        ├── authentication.md    # Auth flow, security
        ├── database.md          # Schema details
        └── api.md               # API structure, contracts
```

### Reference Syntax

In main file, replace detailed section with:
```example
### <Section-Name>
[...brief 2-3 line overview]

→ See: docs/PROJECT-ARCH/<sub-file>.md
```

---

## Example: Filled Main File

```example
# PROJECT-ARCH: Acme E-Commerce Platform
Architecture documentation for the Acme e-commerce platform serving B2C retail operations.

⟪📐 arch-overview: layered-monolith | 3-tier, domain-driven, CQRS read-models⟫

## Quick Reference

⟪🗺️ layers: web → application → domain → infrastructure⟫

| Layer | Purpose | Key Components |
|:------|:--------|:---------------|
| Web | HTTP handling, views | `controllers/`, `views/` |
| Application | Use cases, orchestration | `services/`, `commands/` |
| Domain | Business logic, entities | `domain/`, `events/` |
| Infrastructure | External integrations | `repositories/`, `adapters/` |

⟪🔧 services: postgres-14, redis-7, elasticsearch-8 | docker-compose local, EKS prod⟫

---

## Architectural Layers

```diagram
┌─────────────────────────────────────────────────┐
│                  Web Layer                      │
│         Controllers, Middleware, Views          │
├─────────────────────────────────────────────────┤
│               Application Layer                 │
│        Services, Commands, Queries              │
├─────────────────────────────────────────────────┤
│                 Domain Layer                    │
│      Entities, Value Objects, Events            │
├─────────────────────────────────────────────────┤
│              Infrastructure Layer               │
│      Repositories, Adapters, Clients            │
└─────────────────────────────────────────────────┘
```

### Web Layer
**responsibility**
: HTTP request handling, input validation, response formatting

**key-components**
: `ProductController`, `OrderController`, `AuthMiddleware`

→ See: docs/PROJECT-ARCH/layers.md

---

## Domain Model

⟪📂: {domain-model}⟫

### Bounded Contexts

**Catalog**
: Product information, categories, pricing
: Entities: `Product`, `Category`, `PriceList`

**Orders**
: Order lifecycle, fulfillment tracking
: Entities: `Order`, `OrderLine`, `Shipment`

**Customers**
: Customer accounts, preferences, history
: Entities: `Customer`, `Address`, `PaymentMethod`

→ See: docs/PROJECT-ARCH/domain.md

---

## Key Patterns

### Repository Pattern
**rationale**
: Abstracts data access, enables testing without database

**implementation**
: Interface in domain layer, implementation in infrastructure

### CQRS Read Models
**rationale**
: Optimized query performance for catalog browsing

**implementation**
: Elasticsearch projections updated via domain events

→ See: docs/PROJECT-ARCH/patterns.md

---

## Infrastructure

⟪🔧 services: postgres-14, redis-7, elasticsearch-8, rabbitmq-3⟫

| Service | Purpose | Config Location |
|:--------|:--------|:----------------|
| PostgreSQL | Primary data store | `config/database.yml` |
| Redis | Session cache, rate limiting | `config/redis.yml` |
| Elasticsearch | Product search, analytics | `config/elasticsearch.yml` |
| RabbitMQ | Event messaging | `config/rabbitmq.yml` |

→ See: docs/PROJECT-ARCH/infrastructure.md

---

## Critical Issues

🎯 **Session Security**: Redis sessions lack encryption at rest
- Affected: `SessionStore`, `AuthMiddleware`
- Mitigation: Network isolation; encryption planned Q2

🎯 **Search Latency**: Elasticsearch reindexing causes 2-3s delays
- Affected: `ProductSearch`, `CatalogController`
- Mitigation: Background reindexing with alias swap

---

## Summary

**architecture-strengths**
: Clear layer separation enables independent testing; CQRS provides optimized read performance; event-driven design supports future service extraction

**known-tradeoffs**
: Monolith deployment means full redeploy for changes; shared database limits independent scaling

**evolution-path**
: Extract Orders context to separate service Q3; migrate to event sourcing for Catalog Q4
```

---

## Agent Integration

### gopher-scout Usage

When analyzing a codebase, gopher-scout should:

1. Identify architectural style from directory structure and dependencies
2. Map layers based on directory conventions and import patterns
3. Extract service dependencies from configuration files
4. Document patterns found in code through static analysis
5. Flag potential issues for critical issues section

### project-coordinator Usage

When generating PROJECT-ARCH.md, project-coordinator should:

1. Use main file template for initial generation
2. Monitor section lengths during generation
3. Split to sub-files when threshold exceeded
4. Maintain cross-references between main file and sub-files
5. Apply appropriate directives for each section type

---

## See Also

- `${NPL_HOME}/npl/directive.md` - Directive syntax reference
- `${NPL_HOME}/npl/syntax.md` - Core NPL syntax elements
- `${NPL_HOME}/npl/fences/diagram.md` - Diagram fence specifications
- `${NPL_HOME}/npl/formatting.md` - Output formatting patterns
