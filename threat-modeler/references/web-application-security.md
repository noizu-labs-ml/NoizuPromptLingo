# Web Application Security

Reference document for threat modeling web applications built on modern frameworks (Next.js, Phoenix, Express, Rails). Oriented toward developers and architects performing security reviews, not penetration testers.

---

## OWASP Top 10 (2021) Analysis Guide

### A01:2021 -- Broken Access Control

**What it is:** Failures in enforcing policies so that users act only within their intended permissions. This includes privilege escalation, unauthorized data access, and bypassing access controls by modifying URLs, API requests, or internal state.

**How it manifests in modern frameworks:**

| Framework | Common manifestation |
|-----------|---------------------|
| Next.js | Missing middleware auth checks on API routes; relying solely on client-side route guards; `getServerSideProps` fetching data without verifying ownership |
| Phoenix | Missing `Plug` pipelines for auth; controller actions that don't scope queries to `current_user`; LiveView mount lacking auth checks |
| Express | No middleware on sensitive routes; IDOR via unscoped database queries; trusting client-sent user IDs |
| Rails | Missing `before_action` callbacks; `find(params[:id])` without scoping to `current_user`; mass assignment exposing role fields |

**Detection checklist:**

- [ ] Can a logged-in user access another user's resources by changing an ID in the URL or request body?
- [ ] Are API routes and server actions protected by auth middleware, or only by client-side guards?
- [ ] Do database queries scope results to the authenticated user's permissions?
- [ ] Can a regular user access admin endpoints by guessing the URL?
- [ ] Are CORS policies restrictive enough to prevent cross-origin abuse?

**Remediation patterns:**

- Deny by default -- require explicit authorization on every route/controller action.
- Scope all database queries: `Post.where(user_id: current_user.id).find(params[:id])` instead of `Post.find(params[:id])`.
- Use middleware/plug pipelines that run before the handler, never after.
- Implement RBAC or ABAC checks at the service layer, not just the route layer.
- Disable directory listing and ensure metadata files (`.git`, `.env`) are not served.

**Severity context:** Critical when it enables access to other users' data or admin functions. Informational when limited to UI-only exposure with no backend data leak.

---

### A02:2021 -- Cryptographic Failures

**What it is:** Weaknesses related to cryptography (or its absence) that lead to exposure of sensitive data. Covers data in transit, data at rest, weak algorithms, poor key management, and insufficient entropy.

**How it manifests in modern frameworks:**

| Framework | Common manifestation |
|-----------|---------------------|
| Next.js | Storing secrets in `NEXT_PUBLIC_*` env vars (exposed to client); JWT signed with weak/hardcoded secrets; no HSTS |
| Phoenix | Weak `secret_key_base`; storing passwords with MD5/SHA instead of bcrypt; cookies without `secure` flag |
| Express | Hardcoded JWT secrets in source; HTTP without TLS redirect; session cookies missing `secure`/`httpOnly` |
| Rails | `secret_key_base` committed to repo; credentials file with weak master key; `attr_encrypted` with ECB mode |

**Detection checklist:**

- [ ] Is all traffic forced to HTTPS with HSTS enabled?
- [ ] Are secrets (API keys, signing keys) stored in environment variables or a secrets manager, never in source?
- [ ] Are passwords hashed with bcrypt, argon2, or scrypt (not MD5/SHA)?
- [ ] Are JWT signing secrets at least 256 bits of entropy?
- [ ] Is sensitive data (PII, financial) encrypted at rest in the database?

**Remediation patterns:**

- Force TLS everywhere; set HSTS with `max-age=31536000; includeSubDomains`.
- Use `argon2id` or `bcrypt` (cost factor >= 12) for password hashing.
- Rotate signing keys periodically; store them in a secrets manager (Vault, Infisical, AWS SSM).
- Never prefix secrets with `NEXT_PUBLIC_` in Next.js.
- Use authenticated encryption (AES-256-GCM) for data at rest, not AES-ECB or AES-CBC without HMAC.

