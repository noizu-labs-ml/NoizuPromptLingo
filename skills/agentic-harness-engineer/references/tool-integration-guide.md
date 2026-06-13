# Tool Integration Guide

Reference for designing, registering, sandboxing, and testing tools in an agentic harness.

---

## Overview

Tools are the primary mechanism through which an agent affects the world. They are the blast radius of the harness. Every tool that exists can be called; every call can fail, be abused, or produce unexpected side effects. This guide establishes patterns for keeping tools safe, predictable, and auditable.

The tool lifecycle:
1. **Design** — define schema and contract before writing implementation
2. **Register** — attach tool to the harness (static, dynamic, or MCP)
3. **Sandbox** — constrain what the tool can do at runtime
4. **Test** — verify behavior, error paths, and security boundaries
5. **Monitor** — log inputs, outputs, latency, and errors in production

---

## Tool Design Principles

### Least Privilege
A tool should expose the minimum API surface required for the task. A "read file" tool should not also be able to write. A "search contacts" tool should not return payment data. Model each tool as a capability grant — if the agent doesn't need it, don't expose it.

### Schema-First
Define the Zod schema (or equivalent) before writing any implementation. The schema is the contract. It catches bad inputs before they reach business logic and doubles as documentation.

### Idempotency
Tools should be safe to retry. If the agent calls a tool twice with the same arguments (due to retry logic, reflection loops, or LLM hallucination), the result should be the same and no duplicate side effects should occur. Use idempotency keys for mutation tools.

### Error Transparency
Tools must return structured error objects, never throw unhandled exceptions. The harness needs to distinguish between user errors (bad input), system errors (downstream unavailable), and safety errors (action blocked by policy). Unhandled throws collapse all three into noise.

### Atomicity
When a tool performs multiple steps, either all succeed or none commit. Partial mutation is worse than failure — it leaves state inconsistent and makes retries dangerous.

---

## Tool Categories

| Category | Purpose | Examples | Risk Level |
|----------|---------|----------|------------|
| **Data Retrieval** | Read-only access to external data | web search, database query, API fetch, vector search | Low |
| **Data Mutation** | Create/update/delete records | write to DB, update CRM, POST to API | High |
| **Code Execution** | Run agent-generated code | Python sandbox, shell eval, SQL executor | Critical |
| **Communication** | Send messages or notifications | email, Slack, webhook, SMS | High |
| **File System** | Read/write local or remote files | read file, write file, list directory | Medium-High |
| **Browser/Scraping** | Navigate or extract web content | Playwright, Puppeteer, curl | Medium |
| **Agent Spawning** | Launch sub-agents | fork sub-task, delegate to specialist | Critical |

---

## Schema Design

All tools use Zod for runtime validation. Define schemas in a dedicated `tools/schemas/` directory, co-located with their handler.

### Basic Retrieval Tool

```typescript
import { z } from "zod";

export const SearchWebSchema = z.object({
  query: z.string().min(1).max(500).describe("Search query string"),
  maxResults: z.number().int().min(1).max(20).default(5),
  safeSearch: z.boolean().default(true),
});

export type SearchWebInput = z.infer<typeof SearchWebSchema>;
```

### Constrained Enum Tool

```typescript
export const SendNotificationSchema = z.object({
  channel: z.enum(["slack", "email", "sms"]).describe("Delivery channel"),
  recipient: z.string().email().or(z.string().regex(/^\+1\d{10}$/)),
  message: z.string().min(1).max(2000),
  priority: z.enum(["low", "normal", "high"]).default("normal"),
});
```

### Complex Nested Object

```typescript
export const CreateTicketSchema = z.object({
  title: z.string().min(5).max(200),
  description: z.string().max(10000).optional(),
  assignee: z
    .object({
      userId: z.string().uuid(),
      team: z.string().optional(),
    })
    .optional(),
  labels: z.array(z.string().max(50)).max(10).default([]),
  dueDate: z.string().datetime().optional().describe("ISO 8601 datetime"),
  metadata: z.record(z.string(), z.unknown()).optional(),
});

export type CreateTicketInput = z.infer<typeof CreateTicketSchema>;
```

### Pattern-Constrained Input

```typescript
export const ReadFileSchema = z.object({
  path: z
    .string()
    .regex(/^[a-zA-Z0-9_\-./]+$/, "Path must be alphanumeric with / . - _")
    .max(512)
    .refine((p) => !p.includes(".."), "Path traversal not allowed"),
  encoding: z.enum(["utf8", "base64"]).default("utf8"),
  maxBytes: z.number().int().min(1).max(1_000_000).default(100_000),
});
```

