import Foundation

/// Generates procedural brush stroke patterns for the canvas background.
///
/// Produces BrushStroke arrays that, when applied through the paint simulator,
/// create an oil-on-canvas aesthetic without manual painting.
enum ProceduralStrokes {

    /// Generate a full set of background strokes for the popup canvas.
    ///
    /// Creates layered strokes: large washes first, then detail strokes.
    /// All coordinates in texel space (0..<fieldSize).
    static func generateBackground(
        fieldSize: Int = 1024,
        strokeCount: Int = 20,
        seed: UInt64 = 42
    ) -> [BrushStroke] {
        var rng = PRNG(seed: seed)
        var strokes: [BrushStroke] = []

        let size = Float(fieldSize)

        // Phase 1: Large wash strokes (warm base layer)
        let washColors: [(Float, Float, Float)] = [
            (0.92, 0.88, 0.82),  // warm cream
            (0.90, 0.85, 0.78),  // light sienna
            (0.88, 0.84, 0.76),  // warm linen
            (0.94, 0.90, 0.84),  // pale ivory
        ]

        for i in 0..<min(strokeCount / 3, 6) {
            let color = washColors[i % washColors.count]
            let stroke = generateSweepStroke(
                from: CGPoint(x: Double.random(in: -0.1...0.3, using: &rng) * Double(size),
                              y: Double.random(in: 0...1, using: &rng) * Double(size)),
                to: CGPoint(x: Double.random(in: 0.7...1.1, using: &rng) * Double(size),
                            y: Double.random(in: 0...1, using: &rng) * Double(size)),
                color: color,
                radius: Float.random(in: 40...80, using: &rng),
                pressure: Float.random(in: 0.4...0.7, using: &rng),
                viscosity: 0.8,
                mode: .oil,
                controlPoints: 3,
                samplesPerSegment: 30,
                rng: &rng
            )
            strokes.append(stroke)
        }

        // Phase 2: Medium directional strokes (adds texture variety)
        let detailColors: [(Float, Float, Float)] = [
            (0.85, 0.78, 0.68),  // warm ochre
            (0.80, 0.72, 0.60),  // raw sienna
            (0.75, 0.70, 0.62),  // warm grey
            (0.88, 0.82, 0.74),  // buff
            (0.70, 0.65, 0.55),  // umber hint
        ]

        for i in 0..<(strokeCount * 2 / 3) {
            let color = detailColors[i % detailColors.count]
            let startX = Float.random(in: 0...size, using: &rng)
            let startY = Float.random(in: 0...size, using: &rng)
            let angle = Float.random(in: -0.5...0.5, using: &rng) // mostly horizontal
            let length = Float.random(in: 80...300, using: &rng)

            let stroke = generateSweepStroke(
                from: CGPoint(x: Double(startX), y: Double(startY)),
                to: CGPoint(x: Double(startX + cos(angle) * length),
                            y: Double(startY + sin(angle) * length)),
                color: color,
                radius: Float.random(in: 12...35, using: &rng),
                pressure: Float.random(in: 0.3...0.8, using: &rng),
                viscosity: Float.random(in: 0.6...0.95, using: &rng),
                mode: .oil,
                controlPoints: Int.random(in: 2...4, using: &rng),
                samplesPerSegment: 20,
                rng: &rng
            )
            strokes.append(stroke)
        }

        // Phase 3: A few thin watercolor washes for depth
        for _ in 0..<max(strokeCount / 5, 2) {
            let stroke = generateSweepStroke(
                from: CGPoint(x: Double.random(in: 0...1, using: &rng) * Double(size),
                              y: Double.random(in: 0...0.3, using: &rng) * Double(size)),
                to: CGPoint(x: Double.random(in: 0...1, using: &rng) * Double(size),
                            y: Double.random(in: 0.7...1, using: &rng) * Double(size)),
                color: (0.60, 0.55, 0.70), // cool indigo wash
                radius: Float.random(in: 50...120, using: &rng),
                pressure: Float.random(in: 0.1...0.3, using: &rng),
                viscosity: 0.15,
                mode: .watercolor,
                controlPoints: 4,
                samplesPerSegment: 25,
                rng: &rng
            )
            strokes.append(stroke)
        }

        return strokes
    }