**Severity context:** Critical when passwords or PII are stored in plaintext or with broken hashes. Lower severity for missing HSTS on internal-only services.

---

### A03:2021 -- Injection

**What it is:** Untrusted data sent to an interpreter as part of a command or query. Includes SQL injection, NoSQL injection, OS command injection, LDAP injection, and cross-site scripting (XSS).

**How it manifests in modern frameworks:**

| Framework | Common manifestation |
|-----------|---------------------|
| Next.js | XSS via `dangerouslySetInnerHTML`; SQL injection through raw Prisma queries (`$queryRaw`); template injection in email renderers |
| Phoenix | Raw SQL via `Ecto.Adapters.SQL.query/3` with string interpolation; HEEx templates are safe by default but `raw/1` bypasses escaping |
| Express | SQL injection through string-concatenated queries; command injection via `child_process.exec` with user input; XSS in server-rendered templates |
| Rails | SQL injection via `where("name = '#{params[:name]}'")`; XSS via `raw` or `html_safe`; command injection through `system()` with interpolated args |

**Detection checklist:**

- [ ] Are all database queries parameterized (no string interpolation of user input)?
- [ ] Does the template engine auto-escape output? Are there any uses of `raw`/`html_safe`/`dangerouslySetInnerHTML`?
- [ ] Is user input ever passed to `exec`, `system`, `eval`, or equivalent?
- [ ] Are ORM "raw query" escape hatches audited for parameterization?
- [ ] Is input validated on type, length, and format before use?

**Remediation patterns:**

- Use parameterized queries exclusively: `Repo.all(from u in User, where: u.name == ^name)` (Ecto), `User.where(name: name)` (ActiveRecord), `prisma.user.findMany({ where: { name } })`.
- Never use `eval()`, `Function()`, or dynamic `require()` with user input.
- For OS commands, use execFile/spawn with argument arrays, not shell strings.
- Apply Content Security Policy headers to mitigate XSS impact.
- Validate and sanitize HTML input with allowlist-based sanitizers (DOMPurify, HtmlSanitizeEx).

**Severity context:** Critical for SQL injection and command injection (full system compromise). High for stored XSS. Medium for reflected XSS with CSP in place.

---

### A04:2021 -- Insecure Design

**What it is:** Flaws in the design itself, not implementation bugs. Missing threat modeling, insecure business logic, lack of defense in depth. No amount of perfect code fixes a broken design.

**How it manifests in modern frameworks:**

| Framework | Common manifestation |
|-----------|---------------------|
| All | Password reset via predictable tokens; no rate limiting on auth endpoints; business logic that trusts client-side calculations (pricing, permissions); multi-step workflows without server-side state validation |
| Next.js | Trusting client components for authorization decisions; API routes without idempotency on payment flows |
| Phoenix | LiveView state that trusts client-pushed events without server-side validation |
| Rails | Complex `before_action` chains with implicit ordering dependencies |

**Detection checklist:**

- [ ] Was a threat model created during design? Are trust boundaries documented?
- [ ] Do critical business flows (payments, account changes) validate state server-side at every step?
- [ ] Is there rate limiting on authentication, registration, and password reset?
- [ ] Are security requirements (auth, encryption, logging) part of the acceptance criteria?

**Remediation patterns:**

- Conduct threat modeling (STRIDE) during design, not after implementation.
- Validate all business logic server-side; treat client state as untrusted.
- Implement rate limiting on all auth-related endpoints (5-10 attempts per minute).
- Use CAPTCHA or proof-of-work on public-facing forms.
- Design with defense in depth: if one layer fails, the next catches it.

**Severity context:** Severity varies with the business impact. A missing rate limit on login is high; a missing rate limit on a search endpoint is low.

---

### A05:2021 -- Security Misconfiguration

**What it is:** Missing security hardening, unnecessary features enabled, default credentials, overly permissive cloud/container configurations, verbose error messages.

**How it manifests in modern frameworks:**

