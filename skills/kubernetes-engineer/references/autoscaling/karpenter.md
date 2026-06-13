# Karpenter — Just-in-Time Node Provisioning

## What Karpenter Does

Karpenter is a Kubernetes node autoscaler that provisions and deprovisions EC2 instances directly, bypassing the legacy node group / Auto Scaling Group (ASG) model. It watches for unschedulable pods and launches the right instance type within seconds — not minutes.

**Core capabilities:**

| Capability | Description |
|---|---|
| Just-in-time provisioning | Watches pending pods, selects optimal instance, launches it |
| Bin-packing | Chooses smallest instance that satisfies all pending pod requests |
| Consolidation | Replaces underutilized nodes with fewer, smaller ones |
| Spot-first | Can preference spot instances and fall back to on-demand automatically |
| Drift detection | Replaces nodes whose NodePool/EC2NodeClass has changed |
| Expiry / TTL | Rotates nodes on a schedule for AMI freshness and security patching |

**Why it beats cluster-autoscaler:**

- No node group pre-configuration — instance types are selected at scheduling time
- Consolidation is active (not just scale-down-to-zero); it replaces partially used nodes
- Launches in ~30–60s vs cluster-autoscaler's 2–4 minutes
- Handles heterogeneous instance families without separate node groups per family

---

## NodePool Configuration

A `NodePool` defines the constraints and behavior for a class of nodes Karpenter may provision. You can have multiple NodePools to segment workloads.

