# NSEvent & Global Key Monitoring

**Last Updated:** 2026-03-04  
**Min Swift Version:** 5.9  
**Min macOS Version:** 14.0

## Quick Summary

`NSEvent` provides access to system-wide input events, including keyboard, mouse, and other user actions. The global monitoring APIs (`addGlobalMonitorForEvents`) enable applications to detect keyboard shortcuts (hotkeys) outside of their own windows. This is essential for background utilities like Smart Clipboard that need to respond to global shortcuts like `Cmd+Shift+T`.

## Key APIs

| API | Purpose | File Location |
|-----|---------|---------------|
| `NSEvent.addGlobalMonitorForEvents(matching:handler:)` | Registers a block to receive global key events | `HotkeyManager.swift` |
| `NSEvent.removeMonitor(_:)` | Removes a previously registered event monitor | `HotkeyManager.swift` |
| `event.keyCode` | Returns the raw key code of the event | `HotkeyManager.swift` |
| `event.modifierFlags` | Returns the modifier flags (Cmd, Shift, etc.) | `HotkeyManager.swift` |
| `AXIsProcessTrustedWithOptions(_:)` | Checks/prompts for Accessibility permissions | `HotkeyManager.swift` |

## Code Examples

### Basic Usage (Swift 5.9+, macOS 14.0+)

```swift
import Cocoa

class GlobalHotkeyManager: ObservableObject {
    @Published var isActive: Bool = false
    private var eventMonitor: Any?
    private var hotkeyCallback: (() -> Void)?
    
    // Key code for Cmd+Shift+T (V key)
    private let commandKeyCode: UInt16 = 9
    
    func registerGlobalHotkey(callback: @escaping () -> Void) -> Bool {
        self.hotkeyCallback = callback
        
        // Request accessibility permissions with system prompt
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        guard accessEnabled else {
            NSLog("Accessibility permissions not granted")
            return false
        }
        
        // Register global monitor for key down events
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        
        isActive = eventMonitor != nil
        return isActive
    }
    
    func unregisterGlobalHotkey() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        hotkeyCallback = nil
        isActive = false
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        // Check for Cmd+Shift+T combination
        let desiredModifiers: NSEvent.ModifierFlags = [.command, .shift]
        let relevantFlags = event.modifierFlags.intersection([.command, .shift, .control, .option])
        
        if event.keyCode == commandKeyCode && relevantFlags == desiredModifiers {
            hotkeyCallback?()
        }
    }
    
    deinit {
        unregisterGlobalHotkey()
    }
}
```

### Common Key Codes

```swift
// Common virtual key codes used in NSEvent
private let keyCodes: [UInt16: String] = [
    0: "A",
    1: "S",
    2: "D",
    3: "F",
    4: "H",
    5: "G",
    6: "Z",
    7: "X",
    8: "C",
    9: "V",      // Cmd+Shift+T in our project
    11: "B",
    12: "Q",
    13: "W",
    14: "E",
    15: "R",
    16: "Y",
    17: "T",
    31: "O",
    32: "U",
    34: "I",
    35: "P",
    37: "L",
    38: "J",
    39: "'",
    40: "K",
    41: ";",
    42: "\\",
    43: ",",
    44: "/",
    45: "N",
    46: "M",
    47: ".",
    50: "`",
    53: "Escape",
    123: "Arrow Left",
    124: "Arrow Right",
    125: "Arrow Down",
    126: "Arrow Up",
    36: "Return",
    48: "Tab",
    51: "Delete",
    49: "Space"
]
```

## Implementation Notes

### Gotchas

- **Accessibility Permissions Required**: Global event monitoring requires Accessibility permissions (`kAXTrustedCheckOptionPrompt`). The system will prompt the user, and the app must be in System Settings > Privacy & Security > Accessibility.

- **Key Codes are Layout-Independent**: `event.keyCode` returns the physical key's virtual code, which is the same across different keyboard layouts. This means "V" on a QWERTY keyboard has the same code as the equivalent key on a Dvorak keyboard.

- **Modifier Flags Include More Than Expected**: `event.modifierFlags` often includes flags like `.capsLock` or `.numericPad`. Always filter to only the relevant modifiers when checking.

- **NSResponder Event Override**: Use `NSEvent.addLocalMonitorForEvents(matching:)` if you only want to intercept events within your app. Global monitors won't see events that have been handled by other responders.

- **Multiple Monitors on Same Events**: You can register multiple monitors for the same event type. Each will receive the event independently.

### Performance Considerations

- **Minimal Handler Execution**: Keep the event handler as lightweight as possible. The handler runs on the main event loop, so expensive operations will block the entire UI.

- **Use `[weak self]` in Closures**: Always capture self weakly to avoid retain cycles, especially since event monitors can outlive the registering object.

- **Unregister When Not Needed**: Always remove monitors when they're no longer needed to prevent unnecessary event handling overhead.

- **Debounce Rapid Events**: If handling rapid key presses, consider debouncing to avoid triggering callbacks multiple times quickly.

### Threading

- **Main Thread Required**: Event handlers are called on the main thread. Any UI updates must happen here. If you need to perform background work, dispatch to a background queue:

```swift
NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
    // Always on main thread
    DispatchQueue.global(qos: .userInitiated).async {
        // Heavy processing here
    }
}
```

- **Avoid Blocking Operations**: Since the handler runs on the main thread, avoid blocking operations. Use async/await or background queues for heavy work.

## References

- [NSEvent Class Reference - Apple Developer Documentation](https://developer.apple.com/documentation/appkit/nsevent)
- [Accessibility Services - Apple Developer Documentation](https://developer.apple.com/documentation/applicationservices/1515904-axisprocesstrustedwithoptions)
- [NSEvent.EventTypeMask Enumeration - Apple Developer Documentation](https://developer.apple.com/documentation/appkit/nsevent/eventtypemask)
- [Handling Keyboard and Mouse Events - Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/keyboard-and-mouse)

## Version Notes

- **macOS 15.0 (Sonoma)**: No breaking changes to NSEvent global monitoring. Continue to require Accessibility permissions.

- **macOS 14.0 (Ventura)**: No significant changes to NSEvent APIs. Accessibility permission prompts are now in System Settings > Privacy & Security (previously System Preferences > Security & Privacy).

- **macOS 13.0 (Monterey)**: No breaking changes. Same APIs apply.

- **macOS 12.0 (Big Sur)**: No breaking changes to global event monitoring.

- **macOS 11.0 (Catalina)**: Enhanced permission prompts for Accessibility features. Users now receive clearer instructions on how to grant permissions.

### Key Code Constants

The project uses key codes defined in [HIToolbox/Events.h](https://developer.apple.com/documentation/hitoolbox/keyboard_layout_services):

```c
// From HIToolbox/Events.h
enum {
  kVK_V = 9,
  kVK_Return = 36,
  kVK_Tab = 48,
  kVK_Space = 49,
  kVK_Escape = 53,
  // ... many more
};
```

<!-- nav -->

---

[< Previous: Technical Documentation Guidelines](GUIDELINES.md) | [Table of Contents](../../product-spec.md) | [Next: NSWindow & Floating Window Management >](02-nswindow-floating-windows.md)

<!-- nav -->
