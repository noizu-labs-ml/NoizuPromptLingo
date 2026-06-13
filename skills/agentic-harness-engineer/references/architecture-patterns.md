# Agentic Architecture Patterns

## Overview

Comprehensive catalog of agentic architecture patterns with selection criteria, TypeScript implementations, trade-offs, and composition rules. Each pattern solves a distinct class of problem — select based on task complexity, safety requirements, cost sensitivity, and latency tolerance.

---

## 1. Single-Turn Tool Use

The simplest agentic pattern: one LLM call, one optional tool invocation, one response. No loop, no state, no planning.

### When to Use
- Deterministic tasks with a clear single action (lookup, transform, classify)
- API wrappers where the action is known before the call
- Low-latency requirements where a loop is prohibitive
- Pipelines where the orchestrating system manages control flow

### Limitations
- Cannot reason across multiple steps
- No error recovery — if the tool fails, the response fails
- Cannot refine based on intermediate results

### TypeScript Implementation

```typescript
import Anthropic from "@anthropic-ai/sdk";

interface Tool {
  name: string;
  description: string;
  input_schema: {
    type: "object";
    properties: Record<string, { type: string; description: string }>;
    required: string[];
  };
}

interface ToolResult {
  type: "tool_result";
  tool_use_id: string;
  content: string;
}

async function singleTurnToolUse(
  client: Anthropic,
  userMessage: string,
  tools: Tool[],
  toolHandlers: Record<string, (input: Record<string, unknown>) => Promise<string>>
): Promise<string> {
  const response = await client.messages.create({
    model: "claude-sonnet-4-5",
    max_tokens: 1024,
    tools,
    messages: [{ role: "user", content: userMessage }],
  });

  if (response.stop_reason === "tool_use") {
    const toolUseBlock = response.content.find((b) => b.type === "tool_use");
    if (!toolUseBlock || toolUseBlock.type !== "tool_use") {
      throw new Error("Expected tool_use block not found");
    }

    const handler = toolHandlers[toolUseBlock.name];
    if (!handler) {
      throw new Error(`No handler registered for tool: ${toolUseBlock.name}`);
    }

    const toolResult = await handler(toolUseBlock.input as Record<string, unknown>);

    const finalResponse = await client.messages.create({
      model: "claude-sonnet-4-5",
      max_tokens: 1024,
      tools,
      messages: [
        { role: "user", content: userMessage },
        { role: "assistant", content: response.content },
        {
          role: "user",
          content: [
            {
              type: "tool_result",
              tool_use_id: toolUseBlock.id,
              content: toolResult,
            } as ToolResult,
          ],
        },
      ],
    });

    return finalResponse.content
      .filter((b) => b.type === "text")
      .map((b) => (b.type === "text" ? b.text : ""))
      .join("");
  }

  return response.content
    .filter((b) => b.type === "text")
    .map((b) => (b.type === "text" ? b.text : ""))
    .join("");
}
```

---

## 2. ReAct Loop (Reason + Act)

The standard agent loop: **Reason** about what to do, **Act** by calling a tool, **Observe** the result, repeat until done or a termination condition triggers.

### When to Use
- Multi-step tasks where each step informs the next
- Tasks requiring exploration (file system navigation, API discovery)
- Research and retrieval tasks with uncertain depth
- Debugging workflows

### Termination Conditions
1. Model returns `stop_reason: "end_turn"` without a tool call
2. Max iterations exceeded
3. Token/cost budget exhausted
4. Stuck detection: same tool called with same args N times

### TypeScript Implementation

