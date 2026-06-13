# Security Checklist

Pre-deployment security gate. Complete before promoting to any environment that accepts untrusted input. Each item is pass/fail/NA. A single FAIL blocks promotion unless explicitly accepted with a documented risk owner.

**Agent:** _______________  
**Version:** _______________  
**Environment:** [ ] Dev  [ ] Staging  [ ] Production  
**Reviewed by:** _______________  
**Date:** _______________  

---

## Layer 1: Input Guards

Defenses applied before any input reaches the LLM or tools.

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 1.1 | **Injection detection** — static pattern match or classifier rejects known injection strings (e.g., "ignore previous instructions", "system:", "DAN mode") | [ ] Pass  [ ] Fail  [ ] N/A | |
| 1.2 | **Indirect injection surface identified** — all sources of external content (web pages, documents, DB rows, tool outputs) that will be injected into context are inventoried | [ ] Pass  [ ] Fail  [ ] N/A | |
| 1.3 | **Indirect injection mitigated** — external content is sanitized, quoted, or sandboxed before insertion into prompt | [ ] Pass  [ ] Fail  [ ] N/A | |
| 1.4 | **PII detection on input** — user input is scanned for PII (emails, SSNs, credit cards) and handled per policy (block / mask / log-only) | [ ] Pass  [ ] Fail  [ ] N/A | |
| 1.5 | **Token limit enforcement** — maximum input token count enforced per request and per session; oversized requests rejected with a clear error, not silently truncated | [ ] Pass  [ ] Fail  [ ] N/A | |
| 1.6 | **Content-type validation** — if the agent accepts structured input (JSON, YAML), schema validation runs before parsing | [ ] Pass  [ ] Fail  [ ] N/A | |
| 1.7 | **System prompt is not user-visible** — system prompt cannot be extracted by any known prompt technique (tested) | [ ] Pass  [ ] Fail  [ ] N/A | |
| 1.8 | **Multimodal content scanned** — if images/audio/files accepted, malicious content scanning is in place | [ ] Pass  [ ] Fail  [ ] N/A | |

---

## Layer 2: Tool Sandbox

Controls on what tools the agent can call and what those tools can do.

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 2.1 | **Least-privilege tool access** — each tool has only the permissions it needs; no tool has broad write/admin access unless explicitly required | [ ] Pass  [ ] Fail  [ ] N/A | |
| 2.2 | **Tool allowlist enforced** — agent can only call declared tools; no dynamic tool registration from user input | [ ] Pass  [ ] Fail  [ ] N/A | |
| 2.3 | **Destructive tools require confirmation** — any tool that writes, deletes, sends, or pays requires explicit human approval or a second LLM safety check | [ ] Pass  [ ] Fail  [ ] N/A | |
| 2.4 | **Tool call timeout** — each tool invocation has a hard timeout; hung tools do not block the agent indefinitely | [ ] Pass  [ ] Fail  [ ] N/A | |
| 2.5 | **Tool output size limit** — tool responses are capped at a maximum token count before being injected into context | [ ] Pass  [ ] Fail  [ ] N/A | |
| 2.6 | **Tool output sanitized** — tool output is treated as untrusted input (see 1.3 above); not naively injected into prompt | [ ] Pass  [ ] Fail  [ ] N/A | |
| 2.7 | **Code execution sandboxed** — if the agent can execute code, it runs in an isolated environment (container, subprocess, no network, no filesystem access beyond a temp dir) | [ ] Pass  [ ] Fail  [ ] N/A | |
| 2.8 | **External API credentials not exposed to LLM** — API keys, tokens, and passwords used by tools are never included in the LLM context | [ ] Pass  [ ] Fail  [ ] N/A | |
| 2.9 | **Max tool calls per turn** — a hard ceiling on consecutive tool calls prevents runaway loops | [ ] Pass  [ ] Fail  [ ] N/A | |
| 2.10 | **Tool error handling** — tool failures return structured errors, not raw exceptions that might expose stack traces or internal paths | [ ] Pass  [ ] Fail  [ ] N/A | |

---

## Layer 3: Output Guards

