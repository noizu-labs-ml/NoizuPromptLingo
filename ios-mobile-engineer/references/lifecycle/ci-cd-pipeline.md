# CI/CD Pipeline for iOS

Automating build, test, and distribution for iOS apps. Covers Apple's native
Xcode Cloud, GitHub Actions with xcodebuild, and Fastlane for end-to-end
automation.

---

## Xcode Cloud

Apple's built-in CI/CD, integrated into Xcode and App Store Connect.

### Setup

1. Xcode > Product > Xcode Cloud > Create Workflow
2. Select your app target
3. Configure start conditions (branch push, PR, tag, schedule)
4. Add actions: build, test, analyze, archive
5. Add post-actions: TestFlight distribution, notifications

### Workflow Configuration

Workflows are configured in the Xcode Cloud dashboard or Xcode IDE.
No YAML files — everything is UI-driven.

**Start conditions:**
- Branch changes (push to `main`, `release/*`)
- Pull request (open, update)
- Tag creation (`v*`)
- Scheduled (daily, weekly)

**Environment:**
- macOS and Xcode versions are selectable per workflow
- Environment variables set in Xcode Cloud dashboard
- Secrets stored as environment variables (marked sensitive)

### Custom Scripts

Place scripts in `ci_scripts/` at your project root:

```
ci_scripts/
├── ci_post_clone.sh      # After repo clone (install tools, resolve deps)
├── ci_pre_xcodebuild.sh  # Before build (generate files, set env)
└── ci_post_xcodebuild.sh # After build (upload artifacts, notify)
```

```bash
#!/bin/bash
# ci_scripts/ci_post_clone.sh
# Install dependencies after clone
brew install swiftlint
```

### Limitations

- macOS runners only (no Linux)
- 25 compute hours/month on free tier
- Limited customization compared to GitHub Actions
- No self-hosted runners

### Best For

Teams that want zero-config CI with native Xcode integration and automatic
TestFlight distribution.

---

## GitHub Actions with xcodebuild

Full control over the CI environment. Requires macOS runners.

### Basic Workflow

```yaml
# .github/workflows/ios.yml
name: iOS CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.2.app

      - name: Resolve packages
        run: xcodebuild -resolvePackageDependencies \
          -project MyApp.xcodeproj \
          -scheme MyApp

      - name: Run tests
        run: xcodebuild test \
          -project MyApp.xcodeproj \
          -scheme MyApp \
          -destination "platform=iOS Simulator,name=iPhone 16,OS=18.2" \
          -enableCodeCoverage YES \
          -resultBundlePath TestResults.xcresult

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: TestResults.xcresult
```

### Build and Archive

```yaml
  archive:
    runs-on: macos-15
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.2.app

      - name: Install certificate and profile
        env:
          CERTIFICATE_P12: ${{ secrets.CERTIFICATE_P12 }}
          CERTIFICATE_PASSWORD: ${{ secrets.CERTIFICATE_PASSWORD }}
          PROVISIONING_PROFILE: ${{ secrets.PROVISIONING_PROFILE }}
        run: |
          # Create temporary keychain
          KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db
          KEYCHAIN_PASSWORD=$(openssl rand -base64 32)
          security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
          security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
          security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH

          # Import certificate
          echo "$CERTIFICATE_P12" | base64 --decode > $RUNNER_TEMP/cert.p12
          security import $RUNNER_TEMP/cert.p12 -P "$CERTIFICATE_PASSWORD" \
            -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
          security set-key-partition-list -S apple-tool:,apple: \
            -k "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
          security list-keychains -d user -s $KEYCHAIN_PATH

          # Install provisioning profile
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          echo "$PROVISIONING_PROFILE" | base64 --decode \
            > ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision

      - name: Archive
        run: xcodebuild archive \
          -project MyApp.xcodeproj \
          -scheme MyApp \
          -archivePath build/MyApp.xcarchive \
          -destination "generic/platform=iOS"

      - name: Export IPA
        run: xcodebuild -exportArchive \
          -archivePath build/MyApp.xcarchive \
          -exportPath build/export \
          -exportOptionsPlist ExportOptions.plist

      - name: Upload to TestFlight
        run: xcrun altool --upload-app \
          -f build/export/MyApp.ipa -t ios \
          --apiKey ${{ secrets.APP_STORE_KEY_ID }} \
          --apiIssuer ${{ secrets.APP_STORE_ISSUER_ID }}
```

