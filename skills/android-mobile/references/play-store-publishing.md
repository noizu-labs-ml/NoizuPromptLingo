# Play Store Publishing Guide

End-to-end guide for publishing Android apps to the Google Play Store, including ASO, staged rollouts, and ongoing release management.

## Play Console Setup

### First-Time Setup

1. **Developer account** — $25 one-time registration fee at [play.google.com/console](https://play.google.com/console)
2. **Create app** — Choose app name, default language, app/game classification, free/paid
3. **Complete declarations** — Privacy policy, data safety, content rating, target audience
4. **Set up internal testing track** — Enables deployment before store listing is complete

### Tracks and Rollout Strategy

| Track | Purpose | Audience | Typical Duration |
|-------|---------|----------|-----------------|
| Internal testing | Team verification | Up to 100 testers by email | 1-2 days |
| Closed testing | Beta program | Invite-only, up to groups of testers | 1-2 weeks |
| Open testing | Public beta | Anyone can join via Play Store link | Optional, 1 week |
| Production | Live release | All users | Staged rollout |

### Staged Production Rollout

| Stage | Percentage | Duration | Gate |
|-------|-----------|----------|------|
| 1 | 5% | 24 hours | Crash rate < 1%, no critical ANRs |
| 2 | 20% | 48 hours | No increase in negative reviews |
| 3 | 50% | 48 hours | Metrics stable |
| 4 | 100% | — | Full release |

**Halt criteria:** If crash rate exceeds 2% or ANR rate exceeds 0.5% at any stage, halt the rollout and investigate.

## App Signing

### Play App Signing (Recommended)

Google manages your app signing key. You sign uploads with an upload key.

1. Generate upload keystore: `keytool -genkey -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000`
2. Store upload keystore securely (password manager, CI secrets — never in repo)
3. Configure in `build.gradle.kts`:

```kotlin
android {
    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("KEYSTORE_PATH") ?: "upload-keystore.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: ""
            keyAlias = System.getenv("KEY_ALIAS") ?: "upload"
            keyPassword = System.getenv("KEY_PASSWORD") ?: ""
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

### Build AAB for Upload

```bash
./gradlew bundleRelease
# Output: app/build/outputs/bundle/release/app-release.aab
```

Always upload AAB (Android App Bundle), not APK. Google generates optimized APKs per device configuration.

## App Store Optimization (ASO)

### Metadata Strategy

| Element | Max Length | Strategy |
|---------|-----------|----------|
| App name | 30 chars | `[Primary Keyword] - [Brand]` or `[Brand]: [Value Prop]` |
| Short description | 80 chars | Compelling one-liner with top secondary keyword |
| Full description | 4000 chars | Structured: hook → features → social proof → CTA |

### Full Description Template

```
[Hook — one compelling sentence about the value]

KEY FEATURES:
* [Feature 1 — user benefit, not technical detail]
* [Feature 2]
* [Feature 3]
* [Feature 4]
* [Feature 5]

[Expanded description of primary use case — 2-3 sentences]

[Secondary use case — 1-2 sentences]

WHY [APP NAME]?
* [Differentiator 1]
* [Differentiator 2]
* [Differentiator 3]

[Social proof if available — download count, rating, press mention]

Download [App Name] today and [primary benefit].
```

### Keyword Strategy

1. **Research** — Use AppFollow, Sensor Tower, or App Radar to find relevant keywords
2. **Primary keyword** — Include in app name (highest weight)
3. **Secondary keywords** — Include in short description
4. **Long-tail keywords** — Weave naturally into full description
5. **Localization** — Translate metadata for target markets (don't just machine-translate)

### Screenshots

| Rule | Details |
|------|---------|
| **First 2 are critical** | Most users decide from the first two screenshots in search results |
| **Show core value** | Lead with the primary feature, not a splash screen |
| **Add captions** | Short text overlay explaining what the screenshot shows |
| **Phone + tablet** | Upload both if you support adaptive layouts |
| **Feature graphic** | 1024x500, used in Play Store feature spots and social shares |

### Screenshot Checklist

1. 5-8 screenshots per device type
2. Consistent visual style across all screenshots
3. Captions in the target market's language
4. Show real (or realistic) data, not "Lorem ipsum"
5. Include dark mode screenshots if supported

## Data Safety Form

Google requires disclosure of data collection and sharing. Common declarations:

| Data Type | Collected? | Shared? | Purpose |
|-----------|-----------|---------|---------|
| Email address | If auth | No | Account management |
| Crash logs | Yes (Crashlytics) | With Google | App stability |
| Analytics events | Yes (if using analytics) | With analytics provider | Product improvement |
| Device identifiers | If push notifications | With messaging provider | Notification delivery |

**Tip:** Fill this out honestly. Google audits randomly, and misrepresentation can get your app suspended.

## Privacy Policy

Required for all apps. Must cover:
- What data is collected
- How data is used
- How data is shared (third parties)
- How data is stored and secured
- How users can request deletion
- Contact information

Host on your domain (e.g., `https://example.com/privacy`) and link from Play Console and within the app's settings screen.

## Content Rating

Complete the IARC questionnaire in Play Console. Questions cover:
- Violence (cartoon vs. realistic)
- Sexual content
- Substance use
- User-generated content
- In-app purchases

Answer honestly — incorrect ratings lead to app removal.

## Release Management

### Versioning

```kotlin
android {
    defaultConfig {
        versionCode = 14           // Monotonically increasing integer
        versionName = "1.3.0"     // Human-readable (semver recommended)
    }
}
```

**Version code** must increase with every upload. Automate with CI:
```kotlin
versionCode = System.getenv("GITHUB_RUN_NUMBER")?.toInt() ?: 1
```

### Release Notes

Write for users, not developers:

```
What's new in 1.3.0:
- Added dark mode support — easier on your eyes at night
- Improved offline mode — your data is always available
- Fixed: app no longer crashes when rotating during search
- Performance improvements for smoother scrolling
```

### Crash Monitoring

1. **Firebase Crashlytics** — Automatic crash reporting, priority setting, velocity alerts
2. **Play Console vitals** — ANR rate, crash rate, startup time, permission denials
3. **Set alerts** — Configure crash rate thresholds in Play Console to get notified

### When to Release

- **Regular cadence** — Every 2-4 weeks for active development
- **Hotfixes** — Same day for crashes affecting > 1% of users
- **Feature releases** — When feature is validated through testing tracks
- **Avoid** — Fridays, holidays, major Android OS release days (existing users update, may surface bugs)

## Monetization on Play Store

### In-App Purchases (Google Play Billing)

| Type | When | Implementation |
|------|------|----------------|
| One-time | Permanent unlock (remove ads, premium features) | `BillingClient` + `queryProductDetails` |
| Subscription | Recurring access (monthly/yearly) | Same, with subscription lifecycle management |
| Consumable | Credits, tokens, virtual currency | `consumeAsync` after delivery |

### Freemium Pattern

1. Core experience is free and genuinely useful
2. Premium features are clearly valuable upgrades (not artificial gates)
3. Trial period for subscriptions (3-7 days, set in Play Console)
4. Restore purchases across devices via Google account

### Ad Integration

- **AdMob** — Google's ad network, easy Play Console integration
- **Banner ads** — Low revenue, high fill rate, minimal UX impact
- **Interstitial** — Higher revenue, use sparingly (natural break points only)
- **Rewarded** — Best UX: user opts in for a reward (extra lives, premium content preview)
