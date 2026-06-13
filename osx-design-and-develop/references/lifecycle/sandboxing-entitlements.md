# App Sandbox: Entitlements, Bookmarks & XPC

## What the Sandbox Does

macOS App Sandbox restricts app access to: file system (only container by default), network, hardware, and system services. All App Store apps must be sandboxed. Direct-distribution apps benefit from sandboxing but are not required to use it.

Container paths:
- `~/Library/Containers/<bundle-id>/Data/` — app container (HOME inside sandbox)
- `~/Library/Group Containers/<group-id>/` — shared between app and extensions

---

## Entitlements File

Entitlements live in `<Target>.entitlements` (a plist). Xcode links it under Build Settings → Code Signing Entitlements.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" ...>
<plist version="1.0">
<dict>
    <!-- Required for all sandboxed apps -->
    <key>com.apple.security.app-sandbox</key>
    <true/>

    <!-- Network -->
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <true/>

    <!-- Hardware -->
    <key>com.apple.security.device.camera</key>
    <true/>
    <key>com.apple.security.device.microphone</key>
    <true/>
    <key>com.apple.security.device.bluetooth</key>
    <true/>
    <key>com.apple.security.device.usb</key>
    <true/>

    <!-- File access (read-only vs read-write) -->
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.files.downloads.read-write</key>
    <true/>
    <!-- Avoid com.apple.security.files.all — rejected by App Review -->

    <!-- Scripting -->
    <key>com.apple.security.automation.apple-events</key>
    <true/>

    <!-- Print -->
    <key>com.apple.security.print</key>
    <true/>
</dict>
</plist>
```

---

## Security-Scoped Bookmarks

One-time powerbox grant (NSOpenPanel / NSSavePanel) lets user pick a file. To retain access across launches, persist a security-scoped bookmark.

```swift
// Save bookmark after user picks URL via NSOpenPanel
func persistBookmark(for url: URL) throws -> Data {
    return try url.bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
    )
}

// Restore access on next launch
func resolveBookmark(_ data: Data) throws -> URL {
    var isStale = false
    let url = try URL(
        resolvingBookmarkData: data,
        options: .withSecurityScope,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
    )
    if isStale {
        // Re-save bookmark; url is still valid this session
    }
    url.startAccessingSecurityScopedResource()
    // ... use url ...
    url.stopAccessingSecurityScopedResource()
    return url
}
```

Entitlement required: `com.apple.security.files.bookmarks.app-scope` (or `collection-scope` for document-scoped bookmarks).

Store bookmark Data in UserDefaults or a file in the container. Never store the raw URL — it won't grant access after restart.

---

## Powerbox (NSOpenPanel Grants)

When the user selects a file/folder via NSOpenPanel or NSSavePanel, the sandbox automatically extends access for that session — no extra entitlement needed for the immediate use. For persistence across launches, create a security-scoped bookmark (above).

SwiftUI file importer uses the same powerbox mechanism:

```swift
.fileImporter(isPresented: $showPicker, allowedContentTypes: [.pdf]) { result in
    if let url = try? result.get() {
        let bookmarkData = try? persistBookmark(for: url)
        // store bookmarkData
    }
}
```

---

## Temporary Exceptions (Use Sparingly)

Temporary exceptions bypass sandbox for specific paths. App Review scrutinizes these; document the justification.

```xml
<!-- Read-write access to a specific absolute path (unusual; requires justification) -->
<key>com.apple.security.temporary-exception.files.absolute-path.read-write</key>
<array>
    <string>/usr/local/bin/</string>
</array>

<!-- Mach lookup for specific services -->
<key>com.apple.security.temporary-exception.mach-lookup.global-name</key>
<array>
    <string>com.example.service</string>
</array>
```

Prefer XPC services over temporary exceptions wherever possible.

---

## XPC Services

XPC services run in their own sandbox, enabling privilege separation:

- Declared in `<App>.xpc` target, bundled in `Contents/XPCServices/`
- Each XPC service has its own entitlements plist
- Parent app and XPC service communicate via NSXPCConnection
- Use for: privileged helpers (SMJobBless), network isolation, crash isolation

```swift
// App side
let connection = NSXPCConnection(serviceName: "com.example.MyHelper")
connection.remoteObjectInterface = NSXPCInterface(with: MyHelperProtocol.self)
connection.resume()
let proxy = connection.remoteObjectProxy as? MyHelperProtocol
proxy?.doWork { result in ... }
```

For elevated privileges (e.g., install tools), use SMAppService (macOS 13+) rather than the deprecated SMJobBless.

---

## App Store vs Direct Distribution Sandbox Differences

| Concern | App Store | Direct (Developer ID) |
|---|---|---|
| Sandbox required | Yes, mandatory | No, optional but recommended |
| Hardened Runtime | Yes | Yes (required for notarization) |
| Entitlement review | App Review checks | Automated notarization scan |
| `com.apple.security.get-task-allow` | false in production | false for notarization |
| JIT (`allow-jit`) | Not allowed | Allowed via entitlement |
| Debugger attach | Not allowed | Allowed via `get-task-allow` in dev |

Hardened Runtime entitlement for direct distribution:
```xml
<key>com.apple.security.cs.allow-jit</key>
<true/>
<key>com.apple.security.cs.disable-library-validation</key>
<true/> <!-- only if loading third-party plug-ins -->
```

---

## Checklist

- [ ] `.entitlements` file linked in Build Settings for each target
- [ ] Separate entitlements for Debug (may include `get-task-allow`) vs Release
- [ ] Security-scoped bookmarks saved for any user-selected paths needed across launches
- [ ] No `com.apple.security.files.all` — use narrow entitlements
- [ ] XPC services have their own minimal entitlements
- [ ] Temporary exceptions documented with justification comments
