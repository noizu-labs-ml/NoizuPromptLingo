# Rate Limiting Patterns for MCP Servers

> Strategies for rate limiting MCP server tools. Covers per-tool limits, per-client limits, algorithms, implementation, and graceful degradation.

> For the specification checklist (Section 5), see `references/specification-checklist.md`.

---

## Why Rate Limiting Matters for MCP

MCP servers are particularly vulnerable to over-consumption because:

1. **LLMs are persistent** -- an LLM in a loop can call tools hundreds of times per minute
2. **Upstream costs** -- tools wrapping paid APIs pass costs through to you
3. **Resource exhaustion** -- database connections, file handles, and memory are finite
4. **Fairness** -- without limits, one client can starve others
5. **Security** -- rate limiting is a defense layer against abuse and credential stuffing

---

## Rate Limiting Dimensions

### Per-Tool Limits

Different tools have different costs. Expensive tools get lower limits.

| Tool | Cost | Limit | Rationale |
|------|------|-------|-----------|
| `search_locations` | API call + compute | 10/min | Expensive upstream query |
| `get_current_weather` | API call | 60/min | Matches upstream limit |
| `get_forecast` | API call | 30/min | More expensive upstream call |
| `get_alerts` | API call | 60/min | Lightweight upstream call |

### Per-Client Limits

Identified by auth token, API key, or session ID.

| Client Type | Limit | Rationale |
|-------------|-------|-----------|
| Free tier | 100 req/hour | Prevent abuse, encourage upgrade |
| Paid tier | 1000 req/hour | Reasonable production usage |
| Internal | 5000 req/hour | Higher trust, still bounded |

### Global Limits

Protect the server regardless of client identity.

| Scope | Limit | Rationale |
|-------|-------|-----------|
| All requests | 10,000/min | Server capacity ceiling |
| Per IP (unauthenticated) | 10/min | Prevent scanning/brute force |

---

## Algorithms

### Sliding Window

Tracks requests in a rolling time window. More accurate than fixed windows but uses more memory.

**How it works:**
- Store timestamp of each request
- Count requests in the last N seconds
- Reject if count exceeds limit

**Pros:** Smooth rate enforcement, no burst at window boundaries
**Cons:** Higher memory usage (stores timestamps)

### Token Bucket

Each client has a bucket of tokens. Tokens are consumed per request and refilled at a constant rate. Allows bursts up to bucket capacity.

**How it works:**
- Client starts with N tokens (bucket capacity)
- Each request consumes 1 token (or more for expensive tools)
- Tokens refill at R per second
- Request rejected when bucket is empty

**Pros:** Allows controlled bursts, intuitive model
**Cons:** Slightly more complex to implement

### Fixed Window

Simple counter per time window (e.g., per minute). Resets at window boundaries.

**How it works:**
- Counter starts at 0 at each window boundary
- Increment on each request
- Reject if counter exceeds limit

**Pros:** Simple, low memory
**Cons:** Allows 2x burst at window boundaries (end of one + start of next)

---

## Implementation: Node.js (TypeScript)

### Sliding Window with Map

```typescript
interface RateLimitEntry {
  timestamps: number[];
}

class SlidingWindowRateLimiter {
  private clients = new Map<string, RateLimitEntry>();
  private readonly windowMs: number;
  private readonly maxRequests: number;

  constructor(windowMs: number, maxRequests: number) {
    this.windowMs = windowMs;
    this.maxRequests = maxRequests;
  }

  check(clientId: string): { allowed: boolean; remaining: number; retryAfterMs: number } {
    const now = Date.now();
    const cutoff = now - this.windowMs;

    let entry = this.clients.get(clientId);
    if (!entry) {
      entry = { timestamps: [] };
      this.clients.set(clientId, entry);
    }

    // Remove expired timestamps
    entry.timestamps = entry.timestamps.filter((t) => t > cutoff);

    if (entry.timestamps.length >= this.maxRequests) {
      const oldestInWindow = entry.timestamps[0];
      const retryAfterMs = oldestInWindow + this.windowMs - now;
      return {
        allowed: false,
        remaining: 0,
        retryAfterMs: Math.ceil(retryAfterMs),
      };
    }

    entry.timestamps.push(now);
    return {
      allowed: true,
      remaining: this.maxRequests - entry.timestamps.length,
      retryAfterMs: 0,
    };
  }

  // Periodic cleanup of expired entries
  cleanup(): void {
    const cutoff = Date.now() - this.windowMs;
    for (const [clientId, entry] of this.clients) {
      entry.timestamps = entry.timestamps.filter((t) => t > cutoff);
      if (entry.timestamps.length === 0) {
        this.clients.delete(clientId);
      }
    }
  }
}
```

