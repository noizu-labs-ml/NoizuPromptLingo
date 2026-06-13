import AppKit
import simd

final class BrushEngine: @unchecked Sendable {
    private var rawPoints: [SIMD2<Float>] = []
    private var rawPressures: [Float] = []

    private var currentStroke: StrokeRecord?
    private var pressureSource: (any PressureSource)?
    private var pendingBrushPoints: [BrushPoint] = []

    var brushParams: BrushParams = BrushParams()

    func startStroke(event: NSEvent, canvasPoint: CGPoint) {
        pressureSource = PressureSourceFactory.detect(from: event)
        let pressure = pressureSource!.pressure(for: event)

        rawPoints = [SIMD2<Float>(Float(canvasPoint.x), Float(canvasPoint.y))]
        rawPressures = [pressure]

        currentStroke = StrokeRecord(
            brushParams: brushParams,
            points: [],
            targetLayer: Int(brushParams.activeLayer))

        let bp = BrushPoint(
            positionX: Float(canvasPoint.x),
            positionY: Float(canvasPoint.y),
            pressure: pressure,
            size: brushParams.size * pressure)
        pendingBrushPoints.append(bp)
    }

    func addPoint(event: NSEvent, canvasPoint: CGPoint) {
        guard pressureSource != nil else { return }
        let pressure = pressureSource!.pressure(for: event)

        let pos = SIMD2<Float>(Float(canvasPoint.x), Float(canvasPoint.y))
        rawPoints.append(pos)
        rawPressures.append(pressure)

        if rawPoints.count > 4 {
            rawPoints.removeFirst()
            rawPressures.removeFirst()
        }

        guard rawPoints.count >= 4 else {
            let bp = BrushPoint(
                positionX: pos.x, positionY: pos.y,
                pressure: pressure,
                size: brushParams.size * pressure)
            pendingBrushPoints.append(bp)
            return
        }

        interpolateSegment(
            p0: rawPoints[0], p1: rawPoints[1],
            p2: rawPoints[2], p3: rawPoints[3],
            pr0: rawPressures[1], pr1: rawPressures[2])
    }

    func endStroke() -> StrokeRecord? {
        defer {
            rawPoints.removeAll()
            rawPressures.removeAll()
            pressureSource = nil
            currentStroke = nil
        }
        guard var stroke = currentStroke else { return nil }
        stroke = StrokeRecord(
            brushParams: stroke.brushParams,
            points: stroke.points + pendingBrushPoints,
            targetLayer: stroke.targetLayer)
        pendingBrushPoints.removeAll()
        return stroke
    }

    func flushPoints() -> [BrushPoint] {
        let result = pendingBrushPoints
        pendingBrushPoints.removeAll(keepingCapacity: true)
        return result
    }

    private func interpolateSegment(
        p0: SIMD2<Float>, p1: SIMD2<Float>,
        p2: SIMD2<Float>, p3: SIMD2<Float>,
        pr0: Float, pr1: Float
    ) {
        let segmentLength = simd_distance(p1, p2)
        guard segmentLength > 0 else { return }

        let effectiveSize = brushParams.size * ((pr0 + pr1) * 0.5)
        let spacing = max(1.0, effectiveSize * brushParams.spacing)
        let steps = max(1, Int(segmentLength / spacing))

        for i in 0..<steps {
            let t = Float(i) / Float(steps)
            let pos = Self.catmullRom(p0: p0, p1: p1, p2: p2, p3: p3, t: t)
            let pressure = pr0 + (pr1 - pr0) * t

            let bp = BrushPoint(
                positionX: pos.x, positionY: pos.y,
                pressure: pressure,
                size: brushParams.size * pressure)
            pendingBrushPoints.append(bp)
        }
    }

    static func catmullRom(
        p0: SIMD2<Float>, p1: SIMD2<Float>,
        p2: SIMD2<Float>, p3: SIMD2<Float>,
        t: Float
    ) -> SIMD2<Float> {
        let t2 = t * t
        let t3 = t2 * t
        let a: SIMD2<Float> = 2.0 * p1
        let b: SIMD2<Float> = (-p0 + p2) * t
        let c: SIMD2<Float> = (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2
        let d: SIMD2<Float> = (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
        return 0.5 * (a + b + c + d)
    }
}
