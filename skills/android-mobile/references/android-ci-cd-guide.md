# Android CI/CD Guide

GitHub Actions configuration for building, testing, and deploying Android apps.

## Pipeline Architecture

```
PR opened/updated ──→ Build + Lint + Unit Tests + Screenshot Tests
                      (parallel jobs, ~5-8 min)

Merge to main ──────→ Build Release AAB
                    → Sign with upload key
                    → Upload to internal testing track
                    → Notify team (Slack/Discord)

Tag (v*) ──────────→ Build Release AAB
                    → Upload to production track (staged rollout)
                    → Create GitHub Release with AAB artifact
```

## GitHub Actions Workflow

```yaml
# .github/workflows/android-ci.yml
name: Android CI

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 21

      - uses: gradle/actions/setup-gradle@v4
        with:
          cache-read-only: ${{ github.ref != 'refs/heads/main' }}

      - name: Run lint
        run: ./gradlew lintDebug

      - name: Run unit tests
        run: ./gradlew testDebugUnitTest

      - name: Verify screenshot tests
        run: ./gradlew verifyRoborazziDebug

      - name: Upload test results
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: '**/build/reports/tests/'

  deploy-internal:
    needs: build-and-test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 21

      - uses: gradle/actions/setup-gradle@v4

      - name: Decode keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > upload-keystore.jks

      - name: Build release AAB
        env:
          KEYSTORE_PATH: upload-keystore.jks
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
        run: ./gradlew bundleRelease

      - name: Upload to Play Store (internal)
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT_JSON }}
          packageName: com.example.app
          releaseFiles: app/build/outputs/bundle/release/app-release.aab
          track: internal

  deploy-production:
    needs: build-and-test
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 21

      - uses: gradle/actions/setup-gradle@v4

      - name: Decode keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > upload-keystore.jks

      - name: Build release AAB
        env:
          KEYSTORE_PATH: upload-keystore.jks
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
        run: ./gradlew bundleRelease

      - name: Upload to Play Store (production, staged)
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT_JSON }}
          packageName: com.example.app
          releaseFiles: app/build/outputs/bundle/release/app-release.aab
          track: production
          userFraction: 0.05
          status: inProgress

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: app/build/outputs/bundle/release/app-release.aab
          generate_release_notes: true
```

## Secrets Configuration

Store these in GitHub repository secrets:

| Secret | Value | How to Generate |
|--------|-------|-----------------|
| `KEYSTORE_BASE64` | Base64-encoded upload keystore | `base64 -i upload-keystore.jks` |
| `KEYSTORE_PASSWORD` | Keystore password | Set during keytool generation |
| `KEY_ALIAS` | Key alias | Set during keytool generation |
| `KEY_PASSWORD` | Key password | Set during keytool generation |
| `PLAY_SERVICE_ACCOUNT_JSON` | Google Play API service account | Play Console → API access → Service accounts |

### Setting Up Play Store API Access

1. Go to Play Console → Setup → API access
2. Link to Google Cloud project (or create one)
3. Create a service account with "Release manager" permissions
4. Download JSON key → store as `PLAY_SERVICE_ACCOUNT_JSON` secret

## Gradle Optimization for CI

```properties
# gradle.properties
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configuration-cache=true
org.gradle.daemon=false
org.gradle.jvmargs=-Xmx4g -XX:+HeapDumpOnOutOfMemoryError
```

### Build Cache

Gradle's remote build cache speeds up CI builds by reusing outputs from previous builds:

```kotlin
// settings.gradle.kts
buildCache {
    local { isEnabled = true }
    remote<HttpBuildCache> {
        url = uri(System.getenv("GRADLE_CACHE_URL") ?: "")
        isPush = System.getenv("CI") == "true"
    }
}
```

## Emulator Tests in CI

For connected/instrumentation tests, use the `reactivecircus/android-emulator-runner` action:

```yaml
instrumentation-tests:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-java@v4
      with:
        distribution: temurin
        java-version: 21

    - name: Enable KVM
      run: |
        echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules
        sudo udevadm control --reload-rules
        sudo udevadm trigger --name-match=kvm

    - uses: reactivecircus/android-emulator-runner@v2
      with:
        api-level: 34
        arch: x86_64
        script: ./gradlew connectedDebugAndroidTest
```

**Tip:** Emulator tests are slow (~10-15 min setup). Run them on merge to main, not on every PR. Use Roborazzi/Robolectric for PR-level UI testing instead.