---

## Code Signing in CI (The Hard Part)

Code signing is the single biggest source of CI failures for iOS.

### The Problem

iOS builds require:
1. A distribution certificate (private key + Apple-signed cert)
2. A provisioning profile matching the cert, bundle ID, and entitlements
3. Both must be in the build machine's keychain/profile directory

CI machines are ephemeral — you must install these on every run.

### Approaches

| Method | Complexity | Team-Friendly | Recommended |
|--------|-----------|---------------|-------------|
| Manual secrets | Medium | No — one person's cert | Solo projects |
| Fastlane Match | Low | Yes — shared via git/S3 | Teams |
| Xcode Cloud | None | Yes — Apple-managed | Apple-only CI |

### Fastlane Match (Recommended for Teams)

Match stores encrypted certificates and profiles in a git repo or cloud storage.
Every CI run and team member pulls from the same source.

```ruby
# Matchfile
git_url("https://github.com/your-org/certificates")
storage_mode("git")
type("appstore")
app_identifier("com.yourcompany.app")
```

```bash
# CI setup
fastlane match appstore --readonly
```

The `--readonly` flag prevents CI from creating new profiles. Only generate
new certs locally when needed.

---

## Fastlane

Ruby-based automation toolkit. The standard for iOS CI/CD beyond Xcode Cloud.

### Core Tools

| Tool | Purpose |
|------|---------|
| `match` | Sync certificates and profiles across team/CI |
| `gym` | Build and archive (wraps xcodebuild) |
| `scan` | Run tests (wraps xcodebuild test) |
| `deliver` | Upload builds and metadata to App Store Connect |
| `pilot` | Manage TestFlight builds and testers |
| `snapshot` | Generate localized screenshots automatically |

### Fastfile Example

```ruby
# fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    scan(
      scheme: "MyApp",
      device: "iPhone 16",
      code_coverage: true,
      result_bundle: true
    )
  end

  desc "Build and upload to TestFlight"
  lane :beta do
    match(type: "appstore", readonly: true)
    increment_build_number(
      build_number: ENV["GITHUB_RUN_NUMBER"] || latest_testflight_build_number + 1
    )
    gym(
      scheme: "MyApp",
      export_method: "app-store"
    )
    pilot(
      skip_waiting_for_build_processing: true,
      distribute_external: false
    )
  end

  desc "Upload to App Store"
  lane :release do
    match(type: "appstore", readonly: true)
    gym(scheme: "MyApp", export_method: "app-store")
    deliver(
      submit_for_review: false,
      automatic_release: false,
      force: true
    )
  end
end
```

### GitHub Actions with Fastlane

```yaml
  beta:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true
      - run: bundle exec fastlane beta
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_BASIC_AUTHORIZATION: ${{ secrets.MATCH_GIT_TOKEN }}
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.ASC_KEY_ID }}
          APP_STORE_CONNECT_API_KEY_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_KEY: ${{ secrets.ASC_PRIVATE_KEY }}
```

---

## Version Bumping Strategies

### Build Number: CI Run Number

Simplest approach. Every CI run gets a unique, monotonically increasing number.

```ruby
increment_build_number(build_number: ENV["GITHUB_RUN_NUMBER"])
```

### Build Number: TestFlight Latest + 1

Queries TestFlight for the highest build number and increments.

```ruby
increment_build_number(
  build_number: latest_testflight_build_number + 1
)
```

### Version Number: Git Tags

Derive the marketing version from git tags.

```bash
# Tag format: v1.2.3
VERSION=$(git describe --tags --abbrev=0 | sed 's/^v//')
```

```ruby
increment_version_number(version_number: version_from_git_tag)
```

### Recommended Strategy

- **Marketing version** (`CFBundleShortVersionString`): set manually or from git tags
- **Build number** (`CFBundleVersion`): automated via CI run number
- Never manually set build numbers — let CI own them

---

## Pipeline Architecture

```
Push to main
    |
    v
[Run Tests] ----fail----> Notify + Block
    |
  pass
    |
    v
[Archive + Sign] ----fail----> Notify
    |
  success
    |
    v
[Upload to TestFlight]
    |
    v
[Notify Team]
    |
    v
(manual) [Submit to App Store]
```

Keep App Store submission as a manual trigger. Automated TestFlight is
the sweet spot — fast feedback without accidental production releases.
