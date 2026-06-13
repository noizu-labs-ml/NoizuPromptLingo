# Video Codecs and Transcoding: Technical Reference

A comprehensive inside-baseball reference for building CDN/media streaming architectures. Covers codec internals, encoding ladders, hardware acceleration, perceptual quality metrics, and production-grade FFmpeg recipes.

---

## Table of Contents

1. [Codec Comparison Matrix](#1-codec-comparison-matrix)
2. [Encoding Ladders](#2-encoding-ladders)
3. [GOP Structure Tuning](#3-gop-structure-tuning)
4. [B-Frame Strategies](#4-b-frame-strategies)
5. [Hardware Transcoding](#5-hardware-transcoding)
6. [Perceptual Quality Metrics](#6-perceptual-quality-metrics)
7. [FFmpeg Encoding Examples](#7-ffmpeg-encoding-examples)
8. [Rate Control Modes](#8-rate-control-modes)

---

## 1. Codec Comparison Matrix

### H.264/AVC (MPEG-4 Part 10)

| Property | Detail |
|---|---|
| **Standard** | ITU-T H.264 / ISO/IEC 14496-10 |
| **First released** | 2003 |
| **Royalty status** | Patents largely expired (last MPEG LA pool terms expired ~2024). Effectively royalty-free for most uses in 2026. |
| **Encode speed** | Fastest among all modern codecs. x264 veryfast: real-time 4K60 on modern CPUs; medium: ~120 fps 1080p on 16-core. |
| **Decode complexity** | Lowest. Decoded by literally everything with a screen. |
| **Quality at same bitrate** | Baseline. All other codecs in this matrix beat it by 30-50% at equivalent perceptual quality. |
| **Browser support** | 99%+ globally. Every browser, every device, every era. The universal fallback. |
| **Hardware decode** | Universal. Every GPU since ~2005, every mobile SoC since ~2008. |
| **Max resolution** | Up to 4K with High/High 10 profile (Level 5.1). 8K possible with Level 6.x but rarely used. |
| **Profiles for streaming** | High (8-bit 4:2:0) for most content. High 10 for 10-bit. Baseline for legacy devices (no B-frames, no CABAC). |
| **Best for** | Universal compatibility baseline, live streaming where decoder reach matters most, legacy device support, real-time communication (WebRTC baseline). |

### H.265/HEVC

| Property | Detail |
|---|---|
| **Standard** | ITU-T H.265 / ISO/IEC 23008-2 |
| **First released** | 2013 |
| **Royalty status** | Actively licensed. Three separate patent pools: MPEG LA, Access Advance (formerly HEVC Advance/Via Licensing), and Velos Media. Per-unit and per-subscriber fees apply. Cost structure is the primary barrier to web adoption. Updated May 2026. |
| **Encode speed** | ~3-5x slower than H.264 at equivalent preset. x265 medium: ~40-60 fps 1080p on 16-core. Hardware encoders (NVENC, QSV) close the gap to near real-time. |
| **Decode complexity** | ~2-3x H.264. Requires dedicated hardware for mobile/4K playback. |
| **Quality at same bitrate** | ~40-50% better than H.264 at equivalent perceptual quality. ~15-25% worse than AV1. |
| **Browser support** | ~85-90%. Safari 11+ (native), Chrome 107+ (hardware-dependent), Edge 107+, Firefox 120+ (platform-dependent), Samsung Internet 21+. WebRTC HEVC arrived Chrome 136 (2025) but Safari/Firefox WebRTC stacks still lack it. |
| **Hardware decode** | Excellent. All modern GPUs (NVIDIA Maxwell+, Intel Kaby Lake+, AMD Polaris+). Mobile: Snapdragon 820+, Apple A9+, Exynos 8890+, MediaTek Helio P60+. Near-universal on devices sold after 2018. |
| **Max resolution** | 8K at 120 fps (Level 6.1). |
| **Profiles for streaming** | Main (8-bit 4:2:0), Main 10 (10-bit 4:2:0, essential for HDR), Main Still Picture. |
| **Best for** | 4K/HDR content delivery where decoder support is strong and licensing costs are acceptable. Premium OTT services. Live streaming with hardware encoding when bandwidth savings matter and target devices are known. |

### AV1 (AOMedia Video 1)

| Property | Detail |
|---|---|
| **Standard** | AOMedia Video 1, developed by Alliance for Open Media (Google, Mozilla, Cisco, Amazon, Netflix, AMD, NVIDIA, Apple, Intel, Microsoft, etc.) |
| **First released** | 2018 (spec), practical encoder maturity ~2022 |
| **Royalty status** | Royalty-free. BSD/Apache 2.0 licensed reference implementation. No patent pools. The primary strategic advantage over HEVC. |
| **Encode speed** | Slowest. SVT-AV1 preset 6 (~x265 slow quality): ~15-25 fps 1080p on 16-core. SVT-AV1 preset 8 (~x265 medium): ~40-60 fps. Hardware AV1 encode: Ada Lovelace NVENC and Intel Arc/QSV only (2024+). |
| **Decode complexity** | Highest. ~1.5-2x HEVC. Hardware decode essential for 4K. |
| **Quality at same bitrate** | ~30% better than HEVC, ~50-55% better than H.264 at equivalent perceptual quality. The efficiency leader. |
| **Browser support** | ~90-93%. Chrome 69+, Firefox 67+, Edge 75+, Opera 57+, Samsung Internet 15+. Safari: hardware-dependent (M3+ Macs, iPhone 15 Pro, iPhone 16+). The Safari limitation is the last major gap. |
| **Hardware decode** | GPUs: NVIDIA RTX 30-series (Ampere)+ decode, RTX 40-series (Ada) encode+decode. Intel Arc Alchemist+, 12th-gen Core+ iGPU. AMD RDNA3 (RX 7000-series)+. Mobile: Snapdragon 8 Gen 2+, MediaTek Dimensity 1000+, Apple M3+/A17 Pro+. Mid-tier SoC support still catching up as of 2026. |
| **Max resolution** | 8K at 120 fps. |
| **Profiles for streaming** | Main (8/10-bit 4:2:0), High (12-bit 4:4:4), Professional. |
| **Best for** | Large-scale VOD delivery where bandwidth costs dominate. Long-term strategic bet. On-demand encoding where encode time is less critical. Web delivery where royalty-free is a requirement. Growing live streaming support as hardware encoders mature. |

### VP9 (Google WebM / libvpx)

| Property | Detail |
|---|---|
| **Standard** | Google-developed, part of WebM project |
| **First released** | 2013 (initial), VP9.1 ~2016 |
| **Royalty status** | Royalty-free. Google holds key patents but provides royalty-free license. |
| **Encode speed** | Slow. libvpx-vp9: ~20-40 fps 1080p on 16-core at reasonable quality. No mainstream hardware encoder support (decode only on hardware). |
| **Decode complexity** | Moderate. Similar to HEVC. |
| **Quality at same bitrate** | ~20-30% better than H.264. ~10-20% worse than HEVC. ~30-40% worse than AV1. The weakest of the four modern codecs by quality. |
| **Browser support** | ~96%. Chrome, Firefox, Edge, Opera, Samsung Internet. Safari 14+ (macOS Big Sur, iOS 14). The second most universal codec after H.264. YouTube's 4K desktop default. |
| **Hardware decode** | Good. NVIDIA GTX 10-series+, Intel Kaby Lake+, AMD RX 400-series+. Mobile: Snapdragon 835+, Apple A12+, Exynos 9810+. |
| **Max resolution** | 8K (Profile 2, 10/12-bit). |
| **Profiles for streaming** | Profile 0 (8-bit 4:2:0), Profile 1 (8-bit 4:2:2/4:4:4), Profile 2 (10/12-bit). |
| **Best for** | YouTube delivery (native VP9 pipeline). WebRTC (mandatory-to-implement video codec in WebRTC alongside H.264). Legacy open-source alternative before AV1 maturity. Declining strategic relevance as AV1 supersedes it. |

### Codec Selection Decision Framework

```
Need universal compatibility (99%+)?        --> H.264
Need best quality at lowest bitrate?        --> AV1
Need royalty-free + better than H.264?      --> AV1 (or VP9 as fallback)
Need 4K HDR with known decoder support?     --> HEVC Main 10
Building for WebRTC?                        --> H.264 (mandatory) + VP9 (optional)
Encoding for Apple ecosystem?               --> HEVC (HLS native) or H.264 fallback
Large-scale CDN where bandwidth = $?        --> AV1 for VOD, H.264 baseline + AV1 ladder
Live streaming with GPU encoding?           --> H.264 (NVENC/QSV) or HEVC (NVENC Ada+)
Ultra-low-latency live (<500ms)?            --> H.264 with minimal B-frames
```

---

## 2. Encoding Ladders

Encoding ladders define the set of resolution/bitrate/framerate rungs offered to ABR (Adaptive Bitrate) players. The player selects the highest rung that fits the viewer's current bandwidth.

### H.264 Encoding Ladder (Maximum Compatibility)

The workhorse ladder. Every device can play every rung.

| Rung | Resolution | Framerate | VOD Bitrate (Mbps) | Live Bitrate (Mbps) | Pixel Count |
|------|-----------|-----------|--------------------|--------------------|-------------|
| 1    | 426x240   | 24/30     | 0.3 - 0.5          | 0.4 - 0.6          | 102,240     |
| 2    | 640x360   | 24/30     | 0.7 - 1.0          | 0.8 - 1.2          | 230,400     |
| 3    | 854x480   | 24/30     | 1.2 - 2.0          | 1.5 - 2.5          | 409,920     |
| 4    | 1280x720  | 30        | 2.5 - 4.0          | 3.0 - 5.0          | 921,600     |
| 5    | 1280x720  | 60        | 3.5 - 5.5          | 4.0 - 6.5          | 921,600     |
| 6    | 1920x1080 | 30        | 5.0 - 8.0          | 6.0 - 9.0          | 2,073,600   |
| 7    | 1920x1080 | 60        | 7.0 - 12.0         | 8.0 - 14.0         | 2,073,600   |
| 8    | 2560x1440 | 30        | 10.0 - 16.0        | 12.0 - 18.0        | 3,686,400   |
| 9    | 2560x1440 | 60        | 14.0 - 22.0        | 16.0 - 25.0        | 3,686,400   |
| 10   | 3840x2160 | 30        | 20.0 - 35.0        | 25.0 - 40.0        | 8,294,400   |
| 11   | 3840x2160 | 60        | 30.0 - 50.0        | 35.0 - 55.0        | 8,294,400   |

**H.264-specific notes:**
- Use High profile (not Main or Baseline) for all rungs above 480p.
- Baseline profile only for legacy devices (no CABAC, no B-frames -- 15-20% less efficient).
- Level 4.1 for 1080p60, Level 5.0/5.1 for 1440p/4K.
- Audio: AAC-LC 96-128 kbps for stereo, AAC-LC 192-256 kbps for 5.1 surround.

### H.265/HEVC Encoding Ladder (Efficient Delivery)

~40-50% bandwidth savings vs H.264 at equivalent quality. Use where decoder support is confirmed.

| Rung | Resolution | Framerate | VOD Bitrate (Mbps) | Live Bitrate (Mbps) | H.264 Equiv. Savings |
|------|-----------|-----------|--------------------|--------------------|-----------------------|
| 1    | 426x240   | 24/30     | 0.15 - 0.25        | 0.2 - 0.3          | ~50%                  |
| 2    | 640x360   | 24/30     | 0.4 - 0.6          | 0.5 - 0.7          | ~43%                  |
| 3    | 854x480   | 24/30     | 0.7 - 1.2          | 0.9 - 1.5          | ~42%                  |
| 4    | 1280x720  | 30        | 1.5 - 2.5          | 2.0 - 3.0          | ~40%                  |
| 5    | 1280x720  | 60        | 2.0 - 3.5          | 2.5 - 4.0          | ~43%                  |
| 6    | 1920x1080 | 30        | 3.0 - 5.0          | 3.5 - 5.5          | ~40%                  |
| 7    | 1920x1080 | 60        | 4.5 - 7.0          | 5.0 - 8.0          | ~42%                  |
| 8    | 2560x1440 | 30        | 6.0 - 10.0         | 7.0 - 11.0         | ~38%                  |
| 9    | 2560x1440 | 60        | 9.0 - 14.0         | 10.0 - 16.0        | ~36%                  |
| 10   | 3840x2160 | 30        | 12.0 - 20.0        | 15.0 - 25.0        | ~40%                  |
| 11   | 3840x2160 | 60        | 18.0 - 30.0        | 22.0 - 35.0        | ~40%                  |

**HEVC-specific notes:**
- Use Main 10 profile for all rungs if targeting modern devices (10-bit avoids banding, HDR support).
- Use Main (8-bit) only if you must support older HEVC decoders.
- HEVC shines brightest at higher resolutions (1440p, 4K) where the efficiency gains compound.
- For HDR10/HLG content, Main 10 profile is mandatory.

### AV1 Encoding Ladder (Next-Gen Efficiency)

~30% bandwidth savings vs HEVC, ~50-55% vs H.264. The efficiency leader. Use where encoder budget allows and decoder support is confirmed.

| Rung | Resolution | Framerate | VOD Bitrate (Mbps) | Live Bitrate (Mbps) | H.264 Equiv. Savings |
|------|-----------|-----------|--------------------|--------------------|-----------------------|
| 1    | 426x240   | 24/30     | 0.1 - 0.15         | 0.15 - 0.2         | ~67%                  |
| 2    | 640x360   | 24/30     | 0.25 - 0.4         | 0.35 - 0.5         | ~60%                  |
| 3    | 854x480   | 24/30     | 0.5 - 0.8          | 0.6 - 1.0          | ~58%                  |
| 4    | 1280x720  | 30        | 1.0 - 1.8          | 1.5 - 2.5          | ~55%                  |
| 5    | 1280x720  | 60        | 1.5 - 2.5          | 2.0 - 3.0          | ~55%                  |
| 6    | 1920x1080 | 30        | 2.0 - 3.5          | 3.0 - 4.5          | ~55%                  |
| 7    | 1920x1080 | 60        | 3.5 - 5.0          | 4.0 - 6.0          | ~55%                  |
| 8    | 2560x1440 | 30        | 5.0 - 8.0          | 6.0 - 9.0          | ~50%                  |
| 9    | 2560x1440 | 60        | 7.0 - 11.0         | 8.0 - 13.0         | ~50%                  |
| 10   | 3840x2160 | 30        | 10.0 - 16.0        | 12.0 - 20.0        | ~50%                  |
| 11   | 3840x2160 | 60        | 15.0 - 25.0        | 18.0 - 30.0        | ~50%                  |

**AV1-specific notes:**
- Bitrate savings are content-dependent: animation/screen content sees 40-60% savings vs HEVC, high-motion sports sees 20-30%.
- AV1 CRF values are offset from H.264: AV1 CRF 28-30 roughly equals H.264 CRF 20-23 at smaller file sizes.
- Use SVT-AV1 for practically all production encoding (see Section 5). libaom for maximum quality offline encoding. rav1e for software diversity.

### Practical Ladder Design Guidance

**Minimum viable ladder (4 rungs):**
```
360p @ 1.0 Mbps   -- mobile/slow connections
720p @ 3.5 Mbps   -- tablet/standard
1080p @ 6.0 Mbps  -- desktop/wifi
1080p60 @ 10 Mbps -- desktop/fast connections
```

**Full production ladder (7-8 rungs, H.264):**
```
240p @ 0.4 Mbps   -- thumbnail quality fallback
360p @ 1.0 Mbps   -- mobile cellular
480p @ 1.8 Mbps   -- mobile wifi
720p @ 3.5 Mbps   -- tablet
720p60 @ 5.0 Mbps -- fast mobile
1080p @ 7.0 Mbps  -- desktop standard
1080p60 @ 11 Mbps -- desktop high quality
4K @ 35 Mbps      -- premium / TV
```

**Multi-codec ladder strategy:**
```
For each piece of content, produce:
  - H.264 ladder (4-6 rungs)     -- universal baseline
  - HEVC ladder (3-4 rungs)      -- efficient for supported devices (720p+ only)
  - AV1 ladder (3-4 rungs)       -- maximum efficiency for modern devices (720p+ only)

Device dispatch logic:
  - AV1 hardware decode detected?  --> Serve AV1 ladder
  - HEVC hardware decode detected? --> Serve HEVC ladder
  - Otherwise:                      --> Serve H.264 ladder
```

**Bitrate selection factors:**
- Content type: Talking heads = lower end of range. Sports/gaming = upper end. Animation = 20-30% below average.
- Per-title encoding: Run a quality analysis pass, then adjust bitrates per title. Complex content needs more bits, simple content needs fewer.
- Audio budget: Add 96-256 kbps (AAC-LC) or 64-128 kbps (Opus) on top of video bitrate for total stream bitrate.

---

## 3. GOP Structure Tuning

### GOP (Group of Pictures) Fundamentals

A GOP is a sequence of frames starting with an I-frame (keyframe/intra-coded frame), followed by P-frames (predictive) and B-frames (bi-directional). GOP structure is the single most impactful tuning parameter after bitrate itself.

**Frame types:**
- **I-frame (Keyframe):** Fully self-contained. No references to other frames. Largest frame size (5-15x P-frame). Required for random access points and error recovery.
- **P-frame (Predictive):** References one previous I or P frame. Contains motion vectors + residual. ~2-5x smaller than I-frame.
- **B-frame (Bi-directional):** References both past and future frames. Most efficient compression. ~30-50% smaller than P-frame. Adds latency in live scenarios.

### GOP Size (Keyframe Interval)

The GOP size determines how often a full keyframe appears. It is specified either as a frame count or a duration.

| Parameter | Recommended Setting | Notes |
|-----------|-------------------|-------|
| **Segment-aligned GOP** | GOP duration = segment duration | For HLS/DASH: match keyframe interval to segment length (2s, 4s, 6s, or 10s). Ensures each segment starts with a keyframe for clean ABR switching. |
| **Frame-count GOP** | fps * desired_seconds | 30fps * 2s = 60 frames. 60fps * 2s = 120 frames. |
| **Scene detection** | Enable for VOD | Let the encoder insert keyframes at scene cuts. Much better than fixed interval for VOD content with frequent scene changes. |
| **Fixed interval** | Enable for live | Fixed keyframe interval ensures predictable ABR switching points and consistent latency. |

### GOP Configuration by Use Case

#### VOD (Video on Demand)

```
Keyframe interval: Scene detection ON + max keyint = 2x segment duration
B-frames:          3-5 consecutive (pyramid enabled)
GOP type:          Open GOP (better compression, no decode dependency across GOP boundaries)
Lookahead:         60-120 frames (gives encoder more context for rate allocation)
Reference frames:  4-8 (more = better compression, slower decode)

x264/x265 settings:
  keyint=120        (for 30fps, 4s max GOP)
  min-keyint=30     (min 1s between keyframes)
  scenecut=40       (default scene detection sensitivity)
  bframes=5         (up to 5 consecutive B-frames)
  b-adapt=2         (optimal B-frame placement)
  ref=4             (4 reference frames for streaming decode compatibility)
```

#### Live Streaming (Standard Latency, 3-8 seconds)

```
Keyframe interval: Fixed, 2 seconds (exactly matches HLS segment duration)
B-frames:          2-3 consecutive (latency-constrained)
GOP type:          Closed GOP (each segment is independently decodable)
Lookahead:         20-40 frames (limited by real-time constraint)
Reference frames:  2-4 (balance quality vs. decode complexity)

x264/x265 settings:
  keyint=60         (for 30fps, 2s fixed GOP)
  min-keyint=60     (enforce exactly 2s between keyframes)
  scenecut=0        (disable scene detection for consistent GOP)
  bframes=3
  b-adapt=1         (faster B-frame decision)
  ref=3
  no-scenecut=1     (OBS/FFmpeg flag to disable scene detection)
```

#### Ultra-Low-Latency Live (<1 second, WebRTC/LL-HLS)

```
Keyframe interval: Fixed, 0.5-1.0 seconds
B-frames:          0 (disabled) -- B-frames add at minimum 1 frame of latency per B-frame in the decode path
GOP type:          Closed GOP
Lookahead:         Disabled or 0
Reference frames:  1-2

x264/x265 settings:
  keyint=15-30      (for 30fps, 0.5-1.0s)
  min-keyint=15-30
  scenecut=0
  bframes=0         (no B-frames for lowest latency)
  ref=1             (single reference frame)
  tune=zerolatency  (disables all lookahead and buffering)
  sliced-threads=1  (lower latency threading)
```

### Open vs. Closed GOP

| Property | Open GOP | Closed GOP |
|----------|----------|------------|
| **Boundary behavior** | P/B frames at GOP boundary may reference frames from the previous GOP | Each GOP is independently decodable |
| **Compression efficiency** | Better (~2-5% bitrate savings) | Worse |
| **Random access** | Seek may require decoding from previous GOP | Seek always starts cleanly at I-frame |
| **Error resilience** | Errors can propagate across GOP boundaries | Errors contained within single GOP |
| **ABR switching** | Requires adjacent GOP context | Clean switch at any segment boundary |
| **Use case** | VOD, offline encoding | Live streaming, HLS/DASH segment boundaries, broadcast |

**Rule of thumb:** Use closed GOPs whenever the stream will be segmented for ABR delivery. Use open GOPs only for monolithic file playback (e.g., progressive download, local playback).

### Scene Detection vs. Fixed Interval

- **Scene detection** (`scenecut` in x264/x265): Encoder analyzes frame difference metrics and inserts a keyframe when a significant scene change is detected. Significantly improves quality at scene transitions. Essential for VOD.
- **Fixed interval**: Keyframes appear at regular intervals regardless of content. Required for live ABR streaming where segments must align to keyframes.
- **Hybrid approach (recommended for VOD)**: Enable scene detection AND set a maximum keyframe interval. This gets keyframes at scene cuts but guarantees a maximum interval for reasonable seek behavior.

---

## 4. B-Frame Strategies

### What B-Frames Do

B-frames (Bi-directional predictive frames) encode differences from both past and future reference frames. They provide the highest compression ratio of any frame type but introduce latency because the encoder must buffer future frames before encoding the current B-frame.

**Compression contribution:** B-frames typically reduce total bitrate by 10-25% compared to I/P-only streams, depending on content and B-frame configuration.

### B-Frame Configuration Parameters

| Parameter | Range | Effect |
|-----------|-------|--------|
| **Number of consecutive B-frames** | 0-16 | More = better compression, more latency. 3-5 is typical for VOD, 0-2 for live. |
| **B-frame pyramid** | On/Off | Allows B-frames to reference other B-frames. Improves compression by 2-5%. Requires decoder support (universal in modern decoders). |
| **B-frame adaptive (`b-adapt`)** | 0-2 | 0 = none, 1 = fast algorithm, 2 = optimal (slow). Use 2 for VOD, 1 for live. |
| **Reference B-frames (`b-pyramid`)** | 0-2 | 0 = B-frames are non-reference, 1 = some B-frames act as references, 2 = full pyramid. Higher = better compression, more complex decode. |
| **B-frame bias (`pbias`)** | 0-100 | Tendency to use B-frames vs. P-frames. Default is codec-specific. Rarely needs tuning. |

### B-Frame Strategy by Use Case

#### VOD Encoding (Maximum Quality)

```
B-frames:          5 consecutive (x264/x265), 7-15 for AV1 (handled internally)
Pyramid:           Enabled (b-pyramid=normal or adaptive)
Adaptive placement: b-adapt=2 (optimal)
Weighted prediction: weightb=1 (weighted prediction for B-frames)
Reference B-frames: Yes

Impact: ~20-25% bitrate reduction vs. I/P-only. Zero latency concern.
```

#### Live Streaming (Standard, 3-8s latency)

```
B-frames:          2-3 consecutive
Pyramid:           Disabled or limited
Adaptive placement: b-adapt=1 (fast)
Weighted prediction: Optional
Reference B-frames: Limited

Impact: ~10-15% bitrate reduction. Latency cost: 2-3 frames (~66-100ms at 30fps).
```

#### Ultra-Low-Latency Live (<1s latency)

```
B-frames:          0 (disabled)
Reason: Each B-frame adds at least 1 frame period of encode latency.
        At 30fps, 3 B-frames = 100ms added encode latency + decode reordering latency.
        For sub-second glass-to-glass, this is unacceptable.

Impact: ~15-25% bitrate increase vs. B-frame enabled at same quality.
        Compensate by increasing bitrate budget or using a more efficient codec.
```

### Codec-Specific B-Frame Support

| Codec | Max B-frames | Pyramid | Notes |
|-------|-------------|---------|-------|
| **H.264** | 16 (High profile) | Yes | Full B-frame support including pyramid. CABAC + B-frames = best H.264 efficiency. |
| **H.265** | Effectively unlimited | Yes (inherent) | HEVC uses Generalized B-frames (GOP-internal prediction structure). B-frame concept is baked into the codec's CTU prediction. Always enable. |
| **AV1** | Handled internally | Yes (inherent) | AV1 uses a reference frame structure that makes B-frame-like prediction inherent. The "alt-ref" frames serve a similar purpose. SVT-AV1 manages this internally via `bframes` and `pred-struct` parameters. |
| **VP9** | Handled internally | Limited | VP9 uses alt-ref frames (invisible golden frames) for similar effect. Less flexible than AV1/HEVC. |

### B-Frame Decision Heuristics

The encoder decides whether to use a B-frame or P-frame at each position based on:
1. **Motion analysis:** If motion between adjacent frames is very high, a P-frame may be more efficient (B-frame prediction fails when reference frames are too different).
2. **Scene complexity:** Simple, static scenes benefit most from B-frames.
3. **Rate-distortion optimization:** The encoder evaluates whether the bits saved by a B-frame justify the decode complexity.

**Practical guideline:** For high-motion content (sports, gaming), reduce B-frames to 0-1. For typical film/talking-heads content, 3-5 B-frames is optimal. The encoder's adaptive algorithm (`b-adapt=2`) handles this automatically -- trust it for VOD.

---

## 5. Hardware Transcoding

### NVIDIA NVENC

NVIDIA's dedicated hardware encoder on GeForce, Quadro, and datacenter GPUs. Separate from the CUDA cores -- runs on a fixed-function encoder block on the GPU die.

#### NVENC Generations

| Generation | GPU Architecture | GPUs | Codecs | Quality vs. x264 | Notes |
|-----------|-----------------|------|--------|-------------------|-------|
| **Gen 5** | Maxwell (2014) | GTX 900-series | H.264 | ~x264 ultrafast | First usable NVENC. Below streaming quality threshold. |
| **Gen 6** | Pascal (2016) | GTX 10-series | H.264, HEVC | ~x264 superfast | HEVC added. Quality still below x264 medium. |
| **Gen 7** | Turing (2018) | RTX 20-series, GTX 16-series | H.264, HEVC | ~x264 fast/medium | The "new NVENC" quality leap. First NVENC competitive with x264 medium. |
| **Gen 7a** | Ampere (2020) | RTX 30-series | H.264, HEVC, AV1 decode | ~x264 medium | Minor quality improvement over Turing. Added AV1 decode. |
| **Gen 8** | Ada Lovelace (2022) | RTX 40-series | H.264, HEVC, **AV1 encode** | ~x264 medium/slow | AV1 encode support. 40% bitrate savings vs. H.264 NVENC. Dual NVENC on RTX 4070 Ti and above. |
| **Gen 9** | Blackwell (2024+) | RTX 50-series | H.264, HEVC, AV1 | ~x264 slow (projected) | Third-gen AV1 encode. Improved quality per preset. |

#### NVENC Encoding Presets

NVENC presets are designated P1 (fastest) through P7 (slowest/best quality). They control how much compute the hardware encoder spends per frame.

| Preset | Relative Speed | Quality | Use Case |
|--------|---------------|---------|----------|
| **P1** | Fastest | Lowest | Ultra-high-concurrency transcoding where quality is secondary |
| **P2** | | | |
| **P3** | | | |
| **P4** | Default | Good balance | Standard live streaming, VOD batch encoding |
| **P5** | | | |
| **P6** | | | |
| **P7** | Slowest (~30-50% slower than P4) | Highest | Premium VOD, archival. Marginal quality gain vs. P4 for significant speed cost. |

**Practical recommendation:** P4 for live streaming and most VOD. P7 only when encoding time is not a constraint and you need every possible quality bit. The P4-to-P7 quality delta is typically 1-2 VMAF points.

#### NVENC Quality Benchmarks (Approximate)

At 1080p, 8 Mbps, H.264:
```
NVENC Gen 7 (Turing) P4:    VMAF ~93-95
NVENC Gen 7 (Turing) P7:    VMAF ~95-96
NVENC Gen 8 (Ada) P4:       VMAF ~94-96
x264 medium:                 VMAF ~94-96
x264 slow:                   VMAF ~95-97
x264 veryfast:               VMAF ~91-93
```

At 1080p, 8 Mbps, HEVC (NVENC Gen 8, Ada):
```
NVENC HEVC P4:               VMAF ~95-97
NVENC HEVC P7:               VMAF ~96-98
x265 medium:                  VMAF ~95-97
```

NVENC AV1 (Ada Lovelace only):
```
NVENC AV1 P4:                Equivalent quality to NVENC H.264 at ~40% lower bitrate
                              Or: Same bitrate, ~3-5 VMAF points higher than NVENC H.264
```

#### NVENC Throughput

| GPU | NVENC Count | 1080p30 Streams (H.264) | 1080p30 Streams (HEVC) | 1080p30 Streams (AV1) |
|-----|------------|-------------------------|------------------------|------------------------|
| RTX 3060 | 1 (unlocked) | ~12-15 | ~8-10 | N/A |
| RTX 4060 | 1 | ~15-18 | ~10-12 | ~8-10 |
| RTX 4070 Ti | 2 | ~30-36 | ~20-24 | ~16-20 |
| RTX 4090 | 2 | ~30-36 | ~20-24 | ~16-20 |
| A2 (datacenter) | 1 | ~15-18 | ~8-10 | N/A |
| A10 (datacenter) | 1 | ~15-18 | ~8-10 | N/A |
| L4 (datacenter) | 2 | ~30-36 | ~20-24 | ~16-20 |
| L40S (datacenter) | 3 | ~45-55 | ~30-36 | ~24-30 |

Note: GeForce GPUs have NVENC session limits (historically 3, now lifted on most drivers for Turing+), but the fixed-function encoder hardware limits total concurrent throughput regardless of session count. Datacenter GPUs have no session limits.

#### FFmpeg NVENC Flags

```bash
# H.264 NVENC, quality-optimized
ffmpeg -i input.mp4 -c:v h264_nvenc -preset p4 -tune hq -rc vbr -cq 23 -b:v 0 -maxrate 8M -bufsize 16M -profile high output.mp4

# HEVC NVENC, quality-optimized
ffmpeg -i input.mp4 -c:v hevc_nvenc -preset p4 -tune hq -rc vbr -cq 25 -b:v 0 -maxrate 6M -bufsize 12M -profile main10 output.mp4

# AV1 NVENC (Ada Lovelace only)
ffmpeg -i input.mp4 -c:v av1_nvenc -preset p4 -tune hq -rc vbr -cq 30 -b:v 0 -maxrate 4M -bufsize 8M output.mp4
```

### Intel Quick Sync Video (QSV)

Intel's fixed-function media encoder integrated into Intel GPUs (integrated and discrete). Historically the value leader for high-density transcoding.

#### QSV Generations

| Generation | Platform | Codecs | Quality | Notes |
|-----------|----------|--------|---------|-------|
| **Gen 7-8** | Kaby Lake (2017) | H.264, HEVC 8-bit | Moderate | First reasonable HEVC quality. |
| **Gen 9** | Coffee/Ice Lake (2018-2020) | H.264, HEVC 10-bit | Good | HEVC Main 10 support. ~x264 fast equivalent. |
| **Gen 9.5** | Tiger Lake (2020) | H.264, HEVC, **AV1 decode** | Good+ | AV1 decode added. HEVC quality improved. |
| **Gen 12** | Alder Lake (2021), Arc Alchemist (2022) | H.264, HEVC, **AV1 encode** | Very good | First AV1 hardware encode. AV1 quality competitive with NVENC. VMAF ~95-96 at 1080p. |
| **Xe2** | Meteor Lake (2023), Arrow Lake (2024), Battlemage (2024) | H.264, HEVC, AV1 | Very good+ | Refined AV1 encode quality. Lower power per stream than NVIDIA. |

#### QSV Strengths and Weaknesses

**Strengths:**
- Highest density per dollar for H.264/HEVC transcoding. Intel Arc GPUs are very cheap for the encoding throughput.
- Lowest power consumption per stream (critical for datacenter TCO).
- Excellent VPP (Video Post-Processing) pipeline: scaling, deinterlacing, denoise, color space conversion -- all hardware-accelerated.
- AV1 encode quality on Arc Alchemist+ is competitive with NVENC Ada at lower cost.

**Weaknesses:**
- HEVC quality historically slightly behind NVENC (within 1-2 VMAF points on modern generations).
- Linux driver support has historically been fragmented (iHD vs. i965 drivers). Kernel 6.10+ and modern media-driver resolve most issues.
- Intel iGPU memory bandwidth shared with CPU can bottleneck at high concurrency on desktop chips.

#### QSV Throughput

| Platform | 1080p30 Streams (H.264) | 1080p30 Streams (HEVC) | 1080p30 Streams (AV1) |
|----------|-------------------------|------------------------|------------------------|
| Alder Lake i7 (iGPU) | ~8-12 | ~5-8 | ~4-6 |
| Arc A380 | ~12-15 | ~8-10 | ~6-8 |
| Arc A770 | ~18-22 | ~12-15 | ~10-12 |
| Datacenter GPU Flex 170 | ~32-40 | ~20-28 | ~16-22 |

#### FFmpeg QSV Flags

```bash
# H.264 QSV
ffmpeg -hwaccel qsv -i input.mp4 -c:v h264_qsv -preset medium -global_quality 23 -look_ahead 1 output.mp4

# HEVC QSV
ffmpeg -hwaccel qsv -i input.mp4 -c:v hevc_qsv -preset medium -global_quality 25 -profile main10 output.mp4

# AV1 QSV (Arc Alchemist+)
ffmpeg -hwaccel qsv -i input.mp4 -c:v av1_qsv -preset medium -global_quality 30 output.mp4
```

### Apple VideoToolbox

Apple's hardware-accelerated encoding/decoding framework on Apple Silicon (M1/M2/M3/M4) and Intel Macs with T2 chips.

#### VideoToolbox Capabilities

| Chip | H.264 Encode | HEVC Encode | AV1 Encode | AV1 Decode | Notes |
|------|-------------|-------------|------------|------------|-------|
| **M1** (2020) | Yes | Yes (8+10-bit) | No | No | Strong HEVC quality for the era. |
| **M1 Pro/Max/Ultra** (2021) | Yes | Yes (8+10-bit) | No | No | Multiple media engines for higher throughput. |
| **M2** (2022) | Yes | Yes (8+10-bit) | No | No | Minor HEVC quality improvement. |
| **M2 Pro/Max/Ultra** (2023) | Yes | Yes (8+10-bit) | No | No | |
| **M3** (2023) | Yes | Yes (8+10-bit) | No | **Yes** | AV1 hardware decode added. No AV1 encode. |
| **M4** (2024) | Yes | Yes (8+10-bit) | No | Yes | Improved media engine throughput. No AV1 encode as of M4. |

#### VideoToolbox Quality

- HEVC quality is solid: comparable to x264 medium/x265 faster at equivalent bitrates.
- H.264 quality is good but not class-leading -- slightly behind NVENC Turing for high-motion content.
- **No AV1 hardware encode** is a significant limitation for Mac-based transcoding servers. AV1 must be done in software (slow).
- VideoToolbox excels at energy efficiency: transcoding on Apple Silicon uses far less power per stream than discrete GPU solutions.

#### VideoToolbox Throughput (Estimated)

| Chip | 1080p30 Streams (H.264) | 1080p30 Streams (HEVC) |
|------|-------------------------|------------------------|
| M1 | ~4-6 | ~3-4 |
| M1 Pro | ~6-8 | ~5-6 |
| M2 Ultra | ~10-14 | ~8-10 |
| M4 | ~6-8 | ~5-7 |

#### FFmpeg VideoToolbox Flags

```bash
# H.264 VideoToolbox
ffmpeg -i input.mp4 -c:v h264_videotoolbox -q:v 65 -profile high output.mp4

# HEVC VideoToolbox
ffmpeg -i input.mp4 -c:v hevc_videotoolbox -q:v 65 -profile main10 -tag:v hvc1 output.mp4
```

Note: VideoToolbox quality parameter (`-q:v`) is inverted compared to CRF -- higher values = higher quality. Range is roughly 1-100.

### AMD VCE/VCN/AMF

AMD's hardware encoder, historically the weakest of the three GPU vendors but improved significantly with recent driver/SDK updates.

#### VCE/VCN Generations

| Generation | Architecture | Codecs | Quality |
|-----------|-------------|--------|---------|
| **VCE 1-4** | GCN (Radeon RX 400-500) | H.264 | Poor. Avoid for production. |
| **VCN 1.0** | Vega (RX Vega 56/64) | H.264, HEVC | Below NVENC quality. |
| **VCN 2.0** | RDNA1 (RX 5000) | H.264, HEVC | Improved HEVC. Still behind NVENC. |
| **VCN 3.0** | RDNA2 (RX 6000) | H.264, HEVC | Noticeable improvement. B-frames still limited. |
| **VCN 4.0** | RDNA3 (RX 7000) | H.264, HEVC, **AV1 encode** | AV1 encode added. B-frame support restored in AMF SDK 1.4.24+. |

#### AMD Quality Position (2025-2026)

With AMF SDK 1.4.24 (reintroduced B-frames):
- VMAF ~95.4 at 1080p 8 Mbps HEVC (vs. NVENC ~96.1, QSV ~96.4)
- ~1 VMAF point behind NVENC, ~1 point behind Intel QSV
- Acceptable for many production use cases, but not the quality leader
- AV1 encode quality on RDNA3 is functional but behind NVIDIA Ada and Intel Arc

**Recommendation:** AMD is viable for high-density transcoding where cost-per-stream matters more than peak quality. For premium content, prefer NVIDIA or Intel.

### Software Encoders

#### x264 (H.264)

The gold-standard H.264 encoder. Open-source, used by YouTube, Facebook, Twitch, and virtually every streaming platform.

**Presets (fastest to slowest):**

| Preset | Relative Speed | File Size vs. Medium | Quality vs. Medium | Use Case |
|--------|---------------|---------------------|-------------------|----------|
| **ultrafast** | ~10x medium | ~2-3x larger | ~3-5 VMAF lower | Real-time encoding on weak CPUs, testing |
| **superfast** | ~5x medium | ~1.8-2.2x larger | ~2-3 VMAF lower | Fast live encoding |
| **veryfast** | ~3x medium | ~1.4-1.6x larger | ~1-2 VMAF lower | Default live streaming preset. Good balance. |
| **faster** | ~2x medium | ~1.2-1.3x larger | ~0.5-1 VMAF lower | |
| **fast** | ~1.5x medium | ~1.1-1.2x larger | ~0.3-0.5 VMAF lower | |
| **medium** | 1x (baseline) | 1x (baseline) | Baseline | Default preset. Excellent quality/speed tradeoff. |
| **slow** | ~0.3x medium | ~0.85-0.9x | ~0.5-1 VMAF higher | Premium VOD encoding |
| **slower** | ~0.12x medium | ~0.8-0.85x | ~1-1.5 VMAF higher | Offline encoding |
| **veryslow** | ~0.05x medium | ~0.78-0.83x | ~1.5-2 VMAF higher | Maximum quality offline encoding |
| **placebo** | ~0.01x medium | ~0.77-0.82x | ~1.5-2 VMAF higher | Never use. 3-5x slower than veryslow for <0.5% improvement. |

**Key point:** At the same CRF, all presets produce similar *visual quality* -- the difference is file size (compression efficiency). A slower preset uses more sophisticated algorithms (more reference frames, more motion estimation, more rate-distortion optimization) to achieve the same visual quality at a smaller file size.

**Practical encoding speeds (1080p, modern 16-core CPU):**
```
x264 ultrafast:  ~300-500 fps (~10-16x real-time at 30fps)
x264 veryfast:   ~100-150 fps (~3-5x real-time)
x264 medium:     ~40-60 fps   (~1.3-2x real-time)
x264 slow:       ~12-20 fps   (~0.4-0.7x real-time)
x264 veryslow:   ~3-8 fps     (~0.1-0.3x real-time)
```

#### x265 (H.265/HEVC)

The primary open-source HEVC encoder. Similar preset structure to x264 but with additional HEVC-specific tools (CTU sizes, SAO, larger reference structures).

**Quality comparison to x264:**
- x265 slow at CRF 22 produces similar quality to x264 slow at CRF 18, at ~40-50% smaller file size.
- x265 medium is the practical sweet spot for VOD encoding.
- x265 benefits more from slower presets than x264 because HEVC's larger toolset gives the encoder more room to optimize.

**Speed relative to x264:** ~2-4x slower at equivalent presets due to HEVC's greater algorithmic complexity.

**Important x265-specific parameters:**
```
- tu-in-depth:     1-4 (CTU partition depth. Higher = better quality, much slower.)
- sao:             0/1 (Sample Adaptive Offset. Improves quality ~1-2% at small speed cost.)
- weightp:         0/1/2 (Weighted prediction. Always enable for streaming.)
- cutree:          0/1 (Cutree rate control. Adaptive quantization. Enable for VOD.)
- psy-rd/psy-rdoq: Psycho-visual optimizations. Retain sharpness at low bitrates.
```

#### SVT-AV1 (Scalable Video Technology for AV1)

The production AV1 encoder. Developed by Intel and Netflix. The only AV1 encoder suitable for large-scale transcoding due to its speed-quality tradeoff.

**Presets (0 = slowest/best, 13 = fastest):**

| Preset | Speed (1080p, 16-core) | Quality vs. Preset 6 | Use Case |
|--------|------------------------|---------------------|----------|
| **0** | ~0.5-1 fps | Maximum quality | Archival, maximum quality offline |
| **2** | ~1-3 fps | Near-maximum | Premium VOD |
| **4** | ~3-8 fps | High quality | Standard VOD encoding |
| **6** | ~8-20 fps | Baseline | High-quality VOD, comparable to x265 slow |
| **8** | ~25-50 fps | Good | Fast VOD, comparable to x265 medium |
| **10** | ~60-100 fps | Moderate | Near-real-time encoding, comparable to x264 medium |
| **12** | ~120-200 fps | Lower | Real-time encoding |
| **13** | ~200-400 fps | Lowest | Ultra-fast, lowest quality |

**Quality comparison:**
- SVT-AV1 preset 6 produces equivalent quality to x265 slow at ~25-35% smaller file sizes.
- SVT-AV1 preset 8 produces equivalent quality to x265 medium at ~20-30% smaller file sizes.
- SVT-AV1 preset 4 approaches libaom quality at 10-50x the speed.

**CRF mapping (approximate):**
- SVT-AV1 CRF 30 ≈ x265 CRF 22 ≈ x264 CRF 18 (roughly equivalent perceptual quality)

#### libaom-av1 (AOMedia Reference Encoder)

The reference AV1 encoder. Highest quality but extremely slow.

- **Speed:** ~0.1-0.5 fps at 1080p on a 16-core CPU at default settings.
- **Quality:** 1-3% better than SVT-AV1 preset 0-2 at the same bitrate. The quality ceiling.
- **Use case:** Archival encoding, quality benchmarking, final-pass premium content. Not practical for any production pipeline with throughput requirements.
- **CPU usage:** Pegs all available cores. Encoding a 2-hour movie at 1080p can take 8-24 hours.

#### rav1e

Community-developed AV1 encoder written in Rust.

- **Speed:** ~0.5-2 fps at 1080p. Faster than libaom but slower than SVT-AV1.
- **Quality:** ~1-2% below SVT-AV1 at equivalent presets.
- **Use case:** Software diversity (different codebase than SVT-AV1/libaom, reducing risk of common encoder bugs). Not recommended for production pipelines where SVT-AV1 is available.

### Hardware vs. Software Decision Matrix

| Criteria | Hardware (NVENC/QSV) | Software (x264/x265/SVT-AV1) |
|----------|---------------------|-------------------------------|
| **Quality ceiling** | Good (~x264 medium equivalent) | Highest (x264 veryslow, SVT-AV1 preset 0) |
| **Throughput** | 10-50 streams per GPU | 1-5 streams per 16-core CPU |
| **Latency** | Lowest (fixed-function pipeline) | Higher (CPU scheduling, buffering) |
| **Cost per stream** | Low at scale (GPU amortization) | Higher (CPU cores are expensive per stream) |
| **Power per stream** | Lowest (GPU media engines) | Higher (CPU at full utilization) |
| **Flexibility** | Limited (fixed algorithm, preset selection) | Full (every encoding parameter tunable) |
| **AV1 support** | Ada Lovelace NVENC, Arc QSV only | SVT-AV1 runs on any CPU |
| **Live streaming** | Preferred (low latency, high throughput) | Viable with fast presets (veryfast, faster) |
| **VOD encoding** | Good for speed, but software wins on quality | Preferred (no latency constraint, maximize quality) |

---

## 6. Perceptual Quality Metrics

### Why Not Just Use PSNR?

PSNR (Peak Signal-to-Noise Ratio) measures pixel-level differences but correlates poorly with human perception. A 2 dB PSNR difference can be imperceptible or catastrophic depending on the artifact type. PSNR treats all pixels equally; the human visual system does not.

**Use PSNR only as:** A sanity check, a regression test, or when comparing encoders of the same codec family. Never as the primary quality metric for encoding decisions.

### VMAF (Video Multimethod Assessment Fusion)

Developed by Netflix. The industry standard perceptual quality metric for streaming.

#### How VMAF Works

VMAF fuses multiple elementary quality metrics through a machine learning model (support vector machine) trained on human subjective quality scores:

1. **ADM (Additive Detail Metric):** Measures loss of spatial detail/temporal information. Captures blurring and detail loss.
2. **VIF (Visual Information Fidelity):** Measures information fidelity in the frequency domain. Captures how much visual information is preserved.
3. **Motion score:** A temporal component that accounts for the human visual system's reduced sensitivity to detail in high-motion sequences.
4. **Mean luminance:** Accounts for the fact that quality perception varies with brightness.

These components are fused by the SVM model into a single score on a 0-100 scale.

#### VMAF Score Interpretation

| VMAF Range | Quality Level | Subjective Description |
|-----------|--------------|----------------------|
| 95-100 | Effectively transparent | Visually indistinguishable from source (on reference display) |
| 90-95 | Excellent | Minor artifacts visible only on close inspection |
| 80-90 | Good | Noticeable artifacts on scrutiny, acceptable for most content |
| 70-80 | Fair | Visible artifacts (blocking, banding) but content is watchable |
| 60-70 | Poor | Significant artifacts, degraded viewing experience |
| Below 60 | Bad | Severely degraded, difficult to watch |

**Context matters:** These ranges assume desktop/TV viewing at typical distances. Mobile viewing at arm's length is more forgiving.

#### VMAF Models

| Model | Training Target | Use Case |
|-------|----------------|----------|
| **vmaf_v0.6.1** | Default model, 1080p, 4-6 foot viewing | General-purpose quality assessment |
| **vmaf_4k_v0.6.1** | 4K, closer viewing distance | 4K content quality assessment |
| **vmaf_mob_v0.6.1** | Mobile phone viewing conditions | Mobile streaming quality assessment |
| **vmaf_v0.6.1neg** | Penalizes negative quality deviations (blocking) | For detecting specific artifact types |
| **vmaf_v0.6.1neg_v2** | Updated negative model | Improved artifact detection |

**Important:** Always use the model that matches your target viewing conditions. Using the 4K model for mobile content will give misleadingly harsh scores.

#### VMAF Limitations

- **Trained on specific artifacts:** VMAF was trained primarily on H.264/HEVC compression artifacts. It may not accurately score AV1-specific artifacts or AI-upscaled content.
- **Frame-by-frame only:** Does not model temporal quality fluctuations (quality switching in ABR streams).
- **No audio:** Video-only metric. Audio quality requires separate assessment.
- **Reference required:** Needs the original uncompressed source. Cannot score absolute quality without reference (unlike no-reference metrics).
- **Color space dependent:** The default 6:1:1 YUV weighting emphasizes luminance. May underweight chroma artifacts.
- **High computational cost:** VMAF calculation is itself expensive (~1-3 fps for 1080p on CPU).

#### VMAF Tooling

```bash
# FFmpeg libvmaf filter (most common)
ffmpeg -i distorted.mp4 -i original.mp4 -filter_complex libvmaf -f null -

# With specific model
ffmpeg -i distorted.mp4 -i original.mp4 \
  -filter_complex "libvmaf=model_path=/path/to/vmaf_v0.6.1.json" \
  -f null -

# With phone model and JSON output
ffmpeg -i distorted.mp4 -i original.mp4 \
  -filter_complex "libvmaf=model_path=version=vmaf_v0.6.1.json:phone_model=1:log_fmt=json:log_path=vmaf_report.json" \
  -f null -

# Multi-resolution (upscale distorted to reference resolution)
ffmpeg -i distorted_480p.mp4 -i original_1080p.mp4 \
  -filter_complex "[0:v]scale=1920:1080:flags=bicubic[dist];[dist][1:v]libvmaf" \
  -f null -

# NVIDIA VMAF-CUDA (GPU-accelerated VMAF calculation)
ffmpeg -i distorted.mp4 -i original.mp4 \
  -filter_complex "libvmaf_cuda" \
  -f null -
```

### SSIM (Structural Similarity Index)

Measures structural information preservation between reference and distorted images.

| SSIM Range | Interpretation |
|-----------|---------------|
| 0.99-1.00 | Near-identical |
| 0.95-0.99 | Very good quality |
| 0.90-0.95 | Good quality |
| 0.80-0.90 | Noticeable degradation |
| Below 0.80 | Poor quality |

**Strengths:** Fast to compute, well-understood, good at detecting structural distortion.
**Weaknesses:** Does not correlate as well with human perception as VMAF, especially for compression artifacts at low bitrates.

**Use for:** Quick quality checks during encoding pipeline development, regression testing, scenarios where VMAF is too expensive.

```bash
ffmpeg -i distorted.mp4 -i original.mp4 \
  -filter_complex "[0:v][1:v]ssim=stats_file=ssim_stats.log" \
  -f null -
```

### PSNR (Peak Signal-to-Noise Ratio)

| PSNR Range | Interpretation |
|-----------|---------------|
| >45 dB | Near-lossless |
| 40-45 dB | Excellent |
| 35-40 dB | Good |
| 30-35 dB | Fair, visible artifacts |
| <30 dB | Poor |

**Use for:** Regression testing, same-codec comparison, sanity checks. Not suitable as primary quality metric.

```bash
ffmpeg -i distorted.mp4 -i original.mp4 \
  -filter_complex "[0:v][1:v]psnr=stats_file=psnr_stats.log" \
  -f null -
```

### SSIMULACRA 2

Developed by Jon Sneyers (Cloudinary). A modern perceptual metric that addresses several VMAF limitations.

**Score range:** -infinity to 100 (negative scores for severely distorted content).

**Strengths over VMAF:**
- Better correlation with human quality scores for modern codec artifacts (AV1, AI-upscaled).
- Penalizes specific visible artifacts (color banding, ringing, blocking) more accurately.
- No-reference variant available (SSIMULACRA2 NR) for quality estimation without a reference.
- Better at detecting perceptual differences in chroma.

**Weaknesses:**
- Less widely adopted than VMAF. Fewer tools and integrations.
- Newer metric with less historical data for benchmarking.

**Use for:** Quality assessment of AV1 and AI-enhanced content, where VMAF may underreport visible artifacts.

**Tooling:**
```bash
# Standalone SSIMULACRA2 tool
ssimulacra2 original.png distorted.png

# Via ffmpeg-quality-metrics (wrapper tool)
ffmpeg-quality-metrics distorted.mp4 original.mp4 -m ssimulacra2
```

### Metric Selection Guide

| Scenario | Primary Metric | Secondary Metric | Why |
|----------|---------------|-----------------|-----|
| **Encoding ladder design** | VMAF (correct model) | SSIM | VMAF for perceptual quality targets, SSIM for regression |
| **Live streaming QC** | VMAF (phone model for mobile) | PSNR | Quick turnaround, mobile-targeted |
| **AV1 quality evaluation** | SSIMULACRA2 | VMAF | SSIMULACRA2 better for AV1 artifacts |
| **Encoder regression testing** | PSNR + SSIM | VMAF | Fast, deterministic, sensitive to any change |
| **CDN A/B testing** | VMAF (harmonic mean per session) | SSIMULACRA2 | VMAF for broad quality assessment, SSIMULACRA2 for modern codec |
| **Hardware encoder evaluation** | VMAF at matched bitrate | SSIM, PSNR | Compare quality at same bitrate, VMAF is standard |
| **Per-title encoding** | VMAF (per-frame, model-matched) | -- | Optimize per-title bitrate to hit VMAF target |

---

## 7. FFmpeg Encoding Examples

### H.264 Encoding

#### High-Quality VOD (x264 slow, CRF mode)
```bash
ffmpeg -i input.mov \
  -c:v libx264 -preset slow -crf 18 \
  -profile:v high -level 4.1 \
  -pix_fmt yuv420p \
  -bf 5 -refs 4 -b-adapt 2 -direct-pred auto \
  -weightb 1 -weightp 2 \
  -8x8dct 1 -fast-pskip 1 \
  -aq-mode 3 -aq-strength 1.0 \
  -movflags +faststart \
  -c:a aac -b:a 128k -ac 2 \
  output_h264_vod.mp4
```

#### Live Streaming (x264 veryfast, CBR for ABR)
```bash
ffmpeg -i input.mp4 \
  -c:v libx264 -preset veryfast -tune zerolatency \
  -b:v 4000k -maxrate 4500k -bufsize 8000k \
  -profile:v high -level 4.1 \
  -g 60 -keyint_min 60 -sc_threshold 0 \
  -bf 2 -refs 2 \
  -pix_fmt yuv420p \
  -c:a aac -b:a 128k -ac 2 \
  -f flv rtmp://streaming-server/live/stream_key
```

#### Archival Quality (x264 veryslow, CRF 15)
```bash
ffmpeg -i input.mov \
  -c:v libx264 -preset veryslow -crf 15 \
  -profile:v high -level 5.1 \
  -pix_fmt yuv420p \
  -bf 8 -refs 8 -b-adapt 2 \
  -aq-mode 3 -aq-strength 0.8 \
  -partitions all -me_method umh -subq 10 \
  -movflags +faststart \
  -c:a aac -b:a 192k -ac 2 \
  output_h264_archive.mp4
```

### H.265/HEVC Encoding

#### Streaming-Optimized VOD (x265, CRF mode)
```bash
ffmpeg -i input.mov \
  -c:v libx265 -preset slow -crf 22 \
  -profile:v main10 -level 5.0 \
  -pix_fmt yuv420p10le \
  -x265-params "bframes=5:b-adapt=2:rc-lookahead=60:ref=4:psy-rd=0.6:psy-rdoq=1.0:aq-mode=3:sao=1:cutree=1" \
  -tag:v hvc1 \
  -movflags +faststart \
  -c:a aac -b:a 128k -ac 2 \
  output_hevc_vod.mp4
```

#### HEVC with HDR10 Metadata
```bash
ffmpeg -i input_hdr.mov \
  -c:v libx265 -preset slow -crf 20 \
  -profile:v main10 -level 5.1 \
  -pix_fmt yuv420p10le \
  -color_primaries bt2020 -color_trc smpte2084 -colorspace bt2020nc \
  -master_display "G(13250,34500)B(7500,3000)R(34000,16000)WP(15635,16450)L(10000000,1)" \
  -max_cll "1000,400" \
  -x265-params "hdr10=1:hdr10-opt=1:repeat-headers=1" \
  -tag:v hvc1 \
  -movflags +faststart \
  output_hevc_hdr10.mp4
```

### AV1 Encoding (SVT-AV1)

#### VOD Encoding (Quality-Optimized)
```bash
ffmpeg -i input.mov \
  -c:v libsvtav1 -preset 6 -crf 30 \
  -svtav1-params "film-grain=0:enable-dlf=1:enable-tf=1" \
  -pix_fmt yuv420p10le \
  -movflags +faststart \
  -c:a libopus -b:a 128k \
  output_av1_vod.mp4
```

#### AV1 Fast Encoding (Near-Real-Time)
```bash
ffmpeg -i input.mp4 \
  -c:v libsvtav1 -preset 10 -crf 32 \
  -pix_fmt yuv420p \
  -movflags +faststart \
  -c:a libopus -b:a 96k \
  output_av1_fast.mp4
```

#### Maximum Quality AV1 (Offline)
```bash
ffmpeg -i input.mov \
  -c:v libsvtav1 -preset 2 -crf 25 \
  -svtav1-params "film-grain=0:enable-dlf=1:enable-tf=1:mbr=0" \
  -pix_fmt yuv420p10le \
  -movflags +faststart \
  -c:a libopus -b:a 192k \
  output_av1_max_quality.mp4
```

### Hardware-Accelerated Encoding

#### NVIDIA NVENC H.264 (Live Streaming)
```bash
ffmpeg -hwaccel cuda -hwaccel_output_format cuda \
  -i input.mp4 \
  -c:v h264_nvenc -preset p4 -tune ll \
  -rc vbr -cq 23 -b:v 0 -maxrate 5000k -bufsize 10000k \
  -profile high -level auto \
  -g 60 -bf 2 \
  -c:a aac -b:a 128k \
  -f flv rtmp://streaming-server/live/stream_key
```

#### NVIDIA NVENC HEVC (VOD)
```bash
ffmpeg -hwaccel cuda -hwaccel_output_format cuda \
  -i input.mp4 \
  -c:v hevc_nvenc -preset p7 -tune hq \
  -rc vbr -cq 25 -b:v 0 -maxrate 6000k -bufsize 12000k \
  -profile main10 -level auto \
  -tag:v hvc1 \
  -movflags +faststart \
  -c:a aac -b:a 128k \
  output_nvenc_hevc.mp4
```

#### NVIDIA NVENC AV1 (Ada Lovelace)
```bash
ffmpeg -hwaccel cuda -hwaccel_output_format cuda \
  -i input.mp4 \
  -c:v av1_nvenc -preset p7 -tune hq \
  -rc vbr -cq 30 -b:v 0 -maxrate 4000k -bufsize 8000k \
  -movflags +faststart \
  -c:a libopus -b:a 128k \
  output_nvenc_av1.mp4
```

#### Intel QSV H.264 (High-Density Transcoding)
```bash
ffmpeg -hwaccel qsv -hwaccel_output_format qsv \
  -i input.mp4 \
  -c:v h264_qsv -preset medium -global_quality 23 \
  -look_ahead 1 -look_ahead_depth 40 \
  -profile high \
  -g 60 \
  -c:a aac -b:a 128k \
  output_qsv_h264.mp4
```

#### Intel QSV AV1 (Arc Alchemist+)
```bash
ffmpeg -hwaccel qsv -hwaccel_output_format qsv \
  -i input.mp4 \
  -c:v av1_qsv -preset medium -global_quality 30 \
  -look_ahead 1 \
  -movflags +faststart \
  -c:a libopus -b:a 128k \
  output_qsv_av1.mp4
```

#### Apple VideoToolbox HEVC
```bash
ffmpeg -i input.mp4 \
  -c:v hevc_videotoolbox -q:v 65 \
  -profile main10 -tag:v hvc1 \
  -b:v 5000k -maxrate 6000k \
  -movflags +faststart \
  -c:a aac -b:a 128k \
  output_vt_hevc.mp4
```

### Multi-Bitrate ABR Ladder Generation

#### H.264 ABR Ladder (HLS Output)
```bash
ffmpeg -i input.mov \
  -filter_complex "[0:v]split=4[v1][v2][v3][v4]" \
  -map "[v1]" -c:v:0 libx264 -preset slow -b:v:0 5000k -maxrate:0 5500k -bufsize:0 10000k \
    -s:0 1920x1080 -r:0 30 -profile:v:0 high -level:0 4.1 \
  -map "[v2]" -c:v:1 libx264 -preset slow -b:v:1 3000k -maxrate:1 3300k -bufsize:1 6000k \
    -s:1 1280x720 -r:1 30 -profile:v:1 high -level:1 3.1 \
  -map "[v3]" -c:v:2 libx264 -preset slow -b:v:2 1500k -maxrate:2 1650k -bufsize:2 3000k \
    -s:2 854x480 -r:2 30 -profile:v:2 high -level:2 3.0 \
  -map "[v4]" -c:v:3 libx264 -preset slow -b:v:3 800k -maxrate:3 880k -bufsize:3 1600k \
    -s:3 640x360 -r:3 30 -profile:v:3 high -level:3 3.0 \
  -g 60 -keyint_min 60 -sc_threshold 0 \
  -c:a aac -b:a 128k -ac 2 \
  -var_stream_map "v:0,a:0 v:1,a:0 v:2,a:0 v:3,a:0" \
  -master_pl_name master.m3u8 \
  -f hls \
  -hls_time 4 \
  -hls_playlist_type vod \
  -hls_segment_filename "stream_%v/seg_%03d.ts" \
  "stream_%v/index.m3u8"
```

#### H.264 ABR Ladder with Hardware Encoding (NVENC)
```bash
ffmpeg -hwaccel cuda -hwaccel_output_format cuda \
  -i input.mp4 \
  -filter_complex "[0:v]split=3[v1][v2][v3]" \
  -map "[v1]" -c:v:0 h264_nvenc -preset p4 -tune hq \
    -b:v:0 8000k -maxrate:0 9000k -bufsize:0 16000k \
    -s:0 1920x1080 -r:0 60 -g:0 120 \
  -map "[v2]" -c:v:1 h264_nvenc -preset p4 -tune hq \
    -b:v:1 4000k -maxrate:1 4500k -bufsize:1 8000k \
    -s:1 1280x720 -r:1 30 -g:1 60 \
  -map "[v3]" -c:v:2 h264_nvenc -preset p4 -tune hq \
    -b:v:2 1500k -maxrate:2 1700k -bufsize:2 3000k \
    -s:2 854x480 -r:2 30 -g:2 60 \
  -c:a aac -b:a 128k -ac 2 \
  -var_stream_map "v:0,a:0 v:1,a:0 v:2,a:0" \
  -master_pl_name master.m3u8 \
  -f hls \
  -hls_time 4 \
  -hls_segment_type mpegts \
  -hls_segment_filename "stream_%v/seg_%03d.ts" \
  "stream_%v/index.m3u8"
```

### VMAF Quality Measurement

#### Basic VMAF Measurement
```bash
ffmpeg -i encoded_output.mp4 -i original_source.mov \
  -filter_complex "libvmaf" \
  -f null -
```

#### VMAF with JSON Report and All Metrics
```bash
ffmpeg -i encoded_output.mp4 -i original_source.mov \
  -filter_complex "libvmaf=model_path=version=vmaf_v0.6.1:psnr=1:ssim=1:log_fmt=json:log_path=quality_report.json:n_threads=8" \
  -f null -
```

#### VMAF with Phone Model (Mobile Quality)
```bash
ffmpeg -i encoded_output.mp4 -i original_source.mov \
  -filter_complex "libvmaf=model_path=version=vmaf_v0.6.1:phone_model=1:log_fmt=json:log_path=vmaf_mobile.json" \
  -f null -
```

#### VMAF with Resolution Mismatch (Encoded at Lower Resolution)
```bash
ffmpeg -i encoded_480p.mp4 -i original_1080p.mp4 \
  -filter_complex "[0:v]scale=1920:1080:flags=bicubic[dist];[dist][1:v]libvmaf=model_path=version=vmaf_v0.6.1:log_fmt=json:log_path=vmaf_upscaled.json" \
  -f null -
```

#### GPU-Accelerated VMAF (NVIDIA)
```bash
ffmpeg -hwaccel cuda \
  -i encoded_output.mp4 -i original_source.mov \
  -filter_complex "libvmaf_cuda" \
  -f null -
```

#### Batch VMAF for Encoding Ladder (All Rungs)
```bash
#!/bin/bash
# Evaluate VMAF for each rung in an encoding ladder
REFERENCE="original.mov"
ENCODED_DIR="encoded_ladder"

for file in ${ENCODED_DIR}/*.mp4; do
  name=$(basename "$file" .mp4)
  echo "Evaluating: $name"
  ffmpeg -i "$file" -i "$REFERENCE" \
    -filter_complex "libvmaf=model_path=version=vmaf_v0.6.1:n_threads=4:log_fmt=json:log_path=reports/${name}_vmaf.json" \
    -f null - 2>&1 | grep "VMAF score"
done
```

---

## 8. Rate Control Modes

Rate control determines how the encoder allocates bits across frames and scenes. The choice of rate control mode directly impacts ABR segment quality consistency, buffer behavior, and overall streaming experience.

### Rate Control Modes Reference

#### CQP (Constant Quantization Parameter)

Every macroblock/CTU is encoded at the same quantization parameter (QP). The bitrate varies freely based on content complexity.

| Property | Value |
|----------|-------|
| **Bitrate predictability** | None |
| **Quality consistency** | High (constant QP per frame) |
| **Passes** | Single pass |
| **Output size** | Unpredictable |
| **Complex scenes** | Look worse (same QP, fewer bits per pixel of detail) |
| **Simple scenes** | Look great (same QP, more bits than needed) |

**When to use:** Quality benchmarking, encoder comparisons (CQP is the standard for encoder quality comparisons at matched QP), research, debugging.

**When NOT to use:** Any production streaming scenario. Unpredictable bitrate makes buffering impossible and CDN delivery unreliable.

```bash
# x264 CQP
ffmpeg -i input.mp4 -c:v libx264 -qp 23 output.mp4

# x265 CQP
ffmpeg -i input.mp4 -c:v libx265 -qp 28 output.mp4

# NVENC CQP
ffmpeg -i input.mp4 -c:v h264_nvenc -qp 23 output.mp4
```

#### CRF (Constant Rate Factor)

The encoder targets a perceptual quality level. The QP varies frame-by-frame based on content complexity, but the subjective quality remains approximately constant.

| Property | Value |
|----------|-------|
| **Bitrate predictability** | Low (varies with content complexity) |
| **Quality consistency** | High (perceptually constant) |
| **Passes** | Single pass |
| **Output size** | Content-dependent |
| **Complex scenes** | Get more bits (higher bitrate, lower QP) |
| **Simple scenes** | Get fewer bits (lower bitrate, higher QP) |

**CRF value ranges (H.264/x264):**

| CRF | Quality | Typical Use |
|-----|---------|-------------|
| 0 | Lossless | Archival (H.264 lossless mode) |
| 15-18 | Visually transparent | High-quality VOD, archival |
| 18-22 | Excellent | Standard VOD encoding |
| 22-26 | Good | Web streaming, YouTube/Vimeo |
| 26-30 | Acceptable | Low-bandwidth streaming, mobile |
| 30-35 | Marginal | Thumbnail quality, preview |
| 35+ | Poor | Avoid |

**CRF value mapping across codecs (approximate equivalent quality):**
```
H.264 CRF 20  ≈  HEVC CRF 24  ≈  AV1 CRF 30
H.264 CRF 23  ≈  HEVC CRF 27  ≈  AV1 CRF 33
H.264 CRF 18  ≈  HEVC CRF 22  ≈  AV1 CRF 28
```

**When to use:** VOD encoding where output size is flexible but quality must meet a target. Single-pass encoding (faster than two-pass).

**When NOT to use:** Live streaming with bitrate constraints, any scenario requiring predictable output size.

```bash
# x264 CRF
ffmpeg -i input.mp4 -c:v libx264 -preset slow -crf 20 output.mp4

# x265 CRF
ffmpeg -i input.mp4 -c:v libx265 -preset slow -crf 24 output.mp4

# SVT-AV1 CRF
ffmpeg -i input.mp4 -c:v libsvtav1 -preset 6 -crf 30 output.mp4

# NVENC "CRF-like" (VBR with CQ mode)
ffmpeg -i input.mp4 -c:v h264_nvenc -rc vbr -cq 22 -b:v 0 output.mp4
```

#### CBR (Constant Bitrate)

The encoder maintains a constant bitrate over a short window (typically 1 second). Quality varies to maintain the bitrate target.

| Property | Value |
|----------|-------|
| **Bitrate predictability** | Maximum |
| **Quality consistency** | Low (varies with content complexity) |
| **Passes** | Single pass (with VBV) |
| **Output size** | Predictable |
| **Complex scenes** | Look worse (bitrate starved) |
| **Simple scenes** | Look fine (bitrate wasted) |

**When to use:** Live streaming with strict bitrate requirements (RTMP ingest, MPEG-TS output), broadcast workflows, scenarios where the network pipe is fixed.

**When NOT to use:** VOD encoding (wastes bits on simple scenes, starves complex scenes). Any scenario where quality matters more than bitrate consistency.

```bash
# x264 CBR
ffmpeg -i input.mp4 -c:v libx264 -b:v 4000k -maxrate 4000k -bufsize 4000k -nal-hrd cbr output.ts

# NVENC CBR
ffmpeg -i input.mp4 -c:v h264_nvenc -b:v 4000k -maxrate 4000k -bufsize 4000k -rc cbr output.ts
```

#### VBR (Variable Bitrate)

The encoder allocates bits based on content complexity, targeting a specified average bitrate. May overshoot or undershoot.

| Property | Value |
|----------|-------|
| **Bitrate predictability** | Moderate |
| **Quality consistency** | Moderate-High |
| **Passes** | Single or two-pass |
| **Output size** | Approximately predictable |

**When to use:** VOD encoding with a target file size, general-purpose streaming where some bitrate variation is acceptable.

```bash
# x264 VBR (two-pass for best results)
# Pass 1
ffmpeg -i input.mp4 -c:v libx264 -b:v 4000k -pass 1 -an -f mp4 /dev/null
# Pass 2
ffmpeg -i input.mp4 -c:v libx264 -b:v 4000k -pass 2 -c:a aac -b:a 128k output.mp4

# NVENC VBR
ffmpeg -i input.mp4 -c:v h264_nvenc -rc vbr -b:v 4000k -maxrate 6000k -bufsize 8000k output.mp4
```

#### ABR (Average Bitrate)

Targets a specific average bitrate while allowing local variation. Similar to VBR but with tighter average tracking. The term is sometimes used interchangeably with VBR.

```bash
# x264 ABR (single-pass)
ffmpeg -i input.mp4 -c:v libx264 -b:v 4000k -maxrate 6000k -bufsize 8000k output.mp4
```

#### Capped VBR / Constrained VBR

VBR with a maximum bitrate cap. The encoder can vary the bitrate freely up to the cap but never exceeds it. The most common mode for streaming encoders.

```bash
# x264 capped VBR (CRF + maxrate)
ffmpeg -i input.mp4 -c:v libx264 -crf 20 -maxrate 5000k -bufsize 10000k output.mp4

# NVENC capped VBR
ffmpeg -i input.mp4 -c:v h264_nvenc -rc vbr -cq 22 -b:v 4000k -maxrate 6000k -bufsize 10000k output.mp4
```

### VBV/HRD Compliance

**VBV (Video Buffering Verifier)** and **HRD (Hypothetical Reference Decoder)** are buffer models that constrain how much the bitrate can vary over short windows. They are essential for streaming because they guarantee the decoder buffer never underflows (stalls) or overflows (drops data).

#### VBV Parameters

| Parameter | What It Does | Recommended Value |
|-----------|-------------|-------------------|
| **`-maxrate`** | Maximum instantaneous bitrate the encoder may produce | 1.0-1.5x target bitrate for VOD, 1.0-1.25x for live |
| **`-bufsize`** | Size of the hypothetical decoder buffer | 2x maxrate for VOD, 1-2x maxrate for live |

**VBV bufsize determines the "burstiness" window:**
- Larger bufsize = encoder can burst more bits for complex scenes = better quality consistency but higher peak bitrate and larger player buffer requirement.
- Smaller bufsize = tighter bitrate control = more consistent segment sizes but lower quality on complex scenes.
- For HLS/DASH segments: bufsize should be at least 1 segment duration worth of bits (segment_duration * maxrate).

**Practical VBV settings by use case:**

| Use Case | maxrate | bufsize | Notes |
|----------|---------|---------|-------|
| **VOD (relaxed)** | 1.5x target | 2x maxrate | Maximum quality within broad bitrate bounds |
| **VOD (tight)** | 1.25x target | 1.5x maxrate | More consistent segment sizes for CDN caching |
| **Live (standard)** | 1.25x target | 1x maxrate | Predictable ingest bitrate |
| **Live (CBR-like)** | 1.0x target (= target) | 1x target | True CBR via VBV. Strictest control. |
| **Ultra-low-latency** | 1.0x target | 0.5x target | Minimal buffer for fastest decode start |

```bash
# VOD: Relaxed VBV (quality-optimized)
ffmpeg -i input.mp4 -c:v libx264 -crf 20 -maxrate 7500k -bufsize 15000k output.mp4

# Live: Standard VBV (balanced)
ffmpeg -i input.mp4 -c:v libx264 -b:v 4000k -maxrate 5000k -bufsize 5000k output.ts

# Live: Strict CBR via VBV
ffmpeg -i input.mp4 -c:v libx264 -b:v 4000k -maxrate 4000k -bufsize 4000k -nal-hrd cbr output.ts
```

### Rate Control for ABR Streaming Segments

For HLS/DASH ABR delivery, rate control must produce consistent segment sizes so the player's ABR algorithm can make accurate bandwidth estimates.

**Key requirements:**
1. **Segment size consistency:** Each segment at a given rung should be approximately the same size (within 10-15% of expected = bitrate * segment_duration).
2. **Keyframe alignment:** GOP boundaries must align with segment boundaries. Every segment starts with a keyframe.
3. **No bitrate overshoot:** Segments that are much larger than expected cause player buffer underflow on constrained connections.

**Recommended rate control for ABR:**

| Method | Quality | Segment Consistency | Complexity | Recommended For |
|--------|---------|---------------------|------------|-----------------|
| **Two-pass VBR** | Best | Good | Highest (requires two encode passes) | Premium VOD, per-title encoding |
| **Capped CRF + VBV** | Very good | Very good | Medium | Standard VOD, production default |
| **CRF + maxrate** | Good | Moderate | Low | Quick VOD, test encodes |
| **CBR** | Worst | Best | Low | Live streaming, broadcast ingest |

**Production recommendation:** Use capped CRF with VBV constraints for VOD encoding. This gives perceptually constant quality while maintaining segment size predictability.

```bash
# Production VOD: Capped CRF + VBV (the sweet spot)
ffmpeg -i input.mov \
  -c:v libx264 -preset slow -crf 20 \
  -maxrate 8000k -bufsize 16000k \
  -profile:v high -level 4.1 \
  -g 120 -keyint_min 120 -sc_threshold 0 \
  -pix_fmt yuv420p \
  -c:a aac -b:a 128k -ac 2 \
  -movflags +faststart \
  output_production.mp4
```

### Per-Title Encoding

Per-title encoding adapts the encoding ladder to each piece of content. Instead of using a fixed bitrate ladder, the encoder analyzes the content complexity and selects optimal bitrates to hit a target quality level (typically VMAF 95 for desktop, VMAF 90 for mobile).

**Workflow:**
1. Encode a quick probe pass at multiple CRF values.
2. Measure VMAF at each CRF to build a complexity curve for this title.
3. Select bitrates that hit the VMAF target for each resolution rung.
4. Encode the full ladder with per-title optimized bitrates.

**Benefit:** 20-40% bandwidth savings on average across a content library, because simple content (talking heads, animation) gets much lower bitrates than complex content (sports, action movies) at the same quality level.

---

## Appendix: Quick Reference Card

### Codec Selection Cheat Sheet

```
Universal fallback:           H.264 High, CRF 20-23, AAC audio
VOD quality-efficiency:       HEVC Main10, CRF 22-26, Opus/AAC audio
VOD maximum efficiency:       AV1, SVT-AV1 preset 4-6, CRF 28-32, Opus audio
Live standard latency:        H.264, x264 veryfast, CBR/capped VBR
Live GPU-accelerated:         H.264 NVENC P4 or HEVC NVENC P4
Ultra-low-latency live:       H.264, x264 veryfast + tune zerolatency, no B-frames
4K HDR VOD:                   HEVC Main10 or AV1, 10-bit, HDR10 metadata
Mobile-optimized:             AV1 (where supported) or H.264 for fallback
```

### FFmpeg Preset Quick Reference

```
# H.264 production VOD
-c:v libx264 -preset slow -crf 20 -profile:v high -maxrate 1.5x_target -bufsize 2x_maxrate

# HEVC production VOD
-c:v libx265 -preset slow -crf 24 -profile:v main10 -pix_fmt yuv420p10le -tag:v hvc1

# AV1 production VOD
-c:v libsvtav1 -preset 6 -crf 30 -pix_fmt yuv420p10le

# NVENC live
-c:v h264_nvenc -preset p4 -tune ll -rc vbr -cq 22 -b:v 0 -maxrate 5000k -bufsize 10000k

# QSV high-density
-c:v h264_qsv -preset medium -global_quality 23 -look_ahead 1
```

### VMAF Target Quick Reference

```
Premium VOD:        VMAF >= 95 (desktop model)
Standard VOD:       VMAF >= 90 (desktop model)
Mobile streaming:   VMAF >= 85 (phone model)
Live streaming:     VMAF >= 80 (phone model)
Thumbnail/preview:  VMAF >= 70 (any model)
```

---

*Last updated: 2026-05-27. Specifications and benchmarks reflect publicly available data as of this date. Hardware encoder quality and throughput numbers are approximate and vary by content, driver version, and system configuration.*
