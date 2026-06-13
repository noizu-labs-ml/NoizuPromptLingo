import Cocoa

/// Manages the menu bar status item, menu construction, and menu actions.
///
/// Accepts closures for actions that cross module boundaries (showing the
/// clipboard popup, quitting the app) so it never needs a direct reference
/// to PopupWindowManager or other managers.
final class MenuBarManager {

    // MARK: - Callbacks

    /// Called when the user clicks "Show Clipboard" or triggers its shortcut.
    var onShowClipboard: (() -> Void)?

    /// Called when the user clicks "Quit KopiGajj".
    var onQuit: (() -> Void)?

    // MARK: - Private state

    private var statusItem: NSStatusItem?

    // MARK: - Setup

    /// Create and install the menu bar status item and its dropdown menu.
    func install() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "KopiGajj")
            button.toolTip = "KopiGajj - Cmd+Shift+T"
        }

        statusItem?.menu = buildMenu()
    }

    // MARK: - Menu construction

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        // Hotkey hint (disabled label)
        let hotkeyItem = NSMenuItem(title: "Hotkey: Cmd+Shift+T", action: nil, keyEquivalent: "")
        hotkeyItem.isEnabled = false
        menu.addItem(hotkeyItem)

        menu.addItem(NSMenuItem.separator())

        // Show Clipboard
        let showItem = NSMenuItem(title: "Show Clipboard", action: #selector(showClipboard), keyEquivalent: "t")
        showItem.keyEquivalentModifierMask = [.command, .shift]
        showItem.target = self
        menu.addItem(showItem)

        menu.addItem(NSMenuItem.separator())

        // About & Quit
        let aboutItem = NSMenuItem(title: "About KopiGajj", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        let quitItem = NSMenuItem(title: "Quit KopiGajj", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    // MARK: - Actions

    @objc private func showClipboard() {
        onShowClipboard?()
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "KopiGajj"
        alert.informativeText = """
            Smart Clipboard Manager

            Press Cmd+Shift+T to access clipboard history.

            Version \(AppVersion.current) (\(AppVersion.stage))
            Metal: \(CanvasTheme.metalAvailable ? "active (runtime compute)" : "unavailable")
            """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func quitApp() {
        onQuit?()
    }

    // MARK: - Helpers

    /// Display a modal alert (warning style).
    static func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
