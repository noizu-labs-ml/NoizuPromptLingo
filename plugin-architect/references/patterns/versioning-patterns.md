# Versioning Patterns

How plugin APIs evolve without breaking the ecosystem. The central challenge: the host application moves faster than the plugin ecosystem can adapt.

## Strategy 1: Semantic Versioning

The host's plugin API has an explicit version. Major bumps break plugins; minor/patch don't.

### When to Use
- Stable APIs with infrequent breaking changes
- When the plugin ecosystem is large enough that breakage is costly

### Implementation

```typescript
// Host declares its API version
const PLUGIN_API_VERSION = '2.1.0';

// Plugin manifest declares compatible range
{
  "dependencies": {
    "host": "^2.0.0"  // Works with any 2.x.x
  }
}

// Registry enforces
if (!semver.satisfies(PLUGIN_API_VERSION, plugin.dependencies.host)) {
  throw new IncompatiblePluginError(plugin.name, plugin.dependencies.host, PLUGIN_API_VERSION);
}
```

### Breaking Change Definition

| Change Type | Breaking? | Example |
|-------------|-----------|---------|
| Remove a hook | Yes | Removing `beforeSave` |
| Change hook signature | Yes | Adding required parameter |
| Add optional hook parameter | No | New optional field in context |
| Add new hook | No | New `onExport` hook |
| Change return type | Yes | `string` → `string[]` |
| Narrow accepted input | Yes | Accepting fewer values |
| Widen returned output | No | Adding optional fields |

---

## Strategy 2: API Version Header

Plugin declares which API version it targets. Host routes to the correct handler.

### When to Use
- Rapidly evolving APIs with frequent breaking changes
- When multiple API versions must be supported simultaneously

### Implementation

```typescript
// Plugin declares
{
  "apiVersion": "v2"
}

// Host routes
function invokeHook(plugin: Plugin, hookName: string, data: unknown) {
  const handler = apiHandlers[plugin.apiVersion];
  if (!handler) throw new UnsupportedApiVersionError(plugin.apiVersion);
  return handler.invoke(hookName, data);
}

// Version-specific handlers coexist
const apiHandlers = {
  v1: new V1Handler(),  // Legacy
  v2: new V2Handler(),  // Current
  v3: new V3Handler(),  // Beta
};
```

### Trade-offs
- (+) Clean separation between versions
- (+) Old plugins keep working without changes
- (-) Must maintain multiple API handler implementations
- (-) Feature parity across versions becomes a burden

---

## Strategy 3: Capability Negotiation

Plugin requests features; host reports which are available. No fixed version — just a set of capabilities.

### When to Use
- Highly heterogeneous host versions
- When plugins should gracefully degrade on older hosts
- Browser-style "feature detection" model

### Implementation

```typescript
// Plugin checks capabilities
function activate(host: HostAPI) {
  if (host.supports('sidebar-widgets@2')) {
    host.slots.register('sidebar', AdvancedWidget);
  } else if (host.supports('sidebar-widgets@1')) {
    host.slots.register('sidebar', BasicWidget);
  } else {
    console.warn('Sidebar widgets not supported — plugin running in limited mode');
  }
}

// Host declares capabilities
class HostAPI {
  private capabilities = new Set([
    'sidebar-widgets@2',
    'hooks@3',
    'events@1',
    'services@2',
  ]);

  supports(capability: string): boolean {
    return this.capabilities.has(capability);
  }
}
```

### Trade-offs
- (+) Maximum flexibility — plugins adapt to host
- (+) No binary "compatible or not" — graceful degradation
- (-) Plugins must handle every combination of present/absent capabilities
- (-) Testing matrix explodes

---

## Strategy 4: Adapter Layer

Host provides shims that translate old API calls into new ones. Legacy plugins run unmodified against adapters.

### When to Use
- Long-lived ecosystems with many legacy plugins (VS Code, WordPress)
- When breaking changes are necessary but plugin churn must be minimized
- As a transitional strategy during major API migrations

### Implementation

```typescript
// V1 API (deprecated)
interface PluginV1 {
  onSave(document: string): string;
}

// V2 API (current)
interface PluginV2 {
  onSave(context: { document: string; metadata: Metadata }): SaveResult;
}

// Adapter wraps V1 plugins to look like V2
class V1Adapter implements PluginV2 {
  constructor(private legacy: PluginV1) {}

  onSave(context: { document: string; metadata: Metadata }): SaveResult {
    const result = this.legacy.onSave(context.document);
    return { document: result, metadata: context.metadata };
  }
}
```

### Trade-offs
- (+) Zero effort for plugin authors during migration
- (+) Host can evolve freely internally
- (-) Adapters accumulate — each layer adds latency and complexity
- (-) Some new features can't be backported through adapters

---

## Deprecation Protocol

Regardless of versioning strategy, have a clear deprecation process:

### Timeline

```
Version N:   Feature works normally
Version N+1: Feature emits deprecation warning at runtime
Version N+2: Feature emits warning + is documented as deprecated
Version N+3: Feature removed (breaking change → major version bump)
```

### Runtime Warnings

```typescript
function deprecatedHook(name: string, replacement: string) {
  return function(target: any, key: string) {
    const original = target[key];
    target[key] = function(...args: any[]) {
      console.warn(
        `[DEPRECATED] Hook "${name}" will be removed in v${NEXT_MAJOR}. ` +
        `Use "${replacement}" instead. Plugin: ${this.pluginName}`
      );
      return original.apply(this, args);
    };
  };
}
```

### Migration Guides

Every breaking change must ship with:
1. What changed and why
2. Before/after code examples
3. Automated codemod if possible (jscodeshift, AST transforms)
4. Timeline for removal
