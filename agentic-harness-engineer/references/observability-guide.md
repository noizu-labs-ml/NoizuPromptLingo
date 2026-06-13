# Observability Guide

Full observability for agentic systems: structured logging, distributed tracing, metrics, cost tracking, and anomaly detection using OpenTelemetry.

## Why Agents Need Different Observability

Traditional APM monitors request latency and error rates. Agentic systems additionally need:
- **Token budget tracking** — LLM calls are expensive; budget exhaustion is a P0 incident
- **Tool call auditing** — which tools were invoked with what parameters
- **Reasoning trace capture** — full message history for debugging incorrect decisions
- **Multi-turn correlation** — link turns across a session into one logical trace
- **Behavioral anomaly detection** — unusual tool usage patterns, injection attempts, cost spikes

---

## OpenTelemetry Setup

```typescript
import { NodeSDK } from "@opentelemetry/sdk-node";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { OTLPMetricExporter } from "@opentelemetry/exporter-metrics-otlp-http";
import { PeriodicExportingMetricReader } from "@opentelemetry/sdk-metrics";
import { Resource } from "@opentelemetry/resources";
import { SEMRESATTRS_SERVICE_NAME, SEMRESATTRS_SERVICE_VERSION } from "@opentelemetry/semantic-conventions";

export function initTelemetry(config: {
  serviceName: string;
  serviceVersion: string;
  otlpEndpoint: string;
}): NodeSDK {
  const sdk = new NodeSDK({
    resource: new Resource({
      [SEMRESATTRS_SERVICE_NAME]: config.serviceName,
      [SEMRESATTRS_SERVICE_VERSION]: config.serviceVersion,
    }),
    traceExporter: new OTLPTraceExporter({
      url: `${config.otlpEndpoint}/v1/traces`,
    }),
    metricReader: new PeriodicExportingMetricReader({
      exporter: new OTLPMetricExporter({
        url: `${config.otlpEndpoint}/v1/metrics`,
      }),
      exportIntervalMillis: 15_000,
    }),
  });

  sdk.start();

  process.on("SIGTERM", () => sdk.shutdown());
  return sdk;
}
```

---

## Structured Logging

```typescript
import pino from "pino";

interface AgentLogContext {
  requestId: string;
  agentId: string;
  userId?: string;
  sessionId: string;
  traceId?: string;
  spanId?: string;
}

function createAgentLogger(context: AgentLogContext) {
  return pino({
    level: process.env.LOG_LEVEL ?? "info",
    base: context,
    timestamp: pino.stdTimeFunctions.isoTime,
    formatters: {
      level: (label) => ({ level: label }),
    },
  });
}

// Usage: structured fields, not string concatenation
// logger.info({ toolName: "web_search", queryLength: q.length }, "Tool invoked");
// logger.warn({ code: "COST_LIMIT_APPROACHING", budgetUsed: 0.85 }, "Cost threshold warning");
// logger.error({ code: "INJECTION_DETECTED", input: sanitized }, "Guard blocked request");
```

---

## Distributed Tracing

Every agent invocation creates a root span. Tool calls create child spans. Multi-turn sessions link via `sessionId` baggage.

```typescript
import { trace, context, SpanStatusCode, Span } from "@opentelemetry/api";

const tracer = trace.getTracer("agent-harness", "1.0.0");

interface AgentInvocationOptions {
  requestId: string;
  agentId: string;
  userId?: string;
  sessionId: string;
  input: string;
}

async function tracedAgentInvocation<T>(
  opts: AgentInvocationOptions,
  fn: (span: Span) => Promise<T>
): Promise<T> {
  return tracer.startActiveSpan(
    `agent.invoke`,
    {
      attributes: {
        "agent.id": opts.agentId,
        "agent.request_id": opts.requestId,
        "agent.session_id": opts.sessionId,
        "user.id": opts.userId ?? "anon",
        "input.length": opts.input.length,
      },
    },
    async (span) => {
      try {
        const result = await fn(span);
        span.setStatus({ code: SpanStatusCode.OK });
        return result;
      } catch (err) {
        span.setStatus({ code: SpanStatusCode.ERROR, message: String(err) });
        span.recordException(err as Error);
        throw err;
      } finally {
        span.end();
      }
    }
  );
}

async function tracedToolCall<T>(
  toolName: string,
  parameters: Record<string, unknown>,
  fn: () => Promise<T>
): Promise<T> {
  return tracer.startActiveSpan(
    `tool.call`,
    {
      attributes: {
        "tool.name": toolName,
        "tool.param_keys": Object.keys(parameters).join(","),
      },
    },
    async (span) => {
      const start = Date.now();
      try {
        const result = await fn();
        span.setAttribute("tool.latency_ms", Date.now() - start);
        span.setStatus({ code: SpanStatusCode.OK });
        return result;
      } catch (err) {
        span.setStatus({ code: SpanStatusCode.ERROR, message: String(err) });
        throw err;
      } finally {
        span.end();
      }
    }
  );
}
```

