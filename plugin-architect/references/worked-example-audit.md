# Worked Example: Plugin Architecture Audit

Walkthrough of auditing an existing plugin system — mapping extensions, scoring architecture, and recommending improvements.

## Scenario

You're auditing **DataFlow**, a data pipeline tool with an existing plugin system. The team reports:
- Plugin authors complain about frequent breaking changes
- Some plugins crash the host application
- New plugin development takes days to get started
- No way to test plugins without running the full pipeline

## Step 1: Map Current Extension Points

### Inventory

| Extension Point | Pattern | Typed? | Versioned? | Documented? |
|----------------|---------|--------|------------|-------------|
| `onTransform` | Hook | Partial (`any` params) | No | Yes (README) |
| `onValidate` | Hook | Partial | No | No |
| `onError` | Event | No (`any` payload) | No | No |
| `registerSource` | Service Provider | Yes (interface) | No | Yes |
| `registerSink` | Service Provider | Yes (interface) | No | Yes |
| UI: Pipeline view | Slot (React) | No | No | No |

### Findings

- **6 extension points** but only 2 are well-typed
- No versioning on any extension point — every host change can break plugins
- UI extension is ad-hoc (React component injection without contract)
- Error event has no typed payload — plugins can't reliably handle errors

## Step 2: Check Lifecycle Completeness

| State | Implemented? | Notes |
|-------|-------------|-------|
| Discovered | Yes | Scans `plugins/` directory |
| Installed | Partial | No dependency resolution |
| Activated | Yes | Calls `activate()` on import |
| Running | Yes | Hooks registered |
| Deactivated | No | No `deactivate()` hook |
| Errored | No | Plugin crash = host crash |
| Uninstalled | No | Manual file deletion |

### Findings

- **Only 3 of 7 states** are implemented
- No error containment — a failing plugin takes down the pipeline
- No deactivation — plugins leak resources, can't be disabled at runtime
- No dependency resolution — load order is alphabetical directory listing

## Step 3: Assess Security

| Threat | Current Mitigation | Gap |
|--------|-------------------|-----|
| Malicious code | None (same-process, full access) | Critical |
| Resource exhaustion | None | High |
| Data exfiltration | None | High |
| Host state corruption | Partial (some immutable objects) | Medium |
| Dependency confusion | None (no registry) | Low (internal only) |

### Findings

- All plugins run in the host process with full access — appropriate for internal use but dangerous if the team ever opens to third-party plugins
- No resource limits — a plugin with an infinite loop blocks the entire pipeline
- No audit logging

## Step 4: Measure Developer Experience

### Time to First Plugin

| Step | Time | Notes |
|------|------|-------|
| Find documentation | 10 min | README in repo root, but incomplete |
| Set up project | 30 min | No template, must copy existing plugin |
| Get type completions | 15 min | Types exist but aren't published as a package |
| Write basic plugin | 20 min | Unclear which hooks to use for common tasks |
| Test plugin | 45 min | Must run full pipeline locally |
| Debug issue | 30 min | No dev tools, console.log only |
| **Total** | **~2.5 hours** | **Target: under 30 minutes** |

### Findings

- No project template or scaffolding CLI
- Types not published — must symlink to host repo
- No test harness — full pipeline required for any testing
- No examples — new authors reverse-engineer existing plugins

## Step 5: Score and Recommend

### Scoring (10-point scale)

| Criterion | Score | Notes |
|-----------|-------|-------|
| Contract quality | 4/10 | Partial typing, no versioning |
| Lifecycle completeness | 3/10 | 3 of 7 states |
| Security | 2/10 | No isolation, no capabilities |
| Developer experience | 3/10 | 2.5 hours to first plugin |
| Documentation | 3/10 | README only, no API reference |
| Error handling | 2/10 | Plugin crash = host crash |
| **Weighted average** | **2.8/10** | |

### Priority Recommendations

| Priority | Recommendation | Impact | Effort |
|----------|---------------|--------|--------|
| P0 | **Add error containment** — wrap all plugin callbacks in try/catch with timeout | Stops plugin crashes from killing the host | 1-2 days |
| P0 | **Type all extension points** — replace `any` with specific types | Catches 80% of plugin bugs at compile time | 2-3 days |
| P1 | **Add deactivation lifecycle** — implement `onDeactivate()` hook and resource cleanup | Enables runtime plugin management | 1-2 days |
| P1 | **Publish type package** — `@dataflow/plugin-sdk` on internal registry | Unlocks IDE completions for plugin authors | 1 day |
| P1 | **Create project template** — `npx create-dataflow-plugin` | Drops time-to-first-plugin to 5 minutes | 2-3 days |
| P2 | **Build test harness** — mock pipeline context for plugin unit tests | Drops test time from 45 min to 30 seconds | 3-5 days |
| P2 | **Version extension points** — add API version to manifest, enforce constraints | Prevents silent breakage on host upgrades | 2-3 days |
| P3 | **Add capability model** — if opening to third-party plugins | Foundational security | 1-2 weeks |

### Implementation Order

```
Week 1: P0 items (error containment + typing)
Week 2: P1 items (lifecycle + SDK package + template)
Week 3: P2 items (test harness + versioning)
Week 4+: P3 items (only if third-party plugins planned)
```

### Expected Impact

- Plugin crashes → 0 host crashes (error containment)
- Time to first plugin: 2.5 hours → 15 minutes (template + types + harness)
- Breaking change frequency: unknown → detectable (versioning)
- Score improvement: 2.8/10 → estimated 7.0/10 after P0-P2