```typescript
import Anthropic from "@anthropic-ai/sdk";

interface ReActConfig {
  maxIterations: number;
  maxTokensPerStep: number;
  stuckDetectionWindow: number;
  systemPrompt?: string;
}

interface StepRecord {
  toolName: string;
  inputHash: string;
}

function hashInput(input: unknown): string {
  return JSON.stringify(input);
}

function isStuck(history: StepRecord[], window: number): boolean {
  if (history.length < window) return false;
  const recent = history.slice(-window);
  const first = recent[0];
  return recent.every(
    (s) => s.toolName === first.toolName && s.inputHash === first.inputHash
  );
}

async function reactLoop(
  client: Anthropic,
  userMessage: string,
  tools: Anthropic.Tool[],
  toolHandlers: Record<string, (input: Record<string, unknown>) => Promise<string>>,
  config: ReActConfig
): Promise<{ result: string; iterations: number; terminated: string }> {
  const messages: Anthropic.MessageParam[] = [
    { role: "user", content: userMessage },
  ];

  const stepHistory: StepRecord[] = [];
  let iterations = 0;

  while (iterations < config.maxIterations) {
    iterations++;

    const response = await client.messages.create({
      model: "claude-sonnet-4-5",
      max_tokens: config.maxTokensPerStep,
      system: config.systemPrompt,
      tools,
      messages,
    });

    messages.push({ role: "assistant", content: response.content });

    if (response.stop_reason === "end_turn") {
      const text = response.content
        .filter((b) => b.type === "text")
        .map((b) => (b.type === "text" ? b.text : ""))
        .join("");
      return { result: text, iterations, terminated: "end_turn" };
    }

    if (response.stop_reason !== "tool_use") {
      return {
        result: "Unexpected stop reason: " + response.stop_reason,
        iterations,
        terminated: "unexpected_stop",
      };
    }

    const toolUseBlocks = response.content.filter((b) => b.type === "tool_use");
    const toolResults: Anthropic.ToolResultBlockParam[] = [];

    for (const block of toolUseBlocks) {
      if (block.type !== "tool_use") continue;

      const record: StepRecord = {
        toolName: block.name,
        inputHash: hashInput(block.input),
      };
      stepHistory.push(record);

      if (isStuck(stepHistory, config.stuckDetectionWindow)) {
        return {
          result: `Agent stuck: repeated ${block.name} with same inputs`,
          iterations,
          terminated: "stuck",
        };
      }

      const handler = toolHandlers[block.name];
      let resultContent: string;

      if (!handler) {
        resultContent = `Error: No handler for tool "${block.name}"`;
      } else {
        try {
          resultContent = await handler(block.input as Record<string, unknown>);
        } catch (err) {
          resultContent = `Error executing ${block.name}: ${err instanceof Error ? err.message : String(err)}`;
        }
      }

      toolResults.push({
        type: "tool_result",
        tool_use_id: block.id,
        content: resultContent,
      });
    }

    messages.push({ role: "user", content: toolResults });
  }

  return {
    result: "Max iterations exceeded",
    iterations,
    terminated: "max_iterations",
  };
}
```

---

## 3. Plan-and-Execute

Two-phase architecture: a **Planner** LLM decomposes the goal into ordered steps, then an **Executor** LLM (or the same model in a loop) runs each step independently.

### When to Use
- Complex multi-step tasks where the full plan can be known upfront
- Tasks requiring sequential dependencies (step 3 needs output of step 2)
- Debugging or auditing — the plan is human-readable before execution
- Cost control — you can review the plan before spending execution budget

### Immutable vs Adaptive Plans
- **Immutable**: plan is fixed; executor raises errors but does not replan. Good for compliance, reproducibility.
- **Adaptive**: executor can signal re-plan needed; planner regenerates from current context. Good for exploratory tasks.

### TypeScript Implementation

```typescript
import Anthropic from "@anthropic-ai/sdk";

interface ExecutionStep {
  id: string;
  description: string;
  tool?: string;
  dependsOn: string[];
  status: "pending" | "running" | "done" | "failed";
  result?: string;
  error?: string;
}

interface Plan {
  goal: string;
  steps: ExecutionStep[];
  adaptive: boolean;
}

async function generatePlan(
  client: Anthropic,
  goal: string,
  availableTools: string[]
): Promise<Plan> {
  const response = await client.messages.create({
    model: "claude-opus-4-5",
    max_tokens: 2048,
    system: `You are a planning agent. Given a goal and available tools, produce a JSON execution plan.
Available tools: ${availableTools.join(", ")}

