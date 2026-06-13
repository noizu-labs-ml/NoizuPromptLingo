# noizu_labs_core (0.1.7)

Foundation module providing the EntityReference Protocol (ERP), Context system, and shared Erlang records. Every other Noizu library depends on this.

---

## Installation

```elixir
{:noizu_labs_core, "~> 0.1.7"}
```

---

## Quick Start

```elixir
use Noizu.Core
# Pulls in: EntityReference.Protocol, Records, Context helpers
```

---

## EntityReference Protocol (ERP)

The ERP is the identity backbone of the Noizu ecosystem. It provides a polymorphic interface that lets any representation of an entity — a raw ID, a tuple ref, a string ref, or a full struct — be normalized to any other form without the caller caring about the source type.

`@fallback_to_any true` is set on the protocol, so unknown types degrade gracefully rather than raising.

### Protocol Definition

```elixir
@spec id(subject)     :: {:ok, any}        | {:error, any}
@spec kind(subject)   :: {:ok, atom}       | {:error, any}
@spec ref(subject)    :: {:ok, ref(module: atom, id: any)} | {:error, any}
@spec sref(subject)   :: {:ok, String.t()} | {:error, any}
@spec entity(subject, context) :: {:ok, any} | {:error, any}
```

| Function | Returns | Description |
|----------|---------|-------------|
| `id/1` | bare identifier | Extract the raw ID (integer, UUID, atom, etc.) |
| `kind/1` | module atom | Get the entity's type module |
| `ref/1` | `ref(module:, id:)` record | Erlang record tuple reference |
| `sref/1` | `"ref.my-entity.123"` | Human-readable / storable string reference |
| `entity/2` | full struct | Materialize the entity, loading from DB if needed |

### Implementing ERP for a Custom Struct

```elixir
defimpl Noizu.EntityReference.Protocol, for: MyApp.User do
  def id(%{id: id}),   do: {:ok, id}
  def kind(_),         do: {:ok, MyApp.User}
  def ref(%{id: id}),  do: {:ok, ref(module: MyApp.User, id: id)}
  def sref(%{id: id}), do: {:ok, "ref.user.#{id}"}
  def entity(subject, _context), do: {:ok, subject}
end
```

For a reference tuple that needs to load from the database:

```elixir
defimpl Noizu.EntityReference.Protocol, for: Noizu.EntityReference.Records.Ref do
  def entity(ref(module: mod, id: id), context) do
    mod.entity(id, context)
  end
  # ... other callbacks delegate to module
end
```

### Using ERP in Application Code

```elixir
alias Noizu.EntityReference.Protocol, as: ERP

# Works on a struct, a ref record, a string ref, or a bare ID
{:ok, id}     = ERP.id(anything)
{:ok, kind}   = ERP.kind(anything)
{:ok, ref}    = ERP.ref(anything)
{:ok, sref}   = ERP.sref(anything)
{:ok, entity} = ERP.entity(anything, context)
```

---

## Context System

A lightweight request context record threaded through every service call. Carries the caller identity, timestamp, role set, and an options map — enabling auth checks, audit logging, and per-call behavioral flags without process dictionary abuse.

### Context Record Fields

```elixir
context(
  caller:  term,          # who is making the call (user ref, system atom, etc.)
  ts:      DateTime.t(),  # when the context was created
  roles:   MapSet.t(),    # set of role atoms granted to this context
  options: map            # arbitrary per-call flags
)
```

### Pre-built Context Constructors

```elixir
Noizu.Context.restricted()   # empty roles — minimal permissions
Noizu.Context.admin()        # :admin role — elevated access
Noizu.Context.system()       # :system role — internal infrastructure calls
Noizu.Context.internal()     # :internal role — cross-service calls
```

Use `admin()` in tests and seeds. Use `system()` / `internal()` for background jobs and inter-service calls. Use `restricted()` as the default when no auth context is available.

### Mutating Context

```elixir
# Add a single option flag
ctx = Noizu.Context.with_option(ctx, :trace, true)
ctx = Noizu.Context.with_option(ctx, :dry_run, true)

# Add multiple options at once
ctx = Noizu.Context.with_options(ctx, trace: true, dry_run: true)
```

### Reading Context Options

```elixir
# Returns {:ok, value} | {:error, :not_found}
Noizu.Context.option(ctx, :trace)

# Returns value or default
Noizu.Context.option(ctx, :trace, false)
```

---

## Records Module

Both ERP and Context use Erlang records for their core structs — zero overhead, pattern-matchable in function heads.

```elixir
# In Noizu.EntityReference.Records
record ref(module: atom, id: any)

# In Noizu.Context.Records
record context(caller: term, ts: DateTime.t(), roles: MapSet.t(), options: map)
```

Import them for pattern matching:

```elixir
require Noizu.EntityReference.Records
import  Noizu.EntityReference.Records, only: [ref: 1, ref: 2]

require Noizu.Context.Records
import  Noizu.Context.Records, only: [context: 1, context: 4]

# Now usable in heads:
def process(ref(module: MyApp.User, id: id), context(roles: roles)) do
  ...
end
```

---

## Key Design Concepts

1. **ERP is the universal identity layer** — every entity across the stack implements it so cross-system references are always resolvable without knowing the source type.
2. **Context flows everywhere** — pass it as the last argument to every service function. Never reach for the process dictionary.
3. **Records are lightweight** — they compile to Erlang tuples, enabling pattern matching in function heads with no struct overhead.
4. **`@fallback_to_any true`** — ERP calls on unknown types return `{:error, :not_supported}` rather than raising. Guard at the boundary, not mid-stack.
5. **sref is for storage and logs** — use string refs in database foreign-key fields and log messages; use `ref()` records in-memory.

---

## Common Patterns

```elixir
alias Noizu.EntityReference.Protocol, as: ERP

# Normalize any entity form to its ID
{:ok, id} = ERP.id(user_or_ref_or_sref)

# Build a context for a background job
ctx = Noizu.Context.system()
ctx = Noizu.Context.with_option(ctx, :job_id, job.id)

# Pass context through service layers
MyApp.EmailService.send_welcome(user, ctx)

# Pattern match on ref in a function head
def load(ref(module: mod, id: id), ctx) do
  mod.get(id, ctx)
end

# Check roles at a service boundary
context(roles: roles) = ctx
if :admin in roles do
  # elevated path
end
```
