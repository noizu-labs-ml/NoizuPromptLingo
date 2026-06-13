# Cloud-Native Security

Reference guide for threat modeling Kubernetes clusters in self-hosted environments. Assumes Helm-based deployments, OpenEBS LVM storage, Cloudflare ingress/TLS, and Infisical for secrets management.

---

## Kubernetes Threat Landscape

The Kubernetes attack surface spans multiple layers: orchestration control plane, node-level daemons, container runtime, network fabric, and the software supply chain feeding all of them.

### Core Attack Surfaces

| Component | What It Exposes | Common Attack Vectors |
|-----------|----------------|----------------------|
| API Server | Cluster-wide control | Unauthenticated access, token theft, RBAC escalation |
| etcd | All cluster state and secrets | Direct access (unencrypted), snapshot exfiltration |
| Kubelet | Node-level pod control | Anonymous auth, read-only port (10255), exec into pods |
| Container Runtime | Host kernel access | Container escape, privileged containers, kernel exploits |
| Network | Pod-to-pod traffic | Lateral movement, DNS spoofing, unencrypted service traffic |
| Supply Chain | Image and dependency integrity | Malicious base images, typosquatting, compromised CI/CD |
| Helm/Tiller | Deployment control | Tiller (v2) cluster-admin, values injection, chart tampering |
| Storage (OpenEBS) | Persistent data | Unencrypted volumes, host path traversal, PV data exfiltration |

### STRIDE Mapping

| STRIDE Category | Kubernetes Attack Vectors |
|----------------|--------------------------|
| **Spoofing** | Forged ServiceAccount tokens, kubelet identity spoofing, DNS rebinding |
| **Tampering** | etcd modification, image layer injection, ConfigMap/Secret mutation, Helm values override |
| **Repudiation** | Disabled audit logging, missing admission webhooks, unsigned images |
| **Information Disclosure** | Secrets in environment variables, etcd plaintext, exposed metrics endpoints, verbose error responses |
| **Denial of Service** | Resource exhaustion (no limits/quotas), fork bombs, storage fill, API server flooding |
| **Elevation of Privilege** | Privileged containers, hostPID/hostNetwork, writable hostPath, RBAC wildcard grants, node-to-admin escalation |

---

## Pod Security Standards (PSS)

Pod Security Standards define three progressive restriction levels enforced via the `pod-security.kubernetes.io` namespace labels (or via admission controllers like OPA/Kyverno).

### PSS Levels

| Level | Purpose | Use Case |
|-------|---------|----------|
| **Privileged** | No restrictions | System-level workloads (CNI, storage drivers, monitoring agents) |
| **Baseline** | Blocks known privilege escalations | General workloads that need some flexibility |
| **Restricted** | Maximum lockdown | Untrusted workloads, multi-tenant clusters, production applications |

### Enforcement Modes

Apply per-namespace via labels:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

### SecurityContext Field Reference

| Field | Recommended Value | Baseline Allows | Restricted Requires | Notes |
|-------|-------------------|-----------------|---------------------|-------|
| `runAsNonRoot` | `true` | Not required | Required | Prevents UID 0 execution |
| `runAsUser` | `>= 1000` | Any | Non-zero | Set explicit UID |
| `readOnlyRootFilesystem` | `true` | Not required | Not required (but recommended) | Use `emptyDir` for write needs |
| `allowPrivilegeEscalation` | `false` | Not required | `false` required | Blocks `setuid` binaries |
| `privileged` | `false` | `false` required | `false` required | Full host access if true |
| `capabilities.drop` | `["ALL"]` | Partial restriction | `ALL` dropped | Add back only what is needed |
| `capabilities.add` | `[]` or `["NET_BIND_SERVICE"]` | Subset allowed | Only `NET_BIND_SERVICE` | Minimize added capabilities |
| `seccompProfile.type` | `RuntimeDefault` | Not required | `RuntimeDefault` or `Localhost` | Syscall filtering |
| `hostNetwork` | `false` | `false` required | `false` required | Shares host network namespace |
| `hostPID` | `false` | `false` required | `false` required | Sees host processes |
| `hostIPC` | `false` | `false` required | `false` required | Shares host IPC namespace |

