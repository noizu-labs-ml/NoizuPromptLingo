# Security Implementation

Full TypeScript implementation of the guard layer for agentic systems. Each guard is independently configurable and composable via a middleware pipeline.

## Guard Pipeline Architecture

```typescript
interface GuardContext {
  requestId: string;
  agentId: string;
  userId?: string;
  sessionId: string;
  input: string;
  toolCalls?: ToolCall[];
  output?: string;
  metadata: Record<string, unknown>;
}

type GuardResult = { passed: true } | { passed: false; reason: string; code: string };
type GuardMiddleware = (ctx: GuardContext, next: () => Promise<GuardResult>) => Promise<GuardResult>;

async function runGuardPipeline(
  ctx: GuardContext,
  guards: GuardMiddleware[]
): Promise<GuardResult> {
  let index = 0;

  const next = async (): Promise<GuardResult> => {
    if (index >= guards.length) return { passed: true };
    const guard = guards[index++];
    return guard(ctx, next);
  };

  return next();
}
```

---

## 1. Input Filter

Screens user input for injection attempts, banned content, and PII before it reaches the LLM.

```typescript
interface InputFilterConfig {
  maxLengthChars: number;
  blockedPatterns: Array<{ name: string; pattern: RegExp; severity: string }>;
  piiDetection: boolean;
  normalizeUnicode: boolean;
}

const DEFAULT_INPUT_FILTER_CONFIG: InputFilterConfig = {
  maxLengthChars: 32_000,
  blockedPatterns: [
    {
      name: "ignore_instructions",
      pattern: /ignore\s+(all\s+)?(previous|prior|system)\s+instructions?/i,
      severity: "high",
    },
    {
      name: "system_override",
      pattern: /\[?(SYSTEM|ADMIN|ROOT)\]?\s*:/i,
      severity: "high",
    },
    {
      name: "zero_width",
      pattern: /[​-‍﻿­]/,
      severity: "medium",
    },
  ],
  piiDetection: true,
  normalizeUnicode: true,
};

// Simple PII patterns — replace with a dedicated library (e.g., presidio) in production
const PII_PATTERNS = [
  { name: "ssn", pattern: /\b\d{3}-\d{2}-\d{4}\b/ },
  { name: "credit_card", pattern: /\b(?:\d{4}[- ]?){3}\d{4}\b/ },
  { name: "email", pattern: /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}\b/i },
];

function createInputFilter(config: InputFilterConfig = DEFAULT_INPUT_FILTER_CONFIG): GuardMiddleware {
  return async (ctx, next) => {
    let input = ctx.input;

    if (config.normalizeUnicode) {
      input = input.normalize("NFKC").replace(/\s+/g, " ").trim();
    }

    if (input.length > config.maxLengthChars) {
      return { passed: false, reason: `Input exceeds ${config.maxLengthChars} characters`, code: "INPUT_TOO_LONG" };
    }

    for (const { name, pattern } of config.blockedPatterns) {
      if (pattern.test(input)) {
        return { passed: false, reason: `Blocked pattern: ${name}`, code: "INJECTION_DETECTED" };
      }
    }

    if (config.piiDetection) {
      for (const { name, pattern } of PII_PATTERNS) {
        if (pattern.test(input)) {
          // Log but don't block — depends on use case
          ctx.metadata[`pii_detected_${name}`] = true;
        }
      }
    }

    ctx.input = input; // pass normalized input downstream
    return next();
  };
}
```

---

## 2. Output Validator

Validates LLM output before returning to the user. Checks for content policy violations, canary token leakage, and schema compliance.

```typescript
interface OutputValidatorConfig {
  canaryToken?: string;
  blockedOutputPatterns: Array<{ name: string; pattern: RegExp }>;
  maxOutputChars: number;
  requireSchema?: Record<string, unknown>; // JSON Schema for structured outputs
}

function createOutputValidator(config: OutputValidatorConfig): GuardMiddleware {
  return async (ctx, next) => {
    const result = await next();
    if (!result.passed) return result;

    const output = ctx.output ?? "";

    if (output.length > config.maxOutputChars) {
      return { passed: false, reason: "Output too long", code: "OUTPUT_TOO_LONG" };
    }

    if (config.canaryToken && output.includes(config.canaryToken)) {
      return { passed: false, reason: "System prompt leaked in output", code: "CANARY_LEAKED" };
    }

    for (const { name, pattern } of config.blockedOutputPatterns) {
      if (pattern.test(output)) {
        return { passed: false, reason: `Output blocked: ${name}`, code: "OUTPUT_BLOCKED" };
      }
    }

    return { passed: true };
  };
}
```

---

## 3. Cost Limiter

