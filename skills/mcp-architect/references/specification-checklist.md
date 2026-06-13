# MCP Server Specification Checklist

> The core artifact of the trl-mcp-architect skill. Walk through all 8 sections before writing implementation code. Each section includes mandatory questions, decision criteria, red flags, and "Done" criteria.

> For ecosystem context, see **trl-mcp-builder** (`references/mcp-ecosystem-overview.md`).
> For implementation, see **trl-mcp-forge** (`references/scaffold-nodejs-production.md`).

---

## How to Use This Checklist

1. Work through sections **in order** -- later sections depend on earlier decisions
2. Answer every mandatory question -- "not applicable" is a valid answer if justified
3. Watch for red flags -- they indicate decisions likely to cause problems
4. Check "Done" criteria before moving to the next section
5. Record all answers in the spec document template (`assets/spec-document-template.md`)
6. Write ADRs for major decisions (`assets/adr-template.md`)

---

## Section 1: Purpose & Scope

**Why this section exists:** A server without a clear purpose accumulates tools until it becomes unmaintainable. Scope discipline prevents feature creep and ensures the server does one thing well.

### Mandatory Questions

| # | Question | Rationale |
|---|----------|-----------|
| 1.1 | What specific problem does this MCP server solve? | Forces a clear, one-sentence problem statement. If you can't articulate the problem, you can't design the solution. |
| 1.2 | Who are the consumers? (Claude Desktop, Cursor, custom app, multi-client) | Different clients have different capabilities and limitations. Claude Desktop supports stdio natively; custom apps may need HTTP. |
| 1.3 | List every tool the server will expose (name + one-sentence description) | The tool inventory is the scope boundary. If it's not on the list, it's not in scope. |
| 1.4 | Will the server expose resources or prompts in addition to tools? | Resources (read-only data) and prompts (reusable templates) are separate MCP primitives. Many servers only need tools. |
| 1.5 | What is explicitly OUT of scope? | Exclusions prevent scope creep. "We will NOT handle X" is as important as "we will handle Y." |
| 1.6 | Is MCP the right protocol, or would a REST API / GraphQL / CLI tool serve better? | MCP adds complexity. If the server is only consumed by your own app (not by LLM clients), a REST API is simpler. |
| 1.7 | What is the expected request volume? (per minute, per hour, per day) | Volume determines transport, hosting, and rate limiting decisions downstream. |

### Decision Criteria: MCP vs REST API

| Factor | Favors MCP | Favors REST API |
|--------|-----------|-----------------|
| Primary consumer | LLM clients (Claude, Cursor, etc.) | Your own application code |
| Tool discovery | Clients need to discover tools dynamically | Client knows the API surface at build time |
| Schema evolution | Tools evolve independently, clients adapt | API versioned as a whole |
| Multi-model support | Multiple LLM clients need the same tools | Single consumer |
| Human interaction | LLM decides when to call tools | Human or code decides |

### Red Flags

- "It does everything" -- a server without scope boundaries will be unmaintainable
- Tool count exceeds 15-20 -- consider splitting into multiple servers
- No clear consumer -- if you don't know who uses it, you can't design tool descriptions
- "We might need X later" -- design for today, not hypotheticals
- Every tool is read-write -- consider whether read-only tools can cover most use cases

### Done Criteria

- [ ] Problem statement is one sentence
- [ ] Consumer list is explicit (named clients)
- [ ] Tool inventory exists with name + description for each tool
- [ ] Resources and prompts decision is documented
- [ ] Out-of-scope list exists
- [ ] MCP vs REST decision is justified
- [ ] Expected volume is estimated

### Example: Weather API Server

