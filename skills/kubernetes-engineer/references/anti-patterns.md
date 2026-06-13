# Kubernetes Anti-Pattern Catalog

Comprehensive reference of production K8s anti-patterns, organized by category. Each entry includes detection commands and step-by-step remediation.

---

## Resource Management

### 1. No Resource Requests or Limits

**Severity:** Critical

**Description:** Containers deployed without `resources.requests` and `resources.limits` defined. The scheduler has no signal for placement and the kubelet has no enforcement ceiling.

**Why it's dangerous:** Without requests, the scheduler places pods on nodes arbitrarily — leading to noisy-neighbor contention, OOMKilled cascades, and node pressure evictions. Without limits, a single runaway process can starve all other workloads on the node. QoS class defaults to BestEffort, making these pods the first evicted under memory pressure.

**Detection:**
```bash
# Find containers with no requests or limits
kubectl get pods -A -o json | jq -r '
  .items[] |
  .metadata.namespace as $ns |
  .metadata.name as $pod |
  .spec.containers[] |
  select(.resources.requests == null or .resources.limits == null) |
  [$ns, $pod, .name] | join("/")
'

# Kube-score (static analysis)
kube-score score deployment.yaml

# Polaris audit
polaris audit --audit-path . --format=pretty
```

**Remediation:**
1. Add `resources` block to every container spec:
   ```yaml
   resources:
     requests:
       cpu: "100m"
       memory: "128Mi"
     limits:
       cpu: "500m"
       memory: "256Mi"
   ```
2. Use VPA in recommendation mode (`updateMode: "Off"`) for 7+ days to collect baseline data.
3. Retrieve VPA recommendations: `kubectl describe vpa <name> -n <ns>`
4. Apply recommendations with a 20% headroom buffer.
5. Enforce via admission webhook (OPA Gatekeeper or Kyverno policy requiring resources on all containers).

---

### 2. Limits Set 4x or More Above Requests

**Severity:** High

**Description:** Resource limits defined at extreme multiples of requests (e.g., `requests.cpu: 100m`, `limits.cpu: 4000m`). Often seen when developers cargo-cult "set limits high to be safe."

**Why it's dangerous:** The scheduler uses *requests* for placement, so the node is overcommitted on paper. If multiple pods burst to their limits simultaneously the node saturates, triggering CPU throttling and OOM kills across unrelated workloads. Also produces misleading capacity planning numbers.

**Detection:**
```bash
kubectl get pods -A -o json | jq -r '
  .items[] | .metadata.namespace as $ns | .metadata.name as $pod |
  .spec.containers[] |
  select(
    .resources.limits.cpu != null and .resources.requests.cpu != null
  ) |
  . as $c |
  ($c.resources.limits.cpu | gsub("m";"") | tonumber) as $lim |
  ($c.resources.requests.cpu | gsub("m";"") | tonumber) as $req |
  select($lim / $req > 4) |
  [$ns, $pod, $c.name, ($req|tostring), ($lim|tostring)] | join("\t")
'
```

**Remediation:**
1. Establish a target ratio: limits should be 1.5x–2x requests for latency-sensitive workloads, up to 3x for batch.
2. Run VPA recommender for one week and use its `upperBound` as the limit, `target` as the request.
3. Implement a LimitRange in each namespace to enforce ratio policy:
   ```yaml
   apiVersion: v1
   kind: LimitRange
   metadata:
     name: ratio-policy
   spec:
     limits:
     - type: Container
       maxLimitRequestRatio:
         cpu: "3"
         memory: "2"
   ```

---

### 3. VPA and HPA Targeting the Same Metric

**Severity:** High

**Description:** Both Vertical Pod Autoscaler and Horizontal Pod Autoscaler are configured on the same Deployment and both target CPU utilization. They issue conflicting signals — VPA raises resource requests (which lowers utilization), HPA tries to scale horizontally based on utilization, and they fight each other in a feedback loop.

**Why it's dangerous:** Oscillation between scaling actions causes pod churn, constant restarts (VPA evicts to apply new requests), unpredictable replica counts, and degraded availability during high-traffic events.

**Detection:**
```bash
# List all VPAs and HPAs per namespace and compare targets
kubectl get vpa,hpa -A -o wide

# Check if same deployment appears in both
kubectl get vpa -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.spec.targetRef.name}{"\n"}{end}'
kubectl get hpa -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.spec.scaleTargetRef.name}{"\n"}{end}'
```

**Remediation:**
- **Option A (preferred):** Use VPA for memory only (`containerPolicies: [{controlledResources: ["memory"]}]`), HPA for CPU-based horizontal scaling. They operate on different dimensions and do not conflict.
- **Option B:** Remove HPA; use VPA with `updateMode: Auto` for workloads that are truly single-instance.
- **Option C:** Use KEDA for custom-metric HPA (queue depth, RPS) and VPA for right-sizing — zero overlap.
- Never run both targeting CPU simultaneously.

