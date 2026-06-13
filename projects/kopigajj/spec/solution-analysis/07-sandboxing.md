# App Sandboxing Considerations for Clipboard Access

## Overview

App Sandboxing is a macOS security feature that limits application access to system resources. Clipboard managers face specific challenges with sandboxing due to their need to monitor clipboard contents and interact with user files.

## Core Concepts

- **Sandboxing**: Restricts app access to system resources
- **Entitlements**: Permissions granted to sandboxed apps
- **Security-scoped Resources**: Temporary access to files
- **UserDefaults**: Key-value storage without file system access
- **App Groups**: Shared container for related apps

## Key APIs and Frameworks

| API/Framework | Purpose |
|--------------|---------|
| `NSAppTransportSecurity` | Network security |
| `Entitlements` (.entitlements plist) | Permissions and capabilities |
| `NSOpenPanel` | File access with user selection |
| `NSPasteboard` | Clipboard access |
| `Security-Scoped Bookmarks` | Persistent file access |

## Swift Code Examples

### Entitlements Configuration

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App ID -->
    <key>com.apple.security.app-sandbox</key>
    <true/>

    <!-- Clipboard Access (usually allowed) -->
    <key>com.apple.security.automation.apple-events</key>
    <true/>

    <!-- Network Access -->
    <key>com.apple.security.network.client</key>
    <true/>

    <!-- Outgoing connections to specific domains -->
    <key>com.apple.security.network.outgoing</key>
    <array>
        <string>*.yourdomain.com</string>
    </array>

    <!-- File Access -->
    <!-- User Selected Files -->
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>

    <!-- Download Folder -->
    <key>com.apple.security.files.downloads.read-write</key>
    <true/>

    <!-- Pictures Folder (for image clipboard items) -->
    <key>com.apple.security.assets.pictures.read-write</key>
    <true/>

    <!-- Accessiblity -->
    <key>com.apple.security.automation.apple-events</key>
    <true/>

    <!-- App Groups for XPC communication -->
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.yourapp.clipboard</string>
    </array>

    <!-- Audio (if adding audio clipboard support) -->
    <key>com.apple.security.assets.music.read-write</key>
    <true/>

    <!-- Hardware access for microphone/clipboard capture -->
    <key>com.apple.security.device.camera</key>
    <false/>
    <key>com.apple.security.device.microphone</key>
    <false/>
</dict>
</plist>
```

### Clipboard Access in Sandbox

```swift
import AppKit

class SandboxClipboardMonitor {
    private var pasteboard = NSPasteboard.general

    /// Check if clipboard access is available
    func canAccessClipboard() -> Bool {
        // Pasteboard access is typically allowed even sandboxed
        // but should be gracefully handled
        guard pasteboard.types != nil else {
            return false
        }
        return true
    }

    func readClipboardSafely() -> ClipboardItem? {
        // This should work in sandbox
        do {
            guard let types = pasteboard.types,
                  types.contains(.string),
                  let text = pasteboard.string(forType: .string) else {
                return nil
            }

            return ClipboardItem(
                id: UUID(),
                type: .text,
                content: text,
                timestamp: Date()
            )
        } catch {
            print("Failed to access clipboard: \(error)")
            return nil
        }
    }
}
```

### Security-Scoped File Access

```swift
import Cocoa

class SecureFileManager {
    private var securityScopedBookmarks: [String: Data] = [:]

