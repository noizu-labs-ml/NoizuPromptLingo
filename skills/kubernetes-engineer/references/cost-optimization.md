# Kubernetes Cost Optimization Guide

Systematic approach to reducing cloud infrastructure spend without sacrificing reliability or performance. Organized from foundational visibility through advanced scheduling and idle elimination.

---

## Strategy Priority Matrix

| Strategy | Effort | Savings Potential | Risk | Priority |
|---|---|---|---|---|
| Right-size over-provisioned workloads | Medium | High (20–50%) | Low | 1 |
| Eliminate idle/orphaned resources | Low | Medium (5–15%) | Low | 2 |
| Spot/preemptible nodes for batch | Medium | High (60–80% on batch) | Medium | 3 |
| Node consolidation (Karpenter) | Medium | Medium (15–30%) | Low | 4 |
| ARM/Graviton migration | High | Medium (20–40%) | Medium | 5 |
| Cost visibility + showback | Low | Indirect (enables all others) | None | 0 (prerequisite) |
| KEDA cron scaling + kube-downscaler | Medium | Medium (10–30% in dev) | Low | 6 |
| Bin-packing via scheduling config | Low | Low–Medium (5–15%) | Low | 7 |

---

## 1. Cost Visibility (Do This First)

No optimization without measurement. Before changing anything, establish what you're spending and on what.

### Kubecost / OpenCost

**OpenCost** (CNCF, open source) and **Kubecost** (commercial, built on OpenCost) provide per-namespace, per-deployment, per-team cost allocation.

```bash
# Install OpenCost via Helm
helm repo add opencost https://opencost.github.io/opencost-helm-chart
helm install opencost opencost/opencost -n opencost --create-namespace \
  --set opencost.exporter.defaultClusterId=my-cluster

# Port-forward UI
kubectl port-forward -n opencost svc/opencost 9090:9090
```

Key views to establish:
- Cost by namespace (team allocation)
- Cost by label (`team=`, `env=`, `app=`)
- Efficiency score (requested vs. actual usage ratio)
- Idle costs (reserved but unused capacity)

### Cost-Allocation Labels

Labels are the foundation of cost attribution. Without them, OpenCost can only break down costs by namespace.

```yaml
# Apply to all workloads — enforce via Kyverno mutate
labels:
  team: platform          # cost center owner
  env: production         # environment (drives showback split)
  app.kubernetes.io/name: myapp
  cost-center: "1042"     # finance code (optional)
  project: payments       # business unit
```

Enforce label presence at admission:
```yaml
# Kyverno policy: require cost labels on all Deployments
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-cost-labels
spec:
  rules:
  - name: check-team-label
    match:
      resources:
        kinds: [Deployment, StatefulSet, DaemonSet]
    validate:
      message: "Label 'team' is required on all workloads."
      pattern:
        metadata:
          labels:
            team: "?*"
            env: "?*"
```

### Showback Reports

Configure OpenCost to export daily cost CSVs to S3 or GCS for finance reporting:
```bash
# Query OpenCost API for namespace costs
curl "http://localhost:9090/model/allocation?window=7d&aggregate=namespace&accumulate=false" | \
  jq '.data[] | .[] | {namespace: .name, totalCost: .totalCost, cpuCost: .cpuCost, ramCost: .ramCost}'
```

Prometheus recording rule for persistent cost metrics:
```yaml
- record: namespace:cost:rate1h
  expr: sum(container_cpu_usage_seconds_total) by (namespace) * on(namespace) group_left kube_namespace_labels
```

---

## 2. Right-Sizing

The highest ROI optimization. Most clusters run at 20–40% actual CPU utilization against what is requested.

### VPA Recommender (Baseline Data Collection)

Run VPA in recommendation-only mode for 7–14 days before changing anything:

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
  namespace: my-ns
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  updatePolicy:
    updateMode: "Off"   # Observe only — do NOT auto-apply yet
  resourcePolicy:
    containerPolicies:
    - containerName: myapp
      minAllowed:
        cpu: 50m
        memory: 64Mi
      maxAllowed:
        cpu: 4000m
        memory: 4Gi