---

## Metrics Collection

```typescript
import { metrics } from "@opentelemetry/api";

const meter = metrics.getMeter("agent-harness");

// Counters
const requestCounter = meter.createCounter("agent.requests.total", {
  description: "Total agent requests",
});
const guardBlockCounter = meter.createCounter("agent.guard.blocks.total", {
  description: "Total guard blocks by code",
});
const toolCallCounter = meter.createCounter("agent.tool.calls.total", {
  description: "Tool invocations by name",
});

// Histograms
const requestLatency = meter.createHistogram("agent.request.latency_ms", {
  description: "Agent request latency",
  unit: "ms",
  advice: { explicitBucketBoundaries: [50, 100, 250, 500, 1000, 2500, 5000, 10000] },
});
const inputTokensHist = meter.createHistogram("agent.tokens.input", {
  description: "Input tokens per request",
  advice: { explicitBucketBoundaries: [100, 500, 1000, 2000, 5000, 10000, 20000] },
});
const outputTokensHist = meter.createHistogram("agent.tokens.output", {
  description: "Output tokens per request",
});

// Gauges (use observable callbacks)
const activeSessionsGauge = meter.createObservableGauge("agent.sessions.active", {
  description: "Currently active sessions",
});

// Record metrics after each request
function recordRequestMetrics(opts: {
  agentId: string;
  latencyMs: number;
  inputTokens: number;
  outputTokens: number;
  guardCode?: string;
  toolNames: string[];
  error?: string;
}): void {
  const baseAttrs = { "agent.id": opts.agentId };

  requestCounter.add(1, { ...baseAttrs, status: opts.error ? "error" : "ok" });
  requestLatency.record(opts.latencyMs, baseAttrs);
  inputTokensHist.record(opts.inputTokens, baseAttrs);
  outputTokensHist.record(opts.outputTokens, baseAttrs);

  if (opts.guardCode) {
    guardBlockCounter.add(1, { ...baseAttrs, code: opts.guardCode });
  }

  for (const toolName of opts.toolNames) {
    toolCallCounter.add(1, { ...baseAttrs, "tool.name": toolName });
  }
}
```

---

## Cost Tracking

```typescript
interface CostRecord {
  timestamp: number;
  requestId: string;
  agentId: string;
  userId?: string;
  model: string;
  inputTokens: number;
  outputTokens: number;
  inputCostUsd: number;
  outputCostUsd: number;
  totalCostUsd: number;
}

// Model pricing table (update as pricing changes)
const MODEL_PRICING: Record<string, { inputPer1k: number; outputPer1k: number }> = {
  "claude-opus-4": { inputPer1k: 0.015, outputPer1k: 0.075 },
  "claude-sonnet-4-5": { inputPer1k: 0.003, outputPer1k: 0.015 },
  "claude-haiku-3-5": { inputPer1k: 0.00025, outputPer1k: 0.00125 },
};

function calculateCost(model: string, inputTokens: number, outputTokens: number): CostRecord["inputCostUsd"] {
  const pricing = MODEL_PRICING[model] ?? { inputPer1k: 0.003, outputPer1k: 0.015 };
  return (inputTokens / 1000) * pricing.inputPer1k + (outputTokens / 1000) * pricing.outputPer1k;
}

// Emit cost as OTLP metric
const costCounter = meter.createCounter("agent.cost.usd", {
  description: "Cumulative LLM cost in USD",
  unit: "USD",
});

function recordCost(record: Omit<CostRecord, "inputCostUsd" | "outputCostUsd" | "totalCostUsd">): void {
  const pricing = MODEL_PRICING[record.model] ?? { inputPer1k: 0.003, outputPer1k: 0.015 };
  const inputCostUsd = (record.inputTokens / 1000) * pricing.inputPer1k;
  const outputCostUsd = (record.outputTokens / 1000) * pricing.outputPer1k;
  const totalCostUsd = inputCostUsd + outputCostUsd;

  costCounter.add(totalCostUsd, {
    "agent.id": record.agentId,
    "model": record.model,
    "user.id": record.userId ?? "anon",
  });
}
```

