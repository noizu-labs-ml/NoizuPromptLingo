# Remote-Access Reverse-Tunnel Subsystem — Design / Plan

> **Status:** Design only. Nothing in this document has been implemented. No
> terraform, helm, or application code is to be changed as part of producing it.
>
> **Author context:** Complements the `browser-controller` (which connects
> *outbound* from a local machine to the cloud). This subsystem adds the
> *inbound* direction: a public DNS endpoint such as
> `starlight-robot.remote-access.noizu.com` that forwards inbound HTTP(S) (and
> optionally arbitrary TCP) down to a service running on a user's **local**
> machine, which has registered an outbound tunnel.

---

## 1. Context

### What we have today

The Noizu cluster is a bare-metal Kubernetes cluster whose only public-facing
node is **`noizu-server`** (`208.64.36.80`, public range `208.64.36.78–83`).
Everything public is reached the same way:

```
Cloudflare DNS (orange-cloud proxied)
        │   A/CNAME → 208.64.36.80
        ▼
ingress-nginx  (hostNetwork=true, pinned to noizu-server, binds :80/:443)
        │   ingressClassName: nginx
        │   TLS terminated with the shared *.noizu.com wildcard secret
        ▼
in-cluster Service → app pod
```

Key facts that constrain (and enable) this design — all verified against the repo:

| Concern | Current state | Source |
|---|---|---|
| DNS | Cloudflare provider `~> 5.0`, `cloudflare_dns_record` resources, one dir per zone | `terraform/cloudflare/zones/noizu.com/main.tf` |
| noizu.com zone | `zone_id 46014d24206a7141ed698d2d9d963e85`, `account_id a75e745949fc104ea4c4107a17158f15` | `terraform/cloudflare/zones/noizu.com/{locals,provider,backend}.tf` |
| Wildcard | `*.noizu.com` CNAME → `derobot.is`, **proxied=true** (catch-all today) | `terraform/cloudflare/zones/noizu.com/main.tf` |
| TLS | **No cert-manager / ACME.** Cloudflare-origin `*.noizu.com` wildcard cert stored in Infisical, synced into the cluster Secret `cloudflare-tls-synced` | `terraform/kubernetes/infra-services/secrets.tf`, platform `*/variables.tf` (`tls_secret_name` default `cloudflare-tls-synced`) |
| Ingress | `ingress-nginx` v4.15.1, ns `ingress-nginx`, `hostNetwork=true`, `service.type=ClusterIP`, pinned to `noizu-server`, default class `nginx` | `terraform/kubernetes/init/controllers.tf` |
| Node pinning | every workload uses `nodeSelector { "kubernetes.io/hostname" = "noizu-server" }` | `terraform/kubernetes/init/outputs.tf` |
| Cloudflare Tunnel | **Not used.** `zero-trust/` only has Access apps/groups; no `cloudflare_tunnel`/`cloudflared` anywhere | `terraform/cloudflare/zero-trust/` |
| CF API token | tfvar `noizu_cloudflare_api_token` (`TF_VAR_…`) | `terraform/cloudflare/zones/noizu.com/provider.tf` |
| Deploy model | tiers + namespaces in `.infra-config.yaml`; Docker image → helm `values_path`; charts under `projects/<x>/helm/<chart>` or upstream `noizu-infra` | `.infra-config.yaml` |
| Auth we can reuse | NoizuPromptLingo (NPL) backend mints **MCP JWTs** (`iss "tobor-locker"`, HS256 `GUARDIAN_SECRET_KEY`, 30d) from long-lived **MCP API keys** via `POST /api/mcp/token` | `backend/lib/noizu_prompt_lingua/token.ex`, `.../mcp_auth.ex`, `.../controllers/token_controller.ex` |
| Existing tunnel-ish thing | `browser-controller` connects **outbound** over a Phoenix channel `browser:<org_id>` on `wss://tobor.locker/socket`, authed with the MCP JWT | `projects/NoizuPromptLingo/browser-controller/README.md`, `backend/.../endpoint.ex` |

### The goal

A user runs a small client on their laptop:

```bash
remote-access connect --name starlight-robot --port 3000
```

and `https://starlight-robot.remote-access.noizu.com` (443/80) becomes a public
URL that forwards inbound requests through the cluster, down the outbound tunnel,
to `localhost:3000` on that laptop. A name is **claimed + authenticated** (no
open relay, no squatting), and the same mechanism lets a **server-side headless
browser pod** reach a local endpoint when needed.

---

## 2. Options compared

