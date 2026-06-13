# Monitoring and Observability for MCP Servers

Structured logging, metrics, tracing, and alerting patterns for production MCP servers.

## 1. Structured Logging

Every tool call should produce a structured log entry with consistent fields.

### Log Entry Schema

```json
{
  "timestamp": "2026-05-08T14:32:00.000Z",
  "level": "info",
  "message": "Tool call completed: get_timestamp",
  "tool": "get_timestamp",
  "params_hash": "a1b2c3d4",
  "duration_ms": 12.5,
  "result_summary": "success",
  "session_id": "abc-123",
  "request_id": "req-456"
}
```

Key fields:
- **tool** -- which tool was called
- **params_hash** -- hash of input params (avoid logging sensitive data)
- **duration_ms** -- wall-clock execution time
- **result_summary** -- "success", "error", "rate_limited"
- **session_id** -- MCP session identifier
- **request_id** -- unique per-request identifier

### Error Log Entry

```json
{
  "timestamp": "2026-05-08T14:32:01.000Z",
  "level": "error",
  "message": "Tool call failed: create_payment",
  "tool": "create_payment",
  "params_hash": "e5f6g7h8",
  "duration_ms": 2340,
  "error": "Stripe API timeout after 2000ms",
  "error_type": "TimeoutError",
  "stack": "TimeoutError: Stripe API timeout...",
  "session_id": "abc-123",
  "request_id": "req-457"
}
```

### Implementation: TypeScript

```typescript
// src/middleware/logger.ts
import crypto from "node:crypto";

interface LogEntry {
  timestamp: string;
  level: "debug" | "info" | "warn" | "error";
  message: string;
  tool?: string;
  params_hash?: string;
  duration_ms?: number;
  result_summary?: string;
  session_id?: string;
  request_id?: string;
  error?: string;
  error_type?: string;
  [key: string]: unknown;
}

export function createRequestLogger(sessionId?: string) {
  const requestId = crypto.randomUUID();

  return {
    logToolCall(
      tool: string,
      params: Record<string, unknown>,
      startTime: number,
      error?: Error
    ): void {
      const entry: LogEntry = {
        timestamp: new Date().toISOString(),
        level: error ? "error" : "info",
        message: `Tool call ${error ? "failed" : "completed"}: ${tool}`,
        tool,
        params_hash: hashParams(params),
        duration_ms: Date.now() - startTime,
        result_summary: error ? "error" : "success",
        session_id: sessionId,
        request_id: requestId,
      };
      if (error) {
        entry.error = error.message;
        entry.error_type = error.constructor.name;
      }
      process.stderr.write(JSON.stringify(entry) + "\n");
    },
  };
}

function hashParams(params: Record<string, unknown>): string {
  return crypto
    .createHash("md5")
    .update(JSON.stringify(params))
    .digest("hex")
    .slice(0, 8);
}
```

### Implementation: Python

```python
# src/middleware/logger.py
import hashlib
import json
import sys
import time
import uuid
from typing import Any


def create_request_logger(session_id: str | None = None):
    request_id = str(uuid.uuid4())

    def log_tool_call(
        tool: str,
        params: dict[str, Any],
        start_time: float,
        error: Exception | None = None,
    ) -> None:
        entry = {
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
            "level": "error" if error else "info",
            "message": f"Tool call {'failed' if error else 'completed'}: {tool}",
            "tool": tool,
            "params_hash": _hash_params(params),
            "duration_ms": round((time.time() - start_time) * 1000, 2),
            "result_summary": "error" if error else "success",
            "session_id": session_id,
            "request_id": request_id,
        }
        if error:
            entry["error"] = str(error)
            entry["error_type"] = type(error).__name__
        print(json.dumps(entry), file=sys.stderr, flush=True)

    return log_tool_call


def _hash_params(params: dict[str, Any]) -> str:
    raw = json.dumps(params, sort_keys=True, default=str)
    return hashlib.md5(raw.encode()).hexdigest()[:8]
```

## 2. Metrics

### Key Metrics for MCP Servers

| Metric | Type | Description |
|---|---|---|
| `mcp_tool_calls_total` | Counter | Total tool calls, labeled by tool name and status |
| `mcp_tool_call_duration_seconds` | Histogram | Tool call duration distribution |
| `mcp_tool_errors_total` | Counter | Tool call errors, labeled by tool and error type |
| `mcp_active_sessions` | Gauge | Currently active MCP sessions |
| `mcp_rate_limit_rejections_total` | Counter | Requests rejected by rate limiter |

### Prometheus Metrics (TypeScript)

```typescript
// src/metrics.ts
// Lightweight in-memory metrics (no Prometheus client dependency)

interface MetricStore {
  counters: Map<string, number>;
  histograms: Map<string, number[]>;
  gauges: Map<string, number>;
}

const store: MetricStore = {
  counters: new Map(),
  histograms: new Map(),
  gauges: new Map(),
};

export function incCounter(name: string, labels: Record<string, string> = {}): void {
  const key = `${name}{${serializeLabels(labels)}}`;
  store.counters.set(key, (store.counters.get(key) ?? 0) + 1);
}

export function observeHistogram(name: string, value: number, labels: Record<string, string> = {}): void {
  const key = `${name}{${serializeLabels(labels)}}`;
  const values = store.histograms.get(key) ?? [];
  values.push(value);
  store.histograms.set(key, values);
}

export function setGauge(name: string, value: number): void {
  store.gauges.set(name, value);
}

export function getMetrics(): string {
  const lines: string[] = [];
  for (const [key, value] of store.counters) {
    lines.push(`${key} ${value}`);
  }
  for (const [key, values] of store.histograms) {
    const sorted = values.sort((a, b) => a - b);
    const p95 = sorted[Math.floor(sorted.length * 0.95)] ?? 0;
    const p99 = sorted[Math.floor(sorted.length * 0.99)] ?? 0;
    lines.push(`${key}_p95 ${p95}`);
    lines.push(`${key}_p99 ${p99}`);
    lines.push(`${key}_count ${values.length}`);
  }
  for (const [key, value] of store.gauges) {
    lines.push(`${key} ${value}`);
  }
  return lines.join("\n");
}

function serializeLabels(labels: Record<string, string>): string {
  return Object.entries(labels)
    .map(([k, v]) => `${k}="${v}"`)
    .join(",");
}
```

