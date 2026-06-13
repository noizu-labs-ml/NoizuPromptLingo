# Kubernetes Storage Patterns

Guide to designing, provisioning, and operating persistent storage on Kubernetes: StorageClass design, CSI drivers, StatefulSet patterns, backup, and anti-patterns.

---

## 1. StorageClass Design

A well-designed StorageClass is the foundation of predictable storage behavior. Every production cluster should define at least two classes: one for performance-sensitive workloads and one for bulk/archival.

### Key Parameters

| Parameter | Recommended Value | Rationale |
|-----------|------------------|-----------|
| `volumeBindingMode` | `WaitForFirstConsumer` | Delays binding until pod is scheduled; ensures PV is on the same node as the pod |
| `reclaimPolicy` | `Retain` (prod) / `Delete` (dev) | `Retain` protects against accidental deletion; `Delete` keeps dev clusters clean |
| `allowVolumeExpansion` | `true` | Allows PVC resize without re-provisioning; requires CSI driver support |

### OpenEBS LVM StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: openebs-lvmpv
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: local.csi.openebs.io
parameters:
  storage: lvm
  volgroup: "data-vg"           # LVM volume group name on each node
  fstype: ext4
  shared: "no"                  # RWO only; set "yes" for experimental RWX
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

### OpenEBS LVM — Thin-provisioned (dev/staging)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: openebs-lvmpv-thin
provisioner: local.csi.openebs.io
parameters:
  storage: lvm
  volgroup: "data-vg"
  thinProvision: "yes"          # Over-provision; do not use in prod
  fstype: ext4
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

### Longhorn StorageClass (replicated)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn
provisioner: driver.longhorn.io
parameters:
  numberOfReplicas: "3"
  staleReplicaTimeout: "30"
  fromBackup: ""
  fsType: ext4
  dataLocality: best-effort     # prefer scheduling replica on same node as pod
reclaimPolicy: Retain
volumeBindingMode: Immediate    # Longhorn does not support WaitForFirstConsumer
allowVolumeExpansion: true
```

---

## 2. Storage Driver Comparison

| Driver | IOPS Characteristics | HA / Replication | Complexity | Best For |
|--------|---------------------|-----------------|------------|----------|
| **OpenEBS LVM** | Native LVM speed (near-bare-metal) | None — local only | Low | Single-node or zonal workloads; databases needing raw I/O |
| **OpenEBS Mayastor** | NVMe-oF speeds via io_uring | 2-3 replicas, synchronous | Medium | High-throughput databases requiring HA (Postgres, MySQL) |
| **Longhorn** | ~60-70% of local I/O (replication overhead) | 1-3 replicas, async-ish | Medium | General RWO workloads; good UI; built-in backup to S3 |
| **Rook-Ceph (RBD)** | Good for RWO; tunable via crush rules | Strong HA, multi-zone | High | Enterprise clusters; RWO + RWX mix; large teams |
| **Rook-Ceph (CephFS)** | Lower than RBD; metadata overhead | Strong HA | High | Shared filesystems, RWX at scale |
| **Local PV (hostPath)** | Fastest possible — bare metal | None | Very Low | Single-node dev, ephemeral CI runners |
| **NFS (external)** | Network-bound; highly variable | Depends on NFS server | Low-Medium | Legacy workloads; cheap RWX; not latency-sensitive |

### Decision Flowchart

```
Need RWX (ReadWriteMany)?
  ├─ Yes → Need high throughput? → Yes → Rook-Ceph CephFS
  │                              → No  → NFS or Longhorn (RWX experimental)
  └─ No (RWO)
       Need HA (multi-node)?
         ├─ Yes → Need NVMe speeds? → Yes → Mayastor
         │                          → No  → Longhorn (simple) or Rook-Ceph RBD (enterprise)
         └─ No (local/zonal OK)
              → OpenEBS LVM (preferred) or Local PV
