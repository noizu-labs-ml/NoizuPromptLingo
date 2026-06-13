import Cocoa

/// Application delegate for the KopiGajj app
///
/// Manages app lifecycle, hotkey management, and popup coordination.
/// Menu bar concerns are delegated to MenuBarManager; rendering pre-warm
/// is handled by RenderingBootstrap.
class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotkeyManager: HotkeyManager?
    private var popupManager: PopupWindowManager?
    private var menuBarManager: MenuBarManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("📋 KopiGajj app starting...")

        // Create managers
        let popupManager = PopupWindowManager()
        self.popupManager = popupManager

        let hotkeyManager = HotkeyManager()
        self.hotkeyManager = hotkeyManager

        // Register global hotkey (Cmd+Shift+T)
        let success = hotkeyManager.registerGlobalHotkey { [weak self] in
            self?.handleHotkeyPress()
        }

        if success {
            NSLog("✅ Global hotkey Cmd+Shift+T registered successfully")
        } else {
            MenuBarManager.showAlert(
                title: "Accessibility Required",
                message: "Please enable Accessibility permissions in System Settings > Privacy & Security > Accessibility, then restart this app."
            )
        }

        // Pre-warm canvas texture and Metal compute pipeline
        RenderingBootstrap.prewarm()

        // Setup menu bar
        let menuBar = MenuBarManager()
        menuBar.onShowClipboard = { [weak popupManager] in
            popupManager?.showPopup()
        }
        menuBar.onQuit = {
            NSApp.terminate(nil)
        }
        menuBar.install()
        self.menuBarManager = menuBar

        // Set app as accessory (runs in background with menu bar only)
        NSApp.setActivationPolicy(.accessory)

        // Show popup immediately on launch (dev mode)
        popupManager.showPopup()

        NSLog("🎯 KopiGajj ready - press Cmd+Shift+T to show popup")
        NSLog("🎨 Metal: \(CanvasTheme.metalAvailable ? "active (runtime compute)" : "unavailable")")
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSLog("👋 KopiGajj terminating...")
        hotkeyManager?.unregisterGlobalHotkey()
    }

    /// Handle Cmd+Shift+T hotkey press
    private func handleHotkeyPress() {
        popupManager?.togglePopup()

        if popupManager?.isVisible == true {
            NSLog("📝 Popup shown")
        } else {
            NSLog("🔒 Popup hidden")
        }
    }
}