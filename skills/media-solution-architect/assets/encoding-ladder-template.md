# Encoding Ladder Template

Fillable template for defining custom encoding ladders. Adapt the rungs to your content, audience, and bandwidth distribution.

---

## Instructions

1. **Profile your viewers**: Check analytics for device types, screen resolutions, and connection speeds
2. **Choose your codecs**: Typically H.264 for compatibility + one efficient codec (HEVC or AV1)
3. **Set rungs**: Start from the recommended defaults below, then adjust based on viewer data
4. **Validate**: Encode test content at each rung, measure VMAF, ensure quality is acceptable
5. **Deploy**: Test with real viewers, monitor ABR switching behavior

## H.264 Encoding Ladder (Compatibility)

| # | Resolution | Bitrate (kbps) | Framerate | Profile | Level | VMAF Target | Use Case |
|---|-----------|----------------|-----------|---------|-------|-------------|----------|
| 1 | 426×240 | 400 | 30 | Baseline | 3.0 | 85+ | Lowest mobile |
| 2 | 640×360 | 800 | 30 | Main | 3.0 | 88+ | Low mobile |
| 3 | 854×480 | 1200 | 30 | Main | 3.1 | 90+ | Medium mobile |
| 4 | 1280×720 | 2500 | 30 | High | 3.1 | 92+ | HD mobile/tablet |
| 5 | 1280×720 | 3500 | 60 | High | 4.0 | 93+ | HD 60fps |
| 6 | 1920×1080 | 5000 | 30 | High | 4.1 | 93+ | Full HD |
| 7 | 1920×1080 | 8000 | 60 | High | 4.2 | 95+ | Full HD 60fps |
| 8 | 2560×1440 | 12000 | 30 | High | 5.0 | 94+ | QHD |
| 9 | 3840×2160 | 20000 | 30 | High | 5.1 | 94+ | 4K |
| 10 | 3840×2160 | 30000 | 60 | High | 5.2 | 95+ | 4K 60fps |

## HEVC Encoding Ladder (Efficiency)

| # | Resolution | Bitrate (kbps) | Framerate | Profile | VMAF Target | Savings vs H.264 |
|---|-----------|----------------|-----------|---------|-------------|-------------------|
| 1 | 640×360 | 500 | 30 | Main | 88+ | ~38% |
| 2 | 854×480 | 800 | 30 | Main | 90+ | ~33% |
| 3 | 1280×720 | 1500 | 30 | Main | 92+ | ~40% |
| 4 | 1280×720 | 2200 | 60 | Main | 93+ | ~37% |
| 5 | 1920×1080 | 3000 | 30 | Main | 93+ | ~40% |
| 6 | 1920×1080 | 5000 | 60 | Main | 95+ | ~38% |
| 7 | 2560×1440 | 7000 | 30 | Main | 94+ | ~42% |
| 8 | 3840×2160 | 12000 | 30 | Main 10 | 94+ | ~40% |
| 9 | 3840×2160 | 18000 | 60 | Main 10 | 95+ | ~40% |

## AV1 Encoding Ladder (Next-Gen)

| # | Resolution | Bitrate (kbps) | Framerate | Profile | VMAF Target | Savings vs H.264 |
|---|-----------|----------------|-----------|---------|-------------|-------------------|
| 1 | 640×360 | 400 | 30 | Main | 88+ | ~50% |
| 2 | 854×480 | 700 | 30 | Main | 90+ | ~42% |
| 3 | 1280×720 | 1300 | 30 | Main | 92+ | ~48% |
| 4 | 1280×720 | 1800 | 60 | Main | 93+ | ~49% |
| 5 | 1920×1080 | 2500 | 30 | Main | 93+ | ~50% |
| 6 | 1920×1080 | 4000 | 60 | Main | 95+ | ~50% |
| 7 | 2560×1440 | 6000 | 30 | Main | 94+ | ~50% |
| 8 | 3840×2160 | 10000 | 30 | Main | 94+ | ~50% |
| 9 | 3840×2160 | 16000 | 60 | Main | 95+ | ~47% |

## Custom Ladder

| # | Resolution | Codec | Bitrate (kbps) | Framerate | Profile | VMAF Target | Notes |
|---|-----------|-------|----------------|-----------|---------|-------------|-------|
| 1 | | | | | | | |
| 2 | | | | | | | |
| 3 | | | | | | | |
| 4 | | | | | | | |
| 5 | | | | | | | |
| 6 | | | | | | | |

## Notes

- **Bitrate spacing**: Ensure at least 30–50% bitrate difference between adjacent rungs to avoid ABR thrashing
- **Redundant rungs**: Remove rungs where bitrate difference is <25% — players won't switch meaningfully
- **Framerate**: Only include 60fps rungs if source is 60fps; 30fps → 60fps wastes bandwidth
- **Audio**: Add 128kbps AAC-LC (stereo) or 256kbps (surround) per rung in your total bitrate budget
- **Per-title encoding**: For high-value VOD content, run per-title analysis to optimize individual ladder rungs per content complexity