Three realistic implementations were evaluated against the existing
Cloudflare + ingress-nginx + Infisical + NPL-auth stack.

| Criterion | **Cloudflare Tunnel (cloudflared)** | **frp (frps/frpc)** ⟵ recommended | **inlets / inlets-pro** |
|---|---|---|---|
| Self-hosted server pod on noizu-server | No server pod — Cloudflare edge terminates | Yes — `frps` Deployment | Yes — `inlets-server` Deployment |
| Inbound port needed on noizu-server | **None** (outbound 443 to CF edge) | One control port (e.g. `:7000`) + reuse `:443` via vhost | One control/data port |
| TLS on 443/80 | At Cloudflare edge (managed) | Reuse existing `cloudflare-tls-synced` at ingress-nginx, or frps `vhost_https` | At ingress or inlets TLS |
| Wildcard subdomain → tunnel mapping | Per-hostname ingress rules in tunnel config (CF-managed DNS rows or one wildcard route) | **`subdomain_host` + `subdomain` per client = native multi-tenant** | Manual / per-tunnel routing |
| Claim/secure a new named tunnel | CF API creates tunnel + token (heavier; one tunnel object per name, or shared with hostname routing) | Client presents **token**; `frps` validates; name = `subdomain` claim | Token per tunnel |
| Multi-tenant isolation | Strong (separate tunnels) but provisioning is API-driven per name | Good: per-client token + name; **gate registration through NPL** for true isolation | Weak built-in; needs wrapper |
| Auth model fit with NPL | Would need CF API orchestration; doesn't reuse the MCP JWT | **`frps` server plugin → HTTP callback to NPL** validates MCP JWT + name ownership. Clean reuse. | Custom token only |
| Arbitrary TCP (not just HTTP) | Supported (`cloudflared` TCP) but more setup | Native (`type = tcp/http/https`) | Native |
| Ops overhead / new moving parts | Lowest (managed edge), but couples tunnel lifecycle to CF API and adds a CF dependency on the data path | One Helm chart + one NPL endpoint; fits the tier/namespace/helm conventions exactly | New project, smaller community, pro features paywalled |
| Cost | Free | Free (OSS, Apache-2.0) | OSS basic; **inlets-pro is paid** for TCP/TLS/HA |
| Data path | Local → CF edge → CF → cluster origin | Local → frps(noizu-server) → in-cluster | Local → inlets-server → cluster |

### Why **frp**

1. **It mirrors the pattern we already ship.** `browser-controller` is already a
   local outbound client → cloud relay. frp is the same shape, generalized to
   arbitrary HTTP/TCP, and deploys as just another tiered Helm app on
   `noizu-server`.
2. **Native wildcard multi-tenancy.** `frps` `subdomain_host = remote-access.noizu.com`
   plus per-client `subdomain = starlight-robot` gives exactly the requested URL
   scheme with one config knob — no per-name DNS row or per-name tunnel object.
3. **First-class auth hook into NPL.** `frps` supports a **server plugin** (an
   HTTP callback on `Login`/`NewProxy`). We point it at a new NPL endpoint that
   validates the MCP JWT and checks that the user owns the requested name. This
   reuses the exact token system the browser-controller already uses, and gives
   the NPL backend a place to **mint, track, and revoke** tunnel registrations.
4. **Keeps Cloudflare as edge proxy, not as data-plane dependency.** We keep the
   orange-cloud + wildcard-cert model unchanged; frp lives behind ingress-nginx
   just like every other service. No new managed-service coupling on the hot path.
5. **Free, OSS, mature, single static binary** for the client — trivial to ship
   alongside `browser-controller` (and even bundle into the headless pod image).

Cloudflare Tunnel is the strong runner-up and is reasonable if we later want to
drop the public inbound control port entirely; its cost is per-name CF API
orchestration and putting CF on the data path. inlets is rejected on paywalled
TCP/TLS and a smaller ecosystem.

---

## 3. Recommended architecture

