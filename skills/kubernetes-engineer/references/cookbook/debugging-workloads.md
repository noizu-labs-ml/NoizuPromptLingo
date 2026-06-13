# Recipe: Debugging Workloads

**Difficulty:** Beginner
**Prerequisites:** kubectl, basic understanding of Pods, Deployments, Services, and Nodes

---

## How to Use This Guide

Each section covers one failure mode: **symptoms**, **diagnostic commands**, **root causes**, and **fixes**. Work top to bottom within a section. Stop when you find the root cause.

---

## Failure Mode 1: Pending Pods

### Symptoms

- `kubectl get pods` shows `Pending` for more than 30 seconds
- Pod never starts, no container events logged

### Diagnostic Commands

```bash
# Step 1: Describe the pod — look at the Events section at the bottom
kubectl describe pod <pod-name> -n <namespace>

# Step 2: Check node capacity and allocatable resources
kubectl describe nodes | grep -A 5 "Allocated resources"

# Step 3: Check for taints on nodes that might repel the pod
kubectl describe nodes | grep -i taint

# Step 4: Check if a PVC is unbound (if the pod uses storage)
kubectl get pvc -n <namespace>
```

### Root Causes and Fixes

| Root Cause | Event Message | Fix |
|-----------|--------------|-----|
| Insufficient CPU/memory | `0/3 nodes are available: Insufficient cpu` | Lower resource requests or add nodes |
| No nodes match nodeSelector/affinity | `0/3 nodes are available: node(s) didn't match node affinity` | Fix affinity rules or label a node |
| Node has a taint | `0/3 nodes are available: node(s) had taint` | Add toleration to pod spec or remove taint |
| PVC unbound | `pod has unbound immediate PersistentVolumeClaims` | Check StorageClass, PV availability |
| Image pull secret missing | `pod has unbound secrets` | Create imagePullSecret and reference in pod spec |
| Pod Security Standards violation | `pods "x" is forbidden` | Fix security context (drop capabilities, set runAsNonRoot) |

---

## Failure Mode 2: CrashLoopBackOff

### Symptoms

- `kubectl get pods` shows `CrashLoopBackOff` or `Error`
- Pod restarts repeatedly with increasing backoff (10s, 20s, 40s...)

### Diagnostic Commands

```bash
# Step 1: Get logs from the current (crashed) container
kubectl logs <pod-name> -n <namespace>

# Step 2: Get logs from the PREVIOUS container run (the one that actually crashed)
kubectl logs <pod-name> -n <namespace> --previous

# Step 3: Describe the pod — check Last State exit code and reason
kubectl describe pod <pod-name> -n <namespace>
# Look for: Last State > Exit Code, Reason (e.g., OOMKilled, Error, Completed)

# Step 4: Try running the container interactively to debug startup
kubectl run debug-shell --rm -it \
  --image=<same-image> \
  --restart=Never \
  -n <namespace> \
  -- /bin/sh
```

### Root Causes and Fixes

| Exit Code | Reason | Fix |
|-----------|--------|-----|
| 1 | Application error on startup | Check app logs — missing env var, bad config |
| 127 | Command not found | Check `command`/`args` in pod spec |
| 137 | OOMKilled | Increase memory limit or fix memory leak |
| 139 | Segfault | Application bug — check logs, update image |
| 0 | Completed (not a daemon) | Set correct `command` or change `restartPolicy` |

```bash
# If startup fails due to missing env var — list what's actually set
kubectl exec <pod-name> -n <namespace> -- env | sort

# If config file is wrong — view mounted ConfigMap
kubectl get configmap <name> -n <namespace> -o yaml
```

---

## Failure Mode 3: ImagePullBackOff

### Symptoms

- `kubectl get pods` shows `ImagePullBackOff` or `ErrImagePull`
- Container never starts

### Diagnostic Commands

```bash
# Step 1: Describe pod — the Events section shows the exact pull error
kubectl describe pod <pod-name> -n <namespace>
# Look for: Failed to pull image, unauthorized, not found

# Step 2: Verify the image name and tag are correct
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].image}'

# Step 3: Check if imagePullSecret is present in the namespace
kubectl get secret -n <namespace> | grep docker
kubectl get serviceaccount default -n <namespace> -o yaml | grep imagePullSecret
```

### Root Causes and Fixes

| Root Cause | Event Message | Fix |
|-----------|--------------|-----|
| Wrong image name/tag | `manifest unknown` | Fix image tag — check registry for available tags |
| Registry authentication | `unauthorized: authentication required` | Create docker-registry secret and add to SA or pod spec |
| Registry unreachable | `dial tcp: connection refused` | Check network policy, node internet access |
| Image doesn't exist | `not found` | Verify image was built and pushed |

```bash
# Create a docker-registry secret
kubectl create secret docker-registry my-registry-secret \
  --docker-server=registry.example.com \
  --docker-username=<user> \
  --docker-password=<token> \
  -n <namespace>

# Patch the default ServiceAccount to use it automatically
kubectl patch serviceaccount default -n <namespace> \
  -p '{"imagePullSecrets": [{"name": "my-registry-secret"}]}'
```

---

## Failure Mode 4: Service Not Reachable

### Symptoms

