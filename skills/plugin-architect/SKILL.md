---
name: trl-plugin-architect
description: >
  Design and implement plugin architectures for extensible software systems: define extension points,
  build plugin registries, create lifecycle management, and scaffold plugin projects for any host
  application. Use this skill when the user wants to make an application extensible, design a plugin
  system, define extension points, build a plugin registry, create plugin lifecycle hooks, scaffold a
  plugin SDK, generate plugin project templates, or architect a third-party extension system — even if
  they don't say "plugin." Also trigger when users mention extension points, plugin hooks, plugin
  registry, plugin lifecycle, add-on system, middleware pipeline, event bus architecture, host-guest
  contracts, plugin sandboxing, hot-reloading plugins, or plugin SDK design.
---

# Plugin Architect

Design extensible software through principled plugin architectures — from extension point definition through plugin SDK generation.

## Overview

Plugin systems are how software survives contact with users who need it to do things the original author never imagined. This skill provides a methodology for designing plugin architectures that are safe, discoverable, and pleasant to extend. It covers:

- **Extension point design** — Identify where your application should be extensible, define contracts, choose between hooks/events/slots/middleware patterns
- **Registry architecture** — Build the discovery and registration layer: manifest-driven, convention-based, or hybrid approaches
- **Lifecycle management** — Install, activate, deactivate, upgrade, and uninstall plugins safely with dependency resolution
- **Plugin SDK generation** — Scaffold the developer experience: project templates, type stubs, test harnesses, documentation
- **Security boundaries** — Sandbox plugins, validate inputs, enforce capability-based permissions
- **Host-guest protocol design** — Define the API surface between host application and plugin code

## Core Philosophy

**Five Principles:**

1. **Contract-first design** — Define the interface before the implementation; extension points are API surfaces that third parties will depend on, so treat them with the same rigor as public APIs
2. **Minimal surface area** — Expose the least power necessary; every capability granted to a plugin is a capability that can be misused or that constrains future evolution
3. **Lifecycle as first-class concern** — Plugins are born, live, and die; designing for graceful install/upgrade/uninstall prevents the brittle state that accumulates in long-running extensible systems
4. **Developer experience drives adoption** — A plugin system nobody extends is a wasted abstraction; the SDK, docs, and scaffolding matter as much as the runtime architecture
5. **Defense in depth** — Assume plugins will crash, leak memory, block the event loop, and pass malformed data; design the host to survive all of it

## When to Use This Skill

- **Making an existing application extensible** — Adding plugin support to a monolithic app
- **Designing a new extensible system from scratch** — Greenfield architecture with extensibility as a core requirement
- **Defining extension points** — Deciding where, how, and what to expose to plugin authors
- **Building a plugin registry** — Manifest parsing, discovery, dependency resolution, version constraints
- **Creating plugin lifecycle management** — Install/activate/deactivate/upgrade/uninstall flows
- **Scaffolding a plugin SDK** — Project templates, type stubs, test harnesses, example plugins
- **Reviewing an existing plugin architecture** — Audit for security, DX, and evolution risks
- **Designing host-guest protocols** — API contracts, capability negotiation, versioning strategies

> For securing plugin boundaries against adversarial extensions, see **trl-threat-modeler** (`SKILL.md`).
> For designing the plugin management UI, see **trl-user-experience-engineer** (`SKILL.md`).
> For building an MCP server that exposes plugin capabilities, see **trl-mcp-architect** (`SKILL.md`).
> For CLI-based plugin management interfaces, see **trl-tui-engineer** (`SKILL.md`).

## Plugin Architecture Patterns

### Extension Point Taxonomy

| Pattern | Mechanism | Best For | Trade-off |
|---------|-----------|----------|-----------|
| **Hook/Filter** | Named callback registration | Transforming data at defined points | Simple but rigid ordering |
| **Event Bus** | Pub/sub on typed events | Decoupled reactions to system state changes | Hard to trace causality |
| **Middleware Pipeline** | Ordered interceptor chain | Request/response processing (HTTP, CLI) | Order matters, debugging is linear |
| **Slot/Mount Point** | Named UI or content regions | UI extensibility (panels, menus, sidebars) | Tight coupling to host layout |
| **Service Provider** | Interface implementation registration | Swappable backends (storage, auth, transport) | Requires stable interface contracts |
| **AST/IR Transform** | Code transformation pipeline | Build tools, compilers, linters | Complex, high power, high risk |

