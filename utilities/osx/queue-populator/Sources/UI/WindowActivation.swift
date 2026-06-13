import AppKit

@MainActor
func showInteractiveWindow(_ window: NSWindow) {
    let app = NSApplication.shared
    app.activate(ignoringOtherApps: true)
    window.orderFrontRegardless()
    window.makeKeyAndOrderFront(nil)
    window.makeMain()
}
