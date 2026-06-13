# Kubernetes Security Hardening

Comprehensive guide for hardening Kubernetes clusters across cluster infrastructure, workload isolation, access control, network segmentation, admission control, and runtime defense.

---

## Table of Contents

1. [Cluster-Level Security](#cluster-level-security)
2. [Pod Security Standards](#pod-security-standards)
3. [RBAC Design](#rbac-design)
4. [Network Policies](#network-policies)
5. [Admission Controllers](#admission-controllers)
6. [Supply Chain Security](#supply-chain-security)
7. [Runtime Security](#runtime-security)
8. [Hardening Checklist](#hardening-checklist)

---

## Cluster-Level Security

### API Server Audit Logging

Audit logging captures every request to the API server with configurable verbosity per resource and verb. Without it, you have no forensic trail.

**AuditPolicy — recommended production baseline:**

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  # Never log read-only requests to non-sensitive resources
  - level: None
    verbs: ["get", "watch", "list"]
    resources:
      - group: ""
        resources: ["events"]

  # Never log requests from system:kube-proxy
  - level: None
    users: ["system:kube-proxy"]
    verbs: ["watch"]
    resources:
      - group: ""
        resources: ["endpoints", "services", "services/status"]

  # Log at metadata level for read-only access to common resources
  - level: Metadata
    verbs: ["get", "list", "watch"]
    resources:
      - group: ""
        resources: ["secrets", "configmaps", "serviceaccounts/token"]
      - group: "rbac.authorization.k8s.io"
        resources: ["clusterroles", "clusterrolebindings", "roles", "rolebindings"]

  # Log request and response bodies for mutations to sensitive resources
  - level: RequestResponse
    verbs: ["create", "update", "patch", "delete", "deletecollection"]
    resources:
      - group: ""
        resources: ["secrets", "configmaps", "serviceaccounts"]
      - group: "rbac.authorization.k8s.io"
        resources: ["*"]
      - group: "admissionregistration.k8s.io"
        resources: ["*"]

  # Log metadata for all other requests
  - level: Metadata
    omitStages:
      - RequestReceived
```

**API server flags to enable audit logging:**

```
--audit-policy-file=/etc/kubernetes/audit-policy.yaml
--audit-log-path=/var/log/kubernetes/audit.log
--audit-log-maxage=30
--audit-log-maxbackup=10
--audit-log-maxsize=100
```

For production, pipe to a SIEM (Elastic, Splunk, Loki) rather than local files. Use `--audit-webhook-config-file` to ship events in real time.

---

### etcd Encryption at Rest

etcd stores all cluster state including Secrets in plaintext by default. Encryption at rest prevents raw disk reads from exposing credentials.

**EncryptionConfiguration — AES-GCM with key rotation support:**

```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
      - configmaps
    providers:
      # First provider is used for encryption of new writes
      - aescbc:
          keys:
            - name: key-2024-q4
              secret: <base64-encoded-32-byte-key>
            # Previous key kept for decryption of old data during rotation
            - name: key-2024-q3
              secret: <base64-encoded-32-byte-key-old>
      # Identity allows reading unencrypted data written before encryption was enabled
      - identity: {}
```

Enable via API server flag:
```
--encryption-provider-config=/etc/kubernetes/encryption-config.yaml
```

**Key rotation procedure:**

1. Add new key as first entry in `keys[]`
2. Restart API servers (rolling)
3. Re-encrypt all secrets: `kubectl get secrets --all-namespaces -o json | kubectl replace -f -`
4. Remove old key entry
5. Restart API servers again

**KMS integration (preferred for production):**

Replace `aescbc` with `kms` provider to envelope-encrypt with an external KMS (AWS KMS, GCP CKMS, HashiCorp Vault). The etcd value is encrypted with a data encryption key, which is itself encrypted by the KMS.

```yaml
providers:
  - kms:
      apiVersion: v2
      name: aws-kms-provider
      endpoint: unix:///var/run/kmsplugin/socket.sock
      timeout: 3s
  - identity: {}
```

---

### CIS Benchmark Scanning with kube-bench

[kube-bench](https://github.com/aquasecurity/kube-bench) automates CIS Kubernetes Benchmark checks across control plane, etcd, worker nodes, and policies.

**Run as a Job on the cluster:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: kube-bench
spec:
  template:
    spec:
      hostPID: true
      nodeSelector:
        node-role.kubernetes.io/control-plane: ""
      tolerations:
        - key: node-role.kubernetes.io/control-plane
          effect: NoSchedule
      containers:
        - name: kube-bench
          image: aquasec/kube-bench:latest
          command: ["kube-bench", "--json"]
          volumeMounts:
            - name: var-lib-etcd
              mountPath: /var/lib/etcd
              readOnly: true
            - name: etc-kubernetes
              mountPath: /etc/kubernetes
              readOnly: true
      restartPolicy: Never
      volumes:
        - name: var-lib-etcd
          hostPath:
            path: /var/lib/etcd
        - name: etc-kubernetes
          hostPath:
            path: /etc/kubernetes
```

**Priority remediations from CIS Benchmark:**

| Check ID | Finding | Remediation |
|----------|---------|-------------|
| 1.1.x | API server config file permissions | `chmod 600 /etc/kubernetes/manifests/kube-apiserver.yaml` |
| 1.2.6 | `--insecure-port` not 0 | Set `--insecure-port=0` |
| 1.2.14 | `--anonymous-auth` enabled | Set `--anonymous-auth=false` |
| 1.2.16 | `--profiling` enabled | Set `--profiling=false` |
| 2.1 | etcd not using TLS | Set `--cert-file` and `--key-file` |
| 4.2.6 | kubelet `--protect-kernel-defaults` not set | Set `--protect-kernel-defaults=true` |

---

## Pod Security Standards

Pod Security Standards (PSS) replaced PodSecurityPolicy in Kubernetes 1.25. Three built-in levels provide a spectrum from unrestricted to hardened.

### The Three Levels

| Level | Use Case | What It Allows |
|-------|----------|----------------|
| `privileged` | Trusted system workloads (CNI, CSI) | Everything — no restrictions |
| `baseline` | General application workloads | Prevents known privilege escalation vectors |
| `restricted` | Security-sensitive workloads | Heavily restricted; follows hardening best practices |

### Namespace Labels

Apply PSS via namespace labels. Three modes per level:

- `enforce` — Reject pods that violate the policy
- `audit` — Allow pods but log violations to audit log
- `warn` — Allow pods but return warning to the API client

**Recommended: enforce baseline everywhere, enforce restricted for sensitive namespaces:**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production-app
  labels:
    # Enforce restricted — pods that don't comply will be rejected
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest
    # Warn on baseline violations for easier migration debugging
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/warn-version: latest
    # Audit everything for forensic record
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/audit-version: latest
```

**System namespace — privileged level for infrastructure workloads:**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: kube-system
  labels:
    pod-security.kubernetes.io/enforce: privileged
```

### Restricted Profile — Full Requirements

To pass the `restricted` level, pods must satisfy all of the following:

**1. Non-root user:**

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000          # Must not be 0
  runAsGroup: 1000
```

**2. Drop ALL capabilities:**

```yaml
securityContext:
  capabilities:
    drop:
      - ALL
    # Only add back what you actually need
    add:
      - NET_BIND_SERVICE    # Only if binding ports < 1024
```

**3. Read-only root filesystem:**

```yaml
securityContext:
  readOnlyRootFilesystem: true
```

Mount writable volumes only where needed:

```yaml
volumeMounts:
  - name: tmp
    mountPath: /tmp
  - name: cache
    mountPath: /app/cache
volumes:
  - name: tmp
    emptyDir: {}
  - name: cache
    emptyDir: {}
```

**4. No privilege escalation:**

```yaml
securityContext:
  allowPrivilegeEscalation: false
```

**5. Seccomp profile:**

```yaml
securityContext:
  seccompProfile:
    type: RuntimeDefault    # or Localhost for custom profiles
```

**6. No hostPath, hostNetwork, hostPID, hostIPC:**

```yaml
spec:
  hostNetwork: false
  hostPID: false
  hostIPC: false
  # No hostPath volumes
```

**Complete compliant pod example:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hardened-app
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: app
      image: myapp:v1.2.3@sha256:<digest>
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
      volumeMounts:
        - name: tmp
          mountPath: /tmp
  volumes:
    - name: tmp
      emptyDir: {}
```

---

## RBAC Design

### Least Privilege Principles

1. **Grant at the narrowest scope** — namespace Role before ClusterRole
2. **Grant specific verbs** — `["get", "list"]` not `["*"]`
3. **Grant specific resources** — `["pods"]` not `["*"]`
4. **No cluster-admin for applications** — only for break-glass human access
5. **Separate service accounts per workload** — never share the default SA

### Namespace-Scoped Roles vs ClusterRoles

| Use | Resource |
|-----|----------|
| Namespace-specific permissions | `Role` + `RoleBinding` |
| Cluster-wide resources (nodes, PVs) | `ClusterRole` + `ClusterRoleBinding` |
| Same permissions in every namespace | `ClusterRole` + `RoleBinding` (per namespace) |
| Aggregating permissions | `ClusterRole` with `aggregationRule` |

**Minimal service account Role:**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: configmap-reader
  namespace: production
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list", "watch"]
    resourceNames: ["app-config"]   # Restrict to specific ConfigMap names
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-configmap-reader
  namespace: production
subjects:
  - kind: ServiceAccount
    name: my-app
    namespace: production
roleRef:
  kind: Role
  name: configmap-reader
  apiGroup: rbac.authorization.k8s.io
```

### Aggregated ClusterRoles

Use `aggregationRule` to compose roles that automatically inherit from labeled sub-roles. This is how `view`, `edit`, and `admin` work in stock Kubernetes.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-aggregate
aggregationRule:
  clusterRoleSelectors:
    - matchLabels:
        rbac.monitoring.io/aggregate-to-monitoring: "true"
rules: []   # Populated automatically by aggregation

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pods-metrics-reader
  labels:
    rbac.monitoring.io/aggregate-to-monitoring: "true"
rules:
  - apiGroups: ["metrics.k8s.io"]
    resources: ["pods", "nodes"]
    verbs: ["get", "list"]
```

### RBAC Audit Commands

```bash
# Who can do what in a namespace
kubectl auth can-i --list --as=system:serviceaccount:production:my-app -n production

# Check specific permission
kubectl auth can-i delete secrets -n production --as=system:serviceaccount:production:my-app

# Find all ClusterRoleBindings granting cluster-admin
kubectl get clusterrolebindings -o json | \
  jq '.items[] | select(.roleRef.name=="cluster-admin") | .subjects'

# List all service accounts with explicit permissions
kubectl get rolebindings,clusterrolebindings --all-namespaces -o json | \
  jq '.items[] | select(.subjects[]?.kind=="ServiceAccount")'

# Audit: find wildcard grants
kubectl get clusterroles -o json | \
  jq '.items[] | select(.rules[]?.verbs[]?=="*") | .metadata.name'
```

### Common RBAC Mistakes

| Mistake | Risk | Fix |
|---------|------|-----|
| Wildcard verbs `["*"]` | Over-permission; cannot audit specific actions | List explicit verbs |
| Wildcard resources `["*"]` | Grants access to future CRDs | List specific resources |
| `cluster-admin` for apps | Full cluster takeover on pod compromise | Namespace-scoped Role |
| Shared service accounts | Blast radius expansion across workloads | One SA per workload |
| Default SA with bindings | Default SA is auto-mounted; easy target | Bind to named SA only |
| No `automountServiceAccountToken: false` | Token injected even when unused | Disable auto-mount |

**Disable auto-mounted SA token when not needed:**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app
automountServiceAccountToken: false
---
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: my-app
  automountServiceAccountToken: false   # Belt and suspenders
```

---

## Network Policies

By default, Kubernetes allows all pod-to-pod traffic. Network Policies (enforced by the CNI — Calico, Cilium, etc.) provide L3/L4 segmentation.

### Default Deny-All Ingress

Apply this to every namespace as a baseline. Allowlist rules then open specific paths.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: production
spec:
  podSelector: {}       # Selects ALL pods in namespace
  policyTypes:
    - Ingress
```

**Default deny egress (stricter — apply with caution, requires explicit DNS allow):**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
    - Egress
---
# Required companion: allow DNS
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-egress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - ports:
        - port: 53
          protocol: UDP
        - port: 53
          protocol: TCP
```

### Allowlisting Patterns

**Allow ingress from specific pods (pod selector):**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-api
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 8080
```

**Allow ingress from specific namespace:**

```yaml
ingress:
  - from:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: monitoring
      - podSelector:
          matchLabels:
            app: prometheus
```

Note: When `namespaceSelector` and `podSelector` are in the same `from` list item, they are ANDed. Separate list items are ORed.

**Allow egress to external CIDR:**

```yaml
egress:
  - to:
      - ipBlock:
          cidr: 10.0.0.0/8
          except:
            - 10.0.0.0/24    # Exclude specific range
    ports:
      - protocol: TCP
        port: 5432
```

### Cilium L7 Policies

Cilium extends NetworkPolicy with L7-aware `CiliumNetworkPolicy` for HTTP, gRPC, Kafka, and DNS filtering.

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: api-http-policy
  namespace: production
spec:
  endpointSelector:
    matchLabels:
      app: api
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: frontend
      toPorts:
        - ports:
            - port: "8080"
              protocol: TCP
          rules:
            http:
              - method: GET
                path: /api/v1/.*
              - method: POST
                path: /api/v1/orders
  egress:
    - toFQDNs:
        - matchName: "payments.external.com"
      toPorts:
        - ports:
            - port: "443"
              protocol: TCP
```

---

## Admission Controllers

Admission controllers intercept API requests after authentication/authorization but before persistence. They can mutate (change) or validate (allow/reject) resources.

### Kyverno vs OPA/Gatekeeper

| Dimension | Kyverno | OPA/Gatekeeper |
|-----------|---------|----------------|
| Policy language | YAML-native | Rego (purpose-built) |
| Learning curve | Low — K8s-native idioms | High — Rego is a new language |
| Mutation support | Yes — patches, defaults | Limited |
| Policy-as-code | YAML in Git | Rego + ConstraintTemplate CRDs |
| Audit mode | Yes | Yes |
| Generate resources | Yes | No |
| Verify images | Yes (cosign integration) | Via external data |
| Community policies | Kyverno policy library | Gatekeeper policy library |
| Best for | Platform teams preferring K8s YAML | Teams comfortable with Rego |

### Common Policies with Kyverno

**Require non-root containers:**

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-run-as-non-root
spec:
  validationFailureAction: Enforce
  background: true
  rules:
    - name: check-containers
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: "Containers must not run as root."
        pattern:
          spec:
            containers:
              - securityContext:
                  runAsNonRoot: true
            initContainers:
              - =(securityContext):
                  =(runAsNonRoot): true
```

**Disallow latest tag:**

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
spec:
  validationFailureAction: Enforce
  rules:
    - name: require-image-tag
      match:
        any:
          - resources:
              kinds: [Pod]
      validate:
        message: "Image tag 'latest' is not allowed. Use a specific version tag."
        foreach:
          - list: "request.object.spec.containers"
            deny:
              conditions:
                any:
                  - key: "{{element.image}}"
                    operator: Equals
                    value: "*:latest"
                  - key: "{{element.image}}"
                    operator: NotContains
                    value: ":"
```

**Auto-generate NetworkPolicy on namespace creation:**

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: generate-default-networkpolicy
spec:
  rules:
    - name: generate-deny-all-ingress
      match:
        any:
          - resources:
              kinds: [Namespace]
      generate:
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        name: default-deny-ingress
        namespace: "{{request.object.metadata.name}}"
        synchronize: true
        data:
          spec:
            podSelector: {}
            policyTypes:
              - Ingress
```

### Policy Exceptions

Kyverno supports `PolicyException` for workloads that legitimately need to bypass a policy (e.g., CNI pods in kube-system):

```yaml
apiVersion: kyverno.io/v2
kind: PolicyException
metadata:
  name: calico-node-exception
  namespace: kube-system
spec:
  exceptions:
    - policyName: require-run-as-non-root
      ruleNames:
        - check-containers
  match:
    any:
      - resources:
          kinds: [Pod]
          namespaces: [kube-system]
          selector:
            matchLabels:
              k8s-app: calico-node
```

---

## Supply Chain Security

### Image Signing with cosign

[cosign](https://github.com/sigstore/cosign) signs container images and attestations using keyless (Sigstore) or key-based signing.

**Sign an image after build:**

```bash
# Keyless signing (uses OIDC identity — works in CI with GitHub Actions, GCP, etc.)
cosign sign --yes ghcr.io/myorg/myapp:v1.2.3@sha256:<digest>

# Key-based signing
cosign generate-key-pair
cosign sign --key cosign.key ghcr.io/myorg/myapp:v1.2.3
```

**Verify before deploy:**

```bash
cosign verify \
  --certificate-identity-regexp="https://github.com/myorg/myapp/.github/workflows/.*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/myorg/myapp:v1.2.3
```

**Kyverno policy to enforce signature verification:**

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-image-signatures
spec:
  validationFailureAction: Enforce
  rules:
    - name: verify-signature
      match:
        any:
          - resources:
              kinds: [Pod]
      verifyImages:
        - imageReferences:
            - "ghcr.io/myorg/*"
          attestors:
            - entries:
                - keyless:
                    subject: "https://github.com/myorg/*"
                    issuer: "https://token.actions.githubusercontent.com"
```

### Registry Allowlists

Prevent pulling images from untrusted registries:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-image-registries
spec:
  validationFailureAction: Enforce
  rules:
    - name: validate-registries
      match:
        any:
          - resources:
              kinds: [Pod]
      validate:
        message: "Images must come from approved registries."
        foreach:
          - list: "request.object.spec.containers"
            deny:
              conditions:
                all:
                  - key: "{{element.image}}"
                    operator: NotStartsWith
                    value: "ghcr.io/myorg/"
                  - key: "{{element.image}}"
                    operator: NotStartsWith
                    value: "registry.k8s.io/"
```

### SBOM Generation

Generate Software Bill of Materials during CI:

```bash
# Generate SBOM with syft
syft ghcr.io/myorg/myapp:v1.2.3 -o spdx-json > sbom.spdx.json

# Attach SBOM as attestation
cosign attest --predicate sbom.spdx.json --type spdxjson \
  ghcr.io/myorg/myapp:v1.2.3
```

### Vulnerability Scanning with Trivy

```bash
# Scan image in CI
trivy image --exit-code 1 --severity CRITICAL,HIGH \
  ghcr.io/myorg/myapp:v1.2.3

# Scan running cluster (all images in use)
trivy k8s --report=summary cluster

# Scan Helm chart
trivy config ./my-chart/
```

**Trivy as a Kubernetes Operator (trivy-operator):**

```bash
helm repo add aquasecurity https://aquasecurity.github.io/helm-charts/
helm install trivy-operator aquasecurity/trivy-operator \
  --namespace trivy-system \
  --create-namespace \
  --set="trivy.ignoreUnfixed=true"
```

Produces `VulnerabilityReport` and `ConfigAuditReport` CRDs per workload.

---

## Runtime Security

### Falco

Falco uses eBPF/kernel modules to detect anomalous behavior at runtime based on syscall patterns.

**Custom Falco rule — detect shell in container:**

```yaml
- rule: Shell in Container
  desc: A shell was spawned in a container
  condition: >
    spawned_process and
    container and
    shell_procs and
    not proc.pname in (shell_procs)
  output: >
    Shell spawned in container
    (user=%user.name container=%container.name
     image=%container.image.repository:%container.image.tag
     cmd=%proc.cmdline parent=%proc.pname)
  priority: WARNING
  tags: [container, shell, T1059]

- rule: Write to /etc in Container
  desc: Attempt to write to /etc in a running container
  condition: >
    open_write and
    container and
    fd.name startswith /etc
  output: >
    File write in /etc detected
    (user=%user.name file=%fd.name container=%container.name)
  priority: ERROR
```

**Alert routing:**

```yaml
# falco.yaml
json_output: true
http_output:
  enabled: true
  url: http://falcosidekick:2801/
```

Route via falcosidekick to Slack, PagerDuty, Elasticsearch, or any webhook.

### Tetragon (Cilium Runtime Security)

Tetragon provides eBPF-based enforcement (not just detection) with `TracingPolicy` CRDs:

```yaml
apiVersion: cilium.io/v1alpha1
kind: TracingPolicy
metadata:
  name: block-write-bin
spec:
  kprobes:
    - call: "sys_openat"
      syscall: true
      args:
        - index: 0
          type: int
        - index: 1
          type: "char_buf"
          sizeArgIndex: 3
        - index: 2
          type: int
      selectors:
        - matchArgs:
            - index: 2
              operator: "Mask"
              values:
                - "1"   # O_WRONLY
          matchActions:
            - action: Sigkill   # Kill process attempting write
          matchCapabilities:
            - type: Effective
              operator: NotIn
              values:
                - "CAP_SYS_ADMIN"
          matchNamespaces:
            - namespace: Pid
              operator: NotIn
              values:
                - "host_ns"
```

### Custom Seccomp Profiles

Pin workloads to a minimal syscall allowlist:

```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "architectures": ["SCMP_ARCH_X86_64"],
  "syscalls": [
    {
      "names": [
        "read", "write", "open", "close", "stat", "fstat",
        "mmap", "mprotect", "munmap", "brk", "rt_sigaction",
        "rt_sigprocmask", "ioctl", "access", "pipe", "select",
        "sched_yield", "mremap", "msync", "mincore", "madvise",
        "dup", "dup2", "nanosleep", "getpid", "sendfile",
        "socket", "connect", "accept", "sendto", "recvfrom",
        "bind", "listen", "getsockname", "getpeername",
        "setsockopt", "getsockopt", "clone", "fork", "vfork",
        "execve", "exit", "wait4", "kill", "uname", "getuid",
        "getgid", "geteuid", "getegid", "getcwd", "chdir",
        "rename", "mkdir", "rmdir", "unlink", "readlink",
        "chmod", "gettimeofday", "getrlimit", "sysinfo",
        "times", "ptrace", "getppid", "setsid", "setuid",
        "setgid", "futex", "set_tid_address", "exit_group",
        "openat", "getdents64", "set_robust_list",
        "clock_gettime", "clock_nanosleep", "epoll_create1",
        "epoll_ctl", "epoll_wait", "accept4", "eventfd2",
        "timerfd_create", "timerfd_settime", "timerfd_gettime",
        "signalfd4", "getrandom", "prlimit64", "sendmsg",
        "recvmsg", "fchown", "fchmod", "lstat", "readlinkat"
      ],
      "action": "SCMP_ACT_ALLOW"
    }
  ]
}
```

Store at `/var/lib/kubelet/seccomp/profiles/my-app.json` and reference:

```yaml
securityContext:
  seccompProfile:
    type: Localhost
    localhostProfile: profiles/my-app.json
```

---

## Hardening Checklist

### Cluster Infrastructure

- [ ] API server audit logging enabled and shipped to SIEM
- [ ] etcd encrypted at rest (AES-GCM or KMS)
- [ ] etcd mTLS between peers and API server
- [ ] API server `--anonymous-auth=false`
- [ ] API server `--insecure-port=0`
- [ ] API server `--profiling=false`
- [ ] kubelet `--protect-kernel-defaults=true`
- [ ] kubelet anonymous auth disabled
- [ ] kube-bench scan passing CIS Level 2
- [ ] Control plane nodes tainted (no user workloads)

### Workload Security

- [ ] Pod Security Standards enforced (baseline minimum, restricted preferred)
- [ ] All containers run as non-root
- [ ] `allowPrivilegeEscalation: false` on all containers
- [ ] `readOnlyRootFilesystem: true` where possible
- [ ] `capabilities.drop: [ALL]` on all containers
- [ ] Seccomp profile `RuntimeDefault` or stricter
- [ ] No `hostNetwork`, `hostPID`, `hostIPC`
- [ ] No `hostPath` volumes (or restricted via policy)
- [ ] Resource limits set on all containers

### Access Control

- [ ] No wildcard verbs or resources in RBAC
- [ ] No applications bound to `cluster-admin`
- [ ] Unique ServiceAccount per workload
- [ ] `automountServiceAccountToken: false` where token unused
- [ ] RBAC audit run quarterly

### Network

- [ ] Default deny-all ingress NetworkPolicy in every namespace
- [ ] Default deny-all egress NetworkPolicy in sensitive namespaces
- [ ] DNS egress explicitly allowed
- [ ] Explicit allowlist policies for all required traffic paths

### Supply Chain

- [ ] Images signed with cosign in CI
- [ ] Signature verification enforced at admission (Kyverno/OPA)
- [ ] Registry allowlist policy enforced
- [ ] No `latest` tag permitted
- [ ] Trivy scan on every image build
- [ ] SBOM generated and stored per release

### Runtime

- [ ] Falco deployed with alerting configured
- [ ] Runtime alerts routed to on-call
- [ ] Incident response runbook for common Falco alerts
