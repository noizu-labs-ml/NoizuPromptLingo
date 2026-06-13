# Deployment Patterns

Production deployment guide for agentic systems: containerization, scaling, failover, cost control, and safe update strategies.

## Containerization

### Dockerfile for Agent API

```dockerfile
# Build stage
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

# Runtime stage — minimal attack surface
FROM node:22-alpine AS runtime
RUN addgroup -S agent && adduser -S agent -G agent
WORKDIR /app

# Copy only what's needed
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json .

# Never run as root
USER agent

# Explicit port — never 0.0.0.0 in image
EXPOSE 3000

# Health check
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', r => r.statusCode === 200 ? process.exit(0) : process.exit(1))"

ENV NODE_ENV=production
CMD ["node", "dist/server.js"]
```

### docker-compose for local dev

```yaml
services:
  agent-api:
    build: .
    ports: ["3000:3000"]
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - REDIS_URL=redis://redis:6379
      - OTLP_ENDPOINT=http://otel-collector:4318
    depends_on: [redis]
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
    ports: ["6379:6379"]

  otel-collector:
    image: otel/opentelemetry-collector-contrib:latest
    volumes:
      - ./otel-config.yaml:/etc/otelcol-contrib/config.yaml
    ports: ["4318:4318", "8888:8888"]
```

---

## Kubernetes Deployment

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: agent-api
  labels:
    app: agent-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: agent-api
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: agent-api
        version: "{{ .Values.image.tag }}"
    spec:
      # Graceful termination — let in-flight LLM calls complete
      terminationGracePeriodSeconds: 90
      containers:
        - name: agent-api
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: 3000
          env:
            - name: ANTHROPIC_API_KEY
              valueFrom:
                secretKeyRef:
                  name: agent-secrets
                  key: anthropic-api-key
          resources:
            requests:
              cpu: "250m"
              memory: "512Mi"
            limits:
              cpu: "1000m"
              memory: "1Gi"
          readinessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
          lifecycle:
            preStop:
              exec:
                # Signal server to stop accepting new requests before SIGTERM
                command: ["/bin/sh", "-c", "sleep 5"]
```

### HorizontalPodAutoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: agent-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: agent-api
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
    # Custom metric: scale on request queue depth
    - type: External
      external:
        metric:
          name: agent_queue_depth
        target:
          type: AverageValue
          averageValue: "10"
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 30
      policies:
        - type: Pods
          value: 2
          periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300  # slow scale-down — LLM calls are long
```

---

## Blue/Green Deployment for Agent Updates

Agents have stateful prompt logic — rolling updates risk inconsistent behavior mid-session.

```typescript
// Feature flag service: route traffic by version
interface VersionRouter {
  getVersionForSession(sessionId: string): Promise<"blue" | "green">;
  setCanaryPercent(percent: number): Promise<void>; // 0-100
  promoteGreen(): Promise<void>;  // swap green → blue
  rollbackToBlue(): Promise<void>;
}

// In your request handler:
async function handleRequest(req: Request): Promise<Response> {
  const sessionId = req.headers.get("x-session-id") ?? crypto.randomUUID();
  const version = await versionRouter.getVersionForSession(sessionId);

  // Route to appropriate agent backend
  const agentUrl = version === "green"
    ? process.env.AGENT_GREEN_URL
    : process.env.AGENT_BLUE_URL;

  return fetch(`${agentUrl}/invoke`, {
    method: "POST",
    body: req.body,
    headers: req.headers,
  });
}
```

**Deployment checklist:**
1. Deploy green alongside blue (no traffic)
2. Run smoke tests against green directly
3. Ramp canary: 1% → 5% → 25% → 50% → 100% over 24h
4. Monitor error rate and cost deviation between blue/green
5. If deviation < 5%, promote green; otherwise rollback

---

## Feature Flags for Tool/Prompt Changes

```typescript
interface FeatureFlag {
  name: string;
  enabled: boolean;
  rolloutPercent: number; // 0-100
  enabledForUsers?: string[];
  disabledForUsers?: string[];
  metadata: Record<string, unknown>;
}

interface FeatureFlagService {
  isEnabled(flagName: string, context: { userId?: string; sessionId: string }): Promise<boolean>;
  getVariant<T>(flagName: string, context: { userId?: string }, defaultValue: T): Promise<T>;
}

// Usage in agent harness
async function buildSystemPrompt(userId: string, flagService: FeatureFlagService): Promise<string> {
  const useNewSearchTool = await flagService.isEnabled("new_search_tool", { userId });
  const reasoningStyle = await flagService.getVariant<"chain_of_thought" | "direct">(
    "reasoning_style",
    { userId },
    "direct"
  );

  return buildPrompt({ useNewSearchTool, reasoningStyle });
}
```

