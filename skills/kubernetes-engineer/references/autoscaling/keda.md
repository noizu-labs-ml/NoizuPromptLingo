# KEDA — Kubernetes Event-Driven Autoscaling

## What KEDA Does

KEDA (Kubernetes Event-Driven Autoscaler) extends the native Horizontal Pod Autoscaler (HPA) to scale workloads based on external event sources — not just CPU and memory. It enables true 0→N scaling: pods scale to zero when idle and scale up instantly when events arrive.

**Core capabilities:**

| Capability | Description |
|---|---|
| 0→N scaling | Scale to zero replicas; wake on incoming events |
| HPA extension | KEDA creates and manages an HPA; standard HPA still works |
| 50+ scalers | Prometheus, Kafka, RabbitMQ, SQS, Redis, Cron, HTTP, and more |
| ScaledJob support | Scale Kubernetes Jobs instead of Deployments (queue consumers) |
| Multi-trigger | Combine multiple event sources on one ScaledObject |
| External auth | TriggerAuthentication keeps secrets out of ScaledObject specs |

**Architecture:**

KEDA runs as two components:
- **keda-operator** — watches ScaledObject/ScaledJob CRDs, creates/manages HPA objects, calls scalers
- **keda-metrics-apiserver** — exposes external metrics to the HPA via the custom metrics API

KEDA does not replace the HPA — it feeds it metrics and controls the min/max replica range.

---

## ScaledObject Configuration

`ScaledObject` is the primary KEDA resource. It targets a Deployment (or StatefulSet, etc.) and declares one or more scaling triggers.

### Annotated Reference

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: my-app-scaler
  namespace: my-namespace
spec:
  # Target workload to scale
  scaleTargetRef:
    apiVersion: apps/v1          # default; omit for Deployment
    kind: Deployment
    name: my-app

  # Replica bounds
  minReplicaCount: 0             # 0 enables scale-to-zero
  maxReplicaCount: 50

  # How often KEDA polls triggers (seconds)
  pollingInterval: 15

  # How long to wait after last event before scaling down (seconds)
  cooldownPeriod: 300

  # Threshold below which KEDA activates scaling (see below)
  # activationThreshold separate from targetValue — see triggers

  # Behavior passed through to HPA
  advanced:
    horizontalPodAutoscalerConfig:
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 120
          policies:
            - type: Percent
              value: 25
              periodSeconds: 60
        scaleUp:
          stabilizationWindowSeconds: 0
          policies:
            - type: Pods
              value: 5
              periodSeconds: 30

  # Fallback: use if all triggers fail to return metrics
  fallback:
    failureThreshold: 3          # consecutive failures before fallback
    replicas: 2                  # hold at this count during metric failure

  # One or more triggers
  triggers:
    - type: prometheus
      metadata:
        serverAddress: http://prometheus.monitoring.svc:9090
        metricName: http_requests_total
        query: sum(rate(http_requests_total{app="my-app"}[2m]))
        threshold: "100"
        activationThreshold: "1"  # min value to scale FROM zero
```

### Key Fields Explained

| Field | Default | Purpose |
|---|---|---|
| `minReplicaCount` | 0 | Set to 1+ to disable scale-to-zero |
| `maxReplicaCount` | 100 | Hard ceiling on replicas |
| `pollingInterval` | 30s | How often to check triggers |
| `cooldownPeriod` | 300s | Delay before scaling down after idle |
| `activationThreshold` | 0 | Metric value required to scale from 0→1 (separate from scaleUp threshold) |
| `fallback.replicas` | — | Safe replica count when metrics are unavailable |

---

## Key Trigger Types

### Prometheus

Scale on any PromQL query result.

```yaml
triggers:
  - type: prometheus
    metadata:
      serverAddress: http://prometheus.monitoring.svc:9090
      metricName: request_rate
      query: |
        sum(rate(http_requests_total{namespace="production",app="api"}[1m]))
      threshold: "50"            # target: 50 req/s per replica
      activationThreshold: "5"   # need >5 req/s to wake from zero
      namespace: production      # Prometheus namespace filter (optional)
    authenticationRef:
      name: prometheus-auth      # if Prometheus requires auth
```

**Tip:** `threshold` is per-replica target. KEDA computes `desired = ceil(metric / threshold)`. Set it to your per-pod saturation point.

### Cron

Scale on a time schedule. Useful for predictive scaling before business hours.

```yaml
triggers:
  - type: cron
    metadata:
      timezone: America/New_York
      start: "0 8 * * 1-5"      # 8am weekdays
      end:   "0 18 * * 1-5"     # 6pm weekdays
      desiredReplicas: "10"      # hold at 10 during window
```

**Combine with other triggers:** KEDA takes the maximum across all triggers. A cron trigger sets a floor; Prometheus can push higher during high-traffic windows.

### Kafka

Scale consumer group Deployments based on consumer lag.

```yaml
triggers:
  - type: kafka
    metadata:
      bootstrapServers: kafka.infra.svc:9092
      consumerGroup: my-consumer-group
      topic: my-topic
      lagThreshold: "500"          # messages behind per replica
      activationLagThreshold: "10" # wake from zero when lag > 10
      offsetResetPolicy: latest
    authenticationRef:
      name: kafka-auth
