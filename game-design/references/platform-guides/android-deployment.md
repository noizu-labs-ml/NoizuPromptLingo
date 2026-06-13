# Android Deployment Guide

Building and deploying games to the Google Play Store, with device fragmentation considerations.

## Google Play Policies (Key Rules for Games)

### Content Policies

| Category | Rule | Impact |
|----------|------|--------|
| Violence | Moderate violence OK, no gratuitous gore | Similar to iOS |
| Gambling | Real-money gambling restricted | Virtual OK with disclosures |
| Loot boxes | Must disclose odds in app listing | Add to store description |
| Kids | Designed for Families program | Stricter ads/data rules |
| Content rating | IARC questionnaire | Determines age rating per region |
| User-generated content | Moderation required | Reporting system needed |

### Technical Requirements

| Requirement | Details |
|-------------|---------|
| Max APK size | 150 MB (use AAB for larger) |
| Android App Bundle | Required for new apps since 2021 |
| Target API level | Must target latest within 1 year |
| 64-bit required | All apps must have 64-bit version |
| Data safety section | Must declare data collection |

## Unity Android Build Pipeline

### Project Setup

```
1. Unity → File → Build Settings → Android
2. Player Settings:
   - Bundle Identifier: com.company.gamename
   - Version: X.Y.Z (semver)
   - Bundle Version Code: Incrementing integer
   - Minimum API Level: Android 7.0 (API 24) covers 95%+ devices
   - Target API Level: Automatic (highest installed)
   - Scripting Backend: IL2CPP
   - Target Architectures: ARM64 (required), ARMv7 (optional)
   - Build System: Gradle
   - Export Format: Android App Bundle (.aab)
```

### Device Fragmentation Strategy

| Fragmentation Axis | Strategy |
|-------------------|----------|
| **Screen sizes** | Use Canvas Scaler, anchor-based UI, test on 4.7"-12" screens |
| **GPU capability** | Quality settings tiers (Low/Medium/High/Ultra) |
| **RAM** | 2GB/4GB/6GB+ tiers with asset loading strategy |
| **CPU** | ARM64 primary, ARMv7 secondary, no x86 |
| **Android versions** | Min SDK 24 (Android 7.0), target latest |
| **Aspect ratios** | Support 16:9, 18:9, 19.5:9, 20:9, 21:9 |

### Performance by Device Tier

| Tier | Representative Devices | GPU | Strategy |
|------|----------------------|-----|----------|
| **Flagship** | Galaxy S24, Pixel 8 | Adreno 750, Mali-G715 | Ultra settings |
| **Premium** | Galaxy S22, Pixel 7 | Adreno 730, Mali-G710 | High settings |
| **Mid-range** | Galaxy A54, Pixel 6a | Adreno 642, Mali-G68 | Medium settings |
| **Budget** | Galaxy A14, Redmi Note 12 | Mali-G52, Adreno 610 | Low settings |
| **Minimum** | Galaxy A03, Redmi 10 | Mali-G52 (underclocked) | Minimum viable |

### IAP Integration

```yaml
iap_setup:
  store: Google Play Store
  sdk: Unity IAP or Google Play Billing Library 6+
  products:
    - type: consumable  # gems, coins, energy
      id: "gems_100"
    - type: non_consumable  # character, ad removal
      id: "hero_dragon"
    - type: subscription  # VIP pass
      id: "vip_monthly"
  testing: License Test Accounts in Play Console
  receipt_validation: Server-side with Google Play Developer API
```

### Google Play Console Checklist

- [ ] App name (30 chars)
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] Store listing graphics (phone, tablet, TV)
- [ ] Feature graphic (1024x500)
- [ ] App icon (512x512)
- [ ] Screenshots (minimum 4, phone + tablet)
- [ ] Content rating (IARC questionnaire)
- [ ] Data safety form (required)
- [ ] Privacy policy URL (required)
- [ ] In-app products configured
- [ ] Pricing & distribution (countries)
- [ ] AAB uploaded and signed
- [ ] Internal test track verified

## Android-Specific Considerations

### Back Button Handling

Android has a hardware/software back button that must be handled:

```
- In-game: Pause menu or "are you sure you want to quit?"
- In-menu: Navigate to previous screen
- In-overlay: Close overlay first
- Never: Ignore the back button (users expect it to work)
```

### Storage & Permissions

| Permission | When Needed | Alternative |
|-----------|------------|-------------|
| READ_EXTERNAL_STORAGE | Accessing photos/files | Use SAF (Storage Access Framework) |
| INTERNET | Multiplayer, ads, analytics | Required for most F2P games |
| WRITE_EXTERNAL_STORAGE | Saving data | Use app-specific storage |
| VIBRATE | Haptic feedback | Optional, non-critical |
| ACCESS_NETWORK_STATE | Network detection | Check before network operations |

### Google Play Games Services

| Feature | Implementation | Benefit |
|---------|---------------|---------|
| Achievements | Unity Social API or GPGS plugin | Player engagement |
| Leaderboards | Unity Social API or GPGS plugin | Competition |
| Cloud saves | Saved Games API | Cross-device sync |
| Events/Quests | Play Console events | Live ops |
| Player stats | Player Stats API | Analytics |

### Android Release Tracks

| Track | Audience | Purpose |
|-------|----------|---------|
| **Internal** | Up to 100 testers | QA testing, automation |
| **Closed** | Managed list | Soft launch, focused testing |
| **Open** | Anyone with link | Broader testing, soft launch |
| **Production** | All users | Worldwide launch |