---

## Graceful Degradation

When LLM provider is down or rate-limited, degrade gracefully rather than error.

```typescript
interface FallbackConfig {
  primaryModel: string;
  fallbackModel: string;
  fallbackOnStatusCodes: number[];       // e.g., [429, 503]
  fallbackOnLatencyMs: number;           // circuit break if primary exceeds this
  circuitBreakerThreshold: number;       // failures before opening circuit
  circuitBreakerResetMs: number;         // time before retrying primary
}

type CircuitState = "closed" | "open" | "half-open";

class CircuitBreaker {
  private state: CircuitState = "closed";
  private failures = 0;
  private lastFailure = 0;

  async execute<T>(fn: () => Promise<T>, fallback: () => Promise<T>): Promise<T> {
    if (this.state === "open") {
      if (Date.now() - this.lastFailure > this.resetMs) {
        this.state = "half-open";
      } else {
        return fallback();
      }
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (err) {
      this.onFailure();
      return fallback();
    }
  }

  private onSuccess(): void {
    this.failures = 0;
    this.state = "closed";
  }

  private onFailure(): void {
    this.failures++;
    this.lastFailure = Date.now();
    if (this.failures >= this.threshold) this.state = "open";
  }

  constructor(private threshold: number, private resetMs: number) {}
}
```

---

## Cost Control in Production

```typescript
interface CostControlConfig {
  dailyBudgetUsd: number;
  hourlyBudgetUsd: number;
  perUserDailyBudgetUsd: number;
  emergencyShutoffUsd: number;       // hard stop — prevents runaway costs
  alertThresholds: number[];          // [0.5, 0.8, 0.95] = alert at 50%, 80%, 95%
}

// Cost circuit breaker: if daily spend exceeds emergency threshold, stop all requests
class CostCircuitBreaker {
  private dailySpend = 0;
  private lastReset = Date.now();

  async checkBudget(config: CostControlConfig): Promise<{ allowed: boolean; reason?: string }> {
    // Reset daily counter
    if (Date.now() - this.lastReset > 86_400_000) {
      this.dailySpend = 0;
      this.lastReset = Date.now();
    }

    if (this.dailySpend >= config.emergencyShutoffUsd) {
      return { allowed: false, reason: `Emergency shutoff: daily spend $${this.dailySpend.toFixed(2)} exceeded limit $${config.emergencyShutoffUsd}` };
    }

    for (const threshold of config.alertThresholds) {
      if (this.dailySpend >= config.dailyBudgetUsd * threshold) {
        // Emit alert — don't block, but log and notify
        console.warn(`COST ALERT: ${threshold * 100}% of daily budget consumed`);
        break;
      }
    }

    return { allowed: true };
  }

  recordSpend(usd: number): void {
    this.dailySpend += usd;
  }
}
```

---

## Rate Limiting at Infrastructure Level

### nginx rate limiting (upstream of agent API)

```nginx
# nginx.conf
limit_req_zone $http_x_user_id zone=per_user:10m rate=20r/m;
limit_req_zone $binary_remote_addr zone=per_ip:10m rate=60r/m;

location /api/agent {
    limit_req zone=per_user burst=10 nodelay;
    limit_req zone=per_ip burst=30 nodelay;
    limit_req_status 429;

    proxy_pass http://agent_api;
    proxy_read_timeout 120s;   # LLM calls can be slow
    proxy_send_timeout 30s;
}
```

### Redis-based distributed rate limiting (for multi-pod)

```typescript
// Sliding window counter via Redis Lua script
const RATE_LIMIT_SCRIPT = `
local key = KEYS[1]
local now = tonumber(ARGV[1])
local window = tonumber(ARGV[2])
local limit = tonumber(ARGV[3])
local cutoff = now - window

redis.call('ZREMRANGEBYSCORE', key, '-inf', cutoff)
local count = redis.call('ZCARD', key)
if count >= limit then
  return 0
end
redis.call('ZADD', key, now, now .. math.random())
redis.call('EXPIRE', key, window / 1000 + 1)
return 1
`;
```