### Schema Validation in Handler

```typescript
import { ZodError } from "zod";
import { ReadFileSchema } from "./schemas/read-file";

async function handleReadFile(rawInput: unknown): Promise<ToolResult> {
  const parsed = ReadFileSchema.safeParse(rawInput);
  if (!parsed.success) {
    return {
      ok: false,
      error: {
        code: "INVALID_INPUT",
        message: "Input validation failed",
        details: parsed.error.flatten(),
      },
    };
  }
  // safe to use parsed.data from here
  const { path, encoding, maxBytes } = parsed.data;
  // ...
}
```

---

## Tool Result Contract

Every tool returns a `ToolResult` union. Never return raw strings or throw — the harness needs structured output to reason about what happened.

```typescript
export type ToolSuccess<T = unknown> = {
  ok: true;
  data: T;
  metadata?: {
    durationMs: number;
    cached?: boolean;
    truncated?: boolean;
  };
};

export type ToolError = {
  ok: false;
  error: {
    code: ToolErrorCode;
    message: string;       // human-readable, safe to show user
    details?: unknown;     // internal debug info, do NOT surface to LLM verbatim
    retryable?: boolean;
  };
};

export type ToolResult<T = unknown> = ToolSuccess<T> | ToolError;

export type ToolErrorCode =
  | "INVALID_INPUT"
  | "NOT_FOUND"
  | "PERMISSION_DENIED"
  | "RATE_LIMITED"
  | "TIMEOUT"
  | "UPSTREAM_ERROR"
  | "POLICY_BLOCKED"
  | "QUOTA_EXCEEDED";
```

---

## Sandboxing

### Timeout Enforcement

Wrap every tool call in a timeout. Never let a tool block the agent loop indefinitely.

```typescript
function withTimeout<T>(
  fn: () => Promise<T>,
  timeoutMs: number,
  toolName: string
): Promise<T> {
  return Promise.race([
    fn(),
    new Promise<never>((_, reject) =>
      setTimeout(
        () => reject(new Error(`Tool '${toolName}' timed out after ${timeoutMs}ms`)),
        timeoutMs
      )
    ),
  ]);
}

// Usage in harness dispatch:
const result = await withTimeout(
  () => tool.handler(input),
  tool.timeoutMs ?? 10_000,
  tool.name
);
```

### Output Size Limits

Truncate tool output before passing to the LLM context window. Large outputs consume tokens and can crowd out reasoning.

```typescript
function truncateOutput(
  output: string,
  maxChars: number = 8_000,
  notice: string = "\n[output truncated]"
): string {
  if (output.length <= maxChars) return output;
  return output.slice(0, maxChars) + notice;
}
```

### Domain Allowlisting for HTTP Tools

HTTP tools must validate the target domain against an allowlist before making any request.

```typescript
const ALLOWED_DOMAINS = new Set([
  "api.github.com",
  "api.linear.app",
  "slack.com",
]);

function assertAllowedDomain(url: string): void {
  const parsed = new URL(url);
  if (!ALLOWED_DOMAINS.has(parsed.hostname)) {
    throw new PolicyError(
      `HTTP tool blocked: domain '${parsed.hostname}' not in allowlist`
    );
  }
}
```

### Filesystem Path Restrictions

Resolve the path and verify it falls within the permitted root before any I/O.

```typescript
import path from "path";
import fs from "fs/promises";

const ALLOWED_ROOT = path.resolve("/workspace/data");

async function safeReadFile(userPath: string): Promise<string> {
  const resolved = path.resolve(ALLOWED_ROOT, userPath);
  if (!resolved.startsWith(ALLOWED_ROOT + path.sep)) {
    throw new PolicyError(`Path escapes allowed root: ${resolved}`);
  }
  return fs.readFile(resolved, "utf8");
}
```

### Process Isolation for Code Execution

For sandboxed code execution, never exec in the main process. Use a child process with strict limits.