| Question | Answer |
|----------|--------|
| 1.1 Problem | Provide weather data to LLM clients so they can answer weather-related questions with current data |
| 1.2 Consumers | Claude Desktop, Cursor, any MCP-compatible client |
| 1.3 Tools | `get_current_weather` (current conditions for a location), `get_forecast` (5-day forecast), `get_alerts` (active weather alerts), `search_locations` (find location IDs by name) |
| 1.4 Resources/Prompts | No resources or prompts -- tools only |
| 1.5 Out of scope | Historical weather data, satellite imagery, weather maps, climate predictions |
| 1.6 MCP vs REST | MCP -- primary consumers are LLM clients that need to decide when to fetch weather data |
| 1.7 Volume | ~100 requests/hour (personal use), up to 10,000/hour (public service) |

---

## Section 2: Transport

**Why this section exists:** Transport is the most consequential early decision. It cascades into auth (stdio needs none, HTTP needs some), hosting (stdio is local, HTTP needs a server), scaling (stdio is single-client, HTTP scales), and cost (stdio is free, HTTP has hosting costs).

### Mandatory Questions

| # | Question | Rationale |
|---|----------|-----------|
| 2.1 | Will the server run locally (same machine as client) or remotely (network)? | Local = stdio is natural. Remote = HTTP is required. |
| 2.2 | How many concurrent clients will connect? | stdio supports exactly one client per process. HTTP supports many. |
| 2.3 | Does the server need to push real-time updates to clients? | Streamable HTTP supports server-sent events. stdio supports notifications. |
| 2.4 | What are the network constraints? (firewall, VPN, air-gapped) | Firewalls may block incoming HTTP. stdio requires no network. |
| 2.5 | What latency is acceptable? | stdio has near-zero latency. HTTP adds network round-trip. |
| 2.6 | Is there a migration path? (start local, move to remote later) | Starting with stdio and migrating to HTTP later is a common pattern. Design for it if likely. |

### Decision Matrix

| Factor | stdio | Streamable HTTP | SSE (deprecated) |
|--------|-------|-----------------|-------------------|
| **Deployment** | Local only | Local or remote | Local or remote |
| **Client count** | 1 per process | Unlimited | Unlimited |
| **Auth needed** | No | Yes (for remote) | Yes (for remote) |
| **Network** | None | HTTP/HTTPS | HTTP/HTTPS |
| **Latency** | Minimal (IPC) | Network RTT | Network RTT |
| **Push updates** | Via notifications | Via SSE stream | Via SSE stream |
| **Hosting cost** | $0 | $5-50+/mo | $5-50+/mo |
| **SDK support** | All SDKs | All SDKs | Deprecated mid-2026 |
| **Best for** | Dev tools, IDE extensions, personal use | Team tools, public APIs, multi-client | Legacy only -- migrate to Streamable HTTP |

**Quick heuristic:**
- Local + single user + no auth needed = **stdio**
- Remote OR multi-client OR auth required = **Streamable HTTP**
- Never choose SSE for new servers -- it is deprecated

### Red Flags

- Choosing HTTP for a single-user local tool -- unnecessary complexity
- Choosing stdio for a team tool -- can't scale past one client
- "We'll add HTTP later" without designing for it now -- migration is harder than starting with HTTP
- Ignoring the SSE deprecation timeline -- do not build on SSE in 2026
- No consideration of cold start latency for serverless HTTP deployments

### Done Criteria

- [ ] Transport selected (stdio or Streamable HTTP)
- [ ] Rationale documented (why this transport, not the other)
- [ ] Migration path noted (if starting with stdio, when/whether HTTP migration is planned)
- [ ] ADR written for transport decision

### Example: Weather API Server

| Question | Answer |
|----------|--------|
| 2.1 Local/Remote | Remote -- public service accessible from any client |
| 2.2 Concurrent clients | Many -- public service |
| 2.3 Push updates | No -- request/response only |
| 2.4 Network constraints | None -- public internet |
| 2.5 Latency | Sub-second acceptable (weather data is not real-time critical) |
| 2.6 Migration path | N/A -- starting with HTTP |
| **Decision** | **Streamable HTTP** |

