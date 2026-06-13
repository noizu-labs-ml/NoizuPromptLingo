# Background Daemon Lifecycle for macOS Applications

## Overview

A background daemon (or helper) in macOS allows an application to perform tasks without requiring user interaction or a visible interface. For a clipboard manager, this is essential for monitoring clipboard changes continuously even when the main app is not visible.

## Core Concepts

- **Activation Policy**: Controls how the app appears in the system (dock icon, menu bar)
- **Lifecycle States**: Running, sleeping, suspended, terminated
- **Background Modes**: Capabilities for background work (location, audio downloads, etc.)
- **Launch Agents**: System mechanisms for auto-launching background processes
- **App Kit Delegates**: NSApplicationDelegate for lifecycle management

## Key APIs and Frameworks

| API/Framework | Purpose |
|--------------|---------|
| `NSApplication` | Main application instance |
| `NSApplicationDelegate` | Application lifecycle callbacks |
| `NSApplication.SetActivationPolicy` | Control dock/menu presence |
| `NSWorkspace` | System notification and interaction |
| `NSDistributedNotificationCenter` | Cross-process notifications |
| `RunLoops` | Keep background process alive |

## Swift Code Examples

### Basic Background Daemon Structure

```swift
import Cocoa
import AppKit

@main
struct ClipboardDaemon {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate

        // Set activation policy to accessory (no dock icon)
        app.setActivationPolicy(.accessory)

        // Run the app
        app.run()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var clipboardMonitor: ClipboardMonitor?
    private var hotkeyManager: HotkeyManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupDaemon()
    }

    private func setupDaemon() {
        // Initialize services
        clipboardMonitor = ClipboardMonitor()
        clipboardMonitor?.start()

        hotkeyManager = HotkeyManager()
        hotkeyManager?.register()

        // Register for system notifications
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(didWakeFromSleep),
            name: NSWorkspace.screensDidWakeNotification,
            object: nil
        )
    }

    @objc private func didWakeFromSleep() {
        // Restart monitoring after sleep
        clipboardMonitor?.restart()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup
        clipboardMonitor?.stop()
        hotkeyManager?.unregister()
    }
}
```

### Menu Bar Helper with Background Daemon

```swift
import Cocoa
import SwiftUI

@main
struct ClipboardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            MenuBarView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var daemon: ClipboardDaemonService?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        startDaemon()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard")
        }

        // Setup menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show History", action: #selector(showHistory), keyEquivalent: "v"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    private func startDaemon() {
        daeMON = ClipboardDaemonService()
        daemon?.start()
    }

    @objc private func showHistory() {
        notifyPopupWindow(toShow: true)
    }

    @objc private func showPreferences() {
        openPreferencesWindow()
    }

    @objc private func quit() {
        daemon?.stop()
        NSApp.terminate(nil)
    }
}

class ClipboardDaemonService {
    private var clipboardMonitor: ClipboardMonitor?
    private var isRunning = false

    func start() {
        guard !isRunning else { return }

        clipboardMonitor = ClipboardMonitor()
        clipboardMonitor?.onNewClipboard { [weak self] item in
            self?.processNewItem(item)
        }

        clipboardMonitor?.start()
        isRunning = true
    }

    func stop() {
        clipboardMonitor?.stop()
        clipboardMonitor = nil
        isRunning = false
    }

    private func processNewItem(_ item: ClipboardItem) {
        // Save to database, update UI state, etc.
        Database.shared.save(item)
        notifyUIIfNeeded(item)
    }

    private func notifyUIIfNeeded(_ item: ClipboardItem) {
        // Only notify if appropriate (e.g., not for system-generated content)
        guard !item.isSystemGenerated else { return }

        NotificationCenter.default.post(
            name: .clipboardDidUpdate,
            object: item
        )
    }
}
```

### XPC Service Architecture (Modern Approach)

