# AppKit Interoperability from SwiftUI

## When to Drop Down to AppKit

SwiftUI covers 90% of macOS UI needs. Use AppKit when:

| Need | AppKit API |
|------|-----------|
| Custom window chrome (titlebar, traffic lights) | `NSWindowDelegate`, `NSWindow` configuration |
| Access the key window or specific `NSWindow` | `NSApplication.shared.keyWindow` |
| NSPasteboard for custom clipboard types | `NSPasteboard` |
| File open/save panels with custom options | `NSOpenPanel`, `NSSavePanel` |
| Raw keyboard/mouse events | `NSEvent` |
| Custom cursor shapes | `NSCursor` |
| Web content | `WKWebView` via `NSViewRepresentable` |
| Any AppKit control without SwiftUI equivalent | `NSViewRepresentable` |

---

## NSViewRepresentable — Wrapping AppKit Views

The bridge protocol. Implement `makeNSView` (create once) and `updateNSView` (sync on state change).

```swift
struct WebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Page loaded")
        }
    }
}

// Use like any SwiftUI view
WebView(url: URL(string: "https://example.com")!)
    .frame(minWidth: 600, minHeight: 400)
```

**Coordinator pattern**: Use when the AppKit view needs a delegate. The coordinator is owned by the representable, bridging AppKit callbacks back to SwiftUI state.

---

## Accessing NSWindow from SwiftUI

SwiftUI doesn't expose `NSWindow` directly. Use a representable as a probe:

```swift
struct WindowAccessor: NSViewRepresentable {
    let onWindow: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                self.onWindow(window)
            }
        }
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = view.window {
                self.onWindow(window)
            }
        }
    }
}

// Usage — configure window from SwiftUI
ContentView()
    .background(
        WindowAccessor { window in
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.backgroundColor = .clear
        }
    )
```

---

## Custom Window Chrome

```swift
// In WindowGroup scene, use defaultWindowStyle
WindowGroup {
    ContentView()
}
.windowStyle(.hiddenTitleBar)  // Removes title, keeps traffic lights

// Via NSWindow (via WindowAccessor above)
window.titleVisibility = .hidden
window.titlebarAppearsTransparent = true
window.styleMask.insert(.fullSizeContentView)  // Content extends under titlebar

// Remove traffic light buttons entirely (rare — avoid unless building a panel)
window.standardWindowButton(.closeButton)?.isHidden = true
window.standardWindowButton(.miniaturizeButton)?.isHidden = true
window.standardWindowButton(.zoomButton)?.isHidden = true
```

---

## NSWindowDelegate — Window Lifecycle

```swift
class WindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // Save state before close
    }

    func windowDidBecomeKey(_ notification: Notification) {
        // Window gained focus
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Return false to prevent close (e.g., unsaved changes)
        return confirmClose()
    }

    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        // Constrain resize, e.g., maintain aspect ratio
        let ratio = 16.0 / 9.0
        return NSSize(width: frameSize.width, height: frameSize.width / ratio)
    }
}

// Attach via WindowAccessor
WindowAccessor { window in
    window.delegate = WindowDelegateHolder.shared
}
```

Store the delegate in a long-lived object — `NSWindow` holds a weak reference.

---

## NSHostingView — SwiftUI Inside AppKit

For AppKit-primary apps adopting SwiftUI piecemeal:

```swift
// Embed a SwiftUI view inside an AppKit hierarchy
let hostingView = NSHostingView(rootView: MySwiftUIView())
someNSView.addSubview(hostingView)
hostingView.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    hostingView.topAnchor.constraint(equalTo: someNSView.topAnchor),
    hostingView.leadingAnchor.constraint(equalTo: someNSView.leadingAnchor),
    hostingView.trailingAnchor.constraint(equalTo: someNSView.trailingAnchor),
    hostingView.bottomAnchor.constraint(equalTo: someNSView.bottomAnchor),
])

// Or create a full window with SwiftUI content
let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
    styleMask: [.titled, .closable, .resizable],
    backing: .buffered,
    defer: false
)
window.contentView = NSHostingView(rootView: MySwiftUIView())
window.makeKeyAndOrderFront(nil)
```

---

## NSEvent — Raw Input

```swift
// Local monitor — only fires when your app is key
NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
    if event.keyCode == 53 { // Escape
        handleEscape()
        return nil  // Consume the event
    }
    return event  // Pass through
}

// Global monitor — fires even when another app is key (requires Accessibility permission)
NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { event in
    handleGlobalClick(at: event.locationInWindow)
}

// In NSViewRepresentable, override in the view subclass
class EventView: NSView {
    override func keyDown(with event: NSEvent) {
        if event.characters == "f" && event.modifierFlags.contains(.command) {
            NotificationCenter.default.post(name: .triggerFind, object: nil)
        } else {
            super.keyDown(with: event)
        }
    }

    override var acceptsFirstResponder: Bool { true }
}
```

---

## NSPasteboard — Clipboard

```swift
// Write to clipboard
func copyToClipboard(_ text: String) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(text, forType: .string)
}

func copyImageToClipboard(_ image: NSImage) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.writeObjects([image])
}

// Read from clipboard
func pasteFromClipboard() -> String? {
    NSPasteboard.general.string(forType: .string)
}

// Custom type
let customType = NSPasteboard.PasteboardType("com.myapp.customdata")
NSPasteboard.general.clearContents()
NSPasteboard.general.setData(encodedData, forType: customType)
```

---

## NSOpenPanel / NSSavePanel

SwiftUI's `fileImporter`/`fileExporter` covers most cases. Use AppKit panels for advanced options:

```swift
// Open panel with custom configuration
func showOpenPanel() async -> [URL]? {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = true
    panel.canChooseDirectories = false
    panel.canChooseFiles = true
    panel.allowedContentTypes = [.image, .pdf]
    panel.message = "Select files to import"
    panel.prompt = "Import"

    let response = await panel.begin()
    return response == .OK ? panel.urls : nil
}

// Save panel
func showSavePanel(suggestedName: String) async -> URL? {
    let panel = NSSavePanel()
    panel.nameFieldStringValue = suggestedName
    panel.allowedContentTypes = [.json]
    panel.canCreateDirectories = true

    let response = await panel.begin()
    return response == .OK ? panel.url : nil
}
```