---

### 4. No ResourceQuotas on Shared Namespaces

**Severity:** Medium

**Description:** Namespaces used by multiple teams or services have no `ResourceQuota` defined. Any workload can consume unbounded cluster resources.

**Why it's dangerous:** A misconfigured deployment or a runaway job can exhaust CPU, memory, or object counts cluster-wide, starving other tenants. No blast radius boundary exists.

**Detection:**
```bash
# List namespaces without ResourceQuota
comm -23 \
  <(kubectl get ns -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | sort) \
  <(kubectl get resourcequota -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"\n"}{end}' | sort -u)
```

**Remediation:**
1. Define per-namespace quotas based on team allocation:
   ```yaml
   apiVersion: v1
   kind: ResourceQuota
   metadata:
     name: team-quota
     namespace: team-a
   spec:
     hard:
       requests.cpu: "8"
       requests.memory: 16Gi
       limits.cpu: "24"
       limits.memory: 48Gi
       pods: "50"
       persistentvolumeclaims: "20"
   ```
2. Pair with `LimitRange` defaults so pods without explicit resources still land within quota.
3. Set up alerts when quota usage exceeds 80%: `kube_resourcequota` metrics in Prometheus.

---

## Image & Deployment

### 5. Using the `:latest` Image Tag

**Severity:** Critical

**Description:** Container images referenced as `image: myapp:latest` or `image: myapp` (implicit latest). The tag is mutable — it resolves to a different digest on every pull.

**Why it's dangerous:** Deployments become non-reproducible. A node replacement or pod restart can pull a different image version than the rest of the fleet, causing split-version clusters. Rollbacks are impossible when you cannot pin what was running. Also defeats layer caching.

**Detection:**
```bash
kubectl get pods -A -o json | jq -r '
  .items[] | .metadata.namespace as $ns | .metadata.name as $pod |
  .spec.containers[] |
  select(.image | endswith(":latest") or (contains(":") | not)) |
  [$ns, $pod, .name, .image] | join("\t")
'
```

**Remediation:**
1. Pin images to immutable SHA digests in production: `image: myapp@sha256:abc123...`
2. Use semantic version tags as a minimum: `image: myapp:1.4.2`
3. Enforce via admission webhook — deny any pod spec with `:latest` or no tag.
4. In CI/CD, build with commit SHA tag and promote through environments. Never push to `:latest`.
5. Configure `imagePullPolicy: IfNotPresent` for versioned tags (default is `Always` for `:latest`).

---

### 6. Bare Pods (Pods Not Managed by a Controller)

**Severity:** Critical

**Description:** Pods created directly via `kubectl run` or raw Pod manifests, not wrapped in a Deployment, StatefulSet, or Job.

**Why it's dangerous:** Bare pods are not rescheduled if the node fails — they simply disappear. No rolling update, no rollback, no self-healing. Nodes drain, nodes fail; bare pods are permanent casualties.

**Detection:**
```bash
# Find pods not owned by any controller
kubectl get pods -A -o json | jq -r '
  .items[] |
  select(.metadata.ownerReferences == null or (.metadata.ownerReferences | length) == 0) |
  select(.metadata.namespace != "kube-system") |
  [.metadata.namespace, .metadata.name] | join("\t")
'
```

**Remediation:**
1. Wrap every workload in the appropriate controller:
   - Stateless services → `Deployment`
   - Stateful workloads → `StatefulSet`
   - One-time tasks → `Job`
   - Recurring tasks → `CronJob`
   - Node-local daemons → `DaemonSet`
2. Migrate existing bare pods:
   ```bash
   kubectl get pod <name> -o yaml > pod.yaml
   # Wrap spec.containers into a Deployment template
   kubectl delete pod <name>
   kubectl apply -f deployment.yaml
   ```
3. Block bare pod creation with Kyverno:
   ```yaml
   # Kyverno ClusterPolicy: disallow bare pods
   spec:
     rules:
     - name: require-controller
       match:
         resources:
           kinds: [Pod]
       exclude:
         resources:
           namespaces: [kube-system]
       validate:
         message: "Pods must be managed by a controller."
         deny:
           conditions:
           - key: "{{request.object.metadata.ownerReferences}}"
             operator: Equals
             value: null
   ```

---

### 7. Multiple Processes Per Container

**Severity:** High

**Description:** A single container runs multiple processes — e.g., nginx + application + cron — managed by a supervisor like `supervisord` or a shell script.

**Why it's dangerous:** Violates the single-responsibility principle of containers. Process failures are hidden (container stays Running while inner processes die). Independent scaling is impossible. Logs from multiple processes intermingle. Health checks become ambiguous. Security surface expands.

**Detection:**
```bash
# Inspect entrypoints/commands for supervisord or process managers
kubectl get pods -A -o json | jq -r '
  .items[].spec.containers[] |
  select(
    (.command // [] | any(. | test("supervisord|s6|runit|foreman"))) or
    (.args // [] | any(. | test("supervisord|s6|runit|foreman")))
  ) |
  .name
'
```

