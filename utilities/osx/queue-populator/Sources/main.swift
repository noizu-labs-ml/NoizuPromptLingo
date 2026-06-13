import Foundation
import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var coordinator: Coordinator?

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.applicationIconImage = queuePopulatorAppIcon(size: NSSize(width: 1024, height: 1024))
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let appConfig = parseArgs(CommandLine.arguments)

        if appConfig.authorize {
            Task { @MainActor in
                await requestPermissions()
                NSApp.terminate(nil)
            }
            return
        }

        let config = loadConfig()
        let coordinator = Coordinator(config: config, appConfig: appConfig)
        self.coordinator = coordinator
        coordinator.start()
    }
}

@MainActor
func run() {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
}

run()
