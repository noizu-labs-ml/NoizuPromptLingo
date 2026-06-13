# Worked Example: Weather API MCP Server

> Full specification walkthrough for a Weather API MCP server. Walks through all 8 checklist sections with concrete answers. This is a simple domain -- good for learning the methodology.

> For the checklist itself, see `references/specification-checklist.md`.
> For implementation, see **trl-mcp-forge** (`references/scaffold-nodejs-production.md`).

---

## Server Overview

| Field | Value |
|-------|-------|
| **Name** | weather-mcp |
| **Version** | 1.0.0 |
| **Description** | Provides current weather, forecasts, and alerts via OpenWeatherMap |
| **Tools** | 4 (get_current_weather, get_forecast, get_alerts, search_locations) |
| **Transport** | Streamable HTTP |
| **Auth** | API key |
| **Data Source** | OpenWeatherMap API v3.0 |
| **Hosting** | Google Cloud Run (serverless) |

---

## Section 1: Purpose & Scope

### 1.1 Problem Statement

LLM clients need access to current weather data to answer user questions about weather conditions, forecasts, and alerts. Without an MCP server, the LLM must either hallucinate weather data or tell the user to check a weather website.

### 1.2 Consumers

- Claude Desktop (primary)
- Cursor (secondary)
- Any MCP-compatible client

### 1.3 Tool Inventory

| Tool | Description | Read/Write |
|------|-------------|------------|
| `get_current_weather` | Current conditions (temp, humidity, wind, description) for a location | Read |
| `get_forecast` | 5-day / 3-hour forecast for a location | Read |
| `get_alerts` | Active weather alerts (severe weather, advisories) for a location | Read |
| `search_locations` | Find location IDs by city name, zip code, or coordinates | Read |

### 1.4 Resources & Prompts

None. Tools only. Weather data is too dynamic for resources (which imply stable URIs). No prompts needed.

### 1.5 Out of Scope

- Historical weather data (different API endpoint, different pricing)
- Satellite imagery or weather maps (binary data, not suited for text-based tools)
- Climate predictions or long-range forecasts (>5 days)
- Weather-based recommendations ("should I bring an umbrella?") -- that's the LLM's job
- Multiple weather providers (only OpenWeatherMap)

### 1.6 MCP vs REST API