### Usage in Tool Middleware

```typescript
import { incCounter, observeHistogram } from "../metrics.js";

// In tool call wrapper:
incCounter("mcp_tool_calls_total", { tool: toolName, status: error ? "error" : "success" });
observeHistogram("mcp_tool_call_duration_seconds", durationMs / 1000, { tool: toolName });
```

## 3. Health Check Endpoint Design

### /health -- Liveness

Returns 200 if the process is alive. No dependency checks.

```typescript
// Minimal health check
if (req.url === "/health") {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({
    status: "ok",
    version: config.MCP_SERVER_VERSION,
    uptime_seconds: process.uptime(),
  }));
}
```

### /ready -- Readiness

Returns 200 if the server is ready to handle requests. Checks dependencies.

```typescript
if (req.url === "/ready") {
  const checks = {
    database: await checkDatabase(),
    external_api: await checkExternalApi(),
  };
  const allReady = Object.values(checks).every(Boolean);

  res.writeHead(allReady ? 200 : 503, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ ready: allReady, checks }));
}
```

### /metrics -- Prometheus Scrape

```typescript
if (req.url === "/metrics") {
  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end(getMetrics());
}
```

## 4. OpenTelemetry Integration

### Traces Per Tool Call

```typescript
// src/tracing.ts
import { trace, SpanStatusCode } from "@opentelemetry/api";

const tracer = trace.getTracer("mcp-server");

export async function traceToolCall<T>(
  toolName: string,
  params: Record<string, unknown>,
  handler: () => Promise<T>
): Promise<T> {
  return tracer.startActiveSpan(`tool.${toolName}`, async (span) => {
    span.setAttribute("mcp.tool.name", toolName);
    span.setAttribute("mcp.tool.params_count", Object.keys(params).length);

    try {
      const result = await handler();
      span.setStatus({ code: SpanStatusCode.OK });
      return result;
    } catch (error) {
      span.setStatus({
        code: SpanStatusCode.ERROR,
        message: error instanceof Error ? error.message : String(error),
      });
      span.recordException(error as Error);
      throw error;
    } finally {
      span.end();
    }
  });
}
```

### Spans for External Calls

```typescript
// Inside a tool handler:
const result = await tracer.startActiveSpan("stripe.createPayment", async (span) => {
  span.setAttribute("stripe.amount", amount);
  const payment = await stripe.paymentIntents.create({ amount, currency });
  span.setAttribute("stripe.payment_id", payment.id);
  return payment;
});
```

### OpenTelemetry Setup

```typescript
// src/instrumentation.ts
import { NodeSDK } from "@opentelemetry/sdk-node";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { Resource } from "@opentelemetry/resources";

const sdk = new NodeSDK({
  resource: new Resource({
    "service.name": "my-mcp-server",
    "service.version": "0.1.0",
  }),
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT ?? "http://localhost:4318/v1/traces",
  }),
});

sdk.start();
```

## 5. Alerting Patterns

### Error Rate Spikes

Alert when error rate exceeds 5% over a 5-minute window:

```yaml
# Prometheus alerting rule
groups:
  - name: mcp-server
    rules:
      - alert: MCPHighErrorRate
        expr: |
          sum(rate(mcp_tool_errors_total[5m]))
          / sum(rate(mcp_tool_calls_total[5m]))
          > 0.05
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "MCP server error rate above 5%"
```

### Latency Degradation

```yaml
      - alert: MCPHighLatency
        expr: |
          histogram_quantile(0.95, rate(mcp_tool_call_duration_seconds_bucket[5m]))
          > 2.0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "MCP server p95 latency above 2 seconds"
```

### Auth Failures

```yaml
      - alert: MCPAuthFailures
        expr: |
          sum(rate(mcp_auth_failures_total[5m])) > 10
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Elevated MCP auth failures -- possible attack"
```

## 6. Dashboard Suggestions

### Grafana Panels for MCP Servers

**Row 1: Overview**
- Request rate (total tool calls per second)
- Error rate (percentage)
- Active sessions (gauge)

**Row 2: Latency**
- p50/p95/p99 latency by tool (histogram)
- Latency heatmap

**Row 3: Per-Tool Breakdown**
- Calls per tool (stacked bar)
- Error rate per tool
- Average duration per tool

**Row 4: Infrastructure**
- CPU usage
- Memory usage
- Network I/O

**Row 5: Rate Limiting**
- Accepted vs rejected requests
- Token bucket fill level

### Example Grafana JSON Model (Panel)

```json
{
  "title": "Tool Calls per Second",
  "type": "timeseries",
  "datasource": "Prometheus",
  "targets": [
    {
      "expr": "sum(rate(mcp_tool_calls_total[1m])) by (tool)",
      "legendFormat": "{{tool}}"
    }
  ],
  "fieldConfig": {
    "defaults": {
      "unit": "reqps"
    }
  }
}
```