```

---

## 3. StatefulSet Volume Patterns

### volumeClaimTemplates — Automatic per-pod PVC

StatefulSets use `volumeClaimTemplates` to create a PVC for each pod replica automatically. The PVC name is `{template-name}-{statefulset-name}-{ordinal}`.

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: db
spec:
  serviceName: postgres
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:16
          env:
            - name: PGDATA
              value: /var/lib/postgresql/data/pgdata
          volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
            - name: wal
              mountPath: /var/lib/postgresql/wal
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: [ReadWriteOnce]
        storageClassName: openebs-lvmpv
        resources:
          requests:
            storage: 50Gi
    - metadata:
        name: wal
        annotations:
          # separate volume for WAL archives — reduces I/O contention
      spec:
        accessModes: [ReadWriteOnce]
        storageClassName: openebs-lvmpv
        resources:
          requests:
            storage: 10Gi
```

This creates:
- `data-postgres-0`, `data-postgres-1`, `data-postgres-2`
- `wal-postgres-0`, `wal-postgres-1`, `wal-postgres-2`

PVCs are **not deleted** when the StatefulSet is deleted — intentional for data safety.

### Resize a StatefulSet PVC

StatefulSet `volumeClaimTemplates` cannot be updated in-place. To resize:

```bash
# 1. Patch each PVC individually
kubectl patch pvc data-postgres-0 -n db \
  -p '{"spec":{"resources":{"requests":{"storage":"100Gi"}}}}'

# 2. The CSI driver will expand online (if allowVolumeExpansion: true)
# Watch for FileSystemResizePending condition to clear
kubectl get pvc data-postgres-0 -n db -w
```

---

## 4. PV Pre-Provisioning with claimRef

For local storage (OpenEBS LVM, hostPath), use `claimRef` to deterministically bind a PV to a specific PVC. This prevents the scheduler from binding the wrong PV to a PVC if sizes match.

```yaml
# Pre-create the PV
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-data-node1
  labels:
    node: k8s-node-1
    app: postgres
spec:
  capacity:
    storage: 50Gi
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: openebs-lvmpv
  volumeMode: Filesystem
  # claimRef pins this PV to exactly one PVC
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-postgres-0
    namespace: db
  local:
    path: /k8-volumes/db/postgres-0
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values: [k8s-node-1]
```

```yaml
# PVC — will bind exclusively to the pre-provisioned PV above
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-postgres-0
  namespace: db
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: openebs-lvmpv
  volumeName: postgres-data-node1    # optional explicit binding
  resources:
    requests:
      storage: 50Gi
```

---

## 5. Backup and Restore

### Velero + CSI Volume Snapshots

Velero is the de-facto standard for Kubernetes backup. Combined with CSI VolumeSnapshot support, it produces crash-consistent backups without mounting the volume.

#### VolumeSnapshotClass

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: openebs-lvm-snapshot
  labels:
    velero.io/csi-volumesnapshot-class: "true"   # Velero uses this label
driver: local.csi.openebs.io
deletionPolicy: Retain
```

#### Velero Schedule (daily backup, 7-day retention)

```yaml
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: daily-db-backup
  namespace: velero
spec:
  schedule: "0 2 * * *"      # 2am daily
  useOwnerReferencesInBackup: false
  template:
    includedNamespaces: [db, app]
    excludedResources:
      - events
      - events.events.k8s.io
    snapshotVolumes: true
    volumeSnapshotLocations: [default]
    storageLocation: s3-default
    ttl: 168h                 # 7 days
    labelSelector:
      matchLabels:
        backup: "true"        # opt-in via label
    hooks:
      resources:
        - name: postgres-pre-backup
          includedNamespaces: [db]
          labelSelector:
            matchLabels:
              app: postgres
          pre:
            - exec:
                container: postgres
                command:
                  - /bin/bash
                  - -c
                  - psql -U postgres -c "SELECT pg_start_backup('velero-$(date +%s)', true)"
                timeout: 60s
          post:
            - exec:
                container: postgres
                command:
                  - /bin/bash
                  - -c
                  - psql -U postgres -c "SELECT pg_stop_backup()"
                timeout: 60s
```

#### Manual on-demand backup

```bash
velero backup create prod-snapshot-$(date +%Y%m%d) \
  --include-namespaces db,app \
  --snapshot-volumes \
  --wait

# Restore into a different namespace (disaster recovery)
velero restore create --from-backup prod-snapshot-20260101 \
  --namespace-mappings db:db-restored \
  --include-namespaces db
```

### Longhorn Built-in Backup

If using Longhorn, its built-in backup controller eliminates the need for Velero for volume data:

```yaml
apiVersion: longhorn.io/v1beta2
kind: RecurringJob
metadata:
  name: daily-snapshot
  namespace: longhorn-system
