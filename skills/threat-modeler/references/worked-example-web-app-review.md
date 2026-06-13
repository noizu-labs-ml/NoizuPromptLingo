# Worked Example: Web Application Security Review

**Date:** 2026-05-12
**Scope:** Next.js 15 frontend + Phoenix 1.8 API with JWT authentication, PostgreSQL, REST API
**Methodology:** OWASP Top 10 (2021) + Auth deep dive + Data flow analysis
**Application:** Acme Dashboard — multi-tenant analytics SaaS

## Executive Summary

This review identified 5 findings across 4 OWASP categories. Two are rated High severity: an insecure direct object reference (IDOR) vulnerability in the analytics endpoints, and JWT tokens with excessive lifetimes and no revocation mechanism. Three Medium-severity findings cover missing rate limiting, insufficient logging, and overly permissive CORS configuration. The most urgent action is fixing the IDOR vulnerability, which allows authenticated users to access other tenants' data.

---

## Step 1: Endpoint Mapping

| # | Method | Path | Auth | Input Type | Description |
|---|--------|------|------|------------|-------------|
| 1 | POST | /api/auth/login | None | JSON body (email, password) | User authentication, returns JWT |
| 2 | POST | /api/auth/register | None | JSON body (email, password, name) | User registration |
| 3 | POST | /api/auth/refresh | JWT | Cookie (refresh token) | Token refresh |
| 4 | POST | /api/auth/logout | JWT | None | Invalidate session |
| 5 | GET | /api/users/me | JWT | None | Current user profile |
| 6 | PATCH | /api/users/me | JWT | JSON body (name, email) | Update profile |
| 7 | GET | /api/dashboards | JWT | Query params (page, limit) | List user dashboards |
| 8 | POST | /api/dashboards | JWT | JSON body (title, config) | Create dashboard |
| 9 | GET | /api/dashboards/:id | JWT | Path param | Get dashboard by ID |
| 10 | GET | /api/analytics/:dashboard_id/data | JWT | Path param, query params (range, granularity) | Fetch analytics data |

### Auth Boundaries

- **Unauthenticated:** Endpoints 1-2 (login, register)
- **Authenticated (any user):** Endpoints 3-6 (token management, own profile)
- **Authenticated (resource owner):** Endpoints 7-10 (dashboard and analytics data)
- **Admin-only:** None identified (potential gap — no admin endpoints for user management)

---

## Step 2: OWASP Top 10 Assessment

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | FAIL | IDOR on dashboard and analytics endpoints — see Finding 1 |
| A02 Cryptographic Failures | Pass | TLS 1.3 via Cloudflare, bcrypt for passwords, HS256 JWT — adequate |
| A03 Injection | Pass | Ecto parameterized queries throughout; no raw SQL detected |
| A04 Insecure Design | Partial | No rate limiting on auth endpoints — see Finding 3 |
| A05 Security Misconfiguration | Partial | CORS allows wildcard in non-production configs — see Finding 5 |
| A06 Vulnerable Components | Pass | Dependencies current per mix.lock audit; no known CVEs |
| A07 Auth Failures | FAIL | JWT lifetime too long, no revocation — see Finding 2 |
| A08 Integrity Failures | Pass | CI/CD uses pinned dependencies, Docker images use digest refs |
| A09 Logging Failures | FAIL | No structured audit logging for data access — see Finding 4 |
| A10 SSRF | N/A | Application does not make server-side requests to user-supplied URLs |

---

## Step 3: Auth Deep Dive — JWT Implementation Analysis

### Token Architecture

| Property | Current Implementation | Assessment |
|----------|----------------------|------------|
| Algorithm | HS256 (HMAC-SHA256) | Acceptable for single-service; RS256 preferred for distributed systems |
| Access token lifetime | 24 hours | Too long — 15-minute access tokens with refresh flow is standard |
| Refresh token lifetime | 30 days | Acceptable if stored securely and revocable |
| Refresh token storage | httpOnly cookie | Correct — not accessible to JavaScript |
| Token revocation | None | Gap — compromised tokens valid until expiry |
| Key rotation | Manual | Gap — should be automated via Infisical with kid header |
| Claims | sub, email, tenant_id, iat, exp | Adequate; tenant_id in token enables authorization checks |

### Auth Flow Analysis

