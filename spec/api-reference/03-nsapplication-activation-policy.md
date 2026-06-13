# NSApplication & Activation Policy

**Last Updated:** 2026-03-04
**Min Swift Version:** 5.9
**Min macOS Version:** 14.0

## Quick Summary

`NSApplication` is the central class for managing the application's lifecycle and behavior. The `ActivationPolicy` determines whether the app appears in the Dock, has a menu bar when active, and how it behaves when losing focus. For background utilities like Smart Clipboard, toggling between `.accessory` and `.regular` policies enables showing a popup on-demand while staying hidden otherwise.

## Key APIs

| API | Purpose | File Location |
|-----|---------|---------------|
| `NSApplication.shared` | Returns the shared application instance | `main.swift` |
| `NSApplication.setActivationPolicy(_:)` | Sets the app's activation policy | `AppDelegate.swift`, `main.swift` |
| `NSApplication.activate(ignoringOtherApps:)` | Brings the app to the foreground | `PopupWindowManager.swift` |
| `NSApplication.ActivationPolicy` | Enumeration defining activation policies | `AppDelegate.swift`, `main.swift` |
| `NSApplicationDelegate` | Protocol for app lifecycle events | `AppDelegate.swift` |
| `applicationDidFinishLaunching(_:)` | Called when app is ready | `AppDelegate.swift` |
| `applicationWillTerminate(_:)` | Called before app terminates | `AppDelegate.swift` |

## Code Examples

### Application Setup with Activation Policy (Swift 5.9+, macOS 14.0+)

```swift
import Cocoa
import SwiftUI

let app = NSApplication.shared
app.setActivationPolicy(.accessory)  // Start as background app

let appDelegate = AppDelegate()
app.delegate = appDelegate

app.run()

// AppDelegate.swift
class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotkeyManager: HotkeyManager?
    private var popupManager: PopupWindowManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("PasteBin app starting...")

        // Create and configure managers
        let popupManager = PopupWindowManager()
        self.popupManager = popupManager

        let hotkeyManager = HotkeyManager()
        self.hotkeyManager = hotkeyManager

        // Register global hotkey
        let success = hotkeyManager.registerGlobalHotkey { [weak self] in
            self?.handleHotkeyPress()
        }

        if success {
            NSLog("Global hotkey Cmd+Shift+T registered successfully")
        } else {
            showAlert(title: "Accessibility Required",
                      message: "Please enable Accessibility permissions in System Settings.")
        }

        // Ensure app stays in background
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup before termination
        hotkeyManager?.unregisterGlobalHotkey()
    }

    private func handleHotkeyPress() {
        popupManager?.togglePopup()
    }
}
```

### Activation Policy Toggling

```swift
// When showing popup
func showPopup() {
    // Switch to regular to allow window interaction
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)

    // Show window
    window.orderFrontRegardless()
    window.makeKey()
}

// When hiding popup
func hidePopup() {
    // Hide window
    window.orderOut(nil)

    // Switch back to accessory (background mode)
    NSApp.setActivationPolicy(.accessory)
}

// Toggle function
func togglePopup() {
    let isVisible = window.isVisible

    if isVisible {
        hidePopup()
    } else {
        showPopup()
    }
}
```

### Activation Policies Explained

```swift
// 1. Regular - Standard app with Dock icon and menu bar
NSApp.setActivationPolicy(.regular)
// - App appears in Dock
// - Menu bar shows app name
// - App can be active/inactive
// - Standard behavior for most apps

// 2. Accessory - Background app with menu bar only
NSApp.setActivationPolicy(.accessory)
// - No Dock icon
// - Menu bar shows when active
// - Can become active to show windows
// - Used for menu bar apps, utilities

// 3. Prohibited - No UI at all
NSApp.setActivationPolicy(.prohibited)
// - No Dock icon, no menu bar
// - Cannot become active
// - Used for daemons, background services

// Checking current policy
let currentPolicy = NSApp.activationPolicy()
print("Current policy: \(currentPolicy)")
```

### Application Delegate Lifecycle

```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    // Called after app launch completes
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize components
        setupManagers()
        registerHotkeys()
        loadPreferences()
    }

    // Called when app is about to become active
    func applicationWillBecomeActive(_ notification: Notification) {
        // Prepare for user interaction
        refreshData()
        updateUI()
    }

    // Called when app loses focus
    func applicationWillResignActive(_ notification: Notification) {
        // Clean up when user switches away
        saveTemporaryState()
    }

    // Called when app is about to terminate
    func applicationWillTerminate(_ notification: Notification) {
        // Final cleanup
        unregisterHotkeys()
        closeNetworkConnections()
        saveUserData()
    }

    // Called when system wakes from sleep
    func applicationDidBecomeActive(_ notification: Notification) {
        // Optional: handle wake events
    }

    // Query whether app should terminate on last window close
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Return false to keep app running after all windows close
        // Useful for background utilities
        return false
    }
}
```

### Application Termination Handling

