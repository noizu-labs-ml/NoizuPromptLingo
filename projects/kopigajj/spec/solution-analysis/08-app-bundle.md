# macOS App Bundle Structure for Utilities

## Overview

A macOS app bundle is a directory structure that contains an application's executable and all associated resources. For clipboard manager utilities, understanding bundle structure is essential for proper distribution and installation.

## Core Concepts

- **App Bundle**: A directory with `.app` extension
- **Info.plist**: Application metadata and configuration
- **Bundle Structure**: Standardized directory layout
- **Code Signing**: Required for distribution
- **Xcode Build Settings**: Control bundle contents

## Key APIs and Frameworks

| API/Framework | Purpose |
|--------------|---------|
| `Bundle` | Access bundle resources at runtime |
| `NSBundle` | Foundation bundle API |
| `Info.plist` | App configuration |
| `Xcode Build System` | Bundle creation and signing |
| `codesign` CLI | Command-line code signing |

## App Bundle Structure

```
MyApp.app/
├── Contents/
│   ├── Info.plist                # App metadata
│   ├── PkgInfo                   # Type and creator
│   ├── MacOS/
│   │   └── MyApp                 # Executable binary
│   ├── Resources/
│   │   ├── Assets.xcassets/     # Images, icons, colors
│   │   │   ├── AppIcon.icns
│   │   │   ├── AppIcon.appiconset/
│   │   │   └── ...
│   │   ├── en.lproj/            # Localized resources
│   │   │   └── InfoPlist.strings
│   │   └── MainMenu.nib         # Interface files
│   ├── Frameworks/              # Dynamic libraries
│   ├── PlugIns/                 # Plugins/Extensions
│   ├── SharedFrameworks/        # Shared libraries
│   └── _CodeSignature/          # Code signature data
```

## Info.plist Configuration

### Minimal Info.plist for Clipboard Manager

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Basic App Information -->
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>

    <key>CFBundleExecutable</key>
    <string>ClipboardManager</string>

    <key>CFBundleIdentifier</key>
    <string>com.yourapp.clipboardmanager</string>

    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>

    <key>CFBundleName</key>
    <string>ClipboardManager</string>

    <key>CFBundlePackageType</key>
    <string>APPL</string>

    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>

    <key>CFBundleVersion</key>
    <string>1</string>

    <!-- User Interface -->
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>

    <key>NSHumanReadableCopyright</key>
    <string>© 2025 Your Company. All rights reserved.</string>

    <!-- Category -->
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>

    <!-- Display -->
    <key>NSAppleScriptEnabled</key>
    <false/>

    <key>NSPrincipalClass</key>
    <string>NSApplication</string>

    <!-- Dock and Menu Bar -->
    <key>LSUIElement</key>
    <false/>

    <key>NSAllowsArbitraryLoads</key>
    <false/>

    <!-- File Associations -->
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>clipboard</string>
            </array>
            <key>CFBundleTypeIconFile</key>
            <string></string>
            <key>CFBundleTypeName</key>
            <string>Clipboard History</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.plain-text</string>
            </array>
        </dict>
    </array>

    <!-- Services (if sharing) -->
    <key>NSServices</key>
    <array>
        <dict>
            <key>NSMenuItem</key>
            <dict>
                <key>default</key>
                <string>ClipboardManager: Copy History</string>
            </dict>
            <key>NSMessage</key>
            <string>sendHistory</string>
            <key>NSPortName</key>
            <string>ClipboardManager</string>
            <key>NSSendTypes</key>
            <array>
                <string>public.utf8-plain-text</string>
                <string>public.url</string>
            </array>
        </dict>
    </array>

    <!-- Privacy Descriptions -->
    <key>NSAppleEventsUsageDescription</key>
    <string>This app uses AppleEvents to monitor clipboard changes and respond to keyboard shortcuts.</string>

    <key>NSAccessibilityUsageDescription</key>
    <string>This app requires accessibility permissions to monitor global keyboard shortcuts and clipboard changes.</string>

    <key>NSRemindersUsageDescription</key>
    <string></string>

    <key>NSCameraUsageDescription</key>
    <string></string>

    <key>NSMicrophoneUsageDescription</key>
    <string></string>

    <!-- Network -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
    </dict>

    <!-- Permissions -->
    <key>NSSystemAdministrationUsageDescription</key>
    <string></string>