    /// Request access to a file (for clipboard file references)
    func requestAccess(to url: URL) -> Bool {
        // Check if already have access from a previous bookmark
        if let bookmark = securityScopedBookmarks[url.path] {
            return resumeAccessFromBookmark(bookmark)
        }

        // For file items on clipboard, attempt to get security-scoped access
        let accessing = url.startAccessingSecurityScopedResource()
        if accessing {
            // Save bookmark for future use
            if let bookmark = try? url.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            ) {
                securityScopedBookmarks[url.path] = bookmark
            }
        }
        return accessing
    }

    func stopAccess(to url: URL) {
        url.stopAccessingSecurityScopedResource()
        securityScopedBookmarks.removeValue(forKey: url.path)
    }

    private func resumeAccessFromBookmark(_ bookmark: Data) -> Bool {
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: bookmark,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else {
            return false
        }

        if isStale {
            // Bookmark is stale, need to request new access
            return false
        }

        return url.startAccessingSecurityScopedResource()
    }

    func saveBookmarks() {
        // Save bookmarks to UserDefaults for persistence across launches
        let defaults = UserDefaults.standard
        defaults.set(securityScopedBookmarks, forKey: "SecurityScopedBookmarks")
    }

    func restoreBookmarks() {
        let defaults = UserDefaults.standard
        if let bookmarks = defaults.dictionary(forKey: "SecurityScopedBookmarks") as? [String: Data] {
            securityScopedBookmarks = bookmarks
        }
    }
}
```

### Clipboard File Handling

```swift
import AppKit

class ClipboardFileHandler {
    private let fileManager = SecureFileManager()

    func handleFilesOnClipboard() -> [FileReference] {
        let pasteboard = NSPasteboard.general

        guard pasteboard.types?.contains(.fileURL) == true else {
            return []
        }

        guard let fileURLs = pasteboard.readObjects(
            forClasses: [NSURL.self],
            options: nil
        ) as? [URL] else {
            return []
        }

        return fileURLs.compactMap { url in
            guard let fileReference = createFileReference(from: url) else {
                return nil
            }
            return fileReference
        }
    }

    private func createFileReference(from url: URL) -> FileReference? {
        // In sandbox, we can't directly copy file content
        // Instead, we store a secure reference or bookmark

        // Try to get security-scoped access
        let hasAccess = fileManager.requestAccess(to: url)

        // Read file metadata (allowed in sandbox if security scope obtained)
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)

        let fileReference = FileReference(
            id: UUID(),
            fileURL: url,
            name: url.lastPathComponent,
            size: attributes?[.size] as? Int64 ?? 0,
            type: url.pathExtension,
            hasSecurityAccess: hasAccess
        )

        // Release access (will re-acquire when needed)
        if hasAccess {
            fileManager.stopAccess(to: url)
        }

        return fileReference
    }
}

struct FileReference: Identifiable {
    let id: UUID
    let fileURL: URL
    let name: String
    let size: Int64
    let type: String
    let hasSecurityAccess: Bool

    func formatSize() -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter.string(fromByteCount: size)
    }
}
```

### App Groups for Data Sharing

```swift
import Foundation

class SharedDataManager {
    // Use app group container for shared database across helper apps
    private let groupIdentifier = "group.com.yourapp.clipboard"

    var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
    }

    var databaseURL: URL? {
        sharedContainerURL?.appendingPathComponent("ClipboardManager/db.sqlite")
    }

    func initializeSharedDatabase() {
        guard let dbURL = databaseURL else {
            print("Failed to get shared container URL")
            return
        }

        // Ensure directory exists
        try? FileManager.default.createDirectory(
            at: dbURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )

        // Initialize database at shared location
        print("Database at: \(dbURL.path)")
    }
}
```

### UserDefaults in Sandbox

```swift
import Foundation

class SandboxStorage {
    private let userDefaults = UserDefaults.standard

    struct Keys {
        static let maxHistorySize = "maxHistorySize"
        static let startupBehavior = "startupBehavior"
        static let hotkeyModifiers = "hotkeyModifiers"
    }

    // UserDefaults works fine in sandbox for app-specific settings
    func savePreference(key: String, value: Any) {
        userDefaults.set(value, forKey: key)
    }

    func getPreference<T>(key: String, defaultValue: T) -> T {
        return userDefaults.object(forKey: key) as? T ?? defaultValue
    }

    func removeAllPreferences() {
        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
    }

    // Structured settings
    struct AppSettings: Codable {
        var maxHistoryItems: Int
        var autoStart: Bool
        var hotkeyCode: Int
        var showNotifications: Bool

        static let defaultSettings = AppSettings(
            maxHistoryItems: 100,
            autoStart: true,
            hotkeyCode: 9, // 'V' key
            showNotifications: true
        )
    }

