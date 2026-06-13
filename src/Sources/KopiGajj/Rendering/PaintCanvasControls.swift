import SwiftUI
import AppKit

// MARK: - Paint Canvas Controls (SwiftUI toolbar)

struct PaintCanvasControls: View {
    @ObservedObject var state: PaintCanvasState
    @State private var colorMode: ColorMode = .rgb
    @State private var recentColors: [NSColor] = []

    private enum ColorMode: String, CaseIterable { case rgb = "RGB", hsb = "HSB" }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Render mode
            Picker("View", selection: $state.renderMode) {
                ForEach(PaintRenderMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .controlSize(.mini)

            Divider()

            // --- Brush preview + media/tip row ---
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Picker("Media", selection: $state.brushMode) {
                        ForEach(BrushMode.allCases) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .controlSize(.small)
                    .onChange(of: state.brushMode) { _, newMode in
                        let available = BrushTip.tips(for: newMode)
                        if !available.contains(state.brushTip) {
                            state.brushTip = available.first ?? .round
                        }
                        state.applyPreset(for: state.brushTip, medium: newMode)
                    }

                    Picker("Tip", selection: $state.brushTip) {
                        ForEach(BrushTip.tips(for: state.brushMode)) { tip in
                            Text(tip.rawValue).tag(tip)
                        }
                    }
                    .pickerStyle(.segmented)
                    .controlSize(.mini)
                    .onChange(of: state.brushTip) { _, newTip in
                        state.applyPreset(for: newTip, medium: state.brushMode)
                    }

                    if state.isUsingPreset {
                        Button("Reset to Custom") {
                            state.revertToOverrides()
                        }
                        .controlSize(.mini)
                        .foregroundStyle(.secondary)
                    }
                }

                // Brush preview swatch
                brushPreview
                    .frame(width: 80, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
            }

            // --- Color section ---
            Text("COLOR")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary)

            // Native macOS HSB color wheel picker
            HStack {
                ColorPicker("Brush Color", selection: brushColorBinding, supportsOpacity: false)
                    .labelsHidden()

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(nsColor: state.brushColor))
                    .frame(width: 36, height: 22)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.secondary.opacity(0.4)))

                Spacer()

                Button {
                    let panel = NSColorPanel.shared
                    panel.color = state.brushColor
                    panel.isContinuous = true
                    panel.showsAlpha = false
                    ColorPanelCoordinator.shared.attach(state: state, panel: panel)
                    panel.orderFront(nil)
                } label: {
                    Label("Color Wheel", systemImage: "paintpalette")
                        .font(.system(size: 10))
                }
                .buttonStyle(.borderless)
                .help("Open full macOS color panel")
            }

            // Palette categories
            swatchPalette("Earth", [
                c(0.92,0.88,0.82), c(0.85,0.68,0.50), c(0.80,0.72,0.45),
                c(0.55,0.42,0.32), c(0.78,0.48,0.38), c(0.70,0.58,0.42),
                c(0.96,0.94,0.90), c(0.45,0.35,0.25),
            ])
            swatchPalette("Cool", [
                c(0.45,0.42,0.58), c(0.50,0.52,0.55), c(0.60,0.68,0.55),
                c(0.35,0.50,0.65), c(0.55,0.70,0.75), c(0.40,0.55,0.50),
                c(0.30,0.35,0.50), c(0.70,0.80,0.85),
            ])
            swatchPalette("Vivid", [
                c(0.90,0.20,0.20), c(0.20,0.45,0.85), c(0.15,0.70,0.30),
                c(0.95,0.80,0.10), c(0.85,0.40,0.70), c(0.95,0.55,0.10),
                c(0.10,0.10,0.10), c(0.95,0.95,0.95),
            ])

            // Recent colors
            if !recentColors.isEmpty {
                swatchRow("Recent", recentColors.suffix(8).map { $0 })
            }

            // RGB / HSB toggle
            Picker("", selection: $colorMode) {
                ForEach(ColorMode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .controlSize(.mini)

            if colorMode == .rgb {
                colorSlider("R", value: rgbBinding(\.redComponent, setR: true), tint: .red)
                colorSlider("G", value: rgbBinding(\.greenComponent, setG: true), tint: .green)
                colorSlider("B", value: rgbBinding(\.blueComponent, setB: true), tint: .blue)
            } else {
                colorSlider("H", value: hsbBinding(\.hueComponent, setH: true), tint: .orange)
                colorSlider("S", value: hsbBinding(\.saturationComponent, setS: true), tint: .purple)
                colorSlider("B", value: hsbBinding(\.brightnessComponent, setB: true), tint: .yellow)
            }

            // Radius
            HStack(spacing: 4) {
                Text("Radius")
                    .font(.system(size: 11))
                InfoButton(text: MediaTooltips.radius(for: state.brushMode))
                Spacer()
                Text("\(Int(state.brushRadius))")
                    .font(.system(size: 10, design: .monospaced))
            }
            Slider(value: $state.brushRadius, in: 3...300)
                .controlSize(.small)

            // Pressure
            HStack(spacing: 4) {
                Text("Pressure")
                    .font(.system(size: 11))
                InfoButton(text: MediaTooltips.pressure(for: state.brushMode))
                Spacer()
                Text(String(format: "%.2f", state.brushPressure))
                    .font(.system(size: 10, design: .monospaced))
            }
            Slider(value: $state.brushPressure, in: 0.05...1)
                .controlSize(.small)

            // Pressure curve
            HStack(spacing: 4) {
                Text("Pressure Curve")
                    .font(.system(size: 11))
                InfoButton(text: MediaTooltips.pressureCurve(for: state.brushMode))
                Spacer()
                Text(String(format: "%.1f", state.pressureCurve))
                    .font(.system(size: 10, design: .monospaced))
            }
            Slider(value: $state.pressureCurve, in: 0.3...3)
                .controlSize(.small)

            // Paint thickness (height of deposited paint glob)
            HStack(spacing: 4) {
                Text("Thickness")
                    .font(.system(size: 11))
                InfoButton(text: MediaTooltips.thickness(for: state.brushMode))
                Spacer()
                Text(String(format: "%.1fx", state.paintThickness))
                    .font(.system(size: 10, design: .monospaced))
            }
            Slider(value: $state.paintThickness, in: 0.1...5.0)
                .controlSize(.small)

            // Pigment dilution (concentration)
            HStack(spacing: 4) {
                Text("Pigment Load")
                    .font(.system(size: 11))
                InfoButton(text: MediaTooltips.pigmentLoad(for: state.brushMode))
                Spacer()
                Text(String(format: "%.0f%%", state.pigmentDilution * 100))
                    .font(.system(size: 10, design: .monospaced))
            }
            Slider(value: $state.pigmentDilution, in: 0.05...1.0)
                .controlSize(.small)

            // Brush wetness (watercolor only, or transparent watercolor)
            if state.brushMode == .watercolor {
                HStack(spacing: 4) {
                    Text("Wetness")
                        .font(.system(size: 11))
                    InfoButton(text: MediaTooltips.wetness)
                    Spacer()
                    Text(String(format: "%.0f%%", state.brushWetness * 100))
                        .font(.system(size: 10, design: .monospaced))
                }
                Slider(value: $state.brushWetness, in: 0.05...1.0)
                    .controlSize(.small)
            }

            // Transparent mode toggle
            HStack(spacing: 4) {
                Toggle("Transparent", isOn: $state.isTransparent)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 11))
                InfoButton(text: MediaTooltips.transparent(for: state.brushMode))
            }

            // Brush angle (for flat/filbert/knife tips)
            HStack(spacing: 4) {
                Text("Brush Angle")
                    .font(.system(size: 11))
                InfoButton(text: MediaTooltips.brushAngle(for: state.brushMode))
                Spacer()
                Text(String(format: "%.0f°", state.brushAngle * 180 / .pi))
                    .font(.system(size: 10, design: .monospaced))
            }
            Slider(value: $state.brushAngle, in: 0...Double.pi)
                .controlSize(.small)

            Divider()

            // --- Time Simulation ---
            Text("TIME SIMULATION")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary)

            HStack {
                Button(state.simPlaying ? "Pause" : "Play") {
                    state.simPlaying.toggle()
                    state.updateTimer()
                }
                .controlSize(.small)

                Text("\(state.simElapsedSteps) steps")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Reset Time") {
                    state.stopTimer()
                    state.simElapsedSteps = 0
                }
                .controlSize(.small)
            }

            HStack {
                Text("sec/stroke")
                    .font(.system(size: 11))
                Slider(value: $state.secPerStroke, in: 0.1...100)
                    .controlSize(.small)
                Text(String(format: state.secPerStroke < 1 ? "%.1f" : "%.0f", state.secPerStroke))
                    .font(.system(size: 10, design: .monospaced))
                    .frame(width: 30)
            }
            .onChange(of: state.secPerStroke) { _, _ in
                if state.simPlaying { state.updateTimer() }
            }

            Divider()

            // Sim per-stroke
            HStack {
                Text("Flow Steps/Stroke")
                    .font(.system(size: 11))
                Stepper("\(state.flowStepsPerStroke)", value: $state.flowStepsPerStroke, in: 0...40)
                    .font(.system(size: 10, design: .monospaced))
            }
            HStack {
                Text("Dry Steps/Stroke")
                    .font(.system(size: 11))
                Stepper("\(state.dryStepsPerStroke)", value: $state.dryStepsPerStroke, in: 0...20)
                    .font(.system(size: 10, design: .monospaced))
            }

            // Flow/dry/diffusion rate controls
            HStack(spacing: 4) {
                Text("Flow Strength")
                    .font(.system(size: 11))
                InfoButton(text: MediaTooltips.flowStrength(for: state.brushMode))
                Slider(value: $state.flowStrength, in: 0...25)
                    .controlSize(.small)
                Text(String(format: "%.2f", state.flowStrength))
                    .font(.system(size: 10, design: .monospaced))
                    .frame(width: 30)
            }
            HStack(spacing: 4) {
                Text("Diffusion Rate")
                    .font(.system(size: 11))
                InfoButton(text: MediaTooltips.diffusionRate(for: state.brushMode))
                Slider(value: $state.diffusionRate, in: 0...25)
                    .controlSize(.small)
                Text(String(format: "%.2f", state.diffusionRate))
                    .font(.system(size: 10, design: .monospaced))
                    .frame(width: 30)
            }
            HStack(spacing: 4) {
                Text("Dry Rate")
                    .font(.system(size: 11))
                InfoButton(text: MediaTooltips.dryRate(for: state.brushMode))
                Slider(value: $state.dryRate, in: 0...25)
                    .controlSize(.small)
                Text(String(format: "%.2f", state.dryRate))
                    .font(.system(size: 10, design: .monospaced))
                    .frame(width: 30)
            }
            HStack(spacing: 4) {
                Text("Edge Darken")
                    .font(.system(size: 11))
                InfoButton(text: MediaTooltips.edgeDarken(for: state.brushMode))
                Slider(value: $state.edgeDarken, in: 0...25)
                    .controlSize(.small)
                Text(String(format: "%.2f", state.edgeDarken))
                    .font(.system(size: 10, design: .monospaced))
                    .frame(width: 30)
            }

            Divider()

            // Actions
            HStack {
                Button("Clear Canvas") {
                    guard let sim = state.simulator else { return }
                    sim.initCanvas(spacing: Float(state.weaveScale),
                                   ridgeHeight: Float(state.ridgeHeight),
                                   seed: state.seed)
                    state.strokeHistory = StrokeHistory()
                    if let image = sim.render(
                        lightAzimuth: Float(state.lightAzimuth),
                        lightElevation: Float(state.lightElevation),
                        heightScale: Float(state.heightScale)
                    ) {
                        state.canvasImage = image
                    }
                }

                Text("\(state.strokeHistory.strokes.count) strokes")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Brush preview

    private var brushPreview: some View {
        Canvas { ctx, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = min(size.width, size.height) * 0.35
            let color = Color(nsColor: state.brushColor)

            // Draw canvas-like background
            ctx.fill(Path(CGRect(origin: .zero, size: size)),
                     with: .color(Color(red: 0.85, green: 0.82, blue: 0.78)))

            // Simulate a short horizontal stroke
            let strokeLen = r * 1.5
            let steps = 20
            for i in 0..<steps {
                let t = Double(i) / Double(steps - 1)
                let x = center.x - strokeLen / 2 + strokeLen * t
                let y = center.y + sin(t * .pi) * 2 // slight arc

                // Tip shape
                let tipW: Double
                let tipH: Double
                switch state.brushTip {
                case .round:   tipW = r * 0.8; tipH = r * 0.8
                case .flat:    tipW = r * 1.2; tipH = r * 0.3
                case .filbert: tipW = r * 1.0; tipH = r * 0.5
                case .fan:     tipW = r * 1.4; tipH = r * 0.2
                case .knife:   tipW = r * 1.5; tipH = r * 0.1
                case .mop:     tipW = r * 1.0; tipH = r * 1.0
                case .rigger:  tipW = r * 1.2; tipH = r * 0.08
                case .wash:    tipW = r * 1.4; tipH = r * 0.2
                case .stick:   tipW = r * 0.9; tipH = r * 0.4
                case .edge:    tipW = r * 1.2; tipH = r * 0.06
                case .blender: tipW = r * 0.7; tipH = r * 0.7
                case .hard:    tipW = r * 0.5; tipH = r * 0.5
                case .soft:    tipW = r * 1.0; tipH = r * 1.0
                case .chisel:  tipW = r * 1.2; tipH = r * 0.25
                case .fine:    tipW = r * 0.3; tipH = r * 0.3
                case .bullet:  tipW = r * 0.6; tipH = r * 0.6
                }

                // Pressure taper at ends
                let taper = min(t * 4, 1) * min((1 - t) * 4, 1)
                let pressure = state.brushPressure * taper

                let wcOpacity = 0.15 + state.brushWetness * 0.35  // dry brush=more opaque, wet=more transparent
                let opacity: Double
                if state.isTransparent {
                    // Transparent: very faint preview to suggest medium-only deposit
                    opacity = pressure * 0.15
                } else {
                    switch state.brushMode {
                    case .watercolor:  opacity = pressure * wcOpacity
                    case .highlighter: opacity = pressure * 0.35
                    default:           opacity = pressure * 0.7
                    }
                }

                ctx.opacity = opacity
                let rect = CGRect(x: x - tipW / 2, y: y - tipH / 2, width: tipW, height: tipH)
                    .applying(CGAffineTransform(rotationAngle: CGFloat(state.brushAngle)))

                ctx.fill(Path(ellipseIn: CGRect(x: x - tipW / 2, y: y - tipH / 2,
                                                 width: tipW, height: tipH)),
                         with: .color(color))
            }
            ctx.opacity = 1

            // Media label
            let mediaLabel = state.isTransparent
                ? "\(state.brushMode.rawValue.capitalized) (T)"
                : state.brushMode.rawValue.capitalized
            ctx.draw(Text(mediaLabel).font(.system(size: 8, weight: .medium)).foregroundColor(.white),
                     at: CGPoint(x: size.width / 2, y: size.height - 6))
        }
    }

    // MARK: - Color helpers

    /// Binding that bridges SwiftUI `Color` ↔ `NSColor` for the native ColorPicker.
    private var brushColorBinding: Binding<Color> {
        Binding(
            get: { Color(nsColor: state.brushColor) },
            set: { newColor in
                if let nsColor = NSColor(newColor).usingColorSpace(.deviceRGB) {
                    state.brushColor = nsColor
                    addRecentColor(nsColor)
                }
            }
        )
    }

    private func c(_ r: Double, _ g: Double, _ b: Double) -> NSColor {
        NSColor(red: r, green: g, blue: b, alpha: 1)
    }

    private func swatchPalette(_ label: String, _ colors: [NSColor]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.tertiary)
            swatchRow(label, colors)
        }
    }

    private func swatchRow(_ label: String, _ colors: [NSColor]) -> some View {
        HStack(spacing: 3) {
            ForEach(0..<colors.count, id: \.self) { i in
                let color = colors[i]
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(nsColor: color))
                    .frame(width: 22, height: 22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(state.brushColor.isClose(to: color) ? Color.primary : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        state.brushColor = color
                        addRecentColor(color)
                    }
            }
        }
    }

    private func addRecentColor(_ color: NSColor) {
        recentColors.removeAll { $0.isClose(to: color) }
        recentColors.append(color)
        if recentColors.count > 8 { recentColors.removeFirst() }
    }

    private func rgbBinding(_ component: KeyPath<NSColor, CGFloat>,
                            setR: Bool = false, setG: Bool = false, setB: Bool = false) -> Binding<CGFloat> {
        Binding(
            get: { state.brushColor[keyPath: component] },
            set: { val in
                let r = setR ? val : state.brushColor.redComponent
                let g = setG ? val : state.brushColor.greenComponent
                let b = setB ? val : state.brushColor.blueComponent
                state.brushColor = NSColor(red: r, green: g, blue: b, alpha: 1)
            }
        )
    }

    private func hsbBinding(_ component: KeyPath<NSColor, CGFloat>,
                            setH: Bool = false, setS: Bool = false, setB: Bool = false) -> Binding<CGFloat> {
        Binding(
            get: { state.brushColor[keyPath: component] },
            set: { val in
                let h = setH ? val : state.brushColor.hueComponent
                let s = setS ? val : state.brushColor.saturationComponent
                let b = setB ? val : state.brushColor.brightnessComponent
                state.brushColor = NSColor(hue: h, saturation: s, brightness: b, alpha: 1)
            }
        )
    }

    private func colorSlider(_ label: String, value: Binding<CGFloat>, tint: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .frame(width: 14)
            Slider(value: value, in: 0...1)
                .tint(tint)
                .controlSize(.mini)
            Text(String(format: "%.0f", value.wrappedValue * 255))
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 24)
        }
    }
}