```

Read recommendations after 7 days:
```bash
kubectl describe vpa myapp-vpa -n my-ns
# Look for:
# Recommendation:
#   Container Recommendations:
#     Container Name: myapp
#       Lower Bound: cpu 50m, memory 128Mi
#       Target:      cpu 200m, memory 256Mi   ← use this as request
#       Upper Bound: cpu 800m, memory 512Mi   ← use this as limit
```

### Goldilocks

Goldilocks provides a dashboard over VPA recommendations for all workloads in a namespace:

```bash
helm repo add fairwinds-stable https://charts.fairwinds.com/stable
helm install goldilocks fairwinds-stable/goldilocks -n goldilocks --create-namespace

# Enable per namespace
kubectl label namespace my-ns goldilocks.fairwinds.com/enabled=true

# Port-forward dashboard
kubectl port-forward -n goldilocks svc/goldilocks-dashboard 8080:80
```

Dashboard shows:
- Current requests vs. VPA target for every container
- Estimated monthly savings from right-sizing
- "Guaranteed" vs. "Burstable" QoS impact of changes

### Applying Right-Sizing Recommendations

1. Export current resources: `kubectl get deploy myapp -o yaml > before.yaml`
2. Apply VPA `target` as new `requests`, VPA `upperBound` as new `limits` (add 20% buffer to upper bound)
3. Deploy to staging, verify metrics for 24h
4. Deploy to production with `maxUnavailable: 1` rolling update
5. Monitor: `kubectl top pods -n my-ns` — verify actual usage matches predictions

### LimitRange Defaults as a Safety Net

Catch new deployments without explicit resources before they over-provision:
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: my-ns
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
      cpu: "4"
      memory: "8Gi"
```

---

## 3. Node Optimization

### Karpenter Consolidation

Karpenter (AWS-native, also supports Azure/GCP via providers) continuously evaluates whether the current node fleet can be consolidated.

```yaml
# NodePool with consolidation enabled
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: default
spec:
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 30s          # How long to wait before consolidating
    budgets:
    - nodes: "20%"                 # Max nodes to disrupt at once
  template:
    spec:
      nodeClassRef:
        name: default
      requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values: ["spot", "on-demand"]
      - key: kubernetes.io/arch
        operator: In
        values: ["amd64", "arm64"]
```

Monitor consolidation activity:
```bash
kubectl get events -n karpenter --field-selector reason=Consolidated
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter | grep consolidat
```

Key consolidation behaviors:
- **Empty node consolidation**: terminates nodes with no pods (except DaemonSets)
- **Underutilized consolidation**: bin-packs workloads to fewer nodes if possible
- Respects PodDisruptionBudgets — will not consolidate if it would violate them

### Spot / Preemptible Instances

Spot provides 60–80% discount for interruption-tolerant workloads. The key is matching workload characteristics to instance type.

**Spot-suitable workloads:**
- Batch processing jobs
- CI/CD runner pods
- Dev/staging environments
- Stateless microservices with >2 replicas and PDB

**Spot-unsuitable:**
- Stateful databases (unless using StatefulSet with fast reattach)
- Single-replica critical services
- Long-running ML training without checkpointing

Configure Karpenter to prefer spot with on-demand fallback:
```yaml
spec:
  template:
    spec:
      requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values: ["spot", "on-demand"]
  # Karpenter uses price + availability to select spot first
```

For managed node groups, use mixed instance policy:
```yaml
# Terraform example for EKS managed node group
managed_node_groups = {
  batch = {
    instance_types = ["m5.xlarge", "m5a.xlarge", "m4.xlarge", "m5d.xlarge"]
    capacity_type  = "SPOT"
    min_size       = 0
    max_size       = 50
    desired_size   = 0
  }
}
```

Handle spot interruption gracefully:
- Enable AWS Node Termination Handler (NTH) for 2-minute interruption notices
- Configure `terminationGracePeriodSeconds: 90` on spot-hosted pods
- Ensure workloads checkpoint state or are truly stateless

### ARM / Graviton Migration

AWS Graviton3 (arm64) offers 20–40% better price-performance than equivalent x86. GCP Tau T2A similar.

```bash
# Check which workloads can run on arm64 (multi-arch images)
kubectl get pods -A -o json | jq -r '
  .items[] | .spec.containers[].image
' | sort -u | while read img; do
  # Check manifest list for arm64 platform
  docker manifest inspect "$img" 2>/dev/null | jq -r \
    '.manifests[]? | select(.platform.architecture == "arm64") | "'$img': arm64 supported"'
done
```

