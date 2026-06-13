# NSWindow & Floating Window Management

**Last Updated:** 2026-03-04  
**Min Swift Version:** 5.9  
**Min macOS Version:** 14.0

## Quick Summary

`NSWindow` is the fundamental class for creating and managing windows in AppKit. For the Smart Clipboard project, we use NSWindow to create floating popup windows that appear above other applications when triggered by a global hotkey. Proper configuration of window levels, style masks, and behaviors ensures the popup behaves correctly across different screen configurations and macOS versions.

## Key APIs

| API | Purpose | File Location |
|-----|---------|---------------|
| `NSWindow.init(contentRect:styleMask:backing:defer:)` | Creates a new window with specified properties | `PopupWindowManager.swift` |
| `window.level = .floating` | Sets window to float above most other windows | `PopupWindowManager.swift` |
| `window.orderFrontRegardless()` | Brings window to front regardless of app state | `PopupWindowManager.swift` |
| `window.titlebarAppearsTransparent` | Makes title bar area transparent | `PopupWindowManager.swift` |
| `window.collectionBehavior` | Controls window behavior across spaces and fullscreen | `PopupWindowManager.swift` |
| `NSHostingView(rootView:)` | Embeds a SwiftUI view in an AppKit window | `PopupWindowManager.swift` |

## Code Examples

### Basic Floating Window (Swift 5.9+, macOS 14.0+)

```swift
import Cocoa
import SwiftUI

class PopupWindowManager: ObservableObject {
    @Published var isVisible = false
    private var popupWindow: NSWindow?
    
    func showPopup() {
        defer { isVisible = true }
        
        // Create window if needed
        if popupWindow == nil {
            createPopupWindow()
        }
        
        guard let window = popupWindow else { return }
        
        // Activate app and show window
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        window.center()
        window.orderFrontRegardless()
        window.makeKey()
        
        // Trigger accessibility focus
        window.makeFirstResponder(window.contentView)
    }
    
    func hidePopup() {
        guard let window = popupWindow else { return }
        
        window.orderOut(nil)
        NSApp.setActivationPolicy(.accessory)
        
        isVisible = false
    }
    
    private func createPopupWindow() {
        // Create the SwiftUI content view
        let contentView = HelloWorldView {
            self.hidePopup()
        }
        
        // Configure NSWindow
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Clipboard History"
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.titleVisibility = .hidden
        
        // Floating window level - stays above most other windows
        window.level = .floating
        
        // Customize window appearance
        window.backgroundColor = NSColor.windowBackgroundColor
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Embed SwiftUI view
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.autoresizingMask = [.width, .height]
        window.contentView = hostingView
        
        self.popupWindow = window
    }
}
```

### Custom Window Styling

```swift
private func createStyledPopupWindow() {
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
        styleMask: [.titled, .fullSizeContentView],
        backing: .buffered,
        defer: false
    )
    
    // Title bar configuration
    window.title = "Clipboard History"
    window.titlebarAppearsTransparent = true
    window.titleVisibility = .hidden
    window.isMovableByWindowBackground = true
    
    // Window level - determines Z-order
    window.level = .floating  // Above most apps
    
    // Collection behaviors
    window.collectionBehavior = [
        .canJoinAllSpaces,      // Available on all spaces
        .fullScreenAuxiliary    // Visible in fullscreen apps
    ]
    
    // Remove standard window controls
    if let closeButton = window.standardWindowButton(.closeButton) {
        closeButton.isHidden = true
    }
    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
    window.standardWindowButton(.zoomButton)?.isHidden = true
    
    // Custom styling with corner radius
    window.contentView?.wantsLayer = true
    window.contentView?.layer?.cornerRadius = 12
    
    // Background color
    window.backgroundColor = .windowBackgroundColor
}
```

### Window Positioning

```swift
func positionWindow() {
    guard let window = popupWindow else { return }
    
    // Center on screen
    window.center()
    
    // Or position relative to screen
    if let screen = NSScreen.main {
        let screenFrame = screen.visibleFrame
        let windowFrame = window.frame
        
        // Position at top-right corner with padding
        let x = screenFrame.maxX - windowFrame.width - 20
        let y = screenFrame.maxY - windowFrame.height - 80  // Below menu bar
        
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    // Ensure window is visible on current space
    window.orderFrontRegardless()
}
```

### Window Levels Hierarchy

```swift
// From lowest to highest Z-order:
.nsNormal        // Standard windows
.nsFloating      // Above normal windows (used for popups)
.nsModalPanel    // Modal windows
.nsMainMenu      // Menu bar
.nsStatus        // Status bar
.nsPopUpMenu     // Context menus
.nsOverlay       // Overlay windows (screenshots, etc.)
.nsScreenSaver   // Screen saver
.nsDock          // Dock

// Example: Set window level
window.level = .floating  // Clipboard popup
window.level = .modalPanel  // Dialogs
window.level = .screenSaver  // Absolute foreground
```