</dict>
</plist>
```

## Swift Code Examples

### Accessing Bundle Resources

```swift
import Foundation

class BundleManager {
    static let current = BundleManager()

    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    // App Information
    var appName: String {
        bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown"
    }

    var appVersion: String {
        bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    var bundleIdentifier: String {
        bundle.bundleIdentifier ?? ""
    }

    var buildNumber: String {
        bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var copyright: String {
        bundle.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String ?? ""
    }

    // Resource Paths
    var appSupportDirectory: URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(bundleIdentifier)
    }

    var cacheDirectory: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?.            appendingPathComponent(bundleIdentifier)
    }

    func createAppSupportDirectoryIfNeeded() {
        guard let url = appSupportDirectory else { return }
        try? FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    // Load Resources
    func loadJSON<T: Decodable>(filename: String, as type: T.Type) -> T? {
        // First, check for file in Application Support (user customizations)
        if let appSupportURL = appSupportDirectory,
           let customFileURL = appSupportURL.appendingPathComponent(filename).resolveSymlinksInPath(),
           FileManager.default.fileExists(atPath: customFileURL.path) {
            return loadJSON(url: customFileURL, as: type)
        }

        // Check bundle resources
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            return nil
        }
        return loadJSON(url: url, as: type)
    }

    private func loadJSON<T: Decodable>(url: URL, as type: T.Type) -> T? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func loadImage(named name: String) -> NSImage? {
        return bundle.image(forResource: name)
    }

    func loadAsset(named name: String, inAssetCatalog catalogName: String = "Assets") -> NSImage? {
        return NSImage(assetName: name)
    }
}
```

### Application Configuration

```swift
import Foundation

class AppConfiguration {
    static let shared = AppConfiguration()

    struct Settings {
        var maxHistoryItems: Int
        var autoStart: Bool
        var hotkeyCode: Int
        var hotkeyModifiers: Int
        var showNotifications: Bool
        var searchEnabled: Bool
        var cloudSyncEnabled: Bool
        var privacyMode: Bool
    }

    let settings: Settings
    let version: Version

    private init() {
        // Load from Info.plist and config file
        self.version = Version(
            major: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        )

        // Default settings - can be overridden by user preferences
        self.settings = Settings(
            maxHistoryItems: 100,
            autoStart: true,
            hotkeyCode: 9, // 'V' key
            hotkeyModifiers: 0x010308, // Command+Shift+Option
            showNotifications: true,
            searchEnabled: true,
            cloudSyncEnabled: false,
            privacyMode: false
        )
    }
}

struct Version {
    let versionString: String
    let major: Int
    let minor: Int
    let patch: Int

    init(_ versionString: String) {
        self.versionString = versionString
        let parts = versionString.split(separator: ".").map { Int($0.trimmingCharacters(in: CharacterSet(arrayLiteral: "v"))) ?? 0 }
        self.major = parts.count > 0 ? parts[0] : 0
        self.minor = parts.count > 1 ? parts[1] : 0
        self.patch = parts.count > 2 ? parts[2] : 0
    }

    func isOlder(than other: Version) -> Bool {
        if major < other.major { return true }
        if major > other.major { return false }
        if minor < other.minor { return true }
        if minor > other.minor { return false }
        return patch < other.patch
    }

    var description: String {
        versionString
    }
}
```

### Code Signing Helper

```swift
import Foundation

enum CodeSigningError: Error {
    case noBundlePath
    case signingFailed(String)
    case verificationFailed(String)
}

class CodeSigningHelper {
    /// Check if app is code signed
    static func isCodeSigned(at bundlePath: String) -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        task.arguments = ["-d", "-v", bundlePath]

        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }

    /// Verify code signature
    static func verifySignature(at bundlePath: String) -> CodeSigningResult {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        task.arguments = ["--verify", "--verbose=4", bundlePath]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = outputPipe

        do {
            try task.run()
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""

            task.waitUntilExit()

            if task.terminationStatus == 0 {
                return .success
            } else {
                return .failed(output)
            }
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    enum CodeSigningResult {
        case success
        case failed(String)
    }

    /// Get signing identity
    static func getSigningIdentity(for bundlePath: String) -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        task.arguments = ["-d", "-vvv", bundlePath]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = outputPipe

        do {
            try task.run()
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""

            task.waitUntilExit()

            // Parse output to find identifier
            if let range = output.range(of: "Identifier=\"", options: .caseInsensitive),
               let endRange = output.range(of: "\"", range: range.upperBound) {
                return String(output[range.upperBound..<endRange.lowerBound])
            }
            return nil
        } catch {
            return nil
        }
    }
}
```

### Entitlements Handling

```swift
import Foundation