---

## Section 3: Authentication & Authorization

**Why this section exists:** Auth is the primary security boundary for remote MCP servers. Getting it wrong means unauthorized access to whatever data and systems the server touches. For local stdio servers, this section is simpler but not skippable -- credential management for downstream services still matters.

### Mandatory Questions

| # | Question | Rationale |
|---|----------|-----------|
| 3.1 | Who needs to authenticate? (end users, services, both, nobody) | Determines the auth pattern. |
| 3.2 | What auth pattern fits? (none, API key, OAuth 2.0, JWT) | See pattern comparison below. |
| 3.3 | Are there per-tool permission requirements? | Some tools may be admin-only, others public. |
| 3.4 | How are tokens/keys issued and rotated? | Keys that never rotate are keys that eventually leak. |
| 3.5 | Where are secrets stored? (env vars, vault, config file) | Secrets in source code is a critical vulnerability. |
| 3.6 | What happens when auth fails? (error response, rate limiting, alerting) | Graceful failure prevents information leakage. |
| 3.7 | Is token refresh handled? (for OAuth flows) | Expired tokens cause silent failures if not handled. |

### Pattern Comparison

| Pattern | Best For | Complexity | Transport | Key Consideration |
|---------|----------|------------|-----------|-------------------|
| **None** | Local stdio, personal use | Zero | stdio | Only safe when server runs locally |
| **API Key** | Simple remote, internal tools | Low | HTTP | Must rotate; store in vault, not code |
| **OAuth 2.0** | User-delegated access | High | HTTP | Handles user consent, token refresh |
| **JWT** | Service-to-service | Medium | HTTP | Stateless validation; key rotation critical |

> Full implementation patterns: `references/auth-patterns.md`

### Per-Tool Authorization Matrix

If different tools require different permissions, define a matrix:

| Tool | Public | Authenticated | Admin |
|------|--------|--------------|-------|
| `search_documents` | Yes | Yes | Yes |
| `get_document` | No | Yes | Yes |
| `create_document` | No | Yes | Yes |
| `delete_document` | No | No | Yes |

### Red Flags

- API keys in source code or config files checked into git
- No key rotation plan ("we'll rotate when we need to")
- OAuth without token refresh handling
- All tools accessible to all authenticated users (no granularity)
- No auth on a remote HTTP server ("it's just internal")
- Storing user passwords (use OAuth delegation instead)

### Done Criteria

- [ ] Auth pattern selected with rationale
- [ ] Token/key lifecycle defined (issuance, validation, rotation, revocation)
- [ ] Per-tool permission matrix defined (if applicable)
- [ ] Secrets storage mechanism chosen
- [ ] Auth failure behavior defined
- [ ] ADR written for auth decision (if non-trivial)

### Example: Weather API Server

| Question | Answer |
|----------|--------|
| 3.1 Who authenticates | Service consumers (API key identifies the client application) |
| 3.2 Pattern | API key -- simple, sufficient for rate limiting and usage tracking |
| 3.3 Per-tool permissions | No -- all tools are read-only and available to all authenticated clients |
| 3.4 Rotation | Keys can be regenerated via dashboard; old key invalid immediately |
| 3.5 Storage | API key passed via `Authorization: Bearer <key>` header; server validates against database |
| 3.6 Failure | 401 Unauthorized with JSON error body; rate limit 401s trigger temporary IP ban |
| 3.7 Refresh | N/A for API keys |

---

## Section 4: Data Stores

**Why this section exists:** Every data source the server touches introduces a dependency, a potential failure mode, and a security surface. Cataloging them upfront prevents surprises during implementation.

### Mandatory Questions

