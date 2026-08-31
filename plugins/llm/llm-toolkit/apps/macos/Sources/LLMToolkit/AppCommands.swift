import LLMToolkitKit
import SwiftUI

struct AppCommands: Commands {
    @FocusedValue(\.appModel) private var model

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Reload Console") {
                model?.reloadConsole()
            }
            .keyboardShortcut("r", modifiers: [.command])

            Button("Open in Browser") {
                model?.revealInBrowser()
            }
            .keyboardShortcut("o", modifiers: [.command, .shift])
        }

        CommandMenu("Go") {
            destination("Explore", item: .explore, key: "1")
            destination("Safety Watch", item: .safetyWatch, key: "2")
            destination("Datasets", item: .datasets, key: "3")
            destination("Prompts", item: .prompts, key: "4")
            destination("Tags", item: .tags, key: "5")
            destination("Projects", item: .projects, key: "6")
            destination("Settings", item: .settings, key: "7")
            destination("Style Guide", item: .styleGuide, key: "8")
        }

        CommandMenu("Harness") {
            ForEach(Harness.allCases) { harness in
                Button(harness.title) {
                    model?.harness = harness
                }
            }
        }

        CommandMenu("Conversation") {
            Button("View Thread") { model?.openThreadAction(.view) }
                .disabled(model?.canOperateOnThread != true)
            Button("Edit Thread") { model?.openThreadAction(.edit) }
                .keyboardShortcut("e", modifiers: [.command])
                .disabled(model?.canOperateOnThread != true)
            Button("Convert…") { model?.openThreadAction(.convert) }
                .keyboardShortcut("k", modifiers: [.command, .shift])
                .disabled(model?.canOperateOnThread != true)
            Button("Continue Session") { model?.openThreadAction(.continueSession) }
                .disabled(model?.canOperateOnThread != true)
            Divider()
            Button("Clone Thread") {
                Task { await model?.cloneCurrentThread() }
            }
            .disabled(model?.canOperateOnThread != true)
            Button("Archive Thread") {
                Task { await model?.archiveCurrentThread() }
            }
            .disabled(model?.canOperateOnThread != true)
        }

        CommandMenu("Index") {
            Button("Rebuild Index") {
                Task { await model?.rebuildIndex() }
            }
            Button("Start Local Console") {
                Task { await model?.startServers() }
            }
        }
    }

    @ViewBuilder
    private func destination(_ title: String, item: SidebarItem, key: Character) -> some View {
        Button(title) {
            model?.open(item)
        }
        .keyboardShortcut(KeyEquivalent(key), modifiers: [.command])
    }
}

private struct AppModelKey: FocusedValueKey {
    typealias Value = AppModel
}

extension FocusedValues {
    var appModel: AppModel? {
        get { self[AppModelKey.self] }
        set { self[AppModelKey.self] = newValue }
    }
}