```swift
import Foundation
import AppKit

// Main App
@main
struct ClipboardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var xpcServiceConnection: NSXPCConnection?

    func applicationDidFinishLaunching(_ notification: Notification) {
        connectToXPCService()
        setupMenuBar()
    }

    private func connectToXPCService() {
        let connection = NSXPCConnection(serviceName: "com.yourapp.ClipboardDaemon")

        connection.remoteObjectInterface = NSXPCInterface(with: ClipboardDaemonProtocol.self)

        connection.interruptionHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.handleXPCDisconnect()
            }
        }

        connection.invalidationHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.handleXPCDisconnect()
            }
        }

        connection.resume()
        self.xpcServiceConnection = connection

        // Start monitoring
        service?.startMonitoring { [weak self] item in
            self?.handleNewItem(item)
        }
    }

    private var service: ClipboardDaemonProtocol? {
        xpcServiceConnection?.remoteObjectProxy as? ClipboardDaemonProtocol
    }

    private func handleNewItem(_ item: ClipboardItem) {
        // Update UI
        // Save to database
    }

    private func handleXPCDisconnect() {
        // Handle disconnect/reconnect logic
    }

    private func setupMenuBar() {
        // Setup menu bar UI
    }
}

// XPC Service Protocol
@objc protocol ClipboardDaemonProtocol: NSObjectProtocol {
    func startMonitoring(callback: @escaping (ClipboardItem) -> Void)
    func stopMonitoring()
    func getClipboardHistory() -> [ClipboardItem]
}

// XPC Service Implementation
class ClipboardDaemon: NSObject, ClipboardDaemonProtocol {
    private var clipboardMonitor: ClipboardMonitor?
    private var callback: ((ClipboardItem) -> Void)?

    func startMonitoring(callback: @escaping (ClipboardItem) -> Void) {
        self.callback = callback

        clipboardMonitor = ClipboardMonitor()
        clipboardMonitor?.onChange { [weak self] in
            if let item = self?.getCurrentItem() {
                DispatchQueue.main.async {
                    callback(item)
                }
            }
        }

        clipboardMonitor?.start()
    }

    func stopMonitoring() {
        clipboardMonitor?.stop()
        callback = nil
    }

    func getClipboardHistory() -> [ClipboardItem] {
        return Database.shared.fetchAll()
    }

    private func getCurrentItem() -> ClipboardItem? {
        // Get current clipboard content
        return nil
    }
}
```

### Process Lifecycle Management

```swift
import Cocoa

class ProcessManager {
    private var monitor: ClipboardMonitor?
    private var timer: Timer?
    private var isRunning = false

    func start() {
        guard !isRunning else { return }

        // Start clipboard monitoring
        monitor = ClipboardMonitor()
        monitor?.start()

        // Set up periodic tasks
        setupPeriodicTasks()

        // Register for sleep/wake notifications
        setupSleepWakeObservers()

        isRunning = true
    }

    func stop() {
        monitor?.stop()
        monitor = nil

        timer?.invalidate()
        timer = nil

        NSWorkspace.shared.notificationCenter.removeObserver(self)

        isRunning = false
    }

    private func setupPeriodicTasks() {
        // Run cleanup every hour
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.performMaintenance()
        }
    }

    private func performMaintenance() {
        // Cleanup old clipboard items
        Database.shared.cleanup(before: Date().addingTimeInterval(-7 * 86400) // 7 days)

        // Compact database
        Database.shared.vacuum()
    }

    private func setupSleepWakeObservers() {
        let workspace = NSWorkspace.shared.notificationCenter

        workspace.addObserver(
            self,
            selector: #selector(willSleep),
            name: NSWorkspace.willPowerOffNotification,
            object: nil
        )

        workspace.addObserver(
            self,
            selector: #selector(didWake),
            name: NSWorkspace.screensDidWakeNotification,
            object: nil
        )

        workspace.addObserver(
            self,
            selector: #selector(sessionDidResign),
            name: NSWorkspace.sessionDidResignActiveNotification,
            object: nil
        )
    }

    @objc private func willSleep() {
        monitor?.pause()
    }

    @objc private func didWake() {
        monitor?.resume()
    }

    @objc private func sessionDidResign() {
        // User switched accounts/screens
        monitor?.pause()
    }
}
```

### App Switch Detection

```swift
import Cocoa

class AppSwitchManager {
    private var currentAppURL: URL?
    private var observer: NSObjectProtocol?

    func startMonitoring() {
        // Get current app
        currentAppURL = NSWorkspace.shared.frontmostApplication?.bundleURL

        // Observe changes
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
                return
            }
            self?.handleAppSwitch(to: app)
        }
    }

    func stopMonitoring() {
        if let observer = observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }

    private func handleAppSwitch(to app: NSRunningApplication) {
        let previousAppURL = currentAppURL
        currentAppURL = app.bundleURL

        // Check if switching to/from specific apps
        if let previous = previousAppURL {
            // Log clipboard usage per app
            logClipboardUsage(from: previous, to: app.bundleURL)
        }

        // App-specific behavior
        handleAppSpecificBehavior(app)
    }

    private func logClipboardUsage(from: URL?, to: URL?) {
        // Track clipboard usage patterns across apps
        // This can be used for intelligent prediction
    }

    private func handleAppSpecificBehavior(_ app: NSRunningApplication) {
        let appId = app.bundleIdentifier ?? ""

        switch appId {
        case "com.apple.finder":
            // Handle Finder app
            break
        case "com.apple.Safari", "com.google.Chrome":
            // Handle browsers
            break
        default:
            break
        }
    }
}
```

