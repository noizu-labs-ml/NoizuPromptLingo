# SwiftUI Popup Modal Window Patterns for Overlay UI

## Overview

SwiftUI provides several approaches for creating popup and modal windows in macOS applications. For a clipboard manager, the typical pattern involves showing a floating window triggered by a global hotkey that overlays all other applications.

## Core Concepts

- **Window Management**: Controlling window appearance, positioning, and ordering
- **Presentation Styles**: Different ways to show overlays (modal, popover, floating)
- **Z-Ordering**: Controlling window stacking relative to other apps
- **Activation**: Managing focus and activation state
- **Animation**: Smooth transitions for showing/hiding windows

## Key APIs and Frameworks

| API/Framework | Purpose |
|--------------|---------|
| `SwiftUI.Window` | Window container |
| `NSWindow` | Native window control (via NSViewRepresentable) |
| `NSWindow.Level` | Window z-ordering/level |
| `NSColor.SeparatingWindowLevel` | Special window levels |
| `NSPanel` | Panel/utility windows |
| `NSPopover` | Popover presentation |
| `NSApplication.shared.activate` | App activation management |

## Swift Code Examples

### Basic Floating Window

```swift
import SwiftUI
import AppKit

struct ClipboardPopupView: View {
    @State private var isVisible = false
    @State private var clipHistory: [ClipboardItem] = []

    var body: some View {
        ZStack {
            if isVisible {
                FloatingPanelWindow(items: clipHistory, onClose: { self.isVisible = false })
                    .frame(minWidth: 400, minHeight: 300)
            }
        }
        .onAppear {
            setupWindow()
        }
    }

    private func setupWindow() {
        if let window = NSApplication.shared.windows.first {
            window.makeKeyAndOrderFront(nil)
            window.level = .floating
            window.isMovableByWindowBackground = true
            window.styleMask = [.titled, .closable, .resizable]
        }
    }

    func showPopup() {
        isVisible = true
        activateAppAndWindow()
    }

    private func activateAppAndWindow() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
```

### NSWindow Wrapper (NSViewRepresentable)

```swift
import SwiftUI
import AppKit

struct FloatingWindowView: NSViewRepresentable {
    let isVisible: Bool
    let onClose: () -> Void
    let content: AnyView

    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        // Create window controller
        let windowController = NSWindowController()

        // Configure window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.title = "Clipboard History"
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.isReleasedWhenClosed = false

        // Set content view
        let hostingView = NSHostingView(rootView: content)
        hostingView.autoresizingMask = [.width, .height]
        window.contentView = hostingView

        // Store reference in context
        context.coordinator.window = window
        context.coordinator.windowController = windowController

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if isVisible {
            // Center and show window
            if let window = context.coordinator.window {
                window.center()
                window.orderFrontRegardless()
                window.makeKey()
                NSApp.activate(ignoringOtherApps: true)
            }
        } else {
            // Hide window
            context.coordinator.window?.orderOut(nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onClose: onClose)
    }

    class Coordinator {
        var window: NSWindow?
        var windowController: NSWindowController?
        let onClose: () -> Void

        init(onClose: @escaping () -> Void) {
            self.onClose = onClose
        }
    }
}
```

### Panel-Style Window (NSPanel)

```swift
import SwiftUI
import AppKit

struct ClipboardPanelView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var panel: NSPanel?

    var body: some View {
        VStack {
            Text("Clipboard Panel")
                .font(.headline)
                .padding()

            Divider()

            List {
                ForEach(clips) { clip in
                    ClipboardItemRow(item: clip)
                        .onTapGesture {
                            copyToClipboard(clip)
                            dismiss()
                        }
                }
            }

            Divider()

            HStack {
                Button("Close", role: .cancel) {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
            .padding()
        }
        .frame(width: 500, height: 600)
        .onAppear {
            setupPanelStyle()
        }
    }

    private func setupPanelStyle() {
        // Get current window and convert to panel style
        DispatchQueue.main.async {
            if let window = NSApp.keyWindow {
                window.makeKey()
                window.level = .floating
                window.styleMask = [.titled, .closable, .resizable]
                window.titlebarAppearsTransparent = true
                window.isMovableByWindowBackground = true
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

                // Hide standard buttons
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
            }
        }
    }

    private func clips: [ClipboardItem] {
        // TODO: Fetch from clipboard manager
        return []
    }

    private func copyToClipboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
    }
}
```

