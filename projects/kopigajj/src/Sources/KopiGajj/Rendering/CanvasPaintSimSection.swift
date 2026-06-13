import SwiftUI

// MARK: - Paint Simulation Section

struct CanvasPaintSimSection: View {
    @EnvironmentObject var tuning: CanvasTuningState

    let baselineConfig: CanvasConfig
    @Binding var showPaintSim: Bool
    @Binding var isSimulating: Bool
    var onRunPaintSim: () -> Void

    var body: some View {
        let bs = baselineConfig.sim

        tuningSectionHeader("Paint Simulation",
                      desc: "GPU-based physically-inspired paint simulation. Oil and watercolor brushes on a canvas heightfield with flow, drying, and lit rendering.")

        DisclosureGroup("Canvas Surface") {
            VStack(alignment: .leading, spacing: 10) {
                TunableSlider("Ridge Height",
                              desc: "Height of canvas weave ridges. Affects how paint pools and how light catches.",
                              value: $tuning.config.sim.simRidgeHeight, baseline: bs.simRidgeHeight, range: 0.005...0.1)
                TunableSlider("Weave Scale",
                              desc: "Canvas thread spacing for the heightfield.",
                              value: $tuning.config.sim.simWeaveScale, baseline: bs.simWeaveScale, range: 2...12, format: "%.0f")
            }
            .padding(.leading, 8)
        }
        .font(.system(size: 11, weight: .medium))

        DisclosureGroup("Brush & Strokes") {
            VStack(alignment: .leading, spacing: 10) {
                TunableIntSlider(label: "Stroke Count",
                                 desc: "Number of procedural brush strokes to generate.",
                                 value: $tuning.config.sim.simStrokeCount, baseline: bs.simStrokeCount, range: 1...60)
                TunableIntSlider(label: "Seed",
                                 desc: "Random seed for stroke placement.",
                                 value: $tuning.config.sim.simSeed, baseline: bs.simSeed, range: 1...9999)
            }
            .padding(.leading, 8)
        }
        .font(.system(size: 11, weight: .medium))

        DisclosureGroup("Flow & Drying") {
            VStack(alignment: .leading, spacing: 10) {
                TunableSlider("Flow Strength",
                              desc: "How fast watercolor pigment flows downhill. 0 = static, 1 = fast flow.",
                              value: $tuning.config.sim.simFlowStrength, baseline: bs.simFlowStrength, range: 0...1)
                TunableSlider("Diffusion Rate",
                              desc: "How fast pigment spreads through wet regions.",
                              value: $tuning.config.sim.simDiffusionRate, baseline: bs.simDiffusionRate, range: 0...1)
                TunableSlider("Dry Rate",
                              desc: "How fast paint dries. Higher = faster hardening.",
                              value: $tuning.config.sim.simDryRate, baseline: bs.simDryRate, range: 0...0.5)
                TunableSlider("Edge Darken",
                              desc: "Pigment concentration at wet/dry boundaries (watercolor edge effect).",
                              value: $tuning.config.sim.simEdgeDarken, baseline: bs.simEdgeDarken, range: 0...1)
                TunableIntSlider(label: "Flow Steps",
                                 desc: "Simulation steps for water flow per stroke.",
                                 value: $tuning.config.sim.simFlowSteps, baseline: bs.simFlowSteps, range: 0...30)
                TunableIntSlider(label: "Dry Steps",
                                 desc: "Simulation steps for drying per stroke.",
                                 value: $tuning.config.sim.simDrySteps, baseline: bs.simDrySteps, range: 0...20)
            }
            .padding(.leading, 8)
        }
        .font(.system(size: 11, weight: .medium))

        DisclosureGroup("Lighting") {
            VStack(alignment: .leading, spacing: 10) {
                TunableSlider("Light Azimuth",
                              desc: "Horizontal angle of the light source in degrees.",
                              value: $tuning.config.sim.simLightAzimuth, baseline: bs.simLightAzimuth, range: 0...360, format: "%.0f")
                TunableSlider("Light Elevation",
                              desc: "Vertical angle of the light. Low = raking light (shows texture), high = flat.",
                              value: $tuning.config.sim.simLightElevation, baseline: bs.simLightElevation, range: 10...90, format: "%.0f")
                TunableSlider("Ambient",
                              desc: "Minimum brightness in shadows.",
                              value: $tuning.config.sim.simAmbient, baseline: bs.simAmbient, range: 0...1)
                TunableSlider("Specular",
                              desc: "Shiny highlight on wet paint.",
                              value: $tuning.config.sim.simSpecular, baseline: bs.simSpecular, range: 0...1)
                TunableSlider("Height Scale",
                              desc: "Exaggeration of height for normal map. Higher = more 3D relief.",
                              value: $tuning.config.sim.simHeightScale, baseline: bs.simHeightScale, range: 1...20, format: "%.0f")
                TunableSlider("Dry Smoothing",
                              desc: "How much wet paint smooths ridges as it dries. 0 = ridges lock instantly.",
                              value: $tuning.config.sim.simDrySmoothRate, baseline: bs.simDrySmoothRate, range: 0...3, format: "%.1f")
                TunableSlider("Brush Texture",
                              desc: "Intensity of bristle ridges and grain texture from brush strokes.",
                              value: $tuning.config.sim.simBrushTexture, baseline: bs.simBrushTexture, range: 0...3, format: "%.1f")
                TunableSlider("Media Opacity",
                              desc: "Coverage multiplier. Higher = more opaque. Affects acrylic/pastel/oil.",
                              value: $tuning.config.sim.simOpacityMult, baseline: bs.simOpacityMult, range: 0.2...3, format: "%.1f")
            }
            .padding(.leading, 8)
        }
        .font(.system(size: 11, weight: .medium))

        // Render mode toggle — switches instantly without re-simulating
        Picker("View", selection: $tuning.simRenderMode) {
            ForEach(PaintRenderMode.tuningModes) { mode in
                Text(mode.tuningLabel).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.small)

        HStack {
            Button(action: onRunPaintSim) {
                Label(isSimulating ? "Simulating..." : "Generate Canvas",
                      systemImage: "paintpalette")
            }
            .disabled(isSimulating || !CanvasTheme.metalAvailable)

            if showPaintSim {
                Button("Show Live") {
                    showPaintSim = false
                }
            }
        }
    }
}
