# US-261: Server Scalability Architecture

**Persona:** Dave — MUD veteran sysadmin who has seen what happens when a game goes viral unprepared
**Priority:** P0
**Epic:** Admin, GM & Infrastructure

## Story
As Dave, I want the server architecture to scale horizontally across nodes — distributing player, room, and AI processes — so that a viral moment or scheduled large-scale event doesn't bring the game down, and so I can add capacity without changing code.

## Acceptance Criteria
- [ ] Player session processes (GenServers) are distributed across OTP nodes via Erlang Distribution; new nodes can join the cluster without restarting existing nodes; player sessions are not pinned to a specific node and can be migrated on node departure
- [ ] Room processes are distributed based on geographic clustering (rooms in the same region colocated where possible) to minimize cross-node message passing; room process registry uses distributed Horde.Registry and Horde.DynamicSupervisor for fault tolerance across node boundaries
- [ ] Phoenix Channels WebSocket connections are handled by a load balancer with sticky sessions per connection; multiple Phoenix nodes run behind the load balancer; if a node fails, affected WebSocket clients reconnect automatically (client-side reconnect logic with exponential backoff, max 5 attempts)
- [ ] LLM narrative generation (AI calls) is isolated to a dedicated process pool; pool size configurable via environment variable; AI process failures are isolated and do not affect game loop; fallback narratives (static templates) are served if AI pool is saturated or unavailable
- [ ] Database connections managed via PgBouncer connection pooling; read replicas available for analytics queries (US-260) and read-heavy operations (profile lookups, bulletin board browsing); write operations always go to primary; replica lag monitored and alarmed if exceeding 5 seconds
- [ ] Load testing: system must demonstrate handling of 10,000 simultaneous WebSocket connections with p99 message delivery latency under 100ms on target hardware; load test results documented and included in release sign-off
- [ ] Horizontal scaling is capacity-only: adding nodes increases capacity but does not require code changes, config file edits (beyond node address registration), or downtime; scale-up and scale-down tested in staging before each production deploy
- [ ] BEAM cluster metrics exposed to Prometheus: node count, process count per node, message queue depths, memory per node, scheduler utilization; Grafana dashboards for cluster health (used by Dave's monitoring infrastructure)

## Notes
Dave's nightmare scenario: the game gets featured on a popular accessibility or gaming YouTube channel, 50,000 people try to sign up in 24 hours, and the server falls over. The scalability architecture must be designed for this scenario, not the quiet Tuesday evening scenario.

The Elixir/OTP/BEAM choice is fundamentally correct for this use case — the BEAM VM was designed for massively concurrent distributed systems. Dave knows this. The risk is not the platform choice but the application-level design: using global state, single-process bottlenecks, or database queries in hot paths. Every shared state location needs to be identified and stress-tested.

Horde for distributed process registry is the right choice over built-in Registry (which is node-local). Horde.DynamicSupervisor allows room and player processes to be supervised across the cluster. The key failure mode to test: a node drops out of the cluster mid-session. Players on that node should reconnect to a surviving node and find their session state restored from the database checkpoint (not the in-memory process state, which is lost).

Session state persistence strategy: player GenServer state is checkpointed to the database every 30 seconds and on graceful shutdown. On node departure (ungraceful), the last checkpoint is used to restore the session on reconnect. Players lose at most 30 seconds of progress on a node crash — this is acceptable and should be disclosed in game documentation.

The LLM process isolation is critical. AI narrative generation involves external HTTP calls with unpredictable latency (50ms to 5 seconds). If these calls block player processes, combat narration and movement acknowledgment are delayed. The AI pool must be a separate supervision tree with its own bounded queue; if the queue is full, the static fallback fires immediately rather than making the player wait. This is the correct degraded-mode behavior.

WebSocket sticky sessions via load balancer are necessary because Phoenix Channels uses stateful WebSocket connections. The load balancer (HAProxy or nginx) should use consistent hashing on session token for stickiness, not just IP (which fails on mobile networks that change IPs). On node failure, affected clients get a "reconnecting" message in the UI and are routed to a healthy node.

For the Kubernetes deployment: each Phoenix node runs as a Kubernetes Deployment with HPA (horizontal pod autoscaler) configured on CPU and custom BEAM metrics (queue depth). The KEDA integration (visible in the helm infra) is the right tool for queue-depth-based scaling.
