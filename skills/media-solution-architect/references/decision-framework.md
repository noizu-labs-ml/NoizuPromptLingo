# Decision Framework — Streaming Architecture Selection

Structured decision trees for choosing the right architecture, codec, protocol, and deployment strategy.

---

## 1. Latency Class → Protocol Selection

```
What is your maximum acceptable latency from live to viewer?
│
├── <500ms (interactive, two-way)
│   └── WebRTC (SFU) — Janus, mediasoup, LiveKit
│       Constraints: max ~500 concurrent per SFU, cascading needed for scale
│       Cost: high (TURN servers, SFU compute)
│
├── 1–3s (near-live, sports, auctions)
│   └── LL-HLS or LL-DASH with CMAF + chunked transfer
│       Segment duration: 1s (partial segments) + blocking playlist reload
│       Tradeoff: higher origin load, more frequent manifest requests
│
├── 5–15s (standard live, webinars, events)
│   └── HLS or DASH with 2–4s segments
│       Best balance of latency, cache efficiency, and player compatibility
│       Recommended default for most live streaming
│
├── 15–45s (reliability-first, worship, talks)
│   └── HLS with 6–10s segments
│       Maximum cache hit ratio, minimum origin load
│       Best for unreliable viewer connections
│
└── N/A (pre-recorded content)
    └── HLS or DASH with 6–10s segments
        Optimize for cache hit ratio and seek performance
        Consider CMAF for single-encode HLS+DASH delivery
```

## 2. Viewer Count → Delivery Architecture

```
How many concurrent viewers do you expect at peak?
│
├── <50 (internal, dev, test)
│   └── Single origin server — no CDN needed
│       Hardware: 1 server (transcode + origin + web)
│       Network: 100 Mbps egress sufficient
│
├── 50–500 (small community, niche content)
│   └── Origin + reverse proxy cache
│       Hardware: 1–2 servers (transcode on one, origin+cache on another)
│       Network: 500 Mbps–1 Gbps egress
│       Consider: Cloudflare free tier in front of origin
│
├── 500–5,000 (mid-scale live, gaming, education)
│   └── Origin + edge cache nodes or managed CDN
│       Self-hosted: 1 origin + 2–3 edge nodes
│       Alternative: Cloudflare/Fastly in front of origin
│       Network: 1–5 Gbps egress
│
├── 5,000–50,000 (large events, popular streams)
│   └── Hybrid CDN (self-hosted edges + cloud spillover)
│       Self-hosted: 1 origin + 5–10 edge nodes at IX points
│       Cloud: CDN for overflow and distant geographies
│       Network: 5–50 Gbps egress
│
└── 50,000+ (major events, broadcast-scale)
    └── Multi-CDN with traffic management
        2+ CDN providers + traffic router
        Self-hosted edges at major IX points + cloud CDN
        Network: 50+ Gbps egress
        Requires: CDN traffic management (Conviva, Mux Data, Streamroot)
```

## 3. Codec Selection Decision Tree

```
What are your primary viewer devices?
│
├── Mixed/unknown (must work everywhere)
│   ├── H.264 Main/High — universal compatibility
│   │   Add HEVC/AV1 as supplementary for quality/cost optimization
│   └── Encoding ladder: H.264 for all rungs, or H.264 for mobile + HEVC for TV/desktop
│
├── Primarily modern browsers (Chrome, Edge, Firefox)
│   ├── AV1 for primary delivery (best compression, royalty-free)
│   ├── H.264 as fallback for older devices
│   └── Consider: VP9 as middle ground (wider support than AV1, worse compression)
│
├── Apple ecosystem heavy (Safari, iOS, Apple TV)
│   ├── HEVC well-supported on Apple hardware (A9+ chips)
│   ├── H.264 as universal fallback
│   └── Note: AV1 support limited (M1+ Macs, iPhone 15 Pro+)
│
├── Smart TV / Set-top box
│   ├── Check specific model capabilities
│   ├── HEVC hardware decode common on 2016+ models
│   └── H.264 as safe fallback
│
└── Mobile-only (Android/iOS)
    ├── H.264 Baseline for lowest rungs (old Android)
    ├── HEVC for mid-to-high rungs (modern mobile SoCs)
    └── Consider: data cost sensitivity → lower bitrates, fewer rungs
```

### Codec Licensing Reality Check

