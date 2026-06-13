# Worked Example: Self-Hosted Streaming CDN for a Gaming Platform

End-to-end walkthrough of designing a self-hosted streaming system for a mid-scale gaming/content platform.

---

## Scenario

A gaming community platform wants to stream live gameplay and VOD content to its members. They have a colocation presence in the US East region and want to minimize ongoing cloud costs.

**Requirements:**
- 2,000 peak concurrent viewers (500 average)
- 80% US-based, 15% EU, 5% rest-of-world
- Live streams: 1080p60 source, standard latency (10–20s acceptable)
- VOD library: growing by 50 hours/week
- 20 unique simultaneous live streams at peak
- Budget: $3,000–5,000/month
- Must work on all devices (mobile, desktop, smart TV)

## Step 1: Latency Class & Protocol Selection

From the decision framework: 10–20s latency → **Standard live → HLS with 4s segments**.

- Segments: 4 seconds (good balance of cache efficiency and latency)
- Playlist: sliding window of 5 segments (20s of buffer)
- LL-HLS not needed (no sub-5s latency requirement)
- CMAF segments for future HLS+DASH compatibility (single encode)

**Decision**: HLS with fMP4/CMAF segments, 4s duration, H.264 primary + AV1 for quality optimization.

## Step 2: Codec & Encoding Ladder

Given "must work on all devices" → H.264 is mandatory. AV1 as supplementary for bandwidth savings on supported browsers.

### Encoding Ladder

| Rung | Resolution | Codec | Bitrate | FPS | Audio | Notes |
|------|-----------|-------|---------|-----|-------|-------|
| 1 | 480p (854×480) | H.264 High | 1,400 kbps | 30 | AAC 128k | Mobile/slow connections |
| 2 | 720p (1280×720) | H.264 High | 3,000 kbps | 30 | AAC 128k | Standard mobile/tablet |
| 3 | 720p (1280×720) | H.264 High | 4,500 kbps | 60 | AAC 128k | HD 60fps |
| 4 | 1080p (1920×1080) | H.264 High | 6,000 kbps | 60 | AAC 128k | Full HD (primary) |
| 5 | 1080p (1920×1080) | AV1 Main | 3,500 kbps | 60 | AAC 128k | AV1 (Chrome/Edge/Firefox) |

Total per-stream output: ~5 rungs × ~4 Mbps average = ~20 Mbps per input stream.

### Encoding Parameters

```
H.264 (NVENC):
  - Preset: p4 (good quality-speed balance)
  - Rate control: VBR with max bitrate 1.5x target
  - GOP: 2s (half segment duration for good seek)
  - B-frames: 3
  - Profile: High, Level 4.2
  - VBV: target × 1.5

AV1 (SVT-AV1, software):
  - Preset: 8 (balanced speed/quality)
  - Rate control: VBR
  - GOP: 2s
  - Film grain synth: disabled
```

## Step 3: Delivery Architecture

2,000 concurrent at ~4 Mbps average = **8 Gbps peak egress**.

From the decision framework: 500–5K viewers → **Origin + edge cache nodes**.

### Architecture

```
                    ┌──────────────┐
                    │   Streamer   │
                    │  (OBS/SRT)   │
                    └──────┬───────┘
                           │ SRT
                           ▼
                    ┌──────────────┐
                    │   Ingest     │
                    │   Server     │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Transcoder  │
                    │  (GPU node)  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   Packager   │
                    │ (Shaka/Bento4│
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │    Origin    │
                    │   (Nginx)    │
                    │  + Storage   │
                    └──────┬───────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
       ┌──────▼──────┐ ┌──▼───────┐ ┌──▼───────┐
       │  Edge PoP   │ │ Edge PoP │ │Cloudflare│
       │  US East    │ │ US West  │ │ (EU+RoW) │
       │  (IX)       │ │ (IX)     │ │ fallback │
       └─────────────┘ └──────────┘ └──────────┘
```

**Delivery strategy:**
- US East viewers (80%): self-hosted edge at IX → lowest cost
- US West viewers: self-hosted edge at IX → good cost
- EU + rest of world (20%): Cloudflare free/bundled tier → acceptable cost

## Step 4: Hardware Sizing

### Transcoding

20 simultaneous streams × 5 rungs = 100 encode sessions.

NVENC (Turing/Ada) can handle ~25–30 1080p30 H.264 sessions per GPU.
With 60fps and mixed resolutions, derate to ~15–20 sessions per GPU.