- `curl http://my-service.<namespace>.svc.cluster.local` times out or gets connection refused from inside the cluster
- Application logs show connection errors to another service

### Diagnostic Commands

```bash
# Step 1: Verify the Service exists and has the right selector
kubectl get svc <service-name> -n <namespace> -o yaml
# Check: spec.selector must match pod labels

# Step 2: Check that Endpoints are populated (pods matched by selector)
kubectl get endpoints <service-name> -n <namespace>
# If ENDPOINTS shows <none>, the selector doesn't match any pods

# Step 3: Check pod labels match service selector
kubectl get pods -n <namespace> --show-labels

# Step 4: Test DNS from inside the cluster
kubectl run dns-test --rm -it --image=busybox --restart=Never -n <namespace> \
  -- nslookup <service-name>.<namespace>.svc.cluster.local

# Step 5: Test connectivity directly to pod IP
kubectl get pod <pod-name> -n <namespace> -o wide   # get pod IP
kubectl run conn-test --rm -it --image=busybox --restart=Never -n <namespace> \
  -- wget -qO- http://<pod-ip>:<container-port>

# Step 6: Check NetworkPolicy — is traffic blocked?
kubectl get networkpolicy -n <namespace>
```

### Root Causes and Fixes

| Root Cause | Symptom | Fix |
|-----------|---------|-----|
| Selector mismatch | Endpoints shows `<none>` | Fix `spec.selector` in Service to match pod labels |
| Wrong port | Endpoints populated but connection refused | Check `targetPort` matches container port |
| NetworkPolicy blocking | Direct pod IP works, Service doesn't | Add NetworkPolicy rule to allow traffic |
| Pod not ready | Endpoints exist but pod not in rotation | Fix readinessProbe |

---

## Failure Mode 5: OOMKilled

### Symptoms

- Pod restarts with exit code 137
- `kubectl describe pod` shows `Reason: OOMKilled` in Last State

### Diagnostic Commands

```bash
# Step 1: Confirm OOMKill
kubectl describe pod <pod-name> -n <namespace>
# Look for: Last State > Reason: OOMKilled

# Step 2: Check current memory limit
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].resources}'

# Step 3: Check actual memory usage before it crashes (if metrics-server is installed)
kubectl top pod <pod-name> -n <namespace>

# Step 4: Check node-level OOM events
kubectl describe node <node-name> | grep -i oom
dmesg | grep -i "killed process"   # on the node via ssh
```

### Fixes

```bash
# Increase memory limit (patch in place)
kubectl patch deployment <name> -n <namespace> \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"<container>","resources":{"limits":{"memory":"512Mi"}}}]}}}}'

# Or edit the values.yaml for your Helm chart and upgrade
```

Root causes beyond "increase the limit": memory leak in application code, unbounded cache growth, large file processing without streaming. Profile the application — don't just increase limits indefinitely.

---

## Failure Mode 6: Node NotReady

### Symptoms

- `kubectl get nodes` shows a node as `NotReady`
- Pods on that node are being evicted or stuck in `Terminating`

### Diagnostic Commands

```bash
# Step 1: Describe the node — check Conditions section
kubectl describe node <node-name>
# Look for: MemoryPressure, DiskPressure, PIDPressure, NetworkUnavailable

# Step 2: Check node events
kubectl get events --field-selector involvedObject.name=<node-name> --sort-by='.lastTimestamp'

# Step 3: SSH to the node and check kubelet
ssh <node-name>
sudo systemctl status kubelet
sudo journalctl -u kubelet -n 100 --no-pager

# Step 4: Check disk usage on the node
df -h
du -sh /var/lib/docker/*   # or /var/lib/containerd

# Step 5: Check if the container runtime is healthy
sudo crictl ps
sudo crictl info
```

### Root Causes and Fixes

| Condition | Root Cause | Fix |
|-----------|-----------|-----|
| `DiskPressure` | Node disk full (images, logs, eviction data) | Clean up unused images: `crictl rmi --prune`; increase disk; adjust eviction thresholds |
| `MemoryPressure` | Node running out of RAM | Evict low-priority pods; add memory to node; reduce pod memory usage |
| `NetworkUnavailable` | CNI plugin failed | Restart CNI daemonset; check CNI plugin logs |
| kubelet crash | kubelet process died | `systemctl restart kubelet`; check logs for config errors |
| Clock skew | NTP not synced | `chronyc tracking`; restart chronyd |

```bash
# Force evict stuck Terminating pods after confirming node is gone
kubectl delete pod <pod-name> -n <namespace> --grace-period=0 --force
```

---

## Quick Reference: Diagnostic Cheat Sheet

```bash
# All pods across all namespaces with status
kubectl get pods -A | grep -v Running

# Recent events cluster-wide sorted by time
kubectl get events -A --sort-by='.lastTimestamp' | tail -30

# Resource usage (requires metrics-server)
kubectl top pods -A --sort-by=memory

# Exec into a running pod
kubectl exec -it <pod> -n <ns> -- /bin/sh

# Temporary debug pod with network tools
kubectl run netshoot --rm -it --image=nicolaka/netshoot -n <ns> -- bash

# Copy file from pod for inspection
kubectl cp <ns>/<pod>:/path/to/file /tmp/local-copy
```