Migration path:
1. Ensure base images are multi-arch (most official images on Docker Hub are)
2. Update CI to build for `linux/amd64,linux/arm64` via `docker buildx`
3. Add arm64 node pool with taint for gradual migration:
   ```yaml
   taints:
   - key: arch
     value: arm64
     effect: PreferNoSchedule  # Prefer, not require — allows gradual migration
   ```
4. Remove taint after validating workload performance
5. Switch main node pool to Graviton

---

## 4. Scheduling Optimization

### Priority Classes for Cost-Aware Scheduling

Priority classes determine eviction order and scheduling priority. Use them to protect critical workloads and make batch workloads preemptible:

```yaml
# High priority — production critical
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: production-critical
value: 1000
preemptionPolicy: PreemptLowerPriority
globalDefault: false
description: "Production critical services. Never preempted."

---
# Low priority — batch and dev workloads
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: batch-low
value: 100
preemptionPolicy: Never
globalDefault: false
description: "Batch workloads. Preempted by production traffic."
```

Assign in pod specs:
```yaml
spec:
  priorityClassName: batch-low
```

### Bin-Packing via Scheduler Profile

Default scheduler uses `LeastAllocated` (spread). Switch to `MostAllocated` for dev clusters to pack nodes tighter before new nodes are provisioned:

```yaml
# kube-scheduler configuration
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: bin-packing-scheduler
  pluginConfig:
  - name: NodeResourcesFit
    args:
      scoringStrategy:
        type: MostAllocated
        resources:
        - name: cpu
          weight: 1
        - name: memory
          weight: 1
```

Note: Apply bin-packing only to dev/batch node pools. Production should use spread for HA.

### ResourceQuotas to Prevent Over-Provisioning

Enforce per-team/namespace ceilings:
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-quota
  namespace: team-a
spec:
  hard:
    requests.cpu: "16"
    requests.memory: 32Gi
    limits.cpu: "48"
    limits.memory: 96Gi
    count/deployments.apps: "20"
    count/services: "20"
    persistentvolumeclaims: "10"
    requests.storage: 500Gi
```

Alert when approaching limits (Prometheus):
```yaml
- alert: NamespaceQuotaExceeded80Percent
  expr: |
    kube_resourcequota{type="used"} /
    kube_resourcequota{type="hard"} > 0.8
  for: 5m
  labels:
    severity: warning
```

---

## 5. Idle Detection and Scale-to-Zero

### kube-downscaler (Dev/Staging)

Automatically scales down non-production workloads outside business hours:

```bash
helm repo add codeberg https://codeberg.org/hjacobs/charts
helm install kube-downscaler codeberg/kube-downscaler -n kube-downscaler --create-namespace \
  --set args={"--interval=30","--default-uptime=Mon-Fri 08:00-19:00 Europe/Berlin","--default-downtime=never"}
```

Annotate namespaces or deployments for controlled downscaling:
```yaml
# Namespace-level: scale everything in staging down overnight
metadata:
  annotations:
    downscaler/uptime: "Mon-Fri 08:00-18:00 America/New_York"
    downscaler/downtime-replicas: "0"

# Exclude specific deployments from downscaling
metadata:
  annotations:
    downscaler/exclude: "true"
```

Expected savings: 50–65% on dev/staging compute for teams working standard hours.

### KEDA Cron Scaling

For workloads with predictable traffic patterns, KEDA ScaledObject with cron trigger scales to zero outside peak hours:

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: myapp-cron-scaler
spec:
  scaleTargetRef:
    name: myapp
  minReplicaCount: 0
  maxReplicaCount: 10
  triggers:
  - type: cron
    metadata:
      timezone: America/New_York
      start: "0 8 * * 1-5"    # Scale up Mon-Fri 8am
      end: "0 20 * * 1-5"     # Scale down Mon-Fri 8pm
      desiredReplicas: "3"
  - type: prometheus             # Also scale on load during peak hours
    metadata:
      serverAddress: http://prometheus:9090
      metricName: http_requests_per_second
      threshold: "100"
      query: sum(rate(http_requests_total[2m]))
```

KEDA handles the `minReplicaCount: 0` case by managing HPA — native HPA cannot scale to zero.

### Orphan Cleanup Automation

Schedule regular audits as a CronJob:
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: orphan-audit
  namespace: platform
