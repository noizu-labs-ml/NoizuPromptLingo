# Lifecycle State Machine

Complete specification for plugin lifecycle management — states, transitions, guards, error recovery, and dependency ordering.

## State Diagram

```
                    ┌──────────────┐
                    │  Discovered  │
                    └──────┬───────┘
                           │ install()
                           ▼
                    ┌──────────────┐
              ┌─────│  Installed   │◄────────┐
              │     └──────┬───────┘         │
              │            │ activate()      │ deactivate()
              │            ▼                 │
              │     ┌──────────────┐         │
              │     │  Activating  │─────┐   │
              │     └──────┬───────┘     │   │
              │            │ ready       │   │
              │            ▼             │   │
              │     ┌──────────────┐     │   │
              │     │   Running    │     │   │
              │     └──────┬───────┘     │   │
              │            │             │   │
              │       ┌────┴────┐        │   │
              │       │         │        │   │
              │  deactivate() error    │   │
              │       │         │        │   │
              │       ▼         ▼        │   │
              │  ┌─────────┐ ┌────────┐  │   │
              │  │Deactivat│ │Errored │──┘   │
              │  │  ing    │ └────────┘      │
              │  └────┬────┘                 │
              │       │ done                 │
              │       ▼                      │
              │  ┌──────────────┐            │
              │  │ Deactivated  │────────────┘
              │  └──────────────┘
              │
              │ uninstall()
              ▼
        ┌──────────────┐
        │  Uninstalled  │
        └──────────────┘
```

## States

| State | Description | Plugin Code Running? | Host Responsibility |
|-------|-------------|---------------------|---------------------|
| **Discovered** | Manifest found and validated | No | Store manifest, check constraints |
| **Installed** | Artifacts downloaded, on disk | No | Verify integrity, resolve dependencies |
| **Activating** | Loading code, running `onActivate` | Starting | Inject context, register hooks, enforce timeout |
| **Running** | Fully active, responding to extension points | Yes | Monitor health, enforce resource limits |
| **Deactivating** | Running `onDeactivate`, cleaning up | Stopping | Unregister hooks, enforce cleanup timeout |
| **Deactivated** | Code unloaded, hooks unregistered | No | Persist plugin state for reactivation |
| **Errored** | Failed during activation or runtime | Terminated | Quarantine, log error, notify admin |
| **Uninstalled** | Artifacts removed | No | Clean up all plugin data and configuration |

## Transitions

### install(pluginId)

```yaml
from: Discovered
to: Installed
guards:
  - All required dependencies are installed
  - Host version satisfies plugin's constraint
  - Required capabilities can be granted
  - Disk space sufficient for artifacts
actions:
  - Download artifacts (if remote)
  - Verify integrity (checksum, signature)
  - Extract to plugin directory
  - Call plugin.onInstall() if exported
  - Persist installation record
rollback:
  - Remove downloaded artifacts
  - Remove installation record
```

### activate(pluginId)

```yaml
from: Installed | Deactivated
to: Activating → Running
guards:
  - All required plugin dependencies are Running
  - Required capabilities are granted
  - Not in error quarantine
actions:
  - Load plugin code (dynamic import)
  - Inject host context with granted capabilities
  - Call plugin.onActivate(context)
  - Register declared hooks, slots, services
  - Start health monitoring
timeout: 10000  # ms — fail to Errored if exceeded
rollback:
  - Unregister any partially-registered hooks
  - Unload plugin code
  - Transition to Errored
```

### deactivate(pluginId)

```yaml
from: Running
to: Deactivating → Deactivated
guards:
  - No Running plugins depend on this one (or force=true)
actions:
  - Call plugin.onDeactivate()
  - Unregister all hooks, slots, services
  - Stop health monitoring
  - Persist plugin state for later reactivation
  - Unload plugin code / release references
timeout: 5000  # ms — force-kill if exceeded
cascade:
  - If force=true, deactivate dependents first (reverse dependency order)
```

### uninstall(pluginId)

```yaml
from: Installed | Deactivated | Errored
to: Uninstalled
guards:
  - Plugin is not Running (deactivate first)
  - No installed plugins have hard dependency on this one
actions:
  - Call plugin.onUninstall() if available
  - Remove plugin artifacts from disk
  - Remove plugin configuration
  - Remove installation record
  - Notify dependents of removal
```

### error(pluginId, error)

```yaml
from: Activating | Running
to: Errored
trigger: Uncaught exception, timeout, health check failure
actions:
  - Terminate plugin code
  - Unregister all hooks (prevent stale callbacks)
  - Log error with full context
  - Increment error counter
  - Notify admin/user
  - Apply quarantine policy
quarantine:
  maxRetries: 3
  backoff: exponential  # 1s, 2s, 4s
  cooldown: 300000      # 5 min before auto-retry
```

## Dependency Ordering

### Activation Order

```
1. Build dependency graph from all plugins to activate
2. Topological sort → ordered list
3. Activate in order (dependencies first)
4. If any activation fails:
   a. Mark failed plugin as Errored
   b. Skip plugins that depend on it (mark as "dependency-blocked")
   c. Continue activating independent plugins
```

### Deactivation Order

```
1. Build reverse dependency graph
2. Topological sort → ordered list (dependents first)
3. Deactivate in order (dependents before dependencies)
4. If any deactivation times out:
   a. Force-kill the plugin
   b. Continue deactivating remaining plugins
```

## Health Monitoring

```yaml
healthCheck:
  interval: 30000       # ms between checks
  timeout: 5000         # ms to respond
  unhealthyThreshold: 3 # consecutive failures before Errored
  method: ping          # ping | heartbeat | custom

# Ping: host calls plugin.healthCheck(), expects response within timeout
# Heartbeat: plugin calls host.heartbeat() periodically, host tracks last seen
# Custom: plugin registers custom health check function
```

## Persistence

The lifecycle manager must persist state across host restarts:

```json
{
  "plugins": {
    "my-plugin": {
      "state": "running",
      "version": "1.0.0",
      "activatedAt": "2025-01-15T10:30:00Z",
      "config": { "apiKey": "***", "enabled": true },
      "errorCount": 0,
      "lastError": null
    }
  },
  "activationOrder": ["base-theme", "my-plugin", "analytics"],
  "pendingUpdates": {}
}
```

On host restart:
1. Load persisted state
2. Discover current plugins on disk
3. Reconcile (handle plugins added/removed while host was down)
4. Re-activate all plugins that were Running, in dependency order

## Hot Reload

For development workflows, support reloading a plugin without full deactivate/activate:

```
1. Detect file change in plugin directory
2. Call plugin.onDeactivate() (quick cleanup)
3. Invalidate module cache for plugin
4. Re-import plugin code
5. Call plugin.onActivate(context)
6. Re-register hooks with new implementations
```

Guards:
- Only in development mode
- Plugin must declare `"hotReload": true` in manifest
- Host must support module cache invalidation (Node.js, Python importlib)
