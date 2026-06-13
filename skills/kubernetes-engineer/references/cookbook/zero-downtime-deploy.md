# Recipe: Zero-Downtime Deployments

**Difficulty:** Beginner
**Prerequisites:** Deployment basics, kubectl, basic understanding of readiness probes

---

## Goal

Roll out a new container image (or config change) without dropping a single in-flight request. By the end of this recipe you will have a Deployment with a tuned rolling update strategy, a readiness probe that gates traffic, a PodDisruptionBudget that protects against simultaneous evictions, and graceful shutdown hooks that drain connections before the pod exits.

---

## Background

Kubernetes performs rolling updates by default, but the defaults are often wrong for production:

- `maxSurge: 25%` and `maxUnavailable: 25%` mean up to 25% of pods can disappear before new ones are ready. Under load this causes dropped connections.
- Without a readiness probe, Kubernetes sends traffic to a pod the moment it starts — before the app has finished initializing.
- Without `preStop` + `terminationGracePeriodSeconds`, the kubelet sends `SIGTERM` and then immediately starts pulling the pod from the Service endpoints — new requests can still arrive while shutdown is in progress.

The recipe below fixes all three problems.

---

## Key Concepts

| Concept | What It Does |
|---------|-------------|
| `maxSurge` | Extra pods allowed above `replicas` during a rollout |
| `maxUnavailable` | Pods allowed to be unavailable during a rollout |
| `readinessProbe` | Gates traffic — pod only enters Service endpoints when this passes |
| `livenessProbe` | Restarts the container if the app hangs |
| `preStop` hook | Runs before `SIGTERM` — use to sleep so the endpoint is removed first |
| `terminationGracePeriodSeconds` | Total time the kubelet waits before sending `SIGKILL` |
| PodDisruptionBudget | Limits how many pods of a set can be voluntarily disrupted at once |

---

## Full Working Example

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: production
  labels:
    app: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  strategy:
    type: RollingUpdate
    rollingUpdate:
      # Never go below replica count during a rollout
      maxUnavailable: 0
      # Allow one extra pod above replica count during a rollout
      maxSurge: 1
  template:
    metadata:
      labels:
        app: my-app
    spec:
      # Give the app 60 seconds to finish in-flight requests after SIGTERM
      terminationGracePeriodSeconds: 60
      containers:
        - name: my-app
          image: my-registry/my-app:v2.0.0
          ports:
            - containerPort: 8080
          # Readiness probe: pod enters Service endpoints only when this passes
          readinessProbe:
            httpGet:
              path: /healthz/ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 3
            successThreshold: 1
          # Liveness probe: restart if the app hangs
          livenessProbe:
            httpGet:
              path: /healthz/live
              port: 8080
            initialDelaySeconds: 15
            periodSeconds: 10
            failureThreshold: 3
          lifecycle:
            preStop:
              exec:
                # Sleep long enough for kube-proxy to propagate endpoint removal.
                # This runs BEFORE SIGTERM, so in-flight requests land safely.
                command: ["/bin/sh", "-c", "sleep 10"]
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "256Mi"
---
# pdb.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app-pdb
  namespace: production
spec:
  # At least 2 of 3 pods must be available during voluntary disruptions
  # (node drain, cluster upgrades, manual evictions)
  minAvailable: 2
  selector:
    matchLabels:
      app: my-app
```

---

## Step-by-Step Rollout

### 1. Apply the PDB first

```bash
kubectl apply -f pdb.yaml
kubectl get pdb my-app-pdb -n production
```

The PDB must exist before a drain or upgrade attempts to evict pods.

### 2. Deploy (or update the image tag)

```bash
# Apply the full deployment
kubectl apply -f deployment.yaml

# Or patch just the image tag
kubectl set image deployment/my-app my-app=my-registry/my-app:v2.1.0 -n production
```

### 3. Watch the rollout

```bash
kubectl rollout status deployment/my-app -n production --timeout=5m
```

This blocks until the rollout completes or the timeout is reached. Exit code is non-zero on failure — safe to use in CI.

---

## Verification

```bash
# Confirm all pods are Running and Ready
kubectl get pods -n production -l app=my-app

# Confirm the new image is running
kubectl describe deployment/my-app -n production | grep Image

# Check rollout history
kubectl rollout history deployment/my-app -n production

# Confirm PDB status (Disruptions Allowed should be >= 1)
kubectl get pdb -n production
```

---

## Rollback

```bash
# Roll back to the previous revision
kubectl rollout undo deployment/my-app -n production

# Roll back to a specific revision
kubectl rollout undo deployment/my-app -n production --to-revision=3
```

---

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| No `preStop` sleep | Requests 502 during rollout | Add `preStop: sleep 10` |
| `terminationGracePeriodSeconds` too short | In-flight requests killed mid-response | Increase to match p99 request duration + 10s buffer |
| Readiness probe too aggressive | Pod flaps in/out of endpoints | Increase `failureThreshold` or `periodSeconds` |
| PDB `minAvailable` too high | Node drains hang forever | Ensure `minAvailable < replicas` |
| `maxUnavailable: 1` with only 1 replica | Full downtime during rollout | Set `maxUnavailable: 0` and `maxSurge: 1` |

---

## Connection Draining Summary

The complete shutdown sequence with these settings:

1. Pod is marked for termination (eviction, rollout, or deletion)
2. `preStop` hook runs (`sleep 10`) — endpoints are removed from kube-proxy during this window
3. `SIGTERM` is sent to the container process — app should stop accepting new connections and drain existing ones
4. App has `terminationGracePeriodSeconds - preStop duration` remaining to finish in-flight work
5. `SIGKILL` is sent if the process has not exited by the deadline
