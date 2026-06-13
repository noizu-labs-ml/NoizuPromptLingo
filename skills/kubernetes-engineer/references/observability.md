# Kubernetes Observability

Comprehensive guide to building a production observability stack on Kubernetes: metrics, logs, traces, alerting, and multi-cluster federation.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        INSTRUMENTED WORKLOADS                               │
│   Pods / Services / Controllers / Kubelet / Node Exporters                  │
└────────────┬───────────────────────┬───────────────────────────────────────┘
             │  OTLP / Prometheus    │  Logs (stdout/stderr)
             ▼  scrape               ▼
┌────────────────────────┐  ┌────────────────────────┐
│   OTel Collector       │  │   Fluent Bit DaemonSet  │
│   (DaemonSet/Deployment│  │   (log scraper)         │
│   gateway pattern)     │  └──────────┬──────────────┘
└────────┬───────────────┘             │
         │ OTLP                        │ HTTP/gRPC
    ┌────┴─────┐                       ▼
    │  Metrics │             ┌──────────────────────┐
    │  Traces  │             │       Grafana Loki    │
    └────┬─────┘             └──────────┬───────────┘
         │                              │
    ┌────┴──────────────┐               │
    │ VictoriaMetrics   │               │
    │ (or Prometheus)   │               │
    └────┬──────────────┘               │
         │       ┌─────────────────┐    │
         │       │  Grafana Tempo  │    │
         │       │  (traces store) │    │
         │       └────────┬────────┘    │
         │                │             │
         ▼                ▼             ▼
┌────────────────────────────────────────────────────┐
│                    Grafana                          │
│  Dashboards / Alerting / Explore / Correlations    │
└────────────────────────────────────────────────────┘
```

---

## 1. Metrics Pipeline

### Stack: OTel Collector → VictoriaMetrics → Grafana

VictoriaMetrics is preferred over vanilla Prometheus for production: lower RAM, faster queries, built-in retention policies, and native remote-write compatibility.

#### OTel Collector — Deployment (gateway mode)

```yaml
apiVersion: opentelemetry.io/v1beta1
kind: OpenTelemetryCollector
metadata:
  name: otel-gateway
  namespace: telemetry
spec:
  mode: Deployment
  replicas: 2
  config:
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
      prometheus:
        config:
          scrape_configs:
            - job_name: kubelet
              kubernetes_sd_configs:
                - role: node
              scheme: https
              tls_config:
                ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
              bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
              relabel_configs:
                - action: labelmap
                  regex: __meta_kubernetes_node_label_(.+)

    processors:
      batch:
        timeout: 5s
        send_batch_size: 1000
      memory_limiter:
        check_interval: 5s
        limit_mib: 512
      resource:
        attributes:
          - action: insert
            key: cluster
            value: "prod-us-east"

    exporters:
      prometheusremotewrite:
        endpoint: http://victoriametrics:8428/api/v1/write
        tls:
          insecure: true
      otlp/tempo:
        endpoint: http://tempo:4317
        tls:
          insecure: true

    service:
      pipelines:
        metrics:
          receivers: [prometheus, otlp]
          processors: [memory_limiter, batch, resource]
          exporters: [prometheusremotewrite]
        traces:
          receivers: [otlp]
          processors: [memory_limiter, batch, resource]
          exporters: [otlp/tempo]
```

#### VictoriaMetrics — Single-node values (Helm)

```yaml
# helm install victoria-metrics vm/victoria-metrics-single
server:
  retentionPeriod: 12  # months
  extraArgs:
    dedup.minScrapeInterval: 15s
    search.maxQueryDuration: 60s
  resources:
    requests:
      memory: 1Gi
      cpu: 500m
    limits:
      memory: 4Gi
  persistentVolume:
    enabled: true
    storageClass: openebs-lvmpv
    size: 100Gi
```

#### Prometheus Operator — PodMonitor pattern

When you cannot modify pod annotations, use a `PodMonitor` CRD instead of relying on scrape annotations:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: my-app
  namespace: my-ns
spec:
  selector:
    matchLabels:
      app: my-app
  podMetricsEndpoints:
    - port: metrics
      interval: 30s
      path: /metrics
      relabelings:
        - sourceLabels: [__meta_kubernetes_pod_node_name]
          targetLabel: node
```