```
1. POST /api/auth/login
   - Input: {email, password}
   - Process: bcrypt.verify(password, stored_hash)
   - Output: {access_token: JWT, refresh_token: httpOnly cookie}
   - Finding: No account lockout after failed attempts

2. Middleware: verify_jwt plug
   - Extracts Bearer token from Authorization header
   - Validates signature, expiration, and required claims
   - Sets conn.assigns.current_user from token claims
   - Finding: Does NOT check a revocation list or token blacklist

3. POST /api/auth/refresh
   - Input: Refresh token from httpOnly cookie
   - Process: Validate refresh token, issue new access token
   - Output: New access token
   - Finding: Old access token remains valid (no rotation of refresh token)
```

### Auth Findings Summary

- **No token revocation mechanism.** If a JWT is compromised, the attacker has 24 hours of access with no way to invalidate the token server-side.
- **No account lockout.** Brute force attacks against /api/auth/login are not throttled at the application level.
- **Refresh token not rotated.** On refresh, the old refresh token remains valid, enabling persistent access if stolen.

---

## Step 4: Data Flow Analysis — PII Handling

### PII Inventory

| Data Element | Classification | Collected At | Stored In | Encrypted at Rest | Encrypted in Transit | Retention |
|-------------|---------------|-------------|-----------|-------------------|---------------------|-----------|
| Email | PII | Registration | PostgreSQL users table | No (plain text) | Yes (TLS) | Account lifetime |
| Full name | PII | Registration | PostgreSQL users table | No (plain text) | Yes (TLS) | Account lifetime |
| Password | Credential | Registration | PostgreSQL users table | Yes (bcrypt hash) | Yes (TLS) | Account lifetime |
| Billing info | Sensitive PII | Stripe checkout | Stripe (external) | Yes (Stripe-managed) | Yes (TLS) | Stripe retention policy |
| Analytics data | Business data | API ingestion | PostgreSQL analytics tables | No | Yes (TLS) | User-configured |
| Session tokens | Credential | Login | Redis | No | No (cluster-internal) | 30 days |

### Data Flow Diagram

```
User Browser                    Cloudflare              Phoenix API             PostgreSQL
    |                              |                       |                       |
    |-- email, password (TLS) ---->|                       |                       |
    |                              |-- email, pwd (TLS) -->|                       |
    |                              |                       |-- bcrypt verify ----->|
    |                              |                       |<-- user record -------|
    |                              |                       |                       |
    |                              |                       |-- session -> Redis    |
    |                              |<-- JWT (TLS) ---------|                       |
    |<-- JWT (TLS) ----------------|                       |                       |
```

### Data Flow Findings

- **PII stored unencrypted at rest.** Email and name are stored as plain text in PostgreSQL. While the database is behind network policies, a database backup or compromised PV exposes all PII. GDPR Article 32 recommends encryption of personal data at rest.
- **Session data unencrypted in Redis.** Session tokens in Redis are not encrypted and Redis runs without authentication. A compromised pod in the data namespace could read all active sessions.
- **No data retention policy enforced.** User analytics data has no automated expiration. GDPR Article 5(1)(e) requires data minimization and storage limitation.

---

## Step 5: Findings Report

### [HIGH] Finding 1: Insecure Direct Object Reference on Dashboard Endpoints

**Category:** A01 Broken Access Control
**Affected:** GET /api/dashboards/:id, GET /api/analytics/:dashboard_id/data
**Risk:** Likelihood 3 x Impact 5 = Critical (15)

**Description:**
The dashboard and analytics endpoints accept a resource ID as a path parameter but do not verify that the authenticated user owns the requested resource. An authenticated user can access any dashboard or analytics dataset by iterating over sequential IDs.

**Evidence:**
The Phoenix controller fetches the dashboard by ID without scoping to the current tenant:

```elixir
# Current (vulnerable)
def show(conn, %{"id" => id}) do
  dashboard = Repo.get!(Dashboard, id)
  render(conn, :show, dashboard: dashboard)
end
```

**Remediation:**
Scope all queries to the current user's tenant:

```elixir
# Fixed
def show(conn, %{"id" => id}) do
  tenant_id = conn.assigns.current_user.tenant_id
  dashboard = Repo.get_by!(Dashboard, id: id, tenant_id: tenant_id)
  render(conn, :show, dashboard: dashboard)
end
```

**Effort:** Low

---

### [HIGH] Finding 2: JWT Tokens Not Revocable with Excessive Lifetime

**Category:** A07 Identification and Authentication Failures
**Affected:** All authenticated endpoints
**Risk:** Likelihood 3 x Impact 4 = High (12)

**Description:**
Access tokens have a 24-hour lifetime and cannot be revoked server-side. If a token is compromised (XSS, device theft, network interception), the attacker retains access for the full token lifetime. Combined with the lack of refresh token rotation, a stolen refresh token grants indefinite access.