---

## Behavioral Anomaly Detection

```typescript
interface AnomalyRule {
  name: string;
  check: (window: RequestWindow) => boolean;
  severity: "low" | "medium" | "high" | "critical";
  description: string;
}

interface RequestWindow {
  agentId: string;
  userId?: string;
  requests: Array<{
    timestamp: number;
    inputTokens: number;
    outputTokens: number;
    toolCalls: string[];
    guardBlocks: string[];
    latencyMs: number;
  }>;
  windowDurationMs: number;
}

const ANOMALY_RULES: AnomalyRule[] = [
  {
    name: "cost_spike",
    check: (w) => {
      const totalTokens = w.requests.reduce((s, r) => s + r.inputTokens + r.outputTokens, 0);
      const tokensPerMinute = totalTokens / (w.windowDurationMs / 60_000);
      return tokensPerMinute > 100_000;
    },
    severity: "high",
    description: "Token usage exceeds 100k/minute",
  },
  {
    name: "repeated_guard_blocks",
    check: (w) => {
      const blocks = w.requests.flatMap((r) => r.guardBlocks);
      return blocks.length >= 5;
    },
    severity: "critical",
    description: "5+ guard blocks in window — possible attack",
  },
  {
    name: "tool_abuse",
    check: (w) => {
      const allTools = w.requests.flatMap((r) => r.toolCalls);
      const toolCounts = allTools.reduce((m, t) => (m.set(t, (m.get(t) ?? 0) + 1), m), new Map<string, number>());
      return [...toolCounts.values()].some((c) => c > 50);
    },
    severity: "high",
    description: "Single tool called 50+ times in window",
  },
  {
    name: "latency_degradation",
    check: (w) => {
      if (w.requests.length < 5) return false;
      const recent = w.requests.slice(-5).map((r) => r.latencyMs);
      const avgRecent = recent.reduce((s, l) => s + l, 0) / recent.length;
      return avgRecent > 30_000; // 30s avg
    },
    severity: "medium",
    description: "Average latency exceeds 30s",
  },
];

function detectAnomalies(window: RequestWindow): Array<{ rule: AnomalyRule; window: RequestWindow }> {
  return ANOMALY_RULES
    .filter((r) => r.check(window))
    .map((rule) => ({ rule, window }));
}
```

---

## Dashboard Recommendations

### Grafana Panels (for OTLP/Prometheus backend)

| Panel | Query | Alert |
|-------|-------|-------|
| Request rate | `rate(agent_requests_total[5m])` | < 0 (dead) |
| Error rate | `rate(agent_requests_total{status="error"}[5m]) / rate(agent_requests_total[5m])` | > 5% |
| P99 latency | `histogram_quantile(0.99, agent_request_latency_ms_bucket)` | > 10s |
| Cost/hour | `increase(agent_cost_usd[1h])` | > $5/hr |
| Guard blocks | `sum by (code) (rate(agent_guard_blocks_total[5m]))` | Any spike |
| Token burn rate | `rate(agent_tokens_input[5m]) + rate(agent_tokens_output[5m])` | > budget |

### Datadog Tags

Label all metrics with: `agent_id`, `user_id`, `model`, `env` (prod/staging/dev). Use APM traces for waterfall view of multi-tool calls. Set cost monitors via `agent.cost.usd` sum with 1h rollup.