**Remediation:**
1. Split each process into its own container within the same Pod (sidecar pattern) if they share lifecycle and network namespace.
2. For truly independent processes, split into separate Deployments.
3. Use init containers for setup tasks that must complete before the main process starts.
4. Restructure Dockerfile: one `CMD`, one process.

---

### 8. No Readiness Probe Defined

**Severity:** High

**Description:** Containers have no `readinessProbe`. Kubernetes marks the pod Ready immediately after the container starts, before the application is actually ready to serve traffic.

**Why it's dangerous:** During rolling deployments, traffic is routed to new pods before they finish initialization — causing request errors, timeouts, and failed healthchecks hitting users. Also masks slow-starting apps and warm-up failures.

**Detection:**
```bash
kubectl get pods -A -o json | jq -r '
  .items[] | .metadata.namespace as $ns | .metadata.name as $pod |
  .spec.containers[] |
  select(.readinessProbe == null) |
  select(.name != "istio-proxy") |
  [$ns, $pod, .name] | join("\t")
'
```

**Remediation:**
1. Add a readiness probe appropriate to the protocol:
   ```yaml
   readinessProbe:
     httpGet:
       path: /healthz/ready
       port: 8080
     initialDelaySeconds: 10
     periodSeconds: 5
     failureThreshold: 3
   ```
2. For TCP services: use `tcpSocket` probe.
3. For gRPC: use `grpc` probe (K8s 1.24+) or exec with `grpc-health-probe`.
4. Ensure the readiness endpoint returns non-2xx if any downstream dependency is unavailable.
5. Set `initialDelaySeconds` based on measured cold-start time + 20% buffer.

---

### 9. Liveness Probe Identical to Readiness Probe

**Severity:** Medium

**Description:** Both `livenessProbe` and `readinessProbe` point to the same endpoint and thresholds. Often copy-pasted between the two fields.

**Why it's dangerous:** Liveness and readiness serve different purposes. A failing liveness probe kills and restarts the pod — if the endpoint reflects dependency health (e.g., database down), the pod gets restart-looped even though the process is healthy and could recover once the DB returns. This causes cascading restarts under dependency failures.

**Detection:**
```bash
kubectl get pods -A -o json | jq -r '
  .items[] | .metadata.namespace as $ns | .metadata.name as $pod |
  .spec.containers[] |
  select(.livenessProbe != null and .readinessProbe != null) |
  select(.livenessProbe == .readinessProbe) |
  [$ns, $pod, .name] | join("\t")
'
```

**Remediation:**
- **Liveness probe** — checks if the process is alive (not deadlocked). Should only fail if the process cannot recover without a restart. Typically a lightweight internal ping: `/healthz/live`.
- **Readiness probe** — checks if the pod can serve traffic (dependencies up, warmed up). Can reflect external health. `/healthz/ready`.
- Set liveness with higher `failureThreshold` (5–10) to tolerate transient spikes.
- Set readiness with lower threshold (2–3) for fast traffic removal.

---

### 10. Using initContainers for Application Configuration

**Severity:** Medium

**Description:** `initContainers` used to render config templates, fetch secrets, or perform application-level bootstrapping that belongs in the main container startup.

**Why it's dangerous:** Init containers run with the same privileges as the main container but add startup latency, complicate debugging, and can fail silently (pod stuck in `Init:0/1`). Config rendered by an init container may become stale if the main container restarts without re-running init.

**Detection:**
```bash
kubectl get pods -A -o json | jq -r '
  .items[] | select(.spec.initContainers != null and (.spec.initContainers | length) > 0) |
  [.metadata.namespace, .metadata.name, (.spec.initContainers | map(.name) | join(","))] | join("\t")
'
```

**Remediation:**
- Move secret fetching to the application startup (use Infisical SDK, Vault agent sidecar, or CSI driver to mount secrets directly).
- Move config templating to ConfigMaps or Helm rendering at deploy time.
- Reserve `initContainers` for legitimate use cases: waiting for dependency readiness (`wait-for-postgres`), schema migrations (but prefer a Job), or kernel tuning (`sysctl` changes requiring root).

---

## Security

### 11. Privileged Containers

**Severity:** Critical

**Description:** Containers running with `securityContext.privileged: true`. Equivalent to running as root on the host.

**Why it's dangerous:** Privileged containers can access all host devices, modify kernel parameters, escape the container runtime, and pivot to compromise the entire node and cluster. A single RCE in a privileged container = full node compromise.

**Detection:**
```bash
kubectl get pods -A -o json | jq -r '
  .items[] | .metadata.namespace as $ns | .metadata.name as $pod |
  .spec.containers[] |
  select(.securityContext.privileged == true) |
  [$ns, $pod, .name] | join("\t")
'

# Also check for hostPID, hostNetwork, hostIPC
kubectl get pods -A -o json | jq -r '
  .items[] |
  select(.spec.hostPID == true or .spec.hostNetwork == true or .spec.hostIPC == true) |
  [.metadata.namespace, .metadata.name] | join("\t")
'
```