### Recommended Pod SecurityContext Template

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault
containers:
  - name: app
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["ALL"]
    resources:
      limits:
        cpu: "500m"
        memory: "256Mi"
      requests:
        cpu: "100m"
        memory: "128Mi"
```

---

## RBAC Security Patterns

### Principle of Least Privilege

Every ServiceAccount should have the minimum permissions required for its workload. Default ServiceAccounts should never be used for application workloads.

```yaml
# Create a dedicated ServiceAccount per workload
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-sa
  namespace: my-namespace
automountServiceAccountToken: false  # Disable unless the pod needs API access
```

### Namespace-Scoped Roles vs ClusterRoles

| Use | Scope | When Appropriate |
|-----|-------|-----------------|
| `Role` + `RoleBinding` | Single namespace | Application workloads, namespace-scoped operators |
| `ClusterRole` + `RoleBinding` | Reusable template, namespace-bound | Common permission sets applied per-namespace |
| `ClusterRole` + `ClusterRoleBinding` | Cluster-wide | Infrastructure controllers, monitoring, admission webhooks |

Prefer `Role` + `RoleBinding` unless the workload genuinely needs cross-namespace or cluster-scoped resource access.

### Common RBAC Misconfigurations

| Misconfiguration | Risk | Remediation |
|------------------|------|-------------|
| Wildcard verbs (`verbs: ["*"]`) | Grants all operations including delete and escalate | List explicit verbs: `get`, `list`, `watch`, `create`, `update` |
| Wildcard resources (`resources: ["*"]`) | Access to secrets, RBAC objects, and custom resources | Enumerate specific resources |
| Binding roles to `default` ServiceAccount | Every pod in the namespace inherits permissions | Create per-workload ServiceAccounts |
| `cluster-admin` bindings to non-infra workloads | Full cluster compromise from single pod | Use scoped ClusterRoles |
| Granting `escalate` or `bind` verbs | Allows creating more-privileged roles | Never grant unless building an RBAC controller |
| `create` on `pods/exec` | Remote code execution in any pod | Restrict to specific pods or deny entirely |

### RBAC Audit Checklist

- [ ] No bindings reference the `default` ServiceAccount
- [ ] No Role or ClusterRole uses wildcard (`*`) verbs or resources
- [ ] `cluster-admin` is bound only to break-glass identities and infrastructure controllers
- [ ] All application pods set `automountServiceAccountToken: false` unless API access is required
- [ ] No ClusterRoleBinding grants namespace-scoped workloads cluster-wide access
- [ ] `pods/exec`, `pods/attach`, and `pods/portforward` are restricted to admin roles
- [ ] Roles granting `create` on `secrets` are audited (can mint arbitrary credentials)
- [ ] `escalate` and `bind` verbs are not granted outside of RBAC management tooling
- [ ] Helm release ServiceAccounts are scoped to their target namespace
- [ ] RBAC permissions are reviewed after every Helm chart upgrade

---

## Network Policy Design

By default, Kubernetes allows all pod-to-pod traffic. NetworkPolicies are the mechanism to restrict this.

### Default-Deny Patterns

Apply to every namespace as a baseline:

```yaml
# Default deny all ingress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: my-namespace
spec:
  podSelector: {}
  policyTypes:
    - Ingress

---
# Default deny all egress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
  namespace: my-namespace
spec:
  podSelector: {}
  policyTypes:
    - Egress
```

### Allow DNS Egress (Required with Deny-All Egress)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: my-namespace
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

### Allow Ingress from NGINX Ingress Controller

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-controller
  namespace: my-namespace
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: ingress-nginx
          podSelector:
            matchLabels:
              app.kubernetes.io/name: ingress-nginx
      ports:
        - protocol: TCP
          port: 8080
```