| Framework | Common manifestation |
|-----------|---------------------|
| Next.js | Source maps enabled in production; `x-powered-by` header present; permissive `next.config.js` headers; exposed `/_next/data` paths |
| Phoenix | Debug error pages in production (`debug_errors: true`); default `secret_key_base`; Erlang distribution port exposed |
| Express | Stack traces in error responses; `X-Powered-By: Express` header; CORS set to `*` |
| Rails | Detailed error pages in production; default `secret_key_base` from generators; Active Storage serving private files publicly |

**Detection checklist:**

- [ ] Are debug/development features disabled in production (error pages, source maps, verbose logging)?
- [ ] Are default credentials changed for all services (databases, admin panels, message queues)?
- [ ] Are unnecessary HTTP methods disabled?
- [ ] Is the `X-Powered-By` header removed?
- [ ] Are cloud storage buckets and database ports restricted to authorized networks only?

**Remediation patterns:**

- Remove `X-Powered-By` headers: `app.disable('x-powered-by')` (Express), `delete_resp_header("x-powered-by")` (Phoenix).
- Disable source maps in production builds.
- Return generic error messages to clients; log details server-side only.
- Run containers as non-root with read-only filesystems where possible.
- Automate configuration audits in CI (e.g., checkov, trivy config scanning).

**Severity context:** Critical when default credentials or exposed admin interfaces are involved. Low for information disclosure like version headers.

---

### A06:2021 -- Vulnerable and Outdated Components

**What it is:** Using libraries, frameworks, or other software components with known vulnerabilities. Includes transitive dependencies.

**How it manifests in modern frameworks:**

| Framework | Common manifestation |
|-----------|---------------------|
| All (npm) | Outdated dependencies with known CVEs; transitive dependency vulnerabilities; abandoned packages still in use |
| All (Elixir) | Hex packages with unpatched vulnerabilities; outdated Erlang/OTP with security fixes |
| All (Ruby) | Gems with known CVEs; Rails version past EOL |

**Detection checklist:**

- [ ] Is `npm audit` / `mix audit` / `bundle audit` run in CI?
- [ ] Are dependencies updated on a regular cadence (at least monthly)?
- [ ] Are there dependencies that are unmaintained (no commits in 12+ months)?
- [ ] Is the framework version itself still receiving security patches?
- [ ] Are Docker base images rebuilt regularly with updated OS packages?

**Remediation patterns:**

- Run `npm audit`, `mix_audit`, or `bundler-audit` in CI and fail on high/critical findings.
- Use Dependabot, Renovate, or similar for automated dependency PRs.
- Pin major versions but allow patch updates: `"^1.2.3"` not `"1.2.3"`.
- Maintain a software bill of materials (SBOM) for production deployments.
- Subscribe to security advisories for your framework (Next.js blog, Phoenix announcements, Rails security mailing list).

**Severity context:** Severity matches the underlying CVE. A critical RCE in a direct dependency is critical. A low-severity issue in a dev-only dependency is informational.

---

### A07:2021 -- Identification and Authentication Failures

**What it is:** Weaknesses in authentication mechanisms that allow attackers to compromise passwords, keys, session tokens, or exploit implementation flaws to assume other users' identities.

**How it manifests in modern frameworks:**

| Framework | Common manifestation |
|-----------|---------------------|
| Next.js | NextAuth misconfiguration; JWT stored in localStorage (XSS-accessible); no CSRF protection on auth endpoints |
| Phoenix | Session fixation via `put_session` without regeneration; `phx_csrf_token` missing on non-LiveView forms |
| Express | Passport.js with permissive `failureRedirect`; sessions without `regenerate()` after login |
| Rails | Devise defaults without lockout; `remember_me` tokens without expiry; session not reset on login |

**Detection checklist:**

