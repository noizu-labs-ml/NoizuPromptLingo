# iOS Deployment Guide

Building and deploying games to the Apple App Store.

## App Store Guidelines (Key Rules for Games)

### Content Guidelines

| Category | Rule | Impact on Game Design |
|----------|------|----------------------|
| Violence | No realistic violence against humans | Stylize violence, no gore |
| Gambling | No real-money gambling without license | Virtual currency OK, no cash-out |
| Loot boxes | Must disclose drop rates | Publish probability tables |
| Kids category | Stricter content, no behavioral ads | Separate kids version if targeting |
| Violence against animals | No realistic animal cruelty | Stylize or avoid |
| User-generated content | Must have moderation | Content filters, reporting system |

### Technical Requirements

| Requirement | Details |
|-------------|---------|
| Max binary size | 200 MB (over = Wi-Fi download warning) |
| Max on-demand resources | 20 GB total |
| Min iOS version | Set in Xcode, affects device coverage |
| 64-bit required | No 32-bit support since iOS 11 |
| Privacy manifest | Required for tracking, analytics |
| App Tracking Transparency | Must prompt before tracking |

## Unity iOS Build Pipeline

### Project Setup

```
1. Unity → File → Build Settings → iOS
2. Player Settings:
   - Bundle Identifier: com.company.gamename
   - Version: X.Y.Z (semver)
   - Build: Incrementing integer
   - Target Device: iPhone + iPad (or iPhone only)
   - Target Minimum iOS Version: 14.0 (covers 95%+ devices)
   - Architecture: ARM64 only
   - Scripting Backend: IL2CPP (required for App Store)
   - API Compatibility: .NET Standard 2.1
```

### Performance Optimization

| Area | Guideline | Tool |
|------|----------|------|
| Draw calls | <100 per frame | Unity Profiler |
| Triangle count | <100K visible | Frame Debugger |
| Texture memory | <200 MB total | Memory Profiler |
| Shader complexity | Simple mobile shaders | Frame Debugger |
| Scripting | Avoid GC allocations in Update | Profiler |
| Audio | Compressed (Vorbis) for SFX | Audio Inspector |
| Assets | Addressables for large content | Addressables window |

### IAP Integration

```yaml
iap_setup:
  store: Apple App Store
  sdk: Unity IAP or Apple StoreKit 2
  products:
    - type: consumable  # gems, coins, energy
      id: "com.company.game.gems_100"
    - type: non_consumable  # character unlock, ad removal
      id: "com.company.game.hero_dragon"
    - type: subscription  # VIP pass, daily gems
      id: "com.company.game.vip_monthly"
  testing: Sandbox Test Accounts in App Store Connect
  receipt_validation: Server-side (required for security)
```

### App Store Connect Checklist

- [ ] App name (30 chars max, unique)
- [ ] Subtitle (30 chars max)
- [ ] Description (4000 chars)
- [ ] Keywords (100 chars, comma-separated)
- [ ] Screenshots (6.5" iPhone, 12.9" iPad minimum)
- [ ] App Preview video (optional, 15-30 seconds)
- [ ] App icon (1024x1024, no alpha, no rounded corners)
- [ ] Age rating questionnaire
- [ ] Privacy policy URL (required)
- [ ] Support URL (required)
- [ ] In-app purchases configured
- [ ] Game Center enabled (if using leaderboards/achievements)
- [ ] Review information (contact, demo account)

## Device Coverage Strategy

| Device Tier | Models | Performance | Strategy |
|------------|--------|-------------|----------|
| **Flagship** | iPhone 15/16 Pro | High | Ultra settings, all features |
| **Current** | iPhone 13/14/15 | Good | High settings |
| **Popular** | iPhone XR/11/12 | Medium | Medium settings, simplified effects |
| **Legacy** | iPhone 8/X | Low | Low settings, reduced complexity |
| **Minimum** | iPhone SE (2nd gen) | Baseline | All features, minimum visual fidelity |
