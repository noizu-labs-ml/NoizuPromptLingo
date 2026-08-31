import LLMToolkitKit
import SwiftUI

struct SidebarView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                WatchdogCompanionMark(size: 34)
                VStack(alignment: .leading, spacing: 1) {
                    Text("LLM Toolkit")
                        .font(.headline)
                        .foregroundStyle(Nocturne.textBright)
                    Text("agent-watch-dog")
                        .font(.caption2.monospaced())
                        .foregroundStyle(Nocturne.glow)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Nocturne.canvas)

            List(selection: selection) {
            Section {
                ForEach(SidebarItem.primary) { item in
                    row(item)
                }
            }
            Section("Library") {
                ForEach(SidebarItem.library) { item in
                    row(item)
                }
            }
            Section {
                ForEach(SidebarItem.utility) { item in
                    row(item)
                }
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(Nocturne.canvas)
        .safeAreaInset(edge: .bottom) {
            statusFooter
        }
        }
    }

    private var selection: Binding<SidebarItem?> {
        Binding(
            get: { model.route.sidebarItem == .styleGuide ? nil : model.route.sidebarItem },
            set: { item in
                if let item {
                    model.open(item)
                }
            }
        )
    }

    private func row(_ item: SidebarItem) -> some View {
        Label(item.title, systemImage: item.systemImage)
            .tag(item)
            .foregroundStyle(Nocturne.textPrimary)
    }

    private var statusFooter: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(model.health.summary)
                .font(.caption2)
                .foregroundStyle(Nocturne.textDim)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Nocturne.canvas)
        .overlay(alignment: .top) {
            Rectangle().fill(Nocturne.border).frame(height: 1)
        }
    }
}
