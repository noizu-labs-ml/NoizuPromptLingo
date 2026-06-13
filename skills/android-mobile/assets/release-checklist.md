# Android Release Checklist

Complete before every Play Store release. Check each item and note status.

## Build

- [ ] Version code incremented (must be higher than any previously uploaded)
- [ ] Version name updated (semver: major.minor.patch)
- [ ] Release build completes without errors: `./gradlew bundleRelease`
- [ ] ProGuard/R8 rules verified (no runtime crashes in release build)
- [ ] APK size is reasonable (check with APK Analyzer)
- [ ] No debug-only code in release (logging, test endpoints, debug flags)

## Testing

- [ ] All unit tests pass: `./gradlew testReleaseUnitTest`
- [ ] Screenshot tests pass: `./gradlew verifyRoborazziRelease`
- [ ] Manual smoke test on release build (2 device sizes minimum)
- [ ] Internal testing track deployed and verified
- [ ] Closed testing track deployed (if applicable)
- [ ] Crash rate in testing < 1% (check Crashlytics)
- [ ] No critical ANRs (check Play Console vitals)

## Store Listing

- [ ] App title (30 chars max, includes primary keyword)
- [ ] Short description (80 chars max, compelling value prop)
- [ ] Full description (4000 chars max, feature-rich, keyword-optimized)
- [ ] Phone screenshots (5-8, first 2 show core value)
- [ ] Tablet screenshots (if adaptive layout is supported)
- [ ] Feature graphic (1024x500, readable at thumbnail size)
- [ ] App icon meets guidelines (adaptive icon, no text at small sizes)
- [ ] Release notes written (user-facing language, not developer jargon)

## Compliance

- [ ] Privacy policy URL set and accessible
- [ ] Data safety form completed and accurate
- [ ] Content rating questionnaire submitted
- [ ] Target API level meets Play Store requirements (currently API 34+)
- [ ] Ads declaration accurate (if applicable)
- [ ] In-app purchases configured correctly (if applicable)

## Security

- [ ] Release keystore stored securely (not in repository)
- [ ] No API keys hardcoded in source (use BuildConfig or local.properties)
- [ ] Network security config appropriate for production
- [ ] Certificate pinning configured (if handling sensitive data)
- [ ] No exported components without intent filters (AndroidManifest audit)

## Monitoring

- [ ] Firebase Crashlytics integrated and mapping file uploaded
- [ ] Play Console alerts configured (crash rate, ANR rate)
- [ ] Analytics events tracking core flows (if applicable)

## Rollout Plan

- [ ] Rollout percentage decided (recommended: 5% initial)
- [ ] Halt criteria defined (e.g., crash rate > 2%)
- [ ] Rollback plan documented (what to do if critical bug found)
- [ ] Team notified of release timing

## Post-Release

- [ ] Monitor crash rate for 24 hours after each rollout expansion
- [ ] Check user reviews for new issues
- [ ] Expand rollout per plan (5% → 20% → 50% → 100%)
- [ ] Update internal documentation with release notes