Respond ONLY with valid JSON matching this schema:
{
  "goal": string,
  "steps": [{ "id": string, "description": string, "tool": string | null, "dependsOn": string[] }],
  "adaptive": boolean
}`,
    messages: [{ role: "user", content: goal }],
  });

  const text = response.content
    .filter((b) => b.type === "text")
    .map((b) => (b.type === "text" ? b.text : ""))
    .join("");

  const parsed = JSON.parse(text) as Omit<Plan, "steps"> & {
    steps: Omit<ExecutionStep, "status">[];
  };

  return {
    ...parsed,
    steps: parsed.steps.map((s) => ({ ...s, status: "pending" as const })),
  };
}

async function executeStep(
  client: Anthropic,
  step: ExecutionStep,
  completedResults: Record<string, string>,
  tools: Anthropic.Tool[],
  toolHandlers: Record<string, (input: Record<string, unknown>) => Promise<string>>
): Promise<string> {
  const context = step.dependsOn
    .map((id) => `Result of step ${id}: ${completedResults[id] ?? "not available"}`)
    .join("\n");

  const messages: Anthropic.MessageParam[] = [
    {
      role: "user",
      content: `Execute this step: ${step.description}\n\nContext from prior steps:\n${context}`,
    },
  ];

  const response = await client.messages.create({
    model: "claude-sonnet-4-5",
    max_tokens: 1024,
    tools,
    messages,
  });

  if (response.stop_reason === "tool_use") {
    const toolBlock = response.content.find((b) => b.type === "tool_use");
    if (toolBlock && toolBlock.type === "tool_use") {
      const handler = toolHandlers[toolBlock.name];
      if (handler) {
        const result = await handler(toolBlock.input as Record<string, unknown>);
        return result;
      }
    }
  }

  return response.content
    .filter((b) => b.type === "text")
    .map((b) => (b.type === "text" ? b.text : ""))
    .join("");
}

async function planAndExecute(
  client: Anthropic,
  goal: string,
  tools: Anthropic.Tool[],
  toolHandlers: Record<string, (input: Record<string, unknown>) => Promise<string>>
): Promise<{ plan: Plan; results: Record<string, string> }> {
  const availableToolNames = tools.map((t) => t.name);
  const plan = await generatePlan(client, goal, availableToolNames);
  const results: Record<string, string> = {};

  for (const step of plan.steps) {
    const depsComplete = step.dependsOn.every((id) => results[id] !== undefined);
    if (!depsComplete) {
      step.status = "failed";
      step.error = `Dependencies not satisfied: ${step.dependsOn.filter((id) => !results[id]).join(", ")}`;
      if (!plan.adaptive) throw new Error(step.error);
      continue;
    }

    step.status = "running";
    try {
      const result = await executeStep(client, step, results, tools, toolHandlers);
      step.status = "done";
      step.result = result;
      results[step.id] = result;
    } catch (err) {
      step.status = "failed";
      step.error = err instanceof Error ? err.message : String(err);
      if (!plan.adaptive) throw err;
    }
  }

  return { plan, results };
}
```

---

## 4. Router Pattern

A **Classifier** agent routes incoming requests to specialized handlers. Each handler is optimized for a specific task domain.

### When to Use
- Multi-domain chatbots where each domain needs different tools/prompts
- Cost optimization: route simple tasks to cheaper models, complex tasks to expensive ones
- Safety partitioning: route sensitive requests to a hardened handler
- Scalability: each route scales independently

### Static vs LLM-Based Routing
- **Static routes**: regex/keyword matching. Zero latency, no cost, no hallucination. Use when categories are well-defined.
- **LLM-based routing**: model classifies the request. Handles ambiguity and novel phrasing. Use when categories are fuzzy.

### TypeScript Implementation

```typescript
import Anthropic from "@anthropic-ai/sdk";

type RouteId = string;

interface Route {
  id: RouteId;
  name: string;
  description: string;
  keywords?: string[];
  handler: (client: Anthropic, message: string) => Promise<string>;
}

interface RouterConfig {
  routes: Route[];
  fallbackRouteId: RouteId;
  useStaticRouting: boolean;
}

function staticRoute(message: string, routes: Route[]): RouteId | null {
  const lower = message.toLowerCase();
  for (const route of routes) {
    if (route.keywords?.some((kw) => lower.includes(kw.toLowerCase()))) {
      return route.id;
    }
  }
  return null;
}

async function llmRoute(
  client: Anthropic,
  message: string,
  routes: Route[]
): Promise<RouteId> {
  const routeDescriptions = routes
    .map((r) => `- ${r.id}: ${r.description}`)
    .join("\n");

  const response = await client.messages.create({
    model: "claude-haiku-4-5",
    max_tokens: 64,
    system: `You are a routing classifier. Given a user message, respond with ONLY the route ID that best matches.

Available routes:
${routeDescriptions}