| # | Question | Rationale |
|---|----------|-----------|
| 4.1 | What databases does the server access? (type, version, location) | Each database is a dependency with its own connection management, failure modes, and security requirements. |
| 4.2 | What file systems does the server access? (paths, permissions) | File access introduces path traversal risks and sandboxing requirements. |
| 4.3 | What external APIs does the server call? (name, auth, rate limits) | External APIs have their own rate limits, SLAs, and failure modes that cascade into your server. |
| 4.4 | For each data source: read-only or read-write? | Read-only is dramatically safer. Read-write requires validation, confirmation, and audit trails. |
| 4.5 | Who owns the data? (your org, user, third party) | Data ownership determines privacy obligations, retention policies, and deletion requirements. |
| 4.6 | What's the caching strategy? (none, in-memory, Redis, TTL) | Caching reduces load on data sources but introduces staleness. |
| 4.7 | How are connections managed? (per-request, pool, singleton) | Connection pooling prevents resource exhaustion; per-request connections are simpler but wasteful. |
| 4.8 | What happens when a data source is unavailable? | Graceful degradation is better than cascading failure. |

### Data Source Catalog Template

| Data Source | Type | Access | Owner | Connection | Cache TTL | Failure Mode |
|-------------|------|--------|-------|------------|-----------|--------------|
| PostgreSQL (users) | Database | Read-only | Our org | Connection pool (10) | None | Return error |
| OpenWeatherMap | External API | Read-only | Third party | Per-request | 5 min | Return cached/error |
| `/data/uploads/` | File system | Read-write | User | Direct | None | Return error |

> Full data integration patterns: `references/data-store-patterns.md`

### Red Flags

- Database credentials hardcoded in source
- No connection pooling for databases with >10 concurrent connections
- External API without rate limit awareness (your server will be the bottleneck)
- File system access without path validation (path traversal vulnerability)
- Read-write access where read-only would suffice
- No caching for frequently-accessed, slowly-changing data
- No plan for data source unavailability

### Done Criteria

- [ ] Every data source cataloged (type, access pattern, owner)
- [ ] Read-only vs read-write justified for each source
- [ ] Connection management strategy defined
- [ ] Caching strategy defined (or explicitly "no caching" with rationale)
- [ ] Failure modes documented
- [ ] Data ownership and privacy obligations noted

### Example: Weather API Server

| Question | Answer |
|----------|--------|
| 4.1 Databases | None -- stateless server |
| 4.2 File systems | None |
| 4.3 External APIs | OpenWeatherMap API v3.0 (API key auth, 60 calls/min free tier) |
| 4.4 Access pattern | Read-only (all tools fetch data, none modify) |
| 4.5 Data ownership | Third party (OpenWeatherMap owns the data) |
| 4.6 Caching | In-memory cache, 5-minute TTL for current weather, 30-minute TTL for forecasts |
| 4.7 Connections | Per-request HTTP calls to OpenWeatherMap |
| 4.8 Unavailability | Return cached data if available; otherwise return error with "service unavailable" message |

---

## Section 5: Security

**Why this section exists:** Security is not a feature to add later. It is an architectural property that must be designed in from the start. MCP servers are particularly sensitive because they execute actions on behalf of LLMs, which can be manipulated via prompt injection.

### Mandatory Questions

| # | Question | Rationale |
|---|----------|-----------|
| 5.1 | How is input validated for each tool? (schema validation, sanitization, allowlists) | Every tool input is an attack surface. Schema validation is the first line of defense. |
| 5.2 | What rate limiting strategy applies? (per-tool, per-client, global) | Without rate limiting, a single client can exhaust resources or run up costs. |
| 5.3 | How are secrets managed? (env vars, vault, rotation schedule) | Secrets in code or config files are the most common security vulnerability. |
| 5.4 | Is audit logging implemented? (what, when, who) | Audit logs are essential for incident investigation and compliance. |
| 5.5 | What does the threat model look like? | A threat model forces systematic thinking about attack vectors. Complete the worksheet in `assets/security-threat-model-worksheet.md`. |
| 5.6 | How is prompt injection via tool results mitigated? | MCP-specific risk: a malicious data source could embed instructions in tool results that manipulate the LLM. |
| 5.7 | How is SSRF prevented? (if tools accept URLs or network addresses) | Tools that accept user-supplied URLs can be used to scan internal networks. |
| 5.8 | How is path traversal prevented? (if tools accept file paths) | Tools that accept file paths can be used to read/write outside intended directories. |