    func saveSettings(_ settings: AppSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            userDefaults.set(encoded, forKey: "appSettings")
        }
    }

    func loadSettings() -> AppSettings {
        if let data = userDefaults.data(forKey: "appSettings"),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            return decoded
        }
        return AppSettings.defaultSettings
    }
}
```

### XPC Communication in Sandbox

```swift
import Foundation

/// Define the XPC protocol for communication between main app and helper
@objc protocol ClipboardHelperProtocol: NSObjectProtocol {
    func monitorClipboard(withReply: @escaping (Bool) -> Void)
    func fetchHistory(limit: Int, withReply: @escaping ([ClipboardItem]) -> Void)
    func setHotkey(code: Int, withReply: @escaping (Bool) -> Void)
}

/// XPC connection manager
class XPCConnectionManager {
    private var connection: NSXPCConnection?

    func connectToHelper() {
        // Use app group for XPC service location
        connection = NSXPCConnection(serviceName: "com.yourapp.clipboard-helper")

        connection?.remoteObjectInterface = NSXPCInterface(with: ClipboardHelperProtocol.self)

        connection?.interruptionHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.handleDisconnection()
            }
        }

        connection?.resume()
    }

    private func handleDisconnection() {
        connection = nil
        // Attempt to reconnect after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.connectToHelper()
        }
    }

    func monitorClipboard(completion: @escaping (Bool) -> Void) {
        guard let helper = connection?.remoteObjectProxy as? ClipboardHelperProtocol else {
            completion(false)
            return
        }

        helper.monitorClipboard { success in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
```

### Handling Accessibility Privileges

```swift
import ApplicationServices

class AccessibilityHelper {
    /// Check if app has accessibility privileges
    static func hasAccessibilityPermissions() -> Bool {
        return AXIsProcessTrusted()
    }

    /// Prompt user to enable accessibility
    static func requestAccessibilityPermissions() {
        var options: [String: Bool] = [:]
        options[kAXTrustedCheckOptionPrompt.takeRetainedValue() as String] = true
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    /// Open System Settings to accessibility preferences
    static func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    /// Show appropriate UI based on permissions
    static func checkAndRequestPermissionsIfNeeded() {
        if !hasAccessibilityPermissions() {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Accessibility Permissions Required"
                alert.informativeText = "This app needs accessibility permissions to monitor clipboard changes. Please enable this in System Settings."
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Cancel")

                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    openAccessibilitySettings()
                }
            }
        }
    }
}
```

## Implementation Considerations

### Sandbox Compatibility Checklist

- [ ] Clipboard access: Generally permitted within the app's pasteboard
- [ ] Accessibility monitoring: Requires user permission
- [ ] File access: Use security-scoped bookmarks or user-selected files
- [ ] Network: Requires network entitlements
- [ ] Database storage: Use app group container or Application Support
- [ ] IPC: Use XPC services within the app group

### File Access Strategy

For clipboard files, adopt a multi-tiered approach:

1. Initially, detect file URLs from clipboard
2. Request security-scoped access only when needed
3. Store bookmarks for future access
4. Handle access denial gracefully

### Global Hotkeys in Sandbox

Global event monitoring requires accessibility permissions:

```swift
// Register for accessibility permissions early in app launch
AccessibilityHelper.checkAndRequestPermissionsIfNeeded()

// Only start monitoring after permissions are granted
if AccessibilityHelper.hasAccessibilityPermissions() {
    startGlobalHotkeyMonitoring()
}
```

## Potential Pitfalls to Avoid

### 1. Assuming Full File Access

```swift
// BAD - Will fail in sandbox
let data = try Data(contentsOf: fileURL)

// GOOD - Request security scope first
fileURL.startAccessingSecurityScopedResource()
defer { fileURL.stopAccessingSecurityScopedResource() }
let data = try Data(contentsOf: fileURL)
```

### 2. Not Handling Permission Errors

```swift
// BAD - Silent failure
_ = try? fileOperation()

// GOOD - Show user feedback
do {
    try fileOperation()
} catch {
    showPermissionError(error)
}
```

### 3. Forgetting to Release Security Scope

```swift
// BAD - Resources held indefinitely
fileURL.startAccessingSecurityScopedResource()
// Do work
// Forget to stop

// GOOD - Use defer
fileURL.startAccessingSecurityScopedResource()
defer { fileURL.stopAccessingSecurityScopedResource() }
// Do work
```

### 4. Using Wrong Config Directory

```swift
// BAD - Won't work in sandbox
let configPath = "/usr/local/share/app/config"

// GOOD - Use Application Support
let configURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    .first?
    .appendingPathComponent("YourApp/config.json")
```

### 5. Not Checking Sandbox Status

```swift
// BAD - May crash or behave unexpectedly
doWorkRequiringPermissions()

// GOOD - Check first
guard canPerformWork() else {
    showPermissionPrompt()
    return
}
doWorkRequiringPermissions()
```

## Apple Documentation References

- [App Sandbox](https://developer.apple.com/documentation/security/app_sandbox)
- [Designing for App Sandbox](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/)
- [Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements)
- [Accessing Files from a Sandbox](https://developer.apple.com/documentation/security/accessing-files-from-a-sandbox)
- [Security-Scoped Bookmarks](https://developer.apple.com/library/archive/documentation/Security/Conceptual/SecureCodingGuide/Articles/DesigningDataAccess.html)
- [App Groups](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)

## Sandbox Permissions Reference

| Entitlement | Allows access to | When needed |
|-------------|------------------|-------------|
| `com.apple.security.app-sandbox` | Enables sandboxing | Required for sandbox |
| `com.apple.security.automation.apple-events` | AppleScript/Automation | For accessibility monitoring |
| `com.apple.security.network.client` | Outgoing network connections | Cloud sync, telemetry |
| `com.apple.security.network.server` | Incoming network connections | Remote clipboard access |
| `com.apple.security.files.user-selected.read-only` | User-selected files | File clipboard items |
| `com.apple.security.files.user-selected.read-write` | User-selected files (rw) | Saving file clipboard items |
| `com.apple.security.files.downloads.read-only` | Downloads folder | Default clipboard save location |
| `com.apple.security.assets.pictures.read-write` | Pictures folder | Image clipboard items |
| `com.apple.security.application-groups` | Shared container | XPC service, shared DB |

## Best Practices Summary

1. **Enable Sandboxing**: Submit App Store apps with sandboxing
2. **Request Minimal Permissions**: Only request needed entitlements
3. **Use Security Scope**: For file access, use security-scoped resources
4. **Handle Denials Gracefully**: Show clear user messages when access denied
5. **Use App Groups**: For cross-process communication and data sharing
6. **Document Permissions**: Clearly explain to users why permissions are needed
7. **Test in Sandbox**: Verify all functionality in sandboxed environment
7. **Fallback Modes**: Provide reduced functionality when permissions denied
8. **Clean Up Resources**: Release security-scoped resources promptly
9. **Cache Bookmarks**: Persist security-scoped bookmarks for future access
10. **Privacy First**: Be transparent about clipboard monitoring

## Testing Sandboxing

1. Enable sandboxing in Xcode target settings
2. Code sign app with development certificate
3. Run app within Sandbox
4. Test all clipboard operations
5. Test file access for copied files
6. Test with/without accessibility permissions
7. Test with/without file access permissions
8. Verify data persistence across app restarts
9. Test network operations (if applicable)
10. Test on different macOS versions

## Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Can't read clipboard | Missing entitlement | Ensure no clipboard-related entitlement needed |
| File access denied | Missing security scope | Add security-scoped resource handling |
| XPC fails | No app group | Configure app groups in entitlements |
| Database not persistent | Wrong location | Use Application Support or app group container |
| Accessibility fails | No permissions | Request permissions explicitly |

<!-- nav -->

---

[< Previous: SQLite Integration in Swift for Local Persistence](06-sqlite-persistence.md) | [Table of Contents](../../product-spec.md) | [Next: macOS App Bundle Structure for Utilities >](08-app-bundle.md)

<!-- nav -->
