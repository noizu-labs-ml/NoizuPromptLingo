# Direct Distribution: Developer ID, Notarization & Updates

## Overview

Direct distribution bypasses the Mac App Store. Requirements:
1. Sign with **Developer ID Application** certificate
2. Enable **Hardened Runtime**
3. **Notarize** with Apple (automated scan, returns staple ticket)
4. **Staple** the ticket to the binary/DMG/pkg
5. Distribute DMG, pkg, or zip

---

## Developer ID Signing

In Xcode, set the signing identity for Release to "Developer ID Application: Your Name (TEAMID)".

For CI or command-line builds:

```bash
# List available identities
security find-identity -v -p codesigning

# Sign manually (usually Xcode does this)
codesign --force --options runtime \
  --sign "Developer ID Application: Your Name (TEAMID)" \
  MyApp.app

# Verify
codesign --verify --verbose=4 MyApp.app
spctl --assess --type execute --verbose MyApp.app
```

`--options runtime` enables Hardened Runtime — **required for notarization**.

For apps loading plugins or JIT:
```bash
codesign --force --options runtime \
  --entitlements MyApp.entitlements \
  --sign "Developer ID Application: ..." \
  MyApp.app
```

---

## Notarization (notarytool)

`altool` was deprecated in 2023. Use `xcrun notarytool`.

### Store Credentials in Keychain (one-time)

```bash
xcrun notarytool store-credentials "AC_PASSWORD" \
  --apple-id "you@example.com" \
  --team-id YOURTEAMID \
  --password "app-specific-password"
```

### Submit and Wait

```bash
# Submit a zip, DMG, or pkg
xcrun notarytool submit MyApp.dmg \
  --keychain-profile "AC_PASSWORD" \
  --wait

# Check status of a previous submission
xcrun notarytool info <submission-id> --keychain-profile "AC_PASSWORD"

# View detailed log (shows why it failed)
xcrun notarytool log <submission-id> --keychain-profile "AC_PASSWORD" notarization.log
```

Common failures: missing `--options runtime`, missing hardened runtime entitlements, unsigned nested frameworks/dylibs, private API usage.

### Staple the Ticket

After successful notarization, staple so Gatekeeper works offline:

```bash
xcrun stapler staple MyApp.dmg
xcrun stapler validate MyApp.dmg
```

Staple to the DMG (or pkg), not the inner .app — when the .app is extracted from DMG, it carries the staple.

---

## DMG Creation (create-dmg)

[create-dmg](https://github.com/create-dmg/create-dmg) is the standard tool:

```bash
brew install create-dmg

create-dmg \
  --volname "MyApp" \
  --volicon "assets/MyApp.icns" \
  --background "assets/dmg-background.png" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "MyApp.app" 200 190 \
  --hide-extension "MyApp.app" \
  --app-drop-link 600 190 \
  "MyApp-1.0.0.dmg" \
  "build/Release/MyApp.app"
```

Then sign and notarize the DMG:
```bash
codesign --sign "Developer ID Application: ..." MyApp-1.0.0.dmg
xcrun notarytool submit MyApp-1.0.0.dmg --keychain-profile "AC_PASSWORD" --wait
xcrun stapler staple MyApp-1.0.0.dmg
```

---

## pkg Installers

Use `pkgbuild` + `productbuild` for installer packages (useful for CLI tools or multi-component installs):

```bash
# Build component pkg
pkgbuild --root ./payload \
  --identifier com.example.myapp \
  --version 1.0.0 \
  --install-location /Applications \
  MyApp-component.pkg

# Wrap in product archive (with license, UI)
productbuild --distribution Distribution.xml \
  --package-path . \
  --sign "Developer ID Installer: Your Name (TEAMID)" \
  MyApp-1.0.0.pkg

# Notarize and staple
xcrun notarytool submit MyApp-1.0.0.pkg --keychain-profile "AC_PASSWORD" --wait
xcrun stapler staple MyApp-1.0.0.pkg
```

---

## Sparkle Auto-Updates

[Sparkle 2](https://sparkle-project.org) is the standard update framework for direct-distribution apps.

### Setup

Add via Swift Package Manager: `https://github.com/sparkle-project/Sparkle` (version 2.x).

Generate EdDSA keys (one-time):
```bash
./bin/generate_keys
# Outputs: private key (store securely, NOT in repo) + public key for Info.plist
```

Info.plist keys:
```xml
<key>SUPublicEDKey</key>
<string>YOUR_BASE64_PUBLIC_KEY</string>
<key>SUFeedURL</key>
<string>https://example.com/appcast.xml</string>
```

### Appcast XML

```xml
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>MyApp Changelog</title>
    <item>
      <title>Version 1.2.0</title>
      <sparkle:version>120</sparkle:version>          <!-- CFBundleVersion -->
      <sparkle:shortVersionString>1.2.0</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
      <pubDate>Mon, 12 May 2026 00:00:00 +0000</pubDate>
      <enclosure
        url="https://example.com/releases/MyApp-1.2.0.dmg"
        sparkle:edSignature="BASE64_SIGNATURE"
        length="12345678"
        type="application/octet-stream" />
    </item>
  </channel>
</rss>
```

Sign the DMG for appcast:
```bash
./bin/sign_update MyApp-1.2.0.dmg
# Outputs the sparkle:edSignature value
```

### Entitlements for Sparkle XPC

Sparkle 2 uses XPC for the installer helper. Add to entitlements:
```xml
<key>com.apple.security.cs.disable-library-validation</key>
<true/>
```

---

## Homebrew Cask

For CLI tools or apps with a developer audience:

```ruby
# Formula/Cask: my-app.rb
cask "my-app" do
  version "1.2.0"
  sha256 "CHECKSUM_OF_DMG"

  url "https://example.com/releases/MyApp-1.2.0.dmg"
  name "MyApp"
  desc "Short description of what it does"
  homepage "https://example.com"

  app "MyApp.app"

  zap trash: [
    "~/Library/Application Support/com.example.myapp",
    "~/Library/Preferences/com.example.myapp.plist",
  ]
end
```

Submit to [homebrew-cask](https://github.com/Homebrew/homebrew-cask) via PR, or host a tap:
```bash
brew tap the-robot-lives/apps https://github.com/the-robot-lives/homebrew-tap
brew install --cask the-robot-lives/apps/my-app
```

---

## Checklist

- [ ] Hardened Runtime enabled (`--options runtime`)
- [ ] All nested frameworks/dylibs signed before signing outer .app
- [ ] `xcrun notarytool submit --wait` returns `Accepted`
- [ ] `xcrun stapler staple` applied to DMG/pkg
- [ ] `spctl --assess --verbose` passes on final artifact
- [ ] Sparkle EdDSA private key stored in password manager (not repo)
- [ ] Appcast signature regenerated for every release
- [ ] DMG background and icon positioned correctly
