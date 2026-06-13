# noizu_labs_services (0.1.2)

Scaffolding for managing millions of long-lived distributed worker processes with load balancing and cluster coordination.

## Installation
```elixir
{:noizu_labs_services, "~> 0.1.2"}
# Pulls in noizu_labs_entities and noizu_labs_core
```

## Pool Architecture

```
Pool (top-level module)
├── PoolSupervisor (OTP root)
│   ├── Server (request dispatcher)
│   ├── WorkerSupervisor (Layer 1)
│   │   ├── WorkerSupervisor.Seg0 (Layer 2)
│   │   ├── WorkerSupervisor.Seg1
│   │   └── ... (fragmented to avoid bottlenecks)
│   └── Registry (process lookup)
├── NodeManager (cross-node coordination)
├── DispatcherRouter (message routing)
└── ClusterManager (cluster-wide health)
```

## Defining a Pool

```elixir
defmodule MyApp.TaskPool do
  use Noizu.Service

  # Required callbacks
  def __pool__(), do: __MODULE__
  def __worker__(), do: MyApp.TaskPool.Worker
  def __server__(), do: MyApp.TaskPool.Server
end
```

## Worker Definition

```elixir
defmodule MyApp.TaskPool.Worker do
  use Noizu.Service.Worker

  # Worker state and behavior
end
```

## Messaging

### Synchronous (s_call!)
```elixir
MyApp.TaskPool.s_call!(ref, message, context, options, timeout)
```
Sends message, waits for response with acknowledgment.

### Asynchronous (s_cast!)
```elixir
MyApp.TaskPool.s_cast!(ref, message, context, options, timeout)
```
Fire-and-forget async dispatch.

### Other Operations
```elixir
MyApp.TaskPool.get_direct_link!(ref, context, options)  # Process link
MyApp.TaskPool.fetch(ref, field, context, options)       # Get worker state
MyApp.TaskPool.ping(ref, context, options)               # Health check
MyApp.TaskPool.wake!(ref, context, options)              # Ensure worker alive
MyApp.TaskPool.kill!(ref, context, options)              # Terminate worker
MyApp.TaskPool.reload!(ref, context, options)            # Reload worker state
```

## Message Types (Records)

```elixir
import Noizu.Service.Types

link()          # Process link record
settings()      # Pool settings
s()             # Service call wrapper
call()          # Call metadata
msg_envelope()  # Message wrapper

# Flags
sticky?(msg)    # Pin to current node?
spawn?(msg)     # Lazy spawn on first use?
ack?(msg)       # Require acknowledgment?
timeout(msg)    # Get timeout value
safe(msg)       # Safe mode flag
task(msg)       # Task reference
```

## Cluster Coordination

### Node Registration
```elixir
MyApp.TaskPool.join_cluster(pid, context, options)
```

### Load Balancing Targets
- **Low:** 500 workers per supervisor segment
- **Target:** 2,500 workers per segment
- **High:** 5,000 workers per segment

New workers are routed to the least-loaded segments.

### Supervision Spec
```elixir
MyApp.TaskPool.spec(context, options)
# Returns child_spec for inclusion in application supervisor
```

### Pool Scopes
```elixir
MyApp.TaskPool.pool_scopes()
# Returns list of all modules in the supervision hierarchy
```

## Key Concepts

1. **Lazy spawning** — Workers created on first `s_call!`/`s_cast!`, not at startup
2. **Fragmented supervision** — Multiple supervisor segments prevent single-supervisor bottleneck
3. **:syn coordination** — Distributed process registry for cross-node worker discovery
4. **NodeManager** — Tracks failures/minute, health metrics, load per node
5. **Graceful migration** — Messages rerouted during worker respawn or node offload
6. **Sticky workers** — Can be pinned to specific nodes when needed

## Worked Example

```elixir
# Define pool
defmodule MyApp.EmailPool do
  use Noizu.Service
  def __pool__(), do: __MODULE__
  def __worker__(), do: MyApp.EmailPool.Worker
  def __server__(), do: MyApp.EmailPool.Server
end

# Add to supervision tree
children = [
  MyApp.EmailPool.spec(Noizu.Context.system(), [])
]
Supervisor.start_link(children, strategy: :one_for_one)

# Send work
ctx = Noizu.Context.system()
ref = {:ref, MyApp.EmailPool.Worker, user_id}
MyApp.EmailPool.s_cast!(ref, {:send_welcome, user}, ctx, [], 5_000)
```