```

**Tip:** `lagThreshold: "500"` means: for every 500 messages of lag, add one replica. With 5000 messages of lag, KEDA targets 10 replicas.

### RabbitMQ

Scale on queue depth.

```yaml
triggers:
  - type: rabbitmq
    metadata:
      protocol: amqp             # or http
      queueName: task-queue
      mode: QueueLength          # or MessageRate
      value: "50"                # 50 messages per replica
      activationValue: "5"
    authenticationRef:
      name: rabbitmq-auth
```

### External (generic HTTP/gRPC)

Call a custom metrics endpoint conforming to the KEDA external scaler gRPC interface, or a simple HTTP endpoint.

```yaml
triggers:
  - type: external
    metadata:
      scalerAddress: my-custom-scaler.svc:9090
      myCustomMetric: "some-value"
```

Use the HTTP external scaler for REST-based metric sources:

```yaml
triggers:
  - type: external-push           # push-based variant
    metadata:
      scalerAddress: grpc-scaler.svc:9090
```

### CPU / Memory (built-in HPA passthrough)

KEDA can also drive CPU/memory scaling, mirroring HPA behavior but allowing combination with event triggers.

```yaml
triggers:
  - type: cpu
    metricType: Utilization       # or AverageValue
    metadata:
      value: "70"                 # 70% CPU utilization target

  - type: memory
    metricType: Utilization
    metadata:
      value: "80"
```

**Warning:** Mixing CPU/memory triggers with external triggers means KEDA takes the max across all. CPU could prevent scale-to-zero even when the queue is empty. Prefer using native HPA for CPU if you also want 0-replica capability.

---

## Scaling Behaviors

KEDA passes `behavior` blocks through to the underlying HPA. Configure these under `spec.advanced.horizontalPodAutoscalerConfig.behavior`.

### Scale-Up Behavior

```yaml
behavior:
  scaleUp:
    stabilizationWindowSeconds: 0      # No stabilization: scale up immediately
    selectPolicy: Max                  # Take the most aggressive policy
    policies:
      - type: Pods
        value: 10
        periodSeconds: 30              # Add up to 10 pods every 30s
      - type: Percent
        value: 100
        periodSeconds: 60              # Or double replicas every 60s
```

### Scale-Down Behavior

```yaml
behavior:
  scaleDown:
    stabilizationWindowSeconds: 300    # Consider 5 minutes of history before scaling down
    selectPolicy: Min                  # Take the least aggressive policy (conservative)
    policies:
      - type: Pods
        value: 2
        periodSeconds: 60              # Remove at most 2 pods per minute
      - type: Percent
        value: 10
        periodSeconds: 120             # Or 10% of replicas per 2 minutes
```

### Activation vs Scaling Thresholds

These two thresholds serve different purposes:

| Threshold | Controls | Example |
|---|---|---|
| `activationThreshold` | 0 → 1 transition (wake from sleep) | `"5"` — need >5 events to start any pod |
| `threshold` (per trigger) | 1+ replica scaling target | `"100"` — 1 replica per 100 events |

Setting `activationThreshold` prevents spurious wake-ups from noise. If unset, any nonzero metric value scales from 0 to 1.

---

## Authentication

Never put credentials directly in `ScaledObject`. Use `TriggerAuthentication` (namespace-scoped) or `ClusterTriggerAuthentication` (cluster-wide).

### TriggerAuthentication from Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: kafka-credentials
  namespace: my-namespace
type: Opaque
stringData:
  username: my-kafka-user
  password: my-kafka-password
---
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: kafka-auth
  namespace: my-namespace
spec:
  secretTargetRef:
    - parameter: username
      name: kafka-credentials
      key: username
    - parameter: password
      name: kafka-credentials
      key: password
```

Reference in the ScaledObject trigger:

```yaml
triggers:
  - type: kafka
    metadata:
      bootstrapServers: kafka.svc:9092
      consumerGroup: workers
      topic: events
      lagThreshold: "100"
    authenticationRef:
      name: kafka-auth
```

### ClusterTriggerAuthentication

For shared auth used across namespaces (e.g., central Prometheus, shared RabbitMQ):

```yaml
apiVersion: keda.sh/v1alpha1
kind: ClusterTriggerAuthentication
metadata:
  name: prometheus-auth
spec:
  secretTargetRef:
    - parameter: bearerToken
      name: prometheus-token          # Secret must be in KEDA's namespace
      key: token
```

Reference with `kind: ClusterTriggerAuthentication`:

```yaml
authenticationRef:
  name: prometheus-auth
  kind: ClusterTriggerAuthentication
```

### Pod Identity (IRSA / Workload Identity)

For AWS, KEDA can assume an IAM role via IRSA instead of secrets:

```yaml
spec:
  podIdentity:
    provider: aws
    identityId: arn:aws:iam::123456789:role/keda-sqs-role
```

---

## ScaledJob Patterns

Use `ScaledJob` when each work item maps to one Kubernetes Job execution (queue consumer, batch processor). Unlike `ScaledObject`, KEDA creates new Job instances per trigger event rather than scaling an existing Deployment.

### When to Use ScaledJob vs ScaledObject

| Use Case | Resource |
|---|---|
| Long-running consumers (keep polling) | ScaledObject targeting Deployment |
| One-shot processing (1 job = 1 item) | ScaledJob |
| Queue where each message = isolated unit | ScaledJob |
| Stateful stream processors | ScaledObject targeting StatefulSet |

### ScaledJob Example

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
metadata:
  name: queue-processor
  namespace: processing
spec:
  jobTargetRef:
    parallelism: 1
    completions: 1
    activeDeadlineSeconds: 600
    backoffLimit: 2
    template:
      spec:
        containers:
          - name: worker
            image: my-registry/queue-worker:v1.2.0
            env:
              - name: QUEUE_URL
                valueFrom:
                  secretKeyRef:
                    name: queue-config
                    key: url
        restartPolicy: Never

  pollingInterval: 10
  maxReplicaCount: 20
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 5

  scalingStrategy:
    strategy: accurate            # accurate | default | custom
    # accurate: 1 Job per pending message (most precise, higher API load)
    # default: KEDA estimates based on threshold

  triggers:
    - type: rabbitmq
      metadata:
        protocol: amqp
        queueName: processing-queue
        mode: QueueLength
        value: "1"               # 1 job per 1 message
      authenticationRef:
        name: rabbitmq-auth
```

### ScaledJob Scaling Strategies

| Strategy | Behavior | Use When |
|---|---|---|
| `default` | One Job per `value` metric units | General purpose |
| `accurate` | Exactly one Job per pending item | Exactly-once processing required |
| `custom` | User-defined via `customScalingQueueLengthDeduction` | Advanced queue accounting |

---

## Common Pitfalls

### KEDA + HPA Conflict

**Problem:** You have an existing HPA on the same Deployment as your ScaledObject. Two controllers fight over the replica count, causing flapping.

**Fix:** Delete the existing HPA before creating the ScaledObject. KEDA creates and owns its own HPA — do not create one manually.

```bash
kubectl delete hpa my-app -n my-namespace
```

### cooldownPeriod: 0

**Problem:** Setting `cooldownPeriod: 0` means KEDA scales to zero immediately when the metric drops. This causes rapid scale-up/scale-down cycles for bursty workloads (flapping), especially combined with slow pod startup.

**Fix:** Set `cooldownPeriod` to at least 2x your average burst interval. For most web services: 120–300s. For batch consumers: match to your batch frequency.

### No Fallback Configuration

**Problem:** The external metrics source (Prometheus, Kafka broker, etc.) goes down. KEDA cannot get a metric value. Without fallback, behavior is undefined — KEDA may scale to 0 or hold at current replicas depending on version.

**Fix:** Always set `fallback`:

```yaml
fallback:
  failureThreshold: 3     # 3 consecutive poll failures
  replicas: 3             # hold at 3 replicas during outage
```

This prevents accidental scale-to-zero during an observability outage.

### Slow pollingInterval on Fast Queues

**Problem:** Default `pollingInterval: 30` means up to 30 seconds of lag before KEDA reacts to a queue spike. For SQS or Kafka with short message TTLs, this burns messages.

**Fix:** For latency-sensitive queues, set `pollingInterval: 5` or lower. Watch KEDA controller CPU if you have many ScaledObjects at 5s interval.

### activationThreshold Not Set for Scale-to-Zero

**Problem:** `minReplicaCount: 0` but no `activationThreshold`. A single stray metric datapoint (noise, test message, stale Prometheus sample) wakes the Deployment. Cold start latency hits users.

**Fix:** Set `activationThreshold` to a meaningful value (e.g., `"5"` for queue depth, `"10"` for request rate). This creates a dead-band: below the threshold, stay at zero; above it, scale up.

### Threshold Miscalibration

**Problem:** `threshold: "1"` on a Prometheus query returning per-second request rate. With 1000 req/s, KEDA targets 1000 replicas.

**Fix:** `threshold` is the per-replica target. Set it to your pod's measured saturation point, not an arbitrary small number. Load test first, then set threshold to 80% of measured pod capacity.

### ScaledObject Targeting Wrong API Version

**Problem:** ScaledObject targets a CRD-backed resource (e.g., a Rollout from Argo Rollouts) without specifying `apiVersion`. KEDA defaults to `apps/v1` and fails to find the resource.

**Fix:** Always specify `apiVersion` in `scaleTargetRef` when the target is not a standard `apps/v1` Deployment:

```yaml
scaleTargetRef:
  apiVersion: argoproj.io/v1alpha1
  kind: Rollout
  name: my-app
```