| Codec | Patent Status | Cost Implications |
|-------|--------------|-------------------|
| H.264/AVC | MPEG-LA patent pool | Encoder/decoder licensing (often bundled with hardware/software), content royalties for >12min free content waived since 2010 |
| H.265/HEVC | Multiple patent pools (MPEG-LA, HEVC Advance, Velos Media) | Complex, expensive. Encoder licensing ~$0.20–2.00/unit. Content distribution fees possible. **Biggest barrier to self-hosted HEVC delivery** |
| VP9 | Google (royalty-free) | No licensing fees. Limited hardware encode support. |
| AV1 | AOMedia (royalty-free) | No licensing fees. Growing hardware support. Cisco, Google, Netflix backing. **Best long-term choice for self-hosted.** |

**Recommendation for self-hosted**: H.264 for compatibility + AV1 for cost optimization. Avoid HEVC unless you have specific licensing clearance.

## 4. Transcoding Hardware Selection

```
What is your transcoding workload?
│
├── VOD only (batch processing, no real-time requirement)
│   ├── Software encoding (x264/x265/SVT-AV1) — best quality per bitrate
│   ├── CPU-heavy servers (AMD EPYC, Intel Xeon)
│   ├── Can use spot/preemptible instances if cloud
│   └── Cost optimization: slower preset = better compression = less bandwidth
│
├── Live, <5 concurrent streams
│   ├── NVIDIA T4 or L4 — good value, single-slot
│   ├── NVENC for H.264/HEVC, software for AV1
│   └── ~$2K per server for transcoding
│
├── Live, 5–50 concurrent streams
│   ├── NVIDIA A10 (24GB) or RTX A4000 — density per $
│   ├── NVENC sessions: ~15–30 simultaneous 1080p H.264 per GPU
│   └── ~$5–10K per transcoding node
│
├── Live, 50+ concurrent streams
│   ├── Multiple A10/L4 GPUs per server (density) or
│   ├── NVIDIA L40S (48GB, Ada architecture) for AV1 + density
│   └── Consider: CPU transcoding farm for ABR rungs, GPU for highest quality
│
└── Budget-constrained
    ├── Used NVIDIA P40/P4 (~$200–400) — Pascal NVENC, good for H.264
    ├── Used T4 (~$400–800) — Turing NVENC, good for H.264 + HEVC
    ├── Intel Arc GPUs — excellent AV1 encode quality at low cost (~$150–300)
    └── Software encoding on high-core-count CPU as baseline
```

### GPU Quick Comparison

| GPU | Architecture | NVENC Gen | H.264 1080p30 Sessions | HEVC | AV1 | Power | New Price | Used Price |
|-----|-------------|-----------|------------------------|------|-----|-------|-----------|------------|
| T4 | Turing | 7th | ~15–20 | Yes | No | 70W | ~$1,100 | ~$400–600 |
| L4 | Ada | 8th | ~20–30 | Yes | Yes | 72W | ~$1,500 | N/A |
| A10 | Ampere | 7.5 | ~25–35 | Yes | No | 150W | ~$3,000 | ~$1,500 |
| A10G | Ampere | 7.5 | ~25–35 | Yes | No | 150W | AWS only | N/A |
| L40S | Ada | 8th | ~30–40 | Yes | Yes | 350W | ~$6,000 | N/A |
| RTX 4090 | Ada | 8th | ~25–35 | Yes | Yes | 450W | ~$1,600 | ~$1,200 |
| Intel Arc A380 | Xe HPG | — | N/A | Yes | Yes | 75W | ~$140 | ~$100 |
| Intel Arc A770 | Xe HPG | — | N/A | Yes | Yes | 225W | ~$290 | ~$200 |

Note: "Sessions" are approximate 1080p30 real-time encodes. Actual count depends on ABR rungs per stream, quality preset, and whether simultaneous multi-codec output is needed.

## 5. Storage Decision Tree

```
What are your storage needs?
│
├── Transcoding working files (hot, high IOPS)
│   └── Local NVMe — 1–4TB per transcoding node
│       Minimum: 1GB/s sequential write per concurrent 4K encode
│
├── Live origin segment cache (hot, moderate IOPS)
│   └── NVMe or fast SSD — 500GB–2TB per origin
│       Size = concurrent streams × rungs × segment_duration × max_segments × bitrate
│       Example: 10 streams × 5 rungs × 4s × 180 segments × 6 Mbps ≈ 270 GB
│
├── VOD origin (warm, sequential reads)
│   └── SSD or HDD with SSD cache — TB scale
│       Size = hours_of_content × avg_bitrate × redundancy
│       Example: 1000 hours × 8 Mbps × 1.5 redundancy ≈ 5.4 TB
│
├── VOD archive (cold, rarely accessed)
│   └── Object storage (MinIO/S3) or HDD — 10+ TB
│       Lifecycle policy: move from SSD → HDD → object after N days
│
└── Multi-origin shared access
    ├── NFS/SMB share on dedicated storage server
    ├── Or: object storage as shared origin (MinIO distributed mode)
    └── Avoid: PVC ReadWriteMany for high-throughput media workloads
```