### Token Bucket

```typescript
class TokenBucketRateLimiter {
  private buckets = new Map<string, { tokens: number; lastRefill: number }>();
  private readonly capacity: number;
  private readonly refillRate: number; // tokens per second

  constructor(capacity: number, refillRate: number) {
    this.capacity = capacity;
    this.refillRate = refillRate;
  }

  check(clientId: string, cost: number = 1): { allowed: boolean; remaining: number; retryAfterMs: number } {
    const now = Date.now();
    let bucket = this.buckets.get(clientId);

    if (!bucket) {
      bucket = { tokens: this.capacity, lastRefill: now };
      this.buckets.set(clientId, bucket);
    }

    // Refill tokens
    const elapsed = (now - bucket.lastRefill) / 1000;
    bucket.tokens = Math.min(this.capacity, bucket.tokens + elapsed * this.refillRate);
    bucket.lastRefill = now;

    if (bucket.tokens < cost) {
      const waitSeconds = (cost - bucket.tokens) / this.refillRate;
      return {
        allowed: false,
        remaining: Math.floor(bucket.tokens),
        retryAfterMs: Math.ceil(waitSeconds * 1000),
      };
    }

    bucket.tokens -= cost;
    return {
      allowed: true,
      remaining: Math.floor(bucket.tokens),
      retryAfterMs: 0,
    };
  }
}
```

### Express Middleware

```typescript
import express from "express";

const globalLimiter = new SlidingWindowRateLimiter(60_000, 10_000); // 10k/min global
const clientLimiter = new SlidingWindowRateLimiter(3600_000, 1000); // 1k/hour per client

function rateLimitMiddleware(req: express.Request, res: express.Response, next: express.NextFunction) {
  // Global limit
  const globalCheck = globalLimiter.check("global");
  if (!globalCheck.allowed) {
    res.status(429)
      .set("Retry-After", String(Math.ceil(globalCheck.retryAfterMs / 1000)))
      .json({ error: "Server rate limit exceeded", retry_after_ms: globalCheck.retryAfterMs });
    return;
  }

  // Per-client limit
  const clientId = req.clientId ?? req.ip ?? "anonymous";
  const clientCheck = clientLimiter.check(clientId);

  // Always set rate limit headers
  res.set("X-RateLimit-Limit", "1000");
  res.set("X-RateLimit-Remaining", String(clientCheck.remaining));
  res.set("X-RateLimit-Reset", String(Math.ceil(Date.now() / 1000) + 3600));

  if (!clientCheck.allowed) {
    res.status(429)
      .set("Retry-After", String(Math.ceil(clientCheck.retryAfterMs / 1000)))
      .json({ error: "Client rate limit exceeded", retry_after_ms: clientCheck.retryAfterMs });
    return;
  }

  next();
}

app.use("/mcp", rateLimitMiddleware);
```

---

## Implementation: Python (FastMCP)

### Sliding Window

```python
import time
from collections import defaultdict
from threading import Lock

class SlidingWindowRateLimiter:
    def __init__(self, window_seconds: int, max_requests: int):
        self.window = window_seconds
        self.max_requests = max_requests
        self.clients: dict[str, list[float]] = defaultdict(list)
        self.lock = Lock()

    def check(self, client_id: str) -> tuple[bool, int, float]:
        """Returns (allowed, remaining, retry_after_seconds)."""
        now = time.time()
        cutoff = now - self.window

        with self.lock:
            timestamps = self.clients[client_id]
            # Remove expired
            self.clients[client_id] = [t for t in timestamps if t > cutoff]
            timestamps = self.clients[client_id]

            if len(timestamps) >= self.max_requests:
                retry_after = timestamps[0] + self.window - now
                return False, 0, max(0, retry_after)

            timestamps.append(now)
            remaining = self.max_requests - len(timestamps)
            return True, remaining, 0
```