```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Opportunity to cancel or delay termination

        // Check if there's unsaved work
        if hasUnsavedChanges() {
            // Show alert to user
            let response = showSavePrompt()
            if response == .cancel {
                // Cancel termination
                return .terminateCancel
            } else if response == .save {
                saveChanges()
            }
        }

        // Proceed with cleanup
        performCleanup()

        // Allow termination to proceed
        return .terminateNow
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSLog("App terminating, performing final cleanup...")
        hotkeyManager?.unregisterGlobalHotkey()

        // Save any remaining state
        UserDefaults.standard.synchronize()
    }
}
```

## Implementation Notes

### Gotchas

- **Policy Change Timing**: Changing activation policy can be visually jarring. Always change policy after hiding/showing windows to minimize visual disruption.

- **Accessory Policy Activation**: When using `.accessory` mode, you must call `activate(ignoringOtherApps:)` when showing windows, or they won't receive keyboard focus.

- **Menu Bar Appearance**: With `.accessory` policy, the menu bar only shows when the app is active. Configure your main menu to show only relevant menu items for the accessory mode.

- **Dock Icon Not Updating**: The Dock icon may not immediately appear/disappear when switching policies. This is a known limitation; the behavior is usually correct after a brief delay.

- **Termination on Window Close**: By default, apps with `.regular` policy terminate when all windows close. Override `applicationShouldTerminateAfterLastWindowClosed(_:)` to return `false` for background utilities.

- **First Window Show after Accessory Policy**: When switching from `.accessory` to `.regular`, the first window shown may not appear before the Dock icon. Consider pre-creating windows or using `orderFrontRegardless()`.

### Performance Considerations

- **Policy Switch Costs**: Changing activation policy is a relatively expensive operation that updates the Dock and menu bar state. Avoid frequent toggles (e.g., more than once per second).

- **Startup Performance**: Setting `.accessory` policy at startup is faster than setting `.regular`, as it avoids registering with the Dock.

- **Memory in Background**: Apps with `.accessory` policy are still subject to memory management. The system may terminate your app under memory pressure, especially if it has no windows visible.

- **Cleanup on Termination**: Always perform cleanup in `applicationWillTerminate(_:)` rather than relying on `deinit`, as the latter may not be called.

### Threading

- **UI Thread Required**: All NSApplication operations must be on the main thread. Changing activation policy from a background thread can cause crashes or undefined behavior.

```swift
// Correct - main thread
DispatchQueue.main.async {
    NSApp.setActivationPolicy(.regular)
}

// Incorrect - background thread
DispatchQueue.global().async {
    NSApp.setActivationPolicy(.regular)  // Crash risk
}
```

- **Delegate Methods**: All application delegate methods are called on the main thread. Avoid blocking operations in these methods that could freeze the UI.

## References

- [NSApplication Class Reference - Apple Developer Documentation](https://developer.apple.com/documentation/appkit/nsapplication)
- [NSApplication.ActivationPolicy - Apple Developer Documentation](https://developer.apple.com/documentation/appkit/nsapplication/activationpolicy)
- [NSApplicationDelegate Protocol - Apple Developer Documentation](https://developer.apple.com/documentation/appkit/nsapplicationdelegate)
- [App Programming Guide for macOS - Apple Developer Documentation](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CocoaApplicationsGuide/)
- [Running and Terminating Your App - Apple Developer Documentation](https://developer.apple.com/documentation/uikit/app_and_scenes/managing_the_life_cycle_of_your_app)

## Version Notes

- **macOS 14.0 (Sonoma)**:
  - Activation policy behavior unchanged
  - Improved handling of policy transitions with reduced visual flickering
  - Better performance for apps switching frequently between policies

- **macOS 13.0 (Ventura)**:
  - No breaking changes to NSApplication or ActivationPolicy
  - Introduction of Stage Manager may affect window ordering, but activation policy behavior remains consistent

- **macOS 12.0 (Monterey)**:
  - No significant changes to activation policy behavior
  - Improved animation smoothness when switching between policies

- **macOS 11.0 (Big Sur)**:
  - Redesigned Dock appearance, but activation policy behavior unchanged
  - `.accessory` apps may appear slightly differently in the redesigned menu bar

### Choosing the Right Activation Policy

```swift
// Decision guide for activation policy selection:

// Use .regular when:
// - App needs a Dock icon
// - App has multiple windows or documents
// - App should be a primary focus app
// - App needs full menu bar integration

// Use .accessory when:
// - App is a utility or tool
// - App shouldn't appear in Dock
// - App is controlled by hotkeys or menu bar
// - App shows windows only in response to user action

// Use .prohibited when:
// - App is a background service
// - App has no UI
// - App should never become active
// - App is a daemon or background process
```

### Complete Application Structure

```swift
// main.swift - Application entry point
import Cocoa

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let appDelegate = AppDelegate()
app.delegate = appDelegate

app.run()

// AppDelegate.swift
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // App initialization
        setupComponents()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup
        cleanupComponents()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false  // Keep running in background
    }

    private func setupComponents() {
        // Initialize managers
    }

    private func cleanupComponents() {
        // Clean up resources
    }
}
```

<!-- nav -->

---

[< Previous: NSWindow & Floating Window Management](02-nswindow-floating-windows.md) | [Table of Contents](../../product-spec.md) | [Next: SwiftUI View Lifecycle & State >](04-swiftui-view-lifecycle.md)

<!-- nav -->