- [ ] Are passwords hashed with a modern algorithm (bcrypt/argon2) with appropriate cost factors?
- [ ] Is the session ID regenerated after successful authentication?
- [ ] Are there account lockout or throttling mechanisms after failed login attempts?
- [ ] Do JWTs have reasonable expiry times (15 min access, 7 day refresh)?
- [ ] Is MFA available for privileged accounts?

**Remediation patterns:**

- Regenerate session ID on login: `req.session.regenerate()` (Express), `configure_session(renew: true)` (Phoenix).
- Implement account lockout after 5 failed attempts with exponential backoff.
- Store tokens in httpOnly, secure, SameSite=Strict cookies -- never localStorage.
- Set JWT access token expiry to 15 minutes; use refresh tokens for longer sessions.
- Require MFA for admin accounts and sensitive operations.

**Severity context:** Critical when credential stuffing or brute force is unthrottled. High when session fixation is possible. Medium for missing MFA on non-admin accounts.

---

### A08:2021 -- Software and Data Integrity Failures

**What it is:** Failures related to code and infrastructure that does not protect against integrity violations. Includes insecure CI/CD pipelines, auto-update without verification, and deserialization of untrusted data.

**How it manifests in modern frameworks:**

| Framework | Common manifestation |
|-----------|---------------------|
| All (npm) | `postinstall` scripts in dependencies executing arbitrary code; unpinned dependencies in CI; no lockfile integrity checks |
| Next.js | Unsigned deployments; environment variables injected without validation |
| Phoenix | Erlang Term Format (ETF) deserialization of untrusted input; unsigned releases |
| Rails | `Marshal.load` on untrusted data; YAML deserialization attacks (`Psych.unsafe_load`) |

**Detection checklist:**

- [ ] Does CI/CD verify lockfile integrity (`npm ci` instead of `npm install`)?
- [ ] Are CI/CD pipeline configurations access-controlled and audited?
- [ ] Is deserialization of untrusted data avoided (no `Marshal.load`, `pickle.loads`, `YAML.load` on user input)?
- [ ] Are deployments signed or verified via checksums?
- [ ] Are third-party scripts (CDN, analytics) loaded with Subresource Integrity (SRI) hashes?

**Remediation patterns:**

- Use `npm ci` in CI pipelines (respects lockfile exactly).
- Never deserialize untrusted data with native serialization formats; use JSON with schema validation.
- Add SRI hashes to all third-party `<script>` and `<link>` tags.
- Implement branch protection rules and require code review for CI/CD config changes.
- Sign releases and verify signatures during deployment.

**Severity context:** Critical when CI/CD pipelines can be modified by untrusted contributors. High for deserialization of untrusted data. Medium for missing SRI on non-critical scripts.

---

### A09:2021 -- Security Logging and Monitoring Failures

**What it is:** Insufficient logging, monitoring, and alerting that prevents detection of active attacks, breaches, or security incidents.

**How it manifests in modern frameworks:**

| Framework | Common manifestation |
|-----------|---------------------|
| All | No logging of authentication events; logs containing sensitive data (passwords, tokens); no alerting on anomalous patterns |
| Next.js | API route errors swallowed silently; no request logging in serverless deployments |
| Phoenix | Logger level set to `:info` missing auth events; Ecto query logs exposing parameters in production |
| Express | Winston/Pino not configured for structured logging; no correlation IDs across services |

**Detection checklist:**

- [ ] Are authentication successes, failures, and privilege changes logged?
- [ ] Do logs include sufficient context (timestamp, user ID, IP, action) without sensitive data (passwords, tokens, PII)?
- [ ] Are logs shipped to a centralized system with retention >= 90 days?
- [ ] Are there alerts for anomalous patterns (brute force, unusual access patterns)?
- [ ] Is there an incident response plan that references these logs?

**Remediation patterns:**

- Log all authentication events: login, logout, failed attempts, password changes, MFA events.
- Use structured logging (JSON) with correlation IDs for request tracing.
- Scrub sensitive fields from logs: passwords, tokens, credit card numbers.
- Ship logs to a centralized platform (Loki, ELK, Datadog) with alerting rules.
- Set up alerts for: >10 failed logins per minute, admin access from new IPs, error rate spikes.