Respond with only the route ID, nothing else.`,
    messages: [{ role: "user", content: message }],
  });

  const routeId = response.content
    .filter((b) => b.type === "text")
    .map((b) => (b.type === "text" ? b.text.trim() : ""))
    .join("")
    .trim();

  const validIds = new Set(routes.map((r) => r.id));
  return validIds.has(routeId) ? routeId : routes[0].id;
}

async function routerAgent(
  client: Anthropic,
  message: string,
  config: RouterConfig
): Promise<{ routeId: RouteId; result: string }> {
  const routeMap = new Map(config.routes.map((r) => [r.id, r]));

  let selectedRouteId: RouteId;

  if (config.useStaticRouting) {
    selectedRouteId =
      staticRoute(message, config.routes) ?? config.fallbackRouteId;
  } else {
    try {
      selectedRouteId = await llmRoute(client, message, config.routes);
    } catch {
      selectedRouteId = config.fallbackRouteId;
    }
  }

  const route = routeMap.get(selectedRouteId) ?? routeMap.get(config.fallbackRouteId);
  if (!route) throw new Error(`No handler for route: ${selectedRouteId}`);

  const result = await route.handler(client, message);
  return { routeId: selectedRouteId, result };
}
```

---

## 5. Supervisor Pattern

A **Supervisor** agent maintains high-level state and delegates subtasks to specialized **Sub-agents**. The supervisor aggregates results and handles conflicts.

### When to Use
- Tasks requiring coordination across distinct capability domains
- When sub-tasks have different risk profiles (supervisor can gate dangerous sub-agents)
- Multi-step workflows where dependencies between agents are complex
- When you need a single coherent response from disparate specialists

### Preventing Infinite Delegation
- Max delegation depth (supervisor cannot delegate to another supervisor)
- Sub-agent call budget per request
- Circuit breaker: if sub-agent fails N times, supervisor handles directly

### TypeScript Implementation

```typescript
import Anthropic from "@anthropic-ai/sdk";

interface SubAgent {
  id: string;
  name: string;
  capabilities: string;
  execute: (task: string, context: string) => Promise<string>;
}

interface DelegationRecord {
  agentId: string;
  task: string;
  result: string;
  timestamp: number;
}

interface SupervisorState {
  goal: string;
  delegations: DelegationRecord[];
  depth: number;
  maxDepth: number;
}

function buildSubAgentTools(subAgents: SubAgent[]): Anthropic.Tool[] {
  return subAgents.map((agent) => ({
    name: `delegate_to_${agent.id}`,
    description: `Delegate a task to ${agent.name}. Capabilities: ${agent.capabilities}`,
    input_schema: {
      type: "object" as const,
      properties: {
        task: {
          type: "string",
          description: "The specific task to delegate",
        },
        context: {
          type: "string",
          description: "Relevant context the sub-agent needs",
        },
      },
      required: ["task"],
    },
  }));
}

async function supervisorAgent(
  client: Anthropic,
  goal: string,
  subAgents: SubAgent[],
  maxDelegations: number = 10
): Promise<{ result: string; delegations: DelegationRecord[] }> {
  const state: SupervisorState = {
    goal,
    delegations: [],
    depth: 0,
    maxDepth: 3,
  };

  const subAgentMap = new Map(subAgents.map((a) => [a.id, a]));
  const tools = buildSubAgentTools(subAgents);

  const messages: Anthropic.MessageParam[] = [
    {
      role: "user",
      content: `Goal: ${goal}\n\nCoordinate your sub-agents to achieve this goal. Synthesize their outputs into a coherent final response.`,
    },
  ];

  let delegationCount = 0;

  while (delegationCount < maxDelegations) {
    const response = await client.messages.create({
      model: "claude-sonnet-4-5",
      max_tokens: 2048,
      system: `You are a supervisor agent. Coordinate specialized sub-agents to achieve goals. 