```
                         registration / auth (HTTPS)
   ┌─────────────────────────────────────────────────────────────┐
   │                                                               │
   ▼                                                               │
┌──────────────┐  1. POST /api/mcp/token (raw MCP key → JWT)       │
│ user laptop  │ ───────────────────────────────────────────────▶ │
│              │                                          NoizuPromptLingo backend
│ frpc client  │  2. claim name: POST /api/v1/remote-access/tunnels (Bearer JWT)
│  + NPL JWT   │ ◀─────────────── { name, tunnel_token } ─────────│  (npl-mcp, apps-ns)
│  :3000 local │                                                   │  ── mints/tracks/revokes ──▶ Postgres
└──────┬───────┘                                                   ▲
       │ 3. frpc dials frps control port (token=tunnel_token,      │  5. frps Login/NewProxy plugin
       │    subdomain=starlight-robot)                             │     HTTP callback validates token
       ▼                                                           │     + name ownership against NPL
┌─────────────────────────────────────────────┐                   │
│ noizu-server (208.64.36.80)                  │                   │
│                                              │   server plugin   │
│  ingress-nginx :443  (cloudflare-tls-synced) │   callback ───────┘
│      │  host *.remote-access.noizu.com       │
│      ▼                                        │
│  frps Service :vhost_http(80)/:7000(control) │
│      │  subdomain_host = remote-access.noizu.com
│      ▼  matches subdomain "starlight-robot"   │
│  ══ established tunnel ══▶ back up to laptop :3000
└─────────────────────────────────────────────┘
       ▲
       │ 4. public request
┌──────┴────────────────────────┐
│ https://starlight-robot        │   Cloudflare (orange cloud, *.remote-access.noizu.com)
│   .remote-access.noizu.com     │ ─────────────────────────────▶ 208.64.36.80
└────────────────────────────────┘
```

**Request flow at steady state:** Cloudflare proxies
`*.remote-access.noizu.com` → `208.64.36.80` → ingress-nginx terminates TLS with
the wildcard `cloudflare-tls-synced` secret → routes the host to the `frps`
`vhost_http` Service → `frps` matches the `subdomain` to the live `frpc`
connection → forwards the request down the tunnel to `localhost:3000` on the
laptop, and streams the response back.

**Headless-pod direction:** the server-side headless-browser pod simply requests
`https://<name>.remote-access.noizu.com` (or, for non-HTTP, an in-cluster
`frps` TCP Service) and reaches the local endpoint through the same tunnel — no
extra mechanism.

### Component placement (fits existing conventions)

- **Tier:** 3 (Core Applications) or 5 (Auxiliary) — co-locate with `npl-mcp`.
- **Namespace:** `apps-ns` (same as `npl-mcp`; add `remote-access: apps-ns` to
  `namespace_overrides` in `.infra-config.yaml` if not defaulting).
- **Node:** pinned to `noizu-server` via the standard
  `nodeSelector { "kubernetes.io/hostname" = "noizu-server" }`.
- **Chart:** `projects/NoizuPromptLingo/helm/remote-access` (new), referenced in
  `.infra-config.yaml` like `npl-mcp` (or upstream `noizu-infra` if we keep the
  base chart there).
- **Image:** `frps` upstream image is fine; no custom build needed unless we want
  to bake the server-plugin sidecar. The **client** (`frpc` + a thin wrapper) is
  shipped from the NPL repo next to `browser-controller`.

---

## 4. DNS / TLS / Ingress changes (concrete)

All three are additive; nothing existing changes.

### 4.1 DNS — new wildcard for the tunnel namespace

The existing `*.noizu.com` CNAME points at `derobot.is`, so
`*.remote-access.noizu.com` must be claimed explicitly (a more specific wildcard
wins). Add to `terraform/cloudflare/zones/noizu.com/main.tf`, matching the
existing `cloudflare_dns_record` style:

```hcl
# Wildcard for the remote-access reverse-tunnel subsystem.
# <name>.remote-access.noizu.com → noizu-server, proxied through Cloudflare.
resource "cloudflare_dns_record" "remote_access_wildcard" {
  zone_id = local.zone_id
  name    = "*.remote-access"
  type    = "A"
  content = local.ip          # 208.64.36.80 (same local already used by "root")
  proxied = true              # orange cloud — DDoS + hides origin
  ttl     = 1
}

# Optional apex for a status/landing page on the subsystem itself.
resource "cloudflare_dns_record" "remote_access_apex" {
  zone_id = local.zone_id
  name    = "remote-access"
  type    = "A"
  content = local.ip
  proxied = true
  ttl     = 1
}
```

> **Cloudflare proxy + WebSocket note.** Cloudflare's proxy supports WebSocket
> upgrades, so HTTP/WS tunnels work proxied. The **frpc→frps control channel**,
> however, is a long-lived custom TCP stream and must **not** go through the
> orange-cloud HTTP proxy. Two clean options:
> 1. Expose only the **HTTP vhost** (`*.remote-access.noizu.com`, proxied) through
>    ingress-nginx, and give the frps **control port** its own DNS-only record,
>    e.g. `tunnel.noizu.com` `proxied = false`, on a dedicated port (`:7000`)
>    that the laptop dials directly. (Recommended — least surprising.)
> 2. Use `frps` with `transport.tls.enable` and a Cloudflare Spectrum / a
>    Layer-4 path. Heavier; not needed initially.