**Severity context:** High when no authentication logging exists (you cannot detect breaches). Low when logging exists but alerting is incomplete.

---

### A10:2021 -- Server-Side Request Forgery (SSRF)

**What it is:** An attacker causes the server to make HTTP requests to an unintended destination, typically internal services, cloud metadata endpoints, or other backend systems.

**How it manifests in modern frameworks:**

| Framework | Common manifestation |
|-----------|---------------------|
| Next.js | `fetch()` in API routes or server components with user-controlled URLs; image optimization (`next/image`) with unrestricted `remotePatterns` |
| Phoenix | `HTTPoison.get(user_url)` without URL validation; webhook handlers that follow redirects |
| Express | Proxy endpoints that forward user-supplied URLs; PDF generators fetching user-provided URLs |
| Rails | `open-uri` with user input; webhook/callback URLs without validation |

**Detection checklist:**

- [ ] Does any server-side code fetch URLs that are partially or fully user-controlled?
- [ ] Are there allowlists for permitted destination hosts/IP ranges?
- [ ] Is access to cloud metadata endpoints (169.254.169.254) blocked?
- [ ] Do outbound requests follow redirects that could land on internal hosts?
- [ ] Are webhook callback URLs validated against an allowlist?

**Remediation patterns:**

- Validate and allowlist destination URLs: check scheme (https only), host (against allowlist), and resolved IP (not private ranges).
- Block access to metadata endpoints: deny `169.254.169.254`, `fd00::/8`, and link-local ranges.
- Disable HTTP redirects on outbound requests, or re-validate after each redirect.
- Use `next.config.js` `remotePatterns` to restrict `next/image` sources to known domains.
- Run outbound-requesting services in a network segment that cannot reach internal infrastructure.

**Severity context:** Critical when it enables access to cloud metadata (credential theft) or internal services. Medium when limited to port scanning or information disclosure.

---

## API Security Patterns

### Authentication

| Method | Use case | Implementation notes |
|--------|----------|---------------------|
| API keys | Server-to-server, internal services | Hash keys in storage (SHA-256); transmit via `Authorization: Bearer` header, never in query strings; support key rotation with grace periods |
| OAuth 2.0 | Third-party integrations, user-delegated access | Use Authorization Code flow with PKCE for public clients; validate `state` parameter; store tokens server-side |
| JWT | Stateless auth for APIs | Sign with RS256 or ES256 (asymmetric) for distributed systems; HS256 only for single-service; set `exp`, `iat`, `iss`, `aud` claims; keep payloads small |
| Session cookies | Browser-based applications | `httpOnly`, `Secure`, `SameSite=Strict`; regenerate on auth state change; set reasonable expiry |

### Authorization

| Pattern | When to use | Implementation |
|---------|-------------|----------------|
| RBAC (Role-Based) | Simple permission models (admin, editor, viewer) | Map roles to permissions at the service layer; check permissions, not roles, in code |
| ABAC (Attribute-Based) | Complex rules (ownership, department, time-based) | Evaluate policies against request attributes; use a policy engine (Oso, Casbin, OPA) |
| Resource-level | Per-object access (own posts, shared documents) | Scope every query to the authenticated user's accessible resources |

### Rate Limiting

- Apply per-endpoint rate limits based on risk: auth endpoints (5-10/min), API reads (100-1000/min), writes (10-50/min).
- Use sliding window or token bucket algorithms.
- Return `429 Too Many Requests` with `Retry-After` header.
- Rate limit by authenticated user ID when possible, IP address as fallback.
- Implement stricter limits on unauthenticated endpoints.

### Input Validation

- Validate on the server, regardless of client-side validation.
- Define schemas with explicit types, lengths, formats, and allowed values (Zod, Ecto changesets, Rails strong parameters).
- Reject unexpected fields (allowlist, not denylist).
- Validate content types: reject requests with unexpected `Content-Type`.

