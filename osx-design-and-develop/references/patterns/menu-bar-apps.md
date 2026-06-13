# Menu Bar Apps — SwiftUI macOS

## MenuBarExtra Scene

```swift
@main
struct MyApp: App {
    var body: some Scene {
        MenuBarExtra("My App", systemImage: "star.fill") {
            AppMenu()
        }
    }
}
```

Available since macOS 13. Replaces the `NSStatusItem` + `NSMenu` boilerplate for most use cases.

---

## Menu Style vs Window Style

### .menu (default) — native NSMenu dropdown

```swift
MenuBarExtra("Sync", systemImage: "arrow.triangle.2.circlepath") {
    Button("Sync Now") { sync() }
    Divider()
    Button("Quit") { NSApplication.shared.terminate(nil) }
}
.menuBarExtraStyle(.menu)
```

- Renders as a standard macOS menu
- Limited to `Button`, `Divider`, `Toggle`, `Picker`, `Menu` (submenus)
- No arbitrary SwiftUI layout

### .window — floating SwiftUI popover

```swift
MenuBarExtra("Status", systemImage: "chart.bar") {
    StatusView()
        .frame(width: 320, height: 400)
}
.menuBarExtraStyle(.window)
```

- Full SwiftUI layout in a floating window
- Set size via `.frame` on the root content view
- Dismiss by clicking outside or calling `MenuBarExtraAccess` dismiss action

---

## Dismiss from Inside Window Style

```swift
struct StatusView: View {
    @Environment(\.dismiss) private var dismiss  // closes the popover

    var body: some View {
        VStack {
            Text("Status")
            Button("Done") { dismiss() }
        }
        .frame(width: 320, height: 400)
    }
}
```

---

## LSUIElement — Hide Dock Icon

To run as a pure menu bar app with no Dock icon, add to `Info.plist`:

```xml
<key>LSUIElement</key>
<true/>
```

This also hides the app from the standard app switcher (Cmd+Tab). If combining with a `WindowGroup`, users can still access windows but the app won't appear in the Dock.

Alternatively, toggle at runtime:

```swift
NSApp.setActivationPolicy(.accessory)  // hide dock icon
NSApp.setActivationPolicy(.regular)    // show dock icon
```

---

## SMAppService — Launch at Login

```swift
import ServiceManagement

class LaunchAtLoginManager: ObservableObject {
    @Published var isEnabled: Bool {
        didSet { toggle(isEnabled) }
    }

    init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func toggle(_ enable: Bool) {
        do {
            if enable {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Launch at login error: \(error)")
        }
    }
}
```

Requires no helper app on macOS 13+. Status values: `.notRegistered`, `.enabled`, `.requiresApproval`, `.notFound`.

---

## Global Hotkeys

SwiftUI has no native global hotkey API. Use `NSEvent.addGlobalMonitorForEvents`:

```swift
class HotkeyManager {
    private var monitor: Any?

    func register() {
        monitor = NSEvent.addGlobalMonitorForEvents(
            matching: .keyDown
        ) { event in
            if event.modifierFlags.contains([.command, .shift]),
               event.keyCode == 49 {  // Space
                NotificationCenter.default.post(name: .toggleWindow, object: nil)
            }
        }
    }

    func unregister() {
        if let m = monitor { NSEvent.removeMonitor(m); monitor = nil }
    }
}
```

For production, prefer `MASShortcut` or `KeyboardShortcuts` (sindresorhus/KeyboardShortcuts) — they handle accessibility permissions and user-configurable bindings.

Sandbox note: global monitors require `com.apple.security.temporary-exception.mach-lookup.global-name` or accessibility permissions — prompt users with `AXIsProcessTrustedWithOptions`.

---

## Popover Sizing (Window Style)

Window-style `MenuBarExtra` sizes to content. Constrain with `.frame`:

```swift
MenuBarExtra("App", systemImage: "app") {
    ScrollView {
        VStack { ... }
    }
    .frame(width: 300, height: 440)  // fixed
    // or:
    .frame(minWidth: 280, maxWidth: 400, minHeight: 200, maxHeight: 600)
}
.menuBarExtraStyle(.window)
```

Avoid dynamic height changes mid-display — the popover doesn't animate resize.

---

## Combining with WindowGroup

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MainWindow()
        }
        .defaultSize(width: 900, height: 600)

        MenuBarExtra("Quick Access", systemImage: "bolt") {
            QuickMenu()
        }
        .menuBarExtraStyle(.window)
    }
}
```

Use `@Environment(\.openWindow)` in the menu to bring the main window forward:

```swift
Button("Open Main Window") {
    NSApplication.shared.activate(ignoringOtherApps: true)
    openWindow(id: "main")
}
```

---

## Common Pitfalls

- `.window` style MenuBarExtra clips content outside its frame — always set explicit `.frame`.
- `LSUIElement` prevents `NSApp.activate()` from working unless you call `NSApp.setActivationPolicy(.regular)` first.
- `SMAppService` only works for apps distributed via App Store or notarized direct distribution.
- Global `NSEvent` monitors silently fail without Accessibility permission — always check `AXIsProcessTrusted()`.
- Menu-style `MenuBarExtra` doesn't support `@State`-driven dynamic content well; use `.window` style for reactive UIs.