**Remediation:**
1. Remove `privileged: true` from all container specs.
2. Identify what capability the privileged flag was granting and add only that specific capability:
   ```yaml
   securityContext:
     capabilities:
       add: ["NET_ADMIN"]  # only if truly needed
       drop: ["ALL"]
   ```
3. Use `allowPrivilegeEscalation: false` on all containers.
4. Enforce Pod Security Standards at namespace level:
   ```bash
   kubectl label namespace <ns> \
     pod-security.kubernetes.io/enforce=restricted \
     pod-security.kubernetes.io/audit=restricted
   ```
5. For DaemonSets needing host access, use specific `hostPath` mounts rather than full privilege.

---

### 12. cluster-admin ClusterRoleBinding for Application ServiceAccounts

**Severity:** Critical

**Description:** Application workloads run with a ServiceAccount that has `cluster-admin` ClusterRole bound — granting read/write access to all resources in all namespaces.

**Why it's dangerous:** Any pod RCE or SSRF that can reach the Kubernetes API becomes a full cluster takeover. This is the single most common path from application vulnerability to cluster compromise.

**Detection:**
```bash
# Find cluster-admin bindings not in kube-system
kubectl get clusterrolebindings -o json | jq -r '
  .items[] |
  select(.roleRef.name == "cluster-admin") |
  select(.subjects != null) |
  .metadata.name as $binding |
  .subjects[] |
  select(.kind == "ServiceAccount") |
  select(.namespace != "kube-system") |
  [$binding, .namespace, .name] | join("\t")
'
```

**Remediation:**
1. Audit what API operations the application actually performs.
2. Create a least-privilege Role or ClusterRole:
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: Role
   metadata:
     name: app-role
     namespace: my-app
   rules:
   - apiGroups: [""]
     resources: ["configmaps"]
     verbs: ["get", "list", "watch"]
   ```
3. Bind to namespace-scoped RoleBinding, not ClusterRoleBinding.
4. Rotate the ServiceAccount token after binding change.
5. Enable audit logging and alert on any `cluster-admin` binding creation.

---

### 13. No NetworkPolicies (Flat Network)

**Severity:** High

**Description:** All pods in the cluster can communicate with all other pods on any port. No `NetworkPolicy` resources defined.

**Why it's dangerous:** Lateral movement is trivial. A compromised pod in the frontend namespace can directly reach the database pods in the backend namespace. No blast radius containment exists at the network layer.

**Detection:**
```bash
# Namespaces with no NetworkPolicy
comm -23 \
  <(kubectl get ns -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | sort) \
  <(kubectl get networkpolicy -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"\n"}{end}' | sort -u)
```

**Remediation:**
1. Start with a default-deny-all policy in each namespace:
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: default-deny-all
     namespace: my-app
   spec:
     podSelector: {}
     policyTypes: [Ingress, Egress]
   ```
2. Add explicit allow rules for required traffic (ingress from ingress controller, egress to database, egress to DNS port 53).
3. Verify CNI plugin supports NetworkPolicy (Calico, Cilium, Weave — not Flannel alone).
4. Use Cilium NetworkPolicy for L7 (HTTP path/method) enforcement if needed.

---

### 14. Secrets in Environment Variables

**Severity:** Medium

**Description:** Kubernetes Secrets mounted as environment variables (`env[].valueFrom.secretKeyRef`) rather than files or external secret stores.

**Why it's dangerous:** Environment variables leak into crash dumps, `kubectl describe pod` output, process listings (`/proc/<pid>/environ`), and any debug tooling. They are visible to all processes in the container, including any injected sidecar. They cannot be rotated without a pod restart.

**Detection:**
```bash
kubectl get pods -A -o json | jq -r '
  .items[] | .metadata.namespace as $ns | .metadata.name as $pod |
  .spec.containers[] |
  select(.env != null) |
  . as $c |
  .env[] |
  select(.valueFrom.secretKeyRef != null) |
  [$ns, $pod, $c.name, .name] | join("\t")
'
```

**Remediation:**
1. Mount secrets as files using `volumeMounts` + `volumes.secret`:
   ```yaml
   volumes:
   - name: app-secrets
     secret:
       secretName: my-secret
   containers:
   - volumeMounts:
     - name: app-secrets
       mountPath: /run/secrets
       readOnly: true
   ```
2. For dynamic rotation, use CSI Secret Store driver (Infisical, Vault, AWS Secrets Manager).
3. Ensure mounted secret directories have restrictive file permissions (0400).
4. Update application to read from file paths instead of environment variables.

---

### 15. Using the Default ServiceAccount

**Severity:** Medium