### 4.2 TLS — reuse the existing wildcard secret (with one caveat)

`cloudflare-tls-synced` is the `*.noizu.com` wildcard, which **does not cover the
second-level wildcard** `*.remote-access.noizu.com`. Two paths:

- **(a) Cloudflare-terminated TLS only (simplest).** Because records are
  orange-cloud proxied, Cloudflare presents a valid edge cert for
  `*.remote-access.noizu.com` automatically (Total TLS / advanced cert), and the
  origin hop (CF → noizu-server) can use the existing `*.noizu.com` origin cert
  in "Full" mode — the SNI mismatch is tolerated at the origin in Full (not
  Full-Strict). Verify the zone's SSL mode; `Full` is sufficient.
- **(b) Issue a `*.remote-access.noizu.com` origin cert (cleanest for
  Full-Strict).** Mint a Cloudflare Origin CA cert for that hostname, store it in
  Infisical alongside the existing wildcard, sync it as a new secret
  `remote-access-tls-synced`, and reference it from the frps ingress `tls`
  block. This mirrors the existing `cloudflare-tls-synced` / `derobotis-tls`
  pattern (see `infra-services/secrets.tf`).

Recommend **(b)** for parity with how every other domain's TLS is handled
(per-scope Infisical-synced secret, no ACME).

### 4.3 Ingress — one Ingress for the HTTP vhost

Add an ingress (in the new Helm chart, or a `platform/*`/`infra-services` `.tf`
mirroring `phoenix.tf`) routing the wildcard host to the `frps` vhost Service:

```hcl
resource "kubernetes_ingress_v1" "remote_access" {
  metadata {
    name      = "remote-access"
    namespace = "apps-ns"
    annotations = {
      # frp vhost needs the original Host header to match a subdomain.
      "nginx.ingress.kubernetes.io/upstream-vhost" = "$host"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "3600"
      # WebSocket support is on by default in ingress-nginx.
    }
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["*.remote-access.noizu.com"]
      secret_name = "remote-access-tls-synced"   # or cloudflare-tls-synced if (a)
    }
    rule {
      host = "*.remote-access.noizu.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "remote-access-frps"
              port { number = 80 }   # frps vhost_http port
            }
          }
        }
      }
    }
  }
}
```

> ingress-nginx supports a hostname wildcard in `rule.host` (`*.remote-access…`).
> The `upstream-vhost` annotation preserves the original `Host` so frps can map
> it to the right `subdomain`.

### 4.4 frps control port exposure

Because the control channel can't be HTTP-proxied (§4.1), expose `:7000` via a
`hostPort`/NodePort on `noizu-server` (the node already binds host ports for
ingress-nginx), and point the DNS-only `tunnel.noizu.com` record at it. Lock it
to TLS (`transport.tls.force = true`) so only frpc with the right token+TLS can
speak it.

---

## 5. Server component

**`frps` Deployment** (Helm chart `remote-access`), values shape (illustrative):

```yaml
# frps.toml rendered from values
bindPort = 7000                       # control channel (DNS-only tunnel.noizu.com)
vhostHTTPPort = 80                    # behind ingress-nginx → *.remote-access
subdomainHost = "remote-access.noizu.com"
transport.tls.force = true

# Reject anonymous clients; delegate to NPL for token + name ownership.
[[httpPlugins]]
name = "npl-auth"
addr = "https://npl-mcp.apps-ns.svc.cluster.local:4000"
path = "/api/v1/remote-access/frp-auth"
ops  = ["Login", "NewProxy", "CloseProxy"]
```

- `Login` callback: frps forwards the client's metadata (incl. the tunnel token)
  to NPL; NPL validates and returns allow/deny.
- `NewProxy` callback: NPL checks the requested `subdomain` is one this user has
  claimed and is still active; rejects squatting / cross-tenant names.
- `CloseProxy`: NPL marks the registration disconnected (for the
  `Browser.Overview`-style "connected: true/false" status).

Pinned to `noizu-server`, single replica (matches every other workload), ns
`apps-ns`. Resource asks are tiny.

---

## 6. Client component

Ship a thin wrapper next to `browser-controller`
(`projects/NoizuPromptLingo/remote-access-client/` or a subcommand of the same
package) that:

1. Mints/loads an MCP JWT exactly like browser-controller
   (`POST https://tobor.locker/api/mcp/token` with the raw MCP key).
2. Calls **`POST /api/v1/remote-access/tunnels`** with `{ name, port }` and the
   Bearer JWT to **claim** the name and receive a short-lived `tunnel_token`.
3. Renders an `frpc.toml` and launches bundled `frpc`:

```toml
serverAddr = "tunnel.noizu.com"
serverPort = 7000
transport.tls.enable = true
metadatas.token = "<tunnel_token>"     # validated by the frps→NPL plugin

[[proxies]]
name = "starlight-robot"
type = "http"
localIP = "127.0.0.1"
localPort = 3000
subdomain = "starlight-robot"          # → starlight-robot.remote-access.noizu.com
```

CLI parity with browser-controller:

```bash
remote-access connect --name starlight-robot --port 3000 \
  --token <mcp-jwt>          # or BROWSER_CONTROLLER_TOKEN-style env vars
# → https://starlight-robot.remote-access.noizu.com  ready
```

For TCP (non-HTTP) services, `type = "tcp"` + an in-cluster `frps` TCP Service
that the headless pod dials directly (no public DNS needed).

---

## 7. Registration / auth flow

The whole point of routing registration through NPL is to get **named,
authenticated, revocable** tunnels — reusing the MCP-key/JWT system the
browser-controller already proves out.

New NPL backend surface (in `npl-mcp`, mirroring `token_controller.ex` /
`mcp_auth.ex`):

- `RemoteAccessTunnel` schema: `id, user_id, organization_id, name (unique within
  remote-access.noizu.com), tunnel_token_hash, status (active|revoked),
  last_connected_at, expires_at`. Reuses the tickets/assets **tri-scope &
  tombstone** conventions already in the codebase for name lifecycle.
- `POST /api/v1/remote-access/tunnels` (Bearer **MCP JWT**): validate JWT
  (`Noizu.MCP.Auth.CompoundJWTVerifier`, `iss "tobor-locker"`, active api_key);
  enforce the caller is an **editor of the org** (same gate as the browser
  channel); reserve `name` (reject if taken by another owner); generate a
  `tunnel_token` (store only its hash); return it once.
- `DELETE /api/v1/remote-access/tunnels/:name`: revoke (tombstone) the name.
- `GET /api/v1/remote-access/tunnels`: list the caller's claims + live status.
- `POST /api/v1/remote-access/frp-auth` (called by **frps**, not the user):
  the server-plugin callback. Looks up the `tunnel_token` hash, verifies the
  requested `subdomain` matches the claim and is `active`, returns allow/deny.
  Optionally rate-limits per user/org.

Name allocation = the `name` claim row; security = `tunnel_token` (per-claim,
hashed, revocable) + the frps→NPL `NewProxy` check that the subdomain belongs to
the presenting token's owner.

**Tie-in to browser-controller / headless pod:** identical auth front door (MCP
key → JWT). A single `Browser.Overview`-style status (`tunnel_connected: true`)
falls out of the `Login`/`CloseProxy` callbacks. The headless-browser pod can be
granted a tunnel claim the same way and reach local endpoints over
`<name>.remote-access.noizu.com`.

---

## 8. Security considerations

| Risk | Mitigation |
|---|---|
| **Open relay** (anyone tunnels anything out through our IP) | frps `Login` plugin rejects every client lacking a valid NPL-issued `tunnel_token`; no anonymous proxies. |
| **Name squatting** (`starlight-robot` claimed by a stranger) | Names are reserved rows owned by a user/org in NPL; `NewProxy` callback enforces ownership; tombstone on revoke. |
| **Token theft / long-lived exposure** | `tunnel_token` is per-claim, stored hashed, short TTL + revocable; MCP JWT already 30d + revocable via api_key status. Force `transport.tls` on the control channel. |
| **Abuse / DoS via tunneled traffic** | Cloudflare orange-cloud absorbs L3/4 + WAF on the HTTP vhost; per-user rate limits in the `frp-auth` callback; cap concurrent proxies/bandwidth per user in frps. |
| **Reaching internal cluster services** | frpc only forwards *from* the laptop *to* the public name; frps must run with no `tcp`/`stcp` visitor access to cluster internals beyond what's configured; keep frps in `apps-ns` with NetworkPolicy denying egress to data-ns. |
| **Exposing a local dev box to the internet** | Document clearly; default `http`-only; require explicit `--name`; surface live tunnels in the NPL UI so users can revoke. Consider optional Cloudflare Access in front of a name for private tunnels (zero-trust/ already has Access apps). |
| **Cert SNI / Full-Strict** | Use a dedicated `*.remote-access.noizu.com` origin cert (§4.2b) to keep Full-Strict. |
| **Control-port exposure** (`:7000` DNS-only, not behind CF) | TLS-forced, token-gated; firewall to expected source ranges if feasible; monitor connection attempts. |