MCP is the right choice because:
- Primary consumers are LLM clients that decide dynamically when to fetch weather
- Multiple LLM clients should be able to use the same server
- Tool discovery matters (clients should see what's available)
- A REST API would require each client to implement custom integration

### 1.7 Expected Volume

- Personal use: ~100 requests/hour
- Public service: up to 10,000 requests/hour
- Design for public service volume

**Section 1 Status: COMPLETE**

---

## Section 2: Transport

### Decision: Streamable HTTP

### Rationale

| Question | Answer | Implication |
|----------|--------|-------------|
| Local or remote? | Remote (public service) | HTTP required |
| Concurrent clients? | Many | HTTP supports this |
| Push updates? | No | Not a factor |
| Network constraints? | None (public internet) | HTTP works |
| Latency tolerance? | Sub-second | HTTP is fine |
| Migration path? | N/A | Starting with HTTP |

### Why Not stdio

stdio limits the server to a single client per process. This is a public service serving multiple clients. stdio would require each user to run their own server instance and manage their own OpenWeatherMap API key.

### Why Not SSE

SSE is deprecated in the MCP specification (mid-2026). Do not build new servers on SSE.

### ADR

See ADR-001 in `references/adr-template-guide.md` (Example ADR 1).

**Section 2 Status: COMPLETE**

---

## Section 3: Authentication & Authorization

### Decision: API Key

### Auth Design

| Field | Value |
|-------|-------|
| Pattern | API key (Bearer token) |
| Header | `Authorization: Bearer <key>` |
| Key format | `wea_` prefix + 32 bytes base64url |
| Storage | Keys stored hashed (SHA-256) in database |
| Rotation | Self-service via dashboard; immediate invalidation of old key |
| Grace period | None (key swap is instant) |

### Per-Tool Permissions

No per-tool permissions. All 4 tools are read-only and available to all authenticated clients. A permission matrix would add complexity without value here.

### Failure Behavior

| Scenario | Response |
|----------|----------|
| Missing API key | 401 `{"error": "Missing API key. Include Authorization: Bearer <key> header."}` |
| Invalid API key | 401 `{"error": "Invalid API key."}` |
| Expired/revoked key | 401 `{"error": "API key has been revoked."}` |
| Rate limited | 429 with `Retry-After` header |

### Secrets Management

| Secret | Storage | Rotation |
|--------|---------|----------|
| OpenWeatherMap API key | Cloud Run env var via Secret Manager | Quarterly |
| Database connection string | Cloud Run env var via Secret Manager | On credential rotation |
| API key signing secret | Cloud Run env var via Secret Manager | Annually |

**Section 3 Status: COMPLETE**

---

## Section 4: Data Stores

### Data Source Catalog

| Source | Type | Access | Owner | Connection | Cache TTL | Failure Mode |
|--------|------|--------|-------|------------|-----------|--------------|
| OpenWeatherMap API v3.0 | External API | Read-only | Third party (OWM) | Per-request HTTPS | 5 min (current), 30 min (forecast) | Return cached data or error |
| Client key database | Cloud SQL (PostgreSQL) | Read-only (from server perspective) | Our org | Connection pool (5) | N/A | Reject requests (no auth without DB) |

### OpenWeatherMap API Details

| Field | Value |
|-------|-------|
| Base URL | `https://api.openweathermap.org/data/3.0` |
| Auth | API key query parameter (`appid=KEY`) |
| Rate limit | 60 calls/min (free tier), 3000 calls/min (paid) |
| Data format | JSON |
| SLA | Best-effort (no SLA on free tier) |

### Caching Strategy

```
Request -> Check in-memory cache
  -> Hit: Return cached data (with cache-age header)
  -> Miss: Call OpenWeatherMap API
    -> Success: Cache result, return
    -> Failure: Check stale cache
      -> Stale hit: Return stale data (with warning)
      -> No cache: Return error
```

**Section 4 Status: COMPLETE**

---

## Section 5: Security

### Input Validation

| Tool | Input | Validation |
|------|-------|------------|
| `get_current_weather` | `location_id` (string) | Alphanumeric only, max 20 chars |
| `get_current_weather` | `units` (enum) | Must be "metric" or "imperial" |
| `get_forecast` | `location_id` (string) | Same as above |
| `get_forecast` | `days` (integer) | 1-5 range |
| `get_alerts` | `location_id` (string) | Same as above |
| `search_locations` | `query` (string) | Alphanumeric + comma + space + period, max 100 chars |

### Rate Limiting

| Scope | Limit | Algorithm |
|-------|-------|-----------|
| Per API key | 60 req/min | Sliding window |
| Per tool: `search_locations` | 10 req/min | Sliding window (expensive) |
| Global | 1000 req/min | Token bucket |
| Unauthenticated per IP | 5 req/min | Sliding window |

### Threat Model Summary

| Threat | Likelihood | Impact | Mitigation |
|--------|-----------|--------|------------|
| API key abuse (stolen key) | Medium | Medium (cost) | Rate limiting, key revocation, usage alerts |
| Upstream API exhaustion | Low | Medium (service outage) | Rate limiting, caching |
| DDoS | Low | High (service outage) | Cloud Run auto-scaling + rate limiting |
| Prompt injection via weather data | Very Low | Low | Weather data is structured (numbers/short strings) |
| SQL injection | N/A | N/A | No user input in SQL queries |
| SSRF | N/A | N/A | No user-supplied URLs |
| Path traversal | N/A | N/A | No file system access |

### Error Sanitization

- Never expose OpenWeatherMap API key in error messages
- Never expose database connection strings
- Log full errors server-side; return generic messages to clients
- Exception: validation errors include the specific field and constraint violated

**Section 5 Status: COMPLETE**

---

## Section 6: Hosting & Deployment

### Decision: Google Cloud Run

### Rationale

| Factor | Cloud Run Value | Why It Fits |
|--------|----------------|-------------|
| Cost | ~$5-15/mo (free tier covers most) | Low-cost for moderate volume |
| Ops | Fully managed | No server maintenance |
| Scaling | 0-10 instances (auto) | Handles variable load |
| TLS | Built-in | No cert management |
| Deployment | Docker container via CI | Simple, repeatable |

### Cost Estimate

| Component | Monthly Cost |
|-----------|-------------|
| Cloud Run (compute) | $0-10 (depends on traffic) |
| Cloud SQL (PostgreSQL) | $7 (smallest instance) |
| Secret Manager | $0 (free tier) |
| **Total** | **$7-17/month** |

### Monitoring

| Signal | Tool | Alert Threshold |
|--------|------|----------------|
| Error rate | Cloud Monitoring | >5% of requests return 5xx |
| Latency (p95) | Cloud Monitoring | >2 seconds |
| Instance count | Cloud Monitoring | >8 instances sustained (cost warning) |
| Upstream API errors | Application logs | >10% of upstream calls fail |

### Deployment Pipeline

```
Push to main -> GitHub Actions -> Build Docker image -> Push to GCR -> Deploy to Cloud Run -> Smoke test
```

**Section 6 Status: COMPLETE**

---

## Section 7: Discovery & Registration

### Discovery Mechanism

1. **Documentation** -- README with installation instructions and Claude Desktop config example
2. **npm package** -- Published to npm for `npx` usage (stdio mode for local development)
3. **Registry** -- Listed on MCP server registries after stable release

### Client Configuration Example

```json
{
  "mcpServers": {
    "weather": {
      "url": "https://weather-mcp.example.com/mcp",
      "headers": {
        "Authorization": "Bearer wea_abc123..."
      }
    }
  }
}
```

### Documentation Plan

- README.md: Quick start, tool reference, configuration examples
- API key request process
- Rate limit documentation
- Example queries and responses

**Section 7 Status: COMPLETE**

---

## Section 8: Versioning & Lifecycle

### Versioning Scheme

Semantic versioning: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (tool removal, required input changes)
- **MINOR**: New tools, new optional inputs
- **PATCH**: Bug fixes, description improvements

### Breaking Change Definition

| Change | Breaking? |
|--------|-----------|
| Remove a tool | Yes |
| Add required input to existing tool | Yes |
| Change output schema | Yes |
| Add new tool | No |
| Add optional input with default | No |
| Improve description text | No |
| Fix a bug in data parsing | No (unless clients depend on the bug) |

### Deprecation Policy

1. Annotate deprecated tools in their description: `[DEPRECATED: Use X instead. Removed after YYYY-MM-DD.]`
2. Log usage of deprecated tools
3. Minimum 90-day window between deprecation notice and removal
4. Notify API key holders via email before removal

### Backward Compatibility

- Additive changes only to existing tools
- New tools for new functionality
- Output schema changes via new tools (e.g., `get_weather` -> `get_weather_detailed`)

**Section 8 Status: COMPLETE**

---

## Tool Manifest

```json
{
  "server": {
    "name": "weather-mcp",
    "version": "1.0.0",
    "description": "Weather data from OpenWeatherMap for LLM clients"
  },
  "tools": [
    {
      "name": "search_locations",
      "description": "Search for locations by city name, zip code, or coordinates. Returns matching locations with IDs needed by other weather tools. Use this first to get a location_id before calling get_current_weather, get_forecast, or get_alerts. Returns up to 5 matches with city name, country, state (if applicable), and coordinates.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "query": {
            "type": "string",
            "description": "City name (e.g., 'London'), zip code (e.g., '10001'), or 'lat,lon' coordinates (e.g., '40.71,-74.01')"
          }
        },
        "required": ["query"]
      },
      "annotations": {
        "readOnlyHint": true,
        "destructiveHint": false,
        "idempotentHint": true,
        "openWorldHint": true
      }
    },
    {
      "name": "get_current_weather",
      "description": "Get current weather conditions for a specific location. Returns temperature, humidity, wind speed, and a short description (e.g., 'partly cloudy'). Use this for current/real-time weather. Use get_forecast for future weather. Requires a location_id from search_locations.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "location_id": {
            "type": "string",
            "description": "Location identifier returned by search_locations"
          },
          "units": {
            "type": "string",
            "enum": ["metric", "imperial"],
            "description": "Temperature units. 'metric' = Celsius, 'imperial' = Fahrenheit.",
            "default": "metric"
          }
        },
        "required": ["location_id"]
      },
      "annotations": {
        "readOnlyHint": true,
        "destructiveHint": false,
        "idempotentHint": true,
        "openWorldHint": true
      }
    },
    {
      "name": "get_forecast",
      "description": "Get a multi-day weather forecast for a location. Returns 3-hour interval predictions including temperature, humidity, wind, and conditions. Covers 1-5 days ahead. Use this for future weather; use get_current_weather for right now. Requires a location_id from search_locations.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "location_id": {
            "type": "string",
            "description": "Location identifier returned by search_locations"
          },
          "days": {
            "type": "integer",
            "description": "Number of days to forecast (1-5).",
            "default": 3,
            "minimum": 1,
            "maximum": 5
          },
          "units": {
            "type": "string",
            "enum": ["metric", "imperial"],
            "description": "Temperature units. 'metric' = Celsius, 'imperial' = Fahrenheit.",
            "default": "metric"
          }
        },
        "required": ["location_id"]
      },
      "annotations": {
        "readOnlyHint": true,
        "destructiveHint": false,
        "idempotentHint": true,
        "openWorldHint": true
      }
    },
    {
      "name": "get_alerts",
      "description": "Get active weather alerts for a location. Returns severe weather warnings, advisories, and watches from national weather services. May return an empty list if no alerts are active. Use this when the user asks about severe weather, storm warnings, or safety advisories. Requires a location_id from search_locations.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "location_id": {
            "type": "string",
            "description": "Location identifier returned by search_locations"
          }
        },
        "required": ["location_id"]
      },
      "annotations": {
        "readOnlyHint": true,
        "destructiveHint": false,
        "idempotentHint": true,
        "openWorldHint": true
      }
    }
  ],
  "resources": [],
  "prompts": []
}
```

---

## ADR Index

| ADR | Decision | Status |
|-----|----------|--------|
| ADR-001 | Streamable HTTP transport | Accepted |
| ADR-002 | API key authentication | Accepted |
| ADR-003 | Google Cloud Run hosting | Accepted |

See `references/adr-template-guide.md` for the full ADR text.

---

## Next Steps

With this specification complete, the next phase is implementation:

1. Scaffold the project using **trl-mcp-forge** (`references/scaffold-nodejs-production.md`)
2. Implement the 4 tools
3. Add rate limiting middleware
4. Add caching layer
5. Write integration tests
6. Deploy to Cloud Run
7. Publish to npm (for local/stdio development mode)