## 6. Self-Hosted vs Cloud CDN Decision

```
Should you self-host, use cloud CDN, or go hybrid?
│
├── Self-host when:
│   ├── You have predictable, high-volume traffic (>5 Gbps sustained egress)
│   ├── You can access IX peering (dramatically reduces bandwidth cost)
│   ├── You have locations in/near your viewer population
│   ├── Your content is long-duration (live events, 24/7 streams)
│   └── You need maximum control over caching, routing, and failover
│
├── Use cloud CDN when:
│   ├── Traffic is bursty or unpredictable
│   ├── Geographic distribution is wide (global audience, few self-hosted sites)
│   ├── You're below the scale where IX peering makes financial sense
│   ├── Time-to-market matters more than cost optimization
│   └── You want managed DDoS protection and TLS certificate management
│
└── Go hybrid when:
    ├── You have baseline traffic that justifies self-hosted hardware
    ├── Peak traffic exceeds your self-hosted capacity regularly
    ├── You have a primary geographic cluster but distant viewers too
    ├── You want cost optimization without sacrificing reliability
    └── Typical setup: self-hosted at IX for local, cloud CDN for overflow + global
```

### Cost Break-Even Points (approximate)

| Concurrent Viewers | Avg Bitrate | Self-Hosted Monthly | Cloud CDN Monthly | Break-Even |
|--------------------|-------------|--------------------|--------------------|------------|
| 100 | 5 Mbps | N/A (not viable) | ~$150 | Cloud wins |
| 500 | 5 Mbps | ~$800 (single server) | ~$750 | Roughly equal |
| 2,000 | 5 Mbps | ~$1,500 (with IX peering) | ~$3,000 | Self-hosted wins |
| 10,000 | 5 Mbps | ~$4,000 (3 PoPs + IX) | ~$15,000 | Self-hosted wins big |
| 50,000 | 5 Mbps | ~$15,000 (5+ PoPs + IX) | ~$75,000 | Self-hosted dominates |

Cloud CDN pricing based on ~$0.01–0.12/GB egress (varies by provider, region, volume).
Self-hosted assumes IX peering at $0.10–0.50/Mbps committed + hardware amortization over 36 months.

## 7. Ingest Protocol Selection

```
How will content reach your transcoding pipeline?
│
├── Remote camera / on-location encoder
│   ├── SRT over public internet — reliable, 0.5–3s latency
│   ├── SRT with bonding (multiple links) — unreliable internet
│   ├── RTMPS — legacy compatibility, limited to H.264 1080p30
│   └── WHIP (WebRTC-HTTP) — ultra-low-latency ingest
│
├── Studio / same-network encoder
│   ├── RTMP — simple, widely supported by OBS/hardware encoders
│   ├── SRT — if you need reliability over imperfect LAN/WAN
│   └── SMPTE 2110 — broadcast-grade (requires specialized network)
│
├── Software encoder (OBS, vMix, FFmpeg)
│   ├── RTMP/RTMPS — universal software support
│   ├── SRT — growing support in OBS, vMix
│   └── WHIP — emerging, good for browser-based encoders
│
└── Hardware encoder (Teradek, Kiloview, AJA)
    ├── RTMP — universal hardware support
    ├── SRT — modern hardware encoders support it
    └── Some support RTSP (LAN only, no reliability over internet)
```

## Quick Reference: Architecture Patterns by Scale

| Scale | Ingest | Transcode | Package | Origin | Edge | DRM |
|-------|--------|-----------|---------|--------|------|-----|
| <50 | RTMP | CPU (x264) | FFmpeg | Nginx | None | No |
| 50–500 | RTMP/SRT | 1 GPU (NVENC) | FFmpeg | Nginx | Nginx cache | Optional |
| 500–5K | SRT/RTMP | 1–2 GPUs | Shaka/Bento4 | Nginx cluster | 2–3 edge nodes | Optional |
| 5K–50K | SRT + failover | GPU cluster | Shaka cluster | Origin shield + origins | 5–10 PoPs | Multi-DRM |
| 50K+ | Redundant SRT | GPU farm | Dedicated packagers | Multi-origin + shield | 10+ PoPs + cloud CDN | Multi-DRM |
