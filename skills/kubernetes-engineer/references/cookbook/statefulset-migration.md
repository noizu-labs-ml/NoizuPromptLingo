# Recipe: StatefulSet Data Migration

**Difficulty:** Advanced
**Prerequisites:** StatefulSet, PersistentVolumes, storage drivers, kubectl, your CSI driver's snapshot capability

---

## Goal

Move data from one PersistentVolume to another — either changing StorageClass, migrating to a new node pool, or rescaling storage — without data loss and with a tested rollback path.

---

## When to Use This Recipe

| Scenario | Use This Recipe |
|----------|----------------|
| Migrating from Longhorn to OpenEBS LVM | Yes |
| Resizing a PVC (CSI supports online expansion) | No — use `kubectl patch pvc` instead |
| Moving StatefulSet pods to a different node or zone | Yes |
| Changing access mode (RWO → RWX) | Yes |
| Recovering from a corrupted volume | Yes |

---

## Pre-Migration Checklist

- [ ] Snapshot or backup of source PV exists and has been verified
- [ ] Target StorageClass supports the required access mode
- [ ] Enough free storage on target nodes
- [ ] StatefulSet `updateStrategy` understood — ordered rollout expected
- [ ] Rollback procedure documented and tested in staging

---

## Migration Strategies

### Strategy A: Snapshot-Restore (preferred when CSI snapshots are available)

```bash
# 1. Create a VolumeSnapshot of the source PVC
cat <<EOF | kubectl apply -f -
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: my-db-snapshot
  namespace: production
spec:
  volumeSnapshotClassName: csi-hostpath-snapclass   # Use your driver's class
  source:
    persistentVolumeClaimName: data-my-db-0
EOF

# 2. Wait for snapshot to be ready
kubectl wait volumesnapshot/my-db-snapshot -n production \
  --for=jsonpath='{.status.readyToUse}'=true --timeout=5m

# 3. Create a new PVC from the snapshot
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-db-0-new
  namespace: production
spec:
  storageClassName: openebs-lvmpv          # Target StorageClass
  dataSource:
    name: my-db-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
EOF
```

### Strategy B: rsync (when snapshots are unavailable)

```bash
# 1. Scale down the StatefulSet to quiesce writes
kubectl scale statefulset my-db -n production --replicas=0

# 2. Launch a migration pod with both PVCs mounted
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pv-migrator
  namespace: production
spec:
  restartPolicy: Never
  containers:
    - name: rsync
      image: instrumentisto/rsync-ssh:latest
      command:
        - rsync
        - -avz
        - --delete
        - /source/
        - /target/
      volumeMounts:
        - name: source
          mountPath: /source
        - name: target
          mountPath: /target
  volumes:
    - name: source
      persistentVolumeClaim:
        claimName: data-my-db-0            # Old PVC
    - name: target
      persistentVolumeClaim:
        claimName: data-my-db-0-new        # New PVC
EOF

# 3. Wait for rsync to complete
kubectl wait pod/pv-migrator -n production --for=condition=Succeeded --timeout=30m
kubectl logs pv-migrator -n production

# 4. Clean up migration pod
kubectl delete pod pv-migrator -n production
```

---

## PV Rebinding with claimRef

To bind a new PV deterministically to the StatefulSet's expected PVC name:

```bash
# 1. Delete the old PVC (will not delete PV if reclaim policy is Retain)
kubectl delete pvc data-my-db-0 -n production

# 2. Patch the new PV to bind only to the expected PVC name
kubectl patch pv <new-pv-name> -p '{
  "spec": {
    "claimRef": {
      "namespace": "production",
      "name": "data-my-db-0"
    }
  }
}'

# 3. Rename the new PVC to the expected name
# (if created under a different name during migration)
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-db-0
  namespace: production
spec:
  storageClassName: openebs-lvmpv
  volumeName: <new-pv-name>
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
EOF
```

---

## Ordered Rollout and Verification

```bash
# Scale back up — StatefulSet brings pods up in order (0, 1, 2...)
kubectl scale statefulset my-db -n production --replicas=3

# Watch ordered startup
kubectl rollout status statefulset/my-db -n production

# Verify data integrity (application-specific — example for PostgreSQL)
kubectl exec -it my-db-0 -n production -- psql -U postgres -c "SELECT count(*) FROM my_table;"

# Check PVC binding
kubectl get pvc -n production -l app=my-db
```

---

## Rollback Strategy

```bash
# 1. Scale down StatefulSet
kubectl scale statefulset my-db -n production --replicas=0

# 2. Swap PVC back to original (if retained)
#    Re-patch claimRef on the original PV to bind it back to data-my-db-0

# 3. Scale up
kubectl scale statefulset my-db -n production --replicas=3
```

Keep the source PV in `Retain` state until you have confirmed the migrated data is correct and the application has been running successfully for at least one full business cycle.