    // MARK: - Stroke generation

    /// Generate a curved brush stroke from A to B via random control points.
    private static func generateSweepStroke(
        from: CGPoint, to: CGPoint,
        color: (Float, Float, Float),
        radius: Float, pressure: Float, viscosity: Float,
        mode: BrushMode,
        controlPoints: Int,
        samplesPerSegment: Int,
        rng: inout PRNG
    ) -> BrushStroke {
        // Generate random control points between start and end
        var controls: [CGPoint] = [from]
        for i in 1..<controlPoints {
            let t = Double(i) / Double(controlPoints)
            let base = CGPoint(
                x: from.x + (to.x - from.x) * t,
                y: from.y + (to.y - from.y) * t
            )
            let perpLen = Double(radius) * 2
            controls.append(CGPoint(
                x: base.x + Double.random(in: -perpLen...perpLen, using: &rng),
                y: base.y + Double.random(in: -perpLen...perpLen, using: &rng)
            ))
        }
        controls.append(to)

        // Sample along the piecewise Bezier
        var points: [CodableBrushPoint] = []
        let totalSamples = samplesPerSegment * (controls.count - 1)

        // First pass: compute positions
        var positions: [CGPoint] = []
        for i in 0...totalSamples {
            let t = Double(i) / Double(totalSamples)
            positions.append(catmullRomSample(controls: controls, t: t))
        }

        // Second pass: compute directions + build points
        for i in 0...totalSamples {
            let pos = positions[i]
            let t = Double(i) / Double(totalSamples)

            // Direction from previous to next point (central difference)
            let prev = i > 0 ? positions[i - 1] : positions[0]
            let next = i < totalSamples ? positions[i + 1] : positions[totalSamples]
            let dx = Float(next.x - prev.x)
            let dy = Float(next.y - prev.y)
            let dirLen = sqrt(dx * dx + dy * dy)
            let dirX = dirLen > 0.01 ? dx / dirLen : Float(1)
            let dirY = dirLen > 0.01 ? dy / dirLen : Float(0)

            let taperT = min(t * 4, 1) * min((1 - t) * 4, 1)
            let p = pressure * Float(taperT) * Float.random(in: 0.8...1.0, using: &rng)
            let r = radius * Float.random(in: 0.85...1.15, using: &rng)
            let cShift = Float.random(in: -0.03...0.03, using: &rng)

            // Convert reflectance color to absorption via Beer-Lambert
            let aR = PaintMath.reflectanceToAbsorption(color.0 + cShift)
            let aG = PaintMath.reflectanceToAbsorption(color.1 + cShift)
            let aB = PaintMath.reflectanceToAbsorption(color.2 + cShift)

            points.append(CodableBrushPoint(
                x: Float(pos.x), y: Float(pos.y),
                pressure: p, radius: r,
                absR: aR, absG: aG, absB: aB, concentration: 1.0,
                viscosity: viscosity,
                dirX: dirX, dirY: dirY
            ))
        }

        return BrushStroke(points: points, mode: mode)
    }

    /// Catmull-Rom spline interpolation through control points.
    private static func catmullRomSample(controls: [CGPoint], t: Double) -> CGPoint {
        let n = controls.count - 1
        let scaled = t * Double(n)
        let segment = min(Int(scaled), n - 1)
        let local = scaled - Double(segment)

        // Get 4 points for Catmull-Rom (clamped at boundaries)
        let p0 = controls[max(segment - 1, 0)]
        let p1 = controls[segment]
        let p2 = controls[min(segment + 1, n)]
        let p3 = controls[min(segment + 2, n)]

        let tt = local
        let tt2 = tt * tt
        let tt3 = tt2 * tt

        let x = 0.5 * ((2 * p1.x) +
            (-p0.x + p2.x) * tt +
            (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * tt2 +
            (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * tt3)

        let y = 0.5 * ((2 * p1.y) +
            (-p0.y + p2.y) * tt +
            (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * tt2 +
            (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * tt3)

        return CGPoint(x: x, y: y)
    }
}

// MARK: - Seeded PRNG

/// Xorshift64-based PRNG for deterministic procedural generation.
struct PRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