**Description:** Pods run with the `default` ServiceAccount in their namespace — the auto-assigned account when no `serviceAccountName` is specified.

**Why it's dangerous:** The default ServiceAccount often accumulates permissions over time as teams bind roles to it for convenience. Any pod (including misconfigured or compromised ones) in the namespace inherits those permissions. Blast radius is the entire namespace's accumulated RBAC.

**Detection:**
```bash
kubectl get pods -A -o json | jq -r '
  .items[] |
  select(
    .spec.serviceAccountName == "default" or
    .spec.serviceAccountName == null
  ) |
  select(.metadata.namespace != "kube-system") |
  [.metadata.namespace, .metadata.name] | join("\t")
'
```

**Remediation:**
1. Create a dedicated ServiceAccount per application:
   ```yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: myapp
     namespace: my-ns
   automountServiceAccountToken: false  # unless API access is needed
   ```
2. Set `automountServiceAccountToken: false` on the default ServiceAccount to prevent token injection:
   ```bash
   kubectl patch serviceaccount default -n <ns> \
     -p '{"automountServiceAccountToken": false}'
   ```
3. Reference the dedicated SA in pod specs: `serviceAccountName: myapp`.
4. Grant only the minimum RBAC rules the application needs.

---

## Operational

### 16. No PodDisruptionBudgets for Critical Services

**Severity:** High

**Description:** Deployments with multiple replicas have no `PodDisruptionBudget` defined. Node drains (upgrades, spot interruptions) can evict all replicas simultaneously.

**Why it's dangerous:** During cluster upgrades or node replacements, `kubectl drain` evicts pods as fast as possible. Without a PDB, all replicas of a service can be terminated at once, causing a full outage. No quorum guarantees exist.

**Detection:**
```bash
# Deployments with >1 replica and no PDB
kubectl get deploy -A -o json | jq -r '
  .items[] |
  select(.spec.replicas > 1) |
  [.metadata.namespace, .metadata.name] | join("\t")
' | while IFS=$'\t' read ns name; do
  pdb=$(kubectl get pdb -n "$ns" -o json 2>/dev/null | jq -r --arg name "$name" '
    .items[] | select(.spec.selector.matchLabels | to_entries[] | .value == $name)
    | .metadata.name' 2>/dev/null)
  [ -z "$pdb" ] && echo "MISSING PDB: $ns/$name"
done
```

**Remediation:**
1. Create a PDB for every Deployment with >1 replica:
   ```yaml
   apiVersion: policy/v1
   kind: PodDisruptionBudget
   metadata:
     name: myapp-pdb
     namespace: my-ns
   spec:
     minAvailable: 1   # or maxUnavailable: 1
     selector:
       matchLabels:
         app: myapp
   ```
2. For stateful quorum services (etcd, Kafka): `minAvailable` should be `ceil(replicas/2)`.
3. For frontend services: `maxUnavailable: 25%` is reasonable.
4. Test PDB behavior: `kubectl drain <node> --dry-run`.

---

### 17. Direct kubectl edit in Production

**Severity:** High

**Description:** Operators modify live production resources with `kubectl edit`, `kubectl patch`, or `kubectl set image` rather than updating version-controlled manifests or Helm values.

**Why it's dangerous:** Live edits are invisible to GitOps systems — they create configuration drift. The next Helm upgrade or ArgoCD sync will overwrite the change with no warning. Changes are untracked, unreviewed, and non-reproducible. Postmortems become impossible.

**Detection:**
```bash
# If using ArgoCD, check for OutOfSync resources
argocd app list --output json | jq -r '.[] | select(.status.sync.status == "OutOfSync") | .metadata.name'

# Audit recent kubectl edit events
kubectl get events -A --field-selector reason=Updated -o json | \
  jq -r '.items[] | select(.reportingComponent == "kubectl") | [.metadata.namespace, .involvedObject.name, .message] | join("\t")'
```

**Remediation:**
1. Establish GitOps — all changes go through Git PRs (ArgoCD, Flux).
2. Restrict `kubectl edit/patch/delete` in production via RBAC — require operators to use deployment pipelines.
3. Set ArgoCD applications to `syncPolicy.automated.selfHeal: true` to auto-revert drift.
4. For emergency hotfixes: document the change simultaneously in a Git commit, then allow the sync to converge.

---

### 18. No Pod Anti-Affinity for Multi-Replica Deployments

**Severity:** Medium

**Description:** Multi-replica Deployments have no affinity rules — Kubernetes may schedule all replicas on the same node. A single node failure eliminates all replicas.

**Why it's dangerous:** Defeats the entire purpose of running multiple replicas. HA workloads become single points of failure at the node layer.

**Detection:**
```bash
kubectl get deploy -A -o json | jq -r '
  .items[] |
  select(.spec.replicas > 1) |
  select(.spec.template.spec.affinity == null or .spec.template.spec.affinity.podAntiAffinity == null) |
  [.metadata.namespace, .metadata.name, (.spec.replicas | tostring)] | join("\t")
'
```