### Choosing a Pattern

```
Is the extension transforming data in-flight?
  → Hook/Filter

Is the extension reacting to something that happened?
  → Event Bus

Is the extension wrapping a request/response flow?
  → Middleware Pipeline

Is the extension adding visible UI elements?
  → Slot/Mount Point

Is the extension providing an alternative implementation?
  → Service Provider

Is the extension modifying code or configuration before execution?
  → AST/IR Transform
```

Most real systems combine 2-3 patterns. The host application typically uses Hook/Filter for its core pipeline, Event Bus for cross-cutting concerns, and Slot/Mount Point or Service Provider for major extension surfaces.

## Design Process

### Phase 1: Extension Point Discovery

Identify where your application should be extensible.

| Activity | Output | Duration |
|----------|--------|----------|
| Map the data flow | Diagram of how data moves through the system | 30-60 min |
| Identify customization requests | List of "I wish I could..." from users/stakeholders | 30 min |
| Classify extension types | Each point mapped to a pattern from the taxonomy | 30 min |
| Define boundaries | What plugins CAN and CANNOT do | 15 min |
| Prioritize | Which extension points to ship first | 15 min |

**Key question:** "If a third party wanted to change this behavior, what's the minimum they'd need access to?"

### Phase 2: Contract Design

Define the API surface for each extension point.

| Activity | Output | Duration |
|----------|--------|----------|
| Draft type signatures | Interface/type definitions for each hook | 1-2 hours |
| Define context objects | What data the host passes to plugins | 30-60 min |
| Version strategy | How contracts evolve without breaking plugins | 30 min |
| Error contract | How plugins report errors, how host handles them | 30 min |
| Capability model | What permissions plugins request and host grants | 30-60 min |

**Versioning strategies:**

| Strategy | Mechanism | When to Use |
|----------|-----------|-------------|
| **Semantic versioning** | Major bumps break, minor adds, patch fixes | Stable APIs with infrequent changes |
| **API version header** | Plugin declares which API version it targets | Multiple breaking changes expected |
| **Capability negotiation** | Plugin requests features, host reports availability | Highly heterogeneous host versions |
| **Adapter layer** | Host provides shims for old API versions | Long-lived ecosystems with legacy plugins |

### Phase 3: Registry & Discovery

Build the mechanism for finding, loading, and managing plugins.

| Approach | Discovery | Best For |
|----------|-----------|----------|
| **Manifest-driven** | JSON/YAML file declares entry points, deps, metadata | Marketplaces, curated ecosystems |
| **Convention-based** | Directory structure + naming conventions | Internal/enterprise plugins |
| **Hybrid** | Manifest for metadata, convention for structure | Most production systems |
| **Remote registry** | Central server with search, versions, trust | Public ecosystems (npm, VS Code) |

**Registry responsibilities:**
- Discover available plugins (local + remote)
- Parse and validate manifests
- Resolve dependency graphs
- Enforce version constraints
- Manage trust/signing verification

### Phase 4: Lifecycle Implementation

| State | Entry Trigger | Host Responsibility | Plugin Hook |
|-------|--------------|--------------------|----|
| **Discovered** | Registry scan | Validate manifest, check constraints | — |
| **Installed** | User action or dependency | Download, verify, store artifacts | `onInstall()` |
| **Activated** | User action or auto-start | Load code, inject dependencies, register hooks | `onActivate(context)` |
| **Running** | Activation complete | Monitor health, enforce resource limits | Extension point callbacks |
| **Deactivated** | User action or error | Unregister hooks, release resources | `onDeactivate()` |
| **Uninstalled** | User action | Remove artifacts, clean up state | `onUninstall()` |
| **Errored** | Uncaught exception or timeout | Quarantine, notify, offer recovery | `onError(error)` |

