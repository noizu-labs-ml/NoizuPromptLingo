# MCP Server Specification: [Server Name]

> Generated from the trl-mcp-architect specification checklist. Fill in each section below.
> Checklist reference: `references/specification-checklist.md`

---

## Overview

| Field | Value |
|-------|-------|
| **Server Name** | |
| **Version** | |
| **Description** | |
| **Author** | |
| **Date** | |
| **Status** | Draft / In Review / Approved |

---

## Section 1: Purpose & Scope

**Problem Statement:**
_One sentence describing what problem this server solves._

**Consumers:**
_List every client that will use this server (Claude Desktop, Cursor, custom app, etc.)._

**Tool Inventory:**

| Tool Name | Description | Read/Write |
|-----------|-------------|------------|
| | | |
| | | |

**Resources:** _Will the server expose MCP resources? If so, list them._

**Prompts:** _Will the server expose MCP prompts? If so, list them._

**Out of Scope:**
- _What this server will NOT do_

**MCP vs REST Decision:**
- **Decision:** MCP / REST API
- **Rationale:** _Why this protocol?_

**Expected Volume:** _Requests per hour/day_

---

## Section 2: Transport

**Decision:** stdio / Streamable HTTP
**Rationale:** _Why this transport?_

**Alternatives Considered:**
- _Alternative 1:_ _Why rejected_

**Migration Path:** _If starting with stdio, when/if HTTP migration is planned_

**ADR:** ADR-_NNN_ (see ADR file)

---

## Section 3: Authentication & Authorization

**Auth Pattern:** None / API Key / OAuth 2.0 / JWT
**Rationale:** _Why this pattern?_

**Token/Key Lifecycle:**
- Issuance: _How are keys/tokens created?_
- Validation: _How are they checked per request?_
- Rotation: _How and when are they rotated?_
- Revocation: _How are they invalidated?_

**Per-Tool Permissions:**

| Tool | Public | Authenticated | Admin |
|------|--------|--------------|-------|
| | | | |

**Secrets Storage:**
- _Where are downstream credentials stored?_

**Auth Failure Behavior:**
- Missing credentials: _Response_
- Invalid credentials: _Response_
- Expired credentials: _Response_

**ADR:** ADR-_NNN_ (if non-trivial)

---

## Section 4: Data Stores

**Data Source Catalog:**

| Source | Type | Access | Owner | Connection | Cache TTL | Failure Mode |
|--------|------|--------|-------|------------|-----------|--------------|
| | | | | | | |

**Connection Management:**
- Strategy: _Per-request / Pool / Singleton_
- Pool size: _N_
- Timeout: _N seconds_

**Caching Strategy:**
_Describe caching approach or state "No caching" with rationale._

**Failure Modes:**
_What happens when each data source is unavailable?_

---

## Section 5: Security

**Input Validation:**

| Tool | Input | Validation Rule |
|------|-------|----------------|
| | | |

**Rate Limiting:**

| Scope | Limit | Algorithm |
|-------|-------|-----------|
| | | |

**Secrets Management:**

| Secret | Storage | Rotation |
|--------|---------|----------|
| | | |

**Audit Logging:**
_What is logged? What is NOT logged?_

**Threat Model:**
_See completed threat model worksheet (assets/security-threat-model-worksheet.md)_

**MCP-Specific Risks:**
- Prompt injection via results: _Mitigation_
- SSRF: _Mitigation or N/A_
- Path traversal: _Mitigation or N/A_

**Error Sanitization:**
_How are error messages cleaned before returning to clients?_

---

## Section 6: Hosting & Deployment

**Decision:** Local/stdio / VPS / Serverless / Managed / Kubernetes
**Rationale:** _Why this option?_

**Cost Estimate:**

| Component | Monthly Cost |
|-----------|-------------|
| | |
| **Total** | |

**Scaling Strategy:** _Single instance / Vertical / Horizontal / Auto-scale_

**Deployment Mechanism:** _Docker / npm package / binary / source_

**Monitoring:**

| Signal | Tool | Alert Threshold |
|--------|------|----------------|
| | | |

**DR Plan:** _Backup, failover, rollback strategy (or "N/A -- stateless")_

**ADR:** ADR-_NNN_

---

## Section 7: Discovery & Registration

**Discovery Mechanism:** _Manual config / npm / Registry / Documentation_

**Client Configuration Example:**

```json
{
  "mcpServers": {
    "server-name": {
    }
  }
}
```

**Server Dependencies:** _Other MCP servers this depends on (if any)_

**Documentation Plan:** _README, API docs, examples_

---

## Section 8: Versioning & Lifecycle

**Versioning Scheme:** _Semantic versioning / Date-based / Other_

**Breaking Change Definition:**
- _What constitutes a breaking change?_

**Deprecation Policy:**
- Notice period: _N days_
- Notification method: _Changelog / Email / In-description_

**Backward Compatibility Strategy:**
_How are non-breaking changes handled?_

**Minimum Support Window:** _N days after deprecation notice_

---

## Tool Manifest

```json
{
  "server": {
    "name": "",
    "version": "",
    "description": ""
  },
  "tools": [],
  "resources": [],
  "prompts": []
}
```

_See assets/tool-manifest-template.md for the detailed template._

---

## ADR Index

| ADR | Decision | Status |
|-----|----------|--------|
| ADR-001 | | Proposed / Accepted |
| ADR-002 | | Proposed / Accepted |
| ADR-003 | | Proposed / Accepted |

---

## Checklist Summary

| Section | Complete? |
|---------|-----------|
| 1. Purpose & Scope | [ ] |
| 2. Transport | [ ] |
| 3. Auth & Authz | [ ] |
| 4. Data Stores | [ ] |
| 5. Security | [ ] |
| 6. Hosting | [ ] |
| 7. Discovery | [ ] |
| 8. Versioning | [ ] |

**Spec approved by:** _Name, Date_
