import AppKit

@MainActor
final class ProbeApp: NSObject, NSApplicationDelegate {
    private var item: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.isVisible = true
        item.button?.title = "PROBE"
        item.button?.image = nil
        item.button?.toolTip = "Menu Probe"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Menu Probe Worked", action: nil, keyEquivalent: ""))
        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit Probe", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quit)
        item.menu = menu

        self.item = item
        fputs("menu-only-probe: status item installed\n", stderr)
    }
}

@MainActor
func runProbe() {
    let app = NSApplication.shared
    let delegate = ProbeApp()
    app.delegate = delegate
    app.run()
}

await runProbe()
