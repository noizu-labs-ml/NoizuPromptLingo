# Multi-Agent Coordination

## When to Use Multi-Agent vs Single Agent with Tools

| Scenario | Use | Rationale |
|----------|-----|-----------|
| Sequential tool calls, shared context | Single agent | Less overhead, simpler state |
| Parallel independent subtasks | Multi-agent | Concurrency wins |
| Adversarial verification needed | Multi-agent (debate) | Cross-checking reduces errors |
| Domain specialization required | Multi-agent | Specialized system prompts per role |
| Token budget per task is small | Multi-agent | Isolate context windows |
| Audit trail per subtask required | Multi-agent | Isolated traces per agent |
| Simple RAG + generation pipeline | Single agent | Overhead not justified |

**Rule of thumb:** if the task graph has independent branches that don't share mutable state, spawn agents. If it's a linear chain, use tools.

---

## Coordination Patterns

### Supervisor Pattern

A supervisor agent receives the user request, decomposes it, dispatches to worker agents, collects results, and synthesizes the final response. Workers are stateless; the supervisor owns state.

```typescript
interface AgentMessage {
  id: string;
  from: string;
  to: string;
  type: "task" | "result" | "error" | "abort";
  payload: unknown;
  timestamp: number;
  correlationId: string; // links task → result
}

interface WorkerCapability {
  name: string;
  description: string;
  inputSchema: Record<string, unknown>;
  outputSchema: Record<string, unknown>;
}

interface SupervisorConfig {
  workers: WorkerCapability[];
  maxConcurrency: number;
  timeoutMs: number;
  retryPolicy: RetryPolicy;
}

interface RetryPolicy {
  maxAttempts: number;
  backoffMs: number;
  retryableErrors: string[];
}

class SupervisorAgent {
  private inFlight = new Map<string, PendingTask>();

  async dispatch(tasks: AgentTask[]): Promise<AgentMessage[]> {
    const batches = this.batchByConcurrency(tasks);
    const results: AgentMessage[] = [];

    for (const batch of batches) {
      const batchResults = await Promise.allSettled(
        batch.map((task) => this.dispatchOne(task))
      );
      results.push(...this.collectResults(batchResults));
    }

    return results;
  }

  private async dispatchOne(task: AgentTask): Promise<AgentMessage> {
    const msg: AgentMessage = {
      id: crypto.randomUUID(),
      from: "supervisor",
      to: task.workerName,
      type: "task",
      payload: task.input,
      timestamp: Date.now(),
      correlationId: task.correlationId,
    };
    return this.send(msg);
  }
}
```

### Swarm Pattern

No central supervisor. Agents self-organize via a shared message bus. Each agent subscribes to topic filters and publishes results. Emergent coordination — better for open-ended tasks where decomposition is unknown upfront.

```typescript
interface SwarmBus {
  publish(topic: string, message: AgentMessage): Promise<void>;
  subscribe(
    agentId: string,
    topicFilter: string,
    handler: MessageHandler
  ): Unsubscribe;
  getBacklog(topic: string, since: number): Promise<AgentMessage[]>;
}

type MessageHandler = (msg: AgentMessage) => Promise<void>;
type Unsubscribe = () => void;

interface SwarmAgent {
  id: string;
  capabilities: string[]; // topic prefixes this agent handles
  systemPrompt: string;
  handleMessage(msg: AgentMessage, bus: SwarmBus): Promise<void>;
}

// Agents claim work by publishing to a "claimed" subtopic before starting
// Prevents duplicate work in swarms without a coordinator
async function claimWork(
  bus: SwarmBus,
  agentId: string,
  taskId: string
): Promise<boolean> {
  const claimMsg: AgentMessage = {
    id: crypto.randomUUID(),
    from: agentId,
    to: "swarm",
    type: "task",
    payload: { claim: taskId },
    timestamp: Date.now(),
    correlationId: taskId,
  };
  // Real impl: use Redis SETNX or similar for atomic claim
  await bus.publish(`claims.${taskId}`, claimMsg);
  const backlog = await bus.getBacklog(`claims.${taskId}`, 0);
  return backlog[0].from === agentId; // first claim wins
}
```

### Debate Pattern

Two or more agents generate independent responses; a judge agent evaluates and selects or synthesizes. Effective for factual tasks, code review, security analysis.

