import SwiftUI

@main
struct TheRobotPaintsApp: App {
    init() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    var body: some Scene {
        WindowGroup {
            CanvasView()
                .frame(minWidth: 800, minHeight: 700)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