### Error Handling

- Return generic error messages to clients: `{ "error": "Authentication failed" }`, not `{ "error": "User not found" }` vs `{ "error": "Invalid password" }`.
- Use consistent error response schemas across all endpoints.
- Log full error details server-side with request correlation IDs.
- Never expose stack traces, SQL queries, or internal service names in responses.

### CORS Configuration

```
Restrictive (recommended):
  Access-Control-Allow-Origin: https://app.example.com    (specific origin, not *)
  Access-Control-Allow-Methods: GET, POST, PUT, DELETE     (only methods you use)
  Access-Control-Allow-Headers: Content-Type, Authorization
  Access-Control-Allow-Credentials: true
  Access-Control-Max-Age: 86400
```

- Never use `Access-Control-Allow-Origin: *` with `Access-Control-Allow-Credentials: true`.
- Validate the `Origin` header against an allowlist; do not reflect it blindly.
- Restrict `Access-Control-Allow-Methods` to only the HTTP methods your API uses.

---

## Authentication and Authorization Review Checklist

### Password Storage

| Check | Expected |
|-------|----------|
| Hashing algorithm | argon2id (preferred) or bcrypt with cost >= 12 |
| Salt | Unique per password, generated by the hashing library |
| Pepper | Application-level secret applied before hashing, stored outside the database |
| Password policy | Minimum 8 characters; check against breached password lists (HaveIBeenPwned API) |
| Migration path | If upgrading from weaker hashes, rehash on next successful login |

### Session Management

| Check | Expected |
|-------|----------|
| Session ID entropy | >= 128 bits of cryptographically random data |
| Storage | Server-side (Redis, database); never store session data solely in cookies |
| Cookie flags | `httpOnly`, `Secure`, `SameSite=Strict` (or `Lax` if cross-site navigation required) |
| Regeneration | New session ID after login, privilege change, and MFA verification |
| Expiry | Absolute timeout (24h) and idle timeout (30 min) |
| Revocation | Logout destroys server-side session; admin can revoke all sessions for a user |

### Token Lifecycle (JWT)

| Check | Expected |
|-------|----------|
| Access token expiry | 15 minutes |
| Refresh token expiry | 7-30 days |
| Refresh token rotation | Issue new refresh token on each use; invalidate the old one |
| Revocation | Maintain a denylist for logout/compromise; check on every request |
| Storage (browser) | httpOnly secure cookie; never localStorage or sessionStorage |
| Algorithm | RS256 or ES256 for multi-service; HS256 only for single-service with strong key |
| Claims validation | Verify `exp`, `iss`, `aud`, `iat` on every request |

### Multi-Factor Authentication

| Check | Expected |
|-------|----------|
| MFA methods | TOTP (preferred), WebAuthn/FIDO2 (strongest), SMS (last resort) |
| Recovery codes | 8-10 single-use codes, hashed in storage, shown once at setup |
| Enforcement | Required for admin accounts; encouraged for all users |
| Rate limiting | Lock account after 5 failed MFA attempts |

### OAuth Flows

| Check | Expected |
|-------|----------|
| Flow type | Authorization Code with PKCE (public clients); Client Credentials (server-to-server) |
| State parameter | Random, unguessable, validated on callback |
| Token storage | Server-side; never exposed to the browser in URL fragments |
| Scope | Request minimum necessary scopes; validate scopes on resource server |
| Redirect URI | Exact match validation; no open redirects |

### RBAC Implementation

| Check | Expected |
|-------|----------|
| Role assignment | Stored in database, not in JWT claims (unless short-lived) |
| Permission checks | Check permissions at the service layer, not just route/middleware level |
| Default role | New users get minimum-privilege role |
| Role changes | Require re-authentication; invalidate existing sessions |
| Audit trail | Log all role/permission changes with actor, target, timestamp |

---

## Secure Headers

