# Kubernetes Networking Reference Guide

A comprehensive reference for Kubernetes networking: Services, Ingress, Gateway API, service mesh, DNS tuning, and NetworkPolicy design.

---

## Table of Contents

1. [Service Types](#service-types)
2. [Ingress vs Gateway API](#ingress-vs-gateway-api)
3. [Ingress Controllers](#ingress-controllers)
4. [Service Mesh](#service-mesh)
5. [DNS Tuning](#dns-tuning)
6. [NetworkPolicy Design](#networkpolicy-design)

---

## Service Types

A Kubernetes Service is a stable network endpoint that load-balances traffic to a set of Pods. The `type` field controls how traffic reaches it from inside and outside the cluster.

### ClusterIP (default)

Internal-only stable IP. DNS resolves within the cluster. No external access.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-backend
  namespace: my-app
spec:
  type: ClusterIP
  selector:
    app: my-backend
  ports:
    - port: 80          # Port on the Service
      targetPort: 8080  # Port on the Pod
      protocol: TCP
```

DNS: `my-backend.my-app.svc.cluster.local` → ClusterIP  
Use for: Internal microservice communication, databases, caches.

### NodePort

Exposes the service on a static port (30000–32767) on every node's IP. External traffic: `<NodeIP>:<NodePort>` → Service → Pod.

```yaml
spec:
  type: NodePort
  selector:
    app: my-app
  ports:
    - port: 80
      targetPort: 8080
      nodePort: 31080   # Omit to auto-assign
```

Use for: Development, bare-metal clusters without a cloud load balancer, direct node access.  
Avoid in production: Exposes a port on every node, bypasses standard load balancers.

### LoadBalancer

Provisions a cloud load balancer (AWS ELB, GCP LB, Azure LB) and assigns an external IP. Extends NodePort — the LB forwards to node ports.

```yaml
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
    - port: 443
      targetPort: 8443
  loadBalancerSourceRanges:
    - 10.0.0.0/8        # Restrict source IPs at LB level
```

Annotations control cloud-specific behavior:

```yaml
metadata:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
    service.beta.kubernetes.io/aws-load-balancer-internal: "true"
```

Use for: Services that must be directly exposed without an Ingress controller (e.g., TCP/UDP services, SMTP, game servers).

### ExternalName

Maps a Service name to an external DNS name. No proxying — kube-dns returns a CNAME.

```yaml
spec:
  type: ExternalName
  externalName: my-database.us-east-1.rds.amazonaws.com
```

DNS: `my-db.my-app.svc.cluster.local` → CNAME → `my-database.us-east-1.rds.amazonaws.com`

Use for: Abstracting external dependencies behind an in-cluster DNS name. Allows swapping external endpoints without updating application config.

### Headless Service

`clusterIP: None` — no stable VIP. DNS returns individual Pod IPs directly. Used for stateful sets, client-side load balancing, service discovery.

```yaml
spec:
  clusterIP: None
  selector:
    app: my-statefulset
  ports:
    - port: 5432
```

DNS: `my-statefulset.my-app.svc.cluster.local` → returns all Pod IPs (A records)  
DNS: `pod-0.my-statefulset.my-app.svc.cluster.local` → individual Pod IP (StatefulSet pods)

Use for: StatefulSets (Postgres, Kafka, ZooKeeper), gRPC clients that handle LB themselves, service mesh sidecar discovery.

---

## Ingress vs Gateway API

### Ingress (Legacy)

`Ingress` is the original Kubernetes API for HTTP(S) routing. It routes external HTTP(S) traffic to Services based on host and path rules.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/proxy-body-size: 50m
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - my-app.example.com
      secretName: my-app-tls
  rules:
    - host: my-app.example.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: my-api
                port:
                  number: 80
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-frontend
                port:
                  number: 80
```

**Ingress limitations**:
- Annotations are controller-specific — not portable between NGINX, Traefik, Envoy
- No native support for TCP/UDP routing, gRPC, traffic weighting, header mutation
- Single resource handles routing concerns that logically belong to different teams (infra vs app)
- No built-in multi-tenancy model

### Gateway API (Future Standard)

Gateway API is the successor to Ingress. It is role-oriented, expressive, and extensible. It separates concerns into distinct resources:

| Resource | Owner | Role |
|----------|-------|------|
| `GatewayClass` | Infrastructure admin | Defines the controller implementation |
| `Gateway` | Cluster operator | Defines listeners (ports, protocols, TLS) |
| `HTTPRoute` | Application team | Defines HTTP routing rules |
| `GRPCRoute` | Application team | Defines gRPC routing rules |
| `TCPRoute` | Application team | Defines TCP routing rules |

#### GatewayClass and Gateway

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: envoy-gateway
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller

---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: prod-gateway
  namespace: infra
spec:
  gatewayClassName: envoy-gateway
  listeners:
    - name: https
      port: 443
      protocol: HTTPS
      tls:
        mode: Terminate
        certificateRefs:
          - name: wildcard-tls
            namespace: infra
      allowedRoutes:
        namespaces:
          from: Selector
          selector:
            matchLabels:
              gateway-access: allowed
```

#### HTTPRoute

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-app
  namespace: my-app    # Different namespace from Gateway
spec:
  parentRefs:
    - name: prod-gateway
      namespace: infra
      sectionName: https
  hostnames:
    - my-app.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /api
        - headers:
            - name: X-API-Version
              value: v2
      backendRefs:
        - name: my-api-v2
          port: 80
          weight: 100
    - matches:
        - path:
            type: PathPrefix
            value: /api
      filters:
        - type: RequestHeaderModifier
          requestHeaderModifier:
            add:
              - name: X-Forwarded-Prefix
                value: /api
      backendRefs:
        - name: my-api-v1
          port: 80
          weight: 90
        - name: my-api-canary
          port: 80
          weight: 10   # 10% traffic to canary
```

#### GRPCRoute

```yaml
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: GRPCRoute
metadata:
  name: my-grpc-service
  namespace: my-app
spec:
  parentRefs:
    - name: prod-gateway
      namespace: infra
  hostnames:
    - grpc.example.com
  rules:
    - matches:
        - method:
            service: mypackage.MyService
            method: MyMethod
      backendRefs:
        - name: my-grpc-backend
          port: 9090
```

#### TCPRoute

```yaml
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: TCPRoute
metadata:
  name: postgres-route
  namespace: databases
spec:
  parentRefs:
    - name: prod-gateway
      namespace: infra
      sectionName: postgres   # Gateway listener on port 5432
  rules:
    - backendRefs:
        - name: postgres
          port: 5432
```

### Why Gateway API Is the Future

- **Portable**: Routes are controller-agnostic — the same YAML works with Envoy Gateway, Cilium, NGINX Gateway Fabric
- **Role-separated**: Infra teams own `Gateway`, app teams own `Route` — no annotation wars, no cross-team coupling
- **Expressive**: Native traffic weighting, header manipulation, URL rewriting — no annotations needed
- **Multi-protocol**: HTTP, HTTPS, gRPC, TCP, UDP in one coherent API
- **Multi-tenancy**: `ReferenceGrant` controls cross-namespace backend references
- **Extensible**: `ExtensionRef` and policy attachment allow controller-specific features without polluting core API

---

## Ingress Controllers

### NGINX Ingress Controller

The most widely deployed. Mature, battle-tested, large ecosystem of annotations.

| Property | Value |
|----------|-------|
| Protocol support | HTTP, HTTPS, TCP/UDP (via ConfigMap) |
| Configuration | Annotations, ConfigMap |
| Gateway API support | Partial (NGINX Gateway Fabric is separate project) |
| Performance | High — C++ NGINX core |

**When to choose**: Existing NGINX expertise, large annotation ecosystem, broad cloud provider compatibility.

### Envoy Gateway

Cloud-native gateway built on Envoy Proxy, designed for Gateway API from the ground up.

| Property | Value |
|----------|-------|
| Protocol support | HTTP, HTTPS, gRPC, TCP, UDP, WebSocket |
| Configuration | Gateway API native |
| Gateway API support | Full — reference implementation |
| Performance | Very high — Envoy C++ data plane |

**When to choose**: New clusters, Gateway API adoption, gRPC-heavy workloads, service mesh integration (Envoy-based mesh composability).

### Traefik

Dynamic, auto-discovery focused. Native Docker/K8s service discovery without explicit configuration.

| Property | Value |
|----------|-------|
| Protocol support | HTTP, HTTPS, TCP, UDP, gRPC |
| Configuration | IngressRoute CRD, Ingress annotations, Gateway API (beta) |
| Gateway API support | Beta |
| Performance | Good — Go-based |

**When to choose**: Mixed Docker/Kubernetes environments, rapid configuration from service labels/annotations, simpler operational model for smaller teams.

---

## Service Mesh

A service mesh provides mTLS encryption, observability (traces, metrics, access logs), traffic management, and policy enforcement for service-to-service communication — without modifying application code.

### When You Need a Mesh

| Need | Mesh Required? |
|------|---------------|
| mTLS between all services | Yes |
| Per-request traces across services | Yes (or OpenTelemetry SDK) |
| Traffic shifting at L7 (not Ingress) | Yes |
| Circuit breaking, retries, timeouts per route | Yes |
| Zero-trust network within cluster | Yes |
| Basic service-to-service communication | No — NetworkPolicy + TLS in app is enough |
| Only external traffic management | No — Ingress/Gateway API is enough |

### Istio Ambient Mode

Ambient mode eliminates the per-pod sidecar. Traffic is handled by:
- **ztunnel**: Per-node DaemonSet — L4 mTLS, telemetry, policy enforcement
- **waypoint proxy**: Per-namespace or per-service Envoy proxy — L7 features (HTTP routing, authorization policies, retries)

```yaml
# Enable ambient for a namespace
apiVersion: v1
kind: Namespace
metadata:
  name: my-app
  labels:
    istio.io/dataplane-mode: ambient

---
# Deploy a waypoint for L7 features
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: waypoint
  namespace: my-app
  annotations:
    istio.io/waypoint-for: service
spec:
  gatewayClassName: istio-waypoint
  listeners:
    - name: mesh
      port: 15008
      protocol: HBONE
```

**Advantages over sidecar mode**: No per-pod overhead, no restart required to add mesh, simpler upgrade path, ~30-40% lower resource usage.

### Linkerd

Ultralight, security-focused mesh. Rust-based micro-proxy (linkerd2-proxy) — minimal CPU/memory overhead.

| Feature | Linkerd | Istio |
|---------|---------|-------|
| Resource overhead | Very low (~10MB/proxy) | Moderate (Envoy ~50MB/proxy) |
| Configuration complexity | Low | High |
| L7 policy | Limited | Full |
| Multi-cluster | Via service mirroring | Via east-west gateway |
| Protocol detection | Automatic | Automatic |
| WASM extensions | No | Yes |

**When to choose Linkerd**: Resource-constrained clusters, strong security posture with minimal config, teams that want mesh-on by default with zero config.

**When to choose Istio**: Full L7 traffic management within the mesh, WASM extensions, mature multi-cluster federation, Envoy ecosystem familiarity.

---

## DNS Tuning

Kubernetes DNS is provided by CoreDNS. Default configuration works for most clusters but has known performance pitfalls at scale.

### Default DNS Behavior

Every Pod uses CoreDNS as its nameserver. DNS resolution for `my-service` goes through the ndots search path:

```
my-service.my-namespace.svc.cluster.local  → hit
my-service.my-namespace                    → miss (before .local)
my-service.svc.cluster.local              → miss
my-service.cluster.local                  → miss
my-service                                → miss (external lookup)
```

With default `ndots:5`, a name like `api.example.com` triggers **5 DNS queries** before getting the external answer. This is the ndots problem.

### ndots:2 Fix

Set `ndots: 2` in Pod spec to reduce unnecessary cluster-local lookups for external names:

```yaml
spec:
  dnsConfig:
    options:
      - name: ndots
        value: "2"
      - name: single-request-reopen  # Fix for some DNS timeout issues
```

With `ndots: 2`, `api.example.com` (2 dots) is treated as absolute and resolves directly — no search path traversal.

**Trade-off**: Short internal service names like `my-service` (0 dots) will still go through the search path. Use FQDNs internally (`my-service.my-namespace.svc.cluster.local`) to avoid search path for internal names too.

### Autopath Plugin

CoreDNS `autopath` plugin answers in one round trip by predicting the correct FQDN server-side, eliminating client-side retries. Reduces DNS queries by ~4x for cluster-local names.

```yaml
# CoreDNS ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        autopath @kubernetes        # Enable autopath
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
```

### Node-Local DNS Cache

Deploy `node-local-dns` DaemonSet to run a CoreDNS instance on each node. Pods query the local node cache instead of the cluster CoreDNS Service, eliminating conntrack table saturation and reducing cross-node DNS traffic.

```bash
# Deploy node-local-dns (uses link-local address 169.254.20.10)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/dns/nodelocaldns/nodelocaldns.yaml
```

Pod DNS configuration with node-local-dns:

```yaml
spec:
  dnsPolicy: None
  dnsConfig:
    nameservers:
      - 169.254.20.10       # Node-local cache
    searches:
      - my-namespace.svc.cluster.local
      - svc.cluster.local
      - cluster.local
    options:
      - name: ndots
        value: "5"
      - name: single-request-reopen
```

**Impact at scale**: Reduces CoreDNS pod load by 90%+ on large clusters with high DNS query rates.

---

## NetworkPolicy Design

NetworkPolicy resources control which Pods can communicate with each other and with external endpoints. By default, all traffic is allowed — NetworkPolicy is additive whitelisting.

### Default-Deny All (Recommended Baseline)

Apply this to every namespace to establish zero-trust baseline, then add explicit allow policies.

```yaml
# Deny all ingress and egress in namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: my-app
spec:
  podSelector: {}      # Applies to all pods in namespace
  policyTypes:
    - Ingress
    - Egress
```

After applying, nothing can reach your pods and your pods cannot reach anything. Add policies to open specific paths.

### Allow Ingress from Specific Namespace

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-from-frontend
  namespace: my-app
spec:
  podSelector:
    matchLabels:
      app: my-backend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: frontend-ns
          podSelector:
            matchLabels:
              app: my-frontend
      ports:
        - protocol: TCP
          port: 8080
```

Note: `namespaceSelector` AND `podSelector` in the same `from` entry means both must match. Use separate list items for OR logic.

### Allow Egress to Specific Service

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-to-database
  namespace: my-app
spec:
  podSelector:
    matchLabels:
      app: my-backend
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: databases
          podSelector:
            matchLabels:
              app: postgres
      ports:
        - protocol: TCP
          port: 5432
    - to:                   # Allow DNS
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

Always include a DNS egress rule — without it, `default-deny-all` blocks DNS and nothing resolves.

### Allow Egress to External CIDR

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-external-api
  namespace: my-app
spec:
  podSelector:
    matchLabels:
      app: my-backend
  policyTypes:
    - Egress
  egress:
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
              - 10.0.0.0/8        # Exclude RFC-1918 — force traffic to be
              - 172.16.0.0/12     # explicit about internal vs external
              - 192.168.0.0/16
      ports:
        - protocol: TCP
          port: 443
```

### Allow Prometheus Scraping

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-prometheus-scrape
  namespace: my-app
spec:
  podSelector: {}          # All pods in namespace
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring
          podSelector:
            matchLabels:
              app.kubernetes.io/name: prometheus
      ports:
        - protocol: TCP
          port: 9090        # Or whatever your metrics port is
```

### Cilium L7 NetworkPolicy

Standard Kubernetes `NetworkPolicy` operates at L3/L4 (IP/port). Cilium's `CiliumNetworkPolicy` extends this to L7 — allowing or denying based on HTTP method, path, gRPC service, DNS name, and Kafka topic.

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-http-get-only
  namespace: my-app
spec:
  endpointSelector:
    matchLabels:
      app: my-backend
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: my-frontend
      toPorts:
        - ports:
            - port: "8080"
              protocol: TCP
          rules:
            http:
              - method: GET
                path: /api/v1/.*
              - method: POST
                path: /api/v1/items
              # POST to /admin is NOT in the list — blocked at L7

---
# Cilium DNS egress policy
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-egress-s3
  namespace: my-app
spec:
  endpointSelector:
    matchLabels:
      app: my-backend
  egress:
    - toFQDNs:
        - matchName: s3.amazonaws.com
        - matchPattern: "*.s3.amazonaws.com"
      toPorts:
        - ports:
            - port: "443"
              protocol: TCP
```

**Cilium L7 advantages**:
- Block specific HTTP methods or paths — not just ports
- Egress control by DNS name (not just IP CIDR — which changes for cloud services)
- gRPC-aware routing (by service/method)
- Kafka topic-level access control
- Integrated with Hubble for deep observability

### NetworkPolicy Checklist

| Check | Action |
|-------|--------|
| Default-deny applied to all namespaces | `kubectl get netpol --all-namespaces` |
| DNS egress explicitly allowed | Every egress policy must include port 53 |
| Monitoring ingress allowed | Prometheus can scrape metrics |
| Health check ingress allowed | Kubelet can reach liveness/readiness probes |
| Cross-namespace refs use both selectors | Avoid accidentally allowing all pods in a namespace |
| Policies tested before enforcement | Use `cilium connectivity test` or `network-policy-editor.sysdig.com` |
