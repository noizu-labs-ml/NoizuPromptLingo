# Plugin Architecture Design Principles

Core principles that apply to every plugin architecture regardless of language, framework, or scale.

## Principle 1: Contracts Are APIs

Every extension point is a public API. Plugin authors will write code against it, ship it, and expect it to keep working. Apply the same rigor you'd apply to a REST API or library interface:

- **Type it precisely** — Loose types (`any`, `object`, `interface{}`) create bugs that surface in production, not development
- **Version it explicitly** — Every breaking change needs a migration path
- **Document it thoroughly** — The contract is the spec; if it's ambiguous, plugins will interpret it differently
- **Test it independently** — Extension point contracts should have their own test suites

### Anti-pattern: The God Hook

```typescript
// Bad — plugin gets full mutable access to everything
onBeforeRender(context: AppState): void

// Good — plugin gets exactly what it needs, immutably
onBeforeRender(context: Readonly<{
  currentPage: PageData;
  userPreferences: UserPrefs;
}>): RenderModification | null
```

## Principle 2: Minimal Surface Area

Every capability you expose is a capability you must maintain. Every data field you share is a field you can't rename.

**Decision framework:**
1. Start with zero extension points
2. Add each one in response to concrete demand, not speculation
3. For each candidate, ask: "Can this be achieved with existing extension points?"
4. If not: expose the minimum data and authority needed

### The Capability Ratchet

Capabilities are easy to grant and hard to revoke. Once a plugin uses a capability, removing it is a breaking change. Default to denial and let plugin authors request what they need.

```yaml
# Plugin manifest requests capabilities explicitly
capabilities:
  required:
    - read:user-preferences
    - write:sidebar-content
  optional:
    - read:analytics-data
```

## Principle 3: Graceful Degradation

Plugins will fail. They'll throw exceptions, return malformed data, hang forever, and leak memory. The host application must survive all of it.

**Required resilience patterns:**
- **Timeout enforcement** — Every plugin callback has a maximum execution time
- **Error containment** — One plugin's failure never cascades to others
- **Fallback behavior** — The host has a sensible default for every extension point
- **Health monitoring** — Track plugin error rates and auto-disable chronic offenders
- **Recovery path** — Users can always disable a broken plugin without restarting the host

## Principle 4: Deterministic Ordering

When multiple plugins extend the same point, execution order matters. Make it explicit and controllable.

**Approaches:**
- **Priority numbers** — Plugin declares numeric priority (lower = earlier)
- **Before/after constraints** — Plugin declares "run before X" or "run after Y"
- **Topological sort** — Derive order from dependency graph
- **User-configurable** — Let the host application's admin set the order

**Anti-pattern:** Relying on registration order (load order is an implementation detail, not a contract).

## Principle 5: Evolution Without Breakage

Plugin systems live for years. The host application will evolve faster than the plugin ecosystem can keep up.

**Evolution strategies:**
- **Additive changes are safe** — New optional fields, new events, new extension points
- **Deprecation before removal** — Warn for at least one major version before removing
- **Adapter layers** — Shim old API versions for plugins that haven't migrated
- **Feature detection** — Let plugins check what the host supports before using it

```typescript
// Plugin checks host capabilities before using new API
if (host.supports('sidebar-widgets@2')) {
  host.registerSidebarWidget(myWidget);
} else {
  host.registerSidebarItem(myLegacyItem);
}
```

## Principle 6: Developer Experience Is Architecture

A plugin system with perfect internals but terrible DX won't be extended. The scaffolding, docs, and tooling are architectural decisions, not afterthoughts.

**DX quality bar:**
- **Time to first plugin:** Under 5 minutes from `git clone` to running example
- **Type feedback:** Immediate IDE completions and error highlighting
- **Test feedback:** Plugin can be tested without running the full host application
- **Reload feedback:** Changes visible without full restart (hot-reload or fast restart)
- **Error feedback:** Clear, actionable error messages when a plugin violates its contract

## Principle 7: Separation of Mechanism and Policy

The plugin runtime (mechanism) should be independent of what plugins are allowed to do (policy).

- **Mechanism:** How plugins are discovered, loaded, activated, called, and sandboxed
- **Policy:** Which plugins are trusted, what capabilities each gets, what resource limits apply

This separation means the same runtime can serve internal-only plugins (high trust, no sandbox) and marketplace plugins (low trust, full sandbox) by changing policy configuration.