### MCP-Specific Security Risks

| Risk | Description | Mitigation |
|------|-------------|------------|
| **Prompt injection via results** | Tool results containing instructions that manipulate the LLM | Sanitize tool output; strip control characters; format as structured data, not natural language instructions |
| **SSRF via URL parameters** | Tools accepting URLs used to probe internal networks | Validate URLs against allowlist; block private IP ranges (10.x, 172.16-31.x, 192.168.x) |
| **Path traversal** | Tools accepting file paths used to access sensitive files | Resolve to absolute path, verify within sandbox; reject `..` components; resolve symlinks |
| **SQL injection** | Tools passing user input to database queries | Parameterized queries only; never string concatenation |
| **Resource exhaustion** | Tools with unbounded computation or data retrieval | Timeouts, result size limits, query complexity limits |
| **Credential leakage** | Tool errors exposing connection strings or API keys | Sanitize error messages; never include credentials in tool results |

> Full rate limiting patterns: `references/rate-limiting-patterns.md`

### Red Flags

- "We'll add security later" -- security is architecture, not a feature
- No input validation beyond JSON Schema type checking
- No rate limiting on tools that call external APIs (cost exposure)
- Secrets in environment variables without rotation plan
- No audit logging ("we trust our users")
- Tool results containing raw database error messages
- File path parameters without sandboxing
- URL parameters without SSRF protection

### Done Criteria

- [ ] Input validation strategy defined for each tool
- [ ] Rate limiting strategy defined
- [ ] Secrets management approach documented
- [ ] Audit logging plan in place
- [ ] Threat model worksheet completed (`assets/security-threat-model-worksheet.md`)
- [ ] MCP-specific risks addressed (prompt injection, SSRF, path traversal)
- [ ] Error message sanitization strategy defined

### Example: Weather API Server

| Question | Answer |
|----------|--------|
| 5.1 Input validation | JSON Schema validation via SDK; location strings sanitized (alphanumeric + comma + space only); coordinates validated as valid lat/lon ranges |
| 5.2 Rate limiting | Per-API-key: 60 requests/minute (matching upstream limit). Per-tool: `search_locations` limited to 10/min (expensive). Global: 1000 requests/minute |
| 5.3 Secrets | OpenWeatherMap API key in env var `OWM_API_KEY`; rotated quarterly |
| 5.4 Audit logging | Log: tool name, client ID (hashed API key), timestamp, response time. Do NOT log: full API keys, user IP addresses |
| 5.5 Threat model | See completed worksheet. Key threats: API key abuse, upstream API exhaustion |
| 5.6 Prompt injection | Low risk -- weather data is structured (numbers, short strings). Tool results formatted as JSON, not natural language |
| 5.7 SSRF | N/A -- no tools accept URLs |
| 5.8 Path traversal | N/A -- no tools accept file paths |

---

## Section 6: Hosting & Deployment

**Why this section exists:** Hosting determines cost, operational burden, latency, and scaling characteristics. The right choice depends on transport, expected load, team capacity, and budget.

### Mandatory Questions