**Evidence:**
Token generation uses a static lifetime with no revocation check in the verification middleware.

**Remediation:**
1. Reduce access token lifetime to 15 minutes
2. Implement refresh token rotation (invalidate old refresh token on use)
3. Add a token blacklist in Redis checked during JWT verification (for logout and compromise response)
4. Automate JWT signing key rotation via Infisical with a kid header for key identification

**Effort:** Medium

---

### [MEDIUM] Finding 3: No Rate Limiting on Authentication Endpoints

**Category:** A04 Insecure Design
**Affected:** POST /api/auth/login, POST /api/auth/register
**Risk:** Likelihood 4 x Impact 3 = High (12)

**Description:**
The login and registration endpoints have no rate limiting at the application level. While Cloudflare provides basic DDoS protection, a targeted credential stuffing attack or brute force attempt against a specific account would not be throttled.

**Evidence:**
No rate limiting plug or middleware applied to the auth router scope.

**Remediation:**
1. Add a rate limiting plug using a Redis-backed counter (e.g., `Hammer` or `ExRated` library)
2. Limit login attempts to 10 per minute per IP and 5 per minute per email
3. Implement progressive delays (1s, 2s, 4s) after 3 failed attempts
4. Add account lockout after 10 consecutive failures (unlock via email)

**Effort:** Low

---

### [MEDIUM] Finding 4: Insufficient Security Logging

**Category:** A09 Security Logging and Monitoring Failures
**Affected:** All endpoints
**Risk:** Likelihood 3 x Impact 3 = Medium (9)

**Description:**
The application logs HTTP requests at the access log level but does not produce structured audit logs for security-relevant events. Failed login attempts, privilege-sensitive operations (dashboard creation, data export), and configuration changes are not logged in a format suitable for security monitoring or incident investigation.

**Evidence:**
Logger configuration uses the default Phoenix request logger. No audit-specific log entries found in the codebase.

**Remediation:**
1. Implement structured audit logging (JSON format) for: failed logins, successful logins, password changes, data exports, dashboard creation/deletion, and any admin actions
2. Include: timestamp, user_id, tenant_id, action, resource_type, resource_id, source_ip, user_agent
3. Forward audit logs to a centralized log aggregation system (separate from application logs)
4. Set up alerting on anomalous patterns: 5+ failed logins per account, data access from unusual IPs

**Effort:** Medium

---

### [MEDIUM] Finding 5: Overly Permissive CORS Configuration

**Category:** A05 Security Misconfiguration
**Affected:** All API endpoints
**Risk:** Likelihood 2 x Impact 3 = Medium (6)

**Description:**
The CORS configuration uses a wildcard origin (`*`) in the development configuration, and the mechanism for switching to production configuration is environment-variable-based. If the environment variable is misconfigured or missing, the wildcard applies in production, allowing any website to make authenticated cross-origin requests.

**Evidence:**
CORS plug configuration defaults to `origins: ["*"]` with a runtime override from `CORS_ORIGINS` environment variable.

**Remediation:**
1. Change the default to an empty list (deny all cross-origin requests by default)
2. Require explicit origin configuration; fail startup if CORS_ORIGINS is not set in production
3. Restrict allowed origins to the exact frontend domain (e.g., `https://dashboard.acme.com`)

**Effort:** Low

---

## Summary Table

| # | Severity | Finding | Category | Status | Effort |
|---|----------|---------|----------|--------|--------|
| 1 | High | IDOR on dashboard/analytics endpoints | A01 Broken Access Control | Open | Low |
| 2 | High | JWT not revocable, 24h lifetime | A07 Auth Failures | Open | Medium |
| 3 | Medium | No rate limiting on auth endpoints | A04 Insecure Design | Open | Low |
| 4 | Medium | Insufficient security audit logging | A09 Logging Failures | Open | Medium |
| 5 | Medium | Overly permissive CORS defaults | A05 Misconfiguration | Open | Low |

## Methodology Notes

- This review was conducted through architecture and code-level analysis, not active testing
- OWASP Top 10 (2021) was used as the primary assessment framework
- Dependency vulnerability scanning (mix audit, npm audit) was referenced but not re-executed
- Server-Side Request Forgery (A10) was marked N/A because the application does not fetch user-supplied URLs
- Cryptographic assessment (A02) considered only the application layer; TLS configuration is managed by Cloudflare and was not independently verified
- The Stripe integration was considered out of scope for PII handling since billing data is stored and processed entirely by Stripe
