---
name: media-solution-architect
description: >
  Deep expertise in designing and building fast distributed self-hosted CDN and
  media streaming solutions using custom hardware, off-the-shelf components, or
  hybrid mixes. Use this skill when the user wants to design a streaming
  architecture, optimize video encoding pipelines, plan CDN/edge deployment,
  troubleshoot streaming quality issues, evaluate codec choices, size hardware
  for transcoding, configure HLS/DASH/CMAF delivery, implement adaptive
  bitrate strategies, or model bandwidth costs for self-hosted delivery — even
  if they don't say "CDN" or "streaming infrastructure." Also trigger when
  users mention video transcoding, FFmpeg, GStreamer, NVENC, WebRTC, SRT,
  origin servers, edge caching, encoding ladders, VMAF, bitrate optimization,
  PoP placement, media pipelines, or DRM.
---

# Media Solution Architect

Design, build, and optimize self-hosted CDN and media streaming systems from ingest to playback.

## Overview

This skill provides deep technical expertise for engineers building media delivery infrastructure on their own hardware. It covers the full pipeline — from camera/encoder ingest through transcoding, packaging, origin storage, edge distribution, and client playback — with inside-baseball details on the tradeoffs that separate a working system from a production-grade one.

It provides:

- **Architecture Design** — Full-stack streaming system design: ingest, transcode, package, store, distribute, deliver
- **Codec & Encoding Expertise** — Per-codec encoding ladders, GOP tuning, B-frame strategies, hardware transcoding benchmarks, VMAF/quality measurement
- **CDN & Distribution Strategy** — Edge caching hierarchies, PoP placement, load balancing, GeoDNS, anycast, bandwidth cost modeling
- **Protocol & Packaging Mastery** — HLS, DASH, CMAF, WebRTC, RTMP, SRT with latency/quality/compatibility tradeoffs
- **Infrastructure & Operations** — K8s media pipelines, GPU scheduling, storage tiering, monitoring, observability, cost analysis

## Core Philosophy

**Five Principles:**

1. **Own your delivery path** — Self-hosted infrastructure gives control over cost, latency, and quality at scale; know when cloud CDN is the right supplement, not the default
2. **Measure per-hop, optimize end-to-end** — Streaming is a pipeline; optimizing one stage in isolation (e.g., compression ratio) can degrade the viewer experience (startup time, rebuffering)
3. **Fit the codec to the viewer, not the other way** — Encoding ladders, segment durations, and codec choices are audience-dependent: know your viewer devices, bandwidth distribution, and latency tolerance before choosing parameters
4. **Hardware-aware architecture** — GPU selection, storage IOPS, and network topology must be co-designed; a transcoding cluster that starves on disk I/O or network egress is worse than a smaller, balanced system
5. **Cost per viewer-hour as the north star** — Every architectural decision (codec, edge count, storage tier, redundancy) should be traceable to its impact on cost per concurrent viewer per hour

## When to Use This Skill

- **Designing a streaming system** — From zero-to-production architecture for live or VOD streaming on owned hardware
- **Optimizing encoding quality** — Choosing codecs, tuning encoding parameters, designing ABR ladders, measuring VMAF
- **Planning CDN/edge deployment** — PoP placement, caching strategy, load balancing, failover, bandwidth cost modeling
- **Troubleshooting streaming issues** — Rebuffering, high latency, quality oscillation, origin overload, cache misses
- **Evaluating build vs buy** — Self-hosted vs cloud CDN, FFmpeg vs commercial transcoders, open-source vs licensed origin servers
- **Sizing hardware** — GPU selection for transcoding, storage capacity planning, network bandwidth provisioning
- **Protocol selection** — Choosing between HLS, DASH, CMAF, WebRTC, RTMP, SRT based on latency, scale, and compatibility requirements

> For Kubernetes infrastructure hosting these media workloads, see your cluster's `helm/` charts and `infra-config.yaml`.
> For cost modeling as a strategic business decision, see **trl-monetization-strategy**.

## Architecture Decision Framework

### Streaming Latency Classes

