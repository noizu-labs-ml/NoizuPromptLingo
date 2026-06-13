# Extension Patterns

Deep dive into each plugin extension pattern with implementation examples across languages.

## Pattern 1: Hook/Filter

Named callbacks registered at defined points in the host's execution flow. The host calls registered hooks, passing data through them.

### When to Use
- Transforming data at a specific point (e.g., "before save", "after render")
- Allowing plugins to modify behavior without replacing it
- WordPress-style filter chains

### Structure

```
Host defines hook point → Plugins register callbacks → Host invokes in order → Results composed
```

### TypeScript Example

```typescript
type HookCallback<T> = (data: T) => T | Promise<T>;

interface HookRegistry {
  register<T>(hookName: string, callback: HookCallback<T>, priority?: number): void;
  invoke<T>(hookName: string, initialData: T): Promise<T>;
}

// Host defines the hook point
const result = await hooks.invoke('beforeSave', document);

// Plugin registers
hooks.register('beforeSave', (doc) => {
  doc.metadata.lastModified = Date.now();
  return doc;
}, 10);
```

### Python Example

```python
from typing import TypeVar, Callable, Generic
T = TypeVar('T')

class HookRegistry:
    def register(self, name: str, callback: Callable[[T], T], priority: int = 100) -> None: ...
    def invoke(self, name: str, data: T) -> T: ...

# Plugin registers
@hooks.filter('before_save', priority=10)
def add_timestamp(doc: Document) -> Document:
    doc.metadata['last_modified'] = datetime.now()
    return doc
```

### Composition Semantics
- **Chain:** Output of one callback becomes input of the next (most common)
- **First-wins:** First non-null return value is used
- **Accumulate:** All results collected into a list

### Pitfalls
- Order-dependent behavior is hard to debug
- Long chains become performance bottlenecks
- Side effects in filters break composability

---

## Pattern 2: Event Bus

Publish-subscribe on typed events. Decoupled — publishers don't know about subscribers.

### When to Use
- Reacting to state changes (e.g., "user logged in", "file saved")
- Cross-cutting concerns (logging, analytics, notifications)
- When the host shouldn't wait for plugin responses

### Structure

```
Host emits event → Bus delivers to subscribers → Subscribers react independently
```

### TypeScript Example

```typescript
interface TypedEventBus {
  on<E extends keyof EventMap>(event: E, handler: (payload: EventMap[E]) => void): Unsubscribe;
  emit<E extends keyof EventMap>(event: E, payload: EventMap[E]): void;
}

interface EventMap {
  'document:saved': { id: string; version: number };
  'user:login': { userId: string; method: string };
}

// Plugin subscribes
bus.on('document:saved', ({ id, version }) => {
  analytics.track('save', { documentId: id });
});
```

### Pitfalls
- Event storms — one event triggers another triggers another
- Hard to trace causality ("why did X happen?")
- No guaranteed delivery order (by design)
- Memory leaks from unremoved subscriptions

---

## Pattern 3: Middleware Pipeline

Ordered chain of interceptors that wrap a core operation. Each middleware can short-circuit, modify the request/response, or pass through.

### When to Use
- Request/response processing (HTTP servers, CLI commands)
- When plugins need to wrap the core behavior (auth, logging, caching)
- When order is a first-class concern

### Structure

```
Request → MW1 → MW2 → MW3 → Core → MW3 → MW2 → MW1 → Response
```

### TypeScript Example

```typescript
type Middleware<Ctx> = (ctx: Ctx, next: () => Promise<void>) => Promise<void>;

class Pipeline<Ctx> {
  use(middleware: Middleware<Ctx>, options?: { before?: string; after?: string }): void;
  execute(ctx: Ctx): Promise<void>;
}

// Plugin adds middleware
pipeline.use(async (ctx, next) => {
  const start = Date.now();
  await next();
  ctx.response.headers['X-Response-Time'] = `${Date.now() - start}ms`;
});
```

### Go Example

