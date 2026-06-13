# Contract Templates

Fillable templates for extension point contracts across languages. Copy the template for your language, fill in the bracketed placeholders, and use as the contract definition for your extension point.

## TypeScript

### Hook Contract

```typescript
/**
 * Extension Point: {{hookName}}
 * Pattern: Hook/Filter
 * API Version: {{version}}
 */

export interface {{HookName}}Context {
  readonly {{contextField1}}: {{Type1}};
  readonly {{contextField2}}: {{Type2}};
}

export interface {{HookName}}Result {
  {{resultField1}}: {{Type1}};
  {{resultField2}}?: {{Type2}};
}

export type {{HookName}}Hook = (
  context: Readonly<{{HookName}}Context>
) => {{HookName}}Result | Promise<{{HookName}}Result> | null;
```

### Event Contract

```typescript
/**
 * Event: {{eventName}}
 * Pattern: Event Bus
 * API Version: {{version}}
 */

export interface {{EventName}}Payload {
  readonly {{field1}}: {{Type1}};
  readonly {{field2}}: {{Type2}};
  readonly timestamp: number;
}
```

### Service Provider Contract

```typescript
/**
 * Service: {{serviceName}}
 * Pattern: Service Provider
 * API Version: {{version}}
 */

export interface {{ServiceName}}Provider {
  readonly name: string;

  {{method1}}({{param}}: {{ParamType}}): Promise<{{ReturnType}}>;
  {{method2}}({{param}}: {{ParamType}}): Promise<{{ReturnType}}>;

  dispose(): Promise<void>;
}
```

### Slot Contract

```typescript
/**
 * Slot: {{slotName}}
 * Pattern: Slot/Mount Point
 * API Version: {{version}}
 */

export interface {{SlotName}}Props {
  readonly {{prop1}}: {{Type1}};
  readonly {{prop2}}: {{Type2}};
}

export interface {{SlotName}}Registration {
  id: string;
  priority?: number;
  when?: (context: AppContext) => boolean;
  render: (props: {{SlotName}}Props) => {{RenderOutput}};
}
```

---

## Python

### Hook Contract

```python
"""
Extension Point: {{hook_name}}
Pattern: Hook/Filter
API Version: {{version}}
"""

from dataclasses import dataclass
from typing import Protocol, Optional

@dataclass(frozen=True)
class {{HookName}}Context:
    {{field1}}: {{type1}}
    {{field2}}: {{type2}}

@dataclass
class {{HookName}}Result:
    {{field1}}: {{type1}}
    {{field2}}: Optional[{{type2}}] = None

class {{HookName}}Hook(Protocol):
    def __call__(self, context: {{HookName}}Context) -> Optional[{{HookName}}Result]: ...
```

### Service Provider Contract

```python
"""
Service: {{service_name}}
Pattern: Service Provider
API Version: {{version}}
"""

from typing import Protocol, AsyncIterator

class {{ServiceName}}Provider(Protocol):
    @property
    def name(self) -> str: ...

    async def {{method1}}(self, {{param}}: {{ParamType}}) -> {{ReturnType}}: ...
    async def {{method2}}(self, {{param}}: {{ParamType}}) -> {{ReturnType}}: ...
    async def dispose(self) -> None: ...
```

---

## Go

### Hook Contract

```go
// Extension Point: {{HookName}}
// Pattern: Hook/Filter
// API Version: {{version}}

type {{HookName}}Context struct {
    {{Field1}} {{type1}}
    {{Field2}} {{type2}}
}

type {{HookName}}Result struct {
    {{Field1}} {{type1}}
    {{Field2}} {{type2}}
}

type {{HookName}}Hook func(ctx context.Context, data {{HookName}}Context) (*{{HookName}}Result, error)
```

### Service Provider Contract

```go
// Service: {{ServiceName}}
// Pattern: Service Provider
// API Version: {{version}}

type {{ServiceName}}Provider interface {
    Name() string
    {{Method1}}(ctx context.Context, {{param}} {{ParamType}}) ({{ReturnType}}, error)
    {{Method2}}(ctx context.Context, {{param}} {{ParamType}}) ({{ReturnType}}, error)
    Close() error
}
```

---

## Rust

### Hook Contract

```rust
/// Extension Point: {{hook_name}}
/// Pattern: Hook/Filter
/// API Version: {{version}}

pub struct {{HookName}}Context {
    pub {{field1}}: {{Type1}},
    pub {{field2}}: {{Type2}},
}

pub struct {{HookName}}Result {
    pub {{field1}}: {{Type1}},
    pub {{field2}}: Option<{{Type2}}>,
}

pub trait {{HookName}}Hook: Send + Sync {
    fn invoke(&self, ctx: &{{HookName}}Context) -> Result<Option<{{HookName}}Result>>;
}
```

### Service Provider Contract

```rust
/// Service: {{service_name}}
/// Pattern: Service Provider
/// API Version: {{version}}

#[async_trait]
pub trait {{ServiceName}}Provider: Send + Sync {
    fn name(&self) -> &str;
    async fn {{method1}}(&self, {{param}}: &{{ParamType}}) -> Result<{{ReturnType}}>;
    async fn {{method2}}(&self, {{param}}: &{{ParamType}}) -> Result<{{ReturnType}}>;
    async fn close(&self) -> Result<()>;
}
```