| Latency Class | Target | Protocol | Use Case | Complexity |
|---------------|--------|----------|----------|------------|
| Ultra-low | <1s | WebRTC (SFU) | Interactive, gaming, bidding | Very High |
| Low | 1–5s | LL-HLS / LL-DASH | Sports, live events, auctions | High |
| Standard | 10–30s | HLS / DASH | General live streaming, webinars | Medium |
| High | 30–60s | HLS (6–10s segments) | Reliability-first live (worship, talks) | Low |
| VOD | N/A | HLS / DASH | Movies, courses, archived content | Low |

### Codec Selection Matrix

| Factor | H.264/AVC | H.265/HEVC | VP9 | AV1 |
|--------|-----------|------------|-----|-----|
| Browser support | Universal | Safari + Edge + HW | Chrome + Firefox + Edge | Chrome + Firefox (growing) |
| Encode speed | Fast | 3–10x slower | 5–15x slower | 10–50x slower (SVT-AV1: faster) |
| Quality at same bitrate | Baseline | ~40% better | ~30% better | ~50% better |
| Hardware encode | NVENC, QSV, VCE | NVENC, QSV | Limited | NVENC (Ada+), QSV (Arc) |
| Licensing | Mature (MPEG-LA) | Complex (MPEG-LA + HEVC Advance) | Royalty-free | Royalty-free (AOMedia) |
| Recommended for | Compatibility-first | Quality/cost optimization | YouTube-ecosystem | Forward-looking / cost at scale |

> For full encoding ladders, GOP tuning, and hardware transcoding benchmarks, see **Codecs & Transcoding** (`references/codecs-and-transcoding.md`).

### Delivery Architecture Patterns

| Pattern | Description | Best For | Edge Count |
|---------|-------------|----------|------------|
| **Single origin** | Origin serves all clients directly | <100 concurrent, low latency tolerance | 0 |
| **Origin + managed CDN** | Origin behind Cloudflare/Fastly | <10K concurrent, global audience | Cloud-managed |
| **Hybrid CDN** | Self-hosted edges + cloud spillover | 1K–50K concurrent, cost-sensitive | 3–10 self-hosted |
| **Full self-hosted CDN** | Owned PoPs in multiple locations | >10K concurrent, long-running streams | 5–20+ |
| **Mesh federation** | Multiple sites connected via VPN/overlay | Distributed org, multi-site production | Per-site |

> For full CDN architecture, caching hierarchies, and PoP placement, see **CDN Distribution Architecture** (`references/cdn-distribution-architecture.md`).

### Storage Selection

| Storage Type | Use Case | Throughput | Cost/TB |
|-------------|----------|------------|---------|
| NVMe (local) | Origin hot cache, transcoding working files | 3–7 GB/s | $$$ |
| SSD (block) | Origin storage, segment cache | 500MB–2GB/s | $$ |
| HDD (block) | VOD library, warm archive | 100–300MB/s | $ |
| Object (MinIO/S3) | VOD archive, segment storage | Network-bound | $ |
| NFS/SMB | Shared access for multi-origin | Network-bound | $$ |

> For storage sizing calculations, tiering strategies, and K8s volume configs, see **Infrastructure & Pipelines** (`references/infrastructure-and-pipelines.md`).

## Quick Start Guides

### Design a Streaming System from Scratch
1. Define your latency class (see table above) — this locks in your protocol
2. Choose codec(s) based on viewer device landscape
3. Design your encoding ladder — see `references/codecs-and-transcoding.md`
4. Select delivery pattern based on concurrent viewer count
5. Size hardware — see `references/infrastructure-and-pipelines.md` for GPU/storage/network calculations
6. Plan monitoring — see `references/infrastructure-and-pipelines.md` for metrics and alerting

### Optimize an Existing Streaming Pipeline
1. Measure current quality: VMAF, rebuffer ratio, startup time — see `references/codecs-and-transcoding.md`
2. Profile the bottleneck: encoder, packager, origin, network, player — see `references/infrastructure-and-pipelines.md`
3. Tune encoding parameters: CRF, preset, GOP, B-frames — see `references/codecs-and-transcoding.md`
4. Optimize caching: segment TTL, manifest TTL, cache key design — see `references/cdn-distribution-architecture.md`
5. Iterate: measure → tune → measure

