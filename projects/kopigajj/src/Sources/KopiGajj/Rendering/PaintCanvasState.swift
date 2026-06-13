import SwiftUI
import AppKit

// MARK: - Brush Preset

/// Parameter snapshot for a given medium × tip combination.
struct BrushPreset {
    let radiusMultiplier: Double  // multiplied against current radius
    let pressureCurve: Double
    let thickness: Double
    let pigmentLoad: Double
}

// MARK: - PaintCanvasState

/// Observable state shared between SwiftUI controls and the NSView canvas.
/// All tuneable parameters use Double for direct SwiftUI Slider binding.
/// Converted to Float at the PaintSimulator (Metal) boundary.
final class PaintCanvasState: ObservableObject {
    // Brush settings
    @Published var brushMode: BrushMode = .oil
    @Published var brushTip: BrushTip = .round
    @Published var brushAngle: Double = 0
    @Published var brushRadius: Double = 20
    @Published var brushColor: NSColor = NSColor(red: 0.85, green: 0.78, blue: 0.68, alpha: 1.0)
    @Published var brushPressure: Double = 0.6
    @Published var pressureCurve: Double = 1.5
    @Published var paintThickness: Double = 1.0  // height multiplier for oil/acrylic/pastel deposits
    @Published var pigmentDilution: Double = 1.0  // pigment concentration: 0.1=very dilute wash, 1.0=full strength
    @Published var brushWetness: Double = 0.7     // water saturation for watercolor: 0=dry brush, 1=saturated
    @Published var isTransparent: Bool = false     // transparent mode: watercolor=water only, oil/acrylic/pastel=grain only
    @Published var renderMode: PaintRenderMode = .lit

    // Sim settings
    @Published var flowStepsPerStroke: Int = 20
    @Published var dryStepsPerStroke: Int = 10
    @Published var flowStrength: Double = 0.5
    @Published var dryRate: Double = 0.1
    @Published var diffusionRate: Double = 0.3
    @Published var edgeDarken: Double = 0.3

    // Time simulation — virtual strokes advance material aging
    @Published var simPlaying: Bool = false
    @Published var secPerStroke: Double = 5.0  // seconds between virtual strokes (0.1=fast, 100=slow)
    @Published var simElapsedSteps: Int = 0

    // Canvas settings
    @Published var ridgeHeight: Double = 0.04
    @Published var weaveScale: Double = 4.0
    @Published var seed: UInt32 = 42
    @Published var lightAzimuth: Double = 45
    @Published var lightElevation: Double = 60
    @Published var heightScale: Double = 16.0

    // Preset state
    /// Saved user-manual values captured before the first preset application.
    @Published var userOverrides: (pressureCurve: Double, thickness: Double, pigmentLoad: Double)?
    /// True while a medium×tip preset is in effect (not yet reverted).
    @Published var isUsingPreset: Bool = false

    // State
    @Published var canvasImage: NSImage?
    @Published var isReady = false

    var simulator: PaintSimulator?
    var strokeHistory: StrokeHistory = StrokeHistory()

    // MARK: - Preset table

