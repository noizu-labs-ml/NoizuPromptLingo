import SwiftUI

// MARK: - Paint Filter Section

struct CanvasFilterSection: View {
    @EnvironmentObject var tuning: CanvasTuningState

    let baselineConfig: CanvasConfig
    @Binding var showFiltered: Bool
    @Binding var isRendering: Bool
    var onRenderFilter: () -> Void

    var body: some View {
        let bf = baselineConfig.filter

        tuningSectionHeader("Paint Filter",
                      desc: "Post-process filter applied to impasto + card chrome. 8 filter types available.")

        Toggle("Enabled", isOn: $tuning.config.filter.filterEnabled)
            .onChange(of: tuning.config.filter.filterEnabled) { _, enabled in
                if !enabled { showFiltered = false }
            }

        Picker("Filter", selection: $tuning.config.filter.filterType) {
            ForEach(PaintFilterType.allCases) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .onChange(of: tuning.config.filter.filterType) { _, newType in
            tuning.config.filter.filterParam1 = newType.param1Default
            tuning.config.filter.filterParam2 = newType.param2Default
            showFiltered = false
        }

        TunableSlider("Radius",
                      desc: "Primary size parameter. Meaning varies by filter.",
                      value: $tuning.config.filter.filterRadius,
                      baseline: bf.filterRadius, range: 1...16, format: "%.0f")

        // Conditional param1
        if !tuning.config.filter.filterType.param1Label.isEmpty {
            TunableSlider(tuning.config.filter.filterType.param1Label,
                          desc: "Filter-specific parameter.",
                          value: $tuning.config.filter.filterParam1,
                          baseline: bf.filterParam1,
                          range: tuning.config.filter.filterType.param1Range)
        }

        // Conditional param2
        if !tuning.config.filter.filterType.param2Label.isEmpty {
            TunableSlider(tuning.config.filter.filterType.param2Label,
                          desc: "Filter-specific parameter.",
                          value: $tuning.config.filter.filterParam2,
                          baseline: bf.filterParam2, range: 0...1)
        }

        HStack {
            Button(action: onRenderFilter) {
                Label(isRendering ? "Rendering..." : "Render \(tuning.config.filter.filterType.rawValue)",
                      systemImage: "paintbrush.pointed")
            }
            .disabled(isRendering || !tuning.config.filter.filterEnabled || !CanvasTheme.metalAvailable)

            if showFiltered {
                Button("Remove Filter") { showFiltered = false }
            }
        }

        if !CanvasTheme.metalAvailable {
            Label("Metal unavailable — need GPU compute", systemImage: "exclamationmark.triangle")
                .font(.caption)
                .foregroundStyle(.orange)
        }
    }
}
