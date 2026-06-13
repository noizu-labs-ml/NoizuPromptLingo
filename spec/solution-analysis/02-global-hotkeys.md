# Global Hotkey Implementation

## Overview

Global hotkeys allow macOS applications to respond to keyboard shortcuts even when not in focus. This is essential for clipboard managers, screenshot tools, and other utilities triggered by quick actions.

## Core Concepts

- **Global Event Monitoring**: Intercepting keyboard events system-wide
- **Carbon Event Manager**: Legacy C API for hotkey registration
- **NSEvent API**: Higher-level Cocoa API for event monitoring
- **Key Codes**: Unique integers identifying physical keys
- **Modifiers**: Shift, Control, Option, Command flags

## Key APIs and Frameworks

| API/Framework | Purpose | Notes |
|--------------|---------|-------|
| `NSEvent` | Event monitoring | Modern, Cocoa-based |
| `Carbon Event Manager` | Low-level event handling | Legacy, C-based |
| `CGEventTap` | Low-level event interception | System event filtering |
| `EventKit` | Event handling | Higher level |

## Swift Code Examples

### NSEvent Global Monitor (Recommended)

```swift
import Cocoa

class GlobalHotkeyManager {
    private var monitor: Any?

    func startMonitoring(commandKey: Int = 9, // 'V' key
                        modifierFlags: NSEvent.ModifierFlags = [.command, .shift],
                        callback: @escaping () -> Void) {

        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            // Check if key and modifiers match
            if event.keyCode == UInt16(commandKey) &&
               event.modifierFlags == modifierFlags {
                callback()
            }
        }
    }

    func stopMonitoring() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
```

### Carbon Event Manager (Legacy, More Reliable)

```swift
import Cocoa

class CarbonHotkeyManager {
    typealias EventHotKeyRef = UInt32

    private var hotKeyRef: EventHotKeyRef = 0
    private var hotkeyCallback: (() -> Void)?

    // Carbon event type
    struct EventHotKeyID {
        var signature: OSType
        var id: UInt32
    }

    struct EventHotKeyEntry {
        var hotKeyID: EventHotKeyID
        var spec: EventHotKeySpec
    }

    func registerHotkey(
        keyCode: UInt32,
        modifiers: UInt32,
        signature: OSType = 0x48454C50, // 'HELP'
        id: UInt32 = 1,
        callback: @escaping () -> Void
    ) -> Bool {
        self.hotkeyCallback = callback

        var eventType = EventTypeSpec(eventClass: OSType(4), eventKind: OSType(10))

        // Install event handler
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
                guard let userData = userData else { return noErr }
                let manager = Unmanaged<CarbonHotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.hotkeyCallback?()
                return noErr
            },
            1,
            &eventType,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            nil
        )

        guard status == noErr else { return false }

        // Register hotkey
        var hotKeyEntry = EventHotKeyEntry(
            hotKeyID: EventHotKeyID(signature: signature, id: id),
            spec: EventHotKeySpec(modifiers: modifiers, keyCode: keyCode)
        )

        let registerStatus = RegisterEventHotKey(
            hotKeyEntry.spec.keyCode,
            hotKeyEntry.spec.modifiers,
            hotKeyEntry.hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        return registerStatus == noErr
    }

    func unregisterHotkey() {
        if hotKeyRef != 0 {
            UnregisterEventHotKey(hotKeyRef)
            hotKeyRef = 0
        }
    }
}
```

### CGEventTap Approach

```swift
import Cocoa

class CGEventTapManager {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var callback: (() -> Void)?

    func startMonitoring(
        keyCode: CGKeyCode = 9, // 'V'
        modifiers: CGEventFlags = [.maskCommand, .maskShift],
        callback: @escaping () -> Void
    ) -> Bool {
        self.callback = callback

        let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else {
                    return Unmanaged.passRetained(event)
                }

                let manager = Unmanaged<CGEventTapManager>.fromOpaque(refcon).takeUnretainedValue()

                // Check if key matches
                if event.getIntegerValueField(.keyboardEventKeycode) == Int64(keyCode) &&
                   event.flags.contains(modifiers) {
                    manager.callback?()
                    // Prevent the key press from being passed through
                    return nil
                }

                return Unmanaged.passRetained(event)
            },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )

        guard let eventTap = eventTap else {
            return false
        }

        self.eventTap = eventTap

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        self.runLoopSource = runLoopSource

        return true
    }

    func stopMonitoring() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            if let runLoopSource = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            }
            self.eventTap = nil
            self.runLoopSource = nil
        }
    }
}
```