## Implementation Notes

### Gotchas

- **Window Levels Not Absolute Protection**: Even with `.floating` or `screenSaver` levels, some system windows and full-screen apps (e.g., Finder, Zoom) may still appear above your window. For truly robust positioning, consider `.popUpMenu` level.

- **Multiple Monitors**: Use `NSScreen.main?.visibleFrame` (not just `frame`) to respect the dock and menu bar positions on each monitor. Test positioning on multi-display setups.

- **Window Focus Issues**: When toggling between `.accessory` and `.regular` activation policies, you may need to explicitly call `NSApp.activate(ignoringOtherApps: true)` to ensure the window receives keyboard focus.

- **SwiftUI + NSWindow Integration**: Always use `NSHostingView` correctly sized with proper `autoresizingMask` to ensure the SwiftUI view resizes correctly when the window changes size.

- **Corner Radius Behavior**: Corner radius via `layer?.cornerRadius` only works when `wantsLayer = true`. Consider enabling this on the window's contentView before setting the radius.

- **Window Resizing**: Floating popups typically shouldn't be resizable. Add `.resizable` to `styleMask` if you need it, but consider hiding the resize indicator for a cleaner UI.

### Performance Considerations

- **Window Reuse vs Recreation**: For frequently shown popups, create the window once and reuse it. Recreating windows on every show/hide can cause visible lag.

- **Animation Considerations**: SwiftUI animations within the window (e.g., fade-in) interact with NSWindow animations. Test on older hardware for smoothness.

- **Layer Backing**: Setting `wantsLayer = true` enables Core Animation rendering, which is better for custom styling but has a small overhead. Use judiciously.

- **Ordering Window to Front**: `orderFrontRegardless()` is more expensive than `orderFront(nil)` but guarantees visibility. Use the latter when the app is already active.

### Threading

- **UI Thread Required**: All NSWindow operations must be performed on the main thread. Accessing or modifying windows from background threads can cause crashes or undefined behavior.

```swift
// Correct - on main thread
DispatchQueue.main.async {
    window.orderFrontRegardless()
}

// Incorrect - on background thread
DispatchQueue.global().async {
    window.orderFrontRegardless()  // Crash risk
}
```

- **SwiftUI View Updates**: SwiftUI state updates within an `NSHostingView` are automatically dispatched to the main thread, but avoid expensive computations in View `body` computations.

## References

- [NSWindow Class Reference - Apple Developer Documentation](https://developer.apple.com/documentation/appkit/nswindow)
- [NSWindow.Level - Apple Developer Documentation](https://developer.apple.com/documentation/appkit/nswindow/level)
- [NSWindow.StyleMask - Apple Developer Documentation](https://developer.apple.com/documentation/appkit/nswindow/stylemask)
- [NSWindow.CollectionBehavior - Apple Developer Documentation](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior)
- [NSHostingView - Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/nshostingview)
- [Window Programming Guide - Apple Developer Documentation](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/WinPanel/WinPanel.html)

## Version Notes

- **macOS 14.0 (Sonoma)**: 
  - New window appearance styles introduced for better integration with the redesigned window chrome
  - `NSWindow.styleMask.titled` behavior slightly changed in relation to the redesigned title bar
  - Improved performance for floating windows on Apple Silicon

- **macOS 13.0 (Ventura)**: 
  - New `.fullScreenAuxiliary` collection behavior flag for better fullscreen app integration
  - Redesigned window controls may affect styling
  - `window.titleVisibility` property is now preferred over hiding individual window buttons

- **macOS 12.0 (Monterey)**: 
  - `.canJoinAllSpaces` behavior improved for multi-monitor setups
  - Window animation timing updated for smoother transitions

- **macOS 11.0 (Big Sur)**: 
  - Introduced `.fullSizeContentView` style mask for full-width window content
  - New design language affected default window appearance

### Style Mask Combinations

```swift
// Common style mask combinations for different window types:

// Standard document window
let docWindow = NSWindow(
    styleMask: [.titled, .closable, .miniaturizable, .resizable],
    backing: .buffered,
    defer: false
)

// Floating palette (like our clipboard popup)
let popupWindow = NSWindow(
    styleMask: [.titled, .fullSizeContentView],
    backing: .buffered,
    defer: false
)

// Utility window
let utilityWindow = NSWindow(
    styleMask: [.utilityWindow, .titled, .closable],
    backing: .buffered,
    defer: false
)

// Borderless window
let borderlessWindow = NSWindow(
    styleMask: [.borderless],
    backing: .buffered,
    defer: false
)
```

<!-- nav -->

---

[< Previous: NSEvent & Global Key Monitoring](01-nsevent-global-monitoring.md) | [Table of Contents](../../product-spec.md) | [Next: NSApplication & Activation Policy >](03-nsapplication-activation-policy.md)

<!-- nav -->