Defenses applied to LLM output before it reaches the user.

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 3.1 | **Content policy filter** — output is scanned for prohibited categories (harm, CSAM, extremism, per-policy prohibited topics) | [ ] Pass  [ ] Fail  [ ] N/A | |
| 3.2 | **Format validation** — if output is expected to be JSON/XML/structured, schema validation runs before returning to caller | [ ] Pass  [ ] Fail  [ ] N/A | |
| 3.3 | **PII detection on output** — output is scanned for PII; any PII not authorized by the user's own input is blocked or masked | [ ] Pass  [ ] Fail  [ ] N/A | |
| 3.4 | **No credential leakage** — output does not contain API keys, tokens, internal URLs, or secrets from context | [ ] Pass  [ ] Fail  [ ] N/A | |
| 3.5 | **No system prompt leakage** — output does not reveal system prompt contents even in paraphrase | [ ] Pass  [ ] Fail  [ ] N/A | |
| 3.6 | **Hallucination risk communicated** — if the agent synthesizes factual claims, uncertainty is expressed or citations are provided | [ ] Pass  [ ] Fail  [ ] N/A | |
| 3.7 | **Output length capped** — maximum response token count enforced to prevent cost blowouts | [ ] Pass  [ ] Fail  [ ] N/A | |

---

## Layer 4: Cost Controls

Prevents runaway spend from abuse or misconfiguration.

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 4.1 | **Per-request cost ceiling** — requests that would exceed a cost threshold are rejected before the LLM call | [ ] Pass  [ ] Fail  [ ] N/A | |
| 4.2 | **Per-session token budget** — cumulative token count per conversation session is tracked and capped | [ ] Pass  [ ] Fail  [ ] N/A | |
| 4.3 | **Per-user daily budget** — each user (or API key) has a daily spend limit; requests beyond the limit are rate-limited or queued | [ ] Pass  [ ] Fail  [ ] N/A | |
| 4.4 | **Global budget alarm** — an alert fires when monthly spend crosses a threshold (e.g., 80% of budget); a hard kill switch exists | [ ] Pass  [ ] Fail  [ ] N/A | |
| 4.5 | **Prompt caching enabled** — where applicable, prompt caching is enabled to reduce cost on repeated system prompt tokens | [ ] Pass  [ ] Fail  [ ] N/A | |

---

## Layer 5: Rate Limiting

Prevents abuse via volume.

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 5.1 | **Request rate limit per user** — requests per second / minute / hour per user enforced at the API gateway or middleware layer | [ ] Pass  [ ] Fail  [ ] N/A | |
| 5.2 | **Token rate limit per user** — input + output tokens per minute per user enforced (prevents high-volume cheap requests that consume large context) | [ ] Pass  [ ] Fail  [ ] N/A | |
| 5.3 | **Global rate limit** — aggregate request rate across all users has a ceiling to protect downstream APIs | [ ] Pass  [ ] Fail  [ ] N/A | |
| 5.4 | **Backpressure behavior defined** — when rate limits are hit, behavior is defined: 429 with retry-after header, queue, or graceful degradation | [ ] Pass  [ ] Fail  [ ] N/A | |
| 5.5 | **Burst handling** — short bursts above the rate limit are handled gracefully (token bucket or sliding window, not hard cutoff) | [ ] Pass  [ ] Fail  [ ] N/A | |

---

## Layer 6: Authentication and Authorization

Controls on who can use the agent and what they can do.

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 6.1 | **All endpoints require authentication** — no unauthenticated access to agent APIs in production | [ ] Pass  [ ] Fail  [ ] N/A | |
| 6.2 | **API keys rotatable** — API keys can be rotated without service downtime; rotation procedure is documented | [ ] Pass  [ ] Fail  [ ] N/A | |
| 6.3 | **API keys scoped** — each API key has the minimum permission set needed; no single key has global admin access | [ ] Pass  [ ] Fail  [ ] N/A | |
| 6.4 | **User identity propagated** — if users can be identified, their identity is attached to every LLM call for audit purposes | [ ] Pass  [ ] Fail  [ ] N/A | |
| 6.5 | **Role-based access to tools** — if multiple user roles exist, tool access is gated by role (e.g., only admins can call delete tools) | [ ] Pass  [ ] Fail  [ ] N/A | |
| 6.6 | **Session tokens expire** — session tokens have a defined expiry; refresh token rotation is implemented | [ ] Pass  [ ] Fail  [ ] N/A | |

---

## Layer 7: Audit Logging