## Implementation Considerations

### Memory Management
Background daemons must be careful about memory:
- Avoid unbounded growth of clipboard history
- Implement size limits and cleanup strategies
- Release references to large data (images) when not needed

```swift
class CLiIPBOARDStorage {
    private var items: [ClipboardItem] = []
    private let maxItems = 100
    private let maxMemoryMB = 100

    func add(_ item: ClipboardItem) {
        items.append(item)

        // Enforce item limit
        if items.count > maxItems {
            items.removeFirst(items.count - maxItems)
        }

        // Enforce memory limit (for images)
        if items.reduce(into: 0) { $0 += $1.estimatedSizeMB } > maxMemoryMB {
            cleanupLargeItems()
        }
    }
}
```

### Run Loop Management
For background XPC services:

```swift
// In main()
let service = ClipboardDaemonService()
service.start()

// Keep run loop alive (XPC services handle this automatically)
// For helper processes:
RunLoop.main.run()
```

### Threading Considerations
- Clipboard operations should be on main thread (NSPasteboard requirement)
- Database operations should be on background queue
- UI updates must be on main thread

## Potential Pitfalls to Avoid

### 1. Incorrect Activation Policy

```swift
// BAD - Regular policy creates dock icon
app.setActivationPolicy(.regular)

// GOOD - Accessory for background utilities
app.setActivationPolicy(.accessory)
```

### 2. Not Handling Sleep/Suspend

```swift
// BAD - Monitoring continues through sleep
monitor.start()

// GOOD - Pause during sleep
func applicationWillSleep() {
    monitor.pause()
}

func applicationDidWake() {
    monitor.resume()
}
```

### 3. Memory Leaks with Timer Retain Cycles

```swift
// BAD - Timer retains self, creating cycle
class Manager {
    var timer: Timer?

    func start() {
        timer = Timer.scheduledTimer(...) { [self] _ in // Retain cycle
            // ...
        }
    }
}

// GOOD - Use weak capture
timer = Timer.scheduledTimer(...) { [weak self] _ in
    self?.doWork()
}
```

### 4. Not Respecting User Sessions

```swift
// BAD - Continues running on screen lock/sleep
let timer = Timer(...)

// GOOD - Stop on session change
observer = NotificationCenter.default.addObserver(
    forName: NSWorkspace.screensDidSleepNotification,
    object: nil,
    queue: .main
) { [weak self] _ in
    self?.pauseWork()
}
```

### 5. Blocking Main Thread

```swift
// BAD - Heavy work blocks event loop
func processNewClipboard() {
    heavyDatabaseOperation() // Blocks
}

// GOOD - Offload background work
func processNewClipboard() {
    DispatchQueue.global().async {
        let result = heavyDatabaseOperation()
        DispatchQueue.main.async {
            self.updateUI(with: result)
        }
    }
}
```

## Apple Documentation References

- [NSApplication](https://developer.apple.com/documentation/appkit/nsapplication)
- [NSApplicationDelegate](https://developer.apple.com/documentation/appkit/nsapplicationdelegate)
- [NSWorkspace](https://developer.apple.com/documentation/appkit/nsworkspace)
- [XPC Services](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html)
- [Background Execution](https://developer.apple.com/library/archive/documentation/IPhone/Conceptual/iPhoneOSProgrammingGuide/BackgroundExecution/BackgroundExecution.html)

## Best Practices Summary

1. **Use Accessory Activation**: No dock icon for background utilities
2. **Handle Sleep/Wake**: Pause/resume appropriately
3. **Clean Up Resources**: Deinit observers, timers, connections
4. **Memory Limits**: Bound clipboard history size
5. **Offload Heavy Work**: Use background queues for I/O
6. **Respect User Session**: Stop when locked/sleeping
7. **Use XPC Services**: Separate privileged operations
8. **Monitor Battery**: Reduce activity on battery
9. **Graceful Shutdown**: Handle termination signals
10. **Log Errors**: Track failures for debugging without logs

<!-- nav -->

---

[< Previous: SwiftUI Popup Modal Window Patterns for Overlay UI](03-swiftui-popup.md) | [Table of Contents](../../product-spec.md) | [Next: Clipboard Type Detection >](05-clipboard-types.md)

<!-- nav -->