### Helper: Key Code Constants

```swift
import Cocoa

enum KeyCode: UInt16 {
    case a = 0
    case s = 1
    case d = 2
    case f = 3
    case h = 4
    case g = 5
    case z = 6
    case x = 7
    case c = 8
    case v = 9
    case b = 11
    case q = 12
    case w = 13
    case e = 14
    case r = 15
    case y = 16
    case t = 17
    case o = 31
    case u = 32
    case i = 34
    case p = 35
    case l = 37
    case j = 38
    case k = 40
    case n = 45
    case m = 46
    case comma = 43
    case period = 47
    case quote = 39
    case openBracket = 33
    case closeBracket = 30
    case backslash = 42
    case backtick = 50
    case returnKey = 36
    case tab = 48
    case space = 49
    case delete = 51
    case escape = 53
    case command = 55
    case shift = 56
    case capsLock = 57
    case option = 58
    case control = 59
    case function = 63
    case f1 = 122
    case f2 = 120
    case f3 = 99
    case f4 = 118
    case f5 = 96
    case f6 = 97
    case f7 = 98
    case f8 = 100
    case f9 = 101
    case f10 = 109
    case f11 = 103
    case f12 = 111
    case upArrow = 126
    case downArrow = 125
    case leftArrow = 123
    case rightArrow = 124
    case pageUp = 116
    case pageDown = 121
    case home = 115
    case end = 119
    case forwardDelete = 117
}

enum ModifierFlag {
    case command
    case shift
    case control
    case option

    var carbonValue: UInt32 {
        switch self {
        case .command: return 256
        case .shift: return 512
        case .control: return 4096
        case .option: return 2048
        }
    }

    var nsEventValue: NSEvent.ModifierFlags {
        switch self {
        case .command: return .command
        case .shift: return .shift
        case .control: return .control
        case .option: return .option
        }
    }

    var cgeventValue: CGEventFlags {
        switch self {
        case .command: return .maskCommand
        case .shift: return .maskShift
        case .control: return .maskControl
        case .option: return .maskAlternate
        }
    }
}
```

### Complete Hotkey Manager

```swift
import Cocoa

class HotkeyManager: ObservableObject {
    @Published var isActive: Bool = false

    private var carbonManager: CarbonHotkeyManager?
    private var nseventMonitor: Any?

    func register(commandKey: KeyCode = .v,
                  modifiers: [ModifierFlag] = [.command, .shift],
                  action: @escaping () -> Void) -> Bool {

        // Try Carbon first (more reliable globally)
        let carbonManager = CarbonHotkeyManager()
        let carbonModifiers = modifiers.reduce(UInt32(0)) { $0 + $1.carbonValue }

        if carbonManager.registerHotkey(
            keyCode: UInt32(commandKey.rawValue),
            modifiers: carbonModifiers,
            callback: action
        ) {
            self.carbonManager = carbonManager
            isActive = true
            return true
        }

        // Fallback to NSEvent
        let nsModifiers = modifiers.reduce(NSEvent.ModifierFlags()) { $0.union($1.nsEventValue) }

        nseventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == commandKey.rawValue &&
               event.modifierFlags.intersection([.command, .shift, .control, .option]) == nsModifiers {
                action()
            }
        }

        isActive = true
        return true
    }

    func unregister() {
        carbonManager?.unregisterHotkey()
        carbonManager = nil

        if let monitor = nseventMonitor {
            NSEvent.removeMonitor(monitor)
            nseventMonitor = nil
        }

        isActive = false
    }
}
```

## Implementation Considerations

### Accessibility Permissions
Global event monitoring requires accessibility permissions from the user. macOS will prompt the user:
- In System Settings > Privacy & Security > Accessibility
- Application must be added to the list

### Key Code Mappings
- Key codes correspond to physical keyboard positions, not characters
- Different keyboard layouts may map differently
- Always test with expected user keyboard layouts

### Modifier Key Conflicts
- System-level hotkeys (Cmd+Tab, Cmd+Space) cannot be overridden
- Other apps may have same hotkeys
- Provide customization options for users