```typescript
import { spawn } from "child_process";

interface ExecResult {
  stdout: string;
  stderr: string;
  exitCode: number;
}

function execSandboxed(
  code: string,
  timeoutMs = 5_000
): Promise<ExecResult> {
  return new Promise((resolve, reject) => {
    const child = spawn("node", ["--max-old-space-size=128", "-e", code], {
      timeout: timeoutMs,
      uid: parseInt(process.env.SANDBOX_UID ?? "65534"), // nobody
      env: {}, // no environment passthrough
    });

    let stdout = "";
    let stderr = "";

    child.stdout.on("data", (d) => (stdout += d.toString().slice(0, 50_000)));
    child.stderr.on("data", (d) => (stderr += d.toString().slice(0, 10_000)));

    child.on("close", (code) =>
      resolve({ stdout, stderr, exitCode: code ?? -1 })
    );
    child.on("error", reject);
  });
}
```

---

## Tool Registration Patterns

### Static Registration at Startup

Define tools as a typed registry. Load at harness initialization.

```typescript
export interface ToolDefinition<TInput = unknown, TOutput = unknown> {
  name: string;
  description: string;
  schema: z.ZodType<TInput>;
  handler: (input: TInput) => Promise<ToolResult<TOutput>>;
  timeoutMs?: number;
  requiresApproval?: boolean;
  category: ToolCategory;
}

class ToolRegistry {
  private tools = new Map<string, ToolDefinition>();

  register(tool: ToolDefinition): void {
    if (this.tools.has(tool.name)) {
      throw new Error(`Tool '${tool.name}' already registered`);
    }
    this.tools.set(tool.name, tool);
  }

  get(name: string): ToolDefinition | undefined {
    return this.tools.get(name);
  }

  toAnthropicTools(): AnthropicTool[] {
    return [...this.tools.values()].map((t) => ({
      name: t.name,
      description: t.description,
      input_schema: zodToJsonSchema(t.schema),
    }));
  }
}

// At startup:
const registry = new ToolRegistry();
registry.register(searchWebTool);
registry.register(readFileTool);
registry.register(createTicketTool);
```

### Dynamic Registration (User-Provided Tools)

When users supply tools at runtime (e.g., via API), validate the schema before registering.

```typescript
async function registerUserTool(
  payload: unknown,
  registry: ToolRegistry
): Promise<void> {
  const UserToolSchema = z.object({
    name: z.string().regex(/^[a-z_][a-z0-9_]{0,63}$/),
    description: z.string().max(1000),
    inputSchema: z.record(z.unknown()), // JSON Schema
    endpoint: z.string().url(),
    secret: z.string().optional(),
  });

  const tool = UserToolSchema.parse(payload);

  // Validate endpoint domain
  assertAllowedDomain(tool.endpoint);

  registry.register({
    name: tool.name,
    description: tool.description,
    schema: z.unknown(), // validated by downstream endpoint
    handler: async (input) => {
      // Proxy to user's endpoint
      return callUserToolEndpoint(tool.endpoint, input, tool.secret);
    },
    category: "user-provided",
    requiresApproval: true, // always require approval for user tools
  });
}
```

### MCP Server Integration

Connect to an external MCP server and proxy its tools into the local registry.

```typescript
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

async function registerMcpTools(
  serverPath: string,
  registry: ToolRegistry
): Promise<void> {
  const transport = new StdioClientTransport({
    command: serverPath,
    args: [],
  });

  const client = new Client({ name: "harness", version: "1.0.0" }, {});
  await client.connect(transport);

  const { tools } = await client.listTools();

  for (const mcpTool of tools) {
    registry.register({
      name: `mcp__${mcpTool.name}`,
      description: mcpTool.description ?? "",
      schema: z.unknown(),
      handler: async (input) => {
        try {
          const result = await client.callTool({
            name: mcpTool.name,
            arguments: input as Record<string, unknown>,
          });
          return { ok: true, data: result.content };
        } catch (err) {
          return {
            ok: false,
            error: {
              code: "UPSTREAM_ERROR",
              message: `MCP tool '${mcpTool.name}' failed`,
              details: err,
              retryable: true,
            },
          };
        }
      },
      category: "mcp",
    });
  }
}
```

### Tool Versioning

Version tools explicitly when their schema or behavior changes. Never silently break existing callers.

```typescript
// Register versioned tools with explicit version suffix
registry.register({ name: "search_web_v1", ... });
registry.register({ name: "search_web_v2", ... }); // new schema

// System prompt instructs the model to prefer v2
// v1 remains registered for backward compat during rollout
```

---

## Error Handling

### Retry with Exponential Backoff