### Menu Bar Style Popup

```swift
import SwiftUI
import AppKit

@main
struct ClipboardMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
}

struct ClipboardPopupMenu: Scene {
    var body: some Scene {
        Settings {
            AppMenuView()
        }
    }
}

struct AppMenuView: View {
    @State private var clipboardHistory: [ClipboardItem] = []
    @State private var showWindow = false

    var body: some View {
        Menu {
            Button(action: showFloatingWindow) {
                Label("Show Clipboard History", systemImage: "doc.on.clipboard")
            }
            .keyboardShortcut("v", modifiers: [.command, .shift])

            Divider()

            Button("Preferences") {
                openPreferences()
            }

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            Image(systemName: "doc.on.clipboard")
        }
        .menuStyle(.borderlessButton)
        .frame(width: 30)
        .onAppear {
            setupMenuBar()
        }
        .sheet(isPresented: $showWindow) {
            ClipboardWindowView(isPresented: $showWindow, items: clipboardHistory)
        }
    }

    private func setupMenuBar() {
        // Additional setup if needed
    }

    private func showFloatingWindow() {
        showWindow = true
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func openPreferences() {
        // Open preferences window
    }
}
```

### Advanced: Floating Window with Positioning

```swift
import SwiftUI
import AppKit

class ClipboardPopupWindow: NSWindow {
    init(contentView: AnyView, position: NSPoint) {
        super.init(
            contentRect: NSRect(origin: position, size: NSSize(width: 400, height: 500)),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        self.title = ""
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.backgroundColor = .clear

        let hostingView = NSHostingView(rootView: contentView)
        self.contentView = hostingView

        customizeWindow()
    }

    private func customizeWindow() {
        // Hide title bar buttons
        if let closeButton = standardWindowButton(.closeButton) {
            closeButton.isHidden = true
        }
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true

        // Enable rounded corners
        contentView?.wantsLayer = true
        contentView?.layer?.cornerRadius = 12
    }

    func showAnimated(at position: NSPoint? = nil) {
        if let position = position {
            setFrameOrigin(position)
        }

        self.alphaValue = 0
        self.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.animator().alphaValue = 1
        }
    }

    func hideAnimated(completion: @escaping () -> Void) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            context.completionHandler = completion
            self.animator().alphaValue = 0
        }
    }
}
```

### Window Manager for Lifecycle

```swift
import SwiftUI
import AppKit

class PopupWindowManager: ObservableObject {
    @Published var isVisible = false
    private var popupWindow: ClipboardPopupWindow?

    func showPopup(content: [ClipboardItem]) {
        // Calculate position (center of current screen)
        guard let screen = NSScreen.main else { return }
        let screenRect = screen.visibleFrame
        let position = NSPoint(
            x: screenRect.midX - 200,
            y: screenRect.midY - 250
        )

        // Create or update window
        if popupWindow == nil {
            popupWindow = ClipboardPopupWindow(
                contentView: AnyView(ClipboardListView(items: content, onSelect: { item in
                    self.hidePopup()
                    self.copyItem(item)
                })),
                position: position
            )
        }

        // Show window
        activateAppAndShowWindow()
    }

    func hidePopup() {
        popupWindow?.hideAnimated {
            self.popupWindow?.orderOut(nil)
            self.isVisible = false
            NSApp.setActivationPolicy(.accessory)
        }
    }

    private func activateAppAndShowWindow() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        popupWindow?.showAnimated()
        isVisible = true
    }

    private func copyItem(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
    }
}

struct ClipboardListView: View {
    let items: [ClipboardItem]
    let onSelect: (ClipboardItem) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 1) {
                    ForEach(items) { item in
                        ClipboardItemRow(item: item)
                            .onTapGesture {
                                onSelect(item)
                            }
                    }
                }
            }
        }
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
        .frame(width: 400, height: 500)
    }

    struct HeaderView: View {
        var body: some View {
            HStack {
                Text("Clipboard History")
                    .font(.headline)
                Spacer()
                Button(action: {
                    // Clear history
                }) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
        }
    }
}
```

## Implementation Considerations

