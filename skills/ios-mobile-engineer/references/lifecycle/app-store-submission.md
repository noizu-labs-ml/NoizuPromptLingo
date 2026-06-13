# App Store Submission

End-to-end guide from Apple Developer enrollment through release management.
Follow these steps sequentially for a first submission; experienced developers
can skip to the section they need.

---

## Apple Developer Program

### Enrollment

1. Create an Apple ID at [appleid.apple.com](https://appleid.apple.com) if you lack one
2. Enroll at [developer.apple.com/programs](https://developer.apple.com/programs/)
3. Cost: $99 USD/year for individuals and organizations
4. Organization accounts require a D-U-N-S number (free, takes 5-14 business days)
5. Enrollment approval takes 24-48 hours typically

### Account Types

| Type | Use Case | Key Difference |
|------|----------|----------------|
| Individual | Solo developer | Your legal name on the App Store |
| Organization | Company/team | Company name on store, team management |

Organization accounts unlock team roles: Admin, App Manager, Developer,
Marketing, Finance. Use these to separate concerns on teams.

---

## Certificates and Provisioning Profiles

### Certificate Types

- **Development** — run on physical devices during development
- **Distribution** — required for App Store and TestFlight builds

### Creating Certificates (Manual)

1. Keychain Access > Certificate Assistant > Request a Certificate from a CA
2. Save the `.certSigningRequest` file
3. Developer portal > Certificates > add new > select type > upload CSR
4. Download and double-click the `.cer` to install in Keychain

### Automatic Signing (Recommended)

In Xcode: Signing & Capabilities > check "Automatically manage signing."
Xcode creates and manages certificates and profiles. This is sufficient for
most solo developers and small teams.

### Provisioning Profiles

A provisioning profile bundles: your certificate, app ID, and allowed devices
(for development) or distribution method. Xcode generates these automatically
with managed signing enabled.

For CI/CD, see `ci-cd-pipeline.md` — code signing in CI requires either
Fastlane Match or manual profile management.

---

## App Store Connect Setup

### Register a Bundle ID

1. Developer portal > Identifiers > App IDs > Register
2. Format: reverse domain (e.g., `com.yourdomain.appname`)
3. Enable capabilities your app uses (Push Notifications, Sign in with Apple, etc.)

### Create the App Record

1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) > My Apps > "+"
2. Fill in: name, primary language, bundle ID, SKU
3. SKU is an internal identifier (never public) — use something like `appname-ios-v1`

### App Information

Complete these sections before first submission:

- **General** — category, subcategory, content rights, age rating
- **Pricing** — free or paid, pricing tier, availability by country
- **App Privacy** — privacy nutrition labels (data collection disclosures)

The privacy section requires a privacy policy URL. Host one before submitting.

---

## Build Upload

### From Xcode

1. Set the active scheme to "Any iOS Device (arm64)"
2. Product > Archive
3. Window > Organizer > select archive > Distribute App
4. Choose "App Store Connect" > Upload
5. Accept defaults for bitcode, symbol upload, signing
6. Build appears in App Store Connect within 15-30 minutes

### From Command Line

```bash
# Archive
xcodebuild archive \
  -project MyApp.xcodeproj \
  -scheme MyApp \
  -archivePath build/MyApp.xcarchive \
  -destination "generic/platform=iOS"

# Export
xcodebuild -exportArchive \
  -archivePath build/MyApp.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist

# Upload
xcrun altool --upload-app \
  -f build/export/MyApp.ipa \
  -t ios \
  -u "your@apple.id" \
  -p "@keychain:AC_PASSWORD"
```

Or use `xcrun notarytool` for newer workflows. Fastlane's `deliver` is
simpler for CI — see `ci-cd-pipeline.md`.

---

## TestFlight

### Internal Testing

- Up to 100 testers (must be App Store Connect users)
- Builds available immediately after processing
- No review required
- Use for team and stakeholder testing

### External Testing

- Up to 10,000 testers via email or public link
- First build of each version requires Beta App Review (usually 24-48 hours)
- Subsequent builds of the same version skip review
- Public link: generate at App Store Connect > TestFlight > External Testing

### Managing Testers

```
App Store Connect > TestFlight > Internal/External Group > Add Testers
```

Add testers by email. They receive an invite and install via the TestFlight app.
Use groups to segment (e.g., "QA Team," "Beta Users," "Stakeholders").

### Build Expiration

TestFlight builds expire after 90 days. Plan release cycles accordingly.

---

## App Review Guidelines — Common Rejection Reasons

### Top Rejection Categories

1. **Bugs and crashes** — test on real devices, not just simulator
2. **Broken links** — every URL in the app and metadata must resolve
3. **Incomplete information** — missing privacy policy, placeholder text
4. **Insufficient content** — app too thin or template-like
5. **Guideline 4.3: Spam** — too similar to existing apps (including your own)
6. **Guideline 5.1.1: Data collection** — collecting data without clear purpose
7. **Guideline 2.1: Performance** — app doesn't work as advertised
8. **In-App Purchase required** — digital goods must use IAP, not Stripe/PayPal
9. **Login requirement** — if login required, provide a demo account for review
10. **Minimum functionality** — web wrappers and single-feature apps get rejected

### Review Tips

- Provide a demo account in the App Review notes field
- Include detailed "what to test" instructions for reviewers
- Respond to rejections in Resolution Center (not email)
- First review: 24-48 hours. Subsequent: often faster. Expedited review available for critical fixes.
- If rejected, fix the issue and resubmit — do not argue unless genuinely incorrect

---

## Metadata

### App Name and Subtitle

- Name: 30 characters max. Include a primary keyword if natural.
- Subtitle: 30 characters max. Describe value proposition.

### Description

- 4,000 character limit
- First 2-3 lines visible before "more" — make them count
- Structure: value prop, key features (bulleted), social proof
- No keyword stuffing — Apple penalizes it

### Keywords

- 100 characters total, comma-separated, no spaces after commas
- Do not repeat words from name/subtitle (already indexed)
- Use singular forms (Apple indexes both singular and plural)
- Research with App Store search suggestions and competitor analysis

### Screenshots

| Device | Required | Sizes |
|--------|----------|-------|
| iPhone 6.9" | Yes (if supporting iPhone) | 1320 x 2868 |
| iPhone 6.7" | Yes | 1290 x 2796 |
| iPad 13" | Yes (if supporting iPad) | 2064 x 2752 |

- Up to 10 screenshots per localization
- First 3 screenshots appear in search results — prioritize them
- Include captions on screenshots explaining the feature shown
- Use real app content, not mockups with placeholder data

### App Preview Videos

- Up to 3 videos per localization, 15-30 seconds each
- Show real app usage, not cinematic trailers
- First frame becomes the poster — make it compelling
- No hands or device chrome required (but Apple recommends it)

---

## Release Management

### Release Types

| Type | Behavior |
|------|----------|
| Manual | You press "Release" after approval |
| Automatic | Releases immediately after approval |
| Phased rollout | 1%, 2%, 5%, 10%, 20%, 50%, 100% over 7 days |

### Phased Rollout

- Available only for updates, not first release
- Existing users can still get the update via manual App Store check
- Pause or halt the rollout if crash rates spike
- Monitor crash reports in Xcode Organizer and App Store Connect Analytics

### Version Strategy

- Use semantic versioning: `MAJOR.MINOR.PATCH`
- Build number must increment with every upload (use integer or date-based)
- App Store shows version to users; build number is internal only

### Post-Release

- Monitor crash reports in Xcode Organizer within 24 hours
- Check App Analytics for adoption rate
- Respond to initial reviews promptly
- Have a hotfix branch ready — expedited review takes 24 hours if needed

---

## Submission Checklist

```
[ ] Bundle ID registered with correct capabilities
[ ] App record created in App Store Connect
[ ] Privacy policy URL live and linked
[ ] App privacy labels completed accurately
[ ] Age rating questionnaire filled out
[ ] Screenshots uploaded for all required device sizes
[ ] Description, keywords, subtitle filled in
[ ] Demo account provided in review notes (if login required)
[ ] Build uploaded and processed without errors
[ ] Internal TestFlight tested on real devices
[ ] External TestFlight feedback addressed
[ ] No placeholder text, broken links, or test data in the app
[ ] Release type selected (manual / automatic / phased)
[ ] Submit for review
```