```typescript
async function callWithRetry<T>(
  fn: () => Promise<ToolResult<T>>,
  maxAttempts = 3,
  baseDelayMs = 500
): Promise<ToolResult<T>> {
  let lastResult: ToolResult<T> | undefined;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const result = await fn();

    if (result.ok || !result.error.retryable) {
      return result;
    }

    lastResult = result;

    if (attempt < maxAttempts) {
      const delay = baseDelayMs * Math.pow(2, attempt - 1);
      await new Promise((r) => setTimeout(r, delay));
    }
  }

  return lastResult!;
}
```

### Fallback Tools

Register fallback chains. If primary fails, attempt secondary.

```typescript
async function searchWithFallback(query: string): Promise<ToolResult> {
  const primary = await callWithRetry(() => braveSearch({ query }));
  if (primary.ok) return primary;

  const fallback = await callWithRetry(() => serpApiSearch({ query }));
  if (fallback.ok) return fallback;

  return {
    ok: false,
    error: {
      code: "UPSTREAM_ERROR",
      message: "All search providers failed",
      retryable: false,
    },
  };
}
```

### User-Facing vs Internal Errors

Never leak internal error details (stack traces, query strings, auth tokens) to the LLM context — it may include them in user-facing output or subsequent tool calls.

```typescript
function sanitizeForLlm(result: ToolError): string {
  // Only the public message goes into the LLM context
  return `Tool error (${result.error.code}): ${result.error.message}`;
  // result.error.details stays in the server log, never in the prompt
}
```

---

## Testing Tools

### Unit Testing Tool Handlers

```typescript
import { describe, it, expect, vi } from "vitest";
import { handleReadFile } from "../tools/read-file";

describe("handleReadFile", () => {
  it("returns file content on valid path", async () => {
    vi.spyOn(fs, "readFile").mockResolvedValue("hello world");
    const result = await handleReadFile({ path: "data/file.txt" });
    expect(result.ok).toBe(true);
    if (result.ok) expect(result.data).toBe("hello world");
  });

  it("rejects path traversal", async () => {
    const result = await handleReadFile({ path: "../etc/passwd" });
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.error.code).toBe("POLICY_BLOCKED");
  });

  it("returns INVALID_INPUT for missing path", async () => {
    const result = await handleReadFile({});
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.error.code).toBe("INVALID_INPUT");
  });
});
```

### Integration Testing with Mock LLM

```typescript
import { MockLlmClient } from "../test-utils/mock-llm";
import { AgentHarness } from "../harness";

it("agent uses read_file tool correctly", async () => {
  const mockLlm = new MockLlmClient([
    {
      type: "tool_use",
      name: "read_file",
      input: { path: "data/report.txt" },
    },
    {
      type: "text",
      text: "The report says: hello world",
    },
  ]);

  const harness = new AgentHarness({ llm: mockLlm, registry });
  const result = await harness.run("What does report.txt say?");

  expect(result.text).toContain("hello world");
  expect(mockLlm.toolCallLog).toHaveLength(1);
  expect(mockLlm.toolCallLog[0].name).toBe("read_file");
});
```

### Fuzzing Tool Inputs

```typescript
import fc from "fast-check";

it("read_file handler never throws on arbitrary input", async () => {
  await fc.assert(
    fc.asyncProperty(fc.anything(), async (input) => {
      // Must never throw — always return ToolResult
      const result = await handleReadFile(input).catch(() => null);
      expect(result).not.toBeNull();
    }),
    { numRuns: 1000 }
  );
});
```

### Security Testing Tool Boundaries

```typescript
const maliciousInputs = [
  { path: "../../etc/passwd" },
  { path: "/absolute/path" },
  { path: "file\x00.txt" },          // null byte injection
  { path: "a".repeat(10_000) },      // oversized input
  { path: "normal/../../../etc/shadow" },
];

it.each(maliciousInputs)("blocks malicious path: %o", async (input) => {
  const result = await handleReadFile(input);
  expect(result.ok).toBe(false);
  if (!result.ok) {
    expect(["INVALID_INPUT", "POLICY_BLOCKED"]).toContain(result.error.code);
  }
});
```

---

## Human-in-the-Loop

### When to Require Confirmation

Tools that require user approval before execution:

| Condition | Example | Why |
|-----------|---------|-----|
| Irreversible mutation | delete record, send email | Cannot undo |
| External communication | post to Slack, call webhook | Affects third parties |
| High blast radius | bulk update, mass delete | Hard to recover |
| User-provided tools | any registered dynamically | Unverified behavior |
| Financial operations | charge card, transfer funds | Regulatory + safety |
| Credential access | read API keys, export secrets | Security |