```go
type Middleware func(Handler) Handler
type Handler func(ctx context.Context, req *Request) (*Response, error)

func LoggingMiddleware(next Handler) Handler {
    return func(ctx context.Context, req *Request) (*Response, error) {
        log.Printf("request: %s", req.Path)
        return next(ctx, req)
    }
}
```

### Pitfalls
- Debugging requires tracing through the full stack
- Middleware that forgets to call `next()` silently drops requests
- Order bugs are subtle and hard to reproduce

---

## Pattern 4: Slot/Mount Point

Named regions in the host UI where plugins can inject content.

### When to Use
- UI extensibility (sidebars, toolbars, menus, panels)
- Content injection at defined locations
- When plugins add visible elements to the host interface

### Structure

```
Host defines <Slot name="sidebar" /> → Plugins register components for "sidebar" → Host renders them
```

### React/TypeScript Example

```typescript
interface SlotRegistry {
  register(slotName: string, component: React.ComponentType<SlotProps>, options?: {
    priority?: number;
    when?: (context: AppContext) => boolean;
  }): void;
}

// Host template
<Slot name="sidebar" context={appContext} />

// Plugin registers
slots.register('sidebar', MyWidget, {
  priority: 10,
  when: (ctx) => ctx.currentPage === 'dashboard',
});
```

### Pitfalls
- Layout conflicts when multiple plugins target the same slot
- Conditional rendering logic becomes complex
- Tight coupling to host layout — redesigning the host breaks plugins

---

## Pattern 5: Service Provider

Interface-based registration where plugins provide alternative implementations.

### When to Use
- Swappable backends (storage, auth, email, payment)
- When exactly one implementation should be active per service
- When the host defines the "what" and plugins define the "how"

### Structure

```
Host defines interface → Plugin implements interface → Host resolves via registry
```

### TypeScript Example

```typescript
interface StorageProvider {
  get(key: string): Promise<Buffer | null>;
  put(key: string, data: Buffer): Promise<void>;
  delete(key: string): Promise<void>;
  list(prefix: string): AsyncIterable<string>;
}

// Plugin registers
services.register('storage', S3StorageProvider, {
  priority: 100,
  when: (config) => config.storage.backend === 's3',
});

// Host resolves
const storage = services.resolve<StorageProvider>('storage');
```

### Rust Example

```rust
trait StorageProvider: Send + Sync {
    fn get(&self, key: &str) -> Result<Option<Vec<u8>>>;
    fn put(&self, key: &str, data: &[u8]) -> Result<()>;
    fn delete(&self, key: &str) -> Result<()>;
}

// Plugin registers via inventory crate
inventory::submit! {
    ProviderRegistration::new::<S3Storage>("storage", 100)
}
```

### Pitfalls
- Multiple providers for the same service — need clear resolution strategy
- Interface changes break all providers
- Testing requires mock providers

---

## Pattern 6: AST/IR Transform

Plugins operate on an intermediate representation (source code, configuration, or data structure) before the host processes it.

### When to Use
- Build tools (Babel plugins, webpack loaders, Vite plugins)
- Configuration preprocessing
- Template engines with custom directives
- When plugins need maximum power over the output

### Structure

```
Source → Parse to AST/IR → Plugin transforms → Host processes transformed IR
```

### TypeScript Example (Vite-style)

```typescript
interface TransformPlugin {
  name: string;
  transform?(code: string, id: string): TransformResult | null;
  resolveId?(source: string, importer?: string): string | null;
  load?(id: string): string | null;
}

// Plugin
const myPlugin: TransformPlugin = {
  name: 'auto-import',
  transform(code, id) {
    if (!id.endsWith('.ts')) return null;
    return {
      code: `import { utils } from 'shared';\n${code}`,
      map: null,
    };
  },
};
```

### Pitfalls
- Highest power = highest risk (plugins can do anything to the code)
- Transform ordering is critical and fragile
- Debugging transformed output requires source maps
- Performance — AST parsing/serialization per plugin adds up
