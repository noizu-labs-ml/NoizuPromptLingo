# Architecture Decision Records

## ADR-001: Static Export Over Server-Side Rendering

**Status:** Accepted
**Date:** 2025-05

**Context:** The landing page has no dynamic data, user sessions, or server-side logic. SSR would require running a Node.js process in production.

**Decision:** Use Next.js static export (`next build` producing `/out`) served by nginx.

**Consequences:**
- Simpler deployment (no Node.js runtime in production container)
- Lower resource footprint (nginx serves files, no V8 overhead)
- Cannot add server-side routes without changing the build pipeline
- API routes would require a separate backend service

---

## ADR-002: Cloudflare-Only Ingress

**Status:** Accepted
**Date:** 2025-05

**Context:** All `*.noizu.com` services use Cloudflare for DNS, CDN, and DDoS protection. Direct access to the cluster bypasses these protections.

**Decision:** Whitelist only Cloudflare IP ranges in NGINX ingress annotations. Hardcoded in the Helm `_helpers.tpl` template.

**Consequences:**
- All traffic proxied through Cloudflare (caching, WAF, rate limiting available)
- Direct cluster access blocked (cannot bypass Cloudflare)
- Cloudflare IP range updates require chart update (low-frequency change)

---

## ADR-003: Infisical for TLS Certificate Management

**Status:** Accepted
**Date:** 2025-05

**Context:** The K8s cluster uses Infisical Operator for secrets management. TLS certificates for origin servers are stored in Infisical and synced to K8s Secrets.

**Decision:** Use InfisicalSecret CRD to sync TLS certificates rather than cert-manager or manual Secret creation.

**Consequences:**
- Consistent with cluster-wide secrets pattern
- Certificate rotation handled by updating Infisical (auto-syncs within 5 minutes)
- Depends on Infisical Operator availability (tier 0 dependency)
