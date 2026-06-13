# GitOps Reference Guide

A comprehensive reference for GitOps patterns, ArgoCD, progressive delivery, and secrets management in Kubernetes environments.

---

## Table of Contents

1. [GitOps Principles](#gitops-principles)
2. [ArgoCD Architecture](#argocd-architecture)
3. [Application CRD](#application-crd)
4. [App-of-Apps Pattern](#app-of-apps-pattern)
5. [ApplicationSets](#applicationsets)
6. [Sync Policies](#sync-policies)
7. [Repository Structure](#repository-structure)
8. [Progressive Delivery](#progressive-delivery)
9. [Flux Comparison](#flux-comparison)
10. [Secrets in GitOps](#secrets-in-gitops)
11. [Common Pitfalls](#common-pitfalls)

---

## GitOps Principles

GitOps is an operational framework that applies DevOps best practices — version control, collaboration, compliance, CI/CD — to infrastructure automation.

### The Four Core Principles

**1. Declarative**
The entire system is described declaratively. Infrastructure state is expressed as desired configuration, not imperative scripts. Kubernetes manifests, Helm values, and Kustomize overlays are all declarative artifacts.

**2. Versioned and Immutable**
Desired state is stored in Git. Git's immutable history provides auditability, rollback capability, and the ability to understand exactly what changed and when. Git is the single source of truth — not the cluster, not a CI system.

**3. Pulled Automatically**
Software agents (ArgoCD, Flux) continuously pull the desired state from Git and apply it to the cluster. The cluster is never "pushed to" — the agent reconciles from Git. This eliminates the need for CI systems to have cluster credentials.

**4. Continuously Reconciled**
Software agents continuously observe actual system state and attempt to converge toward desired state. Drift — whether from manual `kubectl` edits or cluster events — is detected and corrected automatically.

### Why GitOps

- **Auditability**: Every change has a Git author, timestamp, and diff
- **Rollback**: `git revert` is an operational tool
- **Disaster recovery**: Re-apply Git state to a new cluster
- **No push credentials**: CI systems only need Git access, not cluster access
- **Consistent review workflow**: PRs gate production changes

---

## ArgoCD Architecture

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes.

### Components

| Component | Role |
|-----------|------|
| `argocd-server` | API server and Web UI — handles user/CLI requests |
| `argocd-application-controller` | Reconciles cluster state vs Git; manages sync operations |
| `argocd-repo-server` | Clones repos, generates manifests (Helm, Kustomize, raw YAML) |
| `argocd-dex-server` | SSO integration (OIDC, SAML, LDAP) |
| `argocd-redis` | Caches repo data and application state |

### Reconciliation Loop

```
Git Repo → argocd-repo-server (clone + render) → argocd-application-controller (diff) → kubectl apply → Cluster
                                                         ↑
                                          Continuous watch (every 3 min default)
```

The application controller watches both Git (via repo-server polling) and the live cluster (via informers) and computes the diff between desired and actual state.

---

## Application CRD

The `Application` CRD is the core ArgoCD primitive. It declares: where to get source manifests, where to deploy them, and how to sync.

### Minimal Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/my-org/my-config
    targetRevision: main
    path: apps/my-app/overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: my-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Helm Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: prometheus
  namespace: argocd
spec:
  project: monitoring
  source:
    repoURL: https://prometheus-community.github.io/helm-charts
    chart: kube-prometheus-stack
    targetRevision: 55.5.0
    helm:
      releaseName: prometheus
      valueFiles:
        - values.yaml
      values: |
        grafana:
          adminPassword: $grafana-admin-password
  destination:
    server: https://kubernetes.default.svc
    namespace: monitoring
  syncPolicy:
    automated:
      prune: false      # Careful with prune on monitoring
      selfHeal: true
```

### Multi-Source Application (ArgoCD 2.6+)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app-with-values
  namespace: argocd
spec:
  project: default
  sources:
    - repoURL: https://charts.bitnami.com/bitnami
      chart: postgresql
      targetRevision: 13.2.0
      helm:
        valueFiles:
          - $values/clusters/prod/postgresql/values.yaml
    - repoURL: https://github.com/my-org/my-config
      targetRevision: main
      ref: values
  destination:
    server: https://kubernetes.default.svc
    namespace: databases
```

---

## App-of-Apps Pattern

The app-of-apps pattern uses a root ArgoCD Application that manages other Applications. This enables bootstrapping an entire cluster from a single `kubectl apply`.

### Root Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.io
spec:
  project: default
  source:
    repoURL: https://github.com/my-org/cluster-config
    targetRevision: main
    path: clusters/production/apps
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Child Applications Directory (`clusters/production/apps/`)

```
clusters/production/apps/
├── monitoring.yaml          # Application → monitoring stack
├── ingress-nginx.yaml       # Application → ingress controller
├── cert-manager.yaml        # Application → cert-manager
├── external-secrets.yaml    # Application → external-secrets-operator
└── my-services.yaml         # Application → business services
```

Each file is an ArgoCD `Application` manifest pointing to a specific path in the config repo.

### Bootstrap Sequence

```
kubectl apply -f clusters/production/bootstrap/root.yaml
         ↓
ArgoCD syncs root application
         ↓
Root creates child Applications (monitoring, ingress, etc.)
         ↓
Each child Application syncs its own resources
         ↓
Cluster reaches desired state
```

---

## ApplicationSets

`ApplicationSet` is a controller that generates `Application` resources from templates and generators. It replaces the need to manually write repetitive Application manifests for multi-cluster or multi-environment scenarios.

### Git Directory Generator

Generates one Application per directory matching a glob pattern.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: cluster-addons
  namespace: argocd
spec:
  generators:
    - git:
        repoURL: https://github.com/my-org/cluster-config
        revision: main
        directories:
          - path: addons/*
  template:
    metadata:
      name: '{{path.basename}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/my-org/cluster-config
        targetRevision: main
        path: '{{path}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{path.basename}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
```

### Cluster Generator

Generates one Application per registered ArgoCD cluster.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: guestbook
  namespace: argocd
spec:
  generators:
    - clusters:
        selector:
          matchLabels:
            environment: production
  template:
    metadata:
      name: '{{name}}-guestbook'
    spec:
      project: default
      source:
        repoURL: https://github.com/my-org/apps
        targetRevision: main
        path: guestbook
      destination:
        server: '{{server}}'
        namespace: guestbook
```

### Matrix Generator

Combines two generators — every combination produces an Application.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: matrix-example
  namespace: argocd
spec:
  generators:
    - matrix:
        generators:
          - clusters:
              selector:
                matchLabels:
                  environment: staging
          - git:
              repoURL: https://github.com/my-org/apps
              revision: main
              directories:
                - path: services/*
  template:
    metadata:
      name: '{{name}}-{{path.basename}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/my-org/apps
        targetRevision: main
        path: '{{path}}/overlays/staging'
      destination:
        server: '{{server}}'
        namespace: '{{path.basename}}'
```

---

## Sync Policies

### Auto-Sync

```yaml
syncPolicy:
  automated:
    prune: true       # Delete resources removed from Git
    selfHeal: true    # Revert manual kubectl changes
    allowEmpty: false # Prevent syncing to empty state (safety)
```

- `prune: false` is the safe default — resources added manually or by other tools won't be deleted
- `selfHeal: true` triggers a sync when live state diverges from desired state (within ~5s)
- Disable `selfHeal` for stateful apps where operators may legitimately mutate state

### Sync Options

```yaml
syncPolicy:
  syncOptions:
    - CreateNamespace=true          # Create destination namespace if missing
    - PrunePropagationPolicy=foreground  # Wait for dependents before pruning
    - PruneLast=true                # Prune after all other resources sync
    - Replace=true                  # Use kubectl replace instead of apply (for CRDs)
    - ServerSideApply=true          # Use server-side apply (resolves field ownership conflicts)
    - SkipDryRunOnMissingResource=true  # Skip dry-run for CRDs not yet installed
    - ApplyOutOfSyncOnly=true       # Only apply resources that are out of sync
```

### Sync Windows

Sync windows restrict when automated syncs can occur — useful for change freezes and maintenance windows.

```yaml
# In AppProject CRD
spec:
  syncWindows:
    - kind: allow
      schedule: '10 1 * * *'    # Daily at 01:10 UTC
      duration: 1h
      applications:
        - '*'
      namespaces:
        - '*'
      clusters:
        - '*'
    - kind: deny
      schedule: '0 22 * * 5'   # Friday at 22:00 UTC
      duration: 60h             # All weekend
      manualSync: true          # Also block manual syncs
```

### Resource Hooks

Hooks run jobs at specific points in the sync lifecycle.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migrate
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
        - name: migrate
          image: my-app:v2.3.0
          command: ["./bin/migrate"]
      restartPolicy: Never
```

| Hook | Timing |
|------|--------|
| `PreSync` | Before applying manifests |
| `Sync` | During apply (alongside resources) |
| `PostSync` | After all resources are healthy |
| `SyncFail` | If sync fails |
| `Skip` | Never apply this resource |

---

## Repository Structure

### Config Separate from Source

**Do not store Kubernetes manifests in the same repo as application source code.** Keep them separate:

```
my-org/
├── my-app/                    # Application source
│   ├── src/
│   ├── Dockerfile
│   └── .github/workflows/     # CI: builds image, PRs to config repo
└── cluster-config/            # GitOps config repo
    ├── apps/
    │   └── my-app/
    │       ├── base/           # Kustomize base
    │       └── overlays/
    │           ├── staging/
    │           └── production/
    └── clusters/
        ├── staging/
        └── production/
```

CI pipeline: build image → push to registry → update image tag in config repo → PR → merge → ArgoCD syncs.

### Mono-Repo vs Multi-Repo

**Mono-repo** (single config repo for all apps):
- Simpler access control setup
- Easier cross-app dependency visibility
- Can become a bottleneck with many teams
- All teams need write access or rigid CODEOWNERS setup

**Multi-repo** (one config repo per app or team):
- Natural team ownership boundaries
- ArgoCD ApplicationSet with cluster generator spans repos
- More complex ArgoCD repo registration
- Better for large organizations with distinct team ownership

### Directory-Per-Environment Pattern

```
cluster-config/
├── base/                       # Shared base manifests
│   └── my-app/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── kustomization.yaml
└── overlays/
    ├── development/
    │   └── my-app/
    │       ├── kustomization.yaml  # patches, image overrides
    │       └── replica-patch.yaml
    ├── staging/
    │   └── my-app/
    └── production/
        └── my-app/
            └── hpa-patch.yaml      # production-only HPA
```

---

## Progressive Delivery

Progressive delivery extends GitOps with controlled rollout strategies — canary, blue-green, A/B — with automated analysis and promotion/rollback gates.

### Argo Rollouts

Argo Rollouts is a Kubernetes controller that provides advanced deployment strategies as a drop-in replacement for `Deployment`.

#### Canary Rollout

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: my-app
spec:
  replicas: 10
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: my-app:v2.0.0
          ports:
            - containerPort: 8080
  strategy:
    canary:
      maxSurge: 2
      maxUnavailable: 0
      steps:
        - setWeight: 10          # Route 10% traffic to canary
        - pause: {duration: 5m}  # Wait 5 minutes
        - analysis:              # Run analysis
            templates:
              - templateName: success-rate
        - setWeight: 25
        - pause: {duration: 10m}
        - analysis:
            templates:
              - templateName: success-rate
              - templateName: latency-p99
        - setWeight: 50
        - pause: {duration: 10m}
        - setWeight: 100         # Full rollout
      canaryService: my-app-canary
      stableService: my-app-stable
      trafficRouting:
        nginx:
          stableIngress: my-app-ingress
```

#### Blue-Green Rollout

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: my-app-bg
spec:
  replicas: 5
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: my-app:v2.0.0
  strategy:
    blueGreen:
      activeService: my-app-active        # Production traffic
      previewService: my-app-preview      # Preview (blue) traffic
      autoPromotionEnabled: false         # Manual promotion required
      prePromotionAnalysis:
        templates:
          - templateName: smoke-test
      postPromotionAnalysis:
        templates:
          - templateName: success-rate
      scaleDownDelaySeconds: 300          # Keep old version for 5 minutes post-cutover
```

### Analysis Templates

Analysis Templates define how to query metrics for automated promotion/rollback decisions.

#### Prometheus Analysis Template

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  args:
    - name: service-name
  metrics:
    - name: success-rate
      interval: 2m
      count: 5                   # Run 5 measurements
      successCondition: result[0] >= 0.95   # 95%+ success rate
      failureLimit: 2            # Fail after 2 failed measurements
      provider:
        prometheus:
          address: http://prometheus.monitoring.svc:9090
          query: |
            sum(rate(http_requests_total{service="{{args.service-name}}",status!~"5.."}[5m]))
            /
            sum(rate(http_requests_total{service="{{args.service-name}}"}[5m]))

---
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: latency-p99
spec:
  metrics:
    - name: p99-latency
      interval: 2m
      count: 5
      successCondition: result[0] <= 0.5   # Under 500ms
      failureLimit: 1
      provider:
        prometheus:
          address: http://prometheus.monitoring.svc:9090
          query: |
            histogram_quantile(0.99,
              sum(rate(http_request_duration_seconds_bucket{service="my-app"}[5m])) by (le)
            )
```

---

## Flux Comparison

Flux v2 is an alternative GitOps toolkit. Both ArgoCD and Flux are CNCF graduated projects.

### Flux Core CRDs

**GitRepository** — defines a Git source to watch:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: cluster-config
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/my-org/cluster-config
  ref:
    branch: main
  secretRef:
    name: github-credentials
```

**Kustomization** — applies manifests from a GitRepository source:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: my-app
  namespace: flux-system
spec:
  interval: 10m
  path: ./apps/my-app/overlays/production
  prune: true
  sourceRef:
    kind: GitRepository
    name: cluster-config
  healthChecks:
    - apiVersion: apps/v1
      kind: Deployment
      name: my-app
      namespace: my-app
  timeout: 5m
```

**HelmRelease** — manages a Helm release from a chart source:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta2
kind: HelmRelease
metadata:
  name: prometheus
  namespace: monitoring
spec:
  interval: 15m
  chart:
    spec:
      chart: kube-prometheus-stack
      version: '55.x'
      sourceRef:
        kind: HelmRepository
        name: prometheus-community
        namespace: flux-system
  values:
    grafana:
      enabled: true
  upgrade:
    remediation:
      retries: 3
  rollback:
    cleanupOnFail: true
```

### When Flux Fits Better

| Scenario | Prefer |
|----------|--------|
| No UI needed, CLI/GitOps-pure workflow | Flux |
| Helm-first workflow (many HelmReleases) | Flux |
| OCI artifact sources (not just Git) | Flux |
| Image automation (auto-update image tags in Git) | Flux |
| Multi-tenancy with namespace isolation | Flux |
| Rich UI, RBAC, SSO, multi-cluster dashboard | ArgoCD |
| App-of-apps / ApplicationSet patterns | ArgoCD |
| Progressive delivery (Argo Rollouts integration) | ArgoCD |
| Notification webhooks, Slack integration | ArgoCD |

The tools are composable — some teams run Flux for cluster infrastructure and ArgoCD for application delivery.

---

## Secrets in GitOps

Never commit plaintext secrets to Git. Three main approaches:

### External Secrets Operator (ESO)

ESO syncs secrets from external stores (Vault, AWS Secrets Manager, GCP Secret Manager, Infisical) into Kubernetes Secrets.

```yaml
# ExternalSecret — fetches from external store into K8s Secret
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: my-app-secrets
  namespace: my-app
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  target:
    name: my-app-secrets        # K8s Secret to create
    creationPolicy: Owner
  data:
    - secretKey: database-url   # Key in K8s Secret
      remoteRef:
        key: my-app/production  # Path in Vault
        property: database_url  # Field in Vault secret

---
# ClusterSecretStore — defines connection to external store
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: https://vault.internal:8200
      path: secret
      version: v2
      auth:
        kubernetes:
          mountPath: kubernetes
          role: external-secrets
```

**This is the recommended approach for production.** ESO works well with GitOps: the `ExternalSecret` CRD is committed to Git (no secrets), and ESO fetches the actual secret values at runtime.

### Sealed Secrets

Sealed Secrets encrypts secrets with a cluster-specific public key. The encrypted `SealedSecret` is safe to commit to Git; the controller decrypts it in-cluster.

```bash
# Encrypt a secret
kubectl create secret generic my-secret --from-literal=key=value \
  --dry-run=client -o yaml | \
  kubeseal --controller-namespace kube-system \
            --controller-name sealed-secrets \
            --format yaml > my-sealed-secret.yaml

# Commit my-sealed-secret.yaml to Git — it's encrypted
```

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: my-secret
  namespace: my-app
spec:
  encryptedData:
    key: AgB3X...  # Encrypted value — safe to commit
  template:
    metadata:
      name: my-secret
      namespace: my-app
```

**Downside**: Sealed by cluster. Rotating the controller key requires re-encrypting all secrets.

### SOPS (Secrets OPerationS)

SOPS encrypts specific values in YAML/JSON files using KMS (AWS, GCP, Azure) or age/PGP keys. Works with Flux natively; ArgoCD requires the `argocd-lovely-plugin` or a custom init container.

```yaml
# my-secret.enc.yaml — encrypted, safe to commit
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
stringData:
  database-url: ENC[AES256_GCM,data:abc123...,tag:xyz...]
sops:
  kms:
    - arn: arn:aws:kms:us-east-1:123456789:key/my-key
  age:
    - recipient: age1...
  lastmodified: "2024-01-15T10:00:00Z"
  version: 3.8.1
```

---

## Common Pitfalls

### 1. Auto-Sync + Prune in Production Without Review

**Problem**: `automated.prune: true` with `selfHeal: true` in production means a bad commit that removes a resource will immediately delete it in production — no human gate.

**Fix**: Use sync windows to restrict automated syncs in production. Require manual sync promotion or PR approval gates. Consider `prune: false` in production and handle pruning manually.

### 2. Mixing `kubectl` with ArgoCD

**Problem**: Running `kubectl apply` or `kubectl edit` on ArgoCD-managed resources causes drift. With `selfHeal: true`, ArgoCD will revert your changes within seconds.

**Fix**: All changes go through Git. Use `kubectl patch` only for emergencies, then immediately update Git to match. Consider using ArgoCD's `ignoreDifferences` for fields that legitimately drift (e.g., HPA `replicas`):

```yaml
spec:
  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers:
        - /spec/replicas    # Managed by HPA — ignore drift
```

### 3. No Health Checks on Custom Resources

**Problem**: ArgoCD marks a sync as complete when resources are applied, but doesn't know if your `CustomResource` is actually healthy. This causes PostSync hooks to run against a broken system.

**Fix**: Register custom health checks in ArgoCD's ConfigMap:

```yaml
# argocd-cm ConfigMap
data:
  resource.customizations.health.my.io_MyResource: |
    hs = {}
    if obj.status ~= nil then
      if obj.status.phase == "Ready" then
        hs.status = "Healthy"
        hs.message = obj.status.message
        return hs
      end
    end
    hs.status = "Progressing"
    hs.message = "Waiting for resource to be ready"
    return hs
```

### 4. Storing Config and Source in the Same Repo

**Problem**: Application code changes trigger GitOps syncs. Image tag updates from CI become noisy commits mixed with code changes. Hard to apply different access policies to code vs config.

**Fix**: Separate repos. CI updates config repo via PR or direct commit to an image-tag file. Config repo changes trigger ArgoCD syncs.

### 5. Not Pinning Chart Versions

**Problem**: Using `targetRevision: '*'` or `latest` for Helm charts means an upstream release can break your cluster without a Git change.

**Fix**: Always pin to a specific chart version. Use Renovate or Dependabot to automate version bump PRs — you get auditability and control without manual tracking.

### 6. Large App-of-Apps Without Project RBAC

**Problem**: A single `default` AppProject with no restrictions means any team's Application can deploy to any namespace on any cluster. One bad actor (or bad PR) can affect the entire cluster.

**Fix**: Use AppProjects to scope team access:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-payments
  namespace: argocd
spec:
  sourceRepos:
    - https://github.com/my-org/payments-config
  destinations:
    - namespace: payments-*
      server: https://kubernetes.default.svc
  clusterResourceWhitelist: []  # No cluster-scoped resources
  namespaceResourceBlacklist:
    - group: ''
      kind: ResourceQuota       # Teams can't modify their own quotas
```

### 7. Missing Finalizers on Applications

**Problem**: Deleting an ArgoCD Application without the finalizer orphans the deployed resources in the cluster.

**Fix**: Include the cascade finalizer when you want delete-to-cascade behavior:

```yaml
metadata:
  finalizers:
    - resources-finalizer.argocd.io
```

Remove the finalizer first if you want to delete the Application without affecting live resources.
