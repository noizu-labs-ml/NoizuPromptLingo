# Mac App Store Submission

## Overview

Mac App Store submission flow:
1. Configure signing & provisioning in Xcode
2. Archive the app (Product → Archive)
3. Validate and upload via Organizer or `altool`/`notarytool`
4. Submit for review in App Store Connect
5. TestFlight for Mac (optional pre-release)

---

## App Store Connect Setup

1. Create app record at appstoreconnect.apple.com
2. Set Bundle ID — must match Xcode target exactly
3. Fill metadata: name, subtitle, description, keywords, support URL, privacy policy URL
4. Upload screenshots (see sizes below)
5. Set pricing, availability, age rating
6. Add App Privacy nutrition labels (declare data types collected)

---

## Provisioning Profiles

### Certificate Types

| Use | Certificate |
|---|---|
| Development | Apple Development |
| App Store distribution | Apple Distribution |
| Direct distribution | Developer ID Application |

### Profile Types

- **Mac App Store** — `Mac App Distribution` profile + `Mac Installer Distribution` (for the .pkg wrapper)
- **Development** — `Mac App Development` profile for running on registered devices

In Xcode: Signing & Capabilities → select team → enable "Automatically manage signing" for development. For App Store builds, Xcode generates profiles automatically with a valid team.

Manual profile management required when: using CI/CD (Fastlane match, Xcode Cloud), multiple teams, or enterprise distribution.

---

## Archiving and Uploading

### Via Xcode Organizer

```
Product → Archive
Window → Organizer → select archive → Validate App → Distribute App
→ App Store Connect → Upload
```

Validation catches common issues before upload: missing entitlements, bitcode settings, info.plist keys.

### Via Command Line

```bash
# Archive
xcodebuild archive \
  -scheme MyApp \
  -configuration Release \
  -archivePath ./build/MyApp.xcarchive

# Export for App Store
xcodebuild -exportArchive \
  -archivePath ./build/MyApp.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath ./build/export

# Upload with notarytool (replaces altool)
xcrun notarytool submit ./build/export/MyApp.pkg \
  --apple-id "you@example.com" \
  --team-id TEAMID \
  --password "@keychain:AC_PASSWORD" \
  --wait
```

ExportOptions.plist for App Store:
```xml
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOURTEAMID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
```

---

## TestFlight for Mac

- Upload build to App Store Connect (same flow as submission)
- Add internal testers (up to 100, no review needed) or external testers (up to 10,000, requires review)
- TestFlight app on macOS 12+ — testers install via TestFlight.app
- Builds expire after 90 days
- Use for beta feedback before App Review

---

## Review Guidelines (Mac-Specific)

Key rules that commonly cause Mac rejections:

| Rule | Detail |
|---|---|
| Sandbox required | App must use App Sandbox entitlement |
| No private API | No `@_spi`, no undocumented frameworks, no dyld injection |
| Accurate metadata | Screenshots must match current app UI |
| Complete functionality | No placeholder features or "coming soon" content |
| No auto-launching at login without consent | Use `SMAppService.mainApp.register()` with user opt-in UI |
| Privacy manifest | Required for apps using certain APIs (UserDefaults, file timestamps, etc.) |
| In-app purchase | Digital goods/subscriptions must use StoreKit; no links to external payment |

Privacy manifest (`PrivacyInfo.xcprivacy`) — required since May 2024 for apps using:
- `UserDefaults`
- File creation timestamps
- `NSFileManager` dates
- `SystemConfiguration` APIs

---

## Screenshot Sizes

| Display | Size |
|---|---|
| MacBook 13" (required) | 1280 × 800 |
| MacBook 15" (required) | 1440 × 900 |
| MacBook 16" (optional) | 1920 × 1200 |
| iMac 24" / Pro Display (optional) | 2560 × 1600 |

PNG or JPEG. No alpha. App must fill frame — no letterboxing. Up to 10 screenshots per size. Preview videos: up to 3, .mov, 15–30 seconds.

---

## StoreKit 2

StoreKit 2 is the modern Swift API (iOS 15+, macOS 12+).

```swift
import StoreKit

// Fetch products
let products = try await Product.products(for: ["com.example.premium"])

// Purchase
let result = try await products.first?.purchase()
switch result {
case .success(let verification):
    let transaction = try verification.payloadValue
    await transaction.finish()
case .userCancelled, .pending:
    break
default:
    break
}

// Check entitlements on launch
for await result in Transaction.currentEntitlements {
    if case .verified(let transaction) = result {
        // unlock feature
    }
}
```

Key StoreKit 2 types: `Product`, `Transaction`, `SubscriptionInfo`, `ProductSubscriptionInfo.RenewalState`.

Testing: StoreKit configuration file in Xcode scheme → StoreKit Testing → auto-generates sandbox transactions without an Apple ID. Use `SKTestSession` in unit tests.

---

## Submission Checklist

- [ ] Bundle ID matches App Store Connect record
- [ ] Version and build number incremented
- [ ] All required entitlements present, no extras
- [ ] Privacy manifest (`PrivacyInfo.xcprivacy`) added if needed
- [ ] Screenshots for 1280×800 and 1440×900 uploaded
- [ ] App Privacy nutrition labels filled in App Store Connect
- [ ] No `get-task-allow` entitlement in release build
- [ ] TestFlight beta tested before submission
- [ ] Support URL and privacy policy URL set
- [ ] Age rating questionnaire completed
