import Foundation
import AppKit

@MainActor
func run() async {
    let app = NSApplication.shared
    app.setActivationPolicy(.regular)

    let appConfig = parseArgs(CommandLine.arguments)

    if appConfig.authorize {
        await requestPermissions()
        exit(0)
    }

    let config = loadConfig()
    let coordinator = Coordinator(config: config, appConfig: appConfig)
    coordinator.start()

    app.run()
}

await run()
