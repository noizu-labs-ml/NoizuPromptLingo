import SwiftUI

// MARK: - Config Section UI

/// Reserved name for the built-in factory defaults theme.
let defaultThemeName = "Default"

/// Theme picker and save/delete controls.
struct CanvasConfigSection: View {
    @EnvironmentObject var tuning: CanvasTuningState

    @Binding var savedConfigs: [String]
    @Binding var selectedConfig: String
    @Binding var newConfigName: String
    @Binding var showSaveField: Bool

    var onLoadTheme: (String) -> Void
    var onSaveNewConfig: () -> Void
    var onRefreshConfigList: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Theme")
                    .font(.system(size: 11, weight: .medium))

                Picker("", selection: $selectedConfig) {
                    ForEach(savedConfigs, id: \.self) { name in
                        Text(name).tag(name)
                    }
                }
                .frame(maxWidth: 160)
                .onChange(of: selectedConfig) { _, name in
                    onLoadTheme(name)
                }

                Button {
                    showSaveField.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 12))
                }

                if selectedConfig != defaultThemeName {
                    Button {
                        try? CanvasConfigStore.save(tuning.asConfig, name: selectedConfig)
                    } label: {
                        Image(systemName: "arrow.down.doc")
                            .font(.system(size: 12))
                    }

                    Button {
                        try? CanvasConfigStore.delete(selectedConfig)
                        selectedConfig = defaultThemeName
                        onRefreshConfigList()
                        onLoadTheme(defaultThemeName)
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                    }
                }
            }

            if showSaveField {
                HStack {
                    TextField("Theme name", text: $newConfigName)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 160)
                        .onSubmit { onSaveNewConfig() }

                    Button("Save") { onSaveNewConfig() }
                        .disabled(newConfigName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Config Management Helpers

/// Ensures the Default theme exists on disk.
func ensureDefaultThemeExists() {
    if CanvasConfigStore.load(defaultThemeName) == nil {
        try? CanvasConfigStore.save(.default, name: defaultThemeName)
    }
}

/// Returns the full sorted config list with Default always first.
func refreshedConfigList() -> [String] {
    var list = CanvasConfigStore.list()
    if let idx = list.firstIndex(of: defaultThemeName) {
        list.remove(at: idx)
    }
    list.insert(defaultThemeName, at: 0)
    return list
}
