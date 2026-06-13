# Recipe: Multi-Tenant Namespace Isolation

**Difficulty:** Intermediate
**Prerequisites:** RBAC (Role, RoleBinding, ServiceAccount), NetworkPolicy, basic namespace management

---

## Goal

Create a Kubernetes namespace that is fully isolated for a single tenant: resource-bounded, network-isolated, least-privilege RBAC, Pod Security Standards enforced, and scoped ServiceAccounts. Multiple copies of this pattern can coexist on the same cluster without tenants interfering with each other.

---

## Background

Kubernetes namespaces provide naming isolation but not security isolation by default. Without additional controls:

- Pods in one namespace can send network traffic to pods in any other namespace.
- A service account with default permissions can list secrets cluster-wide (depending on RBAC setup).
- Tenants can exhaust node resources, starving other namespaces.

This recipe layers four controls to produce genuine isolation:

1. **ResourceQuota + LimitRange** — cap compute and object counts
2. **RBAC** — least-privilege role scoped to the namespace
3. **NetworkPolicy** — default-deny with explicit allowlist
4. **Pod Security Standards** — enforce `restricted` or `baseline` via namespace labels

---

## Namespace Design Decisions

| Decision | Recommendation | Rationale |
|----------|---------------|-----------|
| One namespace per tenant | Yes | Clean quota, RBAC, and NetworkPolicy boundary |
| Shared cluster services | Allowed via NetworkPolicy egress rules | DNS, metrics, ingress controller |
| Pod Security Standard | `restricted` for new workloads | Blocks privilege escalation, host network/pid |
| Default deny-all NetworkPolicy | Required | Explicit allowlist is safer than implicit allow |

---

## Full Working Example

```yaml
# 1. Namespace with Pod Security Standards labels
apiVersion: v1
kind: Namespace
metadata:
  name: tenant-acme
  labels:
    # Enforce restricted PSS — pods that violate are rejected
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest
    # Warn and audit at restricted level as well
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/audit: restricted
---
# 2. ResourceQuota — cap total compute and object counts
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tenant-acme-quota
  namespace: tenant-acme
spec:
  hard:
    # Compute
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    # Object counts
    pods: "20"
    services: "10"
    persistentvolumeclaims: "5"
    secrets: "20"
    configmaps: "20"
---
# 3. LimitRange — enforce per-container defaults and caps
apiVersion: v1
kind: LimitRange
metadata:
  name: tenant-acme-limits
  namespace: tenant-acme
spec:
  limits:
    - type: Container
      default:
        cpu: "200m"
        memory: 256Mi
      defaultRequest:
        cpu: "100m"
        memory: 128Mi
      max:
        cpu: "2"
        memory: 4Gi
      min:
        cpu: "50m"
        memory: 64Mi
---
# 4. ServiceAccount — scoped identity for tenant workloads
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tenant-acme-app
  namespace: tenant-acme
automountServiceAccountToken: false
---
# 5. Role — least privilege for the tenant's operators
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: tenant-acme-operator
  namespace: tenant-acme
rules:
  # Can manage their own workloads
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  # Can read pods and logs
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]
  # Can manage their own ConfigMaps and Secrets
  - apiGroups: [""]
    resources: ["configmaps", "secrets"]
    verbs: ["get", "list", "create", "update", "patch", "delete"]
  # Can manage Services
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
# 6. RoleBinding — bind the role to a tenant group
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tenant-acme-operator-binding
  namespace: tenant-acme
subjects:
  - kind: Group
    name: tenant-acme-operators   # Maps to your OIDC group or certificate CN
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: tenant-acme-operator
  apiGroup: rbac.authorization.k8s.io
---
# 7. NetworkPolicy: default deny all ingress and egress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: tenant-acme
spec:
  podSelector: {}       # Applies to all pods in the namespace
  policyTypes:
    - Ingress
    - Egress
---
# 8. NetworkPolicy: allow DNS egress (required for all pods)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-egress
  namespace: tenant-acme
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
---
# 9. NetworkPolicy: allow intra-namespace pod communication
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
  namespace: tenant-acme
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector: {}   # Any pod in the same namespace
  egress:
    - to:
        - podSelector: {}   # Any pod in the same namespace
---
# 10. NetworkPolicy: allow ingress from the ingress controller namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-controller
  namespace: tenant-acme
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: ingress-nginx
```

---

## Step-by-Step

```bash
# 1. Apply all resources
kubectl apply -f tenant-acme-namespace.yaml

# 2. Verify quota is in place
kubectl describe resourcequota tenant-acme-quota -n tenant-acme

# 3. Verify LimitRange is active
kubectl describe limitrange tenant-acme-limits -n tenant-acme

# 4. Verify NetworkPolicies
kubectl get networkpolicy -n tenant-acme

# 5. Test isolation: try to curl a pod in another namespace from inside tenant-acme
# Should time out / be rejected with the default-deny-all policy
kubectl run debug --rm -it --image=busybox -n tenant-acme -- wget -qO- http://other-service.other-namespace.svc.cluster.local
```

---

## Verification Checklist

- [ ] `kubectl auth can-i list secrets -n tenant-acme --as=system:serviceaccount:tenant-acme:tenant-acme-app` returns `no`
- [ ] Pod without `resources:` block is rejected (LimitRange enforces defaults, ResourceQuota blocks pods over limit)
- [ ] Pod with `hostNetwork: true` is rejected (Pod Security Standards `restricted`)
- [ ] Cross-namespace traffic is blocked (NetworkPolicy default-deny-all)
- [ ] DNS resolution works inside the namespace (allow-dns-egress policy)
