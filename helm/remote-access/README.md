# remote-access (frps)

Helm chart for the **cloud side** of the frp reverse-tunnel subsystem — the
`frps` server. It runs pinned to `noizu-server`, terminates inbound HTTP for
`*.remote-access.noizu.com` behind ingress-nginx, and delegates auth to the
NoizuPromptLingo (`npl-mcp`) backend via the frps HTTP server plugin.

See `projects/NoizuPromptLingo/docs/REMOTE-ACCESS-TUNNEL-DESIGN.md` (§3, §4.3,
§4.4, §5) for the full architecture. This chart implements **Phase 2** of that
plan. The NPL `frp-auth` endpoint (Phase 3) and the `frpc` client (Phase 4) are
separate work items.

## Request flow

```
Cloudflare (*.remote-access.noizu.com, orange-cloud) → 208.64.36.80
  → ingress-nginx :443 (remote-access-tls-synced)
  → remote-access Service :80 (frps vhostHTTP)
  → frps matches subdomain → established frpc tunnel → laptop :localPort

frpc control channel → tunnel.noizu.com:7000 (DNS-only) → frps bindPort (hostPort)
  frps Login/NewProxy/CloseProxy → npl-mcp /api/v1/remote-access/frp-auth
```

## Files

| File | Purpose |
|---|---|
| `templates/configmap.yaml` | Renders `frps.toml` from values (control/vhost ports, `subdomainHost`, TLS-force, NPL `httpPlugins` callback). |
| `templates/deployment.yaml` | Single-replica `frps`, mounts `frps.toml`, `nodeSelector: noizu-server`, `hostPort` for the control port, config checksum rollout. |
| `templates/service.yaml` | ClusterIP exposing vhost `:80` (Ingress backend) + control `:7000`; optional NodePort Service for the control port. |
| `templates/ingress.yaml` | `*.remote-access.noizu.com` → vhost Service, `upstream-vhost: $host`, `proxy-read-timeout: 3600`, optional Cloudflare-only source range. |
| `templates/networkpolicy.yaml` | Allow-only egress (DNS + npl-mcp); data-ns reachability dropped by absence. |
| `templates/_helpers.tpl` | name/labels/selectorLabels + Cloudflare whitelist (matches `start-app`). |

Namespace is taken from the release namespace (`helm-upgrade` sets it from
`namespace_overrides`), matching the other charts in this repo.

## Values

| Key | Default | Notes |
|---|---|---|
| `replicas` | `1` | Single instance (matches every workload). |
| `image` | `snowdreamtech/frps:0.61.1` | Upstream frps; `fatedier/frps:0.61.1` also works. |
| `imagePullPolicy` | `IfNotPresent` | |
| `nodeSelector` | `{kubernetes.io/hostname: noizu-server}` | Only public-facing node. |
| `resources` | tiny (25m/32Mi → 200m/128Mi) | |
| `imagePullSecrets` | `[]` | Set if the image is mirrored to the private registry. |
| `frps.bindPort` | `7000` | Control channel port. |
| `frps.vhostHTTPPort` | `80` | HTTP vhost behind ingress. |
| `frps.subdomainHost` | `remote-access.noizu.com` | `<subdomain>.<subdomainHost>`. |
| `frps.tlsForce` | `true` | `transport.tls.force` on the control channel. |
| `frps.auth.pluginName` | `npl-auth` | httpPlugin name. |
| `frps.auth.addr` | `http://npl-mcp.apps-ns.svc.cluster.local:4000` | NPL callback base. |
| `frps.auth.path` | `/api/v1/remote-access/frp-auth` | NPL callback path. |
| `frps.auth.ops` | `[Login, NewProxy, CloseProxy]` | Hooked operations. |
| `frps.extraConfig` | `""` | Raw TOML appended verbatim (log level, limits). |
| `controlPort.hostPort` | `7000` | Bind control port on the node so DNS-only `tunnel.noizu.com` reaches it. Set `null`/`0` to disable. |
| `controlPort.nodePort.enabled` | `false` | Also publish a NodePort Service for the control port. |
| `controlPort.nodePort.port` | `30700` | |
| `service.type` | `ClusterIP` | |
| `ingress.enabled` | `true` | |
| `ingress.className` | `nginx` | |
| `ingress.host` | `*.remote-access.noizu.com` | |
| `ingress.annotations` | `upstream-vhost: $host`, `proxy-read-timeout: 3600`, `proxy-send-timeout: 3600` | |
| `ingress.cloudflareOnly` | `true` | Restrict ingress source IPs to Cloudflare ranges. |
| `tls.enabled` | `true` | |
| `tls.secretName` | `remote-access-tls-synced` | Override to `cloudflare-tls-synced` for Cloudflare-terminated TLS only (§4.2a). |
| `networkPolicy.enabled` | `true` | |
| `networkPolicy.dataNsCidr` | `""` | Documented only; deny is by allow-list absence (see below). |
| `networkPolicy.nplMcp.namespace` | `apps-ns` | Egress allowed to this namespace. |
| `networkPolicy.nplMcp.port` | `4000` | |

### NetworkPolicy note (deny egress to data-ns)

Plain `NetworkPolicy` is allow-only — there is no deny rule. The policy here
grants egress to **DNS** and **npl-mcp** only; `data-ns` is simply not in the
allow-list, so traffic to it is dropped by the default-deny that a present
`Egress` policy imposes. `networkPolicy.dataNsCidr` is carried for operator
documentation; switch to Cilium/Calico `CiliumNetworkPolicy` if an explicit
deny is required.

## Deploy

```bash
# Prereqs (Phase 1, separate): *.remote-access + tunnel DNS records;
# remote-access-tls-synced secret synced from Infisical into apps-ns.
helm-upgrade --list                          # confirm tier/namespace
helm-upgrade --include remote-access         # deploy/upgrade this chart
helm-upgrade --include remote-access --preview   # diff live vs proposed
```

Do not run `helm`/`apply` until the NPL `frp-auth` endpoint exists, or every
`Login` callback will fail closed (clients rejected) — which is the safe state.

## `.infra-config.yaml` registration snippet

`frps` is an upstream third-party image (no build target in this repo), so it is
registered as a tier-5 chart + namespace override + a standalone chart
reference. Add the following:

1. Under the tier-5 (`Auxiliary & AI Infrastructure`) `charts:` list:

```yaml
      - remote-access
```

2. Under `namespace_overrides:` (Apps section):

```yaml
  remote-access: apps-ns
```

3. As a standalone chart reference (alongside the other `projects[]` entries —
   no `services:` block since the image is not built here):

```yaml
    - domain: remote-access
      name: remote-access.noizu.com
      base_path: projects/NoizuPromptLingo
      helm:
        charts:
          - name: remote-access
            path: projects/NoizuPromptLingo/helm/remote-access
```

> Tier 5 co-locates it with `npl-mcp`'s namespace (`apps-ns`); the design notes
> tier 3 or 5 are both acceptable (§3). If `frps` is later mirrored to the
> private registry, add a `services:` entry with a `helm.values_path` (e.g.
> `.image`) so `docker-push --update-helm` can bump the tag.