**Dependency resolution:**
```
1. Build dependency graph from all plugin manifests
2. Topological sort (fail on cycles)
3. Activate in dependency order
4. Deactivate in reverse dependency order
5. Block uninstall if dependents are active
```

### Phase 5: SDK & Developer Experience

| Deliverable | Purpose | Priority |
|-------------|---------|----------|
| **Project template** | `create-plugin` CLI or scaffold command | Critical |
| **Type stubs** | TypeScript/Python types for all extension points | Critical |
| **Test harness** | Run plugin against mock host without full app | High |
| **Example plugins** | Reference implementations for each extension pattern | High |
| **Documentation** | Extension point catalog, getting started guide, API reference | High |
| **Dev server** | Hot-reload plugin during development | Medium |
| **Linter/validator** | Static checks for common plugin mistakes | Medium |

## Security Model

### Threat Surface

| Threat | Mitigation |
|--------|-----------|
| **Malicious code execution** | Sandbox (VM, process isolation, WASM), capability permissions |
| **Resource exhaustion** | CPU/memory limits, timeout enforcement, rate limiting |
| **Data exfiltration** | Restrict network access, audit API calls, capability-gated I/O |
| **Host state corruption** | Immutable context objects, copy-on-write data, transactional hooks |
| **Dependency confusion** | Signed manifests, pinned versions, integrity checksums |
| **Privilege escalation** | Capability-based permissions, least-privilege defaults, no ambient authority |

### Isolation Strategies

| Strategy | Isolation Level | Performance | Complexity |
|----------|----------------|-------------|------------|
| **Same-process, same-thread** | None | Best | Lowest |
| **Same-process, worker thread** | Thread | Good | Low |
| **Child process** | Process | Moderate | Medium |
| **WASM sandbox** | Memory-safe sandbox | Good | Medium |
| **Container/VM** | Full OS-level | Worst | Highest |

Choose based on trust level: internal plugins → same process; marketplace plugins → WASM or process isolation; untrusted code → container/VM.

## Language-Specific Patterns

| Language | Discovery | Loading | Typing | Common Pattern |
|----------|-----------|---------|--------|----------------|
| **TypeScript/JS** | `package.json` fields, `node_modules` scan | `import()` dynamic | Interface exports | Event emitters + middleware |
| **Python** | Entry points (`pyproject.toml`), `importlib` | `importlib.import_module()` | Protocol classes, ABC | Decorators + registry pattern |
| **Go** | `plugin` pkg (CGo), or RPC | `plugin.Open()` or gRPC | Interface satisfaction | Interface + `init()` registration |
| **Rust** | `dylib` or WASM | `libloading` or `wasmtime` | Trait objects | Trait-based + `inventory` crate |
| **Java/Kotlin** | `ServiceLoader`, classpath scan | `ClassLoader` | Interface/abstract class | SPI + annotation processing |

## Quick Start Guides

### Design Extension Points for an Existing App
1. Map your application's data flow and identify customization requests
2. Select extension point patterns from the taxonomy table
3. Draft type contracts using [contract-templates.md](assets/contract-templates.md)
4. Define the security boundary and capability model
5. Review against [extension-point-checklist.md](references/extension-point-checklist.md)

### Build a Plugin Registry from Scratch
1. Choose discovery approach (manifest, convention, hybrid)
2. Design the manifest schema using [manifest-schema-guide.md](references/manifest-schema-guide.md)
3. Implement dependency resolution (topological sort)
4. Add version constraint checking
5. Wire up the lifecycle state machine

### Scaffold a Plugin SDK
1. Define your target developer persona
2. Generate project template with [sdk-scaffold-guide.md](references/sdk-scaffold-guide.md)
3. Export type stubs for all extension points
4. Build a test harness with mock host context
5. Write 2-3 example plugins demonstrating each pattern
6. Generate API reference documentation

