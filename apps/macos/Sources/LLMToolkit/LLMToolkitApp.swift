import LLMToolkitKit
import SwiftUI

@main
struct LLMToolkitApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(model)
                .preferredColorScheme(.dark)
        }
        .defaultSize(width: 1440, height: 900)
        .windowToolbarStyle(.unified)
        .commands {
            AppCommands()
        }

        Settings {
            SettingsView()
                .environment(model)
                .preferredColorScheme(.dark)
                .frame(minWidth: 520, minHeight: 420)
        }
    }
}