### Namespace Isolation Strategies

| Strategy | Pattern | Tradeoff |
|----------|---------|----------|
| Full isolation | Default-deny in every namespace, explicit allow-lists | Maximum security, higher maintenance |
| Tier-based | Allow within tier, deny across tiers unless explicit | Balances security and operability |
| Shared-services model | Designated namespaces (monitoring, logging) can reach all | Simpler ops, broader attack surface from shared namespaces |

### Cross-Namespace Communication Pattern

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-monitoring
  namespace: my-namespace
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              purpose: monitoring
      ports:
        - protocol: TCP
          port: 9090  # metrics
```

---

## Container Image Security

### Base Image Selection

| Base Image | Size | Attack Surface | Use Case |
|-----------|------|----------------|----------|
| `scratch` | 0 MB | Minimal (no shell, no libc) | Statically compiled Go binaries |
| `distroless` | 2-20 MB | No shell, no package manager | Java, Python, Node.js runtimes |
| `alpine` | 5 MB | musl libc, busybox shell | General purpose when shell is needed |
| `debian-slim` | 30 MB | glibc, apt (but stripped) | When glibc compatibility is required |
| `ubuntu` | 70+ MB | Full userland | Development only, avoid in production |

### Multi-Stage Build Pattern

```dockerfile
# Build stage
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server .

# Runtime stage
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /app/server /server
USER nonroot:nonroot
ENTRYPOINT ["/server"]
```

### Image Scanning Strategy

| Stage | Tool | Purpose |
|-------|------|---------|
| Developer workstation | `trivy image` | Fast feedback before push |
| CI pipeline | Trivy, Grype, or Snyk | Gate on severity thresholds |
| Registry | Harbor (built-in scanning), or registry webhooks | Continuous scanning of stored images |
| Runtime | Admission controller (Kyverno/OPA) | Block unscanned or unsigned images |

### Image Signing and Provenance

```bash
# Sign with cosign (keyless, using OIDC identity)
cosign sign --yes registry.example.com/my-image:v1.0.0

# Verify before deploy
cosign verify registry.example.com/my-image:v1.0.0 \
  --certificate-identity=ci@example.com \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com

# Generate and attach SBOM
syft registry.example.com/my-image:v1.0.0 -o spdx-json > sbom.json
cosign attach sbom --sbom sbom.json registry.example.com/my-image:v1.0.0
```

### Registry Security Checklist

- [ ] Use a private registry (Harbor, GHCR, or self-hosted)
- [ ] Enforce `imagePullPolicy: Always` for mutable tags
- [ ] Use image digests (`@sha256:...`) in production manifests
- [ ] Configure `imagePullSecrets` per namespace, not cluster-wide
- [ ] Enable vulnerability scanning on push
- [ ] Set retention policies to prune untagged images
- [ ] Restrict push access to CI/CD service accounts only

---

## Secrets Management in Kubernetes

### The Problem with Native K8s Secrets

Kubernetes Secrets are base64-encoded, not encrypted. Without additional configuration:

- Stored in plaintext in etcd
- Visible to anyone with `get secrets` RBAC
- Logged in full when verbose API audit logging is enabled
- Persisted in etcd backups without encryption

Enabling etcd encryption-at-rest mitigates storage exposure but does not address RBAC-based access or secret sprawl.

### External Secret Management Patterns

| Solution | Pattern | Strengths | Weaknesses |
|----------|---------|-----------|------------|
| **Infisical** (CRD) | InfisicalSecret syncs to K8s Secret | GitOps-friendly, auto-rotation, audit trail | Operator dependency, sync latency |
| **Vault** (sidecar/CSI) | Agent injects secrets at pod start | Dynamic secrets, lease management | Complexity, HA requirements |
| **Sealed Secrets** | Encrypted in Git, decrypted in-cluster | GitOps-native, no external dependency | No rotation, key management burden |
| **External Secrets Operator** | Syncs from any external store to K8s | Multi-provider, standardized CRD | Another operator to manage |

### InfisicalSecret CRD Pattern

As used in this repository -- secrets are declared as InfisicalSecret CRDs and auto-synced to Kubernetes Secrets by the Infisical operator.

```yaml
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: my-app-secrets
  namespace: my-namespace