**Remediation:**
1. Add `preferredDuringSchedulingIgnoredDuringExecution` anti-affinity (soft) to spread replicas:
   ```yaml
   affinity:
     podAntiAffinity:
       preferredDuringSchedulingIgnoredDuringExecution:
       - weight: 100
         podAffinityTerm:
           labelSelector:
             matchLabels:
               app: myapp
           topologyKey: kubernetes.io/hostname
   ```
2. For critical services, use `requiredDuringSchedulingIgnoredDuringExecution` (hard) — pods will not schedule if a node already has one.
3. For zone-aware HA, use `topologyKey: topology.kubernetes.io/zone`.
4. K8s 1.27+ supports `topologySpreadConstraints` as a cleaner alternative:
   ```yaml
   topologySpreadConstraints:
   - maxSkew: 1
     topologyKey: kubernetes.io/hostname
     whenUnsatisfiable: DoNotSchedule
     labelSelector:
       matchLabels:
         app: myapp
   ```

---

### 19. Orphaned PersistentVolumeClaims and LoadBalancer Services

**Severity:** Medium

**Description:** PVCs and Services of type `LoadBalancer` remain after the workload that created them is deleted. In cloud environments, these continue to bill for provisioned storage and cloud load balancers.

**Why it's dangerous:** Silent cost accumulation. PVCs can hold data from deleted workloads indefinitely. Orphaned LoadBalancers maintain cloud infrastructure costs and exposed IPs with no backend.

**Detection:**
```bash
# PVCs not mounted by any pod
kubectl get pvc -A -o json | jq -r '
  .items[] | select(.metadata.annotations["pv.kubernetes.io/bound-by-controller"] != null) |
  [.metadata.namespace, .metadata.name, .status.phase] | join("\t")
' 

# Cross-reference mounted PVCs
kubectl get pods -A -o json | jq -r '
  .items[].spec.volumes[]? | select(.persistentVolumeClaim != null) | .persistentVolumeClaim.claimName
' | sort -u > /tmp/mounted-pvcs.txt

kubectl get pvc -A -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | sort > /tmp/all-pvcs.txt

comm -23 /tmp/all-pvcs.txt /tmp/mounted-pvcs.txt

# LoadBalancer services with no endpoints
kubectl get svc -A --field-selector spec.type=LoadBalancer -o json | jq -r '
  .items[] | [.metadata.namespace, .metadata.name, .spec.loadBalancerIP] | join("\t")
'
```

**Remediation:**
1. Set `persistentVolumeReclaimPolicy: Delete` on StorageClasses for ephemeral data.
2. Use `Retain` for data that must survive pod deletion — but implement a cleanup workflow.
3. Run periodic audits via `kubectl get pvc -A` cross-referenced with running pods.
4. Use Helm hooks (`post-delete`) to clean up PVCs when chart is uninstalled.
5. For LoadBalancers: delete Services before deleting Deployments. Add to runbooks.

---

### 20. No Consistent Label Strategy

**Severity:** Medium

**Description:** Pods and resources lack a standard label schema. Labels are ad-hoc, inconsistent, or missing recommended keys.

**Why it's dangerous:** Label selectors become unreliable. Monitoring, alerting, and cost allocation tools cannot group resources by team, environment, or service. PDB selectors break. NetworkPolicy selectors match unintended pods.

**Detection:**
```bash
# Check for missing recommended labels
kubectl get pods -A -o json | jq -r '
  .items[] |
  select(
    (.metadata.labels["app.kubernetes.io/name"] == null) or
    (.metadata.labels["app.kubernetes.io/version"] == null) or
    (.metadata.labels["app.kubernetes.io/component"] == null)
  ) |
  [.metadata.namespace, .metadata.name] | join("\t")
'
```

**Remediation:**
1. Adopt the Kubernetes recommended label schema:
   ```yaml
   labels:
     app.kubernetes.io/name: myapp
     app.kubernetes.io/instance: myapp-prod
     app.kubernetes.io/version: "1.4.2"
     app.kubernetes.io/component: backend
     app.kubernetes.io/part-of: myplatform
     app.kubernetes.io/managed-by: helm
   ```
2. Add custom labels for cost allocation: `team: platform`, `env: production`.
3. Enforce via Kyverno `mutate` policy to inject missing labels on pod creation.
4. Update all selectors in Services, HPA, PDB, and NetworkPolicies to use the standard schema.

---

## Helm

### 21. Environment Conditionals in Helm Templates

**Severity:** High

**Description:** Templates contain `{{- if eq .Values.global.env "production" }}` blocks that render different resources or configurations per environment. Production and non-production templates diverge.

**Why it's dangerous:** What you deploy to staging is not what you deploy to production. The production path is never tested in lower environments. Bugs hide behind the conditional. Diff between environments is invisible to reviewers.