Always synthesize sub-agent outputs — never pass raw sub-agent output directly to the user.`,
      tools,
      messages,
    });

    messages.push({ role: "assistant", content: response.content });

    if (response.stop_reason === "end_turn") {
      const result = response.content
        .filter((b) => b.type === "text")
        .map((b) => (b.type === "text" ? b.text : ""))
        .join("");
      return { result, delegations: state.delegations };
    }

    const toolUseBlocks = response.content.filter((b) => b.type === "tool_use");
    const toolResults: Anthropic.ToolResultBlockParam[] = [];

    for (const block of toolUseBlocks) {
      if (block.type !== "tool_use") continue;

      const agentId = block.name.replace("delegate_to_", "");
      const agent = subAgentMap.get(agentId);

      let resultContent: string;

      if (!agent) {
        resultContent = `Error: Unknown sub-agent "${agentId}"`;
      } else {
        delegationCount++;
        const input = block.input as { task: string; context?: string };

        try {
          resultContent = await agent.execute(
            input.task,
            input.context ?? ""
          );
          state.delegations.push({
            agentId,
            task: input.task,
            result: resultContent,
            timestamp: Date.now(),
          });
        } catch (err) {
          resultContent = `Sub-agent ${agentId} failed: ${err instanceof Error ? err.message : String(err)}`;
        }
      }

      toolResults.push({
        type: "tool_result",
        tool_use_id: block.id,
        content: resultContent,
      });
    }

    messages.push({ role: "user", content: toolResults });
  }

  return {
    result: "Max delegations exceeded",
    delegations: state.delegations,
  };
}
```

---

## 6. Swarm Pattern

Independent sub-tasks execute **in parallel** and results are aggregated. Fan-out distributes work; fan-in collects and synthesizes.

### When to Use
- Tasks decomposable into independent parallel chunks (analyze 10 documents simultaneously)
- Latency-sensitive pipelines where sequential would be too slow
- Redundancy: multiple agents attempt the same task, take the best result

### Partial Failure Handling
- `Promise.allSettled` over `Promise.all` — never abort all work due to one failure
- Minimum quorum: require N of M to succeed before synthesis
- Fallback: if agent fails, retry with a different model or simpler prompt

### TypeScript Implementation

```typescript
import Anthropic from "@anthropic-ai/sdk";

interface SwarmTask {
  id: string;
  input: string;
  metadata?: Record<string, unknown>;
}

interface SwarmResult {
  taskId: string;
  output: string;
  success: boolean;
  error?: string;
  durationMs: number;
}

interface SwarmConfig {
  maxConcurrency: number;
  timeoutMs: number;
  minimumSuccessQuorum: number;
  agentSystemPrompt: string;
  synthesisSystemPrompt: string;
}

async function runSwarmAgent(
  client: Anthropic,
  task: SwarmTask,
  config: SwarmConfig
): Promise<SwarmResult> {
  const start = Date.now();

  const timeoutPromise = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new Error("Timeout")), config.timeoutMs)
  );

  const workPromise = client.messages.create({
    model: "claude-haiku-4-5",
    max_tokens: 1024,
    system: config.agentSystemPrompt,
    messages: [{ role: "user", content: task.input }],
  });

  try {
    const response = await Promise.race([workPromise, timeoutPromise]);
    const output = response.content
      .filter((b) => b.type === "text")
      .map((b) => (b.type === "text" ? b.text : ""))
      .join("");

    return {
      taskId: task.id,
      output,
      success: true,
      durationMs: Date.now() - start,
    };
  } catch (err) {
    return {
      taskId: task.id,
      output: "",
      success: false,
      error: err instanceof Error ? err.message : String(err),
      durationMs: Date.now() - start,
    };
  }
}

async function swarm(
  client: Anthropic,
  tasks: SwarmTask[],
  config: SwarmConfig
): Promise<{ results: SwarmResult[]; synthesis: string }> {
  const semaphore = { count: 0 };
  const queue = [...tasks];
  const results: SwarmResult[] = [];

  async function processWithConcurrency(): Promise<void> {
    const active: Promise<void>[] = [];

    for (const task of queue) {
      while (semaphore.count >= config.maxConcurrency) {
        await Promise.race(active);
      }

      semaphore.count++;
      const p = runSwarmAgent(client, task, config)
        .then((result) => {
          results.push(result);
        })
        .finally(() => {
          semaphore.count--;
          const idx = active.indexOf(p);
          if (idx !== -1) active.splice(idx, 1);
        });

      active.push(p);
    }

    await Promise.all(active);
  }

  await processWithConcurrency();

  const successCount = results.filter((r) => r.success).length;
  if (successCount < config.minimumSuccessQuorum) {
    throw new Error(
      `Swarm quorum not met: ${successCount}/${tasks.length} succeeded, required ${config.minimumSuccessQuorum}`
    );
  }

  const successResults = results.filter((r) => r.success);
  const summaryInput = successResults
    .map((r) => `Task ${r.taskId}:\n${r.output}`)
    .join("\n\n---\n\n");

  const synthesis = await client.messages.create({
    model: "claude-sonnet-4-5",
    max_tokens: 2048,
    system: config.synthesisSystemPrompt,
    messages: [
      {
        role: "user",
        content: `Synthesize these parallel agent outputs into a coherent response:\n\n${summaryInput}`,
      },
    ],
  });

  const synthesisText = synthesis.content
    .filter((b) => b.type === "text")
    .map((b) => (b.type === "text" ? b.text : ""))
    .join("");

  return { results, synthesis: synthesisText };
}
```