spec:
  hostAPI: https://infisical.noizu.com/api
  resyncInterval: 60  # seconds
  authentication:
    universalAuth:
      secretsScope:
        projectSlug: my-project
        envSlug: prod
        secretsPath: /
      credentialsRef:
        secretName: infisical-machine-identity
        secretNamespace: infisical-core
  managedSecretReference:
    secretName: my-app-k8s-secret
    secretNamespace: my-namespace
    secretType: kubernetes.io/Opaque
```

### Secret Rotation Strategies

| Strategy | Mechanism | Downtime Risk |
|----------|-----------|---------------|
| Operator resync | `resyncInterval` on InfisicalSecret | Near-zero (pod reads updated Secret on next mount refresh) |
| Rolling restart | Update secret, then `kubectl rollout restart` | Brief (rolling update) |
| Dual-read | Application reads both old and new key during transition | None (application handles) |
| Sidecar refresh | Vault agent / CSI driver refreshes mounted secrets | None (file-based mounts auto-update) |

### Mount vs Environment Variable

| Aspect | Volume Mount | Environment Variable |
|--------|-------------|---------------------|
| Update without restart | Yes (kubelet refreshes) | No (env is immutable after start) |
| Exposure in `kubectl describe` | No | Yes (visible in pod spec) |
| Exposure in crash dumps | Less likely | Often included |
| Application complexity | Read from file path | Direct `os.Getenv()` |
| Recommendation | **Preferred** | Avoid for sensitive values |

```yaml
# Preferred: volume mount
volumes:
  - name: secrets
    secret:
      secretName: my-app-k8s-secret
containers:
  - volumeMounts:
      - name: secrets
        mountPath: /etc/secrets
        readOnly: true
```

---

## Supply Chain Security

### SBOM Generation

Generate Software Bills of Materials at build time and attach to images:

```bash
# Generate SBOM from container image
syft registry.example.com/my-app:v1.0.0 -o spdx-json > sbom.spdx.json

# Generate SBOM from source directory
syft dir:./src -o cyclonedx-json > sbom.cdx.json
```

### Dependency Scanning Tools

| Tool | Scans | Integration | License |
|------|-------|-------------|---------|
| **Trivy** | Images, filesystems, Git repos, K8s clusters | CLI, CI/CD, admission webhook | Apache 2.0 |
| **Grype** | Images, SBOMs, filesystems | CLI, CI/CD | Apache 2.0 |
| **Snyk** | Images, code, IaC, dependencies | CLI, CI/CD, IDE, registry | Commercial (free tier) |

### Admission Controllers for Policy

| Controller | Language | Strength |
|-----------|----------|----------|
| **Kyverno** | YAML (native K8s) | Low learning curve, generate/mutate/validate |
| **OPA Gatekeeper** | Rego | Powerful policy language, shared with non-K8s use cases |

Example Kyverno policy -- require image signatures:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-signed-images
spec:
  validationFailureAction: Enforce
  rules:
    - name: verify-signature
      match:
        any:
          - resources:
              kinds:
                - Pod
      verifyImages:
        - imageReferences:
            - "registry.example.com/*"
          attestors:
            - entries:
                - keyless:
                    subject: "ci@example.com"
                    issuer: "https://token.actions.githubusercontent.com"
```

### Signed Commits and Verified Builds

- Require GPG or SSH commit signing on protected branches
- Pin CI/CD actions by SHA, not tag (`uses: actions/checkout@abcdef123`)
- Use reproducible builds where possible
- Store build provenance (SLSA framework) alongside artifacts
- Verify Helm chart integrity with `helm verify` (provenance files)

