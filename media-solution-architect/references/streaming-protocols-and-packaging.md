# Streaming Protocols, Packaging Formats, and Delivery

Technical reference for CDN/media streaming architecture. Covers the full pipeline from ingestion through packaging, adaptive delivery, content protection, and origin configuration.

---

## Table of Contents

1. [HLS (HTTP Live Streaming)](#1-hls-http-live-streaming)
2. [DASH (Dynamic Adaptive Streaming over HTTP)](#2-dash-dynamic-adaptive-streaming-over-http)
3. [CMAF (Common Media Application Format)](#3-cmaf-common-media-application-format)
4. [Adaptive Bitrate (ABR) Strategies](#4-adaptive-bitrate-abr-strategies)
5. [RTMP/SRT Ingestion](#5-rtmpsrt-ingestion)
6. [WebRTC for Ultra-Low-Latency](#6-webrtc-for-ultra-low-latency)
7. [DRM (Digital Rights Management)](#7-drm-digital-rights-management)
8. [Packaging Tools](#8-packaging-tools)

---

## 1. HLS (HTTP Live Streaming)

HLS is Apple's HTTP-based adaptive streaming protocol, specified in RFC 8216 (with the second edition as `draft-pantos-hls-rfc8216bis`). It is the dominant delivery format for web and mobile streaming, supported natively on iOS, macOS, Safari, Android, and most smart TVs.

### 1.1 Protocol Mechanics

HLS works by breaking a stream into small segments and serving them via a playlist file:

1. **Encoder** produces media segments (`.ts` for MPEG-TS or `.m4s` for fMP4) and a playlist (`.m3u8`).
2. **Origin/CDN** serves segments and playlists as static files over HTTP/HTTPS.
3. **Player** fetches the playlist, determines which rendition to use, then downloads segments sequentially.

**Playlist Types:**

| Type | Tag | Use Case |
|------|-----|----------|
| Master/Multivariant | `#EXT-X-STREAM-INF` | Lists all available renditions (bitrate, resolution, codec) |
| Media | `#EXT-X-TARGETDURATION` | Lists segments for a single rendition |
| Live | Ends with `#EXT-X-ENDLIST` (absent) | Playlist updates with new segments |
| VOD | Ends with `#EXT-X-ENDLIST` | Static, unchanging playlist |

**Example Multivariant Playlist:**

```m3u8
#EXTM3U
#EXT-X-VERSION:6
#EXT-X-INDEPENDENT-SEGMENTS

#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360,CODECS="avc1.64001f,mp4a.40.2"
stream_360p.m3u8

#EXT-X-STREAM-INF:BANDWIDTH=2800000,RESOLUTION=1280x720,CODECS="avc1.64001f,mp4a.40.2"
stream_720p.m3u8

#EXT-X-STREAM-INF:BANDWIDTH=5000000,RESOLUTION=1920x1080,CODECS="avc1.640028,mp4a.40.2"
stream_1080p.m3u8
```

**Example Media Playlist:**

```m3u8
#EXTM3U
#EXT-X-VERSION:6
#EXT-X-TARGETDURATION:6
#EXT-X-MEDIA-SEQUENCE:0

#EXTINF:6.0,
segment_000.ts
#EXTINF:6.0,
segment_001.ts
#EXTINF:6.0,
segment_002.ts
```

### 1.2 Segment Duration Tradeoffs

Segment duration is one of the most consequential decisions in an HLS deployment. It directly impacts latency, cache efficiency, encoding overhead, and viewer experience.

| Segment Duration | Live Latency | CDN Cache Hit Rate | Encoding Efficiency | Request Overhead | Use Case |
|-----------------|-------------|--------------------|--------------------|-------------------|----------|
| **2s** | ~6s | Moderate | Lower (short GOPs) | High (3x more requests vs 6s) | Low-latency live |
| **4s** | ~12s | Good | Good | Moderate | General live |
| **6s** | ~18s | Excellent | Best | Low (Apple default) | Standard live, VOD |
| **10s** | ~30s | Excellent | Best | Very low | VOD, high-cache scenarios |

**Key tradeoffs in detail:**

- **Latency**: Live latency is typically 3x segment duration (one segment being written + one segment in buffer + one segment downloading). A 2s segment yields ~6s latency; a 6s segment yields ~18s.

- **Cache efficiency**: Longer segments mean fewer unique URLs, higher cache hit ratios, and lower origin egress. A 6s segment produces 600 segments per hour vs 1,800 for a 2s segment.

- **Encoding overhead**: Keyframes must align with segment boundaries. Short segments force frequent keyframes (every 2s = 15 keyframes/sec at 30fps). Keyframes are significantly larger than P/B frames, so shorter segments increase bandwidth or reduce quality at a given bitrate. The impact becomes pronounced below 2s GOP sizes.

- **Startup time**: Shorter segments allow faster initial buffering, improving time-to-first-frame. However, more HTTP requests increase connection overhead.

**Recommendation matrix:**

| Scenario | Segment Duration | Rationale |
|----------|-----------------|-----------|
| Premium VOD (Netflix-style) | 6s | Maximum encoding efficiency, CDN cache performance |
| Standard live streaming | 4s | Balance of latency and quality |
| Low-latency live (sports, auctions) | 2s + LL-HLS | Minimum latency without going to WebRTC |
| Ultra-low latency (<1s) | Use WebRTC, not HLS | HLS cannot go below ~2s glass-to-glass |

### 1.3 Low-Latency HLS (LL-HLS)

LL-HLS (introduced in 2019, matured through 2025, published as HLS 2nd Edition in May 2026) extends HLS to achieve 2-5 second latency while retaining CDN scalability.

**Core mechanisms:**

**Partial Segments**: Segments are subdivided into smaller "parts" (typically 200-400ms). Parts are published before the full segment is complete, giving the player something to decode immediately.

```
#EXT-X-PART:DURATION=0.333,URI="part0.m4s",INDEPENDENT=YES
#EXT-X-PART:DURATION=0.333,URI="part1.m4s"
#EXT-X-PART:DURATION=0.333,URI="part2.m4s"
#EXTINF:1.0,
segment_001.m4s
```

**Blocking Playlist Reload**: Instead of polling the playlist repeatedly (wasting requests and adding latency), the client sends a request with `_HLS_msn` and `_HLS_part` query parameters. The server holds the connection open until new content is available:

```
GET /stream.m3u8?_HLS_msn=5&_HLS_part=3
```

The server blocks until playlist MSN (Media Sequence Number) 5, part 3 is available, then returns immediately. This eliminates the polling interval (typically 1-2 seconds) and replaces it with push-like delivery.

**Delta Updates**: The `_HLS_skip=YES` parameter requests a playlist delta update rather than the full playlist, reducing payload size and parsing time.

**Byte-range addressing**: LL-HLS supports byte-range addressing for partial segments within a single file, improving cache efficiency since the CDN stores one file per segment rather than one file per part.

**Latency breakdown for LL-HLS:**

```
[Encoder] -> [Segmenter] -> [Origin] -> [CDN] -> [Player]
   50-100ms    200-400ms     ~0ms      ~50ms    200-400ms

Total: ~500ms - 1s encoding/packaging + 2-3 segments of buffer = 2-5s
```

### 1.4 HLS with fMP4 (CMAF) Segments

Traditional HLS uses MPEG-TS segments. Modern HLS supports fragmented MP4 (fMP4) segments, which are CMAF-compatible. This is critical because it enables single-encode, dual-delivery (HLS + DASH) workflows.

**Advantages of fMP4 over MPEG-TS:**

| Feature | MPEG-TS | fMP4 (CMAF) |
|---------|---------|-------------|
| Container overhead | ~2-4% | ~0.5% |
| CMAF compatible | No | Yes |
| Shared with DASH | No | Yes |
| Codec support | H.264, HEVC (limited) | H.264, HEVC, AV1, VP9 |
| Byte-range addressing | Not practical | Native |
| Subtitle embedding | Sidecar only | In-band (WebVTT, IMSC1) |

**fMP4 initialization segment**: Each rendition requires an init segment (`init.mp4` or `init.m4s`) containing codec configuration, track metadata, and encryption info. This is followed by media segments containing the actual frames.

```
#EXT-X-MAP:URI="init.mp4"
#EXTINF:4.0,
seg_001.m4s
```

**Version requirement**: HLS protocol version 7+ is required for fMP4 segments. Most modern players support this.

### 1.5 Multi-Variant Playlists and Codec Signaling

The multivariant playlist (formerly "master playlist") signals available renditions with codec, resolution, bandwidth, and other attributes.

**CODECS attribute**: Required for correct rendition selection. Format follows RFC 6381 (ISO BMFF codec configuration box notation):

| Codec | CODECS value | Notes |
|-------|-------------|-------|
| H.264 Baseline | `avc1.42E01E` | Legacy compatibility |
| H.264 Main | `avc1.4D401F` | Standard web |
| H.264 High | `avc1.640028` | HD/1080p |
| HEVC (H.265) | `hvc1.1.6.L93.B0` | 4K/HDR |
| AV1 | `av01.0.01M.08` | Next-gen |
| AAC-LC | `mp4a.40.2` | Standard audio |
| HE-AAC | `mp4a.40.5` | Low bitrate audio |
| AC-3 | `ac-3` | Dolby Digital |
| EAC-3 | `ec-3` | Dolby Digital Plus |

**Multi-codec signaling** (HLS with multiple codecs):

```m3u8
#EXTM3U
#EXT-X-VERSION:7

#EXT-X-STREAM-INF:BANDWIDTH=5000000,RESOLUTION=1920x1080,CODECS="avc1.640028,mp4a.40.2"
1080p_avc.m3u8

#EXT-X-STREAM-INF:BANDWIDTH=4500000,RESOLUTION=1920x1080,CODECS="hvc1.1.6.L93.B0,mp4a.40.2",SCORE=8
1080p_hevc.m3u8

#EXT-X-STREAM-INF:BANDWIDTH=3500000,RESOLUTION=1920x1080,CODECS="av01.0.04M.08,mp4a.40.2",SCORE=10
1080p_av1.m3u8
```

The `SCORE` attribute (HLS version 10+) lets the server indicate preferred renditions. Players can use it to prefer AV1 when supported.

**Important**: Switching between different codecs during playback is inefficient and can cause visible artifacts. Best practice is to use the same codec across all renditions within a given session, varying only bitrate and resolution.

### 1.6 Subtitle and Caption Support

HLS supports multiple caption/subtitle formats:

**WebVTT (Web Video Text Tracks)**:

```m3u8
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",LANGUAGE="en",NAME="English",AUTOSELECT=YES,DEFAULT=YES,URI="subs_en.m3u8"
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",LANGUAGE="es",NAME="Espanol",AUTOSELECT=YES,URI="subs_es.m3u8"
```

WebVTT subtitle playlist:

```m3u8
#EXTM3U
#EXT-X-TARGETDURATION:600
#EXT-X-VERSION:3
#EXT-X-MEDIA-SEQUENCE:0
#EXTINF:600,
subs_en_001.vtt
```

**IMSC1 (Internet Media Subtitles and Captions)**: An XML-based subtitle format (profile of TTML) that can be carried in fMP4 segments alongside video, enabling in-band subtitles. Preferred for CMAF workflows because both video and subtitle segments use the same container format.

**CEA-608/708 (Closed Captions)**: Embedded in the video stream itself, signaled with:

```
#EXT-X-MEDIA:TYPE=CLOSED-CAPTIONS,GROUP-ID="cc",LANGUAGE="en",NAME="English",AUTOSELECT=YES,INSTREAM-ID="CC1"
```

| Format | Container | HLS Mode | CMAF Compatible | Styling |
|--------|-----------|----------|-----------------|---------|
| WebVTT | `.vtt` files | Sidecar | Yes (fMP4 wrapping) | CSS-based |
| IMSC1 | fMP4 segments | In-band | Native | TTML styling |
| CEA-608/708 | Embedded in video | In-band | No | Limited |

---

## 2. DASH (Dynamic Adaptive Streaming over HTTP)

MPEG-DASH is an ISO standard (ISO/IEC 23009-1) for adaptive streaming over HTTP. Unlike HLS, DASH is codec-agnostic and vendor-neutral. It is the primary delivery format for browsers that do not support HLS natively (historically Chrome, Firefox, Edge -- though many now support HLS as well).

### 2.1 MPD Structure

The Media Presentation Description (MPD) is an XML document that describes the stream hierarchy:

```
MPD (Media Presentation Description)
  |-- Period (time slice, e.g., ad break vs. main content)
  |     |-- AdaptationSet (media type: video, audio, subtitles)
  |     |     |-- Representation (specific bitrate/resolution/codec)
  |     |     |     |-- SegmentTemplate (segment naming pattern)
  |     |     |     |-- SegmentList (explicit segment URLs)
  |     |     |     |-- SegmentBase (byte-range into single file)
  |     |     |-- ContentProtection (DRM signaling)
  |-- Period
  ...
```

**Example MPD (live stream):**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011"
     type="dynamic"
     minimumUpdatePeriod="PT4S"
     availabilityStartTime="2025-01-15T12:00:00Z"
     minBufferTime="PT2S">

  <Period id="1">
    <AdaptationSet mimeType="video/mp4"
                   contentType="video"
                   segmentAlignment="true"
                   subsegmentAlignment="true">

      <SegmentTemplate timescale="90000"
                       media="seg_$RepresentationID$_$Number$.m4s"
                       initialization="init_$RepresentationID$.mp4"
                       duration="360000"
                       startNumber="1"/>

      <Representation id="360p" bandwidth="800000" width="640" height="360"
                      codecs="avc1.64001f" frameRate="30"/>
      <Representation id="720p" bandwidth="2800000" width="1280" height="720"
                      codecs="avc1.64001f" frameRate="30"/>
      <Representation id="1080p" bandwidth="5000000" width="1920" height="1080"
                      codecs="avc1.640028" frameRate="30"/>

    </AdaptationSet>

    <AdaptationSet mimeType="audio/mp4" contentType="audio" lang="en">
      <SegmentTemplate timescale="44100"
                       media="audio_$RepresentationID$_$Number$.m4s"
                       initialization="audio_init_$RepresentationID$.mp4"
                       duration="176400"/>
      <Representation id="aac128" bandwidth="128000"
                      codecs="mp4a.40.2" audioSamplingRate="44100"/>
    </AdaptationSet>
  </Period>
</MPD>
```

**Key MPD elements:**

| Element | Purpose | Key Attributes |
|---------|---------|---------------|
| `MPD` | Root document | `type` (static/dynamic), `minimumUpdatePeriod`, `minBufferTime` |
| `Period` | Time division | `id`, `start`, `duration` |
| `AdaptationSet` | Media type group | `mimeType`, `contentType`, `lang`, `segmentAlignment` |
| `Representation` | Specific rendition | `id`, `bandwidth`, `width`, `height`, `codecs`, `frameRate` |
| `SegmentTemplate` | URL pattern | `media`, `initialization`, `duration`, `timescale`, `startNumber` |
| `SegmentBase` | Byte-range into file | `indexRange` |
| `ContentProtection` | DRM signaling | `schemeIdUri`, `value` |

### 2.2 Low-Latency DASH (LL-DASH)

LL-DASH (defined in DASH-IF Interoperability Point Low-Latency Live specification) achieves sub-3-second latency by combining CMAF chunks with HTTP chunked transfer encoding (CTE).

**Mechanism**: Instead of waiting for an entire segment to be encoded and published, the packager sends CMAF chunks as they become available using HTTP/1.1 chunked transfer encoding. The player begins decoding as soon as the first chunk arrives.

**MPD signaling for LL-DASH:**

```xml
<SegmentTemplate media="seg_$RepresentationID$_$Number$.m4s"
                 initialization="init_$RepresentationID$.mp4"
                 duration="4000"
                 timescale="1000"
                 availabilityTimeOffset="3.9S"
                 availabilityTimeComplete="false"/>
```

- `availabilityTimeOffset="3.9S"`: Tells the player that segments become available 3.9 seconds before the full segment duration elapses. This signals that chunked transfer is in use.
- `availabilityTimeComplete="false"`: Indicates that segments are delivered incrementally (not atomically).

**Latency reduction:**

| Mode | Mechanism | Typical Latency |
|------|-----------|----------------|
| Standard DASH | Full segments | 12-30s |
| LL-DASH (CTE) | Chunked segments | 2-5s |
| LL-DASH + short segments | 1s segments + CTE | 1-3s |

**Player requirements**: The player must support incremental parsing of MP4 fragments and be able to start playback before a complete segment is buffered. `dash.js`, Shaka Player, and THEOplayer support LL-DASH.

### 2.3 DASH-IF and DVB Profiles

DASH profiles define conformance points ensuring interoperability between encoders and players:

| Profile | URI | Use Case |
|---------|-----|----------|
| **DASH-IF Live** | `urn:mpeg:dash:profile:isoff-live:2011` | Live streaming with SegmentTemplate |
| **DASH-IF On-Demand** | `urn:mpeg:dash:profile:isoff-on-demand:2011` | VOD with SegmentBase |
| **DASH-IF LL** | `urn:mpeg:dash:profile:low-latency-live:2019` | Low-latency live with CTE |
| **DVB DASH** | `urn:dvb:dash:profile:dvb-dash:2014` | Broadcast TV standards |
| **HbbTV** | `urn:hbbtv:dash:profile:isoff-live:2012` | European smart TV |

**DASH-IF IOP (Interoperability Points)**: The DASH Industry Forum publishes implementation guidelines that specify which MPD features players must support. The current version (v5.x, 2025) covers LL-DASH, CMAF, and multi-codec signaling.

**DVB DASH**: Adds constraints for broadcast television including codec requirements, subtitle formats (IMSC1, WebVTT), and DRM signaling (CENC with specific system IDs).

---

## 3. CMAF (Common Media Application Format)

CMAF (ISO/IEC 23009-1, recognized with a Technology & Engineering Emmy Award in September 2025) is the key enabler for single-encode, multi-protocol delivery.

### 3.1 Single Encode, HLS + DASH Delivery

**The problem CMAF solves**: Before CMAF, serving both HLS and DASH audiences required encoding and storing content twice -- once in MPEG-TS containers for HLS and once in ISOBMFF (MP4) containers for DASH. This doubled storage costs and CDN cache footprint.

**CMAF solution**: Encode once into CMAF segments (fragmented MP4). Both HLS multivariant playlists and DASH MPDs reference the same segment files. Only the manifests differ.

```
                          +--> .m3u8 (HLS playlist)
                          |
Encoder --> CMAF segments --+
                          |
                          +--> .mpd (DASH manifest)
```

**Storage and CDN savings**: In theory, up to 75% reduction in storage and origin egress, since segments are shared. In practice, the savings depend on how many output formats were previously duplicated.

### 3.2 CMAF Segments and Chunks

CMAF defines a hierarchical structure for media segments:

| Unit | Description | Typical Size |
|------|-------------|-------------|
| **CMAF Track** | Complete media track (e.g., 1080p video) | Full duration |
| **CMAF Segment** | One GOP-aligned fragment | 2-6 seconds |
| **CMAF Chunk** | Sub-segment unit for LL delivery | 200ms-1s |
| **Initialization Segment** | Codec config, track metadata | Small (~1KB) |

**Segment structure (fMP4):**

```
[ftyp] - File type box
[moov] - Movie header (in init segment)
[moof] - Movie fragment (metadata for samples)
[mdat] - Media data (actual video/audio frames)
```

Each CMAF segment is a self-contained `moof+mdat` pair. The initialization segment contains the `ftyp` and `moov` boxes.

**Byte-range addressing**: CMAF segments within a single file can be addressed by byte range, enabling the CDN to cache one large file while clients request specific byte ranges:

```
# HLS
#EXT-X-BYTERANGE:300000@0
segment.mp4
#EXT-X-BYTERANGE:350000@300000
segment.mp4

# DASH
<SegmentBase indexRange="100-500"/>
```

### 3.3 Encryption and Signaling

CMAF supports Common Encryption (CENC), allowing a single encrypted file to be decrypted by multiple DRM systems.

**Encryption schemes:**

| Scheme | Spec | Use Case |
|--------|------|----------|
| `cenc` | AES-128-CTR | Legacy (Widevine, PlayReady) |
| `cbcs` | AES-128-CBC (pattern encryption) | Apple/FairPlay preferred, also Widevine |

**Pattern encryption (cbcs)**: Only encrypts some blocks in a pattern (e.g., encrypt 10 blocks, skip 5, repeat). This allows certain operations (seek, trick mode) without full decryption. Apple requires `cbcs` for FairPlay.

**Signaling in HLS:**

```m3u8
#EXT-X-KEY:METHOD=SAMPLE-AES,URI="skd://key-id",KEYFORMAT="com.apple.streamingkeydelivery",IV=0x...
#EXT-X-KEY:METHOD=SAMPLE-AES,URI="https://license.widevine.com/...",KEYFORMAT="urn:uuid:edef8ba9-79d6-4ace-a3c8-27dcd51d21ed"
```

**Signaling in DASH:**

```xml
<ContentProtection schemeIdUri="urn:mpeg:cenc:2013" value="cbcs"/>
<ContentProtection schemeIdUri="urn:uuid:edef8ba9-79d6-4ace-a3c8-27dcd51d21ed"
                   value="Widevine"/>
<ContentProtection schemeIdUri="urn:uuid:94ce86fb-07ff-4f43-adb8-93d2fa968ca2"
                   value="FairPlay"/>
```

**Single file, multiple DRM**: Because CENC/CBCS encryption is standard across DRM systems, the same encrypted CMAF segment can be served to Widevine, FairPlay, and PlayReady clients. Only the license acquisition flow differs per DRM system.

---

## 4. Adaptive Bitrate (ABR) Strategies

ABR is the mechanism by which streaming clients dynamically select the appropriate rendition based on current network conditions, device capabilities, and buffer state.

### 4.1 Client-Side ABR Algorithms

| Algorithm | Type | How It Works | Best For | Weakness |
|-----------|------|-------------|----------|----------|
| **Throughput-based** | Bandwidth | Estimates available bandwidth from recent segment downloads, selects highest sustainable bitrate | Startup, high-bandwidth networks | Noisy estimates on mobile; oscillation |
| **Buffer-based** | Buffer | Uses current buffer fill level to decide upshift/downshift, ignoring bandwidth estimates | Stable networks, mobile | Slow to react to bandwidth drops |
| **BOLA** (Buffer Occupancy based Lyapunov Algorithm) | Buffer + Utility | Uses Lyapunov optimization to maximize a utility function over buffer level; default in `dash.js` | General use, stable quality | Conservative in some scenarios |
| **DYNAMIC** | Hybrid | Switches between throughput-based (low buffer) and BOLA (high buffer) | All scenarios | Default in DASH reference player |
| **RL-based** (Reinforcement Learning) | ML | Trains on network traces to predict optimal bitrate decisions | Research/advanced | Complexity, training data required |

**DYNAMIC algorithm flow** (default in `dash.js`):

```
[Start playback]
    |
    v
Buffer < threshold?  --YES-->  Use throughput-based ABR
    |                            (fast adaptation, prioritize startup)
    NO
    |
    v
Buffer >= threshold? --YES-->  Use BOLA
    |                            (stable quality, avoid oscillation)
```

The throughput-based algorithm handles startup and seek (when buffer is empty or low), while BOLA takes over once sufficient buffer exists. This hybrid approach combines the strengths of both.

### 4.2 ABR Ladder Design

The ABR ladder defines the set of bitrate/resolution renditions available to the player. A well-designed ladder covers the full range of viewer bandwidths without unnecessary overlaps.

**Example ABR ladder (H.264, 30fps):**

| Rung | Resolution | Bitrate (Mbps) | FPS | Target Devices |
|------|-----------|---------------|-----|----------------|
| 1 | 426x240 | 0.4 | 24-30 | Slow mobile |
| 2 | 640x360 | 0.8 | 30 | Mobile |
| 3 | 842x480 | 1.4 | 30 | Mobile / tablet |
| 4 | 1280x720 | 2.8 | 30 | Tablet / desktop |
| 5 | 1280x720 | 4.0 | 60 | Desktop (high frame rate) |
| 6 | 1920x1080 | 5.0 | 30 | Desktop HD |
| 7 | 1920x1080 | 8.0 | 60 | Desktop HD (high frame rate) |
| 8 | 2560x1440 | 12.0 | 60 | 2K monitors |
| 9 | 3840x2160 | 16.0 | 60 | 4K |

**Design principles:**

1. **Overlap coverage**: Adjacent rungs should be within ~50-80% bitrate ratio so the ABR algorithm can step up/down smoothly without large quality jumps.

2. **Resolution breakpoints**: Each resolution should span a meaningful bitrate range. A resolution at too-low bitrate looks worse than a lower resolution at proper bitrate.

3. **Frame rate variants**: Include 60fps variants for 720p and 1080p if your content benefits (sports, gaming).

4. **Audio ladder**: Typically simpler -- 64kbps (HE-AAC), 128kbps (AAC-LC), and 256kbps (EAC-3) cover most needs.

5. **Maximum rungs**: More rungs mean finer adaptation but more encoding and storage cost. 6-8 rungs is typical for premium services.

### 4.3 Per-Title Encoding Optimization

Per-title encoding analyzes each piece of content individually and produces an optimized encoding ladder. A fast-motion sports video needs different bitrate allocations than a static talking-head interview.

**Approach:**

1. **Analysis pass**: Run a quick analysis of content complexity (motion vectors, spatial detail, scene change frequency).
2. **Ladder generation**: Adjust the ABR ladder per content type:
   - High-complexity content (sports, action): Shift rungs up, allocate more bitrate per resolution.
   - Low-complexity content (news, animation): Shift rungs down, save bandwidth without quality loss.
   - Screen content (presentations, slides): Add specialized low-bitrate rungs.
3. **Encoding**: Encode with the custom ladder.

**Impact**: Per-title encoding typically saves 30-50% bandwidth for low-complexity content while maintaining or improving quality for complex content, compared to fixed ladders.

**Practical implementation**:

- **CAPE (Content-Aware Pre-Encoding)**: Used by AWS MediaConvert and similar services.
- **Capella Systems**, **Harmonic**, **Bitmovin**: Offer per-title encoding APIs.
- **FFmpeg-based**: Use `-crf` encoding with per-scene analysis to determine optimal bitrate, then use that to inform the ladder.

### 4.4 Quality Oscillation and Viewer Impact

**Oscillation problem**: When ABR algorithms switch frequently between renditions (especially across resolution boundaries), the viewer perceives visible quality fluctuations. This is worse than a stable lower quality.

**Causes:**

1. **Noisy bandwidth estimates**: Mobile networks have high variance, causing throughput-based algorithms to overcorrect.
2. **Small buffer**: Insufficient buffer to ride through brief bandwidth dips.
3. **Abrupt resolution changes**: Switching from 1080p to 480p and back is visually jarring.
4. **Segment boundaries**: Quality can only change at segment boundaries (every 2-6 seconds), creating a sawtooth pattern.

**Mitigation strategies:**

| Strategy | Mechanism | Tradeoff |
|----------|-----------|----------|
| **Buffer-based ABR** | Use buffer level, not bandwidth, for decisions | Slower adaptation to real bandwidth changes |
| **BOLA/DYNAMIC** | Hybrid approach reduces oscillation | More complex, requires tuning |
| **Minimum buffer threshold** | Only upshift if buffer > N seconds | Slower upshift after recovery |
| **Hysteresis** | Require bandwidth > current_rung * 1.3x before upshift | Slower upshift |
| **Same-resolution range** | Keep resolution constant, vary bitrate within | Requires overlapping bitrate rungs |
| **Smoothing filter** | Exponential moving average on bandwidth estimate | Slower reaction to genuine changes |

**Rule of thumb**: Viewers prefer stable 720p over oscillating between 720p and 1080p. When in doubt, bias toward stability over peak quality.

---

## 5. RTMP/SRT Ingestion

Ingestion is the process of getting the live video stream from the source (encoder, camera, OBS) to the media server or origin.

### 5.1 RTMP (Real-Time Messaging Protocol)

RTMP was originally developed by Macromedia (later Adobe) for Flash streaming. Despite Flash's demise, RTMP remains the de facto standard for encoder-to-server ingestion due to universal support in OBS, vMix, Wirecast, and hardware encoders.

**Protocol stack:**

```
Application: RTMP (publish/play commands)
Transport:   TCP (port 1935)
Payload:     FLV container (H.264 + AAC)
```

**Limitations:**

| Limitation | Detail |
|-----------|--------|
| **Codec support** | H.264 (AVC) video, AAC/MP3 audio only. No HEVC, no AV1, no Opus |
| **Resolution cap** | Practical limit of 1080p30 at ~10Mbps. Higher requires RTMP extensions |
| **TCP-based** | Head-of-line blocking; packet loss causes retransmission delays |
| **Latency** | 1-3 seconds typical |
| **Security** | RTMPS (TLS) adds encryption but increases latency |

**When to use RTMP:**
- Encoder does not support SRT or WHIP
- Maximum compatibility with existing hardware/software
- Latency of 1-3 seconds is acceptable

**RTMP with HEVC (enhanced RTMP)**: Some vendors (notably YouTube, Vimeo) have extended RTMP to support HEVC by modifying the FLV container. This is non-standard and support varies.

### 5.2 SRT (Secure Reliable Transport)

SRT is an open-source transport protocol (maintained by the SRT Alliance, now part of Haivision) designed for high-quality, low-latency video contribution over unpredictable networks. In 2025, SRT adoption reached 77% among professional broadcasters, surpassing RTMP at 58%.

**Protocol stack:**

```
Application: SRT (connection management, encryption)
Transport:   UDP (configurable port)
Payload:     Any codec (MPEG-TS wrapped) -- H.264, HEVC, AV1, ProRes, etc.
Encryption:  AES-128 or AES-256 (built-in)
```

**Key mechanics:**

1. **Latency/reliability tradeoff**: SRT uses a configurable latency buffer (receiver side). Higher latency tolerance allows more retransmissions, improving reliability over lossy links.

2. **ARQ (Automatic Repeat reQuest)**: When packets are lost, SRT requests retransmission within the latency window. If retransmission arrives in time, the stream is glitch-free. If not, the packet is skipped.

3. **Packet filtering**: SRT can filter out duplicate packets and reorder out-of-order packets.

4. **Encryption**: AES-128/256 encryption is built into the protocol (no separate TLS layer needed).

**Latency settings:**

| SRT Latency | Packet Loss Tolerance | Use Case |
|-------------|----------------------|----------|
| 120ms | Low (<0.1%) | LAN/studio, lowest latency |
| 500ms | Moderate (1-2%) | Typical internet contribution |
| 1000ms | High (3-5%) | Unreliable internet, satellite |
| 2000ms+ | Very high (>5%) | Extreme conditions |

**SRT modes:**

| Mode | Direction | Use Case |
|------|-----------|----------|
| **Caller** | Outbound connection | Encoder connects to server |
| **Listener** | Inbound connection | Server listens for encoder |
| **Rendezvous** | Bidirectional | Both sides connect simultaneously |

**SRT bonding**: Multiple SRT connections can be bonded (aggregated) to increase bandwidth and reliability. If one path fails, others take over seamlessly. This is useful for remote live production where a single ISP connection may be unreliable.

### 5.3 RIST (Reliable Internet Stream Transport)

RIST is a VSF (Video Services Forum) standard designed as an open alternative to SRT, targeting broadcast-grade contribution.

**Comparison with SRT:**

| Feature | SRT | RIST |
|---------|-----|------|
| Standard body | SRT Alliance (Haivision) | VSF (Video Services Forum) |
| Transport | UDP | UDP |
| Retransmission | ARQ (receiver-driven) | ARQ (receiver-driven) |
| Encryption | AES-128/256 (built-in) | DTLS (profile: Main) |
| Multicast | No | Yes |
| Bonding | Via third-party tools | Native (Profile: Advanced) |
| Null packet removal | No | Yes (significant bandwidth savings) |
| Latency range | 120ms - 5s | 50ms - 5s |
| Codec transport | MPEG-TS | MPEG-TS |
| Adoption | 77% of pro broadcasters | Growing, broadcast-focused |

**When to use RIST over SRT:**
- Broadcast environment with existing RTP/RTSP infrastructure
- Multicast distribution is required
- Null packet removal is needed (satellite, ASI-to-IP)
- Vendor interoperability with broadcast equipment is priority

### 5.4 WHIP (WebRTC-HTTP Ingestion Protocol)

WHIP (standardized as IETF RFC 9725, March 2025) provides a simple HTTP-based mechanism to establish WebRTC sessions for media ingestion. It is rapidly replacing RTMP for ultra-low-latency ingest.

**How WHIP works:**

1. Client sends an HTTP POST with an SDP offer to the WHIP endpoint.
2. Server responds with an SDP answer.
3. WebRTC session is established (ICE, DTLS, SRTP).
4. Media flows over WebRTC with sub-second latency.

```
Encoder (OBS) --HTTP POST/SDP--> WHIP Endpoint --> Media Server
Encoder (OBS) <---SDP Answer----   |
Encoder (OBS) ====WebRTC/SRTP====> Media Server
```

**Advantages:**

| Feature | RTMP | WHIP |
|---------|------|------|
| Latency | 1-3s | 100-500ms |
| Codec support | H.264, AAC | H.264, HEVC, AV1, VP9, Opus, AAC |
| Transport | TCP | UDP (ICE/DTLS/SRTP) |
| Encryption | RTMPS (TLS over TCP) | DTLS + SRTP (built-in) |
| OBS support | Native | Native (since v30) |
| Simulcast | No | Yes (native in WebRTC) |
| Standard | Adobe proprietary | IETF RFC 9725 |

**OBS WHIP configuration:**

In OBS Studio v30+, select "WHIP" as the streaming service, enter the WHIP endpoint URL (e.g., `https://whip.example.com/live/stream-key`), and optionally add a Bearer token for authentication.

**WHIP ecosystem support (2025-2026):** Cloudflare Stream, Twitch, AWS IVS, LiveKit, mediasoup, Janus, and most CPaaS vendors expose WHIP endpoints. This makes it the emerging standard for ultra-low-latency ingest.

---

## 6. WebRTC for Ultra-Low-Latency

WebRTC (Web Real-Time Communication) enables sub-second media delivery, making it essential for interactive applications: video conferencing, live auctions, sports betting, remote production, and viewer engagement features.

### 6.1 SFU vs MCU Architectures

**SFU (Selective Forwarding Unit):**

Each participant sends one stream to the SFU. The SFU forwards (routes) each stream to other participants without transcoding. Bandwidth per participant is O(1) -- you send once, the SFU replicates.

```
            [SFU]
           /  |  \
    Peer A  Peer B  Peer C
    (send 1 stream, receive N-1 streams)
```

**MCU (Multipoint Control Unit):**

The server decodes all incoming streams, composites them into a single layout, encodes the composite, and sends one stream to each participant.

```
    Peer A --send--> [MCU: decode + composite + encode] --send--> Peer A
    Peer B --send--> [                                   ] --send--> Peer B
    Peer C --send--> [                                   ] --send--> Peer C
```

| Aspect | SFU | MCU |
|--------|-----|-----|
| **Server CPU** | Low (routing only) | Very high (transcoding all streams) |
| **Server bandwidth** | O(N * N) total | O(N) total |
| **Client bandwidth** | Upload 1, download N-1 | Upload 1, download 1 |
| **Client CPU** | Decode N-1 streams | Decode 1 stream |
| **Latency** | Low (~50-200ms) | Higher (~200-500ms, encode/decode adds delay) |
| **Scalability** | Thousands per cluster | Tens per server |
| **Layout control** | Client-side | Server-side (fixed layout) |
| **Use case** | Large-scale streaming, conferencing | Legacy SIP interop, simple viewer experience |

**Recommendation**: Use SFU for virtually all modern deployments. MCU only for legacy interoperability (SIP/H.323) or when clients cannot decode multiple streams.

### 6.2 Key WebRTC Servers

| Server | Language | Architecture | Strengths | Best For |
|--------|----------|-------------|-----------|----------|
| **Janus** | C | Plugin-based SFU/MCU | Extremely flexible, many plugins (SIP, streaming, recording), battle-tested | Custom solutions, research, broadcast |
| **mediasoup** | C++ (core) + Node.js (API) | SFU | High performance, Node.js API, simulcast/SVC support, well-documented | Video conferencing, edtech |
| **LiveKit** | Go | SFU | Managed + self-hosted, SDKs for all platforms, horizontal scaling, WHIP/WHEP | Startups, rapid deployment, production conferencing |
| **Pion** | Go | Library (not server) | WebRTC building blocks in Go, composable, used inside other products | Custom WebRTC applications, embedded use |
| **Jitsi** | Java | SFU (Videobridge) | Open-source, mature, web-based meetings, recording | Self-hosted video conferencing |
| **GStreamer WebRTC** | C | Library | Pipeline-based, hardware acceleration, codec flexibility | Embedded, IoT, custom pipelines |

**Selection guide:**

- **Need a complete solution fast**: LiveKit (SDKs, scaling, documentation)
- **Need maximum flexibility/customization**: Janus (plugin architecture, any signaling)
- **Building a custom conferencing product**: mediasoup (high-performance SFU, Node.js control)
- **Embedding WebRTC in a Go application**: Pion (composable Go library)
- **Self-hosted Google Meet alternative**: Jitsi

### 6.3 Simulcast and SVC in WebRTC

**Simulcast**: The sender transmits multiple spatial/temporal quality layers of the same stream. The SFU selects which layer to forward to each receiver based on their bandwidth.

```
Sender --> [High (1080p)] --> SFU --> Receiver A (good bandwidth)
       --> [Med  (720p)]  -->     --> Receiver B (moderate bandwidth)
       --> [Low  (360p)]  -->     --> Receiver C (poor bandwidth)
```

WebRTC simulcast uses RID (Restriction Identifiers) and sender-side encoding to produce multiple layers. In OBS with WHIP, simulcast can be configured to send 3 spatial layers.

**SVC (Scalable Video Coding)**: The encoder produces a single bitstream with extractable layers. The base layer provides a low-quality decode, and enhancement layers improve quality. The SFU can strip enhancement layers without transcoding.

| Aspect | Simulcast | SVC |
|--------|-----------|-----|
| **Encoding overhead** | 3x encode (separate streams) | 1.2-1.5x encode (layered) |
| **Bandwidth** | Higher (separate full streams) | Lower (shared base + enhancements) |
| **SFU complexity** | Low (route whole streams) | Medium (parse and strip layers) |
| **Codec support** | VP8, H.264 (some), VP9 (native) | VP9 (native SVC), AV1 (native SVC), H.264 (limited) |
| **Latency** | Same | Same |
| **Deployment** | Widely supported | VP9 SVC widely supported; AV1 SVC emerging |

**VP9 SVC with 3 spatial layers**: Commonly used in Google Meet and similar products. One encode produces 360p, 720p, and 1080p layers from a single bitstream.

### 6.4 Scalability Limits and Cascading

**Single SFU limits:**

| Metric | Typical Limit |
|--------|--------------|
| Concurrent publishers | 500-2,000 (CPU-limited) |
| Concurrent subscribers | 5,000-10,000 (bandwidth-limited) |
| Total streams forwarded | 10,000-20,000 |
| CPU per publisher (1080p) | ~1-3% per core (forwarding only) |

**Cascading for scale**: For large-scale events, deploy SFUs in multiple regions and cascade between them. Each region's SFU handles local viewers, and SFUs relay publisher streams between regions only for streams that cross regions.

```
[Region A: SFU-A] <--> cascade <--> [Region B: SFU-B]
     |                                    |
  Viewers A                            Viewers B
```

**Scaling patterns:**

1. **Vertical**: Bigger instance (more CPU/bandwidth).
2. **Horizontal**: Multiple SFU instances behind a load balancer, each handling a subset of rooms.
3. **Geographic**: Regional SFUs with cascading for cross-region streams.
4. **Publisher/Subscriber split**: Dedicated SFUs for ingestion (fewer, higher bandwidth) and distribution (more, lower per-stream bandwidth).

**LiveKit horizontal scaling**: LiveKit uses Redis for room state and a mesh topology between SFU nodes. Publishers connect to one node; subscribers can be on any node. Nodes relay streams as needed.

### 6.5 WHIP/WHEP Protocols

**WHIP** (WebRTC-HTTP Ingestion Protocol, RFC 9725): Already covered in Section 5.4. Enables browser/encoder to publish via WebRTC using a simple HTTP POST.

**WHEP** (WebRTC-HTTP Egress Protocol, draft-ietf-wish-whep): The counterpart for subscribing. Clients send an HTTP POST to a WHEP endpoint to receive a WebRTC stream.

```
WHIP:  Encoder --POST/SDP offer--> Server --SDP answer--> Encoder
WHEP:  Player  <--SDP answer---- Server <--POST/SDP offer-- Player
```

**WHEP workflow:**

1. Player sends HTTP POST with SDP offer to WHEP endpoint.
2. Server responds with SDP answer containing media description.
3. WebRTC session established, media flows server-to-player.
4. Player can use `Link: <...>; rel="ice-servers"` header for TURN server config.

**Combined WHIP-to-WHEP pipeline:**

```
[OBS] --WHIP--> [Media Server] --WHEP--> [Browser Player]
  RTMP alt:       |
                   +--HLS/DASH--> [CDN] --> [Browser/TV/Mobile]
```

This architecture enables a single media server to accept WHIP ingest and fan out to both WebRTC (via WHEP) and HLS/DASH (via CDN) delivery simultaneously, covering ultra-low-latency and at-scale viewers.

---

## 7. DRM (Digital Rights Management)

DRM protects content from unauthorized copying and redistribution. In streaming, DRM works by encrypting media segments and requiring a license from a license server to decrypt them.

### 7.1 Major DRM Systems

| DRM System | Owner | Device Coverage | Key System ID |
|-----------|-------|----------------|---------------|
| **Widevine** | Google | Android, Chrome, Firefox, Smart TVs, Chromecast (~60% of devices) | `edef8ba9-79d6-4ace-a3c8-27dcd51d21ed` |
| **FairPlay** | Apple | iOS, macOS, Safari, Apple TV, iPad (~25-30% of devices) | `94ce86fb-07ff-4f43-adb8-93d2fa968ca2` |
| **PlayReady** | Microsoft | Windows, Edge, Xbox, Smart TVs, set-top boxes (~15-20% of devices) | `9a04f079-9840-4286-ab92-e65be0885f95` |

**Security levels (Widevine example):**

| Level | Decryption | Typical Devices |
|-------|-----------|----------------|
| **L1** | Hardware-secure (TEE) | Modern Android phones, smart TVs |
| **L2** | Software-secure (not in TEE) | Older Android devices |
| **L3** | Software-only | Chrome/Firefox desktop browsers |

For premium 4K/HDR content, Widevine L1 is required. Browser-only (L3) is typically capped at 1080p.

**Device coverage for multi-DRM**: Deploying all three systems provides 99%+ device coverage. Netflix, Disney+, and Amazon Prime Video use all three simultaneously.

### 7.2 CENC (Common Encryption)

CENC (ISO/IEC 23001-7) is the standard that enables multi-DRM from a single set of encrypted files. Without CENC, each DRM system would require its own encryption scheme and separate storage for encrypted content.

**How CENC works:**

1. Content is encrypted once using AES-128 with a content key.
2. The encrypted segments are stored (same files for all DRM systems).
3. Each DRM system wraps the same content key in its own license format.
4. The player obtains a license from the appropriate license server for its DRM system.
5. The player decrypts using the content key obtained from the license.

```
[Content Key: 0xABCD...]
        |
        v
[Encrypt segments with CENC/CBCS] --> [Store encrypted segments once]
        |
        +--> Widevine license wraps key --> [Widevine License Server]
        +--> FairPlay license wraps key  --> [FairPlay License Server]
        +--> PlayReady license wraps key --> [PlayReady License Server]
```

**Encryption schemes:**

| Scheme | Algorithm | Pattern | Preferred By |
|--------|-----------|---------|-------------|
| `cenc` | AES-128-CTR | Full encryption | PlayReady (legacy), Widevine |
| `cbcs` | AES-128-CBC | Pattern encryption (encrypt N blocks, skip M) | FairPlay (required), Widevine (supported) |

**Best practice**: Use `cbcs` as the single encryption scheme. Both Widevine and FairPlay support it, and Apple requires it. This eliminates the need for dual-encrypted content.

### 7.3 License Server Architecture

The license server is responsible for authenticating clients, enforcing policy (e.g., maximum resolution, offline playback, rental window), and delivering content keys.

**Architecture:**

```
[Player] --License request--> [License Proxy/Auth] --Key request--> [Key Server]
                                        |                              |
                                   Verify user/token          Store/derive content keys
                                   Check device rights
                                   Enforce policies
                                        |
[Player] <--License response-- [License Proxy] (wraps key in DRM format)
```

**Self-hosted options:**

| Solution | Type | DRM Support | Notes |
|----------|------|-------------|-------|
| **castLabs PRESTOplay** | Commercial self-hosted | Widevine, FairPlay, PlayReady | Enterprise-grade, requires agreement |
| **BuyDRM KeyOS** | Commercial SaaS + self-hosted | Widevine, FairPlay, PlayReady | License server operations, unified multi-DRM |
| **Streamora** | Self-hosted (Go binary) | Widevine L1/L3, PlayReady, FairPlay, ClearKey | Single binary, zero dependencies |
| **OpenDRM** | Open source | Widevine, PlayReady, FairPlay | Community project, not production-hardened |
| **Shaka Packager** (built-in) | Self-hosted | Widevine, FairPlay, PlayReady | Packager includes a simple license server for testing |
| **Axine** (castLabs) | Commercial | Widevine, FairPlay | Modular, API-first |

**Important notes on self-hosting DRM:**

- **FairPlay requires Apple approval**: You must apply to Apple for an FPS (FairPlay Streaming) Key Security Module (KSM) certificate. Apple controls this strictly.
- **Widevine requires Google integration**: You must register with Google and integrate with the Widevine Cloud Authentication proxy (or use a third-party service).
- **Cost**: Self-implementing multi-DRM from scratch costs $10,000-50,000+ in setup and $500-5,000/month ongoing. Using a DRM-as-a-service provider (BuyDRM, castLabs, PallyCon) is usually more cost-effective.

### 7.4 Key Rotation for Live Streams

For live streams, using a single content key for the entire broadcast creates a vulnerability: if the key is extracted, all content is compromised. Key rotation periodically changes the content key.

**How key rotation works:**

1. **Key period**: Define a key rotation interval (e.g., every 30 minutes, every 100 segments).
2. **Multiple keys**: The packager generates a new content key at each interval.
3. **Signaling**: The manifest signals the key ID for each segment, and the player requests the appropriate license.
4. **License caching**: The player caches licenses for previously used keys to avoid re-requesting.

**HLS signaling with key rotation:**

```m3u8
#EXT-X-KEY:METHOD=SAMPLE-AES,URI="key-server/key/1",IV=0x...,KEYID=0xAAAA
#EXTINF:6.0,
seg_001.m4s
...
#EXT-X-KEY:METHOD=SAMPLE-AES,URI="key-server/key/2",IV=0x...,KEYID=0xBBBB
#EXTINF:6.0,
seg_030.m4s
```

**DASH signaling with key rotation:**

```xml
<AdaptationSet>
  <ContentProtection schemeIdUri="urn:mpeg:cenc:2013" value="cbcs"
                     cenc:default_KID="AAAA-BBBB-CCCC-DDDD">
    <!-- Key 1 applies to segments in first Period -->
  </ContentProtection>
</AdaptationSet>
<!-- New Period with new key -->
<Period start="PT30M">
  <AdaptationSet>
    <ContentProtection schemeIdUri="urn:mpeg:cenc:2013" value="cbcs"
                       cenc:default_KID="EEEE-FFFF-0000-1111"/>
  </AdaptationSet>
</Period>
```

**Rotation interval guidance:**

| Content Type | Rotation Interval | Rationale |
|-------------|-------------------|-----------|
| 24/7 live stream | Every 30-60 minutes | Balance security vs. license server load |
| Sports event | Every period/quarter | Natural breaks in content |
| News/linear TV | Every hour | Standard broadcast practice |
| Premium VOD | No rotation (single key per title) | VOD is pre-encrypted; rotation not needed |

---

## 8. Packaging Tools

Packaging is the process of taking encoded media (e.g., H.264/HEVC bitstreams) and wrapping them into segment files (CMAF, TS) with manifests (M3U8, MPD) for delivery.

### 8.1 Tool Overview

| Tool | License | Primary Use | Language | DRM Support |
|------|---------|-------------|----------|-------------|
| **Shaka Packager** | BSD (open source) | DASH + HLS packaging, encryption | C++ | Widevine, FairPlay, PlayReady, ClearKey |
| **Bento4** | GPL/Commercial | MP4/fMP4 manipulation, DASH packaging | C++ | Widevine (via plugins) |
| **FFmpeg** | LGPL/GPL | Encode + transcode + package (all-in-one) | C | AES-128 (HLS), Sample-AES |

### 8.2 Shaka Packager

Shaka Packager (by Google, part of the Shaka Project) is a media packaging and encryption framework for VOD and live DASH and HLS. It supports CMAF, Common Encryption, and both VOD and live workflows.

**Key features:**
- Transmux from one container to another (e.g., MP4 to fMP4, TS to fMP4)
- Package for DASH and HLS simultaneously from a single input
- Encrypt with CENC/CBCS for multi-DRM
- Live packaging with segment templates
- Does NOT transcode -- content must be pre-encoded

**Example: VOD packaging for DASH + HLS with CMAF:**

```bash
packager \
  'in=input.mp4,stream=video,output=video_1080p.m4s,init_segment=video_1080p_init.mp4' \
  'in=input.mp4,stream=audio,output=audio.m4s,init_segment=audio_init.mp4' \
  --mpd_output manifest.mpd \
  --hls_master_playlist_output master.m3u8 \
  --segment_duration 6
```

**Example: Live packaging with DRM:**

```bash
packager \
  'in=udp://233.1.1.1:5000,stream=video,output=video.m4s' \
  'in=udp://233.1.1.1:5000,stream=audio,output=audio.m4s' \
  --mpd_output live.mpd \
  --hls_master_playlist_output live.m3u8 \
  --segment_duration 4 \
  --live \
  --enable_raw_key_encryption \
  --keys label=video:key_id=AAAA:key=BBBB \
  --protection_scheme cbcs
```

**Example: LL-HLS packaging:**

```bash
packager \
  'in=input.mp4,stream=video,output=video.m4s' \
  --hls_master_playlist_output master.m3u8 \
  --hls_parameter_prediction --hls_partial_duration 0.5 \
  --segment_duration 4
```

### 8.3 Bento4

Bento4 is a C++ library and tool suite for MP4 file manipulation. It is widely used for DASH/CMAF packaging and provides fine-grained control over fMP4 segmentation.

**Key tools:**

| Tool | Purpose |
|------|---------|
| `mp4dash` | Create DASH manifest and segments from MP4 input |
| `mp4hls` | Create HLS playlists and segments from MP4 input |
| `mp4fragment` | Fragment a non-fragmented MP4 |
| `mp4encrypt` | Encrypt MP4 with CENC/CBCS |
| `mp4info` | Display MP4 file information |
| `mp4dump` | Dump MP4 box structure |

**Example: DASH + HLS packaging:**

```bash
# Fragment the input
mp4fragment --fragment-duration 6000 input.mp4 fragmented.mp4

# Create DASH output
mp4dash --mpd-name manifest.mpd --subtitles fragmented.mp4

# Create HLS output (from same fragmented file)
mp4hls fragmented.mp4 --output hls_output/
```

**Example: CENC encryption:**

```bash
mp4encrypt \
  --method CBCS \
  --key 1:AAAA:BBBB \
  --iv 1:CCCC \
  --property 1:KID:AAAA \
  fragmented.mp4 encrypted.mp4
```

### 8.4 FFmpeg for Packaging

FFmpeg can both encode and package in a single command. While not as specialized as Shaka or Bento4 for packaging, it is the most commonly used tool due to its ubiquity.

**Example: HLS packaging with fMP4 segments:**

```bash
ffmpeg -i input.mp4 \
  -c:v libx264 -b:v 5000k -s 1920x1080 -r 30 \
  -c:v libx264 -b:v 2800k -s 1280x720 -r 30 \
  -c:a aac -b:a 128k \
  -var_stream_map "v:0,a:0 v:1,a:0" \
  -f hls \
  -hls_time 6 \
  -hls_playlist_type vod \
  -hls_segment_type fmp4 \
  -hls_segment_filename "stream_%v/seg_%03d.m4s" \
  -master_pl_name master.m3u8 \
  "stream_%v/stream.m3u8"
```

**Example: DASH packaging:**

```bash
ffmpeg -i input.mp4 \
  -c:v libx264 -b:v:0 5000k -s:0 1920x1080 \
  -c:v libx264 -b:v:1 2800k -s:1 1280x720 \
  -c:a aac -b:a 128k \
  -adaptation_sets "id=0,streams=v id=1,streams=a" \
  -f dash \
  -seg_duration 6 \
  -init_seg_name "init_\$RepresentationID\$.mp4" \
  -media_seg_name "seg_\$RepresentationID\$_\$Number\$.m4s" \
  manifest.mpd
```

**Example: Live RTMP to HLS (with nginx-rtmp or similar):**

```bash
ffmpeg -i rtmp://source-server/live/stream_key \
  -c:v libx264 -b:v 2800k -s 1280x720 \
  -c:a aac -b:a 128k \
  -f hls \
  -hls_time 4 \
  -hls_list_size 6 \
  -hls_flags delete_segments+append_list \
  -hls_segment_filename "/var/www/html/live/seg_%03d.ts" \
  /var/www/html/live/stream.m3u8
```

**FFmpeg limitations for packaging:**
- HLS + DASH packaging in a single command is not well-supported (use Shaka or Bento4 for simultaneous output)
- DRM encryption support is limited (AES-128 for HLS, Sample-AES for FairPlay, but no CENC multi-DRM)
- Live packaging with LL-HLS requires custom post-processing

### 8.5 Just-in-Time Packaging vs Pre-Packaged

| Approach | Description | Pros | Cons |
|----------|------------|------|------|
| **Pre-packaged** | All renditions and manifests generated at encode time | CDN cacheable, no origin compute, predictable performance | Storage cost, delayed availability, inflexible |
| **JIT (Just-in-Time)** | Origin generates manifests/segments on-the-fly from a mezzanine file | Single storage copy, flexible manifests, instant format changes | Origin compute required, cache-miss penalty, complex origin |
| **Hybrid** | Pre-package popular content, JIT for long-tail | Best of both worlds | More complex architecture |

**JIT packaging architecture:**

```
[CDN Edge] --cache miss--> [Origin: JIT Packager] --> [Storage: Mezzanine files]
                                |
                         Generate manifest/segment on-the-fly
                         Apply DRM, watermark, personalization
                                |
[CDN Edge] <--cache fill---- [Origin]
```

**When to use JIT:**
- Large catalog with long-tail content (not everything needs pre-packaging)
- Personalized manifests (per-user DRM keys, ad insertion, watermarking)
- Multiple output formats from a single mezzanine (reducing storage)
- Server-side ad insertion (SSAI) where manifests are customized per viewer

**When to use pre-packaged:**
- Live streaming (segments must be ready immediately)
- High-volume VOD (Netflix-scale, where everything gets pre-packaged)
- Simplicity and reliability (no origin compute dependency)

### 8.6 Nginx Origin Configuration for HLS/DASH Delivery

For self-hosted origins, Nginx serves HLS/DASH segments as static files with proper MIME types, CORS headers, and caching directives.

**Basic origin configuration:**

```nginx
server {
    listen 80;
    server_name origin.example.com;

    root /var/www/media;

    # HLS delivery
    location /hls/ {
        types {
            application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
            video/mp4 m4s mp4;
        }
        add_header Cache-Control "no-cache, no-store";  # Live playlists
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods "GET, OPTIONS";
        add_header Access-Control-Allow-Headers "Origin, Range";

        # VOD segments: cache longer
        location ~* \.ts$ {
            add_header Cache-Control "max-age=86400";
        }
        location ~* \.m4s$ {
            add_header Cache-Control "max-age=86400";
        }
    }

    # DASH delivery
    location /dash/ {
        types {
            application/dash+xml mpd;
            video/mp4 m4s mp4;
        }
        add_header Cache-Control "no-cache, no-store";
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods "GET, OPTIONS";
        add_header Access-Control-Allow-Headers "Origin, Range";

        location ~* \.m4s$ {
            add_header Cache-Control "max-age=86400";
        }
    }
}
```

**With nginx-vod-module (JIT packaging):**

The `kaltura/nginx-vod-module` enables just-in-time packaging directly in Nginx. It can generate HLS and DASH manifests and segments from MP4 source files on the fly.

```nginx
server {
    listen 80;
    server_name origin.example.com;

    # JIT HLS from MP4 source
    location /hls-jit/ {
        vod hls;
        vod_mode mapped;
        vod_align_segments_to_key_frames on;
        vod_segment_duration 6000;  # 6 seconds
        vod_hls_mpegts_interleave on;

        # Map request URI to source file
        vod_mapping_uri /mapping/$uri;

        types {
            application/vnd.apple.mpegurl m3u8;
        }
        add_header Access-Control-Allow-Origin *;
    }

    # JIT DASH from same MP4 source
    location /dash-jit/ {
        vod dash;
        vod_mode mapped;
        vod_align_segments_to_key_frames on;
        vod_segment_duration 6000;

        vod_mapping_uri /mapping/$uri;

        types {
            application/dash+xml mpd;
        }
        add_header Access-Control-Allow-Origin *;
    }

    # Source file mapping
    location /mapping/ {
        internal;
        alias /var/www/mappings/;
    }

    # Source media files
    location /media/ {
        internal;
        alias /var/www/media/;
    }
}
```

**With nginx-rtmp-module (live ingest + HLS output):**

```nginx
rtmp {
    server {
        listen 1935;
        application live {
            live on;
            record off;

            # Generate HLS on publish
            hls on;
            hls_path /var/www/html/hls;
            hls_fragment 4;          # 4 second segments
            hls_playlist_length 20;  # Keep 5 segments in playlist
            hls_fragment_naming system;

            # Also push to SRT/SRT relay if needed
            # push srt://relay-server:6000;
        }
    }
}

http {
    server {
        listen 8080;

        location /hls/ {
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            root /var/www/html;
            add_header Cache-Control "no-cache";
            add_header Access-Control-Allow-Origin *;
        }
    }
}
```

**Cache strategy for live vs VOD:**

| Content | File Type | Cache-Control | Rationale |
|---------|-----------|---------------|-----------|
| Live playlist | `.m3u8`, `.mpd` | `no-cache` or `max-age=1` | Must refresh frequently |
| VOD playlist | `.m3u8`, `.mpd` | `max-age=86400` | Static, never changes |
| Live segments | `.ts`, `.m4s` | `max-age=60` | Short-lived but cacheable during broadcast |
| VOD segments | `.ts`, `.m4s` | `max-age=31536000` (1 year) | Immutable, aggressively cache |
| Init segments | `init.mp4` | `max-age=86400` | Codec config, rarely changes |

---

## Quick Reference: Protocol Selection Matrix

| Requirement | Protocol | Latency | Scalability | Complexity |
|------------|----------|---------|-------------|------------|
| VOD delivery (at scale) | HLS + DASH (CMAF) | N/A (VOD) | Excellent (CDN cacheable) | Low |
| Standard live streaming | HLS (6s segments) | 15-20s | Excellent | Low |
| Low-latency live | LL-HLS / LL-DASH | 2-5s | Good | Medium |
| Interactive (chat, games) | WebRTC (WHEP) | <500ms | Moderate (SFU-limited) | High |
| Encoder ingest (legacy) | RTMP | 1-3s | Good | Low |
| Encoder ingest (pro) | SRT | 0.5-2s | Good | Medium |
| Encoder ingest (ultra-low) | WHIP | <500ms | Good | Medium |
| Broadcast contribution | RIST or SRT | 0.5-2s | Good | Medium |

---

## Quick Reference: Packaging Pipeline

```
[Source Video]
     |
     v
[Transcode] -- FFmpeg, x264/x265, SVT-AV1
     |
     v
[Package] -- Shaka Packager, Bento4, FFmpeg
     |        Generate: .m4s segments + init.mp4 + .m3u8 + .mpd
     |
     v
[Encrypt] -- Shaka Packager, Bento4 mp4encrypt
     |        CENC/CBCS, multi-DRM key IDs
     |
     v
[Origin] -- Nginx, S3, object storage
     |        Static file serving, JIT packaging
     |
     v
[CDN] -- Cloudflare, Fastly, Akamai
     |        Cache segments, edge delivery
     |
     v
[Player] -- Shaka Player, hls.js, dash.js, AVPlayer
              ABR logic, DRM license acquisition, rendering
```
