# Worked Example: Clipboard History Menu Bar App

A full walkthrough building a clipboard history utility using `MenuBarExtra`, an `@Observable` `ClipboardManager`, a global hotkey, launch-at-login, and notarized DMG distribution.

---

## App Overview

| Attribute | Value |
|-----------|-------|
| App name | ClipStack |
| App type | Menu bar utility (no Dock icon) |
| Window style | `.window` (persistent popover panel) |
| Min macOS | 14.0 (Sonoma) |
| Distribution | Direct (notarized DMG) — not App Store |
| Sandbox | No (required for global hotkey + full pasteboard access) |

---

## 1. App Entry Point

```swift
@main
struct ClipStackApp: App {
    @State private var manager = ClipboardManager()

    var body: some Scene {
        MenuBarExtra("ClipStack", systemImage: "doc.on.clipboard") {
            ClipboardMenuView(manager: manager)
                .frame(width: 320)
        }
        .menuBarExtraStyle(.window)   // Renders a real SwiftUI window, not a menu
    }
}
```

Hide the Dock icon and main window by setting `LSUIElement = YES` in `Info.plist`. This is the standard pattern for menu bar-only apps.

---

## 2. ClipboardManager

`@Observable` macro (Swift 5.9+) replaces `ObservableObject` + `@Published`. No manual `objectWillChange` needed.

```swift
import AppKit
import Observation

@Observable
final class ClipboardManager {
    private(set) var clips: [ClipItem] = []
    private var changeCount: Int = NSPasteboard.general.changeCount
    private var timer: Timer?

    static let maxClips = 25

    init() { startMonitoring() }
    deinit { timer?.invalidate() }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
    }

    private func checkPasteboard() {
        let pb = NSPasteboard.general
        guard pb.changeCount != changeCount else { return }
        changeCount = pb.changeCount

        if let string = pb.string(forType: .string) {
            let item = ClipItem(content: string)
            guard clips.first?.content != string else { return }  // deduplicate
            clips.insert(item, at: 0)
            if clips.count > Self.maxClips { clips.removeLast() }
        }
    }

    func copy(_ item: ClipItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.content, forType: .string)
        changeCount = NSPasteboard.general.changeCount  // suppress re-capture
    }

    func clear() { clips.removeAll() }
}

struct ClipItem: Identifiable {
    let id = UUID()
    let content: String
    let date = Date()

    var preview: String {
        let truncated = content.prefix(80)
        return truncated.components(separatedBy: .newlines).first.map(String.init) ?? String(truncated)
    }
}
```

**Polling vs. `NSPasteboardObserver`:** Polling at 0.5s is reliable; the observer protocol is available but less consistent across macOS versions.

---

## 3. Menu Window View

```swift
struct ClipboardMenuView: View {
    var manager: ClipboardManager
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            clipList
            Divider()
            footer
        }
    }

    private var header: some View {
        HStack {
            Text("Clipboard History")
                .font(.headline)
            Spacer()
            Button("Clear", role: .destructive) { manager.clear() }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var clipList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(manager.clips) { item in
                    ClipRow(item: item) { manager.copy(item) }
                }
            }
            .padding(6)
        }
        .frame(maxHeight: 360)
    }

    private var footer: some View {
        HStack {
            Text("\(manager.clips.count) items")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Preferences…") { /* open settings */ }
                .buttonStyle(.plain)
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}

struct ClipRow: View {
    var item: ClipItem
    var onCopy: () -> Void

    var body: some View {
        Button(action: onCopy) {
            HStack {
                Text(item.preview)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(item.date, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .hoverEffect()   // macOS: highlight on hover
    }
}
```

---

## 4. Global Hotkey

Use `NSEvent.addGlobalMonitorForEvents` — only available outside the sandbox.

```swift
final class HotkeyManager {
    private var monitor: Any?

    func register(onTrigger: @escaping () -> Void) {
        // Cmd+Shift+V
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            guard event.modifierFlags.contains([.command, .shift]),
                  event.charactersIgnoringModifiers == "v"
            else { return }
            DispatchQueue.main.async { onTrigger() }
        }
    }

    func unregister() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }
}
```