---

## 2. Logging Pipeline

### Stack: Fluent Bit DaemonSet → Loki → Grafana

Fluent Bit is preferred over Fluentd: ~10x lower memory, compiled C binary, native Kubernetes metadata enrichment, built-in Loki output plugin.

#### Fluent Bit DaemonSet — ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: telemetry
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush         5
        Daemon        Off
        Log_Level     warn
        Parsers_File  parsers.conf
        HTTP_Server   On
        HTTP_Listen   0.0.0.0
        HTTP_Port     2020

    [INPUT]
        Name              tail
        Tag               kube.*
        Path              /var/log/containers/*.log
        multiline.parser  docker, cri
        DB                /var/log/flb_kube.db
        Mem_Buf_Limit     50MB
        Skip_Long_Lines   On

    [FILTER]
        Name                kubernetes
        Match               kube.*
        Kube_URL            https://kubernetes.default.svc:443
        Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
        Kube_Tag_Prefix     kube.var.log.containers.
        Merge_Log           On
        Keep_Log            Off
        K8S-Logging.Parser  On
        K8S-Logging.Exclude On
        Labels              On
        Annotations         Off

    [FILTER]
        Name   grep
        Match  kube.*
        Exclude $kubernetes['namespace_name'] ^kube-system$

    [OUTPUT]
        Name            loki
        Match           kube.*
        Host            loki.telemetry.svc.cluster.local
        Port            3100
        Labels          job=fluentbit, namespace=$kubernetes['namespace_name'], pod=$kubernetes['pod_name'], container=$kubernetes['container_name'], node=$kubernetes['host']
        Label_Keys      $level,$severity,$log_level
        Batch_Size      102400
        Batch_Wait      1
        Line_Format     json
        Auto_Kubernetes_Labels On

  parsers.conf: |
    [PARSER]
        Name        json
        Format      json
        Time_Key    time
        Time_Format %Y-%m-%dT%H:%M:%S.%L

    [PARSER]
        Name        logfmt
        Format      logfmt
```

#### Loki — Helm values (single-binary for small clusters)

```yaml
# helm install loki grafana/loki
loki:
  auth_enabled: false
  commonConfig:
    replication_factor: 1
  storage:
    type: filesystem
  limits_config:
    retention_period: 720h    # 30 days
    ingestion_rate_mb: 16
    ingestion_burst_size_mb: 32
    per_stream_rate_limit: 5MB
  compactor:
    retention_enabled: true

singleBinary:
  replicas: 1
  persistence:
    enabled: true
    storageClass: openebs-lvmpv
    size: 50Gi
```

---

## 3. Distributed Tracing

### Stack: OTel SDK → OTel Collector → Tempo → Grafana

#### Application Instrumentation (Go example)

```go
// Auto-instrument HTTP server with OTel SDK
import (
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
    "go.opentelemetry.io/otel/sdk/trace"
)

func initTracer() func() {
    exporter, _ := otlptracegrpc.New(ctx,
        otlptracegrpc.WithEndpoint("otel-collector:4317"),
        otlptracegrpc.WithInsecure(),
    )
    tp := trace.NewTracerProvider(
        trace.WithBatcher(exporter),
        trace.WithResource(resource.NewWithAttributes(
            semconv.SchemaURL,
            semconv.ServiceName("my-service"),
            semconv.ServiceVersion("v1.2.3"),
        )),
    )
    otel.SetTracerProvider(tp)
    return func() { tp.Shutdown(ctx) }
}
```

#### Tempo — Helm values

```yaml
# helm install tempo grafana/tempo
tempo:
  storage:
    trace:
      backend: local
      local:
        path: /var/tempo/traces
  retention: 72h

persistence:
  enabled: true
  storageClassName: openebs-lvmpv
  size: 20Gi

# Enable trace-to-log and trace-to-metric correlation
tempoQuery:
  enabled: true
```

#### Grafana data source wiring (trace → log correlation)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
  namespace: telemetry
data:
  datasources.yaml: |
    apiVersion: 1
    datasources:
      - name: Tempo
        type: tempo
        url: http://tempo:3100
        jsonData:
          tracesToLogsV2:
            datasourceUid: loki
            filterByTraceID: true
            filterBySpanID: false
            customQuery: false
          serviceMap:
            datasourceUid: victoriametrics
      - name: Loki
        type: loki
        uid: loki
        url: http://loki:3100
      - name: VictoriaMetrics
        type: prometheus
        uid: victoriametrics
        url: http://victoriametrics:8428
```

---

## 4. SLO-Based Alerting

### Tool: Sloth (SLO generator) or Pyrra

Burn-rate alerts fire when you're consuming error budget faster than sustainable. Sloth generates multi-window, multi-burn-rate PrometheusRules from a simple spec.

#### Sloth SLO spec

```yaml
apiVersion: sloth.slok.dev/v1
kind: PrometheusServiceLevel
metadata:
  name: my-api-availability
  namespace: my-ns
spec:
  service: my-api
  labels:
    team: platform
  slos:
    - name: requests-availability
      objective: 99.9
      description: "99.9% of requests must succeed"
      sli:
        events:
          errorQuery: |
            sum(rate(http_requests_total{job="my-api",code=~"5.."}[{{.window}}]))
          totalQuery: |
            sum(rate(http_requests_total{job="my-api"}[{{.window}}]))
      alerting:
        name: MyApiHighErrorRate
        labels:
          severity: page
        annotations:
          summary: "High error rate on my-api"
        pageAlert:
          labels:
            severity: critical
        ticketAlert:
          labels:
            severity: warning
```

#### Generated PrometheusRule (burn-rate example — what Sloth emits)

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: my-api-availability
spec:
  groups:
    - name: sloth-slo-my-api-requests-availability
      rules:
        # Fast burn (1h + 5m window) — page immediately
        - alert: MyApiHighErrorRate
          expr: |
            (
              slo:sli_error:ratio_rate1h{sloth_id="my-api-requests-availability"} > (14.4 * 0.001)
              and
              slo:sli_error:ratio_rate5m{sloth_id="my-api-requests-availability"} > (14.4 * 0.001)
            )
          for: 2m
          labels:
            severity: critical
            sloth_severity: page
          annotations:
            summary: "Fast burn: consuming error budget at 14.4x rate"

        # Slow burn (6h + 30m window) — ticket
        - alert: MyApiHighErrorRate
          expr: |
            (
              slo:sli_error:ratio_rate6h{sloth_id="my-api-requests-availability"} > (6 * 0.001)
              and
              slo:sli_error:ratio_rate30m{sloth_id="my-api-requests-availability"} > (6 * 0.001)
            )
          for: 15m
          labels:
            severity: warning
            sloth_severity: ticket
```

---

## 5. Dashboard Design

### USE Method — Infrastructure / Node Dashboards

For every resource (CPU, memory, disk, network):

| Panel | Query pattern |
|-------|---------------|
| **U**tilization | `rate(node_cpu_seconds_total{mode!="idle"}[5m])` |
| **S**aturation | `node_load1 / count(node_cpu_seconds_total{mode="idle"}) by (instance)` |
| **E**rrors | `rate(node_disk_io_time_weighted_seconds_total[5m])` — I/O wait proxy |

```
Row: Node Overview
  [CPU Util %]  [CPU Saturation (load avg)]  [CPU Errors (throttle)]
  [Mem Util %]  [Mem Saturation (page faults)] [OOM Kill count]
  [Disk Util %] [Disk Queue Depth]             [Disk Errors]
  [Net Util]    [Net Drop Rate]                [Net Errors]
```

### RED Method — Service / Application Dashboards

For every service:

| Panel | Query pattern |
|-------|---------------|
| **R**ate | `sum(rate(http_requests_total[5m])) by (service)` |
| **E**rrors | `sum(rate(http_requests_total{code=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))` |
| **D**uration | `histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service))` |

```
Row: Service Health
  [RPS by endpoint]  [Error rate %]  [p50/p95/p99 latency]
  [Apdex score]      [SLO burn rate] [Error budget remaining]

Row: Dependencies
  [Upstream latency]  [DB query time]  [Cache hit rate]
```

### Dashboard Variables (must-haves)

```yaml
# Standard variables for every dashboard
- name: cluster
  type: query
  query: label_values(kube_pod_info, cluster)
- name: namespace
  type: query
  query: label_values(kube_pod_info{cluster="$cluster"}, namespace)
- name: pod
  type: query
  query: label_values(kube_pod_info{cluster="$cluster",namespace="$namespace"}, pod)
  multi: true
  includeAll: true
```

---

## 6. Multi-Cluster Observability

### Architecture Options

| Pattern | Best For | Complexity |
|---------|----------|------------|
| **Remote-write federation** | <10 clusters, simple | Low |
| **Thanos sidecar + query** | Many clusters, long retention | High |
| **VictoriaMetrics cluster** | High cardinality, cost-sensitive | Medium |
| **Grafana Agent + central VM** | Lightweight push model | Low-Medium |

### Remote-Write Federation (VictoriaMetrics)

Each cluster pushes to a central VictoriaMetrics:

```yaml
# In each spoke cluster's OTel Collector or Prometheus
remote_write:
  - url: https://central-vm.internal/api/v1/write
    headers:
      X-Cluster-ID: prod-us-east
    queue_config:
      max_samples_per_send: 10000
      capacity: 50000
    tls_config:
      ca_file: /etc/ssl/certs/ca.crt
      cert_file: /etc/ssl/certs/client.crt
      key_file: /etc/ssl/private/client.key
```

Central Grafana queries with cluster label filter:

```promql
# Per-cluster error rate
sum by (cluster, namespace) (
  rate(http_requests_total{code=~"5..", cluster=~"$cluster"}[5m])
)
```

### Thanos Pattern (brief)

```
Spoke clusters: Prometheus + Thanos Sidecar (uploads blocks to object store)
Central: Thanos Query → Thanos Store Gateway → S3/GCS
         Thanos Compactor → dedup + downsampling
         Thanos Ruler → cross-cluster alerting
```

---

## 7. Anti-Patterns

| Anti-pattern | Problem | Fix |
|--------------|---------|-----|
| **Static threshold alerts** (`cpu > 80%`) | Too noisy, misses slow degradation | Use burn-rate or anomaly-based alerting |
| **No burn-rate alerting** | SLOs defined but not enforced | Adopt Sloth or Pyrra to generate multi-window rules |
| **Siloed dashboards per team** | No cross-service correlation | Shared service catalog dashboard with drill-down links |
| **Fluentd over Fluent Bit** | 10x higher memory per node | Migrate to Fluent Bit; use Fluentd only for complex routing |
| **Scraping every 10s globally** | Cardinality explosion, high ingest cost | Use 30s default; 15s only for SLO-critical metrics |
| **No retention policy on Loki** | Disk fills silently | Set `retention_period` and enable compactor |
| **Trace sampling at 100%** | Overwhelms Tempo, high cost | Use head-based sampling at 5-10% + tail-based for errors |
| **Alert on symptoms AND causes** | Double-paging for single incident | Alert on symptoms (latency, errors) only; causes are for dashboards |
| **Unlabeled metrics** | Cannot slice by team, env, version | Enforce `team`, `env`, `version` labels via relabeling at collector |
| **No runbook links in alerts** | On-call doesn't know what to do | Add `runbook_url` annotation to every PrometheusRule alert |

---

## Reference

- [OpenTelemetry Operator](https://github.com/open-telemetry/opentelemetry-operator)
- [Sloth SLO Generator](https://sloth.slok.dev/)
- [Pyrra SLO Tool](https://github.com/pyrra-dev/pyrra)
- [VictoriaMetrics Helm](https://github.com/VictoriaMetrics/helm-charts)
- [Grafana Loki](https://grafana.com/docs/loki/latest/)
- [Grafana Tempo](https://grafana.com/docs/tempo/latest/)
- [USE Method](https://www.brendangregg.com/usemethod.html)
- [RED Method](https://grafana.com/blog/2018/08/02/the-red-method-how-to-instrument-your-services/)