---

## Ingress and TLS Security

### TLS Termination Patterns

| Pattern | TLS Terminates At | In-Cluster Traffic | Use Case |
|---------|-------------------|-------------------|----------|
| Edge termination | Ingress controller | Plaintext | Simple, sufficient when network is trusted |
| Re-encryption | Ingress controller | TLS to backend pod | Defense in depth, regulatory compliance |
| Passthrough | Backend pod | End-to-end encrypted | Maximum security, pod manages own certs |

### Cloudflare Authenticated Origin Pull

Cloudflare presents a client certificate to your origin. NGINX verifies it, ensuring only Cloudflare can reach your ingress. This is the pattern used in this repository via `cloudflare-lib`.

```yaml
# Ingress annotations (via cloudflare-lib template)
annotations:
  nginx.ingress.kubernetes.io/auth-tls-verify-client: "on"
  nginx.ingress.kubernetes.io/auth-tls-secret: "default/cloudflare-origin-pull-ca"
  nginx.ingress.kubernetes.io/auth-tls-verify-depth: "1"
```

Combined with Cloudflare IP whitelisting, this provides two layers:

1. **IP whitelist** -- NGINX only accepts connections from Cloudflare IP ranges
2. **Client certificate** -- NGINX verifies the Cloudflare-presented TLS client cert

### Certificate Management

| Approach | Mechanism | Rotation |
|----------|-----------|----------|
| Cloudflare Origin CA | 15-year certs issued by Cloudflare | Manual (long-lived) |
| cert-manager + Let's Encrypt | Automatic ACME challenge | Automatic (90-day) |
| Infisical-managed certs | Synced via InfisicalSecret CRD | Automatic (resync interval) |
| Manual certs in K8s Secrets | `kubectl create secret tls` | Manual |

### mTLS Between Services

For service-to-service authentication within the cluster:

| Approach | Complexity | Coverage |
|----------|-----------|----------|
| Service mesh (Istio, Linkerd) | High | Automatic mTLS for all meshed services |
| SPIFFE/SPIRE | Medium | Workload identity and cert issuance |
| Application-level TLS | Low | Per-service, manual cert management |

For most self-hosted clusters without regulatory mTLS requirements, NetworkPolicies provide sufficient isolation. Add mTLS when handling financial, healthcare, or PII data across namespace boundaries.

---

## Runtime Security

### Falco for Anomaly Detection

Falco monitors syscalls and Kubernetes audit logs for suspicious activity.

Key detection categories:

| Category | Example Rules |
|----------|--------------|
| Container escape | Write to `/etc`, mount sensitive host paths |
| Crypto mining | Unexpected outbound connections on mining ports |
| Reverse shells | Shell spawned by non-shell parent process |
| Privilege escalation | `setuid` calls, capability changes |
| Data exfiltration | Unexpected DNS lookups, large outbound transfers |
| Drift detection | New binary executed that was not in original image |

### API Server Audit Policy

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  # Log all requests to secrets at Metadata level (no body)
  - level: Metadata
    resources:
      - group: ""
        resources: ["secrets"]
  # Log authentication failures
  - level: Request
    users: ["system:anonymous"]
    verbs: ["*"]
  # Log exec/attach at RequestResponse level
  - level: RequestResponse
    resources:
      - group: ""
        resources: ["pods/exec", "pods/attach"]
  # Default: log at Metadata level
  - level: Metadata
    omitStages:
      - RequestReceived
```

### Resource Limits and Quotas

Prevent denial-of-service via resource exhaustion:

```yaml
# LimitRange -- defaults for pods without explicit limits
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: my-namespace
spec:
  limits:
    - type: Container
      default:
        cpu: "500m"
        memory: "256Mi"
      defaultRequest:
        cpu: "100m"
        memory: "128Mi"
      max:
        cpu: "2"
        memory: "1Gi"

