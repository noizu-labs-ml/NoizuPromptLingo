import Cocoa
import ApplicationServices

/// Manages global hotkey registration and monitoring
///
/// Uses CGEventTap for blocking Cmd+Shift+T from reaching other apps.
/// Requires Accessibility permissions. Will prompt user if not granted.
class HotkeyManager {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var hotkeyCallback: (() -> Void)?

    /// Key code for Cmd+Shift+T (T key)
    private let commandKeyCode: CGKeyCode = 17
    /// Modifier flags for Cmd+Shift
    private let modifierFlags: CGEventFlags = [.maskCommand, .maskShift]

    /// Register the Cmd+Shift+T global hotkey
    /// - Parameter callback: Closure to execute when hotkey is pressed
    /// - Returns: True if registration succeeded, false otherwise
    func registerGlobalHotkey(callback: @escaping () -> Void) -> Bool {
        self.hotkeyCallback = callback

        // Request accessibility permissions first
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)

        if !accessEnabled {
            NSLog("⚠️ Accessibility permissions not granted. Please enable in System Settings > Privacy & Security > Accessibility.")
            return false
        }

        // Create event tap to intercept keyDown events
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else {
                    return Unmanaged.passRetained(event)
                }

                let manager = Unmanaged<HotkeyManager>.fromOpaque(refcon).takeUnretainedValue()

                // Check if this is Cmd+Shift+T
                if event.getIntegerValueField(.keyboardEventKeycode) == Int64(manager.commandKeyCode),
                   event.flags.contains(manager.modifierFlags) {
                    // Execute callback
                    manager.hotkeyCallback?()
                    // Block the event (return nil)
                    return nil
                }

                // Pass through all other events
                return Unmanaged.passRetained(event)
            },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )

        guard let eventTap = eventTap else {
            NSLog("❌ Failed to create event tap - may not have accessibility permissions")
            return false
        }

        // Add to run loop
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        NSLog("✅ Global hotkey Cmd+Shift+T registered via CGEventTap")
        return true
    }

    /// Unregister the global hotkey
    func unregisterGlobalHotkey() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            if let runLoopSource = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            }
            self.eventTap = nil
            self.runLoopSource = nil
        }
        hotkeyCallback = nil
    }

    deinit {
        unregisterGlobalHotkey()
    }
}