---

## 7. Debate / Critique Pattern

Multiple agents argue opposing positions; a **Judge** agent evaluates arguments and reaches a verdict. Forces adversarial examination of assumptions.

### When to Use
- High-stakes decisions where false confidence is dangerous
- Code review, security analysis, architectural decisions
- Generating balanced perspectives on controversial topics
- Evaluating agent outputs before exposing to users

### Convergence and Deadlock Prevention
- Fixed round limit (2–3 rounds is usually sufficient)
- Judge can declare a verdict after any round
- If agents produce identical arguments for N rounds, treat as consensus

### TypeScript Implementation

```typescript
import Anthropic from "@anthropic-ai/sdk";

interface DebatePosition {
  agentId: string;
  stance: string;
  argument: string;
  round: number;
}

interface DebateConfig {
  maxRounds: number;
  topic: string;
  positions: Array<{ agentId: string; stance: string; systemPrompt: string }>;
  judgeSystemPrompt: string;
}

interface DebateResult {
  verdict: string;
  reasoning: string;
  rounds: DebatePosition[][];
  convergenceDetected: boolean;
}

async function runDebateRound(
  client: Anthropic,
  topic: string,
  stance: string,
  systemPrompt: string,
  priorArguments: DebatePosition[]
): Promise<string> {
  const priorContext =
    priorArguments.length > 0
      ? priorArguments
          .map((p) => `${p.agentId} (${p.stance}): ${p.argument}`)
          .join("\n\n")
      : "No prior arguments.";

  const response = await client.messages.create({
    model: "claude-sonnet-4-5",
    max_tokens: 1024,
    system: systemPrompt,
    messages: [
      {
        role: "user",
        content: `Topic: ${topic}\n\nYour position: ${stance}\n\nPrior arguments:\n${priorContext}\n\nProvide your argument for this round.`,
      },
    ],
  });

  return response.content
    .filter((b) => b.type === "text")
    .map((b) => (b.type === "text" ? b.text : ""))
    .join("");
}

function detectConvergence(
  round: DebatePosition[],
  prior: DebatePosition[]
): boolean {
  if (prior.length === 0) return false;
  return round.every((pos, i) => {
    const priorPos = prior[i];
    return priorPos && pos.argument.slice(0, 100) === priorPos.argument.slice(0, 100);
  });
}

async function debate(
  client: Anthropic,
  config: DebateConfig
): Promise<DebateResult> {
  const allRounds: DebatePosition[][] = [];
  let convergenceDetected = false;

  for (let round = 0; round < config.maxRounds; round++) {
    const priorFlat = allRounds.flat();
    const currentRound: DebatePosition[] = [];

    for (const position of config.positions) {
      const argument = await runDebateRound(
        client,
        config.topic,
        position.stance,
        position.systemPrompt,
        priorFlat
      );

      currentRound.push({
        agentId: position.agentId,
        stance: position.stance,
        argument,
        round,
      });
    }

    if (allRounds.length > 0 && detectConvergence(currentRound, allRounds[allRounds.length - 1])) {
      convergenceDetected = true;
      allRounds.push(currentRound);
      break;
    }

    allRounds.push(currentRound);
  }

  const fullDebateText = allRounds
    .flat()
    .map((p) => `Round ${p.round + 1} — ${p.agentId} (${p.stance}):\n${p.argument}`)
    .join("\n\n---\n\n");

  const judgeResponse = await client.messages.create({
    model: "claude-opus-4-5",
    max_tokens: 2048,
    system: config.judgeSystemPrompt,
    messages: [
      {
        role: "user",
        content: `Topic: ${config.topic}\n\nFull debate transcript:\n\n${fullDebateText}\n\nProvide your verdict and reasoning.`,
      },
    ],
  });

  const judgeText = judgeResponse.content
    .filter((b) => b.type === "text")
    .map((b) => (b.type === "text" ? b.text : ""))
    .join("");

  const [verdict, ...reasoningLines] = judgeText.split("\n");

  return {
    verdict: verdict ?? judgeText,
    reasoning: reasoningLines.join("\n"),
    rounds: allRounds,
    convergenceDetected,
  };
}
```