```typescript
interface DebateConfig {
  debaters: DebaterConfig[];
  judge: JudgeConfig;
  rounds: number; // 1 = single response + judge; 2+ = rebuttal rounds
  topic: string;
}

interface DebaterConfig {
  id: string;
  systemPrompt: string;
  temperature: number;
  // Optionally give debaters different tool access
  tools?: ToolDefinition[];
}

interface JudgeConfig {
  systemPrompt: string;
  rubric: string; // injected into judge prompt
  outputSchema: Record<string, unknown>;
}

interface DebateRound {
  round: number;
  positions: Map<string, string>; // debaterId → response
  judgment?: JudgeVerdict;
}

interface JudgeVerdict {
  winner?: string;
  synthesis?: string;
  reasoning: string;
  confidence: number; // 0-1
}

async function runDebate(
  config: DebateConfig,
  question: string
): Promise<JudgeVerdict> {
  const rounds: DebateRound[] = [];

  for (let r = 0; r < config.rounds; r++) {
    const positions = new Map<string, string>();
    const prior = rounds.at(-1)?.positions;

    await Promise.all(
      config.debaters.map(async (d) => {
        const context = prior
          ? `Prior responses:\n${[...prior.entries()].map(([id, p]) => `[${id}]: ${p}`).join("\n")}`
          : "";
        const response = await callAgent(d, question, context);
        positions.set(d.id, response);
      })
    );

    rounds.push({ round: r, positions });
  }

  return judgeRounds(config.judge, rounds, question);
}
```

---

## Shared State Management

Agents must not mutate shared state concurrently without coordination. Options:

| Strategy | Best for | Tradeoffs |
|----------|----------|-----------|
| Immutable message passing | Most cases | Safe, traceable; no shared objects |
| Optimistic locking | Low-contention KV store | Fast reads; retry on conflict |
| Event sourcing | Audit-critical workflows | Full history; replay capability |
| CRDT-based state | Distributed agent notes | Merge-safe; complex to implement |

```typescript
// Event sourcing: agents append events, never mutate state directly
interface AgentEvent {
  id: string;
  agentId: string;
  type: string;
  data: unknown;
  timestamp: number;
  version: number; // monotonic per stream
}

interface EventStore {
  append(streamId: string, event: AgentEvent, expectedVersion: number): Promise<void>;
  read(streamId: string, fromVersion?: number): AsyncIterable<AgentEvent>;
  snapshot(streamId: string): Promise<{ state: unknown; version: number }>;
}
```

---

## Agent Lifecycle Management

```typescript
type AgentStatus = "idle" | "running" | "paused" | "error" | "complete" | "aborted";

interface AgentLifecycle {
  agentId: string;
  status: AgentStatus;
  startedAt?: number;
  completedAt?: number;
  errorCount: number;
  lastError?: string;
  tokenUsage: { input: number; output: number };
  costUsd: number;
}

interface LifecycleManager {
  spawn(config: AgentConfig): Promise<string>; // returns agentId
  pause(agentId: string): Promise<void>;
  resume(agentId: string): Promise<void>;
  abort(agentId: string, reason: string): Promise<void>;
  getStatus(agentId: string): Promise<AgentLifecycle>;
  waitForCompletion(agentId: string, timeoutMs: number): Promise<AgentLifecycle>;
  // Drain: wait for current task to finish, then stop accepting new ones
  drain(agentId: string): Promise<void>;
}
```

---

## Deadlock Prevention

Circular dependencies between agents (A waits for B, B waits for A) are the primary deadlock risk.

**Prevention checklist:**
1. Assign a strict partial order to agent roles — higher-tier agents may not wait on lower-tier results without a timeout
2. Use async message passing, never synchronous RPC between peer agents
3. Set per-agent and per-pipeline timeouts; never `await` indefinitely
4. Detect cycles in the task dependency graph before dispatching
5. Implement a watchdog that aborts stalled agents after `maxIdleMs`

```typescript
function detectCycle(deps: Map<string, string[]>): string[] | null {
  const visited = new Set<string>();
  const stack = new Set<string>();

  function dfs(node: string): string[] | null {
    visited.add(node);
    stack.add(node);
    for (const neighbor of deps.get(node) ?? []) {
      if (!visited.has(neighbor)) {
        const cycle = dfs(neighbor);
        if (cycle) return cycle;
      } else if (stack.has(neighbor)) {
        return [node, neighbor]; // cycle found
      }
    }
    stack.delete(node);
    return null;
  }

  for (const node of deps.keys()) {
    if (!visited.has(node)) {
      const cycle = dfs(node);
      if (cycle) return cycle;
    }
  }
  return null;
}
```

---

## Communication Protocol Summary

```typescript
// Full protocol types for inter-agent communication
export type { AgentMessage, AgentLifecycle, SwarmBus, DebateConfig, JudgeVerdict };

// Message type registry
export const MESSAGE_TYPES = {
  TASK: "task",
  RESULT: "result",
  ERROR: "error",
  ABORT: "abort",
  HEARTBEAT: "heartbeat",
  CLAIM: "claim",
  RELEASE: "release",
} as const;
```

All messages must include `correlationId` for tracing. Log every message at DEBUG level. Emit span events on task dispatch and result receipt (see `observability-guide.md`).