### Minimal NodePool

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: default
spec:
  template:
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default
      requirements:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot", "on-demand"]
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["c", "m", "r"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["2"]
  disruption:
    consolidationPolicy: WhenUnderutilized
    consolidateAfter: 1m
  limits:
    cpu: "1000"
    memory: 4000Gi
```

### Workload Segmentation via Multiple NodePools

**Spot NodePool for stateless workloads:**

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: spot-compute
spec:
  weight: 50
  template:
    metadata:
      labels:
        node-pool: spot-compute
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default
      taints:
        - key: spot
          value: "true"
          effect: NoSchedule
      requirements:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["c", "m"]
        - key: karpenter.k8s.aws/instance-size
          operator: NotIn
          values: ["nano", "micro", "small"]
  disruption:
    consolidationPolicy: WhenUnderutilized
    consolidateAfter: 30s
  limits:
    cpu: "500"
```

**On-demand NodePool for stateful / critical workloads:**

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: on-demand-stable
spec:
  weight: 10
  template:
    metadata:
      labels:
        node-pool: on-demand-stable
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default
      requirements:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["m", "r"]
  disruption:
    consolidationPolicy: WhenEmpty
    consolidateAfter: 5m
    budgets:
      - nodes: "10%"
  limits:
    cpu: "200"
    memory: 800Gi
```

### Weight

`spec.weight` (1–100) controls NodePool priority. Higher weight = preferred. Karpenter selects the lowest-cost option across all eligible NodePools; weight breaks ties. Use this to preference spot over on-demand.

### Limits

`spec.limits` caps total resources a NodePool may provision. Once hit, Karpenter will not launch more nodes from that pool. This prevents runaway scaling and cost overruns.

---

## EC2NodeClass Configuration

`EC2NodeClass` is the AWS-specific complement to `NodePool`. It defines the infrastructure layer: AMIs, networking, storage, IAM, and bootstrap config.

```yaml
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: default
spec:
  # AMI selection — use alias for managed, auto-updated AMIs
  amiSelectorTerms:
    - alias: al2023@latest          # Amazon Linux 2023 (recommended)
    # Alternative: pin a specific AMI family
    # - alias: bottlerocket@latest
    # Alternative: select by tag
    # - tags:
    #     karpenter.sh/discovery: my-cluster

  # IAM role for the node instance profile
  role: KarpenterNodeRole-my-cluster

  # Subnet selection — nodes land in subnets matching these tags
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: my-cluster

  # Security group selection
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: my-cluster

  # Block device (EBS root volume) configuration
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 50Gi
        volumeType: gp3
        iops: 3000
        throughput: 125
        encrypted: true
        deleteOnTermination: true

  # User data injected into the instance at launch (AL2023 NodeConfig format)
  userData: |
    apiVersion: node.eks.aws/v1alpha1
    kind: NodeConfig
    spec:
      kubelet:
        config:
          maxPods: 110
          systemReserved:
            cpu: 100m
            memory: 100Mi
          kubeReserved:
            cpu: 200m
            memory: 200Mi
          evictionHard:
            memory.available: 5%
            nodefs.available: 10%

  # Tags applied to all provisioned EC2 instances
  tags:
    Environment: production
    ManagedBy: karpenter

  # Optional: restrict to specific availability zones
  # (usually prefer subnet tags to control AZ placement)
```

### AMI Alias Reference

| Alias | OS | Notes |
|---|---|---|
| `al2023@latest` | Amazon Linux 2023 | AWS recommended default |
| `al2@latest` | Amazon Linux 2 | Legacy; prefer AL2023 |
| `bottlerocket@latest` | Bottlerocket | Minimal, container-optimized |
| `windows-core-2022@latest` | Windows Server 2022 | Windows nodes |

Pin a specific version in production to prevent unexpected AMI rollouts: `al2023@v20240807`.

---

## Consolidation Policies

Consolidation actively replaces underutilized nodes with fewer, cheaper ones. It runs continuously in the background.

### WhenEmpty

Only replaces nodes that have zero workload pods running (daemonsets excluded).

```yaml
disruption:
  consolidationPolicy: WhenEmpty
  consolidateAfter: 30s
```

Use for: stateful workloads, databases, jobs — anything that should not be evicted mid-run.

### WhenUnderutilized

Replaces nodes when moving their pods to other nodes reduces overall cost. This may evict running pods (respecting PDBs and `do-not-disrupt` annotations).

```yaml
disruption:
  consolidationPolicy: WhenUnderutilized
  consolidateAfter: 1m
```

Use for: stateless web services, workers — anything that can tolerate a rolling restart.

### Disruption Budgets

Budgets cap how many nodes Karpenter may disrupt simultaneously. Think of it as a PDB for nodes.

```yaml
disruption:
  consolidationPolicy: WhenUnderutilized
  consolidateAfter: 1m
  budgets:
    # Limit to 10% of nodes at a time normally
    - nodes: "10%"
    # Allow 0 disruptions during business hours (US Eastern)
    - nodes: "0"
      schedule: "0 9 * * 1-5"
      duration: 8h
```

Multiple budgets are evaluated together; the most restrictive applies at any given moment.

### Preventing Disruption on Specific Pods

Annotate pods to opt out of Karpenter-initiated eviction:

```yaml
metadata:
  annotations:
    karpenter.sh/do-not-disrupt: "true"
```

Karpenter will not consolidate a node if any pod on it carries this annotation.

### Node Expiry (TTL)

Force node rotation on a schedule for AMI patching:

```yaml
spec:
  template:
    spec:
      expireAfter: 720h    # Replace nodes after 30 days
```

---

## Spot Strategies

### Instance Diversity

The single most important spot strategy: request many instance types. The more options Karpenter can choose from, the higher your fill rate and the more graceful your interruption handling.

```yaml
requirements:
  - key: karpenter.sh/capacity-type
    operator: In
    values: ["spot"]
  - key: karpenter.k8s.aws/instance-category
    operator: In
    values: ["c", "m", "r"]         # Multiple families
  - key: karpenter.k8s.aws/instance-generation
    operator: Gt
    values: ["3"]                    # Generations 4+
  - key: karpenter.k8s.aws/instance-size
    operator: In
    values: ["large", "xlarge", "2xlarge", "4xlarge"]
```

**Avoid:** pinning a single instance type or family for spot. That defeats the diversification.

### Capacity-Optimized Allocation

AWS EC2 Fleet uses `price-capacity-optimized` by default when Karpenter selects spot. This balances lowest price with highest available capacity, reducing interruption probability. No extra configuration needed — Karpenter uses this strategy automatically.

### Interruption Handling

Enable the Karpenter interruption handler (deployed alongside the controller) to watch for EC2 spot interruption notices and cordon/drain nodes 2 minutes before reclamation:

In the Karpenter Helm values:

```yaml
settings:
  interruptionQueue: karpenter-my-cluster   # SQS queue name
```

The SQS queue must be subscribed to EC2 spot interruption EventBridge events (set up via Terraform or CDK as part of cluster bootstrap).

### On-Demand Fallback via Multiple NodePools

```yaml
# NodePool 1 — prefer spot (weight: 50)
---
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: spot-first
spec:
  weight: 50
  template:
    spec:
      requirements:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]

# NodePool 2 — on-demand fallback (weight: 10)
---
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: on-demand-fallback
spec:
  weight: 10
  template:
    spec:
      requirements:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