---

## 8. State Machine Pattern

The agent's behavior is governed by **explicit state transitions**. Each state defines allowed actions; invalid transitions are rejected at the harness level.

### When to Use
- Compliance workflows where audit trails are mandatory
- Multi-turn processes with defined phases (intake → review → approval → complete)
- Systems where human-in-the-loop gates must be enforced
- Preventing jailbreak via state isolation (a state can disable dangerous tools)

### TypeScript Implementation

```typescript
import Anthropic from "@anthropic-ai/sdk";

type StateId = string;

interface StateDefinition {
  id: StateId;
  description: string;
  allowedTools: string[];
  transitions: Array<{
    to: StateId;
    condition: string;
    triggerToolName?: string;
  }>;
  onEnter?: (context: StateMachineContext) => Promise<void>;
}

interface StateMachineContext {
  currentState: StateId;
  history: Array<{ state: StateId; timestamp: number; reason: string }>;
  data: Record<string, unknown>;
}

interface StateMachineConfig {
  states: StateDefinition[];
  initialState: StateId;
  terminalStates: StateId[];
}

function filterToolsForState(
  tools: Anthropic.Tool[],
  allowedToolNames: string[]
): Anthropic.Tool[] {
  const allowed = new Set(allowedToolNames);
  return tools.filter((t) => allowed.has(t.name));
}

async function runStateMachine(
  client: Anthropic,
  messages: Anthropic.MessageParam[],
  tools: Anthropic.Tool[],
  toolHandlers: Record<string, (input: Record<string, unknown>, ctx: StateMachineContext) => Promise<string>>,
  config: StateMachineConfig
): Promise<{ finalState: StateId; context: StateMachineContext; result: string }> {
  const stateMap = new Map(config.states.map((s) => [s.id, s]));

  const context: StateMachineContext = {
    currentState: config.initialState,
    history: [{ state: config.initialState, timestamp: Date.now(), reason: "initial" }],
    data: {},
  };

  const currentMessages = [...messages];
  let finalResult = "";

  while (!config.terminalStates.includes(context.currentState)) {
    const state = stateMap.get(context.currentState);
    if (!state) throw new Error(`Unknown state: ${context.currentState}`);

    if (state.onEnter) {
      await state.onEnter(context);
    }

    const allowedTools = filterToolsForState(tools, state.allowedTools);

    const response = await client.messages.create({
      model: "claude-sonnet-4-5",
      max_tokens: 1024,
      system: `Current state: ${state.id} — ${state.description}
Available tools in this state: ${state.allowedTools.join(", ") || "none"}`,
      tools: allowedTools,
      messages: currentMessages,
    });

    currentMessages.push({ role: "assistant", content: response.content });

    if (response.stop_reason === "end_turn") {
      finalResult = response.content
        .filter((b) => b.type === "text")
        .map((b) => (b.type === "text" ? b.text : ""))
        .join("");

      const endTransition = state.transitions.find((t) => !t.triggerToolName);
      if (endTransition) {
        context.history.push({
          state: endTransition.to,
          timestamp: Date.now(),
          reason: endTransition.condition,
        });
        context.currentState = endTransition.to;
      } else {
        break;
      }
      continue;
    }

    const toolUseBlocks = response.content.filter((b) => b.type === "tool_use");
    const toolResults: Anthropic.ToolResultBlockParam[] = [];

    for (const block of toolUseBlocks) {
      if (block.type !== "tool_use") continue;

      if (!state.allowedTools.includes(block.name)) {
        toolResults.push({
          type: "tool_result",
          tool_use_id: block.id,
          content: `Tool "${block.name}" is not permitted in state "${state.id}"`,
          is_error: true,
        });
        continue;
      }

      const handler = toolHandlers[block.name];
      let resultContent: string;

      try {
        resultContent = await handler(block.input as Record<string, unknown>, context);
      } catch (err) {
        resultContent = `Error: ${err instanceof Error ? err.message : String(err)}`;
      }

      toolResults.push({
        type: "tool_result",
        tool_use_id: block.id,
        content: resultContent,
      });

      const transition = state.transitions.find((t) => t.triggerToolName === block.name);
      if (transition) {
        context.history.push({
          state: transition.to,
          timestamp: Date.now(),
          reason: transition.condition,
        });
        context.currentState = transition.to;
      }
    }

    currentMessages.push({ role: "user", content: toolResults });
  }

  return { finalState: context.currentState, context, result: finalResult };
}
```