**Detection:**
```bash
# Find templates with environment conditionals
grep -r 'if eq.*env\|if .Values.global.env\|if eq.*environment' \
  --include="*.yaml" --include="*.tpl" \
  charts/ templates/ */templates/
```

**Remediation:**
1. Eliminate environment branches in templates. Use a single template path.
2. Express environment differences purely in `values-<env>.yaml` files: different replica counts, resource sizes, ingress hostnames.
3. Use Helm's `--values` flag to layer environment overrides:
   ```bash
   helm upgrade myapp . -f values.yaml -f values-production.yaml
   ```
4. If truly divergent infrastructure is required per environment, maintain separate charts or use Kustomize overlays.

---

### 22. Copy-Paste Templates Without Abstraction

**Severity:** High

**Description:** Helm chart templates duplicate boilerplate — the same Deployment structure repeated with minor name changes across multiple files in the same chart.

**Why it's dangerous:** Changes must be made in N places. One missed location causes configuration drift. Security patches (adding `securityContext`, updating probe paths) are inconsistently applied.

**Detection:**
```bash
# Look for near-duplicate template files
find . -name "*.yaml" -path "*/templates/*" | \
  xargs wc -l | sort -n | \
  awk '$1 > 30 {print $2}' | \
  head -20
# Manually inspect for structural similarity
```

**Remediation:**
1. Extract shared structure into named templates in `templates/_helpers.tpl`:
   ```yaml
   {{- define "myapp.deployment" -}}
   # ... shared deployment structure
   {{- end }}
   ```
2. Call via `{{- include "myapp.deployment" . | nindent 0 }}`.
3. For multi-service charts, use a single Deployment template that iterates over a `services:` values map.
4. Consider Helm library charts for patterns shared across multiple charts.

---

### 23. No values.schema.json

**Severity:** Medium

**Description:** Helm charts have no `values.schema.json` to validate the structure and types of values passed to the chart.

**Why it's dangerous:** Typos in values files (`repicas: 2` instead of `replicas: 2`) silently deploy with wrong configuration. Required values can be omitted without error. Type mismatches (string where int expected) surface as cryptic template rendering errors.

**Detection:**
```bash
find . -name "Chart.yaml" | while read chart; do
  dir=$(dirname "$chart")
  [ ! -f "$dir/values.schema.json" ] && echo "Missing schema: $dir"
done
```

**Remediation:**
1. Generate initial schema from existing values.yaml:
   ```bash
   helm schema-gen values.yaml > values.schema.json
   ```
2. Add type constraints, required fields, and enum validations:
   ```json
   {
     "$schema": "https://json-schema.org/draft/07/schema",
     "properties": {
       "replicaCount": {
         "type": "integer",
         "minimum": 1
       },
       "image": {
         "type": "object",
         "required": ["repository", "tag"],
         "properties": {
           "tag": {"type": "string", "pattern": "^v[0-9]+"}
         }
       }
     },
     "required": ["replicaCount", "image"]
   }
   ```
3. Validate in CI: `helm lint --strict chart/` fails on schema violations.

---

### 24. Skipping Upgrade Testing (No Helm Test or Diff)

**Severity:** High

**Description:** Helm upgrades are applied directly to production without a dry-run diff review or post-upgrade test suite.

**Why it's dangerous:** Breaking changes in values or templates are invisible until after deployment. Regressions in probes, RBAC, or service selectors cause silent failures. `helm upgrade` can succeed while the application is broken.

**Detection:**
```bash
# Check if helm tests exist
find . -name "*.yaml" -path "*/templates/tests/*"
find . -name "test-*.yaml" -path "*/templates/*"
```

**Remediation:**
1. Run `helm diff upgrade` (plugin) before every production upgrade:
   ```bash
   helm plugin install https://github.com/databus23/helm-diff
   helm diff upgrade myapp . -f values-prod.yaml
   ```
2. Add `templates/tests/` with smoke tests:
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: "{{ .Release.Name }}-test"
     annotations:
       "helm.sh/hook": test
   spec:
     containers:
     - name: test
       image: curlimages/curl
       command: ['curl', '-f', 'http://{{ .Release.Name }}/healthz']
     restartPolicy: Never
   ```
3. Run tests post-upgrade: `helm test myapp`.
4. Integrate into CI: diff on PR, test after merge.

---

## Architecture

### 25. Everything in One Namespace

**Severity:** High

**Description:** All applications, services, and workloads deployed into a single namespace (often `default`). No namespace-based separation between teams, environments, or risk tiers.

**Why it's dangerous:** No blast radius isolation. A misconfigured ResourceQuota, NetworkPolicy, or RBAC change affects all workloads simultaneously. No ability to give teams scoped access. Cluster upgrades that drain a namespace evict everything at once.

**Detection:**
```bash
# Count pods per namespace
kubectl get pods -A --no-headers | awk '{print $1}' | sort | uniq -c | sort -rn