    /// Per-medium, per-tip parameter presets.
    /// Values reflect the physical character of each medium:
    ///   Oil      — viscous, high impasto, moderate flow
    ///   Watercolor — thin, high flow, low thickness
    ///   Acrylic  — heavy body wet (near oil), shrinks ~25% during drying
    ///   Pastel   — dry, chalky, low pigment load with high surface coverage
    static let presets: [BrushMode: [BrushTip: BrushPreset]] = [
        .oil: [
            .round:   BrushPreset(radiusMultiplier: 1.0, pressureCurve: 1.5, thickness: 1.6, pigmentLoad: 0.70),
            .flat:    BrushPreset(radiusMultiplier: 1.3, pressureCurve: 1.2, thickness: 2.0, pigmentLoad: 0.65),
            .filbert: BrushPreset(radiusMultiplier: 1.1, pressureCurve: 1.4, thickness: 1.8, pigmentLoad: 0.68),
            .fan:     BrushPreset(radiusMultiplier: 1.5, pressureCurve: 1.0, thickness: 1.2, pigmentLoad: 0.50),
            .knife:   BrushPreset(radiusMultiplier: 1.8, pressureCurve: 0.8, thickness: 0.4, pigmentLoad: 0.30),
        ],
        .watercolor: [
            .round:   BrushPreset(radiusMultiplier: 1.0, pressureCurve: 0.9, thickness: 0.2,  pigmentLoad: 0.35),
            .flat:    BrushPreset(radiusMultiplier: 1.2, pressureCurve: 0.8, thickness: 0.15, pigmentLoad: 0.30),
            .mop:     BrushPreset(radiusMultiplier: 1.6, pressureCurve: 0.7, thickness: 0.10, pigmentLoad: 0.25),
            .rigger:  BrushPreset(radiusMultiplier: 0.4, pressureCurve: 1.0, thickness: 0.18, pigmentLoad: 0.40),
            .wash:    BrushPreset(radiusMultiplier: 2.0, pressureCurve: 0.6, thickness: 0.08, pigmentLoad: 0.20),
        ],
        .acrylic: [
            .round:   BrushPreset(radiusMultiplier: 1.0, pressureCurve: 1.3, thickness: 1.5, pigmentLoad: 0.80),
            .flat:    BrushPreset(radiusMultiplier: 1.2, pressureCurve: 1.1, thickness: 1.9, pigmentLoad: 0.85),
            .filbert: BrushPreset(radiusMultiplier: 1.0, pressureCurve: 1.2, thickness: 1.7, pigmentLoad: 0.80),
            .fan:     BrushPreset(radiusMultiplier: 1.3, pressureCurve: 0.9, thickness: 1.1, pigmentLoad: 0.60),
            .knife:   BrushPreset(radiusMultiplier: 1.6, pressureCurve: 0.7, thickness: 0.5, pigmentLoad: 0.50),
        ],
        .pastel: [
            .stick:   BrushPreset(radiusMultiplier: 1.2, pressureCurve: 1.0, thickness: 0.5,  pigmentLoad: 0.55),
            .edge:    BrushPreset(radiusMultiplier: 0.8, pressureCurve: 1.2, thickness: 0.6,  pigmentLoad: 0.50),
            .blender: BrushPreset(radiusMultiplier: 1.0, pressureCurve: 0.8, thickness: 0.1,  pigmentLoad: 0.10),
            .hard:    BrushPreset(radiusMultiplier: 0.6, pressureCurve: 1.3, thickness: 0.7,  pigmentLoad: 0.65),
            .soft:    BrushPreset(radiusMultiplier: 1.5, pressureCurve: 0.9, thickness: 0.35, pigmentLoad: 0.40),
        ],
        .highlighter: [
            .chisel:  BrushPreset(radiusMultiplier: 1.5, pressureCurve: 0.7, thickness: 0.0, pigmentLoad: 0.50),
            .fine:    BrushPreset(radiusMultiplier: 0.5, pressureCurve: 0.9, thickness: 0.0, pigmentLoad: 0.55),
            .bullet:  BrushPreset(radiusMultiplier: 1.0, pressureCurve: 0.8, thickness: 0.0, pigmentLoad: 0.48),
        ],
    ]

    // MARK: - Preset application

    /// Apply the medium × tip preset, capturing current values as user overrides first.
    func applyPreset(for tip: BrushTip, medium: BrushMode) {
        // Capture the manual values only before the first preset application.
        if !isUsingPreset {
            userOverrides = (
                pressureCurve: pressureCurve,
                thickness: paintThickness,
                pigmentLoad: pigmentDilution
            )
        }
        guard let preset = Self.presets[medium]?[tip] else { return }
        pressureCurve = preset.pressureCurve
        paintThickness = preset.thickness
        pigmentDilution = preset.pigmentLoad
        isUsingPreset = true
    }

    /// Restore the manually-set values saved before the first preset was applied.
    func revertToOverrides() {
        guard let saved = userOverrides else { return }
        pressureCurve = saved.pressureCurve
        paintThickness = saved.thickness
        pigmentDilution = saved.pigmentLoad
        isUsingPreset = false
    }

    private var simTimer: Timer?

    /// Start/stop the continuous simulation timer.
    func updateTimer() {
        simTimer?.invalidate()
        simTimer = nil

        guard simPlaying, isReady, simulator != nil else { return }

        simTimer = Timer.scheduledTimer(withTimeInterval: secPerStroke, repeats: true) { [weak self] _ in
            guard let self, self.simPlaying, let sim = self.simulator else { return }

            let mode = self.brushMode
            let flowSteps = self.flowStepsPerStroke
            let drySteps = self.dryStepsPerStroke
            // Double → Float conversion at the Metal boundary
            let flowStr = Float(self.flowStrength)
            let diffRate = Float(self.diffusionRate)
            let dryR = Float(self.dryRate)
            let edgeD = Float(self.edgeDarken)
            let lightAz = Float(self.lightAzimuth)
            let lightEl = Float(self.lightElevation)
            let hScale = Float(self.heightScale)
            let rMode = Int32(self.renderMode.rawValue)

            DispatchQueue.global(qos: .userInteractive).async {
                // Inject virtual zero-pressure strokes to advance the time vector
                sim.injectTimeTick(mode: mode)
                // Then run spatial operators (flow + dry)
                sim.simulate(flowSteps: flowSteps, drySteps: drySteps,
                             flowStrength: flowStr, diffusionRate: diffRate,
                             dryRate: dryR, edgeDarken: edgeD)
                let image = sim.render(
                    lightAzimuth: lightAz, lightElevation: lightEl,
                    heightScale: hScale, renderMode: rMode
                )
                DispatchQueue.main.async {
                    self.simElapsedSteps += 1
                    if let image { self.canvasImage = image }
                }
            }
        }
    }

    func stopTimer() {
        simTimer?.invalidate()
        simTimer = nil
        simPlaying = false
    }
}