### Starlette Middleware

```python
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse
import math

class RateLimitMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, limiter: SlidingWindowRateLimiter):
        super().__init__(app)
        self.limiter = limiter

    async def dispatch(self, request: Request, call_next):
        client_id = getattr(request.state, "client_id", request.client.host)
        allowed, remaining, retry_after = self.limiter.check(client_id)

        if not allowed:
            return JSONResponse(
                {"error": "Rate limit exceeded", "retry_after_seconds": retry_after},
                status_code=429,
                headers={
                    "Retry-After": str(math.ceil(retry_after)),
                    "X-RateLimit-Remaining": "0",
                },
            )

        response = await call_next(request)
        response.headers["X-RateLimit-Remaining"] = str(remaining)
        return response
```

---

## Graceful Degradation

### 429 Response Format

```json
{
  "error": "Rate limit exceeded",
  "retry_after_ms": 5000,
  "limit": 60,
  "remaining": 0,
  "reset_at": "2026-05-08T12:01:00Z"
}
```

### HTTP Headers

| Header | Value | Purpose |
|--------|-------|---------|
| `Retry-After` | Seconds until limit resets | Standard HTTP header; clients should respect this |
| `X-RateLimit-Limit` | Maximum requests per window | Informational |
| `X-RateLimit-Remaining` | Requests remaining in current window | Informational |
| `X-RateLimit-Reset` | Unix timestamp when window resets | Informational |

### Client Behavior

Well-behaved clients should:
1. Read `Retry-After` header on 429 responses
2. Back off exponentially on repeated 429s
3. Pre-check `X-RateLimit-Remaining` before making requests
4. Not retry immediately -- this makes the problem worse

---

## Cost-Based Limiting

Some tools cost more than others. Use a weighted system:

```typescript
const TOOL_COSTS: Record<string, number> = {
  "search_locations": 5,     // Expensive: upstream search API
  "get_forecast": 3,         // Moderate: upstream API with larger payload
  "get_current_weather": 1,  // Cheap: cached upstream call
  "get_alerts": 1,           // Cheap: lightweight upstream call
};

// Token bucket with 100 tokens, refilling at 10/second
const limiter = new TokenBucketRateLimiter(100, 10);

function checkToolRateLimit(clientId: string, toolName: string): boolean {
  const cost = TOOL_COSTS[toolName] ?? 1;
  const result = limiter.check(clientId, cost);
  return result.allowed;
}
```

### Cost Table Template

| Tool | Token Cost | Rationale |
|------|-----------|-----------|
| Read (cached) | 1 | Served from cache, minimal cost |
| Read (upstream) | 2 | Upstream API call |
| Search | 5 | Expensive upstream query + compute |
| Write | 3 | Database mutation + audit log |
| Delete | 3 | Database mutation + audit log |
| Bulk operation | 10 | Multiple upstream calls |

---

## Distributed Rate Limiting

For multi-instance deployments, in-memory rate limiting per instance is insufficient. Use a shared store.

### Redis-Based Rate Limiting

```typescript
import Redis from "ioredis";

const redis = new Redis(process.env.REDIS_URL);

async function checkRateLimit(
  clientId: string,
  limit: number,
  windowSeconds: number
): Promise<{ allowed: boolean; remaining: number }> {
  const key = `ratelimit:${clientId}`;
  const now = Date.now();

  const pipeline = redis.pipeline();
  pipeline.zremrangebyscore(key, 0, now - windowSeconds * 1000);
  pipeline.zadd(key, now, `${now}-${Math.random()}`);
  pipeline.zcard(key);
  pipeline.expire(key, windowSeconds);

  const results = await pipeline.exec();
  const count = results![2][1] as number;

  return {
    allowed: count <= limit,
    remaining: Math.max(0, limit - count),
  };
}
```

### When to Use Distributed Rate Limiting

- Multiple server instances behind a load balancer
- Serverless deployments (each invocation is independent)
- Rate limits must be globally consistent (not per-instance)

### When In-Memory is Sufficient

- Single instance deployment
- stdio transport (single client)
- Approximate rate limiting is acceptable