spec:
  cron: "0 3 * * *"
  task: backup
  groups: [default]
  retain: 7
  concurrency: 2
  labels:
    backup-type: scheduled
```

---

## 6. Ephemeral Volumes

Ephemeral volumes are deleted when the pod is removed. Use them for scratch space, injected config, and secrets.

| Type | Use Case | Size Limit | Notes |
|------|----------|-----------|-------|
| `emptyDir` | Scratch space, inter-container share | Node disk/RAM | `medium: Memory` for tmpfs |
| `configMap` | Inject config files | ~1MB (etcd limit) | Read-only by default |
| `secret` | Inject credentials | ~1MB (etcd limit) | Stored in tmpfs on node |
| `projected` | Combine secret + configMap + SA token | ~1MB | Single mountPath for multiple sources |
| `ephemeral` (CSI) | Large scratch with StorageClass | StorageClass limit | Provisioned per-pod via CSI |

#### projected volume — combine sources

```yaml
volumes:
  - name: config-and-creds
    projected:
      sources:
        - configMap:
            name: app-config
            items:
              - key: config.yaml
                path: config.yaml
        - secret:
            name: app-secrets
            items:
              - key: DATABASE_URL
                path: database_url
        - serviceAccountToken:
            path: token
            expirationSeconds: 3600
            audience: vault
```

#### emptyDir with memory backing (high-speed cache)

```yaml
volumes:
  - name: cache
    emptyDir:
      medium: Memory
      sizeLimit: 512Mi    # prevents runaway memory usage
```

#### Generic ephemeral volume (large scratch via CSI)

```yaml
volumes:
  - name: scratch
    ephemeral:
      volumeClaimTemplate:
        spec:
          accessModes: [ReadWriteOnce]
          storageClassName: openebs-lvmpv-thin
          resources:
            requests:
              storage: 10Gi
```

---

## 7. Anti-Patterns

| Anti-pattern | Problem | Fix |
|--------------|---------|-----|
| **RWX when RWO suffices** | RWX drivers (CephFS, NFS) have higher latency and complexity | Audit access patterns; most apps only need one writer — use RWO |
| **No backup strategy** | First disk failure = permanent data loss | Implement Velero + snapshots or Longhorn recurring backups on day 1 |
| **Ignoring reclaim policy** | PV deleted when PVC deleted in dev, then promoted to prod config | Set `Retain` in prod StorageClasses explicitly; add a deletion confirmation webhook |
| **Immediate binding on local volumes** | PV bound before pod scheduled; pod lands on wrong node | Use `WaitForFirstConsumer` for all local storage classes |
| **Single large PVC for multiple concerns** | I/O contention; can't resize one concern independently | Separate PVCs per concern (data, WAL, logs, cache) |
| **No volume size monitoring** | Disk-full causes pod crash, not graceful degradation | Alert on `kubelet_volume_stats_used_bytes / kubelet_volume_stats_capacity_bytes > 0.85` |
| **hostPath in production** | Not portable, bypasses StorageClass policies, security risk | Replace with Local PV or OpenEBS LVM; use hostPath only for DaemonSets with node access needs |
| **Longhorn with `Immediate` binding on constrained clusters** | Replica placement can't follow pod scheduling | Set `dataLocality: strict-local` or switch to OpenEBS LVM for local-only workloads |
| **Over-provisioning with thin pools silently** | Thin pool fills → all volumes stall simultaneously | Monitor thin pool usage; set `thinProvision: "yes"` only in dev |
| **No pre-flight PV readiness check** | StatefulSet stuck in Pending silently | Add a readiness gate or use init container to verify mount before app starts |

---

## Reference

- [OpenEBS LVM CSI](https://github.com/openebs/lvm-localpv)
- [OpenEBS Mayastor](https://mayastor.gitbook.io/)
- [Longhorn Documentation](https://longhorn.io/docs/)
- [Rook-Ceph](https://rook.io/docs/rook/latest/)
- [Velero](https://velero.io/docs/)
- [CSI Volume Snapshots](https://kubernetes.io/docs/concepts/storage/volume-snapshots/)
- [Kubernetes Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [Ephemeral Volumes](https://kubernetes.io/docs/concepts/storage/ephemeral-volumes/)