| # | Question | Rationale |
|---|----------|-----------|
| 6.1 | Where will the server run? (local, VPS, serverless, managed, Kubernetes) | Each option has different cost, ops, and scaling characteristics. |
| 6.2 | What is the monthly cost budget? | Cost constrains options. stdio is free; serverless can surprise you. |
| 6.3 | Who operates the server? (developer, ops team, nobody/serverless) | Operational burden varies dramatically between options. |
| 6.4 | What is the scaling strategy? (single instance, horizontal, auto-scale) | Scaling must match expected load growth. |
| 6.5 | How is the server deployed? (Docker, binary, npm package, source) | Deployment mechanism affects CI/CD, versioning, and rollback. |
| 6.6 | What monitoring is in place? (health checks, metrics, alerting) | A server you can't monitor is a server you can't fix. |
| 6.7 | What is the disaster recovery plan? (backups, failover, rollback) | For stateful servers, data loss is the worst outcome. |

> Full hosting comparison: `references/hosting-decision-matrix.md`

### Red Flags

- No monitoring or health checks
- Serverless without cold start awareness (first request after idle may take 5-15 seconds)
- VPS without automated deployment (manual SSH deploys are error-prone)
- Kubernetes for a single-developer project (operational overhead exceeds benefit)
- No cost estimate ("we'll figure it out")
- No rollback plan ("we'll fix forward")

### Done Criteria

- [ ] Hosting option selected with rationale
- [ ] Monthly cost estimated
- [ ] Operational responsibility assigned
- [ ] Scaling strategy defined
- [ ] Deployment mechanism chosen
- [ ] Monitoring plan in place
- [ ] DR plan documented (or "N/A -- stateless" with justification)
- [ ] ADR written for hosting decision

### Example: Weather API Server

| Question | Answer |
|----------|--------|
| 6.1 Hosting | Google Cloud Run (serverless containers) |
| 6.2 Cost | ~$5-15/month at expected volume (free tier covers most of it) |
| 6.3 Operations | Nobody -- Cloud Run is fully managed |
| 6.4 Scaling | Auto-scale 0-10 instances based on request volume |
| 6.5 Deployment | Docker container deployed via `gcloud run deploy` from CI |
| 6.6 Monitoring | Cloud Run built-in metrics + Cloud Logging; alert on 5xx rate >5% |
| 6.7 DR | Stateless -- no DR needed. Redeploy from container image. |

---

## Section 7: Discovery & Registration

**Why this section exists:** Clients need to know the server exists, where it lives, and how to connect. For local stdio servers, this is simple (configuration file). For remote HTTP servers, discovery becomes a real problem at scale.

### Mandatory Questions

| # | Question | Rationale |
|---|----------|-----------|
| 7.1 | How do clients discover this server? (manual config, registry, DNS) | Discovery mechanism determines how easy it is to adopt the server. |
| 7.2 | Is the server registered in any MCP registry or marketplace? | Registries increase visibility but may have requirements. |
| 7.3 | What configuration does a client need? (URL, API key, options) | Minimize configuration burden -- fewer fields means faster adoption. |
| 7.4 | Is there multi-server orchestration? (this server depends on or coordinates with other MCP servers) | Server dependencies create implicit coupling. |
| 7.5 | How is the server documented for consumers? (README, API docs, examples) | Without documentation, even a well-designed server won't be adopted. |

### Discovery Mechanisms

| Mechanism | How It Works | Best For |
|-----------|-------------|----------|
| **Manual config** | User adds server URL/command to client config | Personal tools, small teams |
| **Package manager** | `npm install`, `pip install` | Open source tools, CLI-based servers |
| **Registry** | Listed in an MCP server registry | Public servers seeking adoption |
| **DNS/Well-known** | `/.well-known/mcp` endpoint | Enterprise, standardized discovery |
| **Documentation** | README with copy-paste config | Most common starting point |

### Red Flags

- No documentation (the server exists but nobody knows how to use it)
- Complex configuration (more than 3 fields to get started)
- Undocumented server dependencies
- No example configurations for popular clients (Claude Desktop, Cursor)

### Done Criteria

- [ ] Discovery mechanism chosen
- [ ] Client configuration documented (with examples for target clients)
- [ ] Server dependencies listed (if any)
- [ ] Documentation plan in place

### Example: Weather API Server