### Approval Workflow Pattern

```typescript
interface ApprovalRequest {
  toolName: string;
  input: unknown;
  rationale: string;   // agent's stated reason for the call
  expiresAt: Date;
}

interface ApprovalResponse {
  approved: boolean;
  modifiedInput?: unknown;  // user may modify the input before approving
}

class HumanApprovalGate {
  async requestApproval(req: ApprovalRequest): Promise<ApprovalResponse> {
    const token = crypto.randomUUID();

    // Emit approval request to UI/notification channel
    await this.notifier.send({
      type: "approval_required",
      token,
      tool: req.toolName,
      input: req.input,
      rationale: req.rationale,
      expiresAt: req.expiresAt.toISOString(),
    });

    // Poll for response with timeout
    return this.waitForApproval(token, req.expiresAt);
  }

  private async waitForApproval(
    token: string,
    expiresAt: Date
  ): Promise<ApprovalResponse> {
    const pollIntervalMs = 2_000;

    while (new Date() < expiresAt) {
      const response = await this.store.getApproval(token);
      if (response) return response;
      await new Promise((r) => setTimeout(r, pollIntervalMs));
    }

    // Timeout: default to denied
    return { approved: false };
  }
}
```

### Integrating Approval Gate in Harness Dispatch

```typescript
async function dispatchTool(
  tool: ToolDefinition,
  input: unknown,
  approvalGate: HumanApprovalGate
): Promise<ToolResult> {
  if (tool.requiresApproval) {
    const approval = await approvalGate.requestApproval({
      toolName: tool.name,
      input,
      rationale: "Agent determined this action is required to complete the task",
      expiresAt: new Date(Date.now() + 5 * 60 * 1000), // 5 minutes
    });

    if (!approval.approved) {
      return {
        ok: false,
        error: {
          code: "PERMISSION_DENIED",
          message: `User denied approval for tool '${tool.name}'`,
          retryable: false,
        },
      };
    }

    // Use potentially modified input from user
    input = approval.modifiedInput ?? input;
  }

  const parsed = tool.schema.safeParse(input);
  if (!parsed.success) {
    return {
      ok: false,
      error: { code: "INVALID_INPUT", message: "Schema validation failed", details: parsed.error.flatten() },
    };
  }

  return withTimeout(
    () => tool.handler(parsed.data),
    tool.timeoutMs ?? 10_000,
    tool.name
  );
}
```

### Timeout/Fallback When Human Doesn't Respond

```typescript
// If approval times out and the task is non-critical, continue without the tool
// If critical, halt the agent run and surface a clear message

async function dispatchWithFallback(
  tool: ToolDefinition,
  input: unknown,
  approvalGate: HumanApprovalGate
): Promise<ToolResult> {
  const result = await dispatchTool(tool, input, approvalGate);

  if (!result.ok && result.error.code === "PERMISSION_DENIED") {
    // Attempt fallback if one is registered
    const fallback = tool.fallbackTool;
    if (fallback) {
      return dispatchTool(fallback, input, approvalGate);
    }

    // Escalate to harness: stop the run, notify user
    throw new HaltError(
      `Agent halted: required tool '${tool.name}' was denied and no fallback is available.`
    );
  }

  return result;
}
```

---

## Audit Logging

Every tool call — inputs, outputs, duration, approval status — must be logged for post-hoc review and incident response.

```typescript
interface ToolAuditEntry {
  runId: string;
  toolName: string;
  input: unknown;
  result: ToolResult;
  durationMs: number;
  approvalRequired: boolean;
  approvedBy?: string;
  timestamp: string;
}

async function logToolCall(entry: ToolAuditEntry): Promise<void> {
  // Redact sensitive fields before logging
  const sanitized = redactSecrets(entry);
  await auditLog.write(sanitized);
}
```

---

## Checklist

Before shipping a tool to production:

- [ ] Zod schema defined before handler implementation
- [ ] All inputs validated; invalid inputs return `INVALID_INPUT`, never throw
- [ ] Timeout enforced via `withTimeout`
- [ ] Output size capped before returning to harness
- [ ] Path traversal / domain allowlisting enforced for FS/HTTP tools
- [ ] `requiresApproval: true` set for irreversible or high-blast-radius tools
- [ ] Unit tests cover happy path, invalid input, and at least two security boundaries
- [ ] Fuzz test added for any tool accepting free-form string input
- [ ] Audit log entry written on every call
- [ ] Internal error details not surfaced in `error.message` to LLM
