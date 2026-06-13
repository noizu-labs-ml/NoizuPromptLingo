import SwiftUI
import AppKit

// MARK: - Slider Panel

/// The right-side slider panel for tuning canvas parameters.
struct CanvasTuningSliders: View {
    @EnvironmentObject var tuning: CanvasTuningState

    let baselineConfig: CanvasConfig
    let onClose: () -> Void

    // Filter state
    @Binding var showFiltered: Bool
    @Binding var isRendering: Bool

    // Paint sim state
    @Binding var showPaintSim: Bool
    @Binding var isSimulating: Bool
    @Binding var simElapsed: String
    @Binding var paintSimImages: [PaintRenderMode: NSImage]

    // Config management state
    @Binding var savedConfigs: [String]
    @Binding var selectedConfig: String
    @Binding var newConfigName: String
    @Binding var showSaveField: Bool
    @Binding var baselineConfigBinding: CanvasConfig

    // Render action callbacks
    var onRenderFilter: () -> Void
    var onRunPaintSim: () -> Void
    var onResetToTheme: () -> Void

    // Config action callbacks
    var onLoadTheme: (String) -> Void
    var onSaveNewConfig: () -> Void
    var onRefreshConfigList: () -> Void

    var body: some View {
        let bg = baselineConfig.background
        let card = baselineConfig.card
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text("Canvas Tuning")
                        .font(.headline)
                    Spacer()
                    Button("Close", action: onClose)
                        .keyboardShortcut(.escape)
                }

                CanvasConfigSection(
                    savedConfigs: $savedConfigs,
                    selectedConfig: $selectedConfig,
                    newConfigName: $newConfigName,
                    showSaveField: $showSaveField,
                    onLoadTheme: onLoadTheme,
                    onSaveNewConfig: onSaveNewConfig,
                    onRefreshConfigList: onRefreshConfigList
                )
                .environmentObject(tuning)

                Divider()

                // --- Canvas Background ---
                tuningSectionHeader("Canvas Background",
                              desc: "Procedural canvas weave texture and color washes behind all content.")

                TunableSlider("Texture Opacity",
                              desc: "How visible the canvas weave grain is. Higher = more tactile.",
                              value: $tuning.config.background.textureOpacity, baseline: bg.textureOpacity, range: 0...1)
                TunableSlider("Thread Weight",
                              desc: "Thickness of individual canvas threads in pixels.",
                              value: $tuning.config.background.textureThreadWeight, baseline: bg.textureThreadWeight, range: 0.5...5, format: "%.1f")
                TunableSlider("Thread Spacing",
                              desc: "Distance between canvas threads. Smaller = tighter weave.",
                              value: $tuning.config.background.textureThreadSpacing, baseline: bg.textureThreadSpacing, range: 2...10, format: "%.1f")
                TunableIntSlider(label: "Impasto Marks",
                                 desc: "Random thick paint dabs on canvas. Adds tactile depth.",
                                 value: $tuning.config.background.impastoMarkCount, baseline: bg.impastoMarkCount, range: 0...120)

                // Impasto shape controls
                DisclosureGroup("Impasto Shape") {
                    VStack(alignment: .leading, spacing: 10) {
                        TunableSlider("Min Width",
                                      desc: "Minimum ovoid width in pixels.",
                                      value: $tuning.config.background.impastoMinWidth, baseline: bg.impastoMinWidth, range: 2...80, format: "%.0f")
                        TunableSlider("Max Width",
                                      desc: "Maximum ovoid width in pixels.",
                                      value: $tuning.config.background.impastoMaxWidth, baseline: bg.impastoMaxWidth, range: 2...80, format: "%.0f")
                        TunableSlider("Height Ratio",
                                      desc: "Height as fraction of width. 0.25 = flat dabs, 0.8 = round blobs.",
                                      value: $tuning.config.background.impastoHeightRatio, baseline: bg.impastoHeightRatio, range: 0.05...0.8)
                        TunableSlider("Taper",
                                      desc: "Ovoid asymmetry. 0 = symmetric ellipse, 0.8 = egg-shaped (wide heel, narrow tip).",
                                      value: $tuning.config.background.impastoTaper, baseline: bg.impastoTaper, range: 0...0.8)
                        TunableSlider("Min Alpha",
                                      desc: "Minimum opacity of paint dabs.",
                                      value: $tuning.config.background.impastoMinAlpha, baseline: bg.impastoMinAlpha, range: 0...1)
                        TunableSlider("Max Alpha",
                                      desc: "Maximum opacity of paint dabs.",
                                      value: $tuning.config.background.impastoMaxAlpha, baseline: bg.impastoMaxAlpha, range: 0...1)
                        TunableSlider("Color Shift",
                                      desc: "Warm/cool color variation range. Higher = more varied dab colors.",
                                      value: $tuning.config.background.impastoColorShift, baseline: bg.impastoColorShift, range: 0...0.3)
                        TunableSlider("Highlight",
                                      desc: "Brightness of the highlight edge simulating paint thickness.",
                                      value: $tuning.config.background.impastoHighlight, baseline: bg.impastoHighlight, range: 0...1)
                        TunableSlider("Max Rotation",
                                      desc: "Maximum rotation angle in radians. 0 = all horizontal, 1.57 = any direction.",
                                      value: $tuning.config.background.impastoRotation, baseline: bg.impastoRotation, range: 0...1.57)
                        TunableIntSlider(label: "Seed",
                                         desc: "Random seed for mark placement. Change to get a different arrangement.",
                                         value: $tuning.config.background.impastoSeed, baseline: bg.impastoSeed, range: 1...9999)
                    }
                    .padding(.leading, 8)
                }
                .font(.system(size: 11, weight: .medium))