| Header | Recommended value | Purpose |
|--------|-------------------|---------|
| `Content-Security-Policy` | `default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self'; font-src 'self'; object-src 'none'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'` | Mitigates XSS, clickjacking, and data injection |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains; preload` | Forces HTTPS for all future requests |
| `X-Frame-Options` | `DENY` | Prevents clickjacking (superseded by CSP `frame-ancestors` but still needed for older browsers) |
| `X-Content-Type-Options` | `nosniff` | Prevents MIME-type sniffing |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Controls referrer information leakage |
| `Permissions-Policy` | `camera=(), microphone=(), geolocation=(), payment=()` | Disables browser features not used by the application |
| `X-Permitted-Cross-Domain-Policies` | `none` | Prevents Adobe Flash/PDF cross-domain requests |
| `Cross-Origin-Opener-Policy` | `same-origin` | Isolates browsing context from cross-origin windows |
| `Cross-Origin-Resource-Policy` | `same-origin` | Prevents cross-origin reads of resources |
| `Cross-Origin-Embedder-Policy` | `require-corp` | Enables cross-origin isolation (required for SharedArrayBuffer) |

**Framework-specific setup:**

- **Next.js:** Configure in `next.config.js` via `headers()` function.
- **Phoenix:** Use a `Plug` in the endpoint or router pipeline.
- **Express:** Use `helmet` package (`app.use(helmet())`) -- provides sensible defaults for all headers above.
- **Rails:** Configure via `config.action_dispatch.default_headers` or use `secure_headers` gem.

---

## Common Framework-Specific Issues

| Framework | Pitfall | Risk | Mitigation |
|-----------|---------|------|------------|
| **Next.js** | `NEXT_PUBLIC_*` env vars expose secrets to client bundle | Credential leak | Only prefix truly public values; use server-only env vars for secrets |
| **Next.js** | Server Actions without auth checks | Broken access control | Add auth validation at the top of every server action |
| **Next.js** | `dangerouslySetInnerHTML` with user content | XSS | Sanitize with DOMPurify before rendering; prefer React's default escaping |
| **Next.js** | Unrestricted `remotePatterns` in image config | SSRF | Allowlist specific domains and paths |
| **Next.js** | Middleware.ts bypass via direct API route access | Auth bypass | Apply auth checks in both middleware and route handlers |
| **Phoenix** | `raw/1` in HEEx templates | XSS | Avoid `raw/1`; use default escaping; sanitize with HtmlSanitizeEx if raw HTML is required |
| **Phoenix** | LiveView `handle_event` trusting client params | Injection, logic bypass | Validate and cast all params with Ecto changesets |
| **Phoenix** | `Ecto.Adapters.SQL.query` with interpolation | SQL injection | Use parameterized queries: `query("SELECT * FROM users WHERE id = $1", [id])` |
| **Phoenix** | Default error views leaking internal info | Information disclosure | Customize error views for production; set `debug_errors: false` |
| **Express** | `eval()` or `Function()` with user input | Remote code execution | Never use dynamic code evaluation with untrusted input |
| **Express** | `cors({ origin: true })` or `origin: '*'` | Unauthorized cross-origin access | Set explicit origin allowlist |
| **Express** | Prototype pollution via `merge`/`extend` utilities | Denial of service, property injection | Use `Object.create(null)` for option objects; validate input keys |
| **Express** | Unhandled promise rejections in async routes | Crash, denial of service | Use `express-async-errors` or wrap routes in try/catch |
| **Rails** | `html_safe` or `raw` on user input | XSS | Use default escaping; sanitize with `sanitize` helper |
| **Rails** | `params.permit!` (permit all) | Mass assignment | Explicitly list permitted parameters |
| **Rails** | `find(params[:id])` without scoping | IDOR | Use `current_user.posts.find(params[:id])` |
| **Rails** | `send(params[:method])` | Arbitrary method invocation | Allowlist permitted method names |
| **Rails** | `Marshal.load` / `YAML.load` on untrusted data | Remote code execution | Use `JSON.parse` or `YAML.safe_load` |