Everything the agent does must be observable and reconstructable.

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 7.1 | **Every LLM call logged** — request ID, timestamp, model, input tokens, output tokens, latency, user ID, cost estimate | [ ] Pass  [ ] Fail  [ ] N/A | |
| 7.2 | **Every tool call logged** — tool name, arguments (sanitized), result summary, success/fail, latency | [ ] Pass  [ ] Fail  [ ] N/A | |
| 7.3 | **Guard trigger events logged** — every time an input or output guard fires, the event is logged with the triggering content (or a hash if content is sensitive) | [ ] Pass  [ ] Fail  [ ] N/A | |
| 7.4 | **Logs are tamper-evident** — logs are written to a sink that cannot be modified by the application (e.g., append-only log service, separate account) | [ ] Pass  [ ] Fail  [ ] N/A | |
| 7.5 | **Log retention policy defined** — retention period is set per compliance requirements; PII in logs is handled per data policy | [ ] Pass  [ ] Fail  [ ] N/A | |
| 7.6 | **Alerting on anomalies** — alerts fire on unusual patterns: spike in guard triggers, cost anomaly, error rate spike, injection attempt rate | [ ] Pass  [ ] Fail  [ ] N/A | |
| 7.7 | **Full conversation reconstructable** — given a request ID, the full conversation and tool call chain can be replayed for debugging | [ ] Pass  [ ] Fail  [ ] N/A | |

---

## Layer 8: Memory Security

Controls on agent memory systems.

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 8.1 | **Memory namespaced by user** — if multiple users share an agent, their memories are strictly isolated (no cross-user memory read/write) | [ ] Pass  [ ] Fail  [ ] N/A | |
| 8.2 | **PII in memory handled** — if PII can be stored in memory (e.g., user-provided context), storage, access, and deletion are per data policy | [ ] Pass  [ ] Fail  [ ] N/A | |
| 8.3 | **Memory poisoning detection** — if a user can write to shared memory (e.g., shared knowledge base), validation prevents injection of adversarial content | [ ] Pass  [ ] Fail  [ ] N/A | |
| 8.4 | **Memory expiry** — stale memories expire; no unbounded growth of memory stores | [ ] Pass  [ ] Fail  [ ] N/A | |
| 8.5 | **Memory access logged** — reads and writes to long-term memory are audited | [ ] Pass  [ ] Fail  [ ] N/A | |
| 8.6 | **Vector store access control** — if a vector store is used, embedding retrieval is scoped to the requesting user's authorized data | [ ] Pass  [ ] Fail  [ ] N/A | |

---

## Layer 9: Deployment

Infrastructure-level security.

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 9.1 | **TLS enforced** — all traffic between client, agent, and upstream APIs is TLS 1.2+; HTTP is rejected | [ ] Pass  [ ] Fail  [ ] N/A | |
| 9.2 | **Network isolation** — agent service cannot reach internal network resources it doesn't need; egress filtered | [ ] Pass  [ ] Fail  [ ] N/A | |
| 9.3 | **Secrets in secret manager** — API keys and credentials are stored in a secret manager (Vault, AWS Secrets Manager, etc.), not in env files or code | [ ] Pass  [ ] Fail  [ ] N/A | |
| 9.4 | **Container runs as non-root** — if containerized, the agent process runs as a non-root user with a read-only filesystem where possible | [ ] Pass  [ ] Fail  [ ] N/A | |
| 9.5 | **Dependencies pinned and scanned** — dependency versions are pinned; a CVE scanner runs in CI | [ ] Pass  [ ] Fail  [ ] N/A | |
| 9.6 | **Health check endpoint exists** — a `/health` or equivalent endpoint enables monitoring without exposing sensitive state | [ ] Pass  [ ] Fail  [ ] N/A | |
| 9.7 | **Graceful shutdown** — agent handles SIGTERM; in-flight requests complete before shutdown | [ ] Pass  [ ] Fail  [ ] N/A | |
| 9.8 | **Incident response runbook exists** — documented steps for: compromised key, data breach, runaway cost, injection attack in production | [ ] Pass  [ ] Fail  [ ] N/A | |

---

## Summary

| Layer | Items | Pass | Fail | N/A |
|-------|-------|------|------|-----|
| 1. Input Guards | 8 | | | |
| 2. Tool Sandbox | 10 | | | |
| 3. Output Guards | 7 | | | |
| 4. Cost Controls | 5 | | | |
| 5. Rate Limiting | 5 | | | |
| 6. Auth & AuthZ | 6 | | | |
| 7. Audit Logging | 7 | | | |
| 8. Memory Security | 6 | | | |
| 9. Deployment | 8 | | | |
| **Total** | **62** | | | |

**Promotion decision:**  
[ ] Approved for target environment  
[ ] Approved with accepted risks (document below)  
[ ] Blocked — remediation required  

**Accepted risks (if any):**
```
[Document any FAIL items that are accepted, with owner and timeline for remediation]
```