class EntitlementsManager {
    private static let plistKey = "com.apple.security.app-sandbox"

    static let appBundlePath = Bundle.main.bundlePath

    static func isSandboxed() -> Bool {
        guard let entitlements = loadEntitlements() else {
            return false
        }
        return entitlements[plistKey] as? Bool ?? false
    }

    private static func loadEntitlements() -> [String: Any]? {
        // Try embedded entitlements
        if let embeddedPath = Bundle.main.path(forResource: "embedded", ofType: "provisionprofile"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: embeddedPath)),
           let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
            return dict
        }

        // Parse from code signature
        return loadEntitlementsFromSignature()
    }

    private static func loadEntitlementsFromSignature() -> [String: Any]? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        task.arguments = ["--display", "--entitlements", "-", Bundle.main.bundlePath]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        do {
            try task.run()
            task.waitUntilExit()

            if task.terminationStatus == 0 {
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                return try? PropertyListSerialization.propertyList(
                    from: outputData,
                    options: [],
                    format: nil
                ) as? [String: Any]
            }
            return nil
        } catch {
            return nil
        }
    }

    struct Entitlements {
        let isSandboxed: Bool
        let hasAccessibility: Bool
        let hasAppBundle: Bool
        let hasNetworkClient: Bool
        let hasFileAccess: Bool

        static var current: Entitlements {
            let allEntitlements = loadEntitlements() ?? [:]

            return Entitlements(
                isSandboxed: allEntitlements[plistKey] as? Bool ?? false,
                hasAccessibility: allEntitlements["com.apple.security.automation.apple-events"] as? Bool ?? false,
                hasAppBundle: allEntitlements["com.apple.security.application-groups"] as? [String] != nil,
                hasNetworkClient: allEntitlements["com.apple.security.network.client"] as? Bool ?? false,
                hasFileAccess: allEntitlements["com.apple.security.files.user-selected.read-write"] as? Bool ?? false
            )
        }
    }
}
```

### Build Configuration Scripts

```bash
#!/bin/bash
# build-app.sh - Build and prepare macOS app bundle

set -e

# Configuration
APP_NAME="ClipboardManager"
BUNDLE_ID="com.yourapp.clipboardmanager"
BUILD_DIR="build"
ARCHIVE_DIR="archive"
OUTPUT_DIR="release"

# Clean
echo "Cleaning build directory..."
rm -rf "$BUILD_DIR"
rm -rf "$ARCHIVE_DIR"

# Build
echo "Building..."
xcodebuild \
    -scheme "$APP_NAME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    -archivePath "$ARCHIVE_DIR/$APP_NAME.xcarchive" \
    archive

# Export app
echo "Exporting..."
xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_DIR/$APP_NAME.xcarchive" \
    -exportPath "$OUTPUT_DIR" \
    -exportOptionsPlist export-options.plist

# Code sign
echo "Code signing..."
APP_PATH="$OUTPUT_DIR/$APP_NAME.app"
codesign --force --deep --sign "Developer ID Application: Your Name" "$APP_PATH"

# Verify
echo "Verifying signature..."
codesign -vvv --deep "$APP_PATH"

# Create DMG
echo "Creating DMG..."
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
hdiutil create \
    -format UDZO \
    -srcfolder "$OUTPUT_DIR" \
    -volname "$APP_NAME" \
    "$DMG_NAME"

echo "Build complete: $DMG_NAME"
```

### Export Options POM

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>

    <key>stripSwiftSymbols</key>
    <true/>

    <key>uploadSymbols</key>
    <false/>

    <key>uploadBitcode</key>
    <false/>

    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>

    <key>signingStyle</key>
    <string>manual</string>

    <key>signingCertificate</key>
    <string>Developer ID Application</string>
</dict>
</plist>
```

## Implementation Considerations

### Bundle Versioning

Use semantic versioning:
- `CFBundleShortVersionString`: User-facing version (1.0.0)
- `CFBundleVersion`: Build number (increment each build)