NPL is the single audit/issue/revoke point for every tunnel — registrations are
tracked rows, so listing, expiring, and rate-limiting are all just queries.

---

## 9. Phased implementation checklist

**Phase 0 — Spec & decisions**
- [ ] Confirm tier (3 vs 5) and that `remote-access` lives under `npl-mcp`/`apps-ns`.
- [ ] Decide TLS path: (a) Cloudflare-terminated only vs (b) dedicated origin cert. Recommend (b).
- [ ] Decide control-port exposure: DNS-only `tunnel.noizu.com:7000` (recommended) vs Spectrum.

**Phase 1 — DNS / TLS / ingress (terraform)**
- [ ] Add `*.remote-access` (+ apex, + DNS-only `tunnel`) records to `terraform/cloudflare/zones/noizu.com/main.tf`.
- [ ] (If 4.2b) mint `*.remote-access.noizu.com` origin cert, add to Infisical, sync as `remote-access-tls-synced`.
- [ ] Verify zone SSL mode (Full vs Full-Strict) is consistent with the chosen cert.

**Phase 2 — frps server (helm)**
- [ ] New chart `projects/NoizuPromptLingo/helm/remote-access` (frps Deployment, vhost Service, control-port hostPort/NodePort, ingress for the wildcard host).
- [ ] Pin to `noizu-server`; ns `apps-ns`; NetworkPolicy denying egress to `data-ns`.
- [ ] Register in `.infra-config.yaml` (image, helm `values_path`, namespace_override, tier).
- [ ] Configure frps `subdomainHost`, `vhostHTTPPort`, TLS-forced control, and the NPL `httpPlugins` callback URL.

**Phase 3 — NPL backend (registration + auth)**
- [ ] `RemoteAccessTunnel` schema + Liquibase changelog (project uses Liquibase, not Ecto migrate).
- [ ] `POST/GET/DELETE /api/v1/remote-access/tunnels` (MCP-JWT gated, org-editor check).
- [ ] `POST /api/v1/remote-access/frp-auth` server-plugin callback (token + name-ownership + rate limit).
- [ ] Status surfacing (`tunnel_connected`) via `Login`/`CloseProxy`.

**Phase 4 — client**
- [ ] `remote-access-client` next to `browser-controller`: token mint, name claim, render `frpc.toml`, launch bundled `frpc`.
- [ ] CLI/env parity with browser-controller; `install.sh` + docs.

**Phase 5 — headless-pod integration**
- [ ] Grant the headless-browser pod a tunnel claim; verify it can reach `<name>.remote-access.noizu.com`.
- [ ] Optional in-cluster `frps` TCP Service path for non-HTTP local services.

**Phase 6 — hardening & UX**
- [ ] Per-user rate/concurrency caps; revoke-from-UI; live tunnel list.
- [ ] Optional Cloudflare Access in front of private named tunnels.
- [ ] Runbook + threat-model review (STRIDE) of the relay.

---

## Appendix — files referenced (all under `/Users/keithbrings/Work/Space/Infra/Noizu`)

- DNS / zone: `terraform/cloudflare/zones/noizu.com/{main,locals,provider,backend,variables}.tf`
- Ingress controller: `terraform/kubernetes/init/controllers.tf`, `…/init/outputs.tf`
- TLS secret pattern: `terraform/kubernetes/infra-services/secrets.tf`; platform `*/variables.tf` (`tls_secret_name`)
- Ingress example to mirror: `terraform/kubernetes/infra-services/phoenix.tf` (`eval.noizu.com`)
- Deploy config: `.infra-config.yaml` (tiers, `namespace_overrides`, `chart_path_overrides`, image→helm `values_path`)
- Auth to reuse: `projects/NoizuPromptLingo/backend/lib/noizu_prompt_lingua/token.ex`, `.../mcp_auth.ex`, `.../controllers/token_controller.ex`, `.../endpoint.ex`, `.../router.ex`
- Sibling client: `projects/NoizuPromptLingo/browser-controller/README.md`