---
# ResourceQuota -- namespace-wide caps
apiVersion: v1
kind: ResourceQuota
metadata:
  name: namespace-quota
  namespace: my-namespace
spec:
  hard:
    requests.cpu: "8"
    requests.memory: "16Gi"
    limits.cpu: "16"
    limits.memory: "32Gi"
    pods: "50"
    secrets: "20"
```

### Node Security

| Control | Recommendation |
|---------|---------------|
| SSH access | Key-based only, disable password auth, restrict to bastion |
| Host filesystem | No `hostPath` mounts except for system pods |
| Kernel parameters | Restrict via `seccompProfile` and AppArmor/SELinux |
| Node updates | Automated OS patching (unattended-upgrades, kured for reboot) |
| kubelet | Disable anonymous auth, enable webhook authn/authz |
| Read-only ports | Disable kubelet read-only port (10255) |

---

## CIS Kubernetes Benchmark Quick Reference

Top 20 checks organized by severity. Run `kube-bench` for automated assessment.

### Critical

| # | Check | Remediation |
|---|-------|-------------|
| 1.2.6 | API server: disable anonymous auth | Set `--anonymous-auth=false` |
| 1.2.16 | API server: enable admission controllers | Enable `NodeRestriction`, `PodSecurity` |
| 1.1.12 | etcd data directory permissions | Set ownership to `etcd:etcd`, mode `0700` |
| 2.1 | etcd: enable client cert auth | Configure `--client-cert-auth=true` |
| 2.6 | etcd: enable peer TLS | Set `--peer-cert-file` and `--peer-key-file` |

### High

| # | Check | Remediation |
|---|-------|-------------|
| 1.2.20 | API server: enable audit logging | Configure `--audit-policy-file` and `--audit-log-path` |
| 1.2.22 | API server: set audit log maxage | Set `--audit-log-maxage=30` |
| 1.3.2 | Controller manager: bind to localhost | Set `--bind-address=127.0.0.1` |
| 1.4.1 | Scheduler: bind to localhost | Set `--bind-address=127.0.0.1` |
| 4.2.1 | Kubelet: disable anonymous auth | Set `authentication.anonymous.enabled=false` |
| 4.2.4 | Kubelet: enable webhook authorization | Set `authorization.mode=Webhook` |
| 4.2.6 | Kubelet: protect kernel defaults | Set `--protect-kernel-defaults=true` |
| 4.2.10 | Kubelet: rotate certificates | Set `--rotate-certificates=true` |
| 5.1.5 | RBAC: no default SA auto-mount | Set `automountServiceAccountToken: false` |
| 5.2.2 | PSP/PSS: do not admit privileged containers | Enforce Baseline or Restricted PSS |

### Medium

| # | Check | Remediation |
|---|-------|-------------|
| 1.2.10 | API server: enable RBAC | Set `--authorization-mode=Node,RBAC` |
| 1.1.19 | API server: set TLS cert and key | Configure `--tls-cert-file` and `--tls-private-key-file` |
| 5.3.2 | NetworkPolicies: default deny per namespace | Apply default-deny NetworkPolicy |
| 5.4.1 | Secrets: prefer external management | Use Infisical/Vault instead of inline Secrets |
| 5.7.4 | Namespace: avoid using `default` | Deploy workloads to named namespaces |

---

## References

- [Kubernetes Security Documentation](https://kubernetes.io/docs/concepts/security/)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [NIST SP 800-190: Container Security Guide](https://csrc.nist.gov/publications/detail/sp/800-190/final)
- [Infisical Kubernetes Operator](https://infisical.com/docs/integrations/platforms/kubernetes)
- [Cloudflare Authenticated Origin Pull](https://developers.cloudflare.com/ssl/origin-configuration/authenticated-origin-pull/)
- [Falco Runtime Security](https://falco.org/docs/)
- [Sigstore / cosign](https://docs.sigstore.dev/)
- [SLSA Framework](https://slsa.dev/)