### Threading
- Event callbacks may be triggered on background threads
- Dispatch UI updates to main thread

```swift
dispatchAction: { [weak self] in
    DispatchQueue.main.async {
        self?.showPopup()
    }
}
```

## Potential Pitfalls to Avoid

### 1. Not Requesting Accessibility Permissions

```swift
// BAD - Will fail silently without permissions
nseventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
    // This won't work without accessibility permissions
}

// GOOD - Check permissions or guide user
func setupHotkey() {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
    let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)

    if !accessEnabled {
        // Show user instructions for enabling accessibility
        showAlertPleaseEnableAccessibility()
    }

    nseventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
        // Now this should work
    }
}
```

### 2. Memory Leaks with Monitors

```swift
// BAD - Never removes monitor, potential leak
func start() {
    self.monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { _ in
        // Handler
    }
}

// GOOD - Clean up properly
deinit {
    if let monitor = monitor {
        NSEvent.removeMonitor(monitor)
    }
}
```

### 3. Incorrect Modifier Flags

```swift
// BAD - Doesn't account for extra modifiers
if event.modifierFlags == .command {
    // Won't match if user has Shift pressed too
}

// GOOD - Check exact combinations or use intersection
if event.modifierFlags.contains(.command) {
    // Matches regardless of other modifiers
}

// Or for exact match:
let desiredFlags: NSEvent.ModifierFlags = [.command, .shift]
let relevantFlags = event.modifierFlags.intersection([.command, .shift, .control, .option])
if relevantFlags == desiredFlags {
    // Exact match
}
```

### 4. Blocking Event Handling

```swift
// BAD - Long-running operation blocks event loop
callback = {
    heavyProcessingFunction() // Takes seconds
    // Events aren't monitored during this time
}

// GOOD - Offload heavy work
callback = {
    DispatchQueue.global().async {
        let result = heavyProcessingFunction()
        DispatchQueue.main.async {
            self.showResult(result)
        }
    }
}
```

### 5. Multiple Conflicting Key Handlers

```swift
// BAD - Multiple handlers for same key
NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
    if event.keyCode == 9 { /* First handler */ }
}
NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
    if event.keyCode == 9 { /* Second handler */ }
}

// GOOD - Single handler with routing
class HotkeyRouter {
    private var handlers: [String: () -> Void] = [:]

    func register(key: KeyCode, modifiers: [ModifierFlag], action: @escaping () -> Void) {
        let keyString = "\(key.rawValue)-\(modifiers)"
        handlers[keyString] = action
    }

    func start() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.route(event)
        }
    }

    func route(_ event: NSEvent) {
        let keyString = "\(event.keyCode)-\(event.modifierFlags)"
        handlers[keyString]?()
    }
}
```

## Apple Documentation References

- [NSEvent](https://developer.apple.com/documentation/appkit/nsevent)
- [Carbon Event Manager Reference](https://developer.apple.com/documentation/carbon/1445986-carbon_event_manager)
- [CGEventTap](https://developer.apple.com/documentation/coregraphics/cgeventtap)
- [Accessibility](https://developer.apple.com/documentation/accessibility)
- [Event Handling Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/Introduction/Introduction.html)

## Best Practices Summary

1. **Request Permissions Early**: Ask for accessibility access at first use
2. **Provide Fallbacks**: Try multiple approaches for hotkey detection
3. **Allow Customization**: Let users change hotkeys to avoid conflicts
4. **Clean Up Resources**: Always remove monitors when not needed
5. **Use Weak References**: Avoid retain cycles in closures
6. **Test Edge Cases**: User with different keyboard layouts, other apps blocking
7. **Dispatch to Main Thread**: Update UI on main thread only
8. **Handle Errors Gracefully**: Permission denied, system conflicts, etc.
9. **Document Hotkeys**: Clearly show users available hotkeys in settings
10. **Consider Privacy**: Be transparent about global event monitoring

<!-- nav -->

---

[< Previous: NSPasteboard API Usage and Best Practices](01-nspasteboard-api.md) | [Table of Contents](../../product-spec.md) | [Next: SwiftUI Popup Modal Window Patterns for Overlay UI >](03-swiftui-popup.md)

<!-- nav -->