### Audit an Existing Plugin System
1. Map current extension points and their contracts
2. Check lifecycle completeness (all 7 states handled?)
3. Assess security model against the threat surface table
4. Evaluate DX: time from `git clone` to working plugin
5. Score with [plugin-architecture-rubric.md](assets/plugin-architecture-rubric.md)

## Reference Guide

### When to Read Each Reference

| Task | Read These |
|------|-----------|
| **Starting any plugin architecture** | `design-principles.md`, `extension-point-checklist.md` |
| **Choosing extension patterns** | `patterns/extension-patterns.md` |
| **Designing plugin manifests** | `manifest-schema-guide.md` |
| **Implementing lifecycle** | `lifecycle-state-machine.md` |
| **Building the SDK** | `sdk-scaffold-guide.md` |
| **Securing plugins** | `security-model.md` |
| **Full design walkthrough** | `worked-example-vscode-style.md` |
| **Quick audit** | `worked-example-audit.md` |

All reference paths are relative to `references/`.

## Related Skills

- **trl-threat-modeler** — Deep security analysis of plugin trust boundaries, capability models, and adversarial extension scenarios
- **trl-mcp-architect** — MCP servers are themselves a plugin architecture; cross-pollinate patterns for tool registration and lifecycle
- **trl-tui-engineer** — CLI-based plugin management interfaces (`plugin install`, `plugin list`, `plugin enable`)
- **trl-user-experience-engineer** — Plugin marketplace UI, settings panels, extension management screens
- **trl-agentic-harness-engineer** — Agent tool systems are plugin architectures; shared patterns for registration, sandboxing, and lifecycle
- **trl-skill-engineer** — Skills are a form of plugin for AI agents; meta-level pattern sharing
- **trl-dba-db-designer-and-tuning** — Schema design for plugin metadata storage, registry tables, and state persistence

## Bundled Resources

### References

**Foundation** (read first):
- [design-principles.md](references/design-principles.md) — Core principles for plugin architecture: contract stability, minimal surface, graceful degradation, evolution strategies
- [extension-point-checklist.md](references/extension-point-checklist.md) — Pre-ship checklist for each extension point: typing, error handling, versioning, documentation

**Patterns** (`references/patterns/`):
- [extension-patterns.md](references/patterns/extension-patterns.md) — Deep dive into each pattern (hook, event, middleware, slot, service provider, AST transform) with implementation examples
- [registry-patterns.md](references/patterns/registry-patterns.md) — Discovery and registration approaches: manifest-driven, convention-based, remote registry architectures
- [versioning-patterns.md](references/patterns/versioning-patterns.md) — API evolution strategies: semver, capability negotiation, adapter layers, deprecation protocols

**Implementation:**
- [manifest-schema-guide.md](references/manifest-schema-guide.md) — Designing plugin manifest schemas: required fields, optional metadata, validation rules, examples across formats
- [lifecycle-state-machine.md](references/lifecycle-state-machine.md) — Complete state machine specification with transition guards, error recovery, and dependency ordering
- [sdk-scaffold-guide.md](references/sdk-scaffold-guide.md) — Building plugin SDKs: project templates, type exports, test harnesses, dev servers, documentation generation
- [security-model.md](references/security-model.md) — Plugin security architecture: sandboxing strategies, capability permissions, trust levels, audit logging

**Worked Examples:**
- [worked-example-vscode-style.md](references/worked-example-vscode-style.md) — Full walkthrough: designing a VS Code-style extension system from scratch (manifest, activation events, contribution points)
- [worked-example-audit.md](references/worked-example-audit.md) — Auditing an existing plugin system: mapping extensions, scoring architecture, recommending improvements

### Assets

- [contract-templates.md](assets/contract-templates.md) — Fillable templates for extension point contracts (TypeScript, Python, Go, Rust)
- [plugin-architecture-rubric.md](assets/plugin-architecture-rubric.md) — Quality scoring rubric for plugin system design
- [project-tracker.md](assets/project-tracker.md) — Plugin architecture project tracker for monitoring design and implementation progress