spec:
  schedule: "0 9 * * 1"  # Weekly Monday 9am
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: orphan-auditor
          containers:
          - name: audit
            image: bitnami/kubectl:latest
            command:
            - /bin/sh
            - -c
            - |
              echo "=== Unbound PVCs ==="
              kubectl get pvc -A --field-selector status.phase=Pending
              echo "=== LoadBalancer services ==="
              kubectl get svc -A --field-selector spec.type=LoadBalancer
              echo "=== Completed jobs older than 7d ==="
              kubectl get jobs -A -o json | jq -r '
                .items[] |
                select(.status.completionTime != null) |
                select(
                  (now - (.status.completionTime | fromdateiso8601)) > 604800
                ) |
                [.metadata.namespace, .metadata.name] | join("\t")
              '
```

---

## 6. Workload-Specific Patterns

### Batch Jobs

- Use `ttlSecondsAfterFinished` on Jobs to auto-delete completed pods:
  ```yaml
  spec:
    ttlSecondsAfterFinished: 3600  # Delete 1h after completion
  ```
- Set `activeDeadlineSeconds` to prevent runaway jobs accumulating costs
- Use spot instances for all batch workloads
- Set `priorityClassName: batch-low` so batch pods are preempted when spot capacity is reclaimed

### Databases

- PostgreSQL on K8s: right-size connection pooling (PgBouncer) to reduce compute needed per connection
- Use `StorageClass` with `WaitForFirstConsumer` — prevents over-provisioning PVs in wrong zones
- Enable storage auto-resize (EBS GP3 supports this via the CSI driver) to avoid pre-allocating oversized volumes

### Machine Learning

- Use node selectors to restrict GPU pods to GPU nodes; all other pods must tolerate `NoSchedule` taint on GPU nodes
- Enable NVIDIA MIG (Multi-Instance GPU) for workloads that don't need a full GPU
- Use KEDA with custom metrics (queue depth) to scale ML inference pods to zero between jobs

---

## 7. Monitoring Cost Efficiency

### Prometheus Metrics

Key metrics to alert on:

```yaml
# CPU request efficiency (lower = over-provisioned)
- record: workload:cpu_efficiency:ratio
  expr: |
    sum(rate(container_cpu_usage_seconds_total[5m])) by (namespace, pod)
    /
    sum(kube_pod_container_resource_requests{resource="cpu"}) by (namespace, pod)

# Memory efficiency
- record: workload:memory_efficiency:ratio
  expr: |
    sum(container_memory_working_set_bytes) by (namespace, pod)
    /
    sum(kube_pod_container_resource_requests{resource="memory"}) by (namespace, pod)

# Alert: workload using <20% of requested CPU for 24h
- alert: WorkloadCPUOverProvisioned
  expr: workload:cpu_efficiency:ratio < 0.2
  for: 24h
  labels:
    severity: info
  annotations:
    summary: "{{ $labels.namespace }}/{{ $labels.pod }} using {{ $value | humanizePercentage }} of requested CPU"
```

### Cost Dashboards

Build Grafana dashboards with these panels:
1. **Daily cluster cost** — total spend trending
2. **Cost by namespace** — team chargeback
3. **Efficiency heatmap** — CPU and memory utilization ratio by workload
4. **Idle cost** — resources reserved but unused (OpenCost idle metric)
5. **Spot vs on-demand ratio** — spot adoption progress
6. **Storage cost** — PV size vs. actual usage

---

## 8. Quick Wins Checklist

Execute these in order — each can be done in a day or less:

- [ ] Install OpenCost and establish baseline cost by namespace
- [ ] Apply cost-allocation labels to all workloads (enforce via Kyverno)
- [ ] Enable kube-downscaler on all dev/staging namespaces
- [ ] Delete orphaned PVCs and LoadBalancer services
- [ ] Set `ttlSecondsAfterFinished` on all completed Jobs
- [ ] Enable VPA in `Off` mode on top 10 largest deployments
- [ ] After 7 days, apply VPA recommendations to right-size
- [ ] Move batch/CI workloads to spot node groups
- [ ] Enable Karpenter consolidation on idle node pools
- [ ] Add LimitRange defaults to namespaces without explicit resource specs
- [ ] Set `automountServiceAccountToken: false` where unused (reduces etcd overhead)
- [ ] Audit images for arm64 support; migrate eligible workloads to Graviton