100 sessions ÷ 15 sessions/GPU = **7 GPUs minimum** for peak.

The AV1 rung uses software encoding (SVT-AV1) — this runs on CPU.

**Hardware:**
- 2× transcoding servers, each with 2× NVIDIA T4 (used ~$400 each) = 4 GPUs
- 1× transcoding server with 2× NVIDIA L4 = 2 GPUs
- 1× CPU-heavy server (64-core AMD EPYC) for AV1 rungs
- Total: ~7 GPU equivalent + CPU for AV1

**Cost:**
- 2× GPU servers (used): ~$3,000 each = $6,000
- 1× L4 server: ~$4,000
- 1× CPU server: ~$3,000
- **Total transcoding capex: ~$13,000** (amortized over 36 months = ~$360/month)

### Storage

**Live segment cache (hot):**
20 streams × 5 rungs × 4s × 180 segments × ~4 Mbps avg ÷ 8 = ~360 GB
→ **1 TB NVMe** per origin server

**VOD library (warm):**
Growing 50 hours/week × 4 weeks × 20 Mbps avg = ~4.5 TB/month
Retention: 12 months = ~54 TB
→ **60 TB HDD array** (RAID6) + SSD cache for recent content

**Cost:**
- 2× 1TB NVMe (origin hot): ~$300
- 60 TB HDD array: ~$2,400
- SSD cache (4TB): ~$400
- **Total storage capex: ~$3,100** (amortized = ~$86/month)

### Network

**Peak egress:** 8 Gbps

IX peering at US East IX (e.g., Equinix NY):
- 10 Gbps port: ~$500/month
- Peering traffic: ~$0.10–0.30/Mbps committed
- Committed 5 Gbps @ $0.20/Mbps = $1,000/month

IX peering at US West IX:
- 1 Gbps port: ~$200/month
- Sufficient for 15% of traffic

Cloudflare for EU/ROW:
- Pro plan: $20/month per domain
- Egress: ~500 GB/month at EU rates → ~$5–15/month (Cloudflare doesn't charge egress!)

**Total network opex: ~$1,720/month**

### Total Cost Model

| Item | Monthly Capex | Monthly Opex |
|------|-------------|-------------|
| GPU transcoding servers | $360 | $50 (power) |
| CPU transcoding server | $83 | $20 (power) |
| Storage | $86 | $15 (power) |
| IX peering (East) | — | $1,500 |
| IX peering (West) | — | $200 |
| Cloudflare (EU fallback) | — | $25 |
| Colocation (4U + power) | — | $400 |
| Maintenance (10% time) | — | $500 |
| **Total** | **$529** | **$2,710** |
| **Grand total** | | **$3,239/month** |
| **Per viewer-hour** (avg 500 concurrent, 8hr/day) | | **$0.0027** |

**Comparison with cloud CDN:**
- Cloud egress at $0.02/GB: 500 avg × 4 Mbps × 8hr × 30d = ~216 TB/month = ~$4,320/month (egress alone)
- Plus cloud transcoding: ~$2,000/month
- **Cloud total: ~$6,320/month** → self-hosted saves ~$3,000/month

## Step 5: Configuration Examples

### Nginx Origin Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name origin.example.com;

    ssl_certificate /etc/nginx/ssl/origin.pem;
    ssl_certificate_key /etc/nginx/ssl/origin-key.pem;

    # Media segment serving
    location /live/ {
        alias /var/media/live/;

        # CORS for player
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods 'GET, OPTIONS';

        # Caching headers for edge
        add_header Cache-Control "public, max-age=86400";

        # Segment files
        location ~ \.(m4s|ts)$ {
            add_header Cache-Control "public, max-age=86400";
            expires 24h;
        }

        # Manifest/playlist - short cache for live
        location ~ \.(m3u8|mpd)$ {
            add_header Cache-Control "public, max-age=2";
            expires 2s;
            add_header Content-Type "application/vnd.apple.mpegurl";
        }
    }

    # VOD content
    location /vod/ {
        alias /var/media/vod/;

        add_header Access-Control-Allow-Origin *;
        add_header Cache-Control "public, max-age=604800";
        expires 7d;
    }
}
```

### Edge Cache (Nginx Proxy Cache)

```nginx
proxy_cache_path /var/cache/nginx/media levels=1:2
                 keys_zone=media_cache:100m
                 max_size=500g
                 inactive=24h
                 use_temp_path=off;