### Icon Configuration

Multiple icon sizes required for macOS:
- 16x16, 32x32, 128x128, 256x256, 512x512, 1024x1024
- Retina versions: @2x variants

### Code Signing Requirements

1. Development: Self-signed certificate
2. Distribution: Developer ID certificate
3. App Store: Distribution certificate + provisioning profile

### Notarization (for Distribution)

Required for apps distributed outside App Store:

```bash
# Upload for notarization
xcrun notarytool submit "$APP.dmg" \
    --apple-id "your@email.com" \
    --password "app-specific-password" \
    --team-id "YOUR_TEAM_ID" \
    --wait

# Staple notarization
xcrun stapler staple "$APP.dmg"
```

## Potential Pitfalls to Avoid

### 1. Missing Code Signing

```bash
# BAD - Not code signed
cp MyApp.app /Applications/

# GOOD - Code sign before distribution
codesign --force --deep --sign "Certificate Name" MyApp.app
```

### 2. Wrong Bundle Structure

```bash
# BAD - Files not in correct locations
MyApp.app/MyApp  # Wrong location

# GOOD - Proper structure
MyApp.app/Contents/MacOS/MyApp  # Correct location
```

### 3. Missing Info.plist Keys

```xml
<!-- BAD - Missing required keys -->
<dict>
    <key>CFBundleExecutable</key>
    <string>MyApp</string>
</dict>

<!-- GOOD - Include all required keys -->
<dict>
    <key>CFBundleExecutable</key>
    <string>MyApp</string>
    <key>CFBundleIdentifier</key>
    <string>com.myapp.myapp</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    ...
</dict>
```

### 4. Hardcoded Paths

```swift
// BAD - Won't work when bundled
let dbPath = "/usr/local/myapp/database.sqlite"

// GOOD - Use bundle-relative paths
let dbURL = BundleManager.current.appSupportDirectory?.appendingPathComponent("database.sqlite")
```

## Apple Documentation References

- [App Bundle Structure](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/Introduction/Introduction.html)
- [Info.plist Keys](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/)
- [Code Signing](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/Introduction/Introduction.html)
- [Notarizing Mac Software](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)

## Best Practices Summary

1. **Follow Standard Structure**: Never modify the app bundle layout
2. **Proper Code Signing**: Always sign code before distribution
3. **Complete Info.plist**: Include all relevant keys
4. **Use Bundle API**: Access resources correctly via Bundle class
5. **Version Consistency**: Keep version strings in sync
6. **Testing**: Test app from installed location, not build folder
7. **Icon Requirements**: Provide all required icon sizes
8. **Notarization**: Notarize for distribution outside App Store
9. **Entitlements**: Define clear entitlements in .entitlements file
10. **Documentation**: Document build and distribution process

## Directory Locations by Sandbox Status

| Location | Sandboxed | Non-Sandboxed |
|----------|-----------|---------------|
| `/Applications/MyApp.app` | ✅ | ✅ |
| `~/Library/Application Support/` | ✅ | ✅ |
| `~/Library/Caches/` | ✅ | ✅ |
| `/usr/local/lib/` | ❌ | ✅ |
| `/tmp/` | ⚠️ | ✅ |
| User-selected files | ✅ | ✅ |

## Common Info.plist Keys for Utilities

| Key | Description | Required |
|-----|-------------|----------|
| `CFBundleIdentifier` | Reverse-DNS identifier | Yes |
| `CFBundleExecutable` | Executable name | Yes |
| `CFBundleName` | App name | Yes |
| `CFBundleShortVersionString` | Display version | Yes |
| `CFBundleVersion` | Build number | Yes |
| `CFBundlePackageType` | Package type (APPL) | Yes |
| `NSPrincipalClass` | App class name | Yes |
| `LSMinimumSystemVersion` | Min OS version | Recommended |
| `NSHumanReadableCopyright` | Copyright string | Recommended |
| `LSUIElement` | Hides dock icon if true | Optional |
| `NSAccessibilityUsageDescription` | Privacy description | If needed |

<!-- nav -->

---

[< Previous: App Sandboxing Considerations for Clipboard Access](07-sandboxing.md) | [Table of Contents](../../product-spec.md) | [Next: LaunchAgents/LaunchDaemons for Background Processes >](09-launch-agents.md)

<!-- nav -->
