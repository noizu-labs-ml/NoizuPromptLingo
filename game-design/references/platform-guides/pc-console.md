# PC & Console Deployment

Building and deploying games to Steam, Epic Games Store, and console platforms.

## Steam Distribution

### Steam Requirements

| Requirement | Details |
|-------------|---------|
| Steamworks SDK | Required for Steam features |
| Steam Direct fee | $100 per game (recoupable at $1K revenue) |
| Store page | Must be live for 2 weeks before launch |
| Achievements | Up to 5,000 achievements |
| Trading cards | Eligible after revenue thresholds |
| Cloud saves | Up to 100 MB per user per game |
| Workshop | For UGC/mod support |

### Steam Build Pipeline

```
1. Unity Build Settings → PC, Mac & Linux Standalone
2. Architecture: x86_64
3. Scripting Backend: IL2CPP (recommended) or Mono
4. API Compatibility: .NET Standard 2.1
5. Build output → SteamPipe upload
6. Deploy to branches: default, beta, preview
```

### Steam Features Integration

| Feature | Implementation Effort | Value |
|---------|---------------------|-------|
| Achievements | Low | High — completionists |
| Cloud saves | Low | Medium — convenience |
| Leaderboards | Low | Medium — competition |
| Trading cards | None (Steam-managed) | Medium — marketplace |
| Workshop (mods) | High | Very High — longevity |
| Multiplayer (Steam) | Medium | High — matchmaking |
| Stats & achievements | Low | Medium — analytics |
| DLC management | Low | High — monetization |

### Steam Store Page Optimization

| Element | Best Practice |
|---------|--------------|
| Capsule images | 16:9 hero, show gameplay not logo |
| Trailer | First 5 seconds = hook, show gameplay |
| Screenshots | 12-20, show variety of gameplay |
| Tags | 5-10 accurate genre tags |
| Description | Lead with hook, not feature list |
| System requirements | Accurate min/rec specs |
| Price | Research comparable titles |

## Epic Games Store

| Difference | Steam | EGS |
|-----------|-------|-----|
| Revenue split | 70/30 | 88/12 |
| Audience | 120M+ MAU | 75M+ users |
| Discovery | Algorithm-driven | Curated |
| Review system | User reviews | Ratings only |
| Workshop | Built-in | Not available |
| Early Access | Yes | Yes |
| Free games | Rare | Weekly free games |

## Console Certification

### Platform Overview

| Console | SDK Access | Cost | Certification | Timeline |
|---------|-----------|------|---------------|----------|
| **PlayStation 5** | Apply on PlayStation Partners | Free (dev kit cost) | Strict, 2-4 week process | 3-6 months |
| **Xbox Series X/S** | ID@Xbox program | Free | Moderate, 1-3 weeks | 2-4 months |
| **Nintendo Switch** | Nintendo Developer Portal | Free (dev kit cost) | Strict, 2-4 weeks | 3-6 months |

### Certification Requirements (General)

| Category | Typical Requirements |
|----------|---------------------|
| **Performance** | Stable 30 or 60 FPS, no frame drops >5ms |
| **Memory** | No memory leaks, within platform limits |
| **Storage** | Efficient install size, patch size limits |
| **Controls** | Full controller support, consistent mapping |
| **Networking** | Graceful disconnect handling, reconnection |
| **Save games** | Proper save/load, no corruption |
| **Audio** | Proper mixing, no clipping, subtitle support |
| **Accessibility** | Text scaling, colorblind options, remapping |
| **Legal** | Rating board compliance, privacy policy |

### Console Development Timeline

```
Month 1-2: Dev kit setup, SDK integration
Month 3-4: Platform-specific adaptation
Month 5-6: Performance optimization to cert requirements
Month 7: Certification submission
Month 8: Certification response + fixes
Month 9: Re-submission (if needed)
Month 10: Approved → manufacture/digital prep
Month 11: Launch
```

## PC Performance Targets

| Spec | Minimum | Recommended | Ultra |
|------|---------|-------------|-------|
| **CPU** | i5-4460 / Ryzen 3 1200 | i5-8400 / Ryzen 5 2600 | i7-10700 / Ryzen 7 5800X |
| **GPU** | GTX 760 / RX 560 | GTX 1060 / RX 580 | RTX 3070 / RX 6800 |
| **RAM** | 8 GB | 16 GB | 32 GB |
| **Storage** | HDD | SSD | NVMe SSD |
| **Target FPS** | 30 FPS (low) | 60 FPS (medium) | 60-120 FPS (ultra) |
| **Resolution** | 1080p | 1080p-1440p | 1440p-4K |