```

Karpenter evaluates both NodePools; if spot is unavailable or more expensive than the weight delta implies, on-demand wins the selection.

---

## Migration from cluster-autoscaler

### Concept Mapping

| cluster-autoscaler | Karpenter |
|---|---|
| Node Group / ASG | NodePool |
| Launch Template | EC2NodeClass |
| `min-nodes` / `max-nodes` | `spec.limits` (soft ceiling) |
| Scale-down delay | `consolidateAfter` |
| Priority expander | NodePool `weight` |
| `safe-to-evict` annotation | `karpenter.sh/do-not-disrupt` annotation |
| `--balance-similar-node-groups` | Automatic (bin-packing across pools) |

### Step-by-Step Migration

**Step 1: Install Karpenter alongside cluster-autoscaler (do not remove CA yet)**

```bash
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version "1.0.0" \
  --namespace karpenter \
  --create-namespace \
  --set settings.clusterName=my-cluster \
  --set settings.interruptionQueue=karpenter-my-cluster \
  --set controller.resources.requests.cpu=1 \
  --set controller.resources.requests.memory=1Gi
```

**Step 2: Create NodePool and EC2NodeClass targeting NEW node groups**

Tag new subnets and security groups with `karpenter.sh/discovery: my-cluster` so EC2NodeClass can find them.

**Step 3: Cordon all cluster-autoscaler-managed nodes**

```bash
kubectl get nodes -l karpenter.sh/nodepool != "" --no-headers \
  | awk '{print $1}' \
  | xargs -I{} kubectl cordon {}
```

Actually, cordon the old ASG nodes:

```bash
for node in $(kubectl get nodes -l eks.amazonaws.com/nodegroup=old-ng --no-headers | awk '{print $1}'); do
  kubectl cordon $node
done
```

**Step 4: Scale down cluster-autoscaler**

```bash
kubectl scale deployment cluster-autoscaler -n kube-system --replicas=0
```

**Step 5: Drain old nodes gradually**

```bash
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data --grace-period=60
```

Karpenter will provision replacement nodes as pods become unschedulable.

**Step 6: Terminate old ASG instances and remove node groups**

**Step 7: Remove cluster-autoscaler**

```bash
helm uninstall cluster-autoscaler -n kube-system
```

---

## Common Pitfalls

### Single NodePool for Everything

**Problem:** One NodePool with all requirements means one blast radius. A limit hit or misconfiguration blocks all provisioning.

**Fix:** Segment by workload class (spot vs on-demand, GPU vs CPU, etc.) with separate NodePools.

### Too Few Instance Types

**Problem:** Requiring only `m5.2xlarge` means Karpenter competes for a single capacity pool. Spot interruptions are frequent; on-demand can be slow to acquire.

**Fix:** Open at least 5–10 compatible instance types via category + generation selectors, not explicit type names.

### Missing PodDisruptionBudgets

**Problem:** Consolidation evicts pods from underutilized nodes. Without PDBs, rolling replacements can take your service to zero replicas.

**Fix:** Every Deployment with `replicas > 1` should have a PDB:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app-pdb
spec:
  minAvailable: 1          # Or maxUnavailable: 1
  selector:
    matchLabels:
      app: my-app
```

### No Node Expiry TTL

**Problem:** Nodes run indefinitely. AMIs drift from current. Security patches never apply. Instance-level CVEs accumulate.

**Fix:** Set `expireAfter: 720h` (30 days) or your patch cadence. Pair with PDBs so expiry-driven drain is safe.

### Limits Set Too Low

**Problem:** NodePool `limits.cpu` or `limits.memory` is exhausted. Pods go pending. Karpenter refuses to provision. On-call gets paged.

**Fix:** Set limits 20–30% above your expected peak, and monitor `karpenter_nodepool_usage` and `karpenter_nodepool_limit` metrics in Prometheus.

### Conflicting NodePool Requirements

**Problem:** Two NodePools both match the same pending pod. Karpenter picks one arbitrarily (lowest cost). The selected pool may not be the intended one.

**Fix:** Use taints + tolerations to enforce workload → NodePool affinity, or use `nodeAffinity` / `nodeSelector` on pods to express preference.

### consolidateAfter: 0s

**Problem:** Karpenter consolidates immediately after a node becomes underutilized. High-churn workloads (batch jobs that spike and drain) trigger constant node replacement, inflating EC2 startup latency costs.

**Fix:** Set `consolidateAfter: 1m` or higher. Match it to your workload's burst duration.