---

## Pattern Composition

Patterns compose naturally. Common combinations:

### Router → ReAct per Route
Each route runs its own ReAct loop with domain-specific tools and system prompts. The router classifies the intent; the specialized ReAct loop handles depth.

```typescript
const routes: Route[] = [
  {
    id: "research",
    name: "Research Agent",
    description: "Deep research requiring web search and synthesis",
    handler: async (client, msg) => {
      const { result } = await reactLoop(client, msg, researchTools, researchHandlers, {
        maxIterations: 10, maxTokensPerStep: 2048, stuckDetectionWindow: 3,
      });
      return result;
    },
  },
  {
    id: "code",
    name: "Code Agent",
    description: "Code generation, review, and debugging",
    handler: async (client, msg) => {
      const { result } = await reactLoop(client, msg, codeTools, codeHandlers, {
        maxIterations: 5, maxTokensPerStep: 4096, stuckDetectionWindow: 2,
      });
      return result;
    },
  },
];
```

### Supervisor + Debate Verification
The supervisor delegates to sub-agents, then passes critical outputs through the Debate pattern before including them in the final synthesis. Forces adversarial review of sub-agent outputs.

### Plan-and-Execute + Swarm for Parallelizable Steps
The planner marks steps as `parallel: true` when they have no inter-dependencies. The executor fans these out as a Swarm and aggregates before continuing the sequential plan.

### State Machine + ReAct per State
Each state has its own ReAct loop bounded by that state's allowed tools. The state machine enforces phase transitions; ReAct handles open-ended reasoning within a phase.

---

## Selection Criteria

### Decision Matrix

| Axis | Single-Turn | ReAct | Plan-Execute | Router | Supervisor | Swarm | Debate | State Machine |
|------|-------------|-------|--------------|--------|------------|-------|--------|---------------|
| **Task complexity** | Low | Medium | High | Low–Medium | High | Medium | Medium | Medium |
| **Determinism** | High | Low | Medium | High | Low | Medium | Low | High |
| **Safety requirements** | Low | Medium | Medium | Medium | Medium | Low | High | High |
| **Cost sensitivity** | Low | High | Medium | Low | High | High | High | Medium |
| **Latency tolerance** | Low | High | Medium | Low | High | Low | High | Medium |
| **Auditability** | Low | Medium | High | Low | Medium | Low | High | High |
| **Failure recovery** | None | Partial | Replanning | Fallback | Retry | Quorum | N/A | Per-state |

### Quick Selection Guide

- **I need a fast, reliable API wrapper** → Single-Turn Tool Use
- **I need to browse/search/reason iteratively** → ReAct Loop
- **I have a complex goal with knowable steps** → Plan-and-Execute
- **My users ask questions across multiple domains** → Router (static or LLM)
- **I need specialists coordinated by a generalist** → Supervisor
- **I have 10+ independent subtasks** → Swarm
- **I need adversarial review before acting** → Debate/Critique
- **Compliance requires auditable phase transitions** → State Machine
- **Complex + cost-sensitive + latency-tolerant** → Supervisor + Debate + Swarm composition

### Cost vs Capability Trade-offs

| Pattern | Approx. API Calls per Request | Best Model Mix |
|---------|------------------------------|----------------|
| Single-Turn | 1–2 | Haiku or Sonnet |
| ReAct | 2–15 | Sonnet (main), Haiku (tools) |
| Plan-Execute | 3–20 | Opus (plan), Haiku (execute) |
| Router | 2–5 | Haiku (classifier), Sonnet (handler) |
| Supervisor | 5–30 | Sonnet (supervisor), Haiku (sub-agents) |
| Swarm | N + 1 | Haiku (workers), Sonnet (synthesis) |
| Debate | (R × A) + 1 | Sonnet (debaters), Opus (judge) |
| State Machine | Varies | Per-state model selection |

Where R = rounds, A = agents per round, N = number of parallel tasks.
