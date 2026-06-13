# Security Threat Model Worksheet

> Fillable threat model for an MCP server. Complete this as part of specification checklist Section 5 (Security).
> See `references/specification-checklist.md` for context.

**Server Name:** _____
**Date:** _____
**Author:** _____

---

## 1. Assets (What Are We Protecting?)

_List everything of value that the server accesses, stores, or transmits._

| Asset | Sensitivity | Location | Owner |
|-------|------------|----------|-------|
| _Database credentials_ | _Critical_ | _Environment variables_ | _Our org_ |
| _API keys (downstream)_ | _Critical_ | _Environment variables_ | _Our org_ |
| _Client API keys_ | _High_ | _Database (hashed)_ | _Our org_ |
| _User query data_ | _Medium_ | _In transit (not stored)_ | _User_ |
| _Query results_ | _Varies_ | _In transit_ | _Data owner_ |
| | | | |
| | | | |

---

## 2. Threat Actors (Who Might Attack?)

| Actor | Motivation | Capability | Likelihood |
|-------|-----------|------------|------------|
| **Malicious prompts** | Exfiltrate data, execute commands | Craft tool inputs via prompt injection | Medium |
| **Compromised LLM client** | Unauthorized tool execution | Full tool access with valid credentials | Low |
| **Network attacker** | Intercept data, MITM | Network traffic interception | Low (if TLS) / High (if no TLS) |
| **Insider (authorized user)** | Data exfiltration, abuse | Legitimate access, knowledge of system | Low |
| **Automated scanner** | Find vulnerabilities | Port scanning, brute force | Medium (if HTTP) / None (if stdio) |
| | | | |

---

## 3. Attack Surfaces

### 3a. Tool Inputs

_For each tool, what inputs could be malicious?_

| Tool | Input | Attack Vector | Severity | Mitigation |
|------|-------|--------------|----------|------------|
| | | | | |
| | | | | |
| | | | | |

### 3b. Transport Layer

| Surface | Threat | Applies? | Mitigation |
|---------|--------|----------|------------|
| Network listener (HTTP) | Unauthorized access | Yes / No / N/A (stdio) | _Auth, TLS, IP allowlist_ |
| Unencrypted transport | Data interception | Yes / No / N/A | _TLS 1.2+_ |
| Session management | Session hijacking | Yes / No / N/A | _Secure session tokens_ |

### 3c. Data Stores

| Data Store | Threat | Applies? | Mitigation |
|------------|--------|----------|------------|
| Database | SQL injection | Yes / No / N/A | _Parameterized queries_ |
| Database | Credential exposure | Yes / No | _Env vars, vault, rotation_ |
| File system | Path traversal | Yes / No / N/A | _Sandboxing, path validation_ |
| File system | Symlink escape | Yes / No / N/A | _Realpath resolution_ |
| External API | SSRF | Yes / No / N/A | _URL allowlist, block private IPs_ |
| External API | Credential leakage in errors | Yes / No | _Error sanitization_ |

### 3d. Authentication

| Surface | Threat | Applies? | Mitigation |
|---------|--------|----------|------------|
| API keys | Key leakage | Yes / No / N/A | _Hashed storage, rotation_ |
| API keys | Brute force | Yes / No | _Rate limiting, key length_ |
| OAuth tokens | Token theft | Yes / No / N/A | _Short expiry, refresh flow_ |
| JWT | Key compromise | Yes / No / N/A | _JWKS rotation_ |

---

## 4. MCP-Specific Threats

| Threat | Description | Applies? | Severity | Mitigation |
|--------|-------------|----------|----------|------------|
| **Prompt injection via tool results** | Tool returns data containing instructions that manipulate the LLM | Yes / No | | _Structured JSON output, strip control chars_ |
| **Tool confusion** | LLM calls wrong tool due to ambiguous descriptions | Yes / No | | _Clear, disambiguating descriptions_ |
| **Excessive tool calling** | LLM loops, calling tools hundreds of times | Yes / No | | _Rate limiting, circuit breaker_ |
| **Data exfiltration via tool chain** | LLM reads sensitive data with one tool, sends it somewhere with another | Yes / No | | _Per-tool permissions, audit logging_ |
| **Privilege escalation** | Tool exposes more capability than intended | Yes / No | | _Minimum necessary permissions_ |

---

## 5. Mitigations Summary

| Mitigation | Implemented? | Priority | Notes |
|------------|-------------|----------|-------|
| Input validation (JSON Schema) | [ ] | Critical | _Per-tool validation_ |
| Input validation (beyond schema) | [ ] | High | _Regex, allowlists, range checks_ |
| Rate limiting | [ ] | High | _Per-client, per-tool, global_ |
| TLS encryption | [ ] | Critical (HTTP) / N/A (stdio) | |
| Authentication | [ ] | Critical (HTTP) / N/A (stdio) | |
| Authorization (per-tool) | [ ] | Medium | _If tools have different sensitivity_ |
| Audit logging | [ ] | Medium | _Tool calls, auth events_ |
| Error sanitization | [ ] | High | _No credentials in errors_ |
| Secrets in vault | [ ] | High | _Not in code or config_ |
| Secrets rotation schedule | [ ] | Medium | |
| Dependency scanning | [ ] | Medium | _npm audit / pip audit_ |
| Container scanning | [ ] | Medium (if Docker) | |

---

## 6. Residual Risks

_Risks that remain after mitigations are in place. These are accepted risks._

| Risk | Severity | Likelihood | Acceptance Rationale |
|------|----------|-----------|---------------------|
| | | | |
| | | | |

---

## 7. Monitoring Strategy

_How will you detect if something goes wrong?_

| Signal | Detection Method | Response |
|--------|-----------------|----------|
| Unusual request volume | Rate limit alerts | Investigate, potentially revoke key |
| Auth failures spike | Log monitoring | Check for brute force, tighten limits |
| Error rate increase | Error rate alert | Investigate, check dependencies |
| Slow queries | Latency monitoring | Check data stores, add indexes/limits |
| Upstream API failures | Error tracking | Switch to cached data, alert team |
| | | |

---

## Review

| Date | Reviewer | Changes |
|------|----------|---------|
| _YYYY-MM-DD_ | _Name_ | _Initial threat model_ |
| | | |