                TunableSlider("Warm Wash",
                              desc: "Orange radial gradient from top-left. Adds warmth.",
                              value: $tuning.config.background.warmWashOpacity, baseline: bg.warmWashOpacity, range: 0...0.20)
                TunableSlider("Cool Wash",
                              desc: "Indigo radial gradient from bottom-right. Adds depth.",
                              value: $tuning.config.background.coolWashOpacity, baseline: bg.coolWashOpacity, range: 0...0.20)

                Divider()

                // --- Stroke Cards ---
                tuningSectionHeader("Stroke Cards",
                              desc: "Visual treatment for clipboard item cards — the 'brush strokes' on the canvas.")

                TunableSlider("Corner Radius",
                              desc: "Roundness of card corners. 18 = soft painterly, 4 = sharp modern.",
                              value: $tuning.config.card.cardCornerRadius, baseline: card.cardCornerRadius, range: 2...40, format: "%.0f")
                TunableSlider("Border Width",
                              desc: "Angular gradient border simulating paint thickness variation.",
                              value: $tuning.config.card.cardBorderWidth, baseline: card.cardBorderWidth, range: 0...6, format: "%.1f")
                TunableSlider("Border Opacity",
                              desc: "Visibility of the brown/orange painterly border.",
                              value: $tuning.config.card.cardBorderOpacity, baseline: card.cardBorderOpacity, range: 0...0.5)
                TunableSlider("Card Warmth",
                              desc: "Color saturation of the warm hue tint on card backgrounds.",
                              value: $tuning.config.card.cardWarmthSaturation, baseline: card.cardWarmthSaturation, range: 0...0.3)
                TunableSlider("Shadow Radius",
                              desc: "Blur radius of the brown drop shadow beneath cards.",
                              value: $tuning.config.card.cardShadowRadius, baseline: card.cardShadowRadius, range: 0...25, format: "%.0f")
                TunableSlider("Shadow Opacity",
                              desc: "Darkness of the card shadow. Fades with temporal age.",
                              value: $tuning.config.card.cardShadowOpacity, baseline: card.cardShadowOpacity, range: 0...0.6)
                TunableSlider("Edge Jaggedness",
                              desc: "Displacement amplitude of card edges. 0 = smooth, 8+ = torn paper.",
                              value: $tuning.config.card.cardJaggedness, baseline: card.cardJaggedness, range: 0...12, format: "%.1f")
                TunableSlider("Edge Frequency",
                              desc: "Number of wobbles along the card edge. Low = wavy, high = jagged.",
                              value: $tuning.config.card.cardJaggedFrequency, baseline: card.cardJaggedFrequency, range: 2...40, format: "%.0f")

                Divider()

                // --- Temporal Fade ---
                tuningSectionHeader("Temporal Fade",
                              desc: "How clipboard items age visually — older items look drier and more faded.")

                TunableSlider("Max Desaturation",
                              desc: "Color removal from oldest items. 1.0 = fully gray.",
                              value: $tuning.config.card.maxDesaturation, baseline: card.maxDesaturation, range: 0...1)
                TunableSlider("Max Fade",
                              desc: "Opacity reduction on oldest items. 0.8 = nearly invisible.",
                              value: $tuning.config.card.maxFade, baseline: card.maxFade, range: 0...0.8)

                Divider()

                // --- Paint Filter ---
                CanvasFilterSection(
                    baselineConfig: baselineConfig,
                    showFiltered: $showFiltered,
                    isRendering: $isRendering,
                    onRenderFilter: onRenderFilter
                )
                .environmentObject(tuning)

                Divider()

                // --- Paint Simulation (GPU) ---
                CanvasPaintSimSection(
                    baselineConfig: baselineConfig,
                    showPaintSim: $showPaintSim,
                    isSimulating: $isSimulating,
                    onRunPaintSim: onRunPaintSim
                )
                .environmentObject(tuning)

                Divider()

                // --- Actions ---
                HStack {
                    Button("Reset to Theme", action: onResetToTheme)

                    Spacer()

                    Text("~/.config/kopigajj/themes/")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.quaternary)
                }
            }
            .padding(16)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

