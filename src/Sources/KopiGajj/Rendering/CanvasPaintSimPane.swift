import SwiftUI
import AppKit

// MARK: - Interactive Paint Pane

/// The interactive paint canvas shown in the left pane when paint mode is active.
struct CanvasInteractivePaintPane: View {
    @ObservedObject var paintState: PaintCanvasState

    var body: some View {
        ZStack {
            PaintCanvasView(state: paintState)

            // Stroke count indicator
            VStack {
                Spacer()
                HStack {
                    Label("\(paintState.strokeHistory.strokes.count) strokes",
                          systemImage: "paintbrush")
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    Spacer()
                }
                .padding(8)
            }
        }
    }
}

// MARK: - Paint Control Panel (right side when in paint mode)

struct CanvasPaintControlPanel: View {
    @ObservedObject var paintState: PaintCanvasState
    let onClose: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Paint Controls")
                        .font(.headline)
                    Spacer()
                    Button("Close", action: onClose)
                        .keyboardShortcut(.escape)
                }

                PaintCanvasControls(state: paintState)

                Divider()

                // Stroke history save/load
                tuningSectionHeader("Stroke History",
                              desc: "Save and load paint sessions.")

                HStack {
                    Button("Save Strokes") {
                        let name = "session-\(Int(Date().timeIntervalSince1970))"
                        try? paintState.strokeHistory.save(name: name)
                        NSLog("Saved \(paintState.strokeHistory.strokes.count) strokes as '\(name)'")
                    }

                    Button("Clear Canvas") {
                        paintState.canvasImage = nil
                        paintState.isReady = false
                        paintState.seed = paintState.seed &+ 1
                    }
                }

                // List saved sessions
                let saved = StrokeHistory.list()
                if !saved.isEmpty {
                    ForEach(saved, id: \.self) { name in
                        Button(name) {
                            if let history = StrokeHistory.load(name: name) {
                                replayStrokes(history)
                            }
                        }
                        .font(.system(size: 11))
                    }
                }
            }
            .padding(16)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    /// Replay a saved stroke history into the interactive canvas
    private func replayStrokes(_ history: StrokeHistory) {
        guard let sim = paintState.simulator else { return }

        paintState.isReady = false

        // Capture state before detached task — Double → Float at the Metal boundary
        let weaveScale = Float(paintState.weaveScale)
        let ridgeHeight = Float(paintState.ridgeHeight)
        let seed = paintState.seed
        let flowSteps = paintState.flowStepsPerStroke
        let drySteps = paintState.dryStepsPerStroke
        let flowStr = Float(paintState.flowStrength)
        let dryR = Float(paintState.dryRate)
        let lightAz = Float(paintState.lightAzimuth)
        let lightEl = Float(paintState.lightElevation)
        let hScale = Float(paintState.heightScale)

        Task.detached {
            sim.initCanvas(spacing: weaveScale, ridgeHeight: ridgeHeight, seed: seed)
            for stroke in history.strokes {
                let points = stroke.points.map { $0.asBrushPoint }
                sim.applyStroke(points, mode: stroke.mode)
                sim.simulate(flowSteps: flowSteps, drySteps: drySteps,
                             flowStrength: flowStr, dryRate: dryR)
            }
            let image = sim.render(lightAzimuth: lightAz, lightElevation: lightEl,
                                   heightScale: hScale)
            await MainActor.run {
                paintState.strokeHistory = history
                paintState.canvasImage = image
                paintState.isReady = true
            }
        }
    }
}