server {
    listen 443 ssl http2;
    server_name edge.example.com;

    location /live/ {
        proxy_cache media_cache;

        # Segments: cache for 24h
        location ~ \.(m4s|ts)$ {
            proxy_cache_valid 200 24h;
            proxy_cache_key $uri;
            add_header X-Cache-Status $upstream_cache_status;
        }

        # Manifests: cache for 2s, serve stale while revalidating
        location ~ \.(m3u8|mpd)$ {
            proxy_cache_valid 200 2s;
            proxy_cache_key $uri;
            add_header X-Cache-Status $upstream_cache_status;
            proxy_cache_lock on;
        }

        proxy_pass https://origin.example.com;
        proxy_set_header Host origin.example.com;
    }
}
```

### FFmpeg Live Transcode Command

```bash
# Ingest SRT → Transcode to 5-rung ABR ladder → HLS/CMAF output
ffmpeg \
  -i "srt://ingest.example.com:9000?streamid=stream1" \
  -filter_complex "
    [0:v]split=4[v1][v2][v3][v4];
    [v1]scale=854:480,fps=30[480p];
    [v2]scale=1280:720,fps=30[720p30];
    [v3]scale=1280:720,fps=60[720p60];
    [v4]scale=1920:1080,fps=60[1080p60]
  " \
  -map "[480p]" -c:v:0 h264_nvenc -b:v:0 1400k -maxrate:v:0 2100k \
    -bufsize:v:0 2800k -profile:v:0 high -preset p4 -g 60 \
  -map "[720p30]" -c:v:1 h264_nvenc -b:v:1 3000k -maxrate:v:1 4500k \
    -bufsize:v:1 6000k -profile:v:1 high -preset p4 -g 60 \
  -map "[720p60]" -c:v:2 h264_nvenc -b:v:2 4500k -maxrate:v:2 6750k \
    -bufsize:v:2 9000k -profile:v:2 high -preset p4 -g 120 \
  -map "[1080p60]" -c:v:3 h264_nvenc -b:v:3 6000k -maxrate:v:3 9000k \
    -bufsize:v:3 12000k -profile:v:3 high -preset p4 -g 120 \
  -map 0:a -c:a aac -b:a 128k -ac 2 \
  -f hls \
  -hls_time 4 \
  -hls_playlist_type event \
  -hls_segment_type fmp4 \
  -hls_segment_filename "/var/media/live/stream1/%v/seg_%03d.m4s" \
  -master_pl_name "master.m3u8" \
  -var_stream_map "v:0,a:0 v:1,a:0 v:2,a:0 v:3,a:0" \
  "/var/media/live/stream1/%v/index.m3u8"
```

## Step 6: Monitoring Setup

### Key Metrics to Track

| Metric | Source | Alert Threshold |
|--------|--------|----------------|
| Concurrent viewers | Nginx access logs → Prometheus | >2,500 (capacity warning) |
| Edge cache hit ratio | Nginx stub_status | <85% |
| Transcode latency | FFmpeg progress logging | >5s behind real-time |
| GPU utilization | nvidia-smi → Prometheus | >90% sustained |
| Origin response time | Nginx request timing | >100ms p99 |
| Egress bandwidth | Switch SNMP → Prometheus | >7 Gbps (approaching capacity) |
| Viewer rebuffer % | Player telemetry | >1% |
| Average VMAF | Periodic spot-check | <90 at 1080p |

### Prometheus Metrics Example

```yaml
# Media-specific Prometheus scrape configs
scrape_configs:
  - job_name: 'nginx-media'
    metrics_path: /stub_status
    static_configs:
      - targets: ['origin:9113', 'edge-east:9113', 'edge-west:9113']

  - job_name: 'nvidia-gpu'
    static_configs:
      - targets: ['transcode1:9835', 'transcode2:9835']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['origin:9100', 'edge-east:9100', 'edge-west:9100',
                   'transcode1:9100', 'transcode2:9100']
```

## Lessons Learned

1. **Start with H.264 only**, add AV1/HEVC rungs later — NVENC H.264 is 10x faster to debug than multi-codec
2. **4s segments are the sweet spot** for standard-live HLS — shorter segments increase origin load without proportional latency benefit
3. **IX peering is the game-changer** — without it, self-hosted bandwidth costs more than cloud CDN. If you can't get IX access, reconsider the self-hosted approach
4. **Cache warming matters for live events** — pre-populate edges 5 minutes before a major stream start
5. **Monitor viewer-side quality**, not just server metrics — server-side health doesn't predict rebuffering if the last-mile is congested