### Window Levels
Use appropriate `NSWindow.Level` values:
- `.floating`: Above most windows, useful for overlays
- `.popUpMenu`: Higher than normal windows
- `.modalPanel`: For modal dialogs
- `.screenSaver`: Above almost everything (use carefully)

### Activation Policy
- `.regular`: Normal app with dock icon
- `.accessory`: Menu bar utility, no dock icon
- `.prohibited`/: Hidden app

```swift
// For background clipboard manager
NSApp.setActivationPolicy(.accessory)

// When showing popup
NSApp.setActivationPolicy(.regular)
NSApp.activate(ignoringOtherApps: true)

// When hiding popup
NSApp.setActivationPolicy(.accessory)
```

### Blur and Visual Effects
```swift
// Add vibrancy/blur
var body: some View {
    VStack {
        // Content
    }
    .background(
        VisualEffectView(material: .hudWindow)
            .cornerRadius(12)
    )
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.state = .active
        view.isEmphasized = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
```

## Potential Pitfalls to Avoid

### 1. Window Not Appearing on Top

```swift
// BAD - Default window level
window.level = .normal

// GOOD - Set appropriate level
window.level = .floating
// Or higher if needed
// window.level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
```

### 2. App Not Activating Properly

```swift
// BAD - Window shown but app not active
window.orderFront(nil)

// GOOD - Show window and activate app
NSApp.setActivationPolicy(.regular)
NSApp.activate(ignoringOtherApps: true)
window.orderFront(nil)
```

### 3. Memory Leaks with Window References

```swift
// BAD - Strong reference cycle
class Manager {
    var window: NSWindow?

    func createWindow() {
        window = NSWindow() // Captures self
    }
}

// GOOD - Use weak references or cleanup
class Manager {
    weak var window: NSWindow?

    func createWindow() {
        let window = NSWindow()
        self.window = window
        // Ensure cleanup on close
        window.isReleasedWhenClosed = true
    }
}
```

### 4. Wrong Activation Policy

```swift
// BAD - Regular policy for background daemon
NSApp.setActivationPolicy(.regular) // Shows dock icon always

// GOOD - Accessory policy for utilities
NSApp.setActivationPolicy(.accessory) // No dock icon

// Switch when needed
// Show popup
NSApp.setActivationPolicy(.regular)

// Hide popup and go back to background
NSApp.setActivationPolicy(.accessory)
```

### 5. Focus Management Issues

```swift
// BAD - Doesn't handle Escape key
struct ContentView: View {
    var body: some View {
        VStack {
            // Content
        }
    }
}

// GOOD - Handle keyboard dismissal
struct ContentView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            // Content
        }
        .focusable()
        .onKeyPress(.escape) { _ in
            dismiss()
            return .handled
        }
    }
}
```

## Apple Documentation References

- [NSWindow](https://developer.apple.com/documentation/appkit/nswindow)
- [NSWindow.Panel](https://developer.apple.com/documentation/appkit/nspanel)
- [NSWindow.Level](https://developer.apple.com/documentation/appkit/nswindow/level)
- [NSApplication](https://developer.apple.com/documentation/appkit/nsapplication)
- [Windows and Tabs](https://developer.apple.com/documentation/appkit/nswindowstylemask)
- [SwiftUI Window Management](https://developer.apple.com/documentation/swiftui/window)

## Best Practices Summary

1. **Use Floating Level**: Set window level to `.floating` for overlays
2. **Activate App**: Call `NSApp.activate(ignoringOtherApps: true)` when showing
3. **Handle Escape Key**: Provide easy dismissal with ⌘+Escape
4. **Use Blur Effect**: Add vibrancy for modern macOS look
5. **Position Carefully**: Center on current screen
6. **Animate Transitions**: Smooth fade/slide animations
7. **Clean Up Resources**: Remove windows properly when not needed
8. **Test Fullscreen**: Ensure popup works in fullscreen apps
9. **Dark Mode Support**: Respect dark mode appearance
10. **Accessibility**: Support keyboard navigation and VoiceOver

<!-- nav -->

---

[< Previous: Global Hotkey Implementation](02-global-hotkeys.md) | [Table of Contents](../../product-spec.md) | [Next: Background Daemon Lifecycle for macOS Applications >](04-background-daemon.md)

<!-- nav -->
