import LLMToolkitKit
import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 228, max: 280)
        } detail: {
            ZStack {
                ConsoleWebView(
                    baseURL: model.preferences.apiURL,
                    route: model.route,
                    harness: model.harness,
                    nativeChrome: model.preferences.useNativeChrome,
                    reloadToken: model.reloadToken,
                    onRoute: { model.applyRoute($0) },
                    onHarness: { model.harness = $0 }
                )
                .background(Nocturne.surface)
                .opacity(model.health.isReady ? 1 : 0)

                if !model.health.isReady {
                    StartingOverlay()
                }
            }
        }
        .navigationTitle(model.route.title)
        .toolbar { toolbar }
        .background(Nocturne.void)
        .focusedSceneValue(\.appModel, model)
        .task {
            model.start()
        }
        .onDisappear {
            model.stop()
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        @Bindable var model = model
        ToolbarItemGroup(placement: .navigation) {
            Picker("Harness", selection: $model.harness) {
                ForEach(Harness.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 320)
        }
        ToolbarItem(placement: .principal) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Nocturne.textMuted)
                TextField("Search conversations…", text: $model.searchText)
                    .textFieldStyle(.plain)
                    .frame(minWidth: 220)
                    .onSubmit { model.searchFromToolbar() }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Nocturne.void, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Nocturne.border, lineWidth: 1)
            )
        }
        ToolbarItemGroup(placement: .primaryAction) {
            indexBadge
            Button("Reload", systemImage: "arrow.clockwise") {
                model.reloadConsole()
            }
            .help("Reload")
        }
    }

    private var indexBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(model.health.apiOK ? Nocturne.success : Nocturne.danger)
                .frame(width: 7, height: 7)
            Text(model.health.indexStatus.map { $0.capitalized } ?? (model.health.apiOK ? "Ready" : "Starting"))
                .font(.caption)
                .foregroundStyle(Nocturne.textMuted)
        }
        .help(model.health.summary)
    }
}
