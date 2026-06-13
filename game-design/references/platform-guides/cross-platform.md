# Cross-Platform Development

Architecture patterns for building games that deploy across iOS, Android, PC, and console.

## Cross-Platform Strategy Matrix

| Strategy | Description | Code Sharing | Performance | Effort |
|----------|-------------|-------------|-------------|--------|
| **Engine-native** | Unity/Unreal handles platforms | 80-95% | Good | Low |
| **Shared logic + native UI** | C++ core, platform-specific UI | 50-70% | Excellent | Medium |
| **Web wrapper** | HTML5 game in native shell | 90%+ | Poor | Very Low |
| **Separate codebases** | Fully native per platform | 0% | Best per platform | Very High |
| **Hybrid** | Engine gameplay, native menus | 70-85% | Good | Medium |

## Unity Cross-Platform Architecture

### Shared Code Strategy

```
Assets/
├── Scripts/              # 100% shared
│   ├── Core/             # Game logic, no platform dependencies
│   │   ├── Economy/
│   │   ├── Combat/
│   │   └── Progression/
│   ├── Platform/         # Platform abstraction layer
│   │   ├── IStoreManager.cs       # Interface
│   │   ├── IAnalyticsManager.cs   # Interface
│   │   ├── ISocialManager.cs      # Interface
│   │   └── Implementations/
│   │       ├── AppleStoreManager.cs
│   │       ├── GoogleStoreManager.cs
│   │       ├── SteamManager.cs
│   │       └── EditorStoreManager.cs  # For testing
│   └── Config/           # Platform-specific config
│       ├── MobileConfig.cs
│       ├── PCConfig.cs
│       └── ConsoleConfig.cs
├── Addressables/         # Platform-optimized assets
│   ├── Shared/           # All platforms
│   ├── Mobile/           # Mobile-optimized textures
│   └── HD/               # PC/console high-res
└── Plugins/              # Platform-specific native plugins
    ├── iOS/
    ├── Android/
    └── Steam/
```

### Platform Abstraction Pattern

```csharp
// Define interface for platform-specific functionality
public interface IPlatformService
{
    void Initialize();
    void ShowStore();
    void ReportScore(string leaderboard, long score);
    void UnlockAchievement(string id);
    void ShareResult(string text, Texture2D image);
    string GetPlatformName();
}

// Register based on platform at startup
#if UNITY_IOS
    platformService = new IOSPlatformService();
#elif UNITY_ANDROID
    platformService = new AndroidPlatformService();
#elif UNITY_STANDALONE
    platformService = new SteamPlatformService();
#else
    platformService = new EditorPlatformService();
#endif
```

### Asset Management by Platform

| Asset Type | Mobile Strategy | PC Strategy | Console Strategy |
|-----------|----------------|-------------|-----------------|
| Textures | Max 1024px, ETC2/ASTC compression | Max 4096px, BC7 compression | Max 4096px, BC7 compression |
| Meshes | LOD aggressive, low poly | LOD moderate | LOD minimal |
| Audio | MP3/Vorbis, low sample rate | Vorbis/FLAC, high quality | Vorbis/FLAC, high quality |
| Shaders | Mobile simplified | Full effects | Full + platform-specific |
| Video | 720p H.264 | 1080p/4K H.265 | 1080p/4K H.265 |

## Platform-Specific Feature Matrix

| Feature | iOS | Android | PC (Steam) | Console |
|---------|-----|---------|-----------|---------|
| IAP | StoreKit 2 | Play Billing 6 | Steam Microtxn | Platform-specific |
| Leaderboards | Game Center | Play Games | Steam Leaderboards | Platform-specific |
| Achievements | Game Center | Play Games | Steam Achievements | Platform-specific |
| Cloud Saves | iCloud | Play Games | Steam Cloud | Platform-specific |
| Social | Game Center | Play Games | Steam Friends | Platform-specific |
| Push | APNs | FCM | Steam Notifications | Platform-specific |
| Ads | AdMob, ironSource | AdMob, ironSource | Rarely used | Not available |
| Analytics | Firebase + Adjust | Firebase + Adjust | Steam Analytics | Platform-specific |
| Auth | Sign in with Apple | Google Sign-In | Steam Auth | Platform-specific |
| Multiplayer | Game Center / custom | Google Play / custom | Steam Matchmaking | Platform-specific |

## Quality Settings by Platform

### Mobile Quality Presets

```yaml
mobile_low:
  resolution: 720p
  texture_quality: Quarter
  shadow_quality: Disabled
  anti_aliasing: Disabled
  particle_effects: Minimal
  draw_distance: Near
  target_fps: 30

mobile_medium:
  resolution: Native
  texture_quality: Half
  shadow_quality: Low
  anti_aliasing: 2x MSAA
  particle_effects: Reduced
  draw_distance: Medium
  target_fps: 30

mobile_high:
  resolution: Native
  texture_quality: Full
  shadow_quality: Medium
  anti_aliasing: 4x MSAA
  particle_effects: Full
  draw_distance: Far
  target_fps: 60

pc_ultra:
  resolution: Native (up to 4K)
  texture_quality: Full
  shadow_quality: High
  anti_aliasing: TAA
  particle_effects: Full + volumetrics
  draw_distance: Ultra
  target_fps: 60-120
```

## Cross-Platform Testing Strategy

| Test Type | Tool | Platforms | Frequency |
|-----------|------|-----------|-----------|
| Automated unit tests | Unity Test Framework | All | Every commit |
| Device farm testing | Firebase Test Lab, AWS Device Farm | iOS + Android | Daily |
| Performance profiling | Unity Profiler + platform tools | All | Weekly |
| Certification testing | Platform-specific submission tools | Console | Pre-submission |
| Playtest | Real players | All | Bi-weekly |
| Regression | Manual + automated | All | Pre-release |

## Cross-Platform Launch Strategy

| Phase | Platform | Timing |
|-------|----------|--------|
| Soft launch | iOS + Android (selected markets) | Month 1-3 |
| Mobile launch | iOS + Android (worldwide) | Month 4 |
| PC Early Access | Steam | Month 5-6 |
| PC Full Launch | Steam + Epic | Month 7-8 |
| Console (if applicable) | PlayStation, Xbox, Switch | Month 9-12 |

This staggered approach allows:
- Mobile first (fastest iteration, largest audience)
- PC second (higher quality expectations, less fragmentation)
- Console last (certification requirements, longest lead time)
- Cross-save/cross-play can be added post-launch per platform
