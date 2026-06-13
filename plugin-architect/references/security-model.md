# Plugin Security Model

Security architecture for plugin systems — from sandboxing strategies through capability permissions to audit logging.

## Trust Levels

| Level | Who | Isolation | Example |
|-------|-----|-----------|---------|
| **Trusted** | Internal/first-party code | Same process, no sandbox | Core modules shipped with the app |
| **Semi-trusted** | Vetted third-party, signed | Process or WASM sandbox | Marketplace plugins with review process |
| **Untrusted** | Unknown origin, unsigned | Full container/VM isolation | User-uploaded scripts, community plugins |

Design your security model for the lowest trust level you intend to support. You can always relax restrictions for higher-trust plugins.

## Capability-Based Security

Instead of role-based permissions, use capability-based security where plugins explicitly request access to specific resources.

### Capability Model

```yaml
# Plugin manifest declares needed capabilities
capabilities:
  required:
    - read:documents       # Read document content
    - write:sidebar        # Modify sidebar UI
  optional:
    - read:analytics       # Enhanced if analytics available
    - network:outbound     # Call external APIs
```

### Host Enforcement

```typescript
class CapabilityGate {
  private grants: Map<string, Set<string>> = new Map();

  grant(pluginId: string, capability: string): void {
    if (!this.grants.has(pluginId)) this.grants.set(pluginId, new Set());
    this.grants.get(pluginId)!.add(capability);
  }

  check(pluginId: string, capability: string): boolean {
    return this.grants.get(pluginId)?.has(capability) ?? false;
  }

  createProxy<T extends object>(pluginId: string, target: T, capabilityMap: Record<string, string>): T {
    return new Proxy(target, {
      get: (obj, prop) => {
        const required = capabilityMap[prop as string];
        if (required && !this.check(pluginId, required)) {
          throw new CapabilityDeniedError(pluginId, required);
        }
        return (obj as any)[prop];
      },
    });
  }
}
```

### Principle of Least Authority

- Default everything to denied
- Grant only what the manifest declares as required
- Prompt user for optional capabilities
- Never grant ambient authority (no "admin" capability)
- Capabilities are non-transitive (granting to plugin A doesn't grant to plugins A depends on)

## Sandboxing Strategies

### Same Process (No Sandbox)

```
Host Process
├── Host Code
├── Plugin A (shared memory, shared event loop)
└── Plugin B (shared memory, shared event loop)
```

- **Isolation:** None
- **Use when:** All plugins are trusted/internal
- **Risks:** Plugin crash = host crash, memory leaks affect host, full access to host internals

### Worker Thread / Web Worker

```
Host Process
├── Host Code
├── Worker Thread → Plugin A (separate V8 isolate)
└── Worker Thread → Plugin B (separate V8 isolate)
```

- **Isolation:** Separate memory, shared process
- **Use when:** Semi-trusted plugins, performance-sensitive
- **Implementation:** `worker_threads` (Node.js), Web Workers (browser), `threading` (Python)
- **Communication:** Structured clone / message passing
- **Limitations:** No shared objects (must serialize), some APIs unavailable in workers

### Child Process

```
Host Process ←→ IPC ←→ Plugin Process A
              ←→ IPC ←→ Plugin Process B
```

- **Isolation:** Separate process, separate memory
- **Use when:** Semi-trusted to untrusted, plugins need OS-level resources
- **Communication:** JSON-RPC over stdio, IPC, or Unix sockets
- **Trade-off:** Higher latency (serialization + IPC), higher memory (separate runtime per plugin)

### WASM Sandbox

```
Host Process
├── WASM Runtime → Plugin A (memory-safe sandbox)
└── WASM Runtime → Plugin B (memory-safe sandbox)
```

- **Isolation:** Memory-safe sandbox within the process
- **Use when:** Untrusted code that needs near-native performance
- **Implementation:** `wasmtime` (Rust), `wasmer`, browser WASM
- **Trade-off:** Limited host API surface (must bridge through WASM interface), language constraints

### Container / VM

```
Host ←→ gRPC ←→ Container A (Plugin)
     ←→ gRPC ←→ Container B (Plugin)
```

- **Isolation:** Full OS-level isolation
- **Use when:** Fully untrusted code, plugins need arbitrary system access
- **Communication:** gRPC, HTTP, or message queue
- **Trade-off:** Highest latency, highest resource cost, most complex deployment

## Input Validation

Every value returned by a plugin must be validated before the host uses it.

### Validation Points

| Point | What to Validate |
|-------|-----------------|
| **Hook return values** | Schema match, size limits, no forbidden fields |
| **Event payloads** | Schema match, no injection payloads |
| **Slot rendered content** | Sanitize HTML (if applicable), size limits |
| **Service responses** | Interface contract compliance, timeout enforcement |
| **Configuration values** | Type match, range checks, no path traversal |

### Implementation Pattern

```typescript
function validatePluginOutput<T>(
  pluginId: string,
  hookName: string,
  output: unknown,
  schema: ZodSchema<T>
): T {
  const result = schema.safeParse(output);
  if (!result.success) {
    logger.warn(`Plugin "${pluginId}" returned invalid data from "${hookName}"`, {
      errors: result.error.issues,
    });
    throw new PluginOutputValidationError(pluginId, hookName, result.error);
  }
  return result.data;
}
```

## Resource Limits

| Resource | Limit Mechanism | Default |
|----------|----------------|---------|
| **CPU time** | Timeout per hook invocation | 5 seconds |
| **Memory** | V8 heap limit (workers), cgroup (containers) | 128 MB |
| **Disk** | Quota on plugin storage directory | 50 MB |
| **Network** | Capability gate + rate limiting | Denied by default |
| **File system** | Chroot to plugin directory, read-only host paths | Plugin dir only |
| **Concurrency** | Max parallel hook invocations | 10 |

## Audit Logging

Log all security-relevant plugin actions:

```typescript
interface AuditLog {
  timestamp: string;
  pluginId: string;
  action: string;            // 'capability_check' | 'hook_invoked' | 'error' | ...
  capability?: string;
  granted?: boolean;
  details?: Record<string, unknown>;
  duration?: number;
}
```

Retain audit logs for at least 30 days. Alert on:
- Repeated capability denials (plugin probing for access)
- Frequent errors from a single plugin
- Unusual hook invocation patterns (timing, frequency)
- Resource limit hits

## Supply Chain Security

| Threat | Mitigation |
|--------|-----------|
| **Typosquatting** | Namespace plugins under org (e.g., `@org/plugin-name`) |
| **Dependency confusion** | Pin plugin dependencies, use lockfiles |
| **Malicious updates** | Require signed releases, review diffs for sensitive changes |
| **Compromised publisher** | Two-factor auth for publishing, publish alerts to maintainers |
| **Integrity tampering** | SHA-256 checksums in manifest, verify on install |