### Evaluate Self-Hosted vs Cloud CDN
1. Calculate your cost per viewer-hour at current and projected scale — see `references/cdn-distribution-architecture.md`
2. Price equivalent cloud CDN (egress + request costs)
3. Factor in control, latency, and reliability requirements
4. Consider hybrid: self-host for baseline, cloud for peak — see `references/infrastructure-and-pipelines.md`

### Troubleshoot Streaming Quality Issues
1. Identify the symptom: rebuffering, high latency, quality drops, startup failure
2. Map to pipeline stage: ingest → transcode → package → origin → edge → player
3. Consult the protocol reference for tuning parameters — see `references/streaming-protocols-and-packaging.md`
4. Check infrastructure metrics: GPU utilization, disk IOPS, network saturation — see `references/infrastructure-and-pipelines.md`

## Reference Guide

### When to Read Each Reference

| Task | Read These |
|------|-----------|
| **Choosing codecs or encoding parameters** | `codecs-and-transcoding.md` |
| **Designing encoding ladders or measuring quality** | `codecs-and-transcoding.md` |
| **Hardware transcoding (NVENC, QSV, VideoToolbox)** | `codecs-and-transcoding.md` |
| **FFmpeg encoding examples and rate control** | `codecs-and-transcoding.md` |
| **CDN architecture, caching, PoP placement** | `cdn-distribution-architecture.md` |
| **Load balancing, GeoDNS, anycast** | `cdn-distribution-architecture.md` |
| **Bandwidth cost modeling** | `cdn-distribution-architecture.md` |
| **HLS, DASH, CMAF protocol details** | `streaming-protocols-and-packaging.md` |
| **WebRTC, RTMP, SRT ingestion** | `streaming-protocols-and-packaging.md` |
| **DRM, encryption, license servers** | `streaming-protocols-and-packaging.md` |
| **ABR strategy and segment duration tradeoffs** | `streaming-protocols-and-packaging.md` |
| **K8s media pipelines, GPU scheduling** | `infrastructure-and-pipelines.md` |
| **Storage backends and tiering** | `infrastructure-and-pipelines.md` |
| **GPU selection and cost-per-stream** | `infrastructure-and-pipelines.md` |
| **Monitoring, metrics, observability** | `infrastructure-and-pipelines.md` |
| **Full end-to-end design walkthrough** | `worked-example-self-hosted-cdn.md` |
| **Architecture selection decision trees** | `decision-framework.md` |

All reference paths are relative to `references/`.

## Related Skills

- **kubernetes-engineer** — K8s cluster setup, Helm charts, and workload management for hosting media infrastructure
- **terraform-engineer** — Infrastructure provisioning for edge locations, DNS, and networking
- **dba-db-designer-and-tuning** — Database optimization for viewer analytics and content metadata at scale

## Bundled Resources

### References

- [codecs-and-transcoding.md](references/codecs-and-transcoding.md) — Codec comparison, encoding ladders, GOP tuning, hardware transcoding, VMAF, FFmpeg examples
- [cdn-distribution-architecture.md](references/cdn-distribution-architecture.md) — Origin design, edge caching, PoP placement, load balancing, GeoDNS, bandwidth cost modeling
- [streaming-protocols-and-packaging.md](references/streaming-protocols-and-packaging.md) — HLS, DASH, CMAF, WebRTC, RTMP, SRT, DRM, ABR strategies
- [infrastructure-and-pipelines.md](references/infrastructure-and-pipelines.md) — K8s media pipelines, GPU scheduling, storage backends, monitoring, cost analysis
- [decision-framework.md](references/decision-framework.md) — Architecture selection decision trees and comparison matrices
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role definition and execution workflows
- [worked-example-self-hosted-cdn.md](references/worked-example-self-hosted-cdn.md) — End-to-end walkthrough: designing a self-hosted streaming system

### Assets

- [project-tracker.md](assets/project-tracker.md) — Project tracking template for streaming infrastructure builds
- [encoding-ladder-template.md](assets/encoding-ladder-template.md) — Fillable template for defining custom encoding ladders
