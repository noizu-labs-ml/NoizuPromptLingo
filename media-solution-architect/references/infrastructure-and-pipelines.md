# Self-Hosted Streaming Infrastructure: Technical Reference

> Comprehensive reference for building containerized media pipelines, origin servers, transcoding
> infrastructure, and CDN economics on self-hosted Kubernetes.

---

## Table of Contents

1. [Containerized Media Pipelines (K8s)](#1-containerized-media-pipelines-k8s)
2. [Storage Backends for Media](#2-storage-backends-for-media)
3. [Origin Server Software](#3-origin-server-software)
4. [Live Transcoding Pipeline Architecture](#4-live-transcoding-pipeline-architecture)
5. [FFmpeg vs GStreamer](#5-ffmpeg-vs-gstreamer)
6. [GPU Infrastructure for Transcoding](#6-gpu-infrastructure-for-transcoding)
7. [Monitoring and Observability for Streaming](#7-monitoring-and-observability-for-streaming)
8. [Self-Hosted vs Cloud CDN Cost Analysis](#8-self-hosted-vs-cloud-cdn-cost-analysis)

---

## 1. Containerized Media Pipelines (K8s)

### 1.1 NVIDIA GPU Operator Setup

The NVIDIA GPU Operator automates management of all GPU software components in Kubernetes:
drivers, container toolkit, device plugin, DCGM monitoring, and node feature discovery.

**Installation (Helm):**

```yaml
# values-gpu-operator.yaml
operator:
  defaultRuntime: containerd

devicePlugin:
  enabled: true
  config:
    name: time-slicing-config
    default: "any"

driver:
  enabled: true
  repoConfig:
    configMapName: repo-config
  licensingConfig:
    configMapName: licensing-config

dcgmExporter:
  enabled: true

migManager:
  enabled: false  # Enable only for A100/H100

nodeFeatureDiscovery:
  enabled: true
```

```bash
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update
helm install gpu-operator nvidia/gpu-operator \
  --namespace gpu-operator --create-namespace \
  -f values-gpu-operator.yaml
```

### 1.2 GPU Scheduling: Time-Slicing vs MPS vs MIG

| Strategy | Mechanism | Isolation | Best For | GPU Support |
|----------|-----------|-----------|----------|-------------|
| **Time-Slicing** | Temporal multiplexing (round-robin) | None (no memory isolation) | Transcoding (low GPU utilization per stream) | All NVIDIA GPUs |
| **MPS** | CUDA API proxy (parallel kernel execution) | Partial (memory limits configurable) | AI inference, mixed workloads | Kepler+ (GTX 700+) |
| **MIG** | Hardware partitioning (dedicated cores + memory) | Full (fault isolation, QoS) | Multi-tenant, guaranteed SLAs | A100, A30, H100 only |

**Recommendation for transcoding:** Time-slicing. Transcoding workloads typically use 5-15% of GPU compute
per stream (NVENC/NVDEC are fixed-function hardware, not CUDA cores), making time-slicing the natural
fit. You can typically slice a T4 or L4 into 4-8 replicas without noticeable quality degradation.

**Time-Slicing ConfigMap:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: time-slicing-config
  namespace: gpu-operator
data:
  # Default for any GPU type
  any: |-
    version: v1
    flags:
      migStrategy: none
    sharing:
      timeSlicing:
        resources:
          - name: nvidia.com/gpu
            replicas: 4
  # Per-GPU overrides
  NVIDIA-A2: |-
    version: v1
    sharing:
      timeSlicing:
        resources:
          - name: nvidia.com/gpu
            replicas: 2
  NVIDIA-L4: |-
    version: v1
    sharing:
      timeSlicing:
        resources:
          - name: nvidia.com/gpu
            replicas: 4
  NVIDIA-T4: |-
    version: v1
    sharing:
      timeSlicing:
        resources:
          - name: nvidia.com/gpu
            replicas: 4
```

**MIG Configuration (A100/H100 only):**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mig-config
  namespace: gpu-operator
data:
  config.yaml: |-
    version: v1
    flags:
      migStrategy: mixed
    sharing:
      timeSlicing:
        resources:
          - name: nvidia.com/gpu
            replicas: 1
          - name: nvidia.com/mig-1g.10gb
            replicas: 2
          - name: nvidia.com/mig-2g.20gb
            replicas: 1
```

**Hybrid approach (production H100/A100):** Create MIG instances for hardware isolation,
then apply time-slicing within each MIG instance for additional density. This gives both
fault isolation and high utilization.

### 1.3 Node Selectors and Taints for GPU Nodes

```yaml
# Label GPU nodes
# kubectl label nodes <node> node-type=gpu nvidia.com/gpu.product=NVIDIA-L4

# Taint GPU nodes to prevent non-GPU workloads from scheduling
# kubectl taint nodes <node> nvidia.com/gpu=true:NoSchedule

---
# Deployment with GPU node affinity and toleration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: transcoder
  namespace: media
spec:
  replicas: 3
  selector:
    matchLabels:
      app: transcoder
  template:
    metadata:
      labels:
        app: transcoder
    spec:
      tolerations:
        - key: nvidia.com/gpu
          operator: Exists
          effect: NoSchedule
      nodeSelector:
        node-type: gpu
      containers:
        - name: transcoder
          image: registry.example.com/transcoder:v1.2.0
          resources:
            limits:
              nvidia.com/gpu: 1
              memory: "4Gi"
              cpu: "4"
            requests:
              nvidia.com/gpu: 1
              memory: "4Gi"
              cpu: "4"
          env:
            - name: NVIDIA_DRIVER_CAPABILITIES
              value: "video,compute,utility"
            - name: NVIDIA_VISIBLE_DEVICES
              value: "all"
```

### 1.4 Horizontal Scaling with KEDA (Queue-Based Autoscaling)

KEDA translates application events (queue depth, Prometheus metrics) into HPA scale commands,
with faster reaction times than the default HPA (which polls every 15-30 seconds).

```yaml
# KEDA ScaledObject for VOD transcoding queue
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: transcoder-scaler
  namespace: media
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: transcoder
  pollingInterval: 10       # Check every 10 seconds
  cooldownPeriod: 120       # Wait 2 min before scaling down
  minReplicaCount: 1        # Always have 1 warm
  maxReplicaCount: 12       # Ceiling based on GPU node capacity
  triggers:
    - type: redis
      metadata:
        address: redis.media.svc.cluster.local:6379
        listName: transcode:pending
        listLength: "5"     # Scale up when > 5 items per pod
    - type: prometheus
      metadata:
        serverAddress: http://prometheus.observability.svc.cluster.local:9090
        metricName: transcode_queue_depth
        threshold: "5"
        query: >-
          sum(transcode_jobs_pending{namespace="media"})
---
# Alternative: Redis list-based scaling (simpler, no Prometheus dependency)
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: redis-auth
  namespace: media
spec:
  secretTargetRef:
    - parameter: password
      name: redis-credentials
      key: password
```

**KEDA tuning parameters for transcoding:**

| Parameter | Recommended | Rationale |
|-----------|-------------|-----------|
| `pollingInterval` | 5-15s | Fast enough to react to queue spikes |
| `cooldownPeriod` | 120-300s | Prevent thrashing; GPU init overhead is ~2-5s |
| `minReplicaCount` | 1-2 | Keep warm pods for immediate dequeue |
| `maxReplicaCount` | Based on GPU slots | Don't exceed physical GPU capacity |
| `listLength` | 3-10 | Items per pod before scaling; lower = faster reaction |

### 1.5 Job-Based vs DaemonSet Transcoding

**VOD Batch Processing (Kubernetes Jobs):**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: transcode-asset-abc123
  namespace: media
  labels:
    asset-id: abc123
    transcode-profile: hls-abr
spec:
  backoffLimit: 3
  ttlSecondsAfterFinished: 3600  # Auto-clean after 1 hour
  template:
    spec:
      restartPolicy: OnFailure
      tolerations:
        - key: nvidia.com/gpu
          operator: Exists
          effect: NoSchedule
      containers:
        - name: transcoder
          image: registry.example.com/transcoder:v1.2.0
          command:
            - /bin/sh
            - -c
            - |
              ffmpeg -y \
                -hwaccel cuda \
                -hwaccel_output_format cuda \
                -i /input/source.mp4 \
                -filter_complex \
                  "[0:v]split=3[v1][v2][v3]; \
                   [v1]scale_cuda=1920:1080[v1out]; \
                   [v2]scale_cuda=1280:720[v2out]; \
                   [v3]scale_cuda=854:480[v3out]" \
                -map "[v1out]" -c:v:0 h264_nvenc -preset p5 -b:v:0 6000k -maxrate:v:0 8000k \
                -map "[v2out]" -c:v:1 h264_nvenc -preset p5 -b:v:1 3000k -maxrate:v:1 4000k \
                -map "[v3out]" -c:v:2 h264_nvenc -preset p5 -b:v:2 1500k -maxrate:v:2 2000k \
                -map a:0 -c:a aac -b:a 128k \
                -var_stream_map "v:0,a:0 v:1,a:0 v:2,a:0" \
                -master_pl_name master.m3u8 \
                -f hls \
                -hls_time 6 \
                -hls_list_size 0 \
                -hls_segment_filename "/output/stream_%v/segment_%05d.ts" \
                /output/stream_%v/playlist.m3u8
          resources:
            limits:
              nvidia.com/gpu: 1
              memory: "8Gi"
              cpu: "4"
          volumeMounts:
            - name: input
              mountPath: /input
            - name: output
              mountPath: /output
      volumes:
        - name: input
          persistentVolumeClaim:
            claimName: asset-abc123-source
        - name: output
          persistentVolumeClaim:
            claimName: transcoded-output
```

**Live Transcoding (DaemonSet):**

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: live-transcoder
  namespace: media
spec:
  selector:
    matchLabels:
      app: live-transcoder
  template:
    metadata:
      labels:
        app: live-transcoder
    spec:
      tolerations:
        - key: nvidia.com/gpu
          operator: Exists
          effect: NoSchedule
      containers:
        - name: transcoder
          image: registry.example.com/live-transcoder:v1.2.0
          command: ["/app/transcode.sh"]
          env:
            - name: INGEST_URL
              valueFrom:
                configMapKeyRef:
                  name: stream-config
                  key: ingestUrl
            - name: OUTPUT_BASE
              value: "/output"
          resources:
            limits:
              nvidia.com/gpu: 1
              memory: "8Gi"
              cpu: "4"
          volumeMounts:
            - name: output
              mountPath: /output
            - name: encoding-profiles
              mountPath: /etc/transcoder/profiles
          livenessProbe:
            exec:
              command:
                - /app/healthcheck.sh
            initialDelaySeconds: 30
            periodSeconds: 10
            failureThreshold: 3
      volumes:
        - name: output
          hostPath:
            path: /mnt/media/live-output
            type: DirectoryOrCreate
        - name: encoding-profiles
          configMap:
            name: encoding-profiles
```

**Why DaemonSet for live:** A crashed FFmpeg pod takes 5-10 seconds to restart in Kubernetes,
creating a blackout for viewers. DaemonSets ensure the transcoding process runs on every GPU
node, and custom liveness probes can trigger faster restarts. For truly mission-critical live
pipelines, consider running the FFmpeg process under a supervisor (supervisord, s6-overlay)
inside the container for sub-second restarts independent of Kubernetes.

### 1.6 ConfigMaps for Encoding Profiles

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: encoding-profiles
  namespace: media
data:
  # ABR ladder for HLS output
  hls-abr-profile.json: |
    {
      "profiles": [
        {"name": "1080p", "width": 1920, "height": 1080, "bitrate": 6000, "maxrate": 8000, "bufsize": 12000, "preset": "p5"},
        {"name": "720p",  "width": 1280, "height": 720,  "bitrate": 3000, "maxrate": 4000, "bufsize": 6000,  "preset": "p5"},
        {"name": "480p",  "width": 854,  "height": 480,  "bitrate": 1500, "maxrate": 2000, "bufsize": 3000,  "preset": "p6"},
        {"name": "360p",  "width": 640,  "height": 360,  "bitrate": 800,  "maxrate": 1000, "bufsize": 1500,  "preset": "p6"},
        {"name": "240p",  "width": 426,  "height": 240,  "bitrate": 400,  "maxrate": 600,  "bufsize": 900,   "preset": "p7"}
      ],
      "audio": {"codec": "aac", "bitrate": 128, "channels": 2, "sample_rate": 48000},
      "hls": {"segment_duration": 6, "playlist_size": 0}
    }
  # Low-latency profile
  llat-hls-profile.json: |
    {
      "profiles": [
        {"name": "1080p", "width": 1920, "height": 1080, "bitrate": 8000, "maxrate": 10000, "bufsize": 16000, "preset": "p4"},
        {"name": "720p",  "width": 1280, "height": 720,  "bitrate": 4500, "maxrate": 5500,  "bufsize": 9000,  "preset": "p4"}
      ],
      "audio": {"codec": "aac", "bitrate": 128, "channels": 2, "sample_rate": 48000},
      "hls": {"segment_duration": 1, "playlist_size": 5, "llat": true}
    }
  # HEVC quality-optimized for archival
  hevc-archive-profile.json: |
    {
      "profiles": [
        {"name": "4k-hevc", "width": 3840, "height": 2160, "bitrate": 15000, "maxrate": 20000, "bufsize": 30000, "preset": "p6", "codec": "hevc_nvenc", "rc": "vbr", "cq": 25},
        {"name": "1080p-hevc", "width": 1920, "height": 1080, "bitrate": 5000, "maxrate": 7000, "bufsize": 10000, "preset": "p6", "codec": "hevc_nvenc", "rc": "vbr", "cq": 28}
      ],
      "audio": {"codec": "aac", "bitrate": 192, "channels": 2, "sample_rate": 48000},
      "container": "mp4"
    }
```

### 1.7 Persistent Volume Considerations for Media Workloads

Media workloads are I/O-heavy with distinct access patterns:
- **Live segments:** Small files (100KB-2MB), written sequentially, read many times, short-lived (minutes)
- **VOD transcoding:** Large files (1-50GB), sequential read/write, moderate concurrency
- **Origin serving:** Many small random reads (segments), high throughput critical

**OpenEBS LVM StorageClass for media:**

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: media-lvm-nvme
provisioner: local.csi.openebs.io
parameters:
  storageType: "LVM"
  fsType: "xfs"
  # XFS preferred for media: excellent sequential I/O, supports reflink for CoW
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: media-lvm-hdd
provisioner: local.csi.openebs.io
parameters:
  storageType: "LVM"
  fsType: "xfs"
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

**Filesystem recommendations:**
- **XFS:** Best for media workloads (sequential I/O, reflink support, no fragmentation issues with large files)
- **ext4:** Acceptable alternative; disable `data=journal` for performance
- **tmpfs/ramdisk:** For live segments on origin servers (segments are transient; RAM eliminates disk I/O)

**PVC for transcoding working storage:**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: transcode-workspace
  namespace: media
spec:
  storageClassName: media-lvm-nvme
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
```

### 1.8 Network Policies for Media Traffic

```yaml
# Allow ingest from encoders, deny everything else
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingest
  namespace: media
spec:
  podSelector:
    matchLabels:
      app: ingest-server
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: encoders
      ports:
        - port: 1935  # RTMP
          protocol: TCP
        - port: 6060  # SRT
          protocol: TCP
        - port: 5000  # WebRTC
          protocol: UDP
---
# Allow transcoders to read from ingest and write to origin
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-transcoder-traffic
  namespace: media
spec:
  podSelector:
    matchLabels:
      app: transcoder
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: health-checker
      ports:
        - port: 8080
          protocol: TCP
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: ingest-server
      ports:
        - port: 1935
    - to:
        - podSelector:
            matchLabels:
              app: origin-server
      ports:
        - port: 80
        - port: 443
    - to:
        - podSelector:
            matchLabels:
              app: redis
      ports:
        - port: 6379
---
# Allow origin to serve segments to CDN/edge
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-origin-egress
  namespace: media
spec:
  podSelector:
    matchLabels:
      app: origin-server
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: edge
        - podSelector:
            matchLabels:
              app: cdn-pull
      ports:
        - port: 80
          protocol: TCP
        - port: 443
          protocol: TCP
```

### 1.9 Complete Transcoding Deployment Manifest

```yaml
---
# Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: media
  labels:
    name: media
    pod-security.kubernetes.io/enforce: baseline
---
# Redis for job queue
apiVersion: apps/v1
kind: Deployment
metadata:
  name: transcode-queue
  namespace: media
spec:
  replicas: 1
  selector:
    matchLabels:
      app: transcode-queue
  template:
    metadata:
      labels:
        app: transcode-queue
    spec:
      containers:
        - name: redis
          image: redis:7.4.2-alpine
          ports:
            - containerPort: 6379
          resources:
            limits:
              memory: "512Mi"
              cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: transcode-queue
  namespace: media
spec:
  selector:
    app: transcode-queue
  ports:
    - port: 6379
      targetPort: 6379
---
# Transcoder deployment (GPU)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: transcoder
  namespace: media
spec:
  replicas: 2
  selector:
    matchLabels:
      app: transcoder
  template:
    metadata:
      labels:
        app: transcoder
    spec:
      tolerations:
        - key: nvidia.com/gpu
          operator: Exists
          effect: NoSchedule
      nodeSelector:
        node-type: gpu
      containers:
        - name: transcoder
          image: registry.example.com/transcoder:v1.2.0
          ports:
            - containerPort: 8080
              name: metrics
          env:
            - name: NVIDIA_DRIVER_CAPABILITIES
              value: "video,compute,utility"
            - name: REDIS_URL
              value: "redis://transcode-queue:6379"
            - name: OUTPUT_BASE
              value: "/output"
            - name: PROFILE
              value: "hls-abr"
          resources:
            limits:
              nvidia.com/gpu: 1
              memory: "8Gi"
              cpu: "4"
            requests:
              nvidia.com/gpu: 1
              memory: "8Gi"
              cpu: "4"
          volumeMounts:
            - name: output
              mountPath: /output
            - name: encoding-profiles
              mountPath: /etc/transcoder/profiles
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 15
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /readyz
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
      volumes:
        - name: output
          persistentVolumeClaim:
            claimName: transcoded-output
        - name: encoding-profiles
          configMap:
            name: encoding-profiles
---
# KEDA autoscaler
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: transcoder-scaler
  namespace: media
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: transcoder
  pollingInterval: 10
  cooldownPeriod: 120
  minReplicaCount: 1
  maxReplicaCount: 12
  triggers:
    - type: redis
      metadata:
        address: transcode-queue.media.svc.cluster.local:6379
        listName: transcode:pending
        listLength: "5"
```

---

## 2. Storage Backends for Media

### 2.1 Object Storage (MinIO / S3-Compatible)

MinIO is the de facto self-hosted S3-compatible object store. It bypasses kernel caching
for direct-to-disk streaming, uses goroutines for massive concurrency, and supports
multipart upload for large video files.

**MinIO for media segments:**

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: minio-media
  namespace: storage
spec:
  serviceName: minio-media
  replicas: 4  # Erasure coding requires 4+ nodes
  selector:
    matchLabels:
      app: minio-media
  template:
    metadata:
      labels:
        app: minio-media
    spec:
      containers:
        - name: minio
          image: minio/minio:RELEASE.2025-04-22T22-12-54Z
          args: ["server", "--console-address", ":9001", "/data"]
          env:
            - name: MINIO_ROOT_USER
              valueFrom:
                secretKeyRef:
                  name: minio-credentials
                  key: root-user
            - name: MINIO_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: minio-credentials
                  key: root-password
          ports:
            - containerPort: 9000
              name: api
            - containerPort: 9001
              name: console
          resources:
            limits:
              memory: "16Gi"
              cpu: "8"
          volumeMounts:
            - name: data
              mountPath: /data
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        storageClassName: media-lvm-hdd
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 2Ti
```

**Bucket design for media:**

```
media-assets/                    # VOD content library
  ├── source/                    # Original uploaded files
  │   └── {asset-id}/
  │       └── source.mp4
  ├── transcoded/                # ABR renditions
  │   └── {asset-id}/
  │       ├── master.m3u8
  │       ├── 1080p/
  │       │   ├── playlist.m3u8
  │       │   ├── segment_00001.ts
  │       │   └── ...
  │       ├── 720p/
  │       └── 480p/
  └── thumbnails/                # Poster frames
      └── {asset-id}/
          ├── poster.jpg
          └── thumb_{n}.jpg

live-streams/                    # Live segments (auto-expiring)
  ├── {stream-key}/
  │   ├── master.m3u8
  │   ├── 1080p/
  │   │   ├── playlist.m3u8
  │   │   ├── seg_000001.ts
  │   │   └── ...
  │   └── 720p/
  └── dvr/                       # DVR recordings
      └── {stream-key}/
          └── {date}/
              └── recording.mp4
```

**Lifecycle policies for live segments:**

```json
{
  "Rules": [
    {
      "ID": "ExpireLiveSegments",
      "Status": "Enabled",
      "Filter": {"Prefix": "live-streams/"},
      "Expiration": {"Days": 1},
      "NoncurrentVersionExpiration": {"NoncurrentDays": 0}
    },
    {
      "ID": "ExpireDVRArchival",
      "Status": "Enabled",
      "Filter": {"Prefix": "live-streams/dvr/"},
      "Expiration": {"Days": 30}
    }
  ]
}
```

### 2.2 Block Storage for Hot Cache and Working Files

| Storage Class | Backend | Use Case | Performance |
|---------------|---------|----------|-------------|
| `media-lvm-nvme` | OpenEBS LVM on NVMe SSD | Transcode workspace, origin hot cache | ~3 GB/s read, ~2 GB/s write, ~500K IOPS |
| `media-lvm-ssd` | OpenEBS LVM on SATA SSD | Database, queue, metadata | ~550 MB/s read, ~500K IOPS |
| `media-lvm-hdd` | OpenEBS LVM on HDD | Object storage backend, VOD archive | ~200 MB/s sequential read |

**Why local LVM for media:** Network-attached storage (NFS, Ceph, Longhorn) adds latency
and bandwidth overhead on the data path. For media workloads where the pod is co-located
with storage, local LVM provides zero-overhead throughput equal to bare metal.

### 2.3 NFS/Shared Filesystem for Multi-Origin Access

When multiple origin servers need to serve the same content (horizontal scaling), a shared
filesystem is required. Options:

| Solution | Read Throughput | Write Throughput | Complexity | Best For |
|----------|----------------|-----------------|------------|----------|
| NFSv4 | ~1 GB/s | ~500 MB/s | Low | Small clusters, simple setups |
| CephFS | ~2 GB/s | ~1 GB/s | High | Large clusters, built-in replication |
| GlusterFS | ~800 MB/s | ~400 MB/s | Medium | Distributed environments |
| MinIO gateway | ~2 GB/s | ~1.5 GB/s | Low | When MinIO already deployed |

**Recommendation:** For self-hosted streaming, use MinIO as the shared content store
with origin servers pulling directly from it. This avoids maintaining a separate NFS
layer and provides built-in lifecycle management.

### 2.4 Storage Tiering Strategy

```
[Tier 0: NVMe RAM Disk]    Live segments (current + 2 previous)
        |                       10-50 GB per origin node
        v                       Retention: minutes
[Tier 1: NVMe SSD]           Origin hot cache, transcode workspace
        |                       500 GB - 2 TB per node
        v                       Retention: hours to days
[Tier 2: HDD/SSD Mix]        MinIO object storage backend
        |                       10-100 TB total
        v                       Retention: weeks to months (live DVR)
[Tier 3: HDD/Archive]         Cold storage, VOD archive
        |                       50+ TB total
        v                       Retention: years
[Tier 4: Tape/Cloud]          Disaster recovery, compliance archive
                              Off-site, retrieval in hours
```

### 2.5 IOPS and Throughput Requirements

| Workload | Read Pattern | Write Pattern | Throughput Needed | IOPS Needed |
|----------|-------------|---------------|-------------------|-------------|
| Live segment ingest | N/A | Sequential, 2MB/s per stream | 20-100 MB/s (20-50 streams) | Low |
| VOD transcode input | Sequential read | N/A | 50-200 MB/s per transcode job | Low |
| VOD transcode output | N/A | Sequential write | 20-80 MB/s per stream | Low |
| Origin serving (live) | Random read, many small files | N/A | 200 MB/s - 2 GB/s (depends on viewers) | High (10K+) |
| Origin serving (VOD) | Sequential read, moderate size | N/A | 500 MB/s - 5 GB/s | Moderate |
| DVR recording | Sequential read/write | Sequential | 20-100 MB/s | Low |

**Key insight:** Media workloads are overwhelmingly sequential I/O. NVMe SSDs provide
massive sequential bandwidth but IOPS are rarely the bottleneck. A single NVMe drive
(~3 GB/s) can serve ~500 concurrent 1080p HLS streams (avg 6 Mbps = 0.75 MB/s each).

### 2.6 Storage Sizing Calculations

**Per-hour storage at various quality levels:**

| Resolution | Codec | Bitrate | GB/Hour | Multiplier (ABR) |
|-----------|-------|---------|---------|-------------------|
| 4K (2160p) | H.265 | 15 Mbps | 6.75 | 1x |
| 1080p | H.264 | 6 Mbps | 2.70 | 1x |
| 1080p | H.265 | 4 Mbps | 1.80 | 1x |
| 720p | H.264 | 3 Mbps | 1.35 | 0.5x |
| 480p | H.264 | 1.5 Mbps | 0.68 | 0.25x |
| 360p | H.264 | 0.8 Mbps | 0.36 | 0.13x |
| 240p | H.264 | 0.4 Mbps | 0.18 | 0.07x |

**Full ABR ladder per hour (H.264):** ~5.3 GB (1080p + 720p + 480p + 360p + 240p + 128kbps audio)

**Sizing examples:**

| Content Library | Storage Needed (H.264 ABR) | With 20% Overhead |
|----------------|---------------------------|-------------------|
| 100 hours of VOD | 530 GB | 636 GB |
| 1,000 hours of VOD | 5.3 TB | 6.4 TB |
| 10,000 hours of VOD | 53 TB | 63.6 TB |
| 24/7 live + 30-day DVR (1 stream) | 3.8 TB | 4.6 TB |
| 24/7 live + 30-day DVR (10 streams) | 38 TB | 45.6 TB |

**HLS segment overhead:** Each 6-second segment has ~40 bytes of playlist overhead.
For a 2-hour movie with 6-second segments across 5 quality levels:
- 1,200 segments per quality level x 5 = 6,000 segments
- Segment file overhead (inodes, directory entries): negligible vs content

### 2.7 Content-Addressed Storage for Deduplication

For large VOD libraries, content-addressed storage (CAS) can reduce storage by 30-60%
depending on content overlap (e.g., multiple edits of the same source, subtitle variants).

**Approach:** Hash each segment by content (SHA-256), store once, reference by hash.
This is particularly effective for:
- Multiple bitrate renditions of the same source (no benefit -- different content)
- Multiple edits/cuts of the same source (segments from shared portions are identical)
- Regional variants with shared video but different audio/subtitle tracks

**Implementation with MinIO:**

```bash
# Use MinIO's S3-compatible API with content hash as key
# Upload: hash the segment, use hash as object key
# Serve: maintain a manifest mapping playlist position -> content hash
mc alias set media http://minio-media.storage.svc:9000 $ACCESS_KEY $SECRET_KEY
mc cp segment_00001.ts media/cas/ab12cd34ef56...
```

### 2.8 Lifecycle Policies

| Content Type | Retention | Tier After | Delete After |
|-------------|-----------|-----------|-------------|
| Live HLS segments | Current + 3 previous | N/A (overwrite) | 1 hour |
| Live DVR recordings | 7-30 days | HDD after 7 days | 30 days |
| VOD source files | Permanent | HDD after 30 days | Never |
| VOD transcoded renditions | Permanent | HDD after 90 days | Never |
| Thumbnails | Permanent | HDD after 30 days | Never |
| Transcode temp files | Duration of job | N/A | After job completion |
| Failed transcode artifacts | N/A | N/A | 24 hours |

---

## 3. Origin Server Software

### 3.1 Nginx as Media Origin

Nginx with the RTMP module is the most common self-hosted media origin. For production,
compile from source (distribution packages are frequently outdated).

**Optimal HLS/DASH configuration:**

```nginx
worker_processes auto;
worker_rlimit_nofile 100000;

events {
    worker_connections 4096;
    # For high-concurrency segment serving
    multi_accept on;
    accept_mutex off;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;

    # Media-specific optimizations
    output_buffers 1 2m;
    postpone_output 1460;

    #gzip off;  # Never gzip pre-compressed media segments

    open_file_cache max=10000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;

    # Rate limiting for abuse prevention
    limit_req_zone $binary_remote_addr zone=segment:10m rate=100r/s;

    server {
        listen 80;
        server_name origin.example.com;

        root /var/www/media;

        # HLS serving
        location ~ \.m3u8$ {
            types { application/vnd.apple.mpegurl m3u8; }
            add_header Cache-Control no-cache;
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods "GET, OPTIONS";

            # Rate limit
            limit_req zone=segment burst=20 nodelay;
        }

        location ~ \.ts$ {
            types { video/mp2t ts; }
            add_header Cache-Control "public, max-age=86400";
            add_header Access-Control-Allow-Origin *;
        }

        location ~ \.mpd$ {
            types { application/dash+xml mpd; }
            add_header Cache-Control no-cache;
            add_header Access-Control-Allow-Origin *;
        }

        # Health check
        location /healthz {
            return 200 'ok';
            add_header Content-Type text/plain;
        }

        # Block direct access to source files
        location ~ /\.(?!well-known) { deny all; }
        location ~ \.mp4$ {
            # Only serve MP4 through controlled endpoints
            deny all;
        }
    }
}

# RTMP ingest (requires nginx-rtmp-module)
rtmp {
    server {
        listen 1935;
        chunk_size 4096;

        application live {
            live on;
            # Push to transcoders
            push rtmp://transcoder-0.media.svc.cluster.local:1935/live;
            push rtmp://transcoder-1.media.svc.cluster.local:1935/live;

            # Record for DVR
            record all;
            record_path /var/www/media/dvr;
            record_suffix -%Y-%m-%d_%H-%M-%S.flv;

            # HLS output
            hls on;
            hls_path /var/www/media/live;
            hls_fragment 6s;
            hls_playlist_length 60s;

            # Security
            allow publish 10.0.0.0/8;
            allow publish 172.16.0.0/12;
            deny publish all;
        }
    }
}
```

### 3.2 Caddy as Media Origin

Caddy provides automatic HTTPS and simpler configuration, but lacks native RTMP support.

```
origin.example.com {
    root * /var/www/media

    # HLS playlists
    @m3u8 path *.m3u8
    header @m3u8 Content-Type "application/vnd.apple.mpegurl"
    header @m3u8 Cache-Control "no-cache"
    header @m3u8 Access-Control-Allow-Origin "*"

    # HLS segments
    @ts path *.ts
    header @ts Content-Type "video/mp2t"
    header @ts Cache-Control "public, max-age=86400"
    header @ts Access-Control-Allow-Origin "*"

    # DASH manifests
    @mpd path *.mpd
    header @mpd Content-Type "application/dash+xml"
    header @mpd Cache-Control "no-cache"
    header @mpd Access-Control-Allow-Origin "*"

    file_server

    log {
        output file /var/log/caddy/media-access.log {
            roll_size 100mb
            roll_keep 10
        }
    }
}
```

### 3.3 Dedicated Media Servers

**Ant Media Server (Community Edition -- Apache 2.0):**

```yaml
# Kubernetes deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ant-media
  namespace: media
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ant-media
  template:
    metadata:
      labels:
        app: ant-media
    spec:
      containers:
        - name: ant-media
          image: nibiru7777/ant-media-server:v2.12.0
          ports:
            - containerPort: 5080  # HTTP
            - containerPort: 1935  # RTMP
            - containerPort: 5443  # WebRTC TLS
            - containerPort: 5000  # WebRTC UDP range start
          resources:
            limits:
              memory: "16Gi"
              cpu: "8"
```

Key features:
- WebRTC ultra-low latency (~0.5s end-to-end)
- Adaptive bitrate with automatic quality adjustment
- Recording to S3/MinIO
- Cluster mode for horizontal scaling
- REST API for stream management

### 3.4 Comparison Table: Origin/Media Servers

| Feature | Nginx+RTMP | Ant Media CE | Mist Server | Flussonic | Wowza | Nimble |
|---------|-----------|--------------|-------------|-----------|-------|--------|
| **License** | BSD-2 | Apache 2.0 | AGPL-3.0 | Commercial | Commercial | Commercial |
| **Cost** | Free | Free (Enterprise paid) | Free (paid support) | $1,500+/yr | $1,000+/yr | $200+/mo |
| **HLS Output** | Yes | Yes | Yes | Yes | Yes | Yes |
| **DASH Output** | Via module | Yes | Yes | Yes | Yes | Yes |
| **WebRTC** | No | Yes | Yes | Yes | Yes | No |
| **RTMP Ingest** | Yes | Yes | Yes | Yes | Yes | Yes |
| **SRT Ingest** | No | Yes | Yes | Yes | Yes | Yes |
| **Transcoding** | External (FFmpeg) | Built-in (CPU/GPU) | External | Built-in | Built-in | External |
| **DVR/Timeshift** | Manual | Yes | Yes | Yes | Yes | Yes |
| **GPU Accel** | External | NVENC/NVDEC | External | NVENC/NVDEC | NVENC/NVDEC | NVENC |
| **Cluster/Scale** | Manual | Built-in | Built-in | Built-in | Built-in | Manual |
| **REST API** | No | Yes | Yes | Yes | Yes | Yes |
| **Container** | Custom image | Official image | Official image | Official image | Official image | Official |
| **Web UI** | No | Yes | Yes | Yes | Yes | Yes |
| **Performance** | Excellent (static) | Very Good | Excellent | Excellent | Good | Excellent |
| **Best For** | Ingest + static origin | Interactive live | Lightweight origin | IPTV/Multi-channel | Enterprise live | High-density origin |

**Open-source origin alternatives:**

| Project | Description | Status | URL |
|---------|-------------|--------|-----|
| estreamer | Lightweight HLS/DASH packager | Active | github.com/mabrn/estreamer |
| nginx-rtmp-module | RTMP/HLS for nginx | Maintained | github.com/arut/nginx-rtmp-module |
| MediaMTX | RTSP/RTMP/HLS/SRT server (Go) | Very Active | github.com/bluenviron/mediamtx |
| SRS (Simple Realtime Server) | RTMP/HLS/WebRTC/SRT | Very Active | github.com/ossrs/srs |
| Janus Gateway | WebRTC gateway | Active | github.com/meetecho/janus-gateway |

**Recommendation matrix:**

| Use Case | Recommended Stack |
|----------|-------------------|
| Simple live streaming (RTMP in, HLS out) | Nginx + RTMP module + external FFmpeg transcoding |
| Interactive live (sub-second latency) | Ant Media Server (WebRTC) |
| High-density IPTV (100+ channels) | Flussonic or Mist Server |
| Cost-optimized VOD origin | Nginx/Caddy + MinIO |
| RTSP camera ingest + distribution | MediaMTX or SRS |

---

## 4. Live Transcoding Pipeline Architecture

### 4.1 End-to-End Pipeline

```
                    LIVE TRANSCODING PIPELINE
                    ========================

[Camera/Encoder]
      |
      | RTMP/SRT/RTSP
      v
[Ingest Server]         ← nginx-rtmp or Ant Media
      |
      | RTMP push
      v
[Transcoder Pool]       ← FFmpeg with NVENC, KEDA-scaled
      |                   One pod per channel (DaemonSet)
      |                   or batch Jobs for VOD
      v
[HLS Packager]          ← FFmpeg -f hls, or Bento4
      |                   Segments written to shared storage
      |
      v
[Origin Server]         ← Nginx serving from NVMe or MinIO
      |                   CORS headers, proper MIME types
      |
      v
[CDN / Edge]            ← Self-hosted (nginx cache) or Cloud (CF, Bunny)
      |                   Pull-based from origin
      |
      v
[Player]                ← hls.js, Shaka Player, video.js
      |                   ABR selection, buffer management
      v
[Viewer]
```

### 4.2 Pipeline Stage Details

**Stage 1: Ingest**

```bash
# RTMP ingest (most common for OBS, vMix, Wirecast)
ffmpeg -listen 1 -i rtmp://0.0.0.0:1935/live/stream_key \
  -c copy -f flv rtmp://transcoder:1935/live/stream_key

# SRT ingest (better for unreliable networks, lower latency)
ffmpeg -i srt://0.0.0.0:9000?mode=listener \
  -c copy -f mpegts udp://transcoder:5000
```

**Stage 2: Transcode (GPU-accelerated ABR ladder)**

```bash
ffmpeg \
  -hwaccel cuda \
  -hwaccel_output_format cuda \
  -i rtmp://ingest:1935/live/stream_key \
  -filter_complex \
    "[0:v]split=3[v1][v2][v3]; \
     [v1]scale_cuda=1920:1080[v1out]; \
     [v2]scale_cuda=1280:720[v2out]; \
     [v3]scale_cuda=854:480[v3out]" \
  -map "[v1out]" -c:v:0 h264_nvenc -preset p5 -b:v:0 6000k -maxrate:v:0 8000k \
    -bufsize:v:0 12000k -g 120 -keyint_min 120 \
  -map "[v2out]" -c:v:1 h264_nvenc -preset p5 -b:v:1 3000k -maxrate:v:1 4000k \
    -bufsize:v:1 6000k -g 120 -keyint_min 120 \
  -map "[v3out]" -c:v:2 h264_nvenc -preset p5 -b:v:2 1500k -maxrate:v:2 2000k \
    -bufsize:v:2 3000k -g 120 -keyint_min 120 \
  -map a:0 -c:a aac -b:a 128k -ar 48000 -ac 2 \
  -var_stream_map "v:0,a:0 v:1,a:0 v:2,a:0" \
  -master_pl_name master.m3u8 \
  -f hls \
  -hls_time 6 \
  -hls_list_size 10 \
  -hls_flags independent_segments \
  -hls_segment_filename "/output/stream_%v/seg_%05d.ts" \
  /output/stream_%v/playlist.m3u8
```

**Key parameters explained:**
- `-hwaccel cuda -hwaccel_output_format cuda`: Keep frames in GPU memory (avoid PCIe round-trips)
- `-g 120 -keyint_min 120`: Fixed GOP size for seamless ABR switching (120 frames = 4s at 30fps)
- `-hls_flags independent_segments`: Each segment starts with an IDR frame
- `-preset p5`: Medium quality/speed tradeoff on NVENC (p1=fastest, p7=best quality)

### 4.3 NVIDIA Triton Inference Server for ML-Based Encoding Optimization

Triton can enhance the transcoding pipeline with ML models for:

1. **Per-title encoding:** Analyze content complexity, select optimal bitrate ladder per asset
2. **Super-resolution:** Encode at lower resolution, upscale at the edge/client
3. **Artifact detection:** Monitor output quality in real-time
4. **Content-aware encoding:** Adjust encoding parameters scene-by-scene

**Architecture:**

```
[Transcoder] → [Quality Analyzer] → [Triton Inference] → [Parameter Adjuster]
                     |                      |
                     v                      v
              [Metrics Store]    [Model: per-title encoder]
                                 [Model: quality predictor]
                                 [Model: scene classifier]
```

**Triton deployment alongside transcoders:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: triton-encoding-optimizer
  namespace: media
spec:
  replicas: 1
  selector:
    matchLabels:
      app: triton
  template:
    metadata:
      labels:
        app: triton
    spec:
      tolerations:
        - key: nvidia.com/gpu
          operator: Exists
          effect: NoSchedule
      nodeSelector:
        node-type: gpu
      containers:
        - name: triton
          image: nvcr.io/nvidia/tritonserver:24.08-py3
          args: ["tritonserver", "--model-repository=/models"]
          ports:
            - containerPort: 8000  # HTTP
            - containerPort: 8001  # gRPC
            - containerPort: 8002  # Metrics
          resources:
            limits:
              nvidia.com/gpu: 1
              memory: "16Gi"
              cpu: "8"
          volumeMounts:
            - name: models
              mountPath: /models
      volumes:
        - name: models
          persistentVolumeClaim:
            claimName: triton-models
```

### 4.4 FFmpeg Pipeline vs GStreamer Pipeline

**FFmpeg pipeline approach (shell orchestration):**

```bash
#!/bin/bash
# Pipeline: ingest → transcode → package → push to origin
# Each stage is a separate process, connected via pipes or RTMP push

# Stage 1: Ingest (pull from source)
# Stage 2: Transcode (GPU-accelerated ABR ladder)
# Stage 3: Package (HLS segment generation)
# Stage 4: Push to origin (write to shared storage)

# All stages combined in a single FFmpeg process:
ffmpeg -hwaccel cuda \
  -i "rtmp://ingest:1935/live/${STREAM_KEY}" \
  -filter_complex "[0:v]split=3[v1][v2][v3]; ..." \
  -map ... -c:v h264_nvenc ... \
  -f hls -hls_time 6 ... \
  /output/stream_%v/playlist.m3u8
```

**GStreamer pipeline approach (programmatic):**

```python
#!/usr/bin/env python3
import gi
gi.require_version('Gst', '1.0')
from gi.require_version import 'Gst', '1.0'
from gi.repository import Gst, GLib

Gst.init(None)

pipeline = Gst.parse_launch(
    """
    rtmpsrc location=rtmp://ingest:1935/live/stream_key !
    flvdemux name=demux !
    queue !
    h264parse !
    nvh264dec !
    tee name=video_tee

    video_tee. ! queue ! nvvidconv !
      "video/x-raw(memory:NVMM),width=1920,height=1080" !
      nvh264enc bitrate=6000000 gop-size=120 preset=medium !
      h264parse ! queue name=q_1080

    video_tee. ! queue ! nvvidconv !
      "video/x-raw(memory:NVMM),width=1280,height=720" !
      nvh264enc bitrate=3000000 gop-size=120 preset=medium !
      h264parse ! queue name=q_720

    video_tee. ! queue ! nvvidconv !
      "video/x-raw(memory:NVMM),width=854,height=480" !
      nvh264enc bitrate=1500000 gop-size=120 preset=medium !
      h264parse ! queue name=q_480

    demux. ! queue ! aacparse ! tee name=audio_tee

    q_1080. ! mux_1080.
    q_720. ! mux_720.
    q_480. ! mux_480.

    audio_tee. ! queue ! mux_1080.
    audio_tee. ! queue ! mux_720.
    audio_tee. ! queue ! mux_480.

    mpegtsmux name=mux_1080 ! hlssink location=/output/1080p/seg_%05d.ts playlist-location=/output/1080p/playlist.m3u8 target-duration=6 max-files=10

    mpegtsmux name=mux_720 ! hlssink location=/output/720p/seg_%05d.ts playlist-location=/output/720p/playlist.m3u8 target-duration=6 max-files=10

    mpegtsmux name=mux_480 ! hlssink location=/output/480p/seg_%05d.ts playlist-location=/output/480p/playlist.m3u8 target-duration=6 max-files=10
    """
)

loop = GLib.MainLoop()
pipeline.set_state(Gst.State.PLAYING)

try:
    loop.run()
except KeyboardInterrupt:
    pass
finally:
    pipeline.set_state(Gst.State.NULL)
```

### 4.5 Failover and Redundancy

**Active-Active (recommended for live):**

```
                    ┌─── [Transcoder A] ─── [Origin A] ───┐
[Load Balancer] ────┤                                      ├─── [CDN/Edge]
                    └─── [Transcoder B] ─── [Origin B] ───┘
                    (both processing the same stream)

Synchronization:
  - Same input feed to both transcoders
  - GOP-aligned output (fixed -g and -keyint_min)
  - CDN alternates between origins
  - Client-side: hls.js failover on segment 404
```

**Active-Passive (simpler, acceptable for VOD):**

```
                    ┌─── [Transcoder A (active)] ─── [Origin] ─── [CDN]
[Ingest] ──────────┤
                    └─── [Transcoder B (standby)] ── (cold, ready)
                    (B takes over when A health check fails)
                    Failover time: 5-15 seconds
```

**Health check for live transcoders:**

```bash
#!/bin/bash
# healthcheck.sh -- verify transcoder is producing segments
SEGMENT_DIR="/output/stream_0"
MAX_AGE=30  # seconds

latest=$(find "$SEGMENT_DIR" -name "*.ts" -newer /tmp/health_marker -print -quit 2>/dev/null)
if [ -z "$latest" ]; then
  latest_segment_age=$(($(date +%s) - $(stat -c %Y "$SEGMENT_DIR"/seg_*.ts 2>/dev/null | tail -1)))
  if [ "$latest_segment_age" -gt "$MAX_AGE" ]; then
    echo "UNHEALTHY: No new segments for ${latest_segment_age}s"
    exit 1
  fi
fi
touch /tmp/health_marker
echo "OK"
exit 0
```

### 4.6 Latency Budget Breakdown

| Stage | Typical Latency | Optimized Latency | Notes |
|-------|----------------|-------------------|-------|
| Camera/Encoder | 100-500ms | 50-100ms | Use low-latency encoding mode |
| Network (ingest) | 50-200ms | 20-50ms | SRT preferred over RTMP |
| Transcode (GPU) | 100-500ms | 50-200ms | NVENC ~2x faster than CPU |
| Packaging (HLS) | 2-6s | 0.5-2s | Segment duration is the dominant factor |
| Origin response | 5-50ms | 5-20ms | NVMe or RAM-backed |
| CDN propagation | 50-200ms | 20-100ms | Pull-through cache |
| Player buffer | 3-10s | 0.5-3s | LL-HLS reduces this |
| **Total (standard HLS)** | **5.3-17s** | | |
| **Total (LL-HLS optimized)** | | **0.7-3.5s** | |
| **Total (WebRTC)** | | **0.1-0.5s** | No segment packaging |

**Latency reduction strategies:**
- Shorter segments (1-2s instead of 6s) at the cost of more HTTP requests
- CMAF/Low-Latency HLS (partial segments, blocking playlist reload)
- Chunked transfer encoding from origin
- WebRTC for sub-second latency (requires different stack entirely)
- SRT ingest instead of RTMP (reliable UDP, better over lossy networks)

### 4.7 Monitoring Points in the Pipeline

```
[Ingest] ─── M1: Ingest bitrate, frame drops, connection stability
    |
[Transcoder] ─── M2: GPU utilization, encode speed, queue depth
    |             M3: Output bitrate per rendition, segment duration variance
[Packager] ─── M4: Segment generation interval, GOP alignment
    |
[Origin] ─── M5: Request rate, response time, cache hit ratio
    |
[CDN] ─── M6: Cache hit ratio, bandwidth, request rate per PoP
    |
[Player] ─── M7: Buffer ratio, startup time, quality switches, rebuffering %
```

---

## 5. FFmpeg vs GStreamer

### 5.1 Architecture Comparison

| Aspect | FFmpeg | GStreamer |
|--------|--------|-----------|
| **Core model** | Filter graph (command-line) | Pipeline (programmatic) |
| **Primary interface** | CLI (`ffmpeg` command) | C/Python/Vala API |
| **Pipeline construction** | `-filter_complex` string | Code-based element linking |
| **Dynamic reconfiguration** | Limited (restart required) | Full (dynamic pads, runtime changes) |
| **Thread model** | Per-stream threads | Pipeline thread management |
| **Memory model** | Process-scoped | Plugin-scoped with negotiation |
| **Error handling** | Exit codes, log messages | Bus messages, signals, callbacks |
| **State management** | N/A (process lifecycle) | NULL → READY → PAUSED → PLAYING |

### 5.2 When to Use Each

**Use FFmpeg when:**
- VOD transcoding (batch jobs, one-shot conversions)
- Simple live transcoding (fixed ABR ladder, no runtime changes)
- CLI automation / scripting / cron jobs
- Quick format conversion or inspection
- Working with Kubernetes Jobs (process-per-task model)
- Team has stronger CLI/scripting skills than C/Python

**Use GStreamer when:**
- Building a custom media server (embedded in application)
- Dynamic pipelines (add/remove streams at runtime)
- Low-latency requirements (direct memory management)
- Complex real-time processing (live mixing, compositing)
- Need fine-grained error handling and recovery
- Building a commercial product with media as a core feature
- WebRTC or SFU (Selective Forwarding Unit) implementation

### 5.3 Performance Comparison

**H.264 transcoding (1080p, 6 Mbps, single stream):**

| Operation | FFmpeg (CPU) | FFmpeg (NVENC) | GStreamer (CPU) | GStreamer (NVENC) |
|-----------|-------------|----------------|-----------------|-------------------|
| Transcode (preset medium) | ~30 fps | ~200 fps | ~28 fps | ~195 fps |
| Transcode (preset fast) | ~55 fps | ~250 fps | ~50 fps | ~240 fps |
| Resolution downscale | +5% overhead | +2% overhead | +3% overhead | +1% overhead |
| 3-rendition ABR ladder | ~12 fps | ~120 fps | ~10 fps | ~110 fps |
| Memory usage (steady) | ~200 MB | ~350 MB | ~150 MB | ~300 MB |

**Notes:**
- NVENC performance is largely identical between FFmpeg and GStreamer (same hardware encoder)
- CPU transcoding is slightly faster in FFmpeg due to more optimized x264/x265 integration
- GStreamer has lower baseline memory usage due to streaming architecture
- Both can handle 24/7 live transcoding; FFmpeg is simpler to supervise, GStreamer offers better programmatic recovery

### 5.4 Plugin Ecosystems

**FFmpeg:**
- 400+ codecs and formats built-in
- Hardware acceleration: NVENC/NVDEC, QSV, VAAPI, VideoToolbox, AMF
- Filters: 300+ video filters, 100+ audio filters
- Third-party: Limited plugin architecture (mostly compile-time)
- Community: Massive (most widely used multimedia framework)

**GStreamer:**
- 200+ plugins in gst-plugins-{base,good,bad,ugly}
- Hardware acceleration: nvenc, nvdec, vaapi, qsv via plugin sets
- gst-plugins-rs (Rust plugins, modern and safe)
- Dynamic loading: Plugins loaded at runtime via `.so` files
- Commercial plugins: MainConcept, Fluendo, Centricular
- PDI (Plugin Development Interface) for custom elements

### 5.5 Hardware Acceleration Support

| Acceleration | FFmpeg | GStreamer | Notes |
|-------------|--------|-----------|-------|
| NVIDIA NVENC/NVDEC | `h264_nvenc`, `hevc_nvenc` | `nvh264enc`, `nvvh265enc` | Best support in both |
| NVIDIA AV1 NVENC | `av1_nvenc` | `nvav1enc` | L4, Ada generation |
| Intel QSV | `h264_qsv`, `hevc_qsv` | `qsvh264enc` | Intel Quick Sync |
| AMD AMF | `h264_amf`, `hevc_amf` | Limited | FFmpeg has better support |
| Apple VideoToolbox | `h264_videotoolbox` | `vtenc` | macOS only |
| VAAPI (Linux) | `h264_vaapi` | `vaapih264enc` | Open-source Linux GPU |
| CUDA decode | `-hwaccel cuda` | `nvv4l2decoder` | Both supported |

### 5.6 Stability for 24/7 Live Transcoding

| Aspect | FFmpeg | GStreamer |
|--------|--------|-----------|
| **Memory leaks** | Rare in recent versions (6.x) | Rare; Rust plugins eliminate class |
| **Crash recovery** | External (supervisord, systemd, K8s) | Internal (bus messages, state recovery) |
| **Uptime achievable** | Weeks to months (with supervision) | Weeks to months (with proper error handling) |
| **Restart time** | 2-5 seconds (cold process start) | 1-3 seconds (state management) |
| **Known failure modes** | Input discontinuity, codec bugs | Pipeline negotiation failures |
| **Monitoring** | Log parsing, exit codes | Structured bus messages, metrics |
| **Recommendation** | Simpler to operate, widely documented | More control, requires more expertise |

**Production recommendation for K8s:** Use FFmpeg for transcoding inside containers with
an external supervisor (s6-overlay or supervisord) for fast restarts. Use GStreamer if you
are building a custom media server application that needs dynamic pipeline management.

---

## 6. GPU Infrastructure for Transcoding

### 6.1 GPU Selection for Transcoding

| GPU | NVENC Sessions | NVDEC Sessions | VRAM | TDP | AV1 Encode | Used Price (2026) |
|-----|---------------|----------------|------|-----|------------|-------------------|
| **T4** | 38 (1080p30) | 38 | 16 GB | 70W | No | $400-600 |
| **A10** | ~50 | ~50 | 24 GB | 150W | No | $1,200-1,800 |
| **A10G** | ~50 | ~50 | 24 GB | 150W | No | $1,000-1,500 |
| **L4** | ~130 (720p30 AV1) | ~130 | 24 GB | 72W | Yes | $800-1,200 |
| **L40** | ~160 | ~160 | 48 GB | 300W | Yes | $3,000-4,500 |
| **A100** | Not optimized for NVENC | N/A | 40/80 GB | 250-300W | No | $5,000-8,000 |
| **RTX 4090** | 12 (consumer limit) | 12 | 24 GB | 450W | Yes | $1,500-2,000 |
| **RTX 4080** | 8 (consumer limit) | 8 | 16 GB | 320W | Yes | $900-1,300 |
| **RTX A4000** | ~20 | ~20 | 16 GB | 140W | No | $600-900 |

**Note on consumer GPUs:** Since November 2025, NVIDIA raised the concurrent NVENC session
limit on consumer GPUs from 3 to 12. However, data center GPUs remain the recommended choice
for production due to: better thermal management, ECC memory, official server support,
no power limits, and time-slicing support.

### 6.2 Cost-Per-Stream Analysis

**Assumptions:** 1080p30 H.264, 3-rendition ABR ladder (1080p + 720p + 480p), time-sliced
into 4 replicas, running 24/7 for 1 month (730 hours).

| GPU | Streams (ABR ladder) | Used Cost | Monthly Power* | Streams/$ (CAPEX) | $/Stream/Month (Power) |
|-----|---------------------|-----------|----------------|-------------------|----------------------|
| T4 | 10 (38/3 * 4 slices) | $500 | $10.22 (70W x 4) | 20 | $1.02 |
| L4 | 17 (130/3 * 4 slices) | $1,000 | $10.51 (72W x 4) | 17 | $0.62 |
| A10 | 16 (50/3 * 4 slices) | $1,500 | $21.90 (150W x 4) | 11 | $1.37 |
| RTX 4090 | 4 (12/3, no slicing) | $1,750 | $65.70 (450W) | 2 | $16.43 |

**Power cost:** $0.15/kWh (US average commercial rate)

**Best value:** The L4 is the sweet spot for transcoding in 2026. It offers:
- AV1 encoding support (future-proof)
- Low power draw (72W = low cooling costs)
- High stream density per GPU
- Competitive used pricing

**Second best:** The T4 remains excellent for pure H.264/H.265 transcoding
where AV1 is not needed, especially at used prices under $500.

### 6.3 Multi-GPU Strategies

**Strategy 1: One big GPU**
```
Single L40 (48GB, 300W):
  - ~53 concurrent ABR ladders
  - Simpler management (one GPU per node)
  - Higher blast radius on failure
  - $3,000-4,500 used
```

**Strategy 2: Multiple smaller GPUs**
```
4x L4 (4x24GB, 4x72W = 288W total):
  - ~68 concurrent ABR ladders
  - Redundancy (failure takes out 25% capacity, not 100%)
  - Better bin-packing in Kubernetes
  - $3,200-4,800 used
  - Lower power consumption
```

**Recommendation:** Multiple L4 GPUs per node (2-4x). Better redundancy,
better Kubernetes scheduling (can assign individual GPUs to different pods),
and the total power draw is similar to a single large GPU.

**Server configuration for 4x L4:**

| Component | Specification |
|-----------|--------------|
| Server | 2U rackmount (e.g., Dell R750xs, Supermicro 2U) |
| CPU | Intel Xeon Silver 4316 (20C/40T) or AMD EPYC 7543 |
| RAM | 128 GB DDR4 ECC |
| GPUs | 4x NVIDIA L4 (PCIe) |
| Storage (OS) | 2x 480GB NVMe (RAID 1) |
| Storage (Media) | 4x 2TB NVMe (for transcode workspace) |
| Network | 2x 10GbE (bonded) |
| PSU | 1600W 80Plus Platinum |
| Estimated total power | ~650W typical, ~900W peak |
| Estimated cost (used) | $8,000-12,000 |

### 6.4 Power and Cooling Considerations

**Power budget per GPU node:**

| Component | Power Draw |
|-----------|-----------|
| CPU (idle/transcode) | 80-150W |
| RAM (128GB DDR4) | 20-30W |
| 4x L4 GPUs | 288W (4 x 72W) |
| NVMe SSDs (4x) | 20-40W |
| Fans (4+) | 40-80W |
| Motherboard/overhead | 30-50W |
| **Total typical** | **~500W** |
| **Total peak** | **~700W** |

**Cooling requirements:**
- Server fans: High-static-pressure fans required for GPU nodes
- Rack airflow: Hot aisle/cold aisle configuration essential
- Room cooling: 500W per node = ~1,700 BTU/hr. A standard 42U rack with
  10 GPU nodes requires ~17,000 BTU/hr (1.5 tons of cooling)
- Recommended: In-row cooling or rear-door heat exchangers for GPU racks

### 6.5 Rack Density Planning

| Form Factor | GPUs per Node | Nodes per 42U Rack | Total GPUs | Est. Power per Rack |
|-------------|--------------|-------------------|------------|-------------------|
| 2U with 4x L4 | 4 | 16 (with switch/PDU) | 64 | ~8 kW |
| 2U with 2x L40 | 2 | 16 | 32 | ~11 kW |
| 4U with 8x L4 | 8 | 8 | 64 | ~8 kW |
| 1U with 1x T4 | 1 | 32 | 32 | ~6 kW |

**Power budget per rack (typical data center):**
- Standard: 5-8 kW per rack (L4-based nodes fit here)
- High-density: 15-20 kW per rack (L40/A100 nodes require this)
- Maximum: 30+ kW per rack (requires specialized cooling)

### 6.6 Used/Refurbished GPU Options

| GPU | Used Price (2026) | Source | Notes |
|-----|-------------------|--------|-------|
| T4 16GB | $400-600 | eBay, ServerDeals | Abundant supply from decommissioned AI clusters |
| L4 24GB | $800-1,200 | eBay, refurbishers | Newer, AV1 support, excellent value |
| A10 24GB | $1,200-1,800 | eBay, refurbishers | Higher TDP but proven reliability |
| A10G 24GB | $1,000-1,500 | AWS surplus, eBay | AWS-specific variant, similar to A10 |
| RTX 3090 24GB | $700-1,000 | eBay | Consumer card; 12 NVENC sessions; high power |
| RTX 4090 24GB | $1,500-2,000 | eBay | Consumer; best consumer NVENC; very high power |

**Risk factors for used GPUs:**
- **Mining cards (RTX 30/40 series):** May have degraded VRAM thermal pads; stress test for 24h before deploying
- **Data center decommissions (T4, A10, L4):** Generally reliable; enterprise cards are built for 24/7 operation
- **Warranty:** Most used GPUs have no warranty; buy from reputable sellers with return policies
- **Recommendation:** Prefer data center GPUs (T4, L4, A10) from decommissioned servers over consumer mining cards

---

## 7. Monitoring and Observability for Streaming

### 7.1 Key Metrics

**Quality of Experience (QoE) Metrics:**

| Metric | Description | Target | Alert Threshold |
|--------|-------------|--------|-----------------|
| Buffer Ratio | Time spent buffering / total play time | < 0.5% | > 2% |
| Startup Time | Time from play click to first frame | < 2s | > 5s |
| Rebuffering % | Sessions with at least one rebuffer | < 5% | > 15% |
| Bitrate Stability | Quality switches per minute | < 1/min | > 3/min |
| Error Rate | Playback failures / total attempts | < 0.1% | > 1% |

**Infrastructure Metrics:**

| Metric | Description | Target | Alert Threshold |
|--------|-------------|--------|-----------------|
| Concurrent Viewers | Simultaneous active sessions | Trend | Sudden drop > 20% |
| Bitrate per Stream | Average output bitrate per rendition | Profile target | > 120% of configured |
| Segment Generation Interval | Time between new segments | 6s +/- 0.5s | > 10s or < 3s |
| Origin Response Time | Time to serve a segment | < 50ms | > 200ms |
| GPU Utilization | NVENC/NVDEC engine utilization | 60-85% | > 95% or < 20% |
| Transcode Queue Depth | Pending jobs in Redis/queue | < 10 | > 50 |
| CDN Cache Hit Ratio | % of segments served from cache | > 90% | < 70% |

### 7.2 Prometheus Metrics for Media Servers

**DCGM Exporter (GPU metrics):**

```yaml
# Already deployed by NVIDIA GPU Operator
# Key metrics:
#   DCGM_FI_DEV_GPU_UTIL          - GPU compute utilization
#   DCGM_FI_DEV_ENC_UTIL          - NVENC encoder utilization
#   DCGM_FI_DEV_DEC_UTIL          - NVDEC decoder utilization
#   DCGM_FI_DEV_FB_USED           - Framebuffer memory used
#   DCGM_FI_DEV_GPU_TEMP          - GPU temperature
#   DCGM_FI_DEV_POWER_USAGE       - Power draw
```

**Custom transcoding metrics (export from your transcoder application):**

```yaml
# Custom Prometheus metrics to expose from transcoder pods
# Endpoint: /metrics on port 8080

# transcoding_sessions_active gauge
#   Number of active transcoding sessions
#   Labels: gpu_id, profile, resolution

# transcoding_frames_processed_total counter
#   Total frames processed
#   Labels: gpu_id, profile, codec

# transcoding_segments_written_total counter
#   Total HLS segments written
#   Labels: gpu_id, profile, rendition

# transcoding_segment_duration_seconds histogram
#   Actual duration of generated segments
#   Labels: profile, rendition

# transcoding_encode_latency_seconds histogram
#   Time to encode one segment
#   Labels: gpu_id, profile, resolution

# transcoding_queue_depth gauge
#   Pending jobs in queue
#   Labels: queue_name

# transcoding_errors_total counter
#   Transcoding errors
#   Labels: gpu_id, error_type
```

**Origin server metrics (nginx VTS module or nginx-prometheus-exporter):**

```yaml
# Key nginx metrics:
#   nginx_request_duration_seconds  - Request latency histogram
#   nginx_requests_total            - Total requests by status code
#   nginx_bytes_sent_total          - Bytes sent
#   nginx_connections_active        - Active connections
#   nginx_upstream_response_time    - Origin response time
```

### 7.3 Grafana Dashboard Configuration

**Dashboard rows for streaming operations:**

```
Row 1: Viewership Overview
  - Concurrent viewers (time series, stacked by stream)
  - Viewers by quality level (pie chart)
  - Geographic distribution (world map panel)
  - New sessions / minute (counter)

Row 2: Quality of Experience
  - Buffer ratio (gauge + time series)
  - Startup time (histogram, p50/p95/p99)
  - Rebuffering percentage (stat panel)
  - Quality switches / minute (time series)

Row 3: Transcoding Health
  - Active transcoding sessions (stat)
  - GPU utilization per card (bar gauge)
  - NVENC engine utilization (time series)
  - Segment generation interval (time series, should be flat at 6s)
  - Transcode queue depth (time series with alert line)
  - Frames dropped / errors (counter)

Row 4: Origin Performance
  - Requests/second (time series)
  - Response time p50/p95/p99 (time series)
  - Cache hit ratio (gauge)
  - Bandwidth out (time series, Mbps)
  - Active connections (time series)

Row 5: Storage
  - MinIO bucket sizes (stat panels)
  - Segment count per bucket (time series)
  - Storage growth rate (bytes/hour)
  - Available disk space (gauge)

Row 6: Alerts (Alert List Panel)
  - Active firing alerts
  - Recent resolved alerts
```

### 7.4 Log-Based Monitoring

**Nginx access log format for media analytics:**

```nginx
log_format media '$remote_addr - $remote_user [$time_local] '
                 '"$request" $status $body_bytes_sent '
                 '"$http_referer" "$http_user_agent" '
                 '$request_time $upstream_response_time '
                 '$sent_http_content_range "$http_range" '
                 'stream=$arg_stream rendition=$arg_rendition';

access_log /var/log/nginx/media-access.log media;
```

**Log-to-metrics pipeline:**

```
[Nginx Access Logs] → [Fluent Bit] → [Loki] → [Grafana LogQL Queries]
                                            → [Prometheus (via Loki metrics)]
```

**Useful LogQL queries for viewer analytics:**

```promql
# Concurrent viewers (approximation via unique IPs in last 60s)
count(count_over_time({app="origin-server"} | json [60s])) by (stream)

# Top streams by request count
topk(10, sum(rate({app="origin-server"} |= "playlist.m3u8" [5m])) by (stream))

# Error rate by status code
sum(rate({app="origin-server"} | json | status >= 400 [5m])) by (status) /
sum(rate({app="origin-server"} | json [5m]))
```

### 7.5 Alerting Rules

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: streaming-alerts
  namespace: media
spec:
  groups:
    - name: streaming.qoe
      rules:
        - alert: HighBufferRatio
          expr: avg(media_buffer_ratio) > 0.02
          for: 2m
          labels:
            severity: warning
          annotations:
            summary: "Buffer ratio exceeds 2%"
            description: "Average buffer ratio is {{ $value | humanizePercentage }}"

        - alert: HighStartupTime
          expr: histogram_quantile(0.95, media_startup_time_seconds) > 5
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "95th percentile startup time exceeds 5s"

        - alert: HighRebufferRate
          expr: (sum(rate(media_rebuffer_events_total[5m])) / sum(rate(media_sessions_total[5m]))) > 0.15
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "More than 15% of sessions experiencing rebuffers"

    - name: streaming.infrastructure
      rules:
        - alert: TranscodeQueueDepth
          expr: transcode_queue_depth > 50
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "Transcode queue depth is {{ $value }}"

        - alert: GPUEncoderStalled
          expr: DCGM_FI_DEV_ENC_UTIL < 5 and transcoding_sessions_active > 0
          for: 2m
          labels:
            severity: critical
          annotations:
            summary: "GPU encoder utilization near zero despite active sessions"

        - alert: SegmentGenerationDelay
          expr: time() - transcoding_last_segment_timestamp_seconds > 15
          for: 1m
          labels:
            severity: critical
          annotations:
            summary: "No new segments generated for {{ $value }}s"

        - alert: OriginResponseTimeHigh
          expr: histogram_quantile(0.95, nginx_request_duration_seconds_bucket{path=~".*\\.ts"}) > 0.2
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "Origin p95 response time for segments exceeds 200ms"

        - alert: LowCDNCacheHitRatio
          expr: cdn_cache_hit_ratio < 0.70
          for: 10m
          labels:
            severity: warning
          annotations:
            summary: "CDN cache hit ratio below 70%"
```

### 7.6 SCTE-35 Ad Marker Monitoring

SCTE-35 markers signal ad insertion points in broadcast streams. Monitoring them is critical
for ad-supported streaming.

**What to monitor:**

| Metric | Description | Alert Condition |
|--------|-------------|-----------------|
| Marker count per hour | Expected: N per hour (based on schedule) | 0 markers in 30 minutes (when ads expected) |
| Cue-out / Cue-in duration | Time between CUE-OUT and CUE-IN | Duration outside expected range (e.g., not 60-120s) |
| Marker placement accuracy | Offset from scheduled time | > 5 seconds deviation |
| Splice insert errors | Malformed or missing splice commands | Any error |
| Segment boundary alignment | Markers should align to segment boundaries | Marker in middle of segment |

**FFmpeg SCTE-35 extraction:**

```bash
# Extract SCTE-35 markers from a live stream
ffmpeg -i rtmp://ingest:1935/live/stream \
  -filter_complex "[0:v]showinfo" \
  -f null - 2>&1 | grep -i scte

# Or use a dedicated tool:
# scte35-parser (Python): pip install threefive
# Usage: threefive parse rtmp://ingest:1935/live/stream
```

---

## 8. Self-Hosted vs Cloud CDN Cost Analysis

### 8.1 Cloud CDN Pricing Reference (2026)

| Provider | Price/GB (first 10TB, NA/EU) | Price/GB (500TB+, NA/EU) | Min Commit |
|----------|------------------------------|--------------------------|------------|
| CloudFront | $0.085 | $0.050 (volume discount) | None |
| Cloudflare | $0.050 (Pro) | Custom | $0 |
| Fastly | $0.120 | $0.040 (enterprise) | Varies |
| Bunny | $0.005 (volume network) | $0.003 (500TB+) | $0 |
| Akamai | $0.035-0.049 | Custom (enterprise) | High |
| BlazingCDN | $0.005 | $0.003 (500TB+) | $0 |

### 8.2 Self-Hosted Edge: Capital Expenditure

**Single edge node (1U server):**

| Component | Specification | Cost (New) | Cost (Used) |
|-----------|--------------|------------|-------------|
| Server | Supermicro 1U, Xeon E-2388G | $2,500 | $1,200 |
| RAM | 64 GB DDR4 ECC | $200 | $100 |
| Storage (OS) | 2x 240GB SSD (RAID 1) | $100 | $50 |
| Storage (Cache) | 2x 2TB NVMe (cache) | $400 | $250 |
| NIC | 2x 10GbE | $300 | $150 |
| **Total per edge node** | | **$3,500** | **$1,750** |

### 8.3 Self-Hosted Edge: Operating Expenditure

| Cost Item | Monthly Cost | Notes |
|-----------|-------------|-------|
| Colocation (1U) | $50-150 | Depends on facility, power included or separate |
| Bandwidth (transit) | $0.50-2.00/Mbps (95th %ile) | Or $0.001-0.005/GB on blended |
| Power (150W node) | $15-25 | At $0.10-0.15/kWh |
| Maintenance | $50-100/mo amortized | Hardware replacement, labor |
| **Total per node (estimated)** | **$100-300/mo** | |

### 8.4 Break-Even Analysis

**Scenario: 100TB/month traffic**

| Approach | Monthly Cost | Notes |
|----------|-------------|-------|
| CloudFront (NA/EU) | $5,000-8,500 | First 10TB at $0.085, volume discounts |
| Bunny (volume) | $300-500 | $0.005/GB on volume network |
| BlazingCDN | $300-500 | $0.005/GB |
| Self-hosted (1 edge node) | $100-300 + bandwidth | Requires cheap transit |

**Scenario: 500TB/month traffic**

| Approach | Monthly Cost | Annual Cost |
|----------|-------------|-------------|
| CloudFront | $25,000-42,500 | $300K-510K |
| Bunny | $1,500-2,500 | $18K-30K |
| Self-hosted (5 edge nodes) | $2,000-5,000 + transit | Variable |

**Scenario: 10TB/month traffic (small operation)**

| Approach | Monthly Cost | Notes |
|----------|-------------|-------|
| CloudFront | $850 | No commitment |
| Bunny | $50 | Very affordable |
| Self-hosted | $300+ (1 node) | Not cost-effective at this scale |

### 8.5 When Self-Hosting Makes Sense

**Self-hosting wins when:**
1. Monthly traffic exceeds 50TB (bandwidth costs dominate)
2. You can obtain transit at $0.001-0.003/GB (blended rate)
3. Your audience is geographically concentrated (few PoPs needed)
4. You have existing data center or colocation relationships
5. You need fine-grained control over caching behavior

**Cloud CDN wins when:**
1. Traffic is under 10TB/month
2. Audience is globally distributed (need 20+ PoPs)
3. Burst capacity is needed (traffic spikes)
4. You want zero infrastructure management
5. You need integrated DDoS protection and WAF

### 8.6 Hybrid Approach

The optimal strategy for many self-hosters is a hybrid:

```
                    ┌─── [Self-hosted Edge] ────┐
[Origin] ──────────┤                            ├─── [Viewer]
                    └─── [Cloud CDN (spillover)] ┘
                    (primary = self-hosted)
                    (spillover = cloud CDN when self-hosted saturated)
```

**Implementation with nginx split routing:**

```nginx
# DNS-based split (simplest approach)
# Use GeoDNS or anycast to route:
#   - 70% of traffic to self-hosted edge (cheapest)
#   - 30% to cloud CDN (handles spikes, remote regions)

# Or use nginx as a load-balanced origin behind both:
upstream origins {
    server self-hosted-edge.local:80 weight=7;
    # Cloud CDN pulls from origin directly
}
```

**Cost optimization strategy:**
1. Self-host 1-3 edge PoPs in your primary audience region
2. Use a budget cloud CDN (Bunny, BlazingCDN) for global coverage
3. Configure cloud CDN as secondary/failover origin
4. Set cache headers aggressively (max-age=86400 for .ts segments)
5. Monitor cache hit ratios weekly and tune

### 8.7 Real-World TCO Comparison

**Example: 200TB/month streaming service, US-only, 3-year horizon**

| Item | Self-Hosted (3 PoPs) | Cloud CDN (CloudFront) | Hybrid |
|------|---------------------|----------------------|--------|
| **CAPEX (Year 1)** | | | |
| Edge servers (3x used 1U) | $5,250 | $0 | $1,750 (1 PoP) |
| Switch, PDU, cabling | $2,000 | $0 | $1,000 |
| Setup fees (colo) | $1,500 | $0 | $500 |
| **Total CAPEX** | **$8,750** | **$0** | **$3,250** |
| | | | |
| **OPEX (per year)** | | | |
| Colocation (3x 1U) | $3,600 | $0 | $1,200 |
| Bandwidth (transit) | $6,000-12,000 | $0 | $2,000 |
| Cloud CDN (spillover) | $0 | $0 | $3,000-6,000 |
| Cloud CDN (full) | $0 | $18,000-36,000 | $0 |
| Maintenance/replacement | $2,000 | $0 | $500 |
| Power | $900 | $0 | $300 |
| **Total OPEX/year** | **$12,500-18,500** | **$18,000-36,000** | **$7,000-10,000** |
| | | | |
| **3-Year TCO** | **$46,250-64,250** | **$54,000-108,000** | **$24,250-33,250** |

**Conclusion:** The hybrid approach (1 self-hosted PoP + budget cloud CDN for spillover
and remote regions) provides the best TCO for most self-hosted streaming operations.
Pure self-hosting beats pure cloud CDN at scale but requires operational expertise.
Pure cloud CDN is simplest but most expensive at volume.

---

## Appendix A: Dockerfile for GPU Transcoder

```dockerfile
FROM nvidia/cuda:12.6.3-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install FFmpeg with NVENC support
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository ppa:savoury1/ffmpeg6 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    ffmpeg \
    python3 \
    python3-pip \
    redis-tools \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies for queue consumer
RUN pip3 install --no-cache-dir redis prometheus-client

# Copy application
WORKDIR /app
COPY transcode.py /app/
COPY healthcheck.sh /app/
COPY profiles/ /etc/transcoder/profiles/

RUN chmod +x /app/healthcheck.sh

# NVIDIA runtime required
ENV NVIDIA_DRIVER_CAPABILITIES=video,compute,utility
ENV NVIDIA_VISIBLE_DEVICES=all

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD /app/healthcheck.sh

CMD ["python3", "/app/transcode.py"]
```

## Appendix B: Transcode Queue Consumer (Python)

```python
#!/usr/bin/env python3
"""
Transcode queue consumer. Reads jobs from Redis, runs FFmpeg, reports metrics.
"""
import os
import sys
import json
import subprocess
import time
import redis
from prometheus_client import start_http_server, Gauge, Counter, Histogram

# Metrics
ACTIVE_SESSIONS = Gauge('transcoding_sessions_active', 'Active sessions', ['gpu_id', 'profile'])
SEGMENTS_WRITTEN = Counter('transcoding_segments_written_total', 'Segments written', ['rendition'])
SEGMENT_DURATION = Histogram('transcoding_segment_duration_seconds', 'Segment duration')
QUEUE_DEPTH = Gauge('transcode_queue_depth', 'Pending jobs', ['queue_name'])
ERRORS = Counter('transcoding_errors_total', 'Errors', ['error_type'])

def build_ffmpeg_cmd(job, profile_config):
    """Build FFmpeg command from job and profile configuration."""
    cmd = ['ffmpeg', '-y']

    # GPU acceleration
    if os.environ.get('NVIDIA_VISIBLE_DEVICES') == 'all':
        gpu_idx = os.environ.get('GPU_INDEX', '0')
        cmd.extend(['-hwaccel', 'cuda', '-hwaccel_device', gpu_idx,
                    '-hwaccel_output_format', 'cuda'])

    # Input
    cmd.extend(['-i', job['input_url']])

    # Build ABR ladder from profile
    profiles = profile_config['profiles']
    audio = profile_config['audio']
    hls = profile_config['hls']

    # Filter complex for multi-rendition
    split_count = len(profiles)
    filter_parts = [f"[0:v]split={split_count}"] + \
                   [f"[v{i}]" for i in range(split_count)]
    scale_parts = []
    map_args = []
    var_streams = []

    for i, p in enumerate(profiles):
        scale_parts.append(
            f"[v{i}]scale_cuda={p['width']}:{p['height']}[v{i}out]"
        )
        codec = p.get('codec', 'h264_nvenc')
        map_args.extend([
            '-map', f'[v{i}out]',
            f'-c:v:{i}', codec,
            f'-preset', p['preset'],
            f'-b:v:{i}', f"{p['bitrate']}k",
            f'-maxrate:v:{i}', f"{p['maxrate']}k",
            f'-bufsize:v:{i}', f"{p['bufsize']}k",
            '-g', '120', '-keyint_min', '120',
        ])
        var_streams.append(f'v:{i},a:0')

    filter_complex = ';'.join(
        [','.join(filter_parts)] + scale_parts
    )

    cmd.extend(['-filter_complex', filter_complex])
    cmd.extend(map_args)

    # Audio
    cmd.extend([
        '-map', 'a:0',
        '-c:a', 'aac',
        '-b:a', f"{audio['bitrate']}k",
        '-ar', str(audio['sample_rate']),
        '-ac', str(audio['channels']),
    ])

    # HLS output
    cmd.extend([
        '-var_stream_map', ' '.join(var_streams),
        '-master_pl_name', 'master.m3u8',
        '-f', 'hls',
        '-hls_time', str(hls['segment_duration']),
        '-hls_list_size', str(hls.get('playlist_size', 0)),
        '-hls_flags', 'independent_segments',
        '-hls_segment_filename',
        f"{job['output_path']}/stream_%v/seg_%05d.ts",
        f"{job['output_path']}/stream_%v/playlist.m3u8",
    ])

    return cmd


def main():
    start_http_server(8080)

    redis_url = os.environ.get('REDIS_URL', 'redis://localhost:6379')
    r = redis.from_url(redis_url)
    profile_name = os.environ.get('PROFILE', 'hls-abr')

    with open(f'/etc/transcoder/profiles/{profile_name}.json') as f:
        profile_config = json.load(f)

    gpu_id = os.environ.get('GPU_ID', 'gpu-0')
    ACTIVE_SESSIONS.labels(gpu_id=gpu_id, profile=profile_name).set(0)

    print(f"Transcoder ready. GPU={gpu_id}, Profile={profile_name}")

    while True:
        QUEUE_DEPTH.labels(queue_name='transcode:pending').set(
            r.llen('transcode:pending')
        )

        # Block on queue
        result = r.brpop('transcode:pending', timeout=5)
        if result is None:
            continue

        _, job_data = result
        job = json.loads(job_data)
        print(f"Processing job: {job['asset_id']}")

        ACTIVE_SESSIONS.labels(gpu_id=gpu_id, profile=profile_name).set(1)

        try:
            cmd = build_ffmpeg_cmd(job, profile_config)
            print(f"Running: {' '.join(cmd)}")

            process = subprocess.Popen(
                cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                text=True
            )

            for line in process.stdout:
                if 'segment' in line.lower() and 'ts' in line:
                    SEGMENTS_WRITTEN.labels(rendition='default').inc()

            process.wait()

            if process.returncode == 0:
                print(f"Job completed: {job['asset_id']}")
                r.lpush('transcode:completed', job_data)
            else:
                print(f"Job failed (rc={process.returncode}): {job['asset_id']}")
                ERRORS.labels(error_type='ffmpeg_error').inc()
                r.lpush('transcode:failed', job_data)

        except Exception as e:
            print(f"Exception: {e}")
            ERRORS.labels(error_type='exception').inc()
            r.lpush('transcode:failed', job_data)

        finally:
            ACTIVE_SESSIONS.labels(gpu_id=gpu_id, profile=profile_name).set(0)


if __name__ == '__main__':
    main()
```

## Appendix C: Nginx Edge Cache Configuration

```nginx
# Edge cache / reverse proxy in front of origin
# Deploy one per PoP location

proxy_cache_path /var/cache/nginx/media levels=1:2
                 keys_zone=media_cache:100m
                 max_size=200g
                 inactive=24h
                 use_temp_path=off;

server {
    listen 80;
    server_name edge.example.com;

    # HLS playlists -- short cache, revalidate often
    location ~ \.m3u8$ {
        proxy_cache media_cache;
        proxy_cache_valid 200 10s;
        proxy_cache_key "$scheme$request_method$host$request_uri";
        add_header X-Cache-Status $upstream_cache_status;

        proxy_pass http://origin.internal:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;

        # Don't cache 4xx/5xx
        proxy_cache_valid 404 1s;
        proxy_cache_valid 500 1s;
    }

    # HLS segments -- long cache, these never change
    location ~ \.ts$ {
        proxy_cache media_cache;
        proxy_cache_valid 200 86400s;  # 24 hours
        proxy_cache_key "$scheme$request_method$host$request_uri";
        add_header X-Cache-Status $upstream_cache_status;
        add_header Cache-Control "public, max-age=86400";

        proxy_pass http://origin.internal:80;
        proxy_set_header Host $host;

        # Slice range requests for large files
        slice 1m;
        proxy_set_header Range $slice_range;
    }

    # DASH manifests
    location ~ \.mpd$ {
        proxy_cache media_cache;
        proxy_cache_valid 200 10s;
        add_header X-Cache-Status $upstream_cache_status;

        proxy_pass http://origin.internal:80;
        proxy_set_header Host $host;
    }

    # Health check
    location /healthz {
        return 200 'ok';
        add_header Content-Type text/plain;
    }
}
```

---

## Appendix D: Quick Reference -- FFmpeg Commands for Common Operations

```bash
# 1. Simple transcode to HLS ABR ladder (GPU)
ffmpeg -hwaccel cuda -hwaccel_output_format cuda \
  -i input.mp4 \
  -filter_complex "[0:v]split=3[v1][v2][v3]; \
   [v1]scale_cuda=1920:1080[v1out]; \
   [v2]scale_cuda=1280:720[v2out]; \
   [v3]scale_cuda=854:480[v3out]" \
  -map "[v1out]" -c:v:0 h264_nvenc -b:v:0 6000k \
  -map "[v2out]" -c:v:1 h264_nvenc -b:v:1 3000k \
  -map "[v3out]" -c:v:2 h264_nvenc -b:v:2 1500k \
  -map a:0 -c:a aac -b:a 128k \
  -var_stream_map "v:0,a:0 v:1,a:0 v:2,a:0" \
  -master_pl_name master.m3u8 \
  -f hls -hls_time 6 -hls_list_size 0 -hls_flags independent_segments \
  -hls_segment_filename "stream_%v/seg_%05d.ts" \
  stream_%v/playlist.m3u8

# 2. Live transcode from RTMP to HLS (GPU)
ffmpeg -hwaccel cuda -hwaccel_output_format cuda \
  -i rtmp://ingest:1935/live/key \
  -c:v h264_nvenc -preset p5 -b:v 4500k -maxrate 6000k -bufsize 9000k \
  -c:a aac -b:a 128k \
  -f hls -hls_time 4 -hls_list_size 10 \
  -hls_flags delete_segments+independent_segments \
  -hls_segment_filename /output/live/seg_%05d.ts \
  /output/live/playlist.m3u8

# 3. VOD to DASH (CPU, high quality)
ffmpeg -i input.mp4 \
  -c:v libx264 -preset slow -crf 20 -g 120 \
  -c:a aac -b:a 128k \
  -f dash \
  -seg_duration 6 \
  -dash_segment_type mp4 \
  -init_seg_name "init_\$RepresentationID\$.mp4" \
  -media_seg_name "seg_\$RepresentationID\$_\$Number%05d\$.m4s" \
  manifest.mpd

# 4. Extract SCTE-35 markers
ffprobe -show_frames -select_streams v \
  -i input.ts 2>&1 | grep -A5 "scte35"

# 5. Generate thumbnails
ffmpeg -i input.mp4 -vf "fps=1/60,scale=320:-1" \
  -q:v 3 thumb_%04d.jpg

# 6. Check stream info
ffprobe -v quiet -print_format json -show_format -show_streams \
  rtmp://ingest:1935/live/key

# 7. Low-latency HLS (1s segments)
ffmpeg -hwaccel cuda -i rtmp://ingest:1935/live/key \
  -c:v h264_nvenc -preset p4 -tune ll -b:v 6000k \
  -c:a aac -b:a 128k \
  -f hls \
  -hls_time 1 -hls_list_size 5 \
  -hls_flags delete_segments+independent_segments \
  -hls_segment_type mpegts \
  /output/ll-live/playlist.m3u8

# 8. AV1 encoding (L4 GPU)
ffmpeg -hwaccel cuda -hwaccel_output_format cuda \
  -i input.mp4 \
  -c:v av1_nvenc -preset p5 -b:v 4000k \
  -c:a aac -b:a 128k \
  -f hls -hls_time 6 -hls_list_size 0 \
  -hls_segment_filename "av1_%05d.ts" \
  playlist.m3u8
```

---

*Document version: 2026-05-27*
*This reference covers self-hosted streaming infrastructure as of May 2026. GPU pricing, CDN rates, and software versions change frequently -- verify current numbers before making purchasing decisions.*