| Question | Answer |
|----------|--------|
| 7.1 Discovery | Documentation (README) + npm package for easy installation |
| 7.2 Registry | Listed on MCP server registry after launch |
| 7.3 Configuration | URL + API key (2 fields) |
| 7.4 Multi-server | None -- standalone server |
| 7.5 Documentation | README with quickstart, Claude Desktop config example, tool reference |

---

## Section 8: Versioning & Lifecycle

**Why this section exists:** Tools evolve. Descriptions improve, schemas change, new tools appear, old tools retire. Without a versioning strategy, every change risks breaking existing clients.

### Mandatory Questions

| # | Question | Rationale |
|---|----------|-----------|
| 8.1 | What versioning scheme applies? (semver, date-based, unversioned) | Semantic versioning communicates change impact (major = breaking, minor = additive, patch = fix). |
| 8.2 | What constitutes a breaking change? | Define explicitly: removing a tool, changing required inputs, changing output format. |
| 8.3 | What is the deprecation policy? (timeline, notification, migration guide) | Clients need warning and time to adapt before tools are removed. |
| 8.4 | How is backward compatibility maintained? | Strategies: additive-only changes, new tools for new behavior, version negotiation. |
| 8.5 | How are clients notified of changes? (changelog, email, in-protocol) | Silent changes cause silent breakage. |
| 8.6 | What is the minimum support window for deprecated tools? | Give clients a concrete timeline (e.g., 90 days after deprecation notice). |

### Breaking vs Non-Breaking Changes

| Change Type | Breaking? | Strategy |
|-------------|-----------|----------|
| Add new tool | No | Just add it |
| Add optional input to existing tool | No | Default value required |
| Add required input to existing tool | **Yes** | Create new tool instead |
| Remove a tool | **Yes** | Deprecate first, remove after support window |
| Change input type | **Yes** | Create new tool instead |
| Change output format | **Yes** | Version the output or create new tool |
| Improve description text | No | Just update it |
| Fix a bug in tool behavior | Maybe | Judgment call -- document the change |

### Red Flags

- No versioning at all ("it's just a side project")
- Breaking changes without deprecation
- No changelog
- Removing tools without notice
- Changing tool behavior silently

### Done Criteria

- [ ] Versioning scheme chosen (semver recommended)
- [ ] Breaking change definition documented
- [ ] Deprecation policy defined with timeline
- [ ] Backward compatibility strategy documented
- [ ] Client notification mechanism chosen
- [ ] Minimum support window defined

### Example: Weather API Server

| Question | Answer |
|----------|--------|
| 8.1 Versioning | Semantic versioning (e.g., 1.0.0, 1.1.0, 2.0.0) |
| 8.2 Breaking changes | Removing a tool, adding required inputs, changing output schema |
| 8.3 Deprecation | 90-day notice via changelog and tool description annotation |
| 8.4 Backward compat | Additive-only changes; new tools for new behavior |
| 8.5 Notification | CHANGELOG.md in repo; deprecation warnings in tool descriptions |
| 8.6 Support window | 90 days minimum from deprecation notice to removal |

---

## Checklist Summary

Use this as a quick reference to verify all sections are complete.

| Section | Status | Key Decision | ADR? |
|---------|--------|-------------|------|
| 1. Purpose & Scope | [ ] | Problem: ______ | -- |
| 2. Transport | [ ] | Transport: ______ | [ ] |
| 3. Auth & Authz | [ ] | Pattern: ______ | [ ] |
| 4. Data Stores | [ ] | Sources: ______ | -- |
| 5. Security | [ ] | Threat model: ______ | -- |
| 6. Hosting | [ ] | Hosting: ______ | [ ] |
| 7. Discovery | [ ] | Mechanism: ______ | -- |
| 8. Versioning | [ ] | Scheme: ______ | -- |

**Spec is complete when all 8 sections show [x] and all required ADRs are written.**