Wire into app init:

```swift
private var hotkeyManager = HotkeyManager()

// In App.init or onAppear:
hotkeyManager.register {
    // Toggle MenuBarExtra window visibility
    NSApp.activate(ignoringOtherApps: true)
}
```

**Accessibility permission required:** Global key monitors need the app to be listed under System Settings > Privacy & Security > Accessibility. Prompt on first launch:

```swift
if !AXIsProcessTrusted() {
    let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
    AXIsProcessTrustedWithOptions(opts as CFDictionary)
}
```

---

## 5. Launch at Login

Use `ServiceManagement` (macOS 13+) — no helper bundle needed.

```swift
import ServiceManagement

struct LaunchAtLoginToggle: View {
    @State private var enabled = (SMAppService.mainApp.status == .enabled)

    var body: some View {
        Toggle("Launch at Login", isOn: $enabled)
            .onChange(of: enabled) { _, newValue in
                do {
                    if newValue { try SMAppService.mainApp.register() }
                    else        { try SMAppService.mainApp.unregister() }
                } catch {
                    print("Launch at login error: \(error)")
                    enabled = !newValue  // revert
                }
            }
    }
}
```

---

## 6. Notarized DMG Distribution

### Build Steps

```bash
# 1. Archive in Xcode: Product > Archive
# 2. Export as Developer ID Application (not App Store)
xcodebuild archive \
  -scheme ClipStack \
  -configuration Release \
  -archivePath build/ClipStack.xcarchive

xcodebuild -exportArchive \
  -archivePath build/ClipStack.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist
```

`ExportOptions.plist`:
```xml
<dict>
  <key>method</key><string>developer-id</string>
  <key>signingStyle</key><string>automatic</string>
</dict>
```

### Notarize

```bash
xcrun notarytool submit build/export/ClipStack.app \
  --apple-id "you@example.com" \
  --team-id "YOURTEAMID" \
  --password "@keychain:AC_PASSWORD" \
  --wait

xcrun stapler staple build/export/ClipStack.app
```

### Package as DMG

```bash
hdiutil create -volname "ClipStack" \
  -srcfolder build/export/ClipStack.app \
  -ov -format UDZO \
  build/ClipStack.dmg
```

Notarize the DMG too — Gatekeeper checks it at download time:

```bash
xcrun notarytool submit build/ClipStack.dmg \
  --apple-id "you@example.com" \
  --team-id "YOURTEAMID" \
  --password "@keychain:AC_PASSWORD" \
  --wait
xcrun stapler staple build/ClipStack.dmg
```

---

## 7. Common Pitfalls

| Pitfall | Fix |
|---------|-----|
| Dock icon appears despite `LSUIElement` | Ensure key is in the app's own `Info.plist`, not a test target's |
| Global monitor fires inside own app | Check `event.cgEvent?.source` or use `addLocalMonitorForEvents` for in-app events |
| Accessibility prompt loops | Check `AXIsProcessTrusted()` before registering monitor |
| `SMAppService` throws even when user approves | Delay register call until after main window appears |
| Notarization fails: missing hardened runtime | Enable "Hardened Runtime" in Signing & Capabilities |
| `MenuBarExtra(.window)` flickers on show | Ensure view has a fixed `frame(width:)` — unconstrained width causes layout churn |

---

## Key Takeaways

- `MenuBarExtra(.window)` gives a proper SwiftUI view; `.menu` gives a traditional NSMenu
- `@Observable` is cleaner than `ObservableObject` for manager classes on macOS 14+
- Global hotkeys require non-sandboxed entitlements — plan distribution accordingly
- `SMAppService.mainApp` replaces the old login item helper bundle pattern (macOS 13+)
- Notarize both the `.app` and the `.dmg` — staple the ticket to both artifacts