# Flag if default namespace has significant workloads
kubectl get all -n default
```

**Remediation:**
1. Define namespace strategy: by team, by environment, or by tier (match cluster tier model).
2. Migrate workloads incrementally — start with the highest-risk or most independent services.
3. Apply ResourceQuotas, LimitRanges, NetworkPolicies, and RBAC per namespace from the start.
4. Use namespace-scoped RoleBindings to give teams access to their namespaces only.
5. Label namespaces for Pod Security Standards enforcement.

---

### 26. Sidecar Overuse

**Severity:** Medium

**Description:** Every pod carries multiple sidecars (log shippers, metrics exporters, secret agents, proxies) injected by multiple mutating webhooks. Pod specs balloon to 5–8 containers.

**Why it's dangerous:** Each sidecar adds resource overhead (often 50–100m CPU, 64–128Mi memory) multiplied across all pods. Pod startup time increases. Debugging which container is failing becomes complex. Sidecar failures can block main container readiness.

**Detection:**
```bash
kubectl get pods -A -o json | jq -r '
  .items[] |
  select((.spec.containers | length) > 3) |
  [.metadata.namespace, .metadata.name, (.spec.containers | length | tostring)] | join("\t")
' | sort -t$'\t' -k3 -rn | head -20
```

**Remediation:**
1. Audit which sidecars are truly necessary vs. injected by default.
2. Disable auto-injection on namespaces or pods that do not need the sidecar:
   ```yaml
   # Disable Istio sidecar injection per pod
   annotations:
     sidecar.istio.io/inject: "false"
   ```
3. Prefer node-level agents (DaemonSet) for log collection over per-pod sidecar injection.
4. Consolidate metrics exporters — if Prometheus scrapes the main app, a separate exporter sidecar may be redundant.
5. Set resource limits on all sidecars explicitly.

---

### 27. ConfigMaps for Large or Binary Data

**Severity:** Medium

**Description:** ConfigMaps used to store large datasets (>1MB), binary content, or data that changes frequently (e.g., ML model weights, large certificates, dynamic feature flag JSON).

**Why it's dangerous:** ConfigMaps have a 1MB etcd size limit per object. Large ConfigMaps inflate etcd size, slow watches, and degrade API server performance. etcd is not designed as a blob store.

**Detection:**
```bash
kubectl get configmaps -A -o json | jq -r '
  .items[] |
  . as $cm |
  (.data // {} | to_entries | map(.value | length) | add // 0) as $size |
  select($size > 500000) |
  [$cm.metadata.namespace, $cm.metadata.name, ($size | tostring)] | join("\t")
'
```

**Remediation:**
1. Move large static assets to object storage (S3, GCS, MinIO) and mount via init container or fetch at startup.
2. For large configuration files, store in a dedicated ConfigMap per file and mount only what is needed.
3. For binary data, use a PVC or object storage — not ConfigMaps.
4. For dynamic configuration, use a config management system (Consul, etcd application-level, LaunchDarkly) rather than K8s ConfigMaps.
5. Break large monolithic ConfigMaps into smaller, purpose-scoped ones.

---

## Quick Reference: Severity Matrix

| Anti-Pattern | Severity | Primary Risk |
|---|---|---|
| No resource requests/limits | Critical | Node instability, OOMKill cascade |
| `:latest` image tag | Critical | Non-reproducible deploys |
| Bare Pods | Critical | No self-healing |
| Privileged containers | Critical | Node compromise |
| `cluster-admin` for apps | Critical | Cluster takeover via RCE |
| Limits 4x+ requests | High | Node overcommit, noisy neighbor |
| VPA+HPA same metric | High | Scaling oscillation |
| No readiness probe | High | Traffic during initialization |
| Multiple processes per container | High | Hidden failures, no isolation |
| No PDB | High | Full outage during node drain |
| kubectl edit in prod | High | GitOps drift, untracked changes |
| No NetworkPolicies | High | Lateral movement |
| Env conditionals in Helm | High | Staging != production |
| Copy-paste templates | High | Inconsistent security patches |
| Skipping upgrade testing | High | Silent regressions |
| One namespace for everything | High | No blast radius isolation |
| Liveness = readiness probe | Medium | Restart loops on dependency failure |
| initContainers for app config | Medium | Stale config on pod restart |
| Secrets in env vars | Medium | Credential leakage |
| Default ServiceAccount | Medium | Accumulated RBAC exposure |
| No pod anti-affinity | Medium | All replicas on one node |
| Orphaned PVCs/LBs | Medium | Silent cost accumulation |
| No label strategy | Medium | Broken selectors, no cost allocation |
| No values.schema.json | Medium | Silent misconfiguration |
| Sidecar overuse | Medium | Resource bloat, startup latency |
| ConfigMaps for large data | Medium | etcd pressure, 1MB limit |
| No ResourceQuotas | Medium | Unbounded resource consumption |