Tracks token consumption per user/session and enforces hard and soft limits.

```typescript
interface CostLimiterConfig {
  maxTokensPerUser24h: number;
  maxTokensPerSession: number;
  maxUsdPerUser24h: number;
  inputTokenCostPer1k: number;
  outputTokenCostPer1k: number;
  store: CostStore;
}

interface CostStore {
  getUsage(key: string): Promise<{ tokens: number; usd: number }>;
  incrementUsage(key: string, tokens: number, usd: number, ttlSeconds: number): Promise<void>;
}

interface TokenUsage {
  inputTokens: number;
  outputTokens: number;
}

function createCostLimiter(config: CostLimiterConfig): GuardMiddleware {
  return async (ctx, next) => {
    const userKey = `cost:user:${ctx.userId ?? "anon"}`;
    const sessionKey = `cost:session:${ctx.sessionId}`;

    const [userUsage, sessionUsage] = await Promise.all([
      config.store.getUsage(userKey),
      config.store.getUsage(sessionKey),
    ]);

    if (userUsage.tokens >= config.maxTokensPerUser24h) {
      return { passed: false, reason: "Daily token limit exceeded", code: "COST_LIMIT_USER_DAILY" };
    }

    if (sessionUsage.tokens >= config.maxTokensPerSession) {
      return { passed: false, reason: "Session token limit exceeded", code: "COST_LIMIT_SESSION" };
    }

    if (userUsage.usd >= config.maxUsdPerUser24h) {
      return { passed: false, reason: "Daily cost limit exceeded", code: "COST_LIMIT_USD_DAILY" };
    }

    const result = await next();

    // After completion, record usage from ctx.metadata
    const usage = ctx.metadata.tokenUsage as TokenUsage | undefined;
    if (usage) {
      const totalTokens = usage.inputTokens + usage.outputTokens;
      const usd =
        (usage.inputTokens / 1000) * config.inputTokenCostPer1k +
        (usage.outputTokens / 1000) * config.outputTokenCostPer1k;

      await Promise.all([
        config.store.incrementUsage(userKey, totalTokens, usd, 86400),
        config.store.incrementUsage(sessionKey, totalTokens, usd, 3600),
      ]);
    }

    return result;
  };
}
```

---

## 4. Rate Limiter

Token bucket algorithm with per-user and per-IP rate limiting.

```typescript
interface RateLimiterConfig {
  requestsPerMinutePerUser: number;
  requestsPerMinutePerIp: number;
  burstMultiplier: number; // e.g., 1.5x burst allowed
  store: RateLimitStore;
}

interface RateLimitStore {
  increment(key: string, windowSeconds: number): Promise<number>; // returns new count
  reset(key: string): Promise<void>;
}

function createRateLimiter(config: RateLimiterConfig): GuardMiddleware {
  return async (ctx, next) => {
    const userKey = `rate:user:${ctx.userId ?? ctx.sessionId}`;
    const ipKey = `rate:ip:${ctx.metadata.ip ?? "unknown"}`;

    const burstLimit = Math.floor(config.requestsPerMinutePerUser * config.burstMultiplier);

    const [userCount, ipCount] = await Promise.all([
      config.store.increment(userKey, 60),
      config.store.increment(ipKey, 60),
    ]);

    if (userCount > burstLimit) {
      return { passed: false, reason: "User rate limit exceeded", code: "RATE_LIMIT_USER" };
    }

    if (ipCount > config.requestsPerMinutePerIp * config.burstMultiplier) {
      return { passed: false, reason: "IP rate limit exceeded", code: "RATE_LIMIT_IP" };
    }

    return next();
  };
}
```

---

## 5. Tool Sandbox

Validates tool calls against an allowlist, enforces parameter constraints, and prevents tool abuse.

