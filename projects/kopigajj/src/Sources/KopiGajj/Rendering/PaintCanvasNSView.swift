import SwiftUI
import AppKit

/// NSView that handles mouse events and renders the paint field.
class PaintCanvasNSView: NSView {
    var state: PaintCanvasState
    private var currentStrokePoints: [CodableBrushPoint] = []
    private var lastPoint: NSPoint?
    private var pendingPoints: [CodableBrushPoint] = []
    private var lastRenderTime: CFAbsoluteTime = 0
    private var renderScheduled = false
    /// Minimum interval between GPU render dispatches (~60fps).
    private let renderThrottleInterval: CFAbsoluteTime = 1.0 / 60.0
    /// Last 4 raw mouse locations for Catmull-Rom interpolation.
    private var recentRawPoints: [NSPoint] = []

    init(state: PaintCanvasState) {
        self.state = state
        super.init(frame: .zero)

        // Initialize simulator on a background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let sim = try PaintSimulator(width: 1024, height: 1024)
                sim.initCanvas(
                    spacing: Float(state.weaveScale),
                    ridgeHeight: Float(state.ridgeHeight),
                    seed: state.seed
                )
                let image = sim.render(
                    lightAzimuth: Float(state.lightAzimuth),
                    lightElevation: Float(state.lightElevation),
                    heightScale: Float(state.heightScale),
                    renderMode: Int32(state.renderMode.rawValue)
                )
                DispatchQueue.main.async {
                    self?.state.simulator = sim
                    self?.state.canvasImage = image
                    self?.state.isReady = true
                    self?.needsDisplay = true
                    // Auto-start time simulation so paint dries/flows without needing "Play"
                    self?.state.simPlaying = true
                    self?.state.updateTimer()
                }
            } catch {
                NSLog("❌ Paint canvas init failed: \(error)")
            }
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override var acceptsFirstResponder: Bool { true }
    override var isFlipped: Bool { true }
    override var mouseDownCanMoveWindow: Bool { false }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        if let image = state.canvasImage,
           let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            ctx.draw(cgImage, in: bounds)
        } else {
            // Placeholder
            ctx.setFillColor(NSColor.darkGray.cgColor)
            ctx.fill(bounds)
            let str = "Initializing canvas..." as NSString
            str.draw(at: NSPoint(x: bounds.midX - 60, y: bounds.midY - 8),
                     withAttributes: [.foregroundColor: NSColor.white,
                                      .font: NSFont.systemFont(ofSize: 14)])
        }
    }

    // MARK: - Mouse handling

    override func mouseDown(with event: NSEvent) {
        guard state.isReady else { return }
        currentStrokePoints = []
        lastPoint = nil
        recentRawPoints = []
        addPoint(from: event)
    }

    override func mouseDragged(with event: NSEvent) {
        guard state.isReady else { return }
        addPoint(from: event)
    }

    override func mouseUp(with event: NSEvent) {
        // Emit final interpolated segment to close the curve
        if recentRawPoints.count >= 2 {
            let loc = convert(event.locationInWindow, from: nil)
            emitBrushPoint(at: loc, from: event)
        }
        // Flush any pending render
        flushPendingRender()
        recentRawPoints = []

        guard state.isReady, !currentStrokePoints.isEmpty else { return }

        // Finalize stroke
        let stroke = BrushStroke(points: currentStrokePoints, mode: state.brushMode)
        state.strokeHistory.strokes.append(stroke)

        // Capture state on main thread, convert Double → Float for Metal boundary
        let flowSteps = state.flowStepsPerStroke
        let drySteps = state.dryStepsPerStroke
        let flowStr = Float(state.flowStrength)
        let diffRate = Float(state.diffusionRate)
        let dryR = Float(state.dryRate)
        let edgeD = Float(state.edgeDarken)
        let lightAz = Float(state.lightAzimuth)
        let lightEl = Float(state.lightElevation)
        let hScale = Float(state.heightScale)
        let rMode = Int32(state.renderMode.rawValue)

        // Run simulation steps after stroke completes
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self, let sim = self.state.simulator else { return }
            sim.simulate(
                flowSteps: flowSteps,
                drySteps: drySteps,
                flowStrength: flowStr,
                diffusionRate: diffRate,
                dryRate: dryR,
                edgeDarken: edgeD
            )
            let image = sim.render(
                lightAzimuth: lightAz,
                lightElevation: lightEl,
                heightScale: hScale,
                renderMode: rMode
            )
            DispatchQueue.main.async {
                self.state.canvasImage = image
                self.needsDisplay = true
            }
        }

        currentStrokePoints = []
        lastPoint = nil
    }

    // MARK: - Catmull-Rom interpolation

    /// Interpolate between p1 and p2 using Catmull-Rom with 4 control points.
    private func catmullRom(_ p0: NSPoint, _ p1: NSPoint, _ p2: NSPoint, _ p3: NSPoint, t: CGFloat) -> NSPoint {
        PaintMath.catmullRom(p0, p1, p2, p3, t: t)
    }

    // MARK: - Point conversion

    private func addPoint(from event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)

        // Skip if too close to last raw point
        if let last = recentRawPoints.last, hypot(loc.x - last.x, loc.y - last.y) < 2 {
            return
        }

        recentRawPoints.append(loc)

        // Need at least 3 points for Catmull-Rom (use duplication for endpoints)
        if recentRawPoints.count >= 3 {
            let n = recentRawPoints.count
            let p0 = recentRawPoints[max(n - 4, 0)]
            let p1 = recentRawPoints[n - 3]
            let p2 = recentRawPoints[n - 2]
            let p3 = recentRawPoints[n - 1]

            // Subdivide the segment p1→p2 based on distance
            let segLen = hypot(p2.x - p1.x, p2.y - p1.y)
            let stepSize: CGFloat = 2.0  // dense interpolation for smooth strokes
            let steps = max(Int(segLen / stepSize), 1)

            for i in 0..<steps {
                let t = CGFloat(i) / CGFloat(steps)
                let interp = catmullRom(p0, p1, p2, p3, t: t)
                emitBrushPoint(at: interp, from: event)
            }
        } else if recentRawPoints.count == 2 {
            // Linear interpolation before Catmull-Rom has enough control points
            let p0 = recentRawPoints[0]
            let p1 = recentRawPoints[1]
            let segLen = hypot(p1.x - p0.x, p1.y - p0.y)
            let stepSize: CGFloat = 2.0
            let steps = max(Int(segLen / stepSize), 1)
            for i in 1...steps {
                let t = CGFloat(i) / CGFloat(steps)
                let interp = NSPoint(x: p0.x + (p1.x - p0.x) * t,
                                     y: p0.y + (p1.y - p0.y) * t)
                emitBrushPoint(at: interp, from: event)
            }
        } else if recentRawPoints.count == 1 {
            // First point — emit directly
            emitBrushPoint(at: loc, from: event)
        }

        // Keep only last 4 raw points
        if recentRawPoints.count > 4 {
            recentRawPoints.removeFirst(recentRawPoints.count - 4)
        }
    }

    /// Build a CodableBrushPoint (Float, for Metal) from view coordinates and current state (Double).
    private func emitBrushPoint(at loc: NSPoint, from event: NSEvent) {
        // Convert view coordinates to texel coordinates (1024×1024 field)
        let scaleX = Float(1024) / Float(bounds.width)
        let scaleY = Float(1024) / Float(bounds.height)

        // Use tablet pressure if available (Wacom, Apple Pencil via Sidecar),
        // otherwise fall back to the slider value
        let rawPressure: Float = {
            let tabletPressure = event.pressure  // 0-1 from tablet hardware
            if tabletPressure > 0 && event.subtype == .tabletPoint {
                return tabletPressure
            }
            return Float(state.brushPressure)
        }()
        let curved = pow(rawPressure, Float(state.pressureCurve)) * Float(state.paintThickness)

        let color = state.brushColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Convert reflectance (0-1) to absorption (0-8) via Beer-Lambert
        // Transparent mode: zero absorption, signal via negative concentration (-1)
        // Shader reads concentration < 0 as "transparent mode" — deposit grain/wetness only
        let absR: Float, absG: Float, absB: Float
        if state.isTransparent {
            absR = 0; absG = 0; absB = 0
        } else {
            absR = PaintMath.reflectanceToAbsorption(Float(r))
            absG = PaintMath.reflectanceToAbsorption(Float(g))
            absB = PaintMath.reflectanceToAbsorption(Float(b))
        }

        // NSView isFlipped=true → loc.y is top-down, matching Metal texture coords
        // But CGContext.draw flips the rendered image, so invert Y to compensate
        let flippedY = Float(bounds.height - loc.y)

        let viscosity: Float = {
            switch state.brushMode {
            case .oil: return 0.85
            case .watercolor: return Float(0.05 + (1.0 - state.brushWetness) * 0.25)  // wet=0.05(fluid), dry=0.30(sticky)
            case .acrylic: return 0.7
            case .pastel: return 0.95
            case .highlighter: return 0.15  // felt-tip marker — very fluid, no drag
            }
        }()

        // Compute stroke travel direction from last point
        var dirX: Float = 1, dirY: Float = 0
        if let last = lastPoint {
            let dx = Float(loc.x - last.x)
            let dy = flippedY - Float(bounds.height - last.y)
            let len = sqrt(dx * dx + dy * dy)
            if len > 0.5 {
                dirX = dx / len
                dirY = dy / len
            }
        }

        // Watercolor wetness — other media get a neutral default
        // Transparent watercolor gets full wetness to drive diffusion of existing colors
        let wetness: Float
        if state.isTransparent && state.brushMode == .watercolor {
            wetness = max(Float(state.brushWetness), 0.8)  // ensure plenty of water
        } else if state.brushMode == .watercolor {
            wetness = Float(state.brushWetness)
        } else {
            wetness = 0.5
        }

        // Transparent mode signals via concentration = -1 so the shader knows
        // to deposit grain/wetness without color
        let concentration: Float = state.isTransparent ? -1.0 : Float(state.pigmentDilution)

        let point = CodableBrushPoint(
            x: Float(loc.x) * scaleX,
            y: flippedY * scaleY,
            pressure: curved,
            radius: Float(state.brushRadius) * scaleX,
            absR: absR, absG: absG, absB: absB, concentration: concentration,
            viscosity: viscosity,
            tipType: state.brushTip.tipIndex,
            angle: Float(state.brushAngle),
            dirX: dirX,
            dirY: dirY,
            wetness: wetness
        )

        currentStrokePoints.append(point)
        pendingPoints.append(point)
        lastPoint = loc  // Set AFTER direction calculation so next call sees previous position

        // Throttle GPU dispatch to ~60fps to avoid queueing excessive work
        let now = CFAbsoluteTimeGetCurrent()
        if now - lastRenderTime >= renderThrottleInterval {
            flushPendingRender()
        } else if !renderScheduled {
            renderScheduled = true
            let delay = renderThrottleInterval - (now - lastRenderTime)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.renderScheduled = false
                self?.flushPendingRender()
            }
        }
    }

    /// Flush accumulated points to GPU in a single batch.
    private func flushPendingRender() {
        guard !pendingPoints.isEmpty, let sim = state.simulator else { return }
        let batch = pendingPoints.map { $0.asBrushPoint }
        pendingPoints.removeAll()
        lastRenderTime = CFAbsoluteTimeGetCurrent()

        let brushMode = state.brushMode
        let lightAz = Float(state.lightAzimuth)
        let lightEl = Float(state.lightElevation)
        let hScale = Float(state.heightScale)
        let rMode = Int32(state.renderMode.rawValue)

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            sim.applyStroke(batch, mode: brushMode)
            let image = sim.render(
                lightAzimuth: lightAz, lightElevation: lightEl,
                heightScale: hScale, renderMode: rMode
            )
            DispatchQueue.main.async {
                self?.state.canvasImage = image
                self?.needsDisplay = true
            }
        }
    }

    // MARK: - Public actions

    func clearCanvas() {
        guard let sim = state.simulator else { return }
        sim.initCanvas(spacing: Float(state.weaveScale), ridgeHeight: Float(state.ridgeHeight), seed: state.seed)
        state.strokeHistory = StrokeHistory()
        if let image = sim.render(
            lightAzimuth: Float(state.lightAzimuth),
            lightElevation: Float(state.lightElevation),
            heightScale: Float(state.heightScale)
        ) {
            state.canvasImage = image
            needsDisplay = true
        }
    }
}