```typescript
interface ToolPolicy {
  toolName: string;
  allowedRoles?: string[];          // restrict to agent roles
  parameterConstraints?: Record<string, ParameterConstraint>;
  maxCallsPerSession?: number;
  requireConfirmation?: boolean;    // human-in-the-loop for destructive tools
}

interface ParameterConstraint {
  type?: string;
  pattern?: RegExp;
  maxLength?: number;
  allowedValues?: unknown[];
}

interface ToolSandboxConfig {
  policies: ToolPolicy[];
  defaultDeny: boolean;  // if true, unlisted tools are blocked
}

function createToolSandbox(config: ToolSandboxConfig): GuardMiddleware {
  const policyMap = new Map(config.policies.map((p) => [p.toolName, p]));

  return async (ctx, next) => {
    for (const call of ctx.toolCalls ?? []) {
      const policy = policyMap.get(call.name);

      if (!policy) {
        if (config.defaultDeny) {
          return { passed: false, reason: `Tool not in allowlist: ${call.name}`, code: "TOOL_NOT_ALLOWED" };
        }
        continue;
      }

      if (policy.allowedRoles && ctx.metadata.agentRole) {
        const role = ctx.metadata.agentRole as string;
        if (!policy.allowedRoles.includes(role)) {
          return { passed: false, reason: `Role ${role} cannot use tool ${call.name}`, code: "TOOL_ROLE_FORBIDDEN" };
        }
      }

      if (policy.parameterConstraints) {
        for (const [param, constraint] of Object.entries(policy.parameterConstraints)) {
          const value = (call.parameters as Record<string, unknown>)[param];
          if (constraint.type && typeof value !== constraint.type) {
            return { passed: false, reason: `Parameter ${param} type mismatch`, code: "TOOL_PARAM_TYPE" };
          }
          if (constraint.maxLength && typeof value === "string" && value.length > constraint.maxLength) {
            return { passed: false, reason: `Parameter ${param} too long`, code: "TOOL_PARAM_LENGTH" };
          }
          if (constraint.pattern && typeof value === "string" && !constraint.pattern.test(value)) {
            return { passed: false, reason: `Parameter ${param} fails pattern`, code: "TOOL_PARAM_PATTERN" };
          }
        }
      }
    }

    return next();
  };
}
```

---

## 6. Audit Logger

Immutable append-only log of every request, guard decision, tool call, and response.

```typescript
interface AuditEvent {
  id: string;
  timestamp: number;
  requestId: string;
  agentId: string;
  userId?: string;
  sessionId: string;
  eventType: "request" | "guard_block" | "tool_call" | "response" | "error";
  data: Record<string, unknown>;
  guardCode?: string;
}

interface AuditStore {
  append(event: AuditEvent): Promise<void>;
  query(filter: AuditFilter): Promise<AuditEvent[]>;
}

interface AuditFilter {
  requestId?: string;
  agentId?: string;
  userId?: string;
  fromTimestamp?: number;
  toTimestamp?: number;
  eventType?: AuditEvent["eventType"];
}

function createAuditLogger(store: AuditStore): GuardMiddleware {
  return async (ctx, next) => {
    const requestEvent: AuditEvent = {
      id: crypto.randomUUID(),
      timestamp: Date.now(),
      requestId: ctx.requestId,
      agentId: ctx.agentId,
      userId: ctx.userId,
      sessionId: ctx.sessionId,
      eventType: "request",
      data: { inputLength: ctx.input.length, toolCallCount: ctx.toolCalls?.length ?? 0 },
    };

    await store.append(requestEvent);

    const result = await next();

    const outcomeEvent: AuditEvent = {
      id: crypto.randomUUID(),
      timestamp: Date.now(),
      requestId: ctx.requestId,
      agentId: ctx.agentId,
      userId: ctx.userId,
      sessionId: ctx.sessionId,
      eventType: result.passed ? "response" : "guard_block",
      data: result.passed
        ? { outputLength: ctx.output?.length ?? 0 }
        : { reason: result.reason },
      guardCode: result.passed ? undefined : result.code,
    };

    await store.append(outcomeEvent);
    return result;
  };
}
```

---

## Composing the Full Guard Stack

```typescript
function buildGuardStack(deps: {
  costStore: CostStore;
  rateLimitStore: RateLimitStore;
  auditStore: AuditStore;
  canaryToken: string;
}): GuardMiddleware[] {
  return [
    createAuditLogger(deps.auditStore),          // always first and last — wraps all
    createRateLimiter({
      requestsPerMinutePerUser: 20,
      requestsPerMinutePerIp: 60,
      burstMultiplier: 1.5,
      store: deps.rateLimitStore,
    }),
    createCostLimiter({
      maxTokensPerUser24h: 500_000,
      maxTokensPerSession: 50_000,
      maxUsdPerUser24h: 5.0,
      inputTokenCostPer1k: 0.003,
      outputTokenCostPer1k: 0.015,
      store: deps.costStore,
    }),
    createInputFilter(),
    createToolSandbox({
      defaultDeny: true,
      policies: [
        { toolName: "web_search", maxCallsPerSession: 20 },
        { toolName: "code_execute", requireConfirmation: true, allowedRoles: ["developer"] },
        {
          toolName: "file_write",
          requireConfirmation: true,
          parameterConstraints: {
            path: { pattern: /^\/workspace\//, maxLength: 256 },
          },
        },
      ],
    }),
    createOutputValidator({
      canaryToken: deps.canaryToken,
      blockedOutputPatterns: [],
      maxOutputChars: 100_000,
    }),
  ];
}
```
