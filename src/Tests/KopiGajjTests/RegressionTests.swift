import XCTest
import Metal
@testable import KopiGajj

final class RegressionTests: XCTestCase {

    // MARK: - Line Segment Coverage

    func testMetal_lineSegmentCoverage() throws {
        let helper = try TestMetalHelper.requireDevice()
        let sim = try PaintSimulator(width: 128, height: 128)
        sim.initCanvas()

        // Two brush points 50px apart along y=64
        let points = TestFixtures.twoPointStroke(
            from: (30, 64), to: (80, 64),
            pressure: 0.8, radius: 15,
            absR: 4.0, absG: 2.0, absB: 1.0
        )
        sim.applyStroke(points, mode: .oil)

        // Check midpoint (55, 64) — should have wet paint absorption > 0
        if let pixel = helper.readbackFloat4(from: sim.field.readWetAbsorb, x: 55, y: 64) {
            let totalAbsorb = pixel.r + pixel.g + pixel.b
            XCTAssertGreaterThan(totalAbsorb, 0,
                "Midpoint between two stroke points should have paint absorption > 0")
        } else {
            XCTFail("Failed to read back wet absorb texture")
        }
    }

    // MARK: - Acrylic Drying Preserves Color

    func testMetal_acrylicDryingPreservesColor() throws {
        let helper = try TestMetalHelper.requireDevice()
        let sim = try PaintSimulator(width: 128, height: 128)
        sim.initCanvas()

        // Apply acrylic stroke
        let point = TestFixtures.singlePoint(
            at: (64, 64), pressure: 0.9, radius: 25,
            absR: 3.0, absG: 1.0, absB: 0.5,
            concentration: 1.0, viscosity: 0.8
        )
        sim.applyStroke([point], mode: .acrylic)

        // Read wet absorption before drying
        let wetBefore = helper.readbackFloat4(from: sim.field.readWetAbsorb, x: 64, y: 64)

        // Run 30 dry steps to transfer wet → solid
        sim.simulate(flowSteps: 0, drySteps: 30, dryRate: 0.3)

        // Read solid absorption after drying
        let solidAfter = helper.readbackFloat4(from: sim.field.solidAbsorbTex, x: 64, y: 64)

        // If there was wet paint deposited, solid should have picked up some color
        if let wet = wetBefore, (wet.r + wet.g + wet.b) > 0 {
            guard let solid = solidAfter else {
                XCTFail("Failed to read solid absorb after drying")
                return
            }
            let solidTotal = solid.r + solid.g + solid.b
            XCTAssertGreaterThan(solidTotal, 0,
                "After drying, solid layer should have absorbed pigment from wet layer")
        }
    }

    // MARK: - Catmull-Rom count=2 linear interpolation

    func testCatmullRom_linearInterpolation() {
        // With collinear points, Catmull-Rom should produce linear interpolation
        let p0 = CGPoint(x: 0, y: 0)
        let p1 = CGPoint(x: 10, y: 10)
        let p2 = CGPoint(x: 20, y: 20)
        let p3 = CGPoint(x: 30, y: 30)

        // Check several t values
        for i in 0...10 {
            let t = CGFloat(i) / 10.0
            let result = PaintMath.catmullRom(p0, p1, p2, p3, t: t)
            let expected = 10.0 + t * 10.0  // linear from 10 to 20
            XCTAssertEqual(result.x, expected, accuracy: 0.5,
                "Catmull-Rom at t=\(t) should be linear for collinear points")
            XCTAssertEqual(result.y, expected, accuracy: 0.5)
        }
    }

    // MARK: - Height normalization

    func testMetal_heightNormalized() throws {
        let helper = try TestMetalHelper.requireDevice()
        let sim = try PaintSimulator(width: 128, height: 128)
        sim.initCanvas(ridgeHeight: 0.04)

        // Apply many overlapping strokes at the same location
        for _ in 0..<20 {
            let point = TestFixtures.singlePoint(
                at: (64, 64), pressure: 1.0, radius: 10,
                absR: 3.0, absG: 2.0, absB: 1.0
            )
            sim.applyStroke([point], mode: .oil)
        }

        // Height should be reasonable — not astronomically large
        if let h = helper.readbackFloat(from: sim.field.heightTex, x: 64, y: 64) {
            // Height includes canvas relief + paint. With 20 overlapping strokes,
            // it should still be bounded (shader clamps or limits accumulation).
            // We just check it's finite and not excessively large.
            XCTAssertTrue(h.isFinite, "Height should be finite")
            XCTAssertLessThan(h, 100.0, "Height should not accumulate excessively")
        } else {
            XCTFail("Failed to read back height texture")
        }
    }

    // MARK: - Render produces non-black output after stroke

    func testMetal_renderAfterStrokeProducesColor() throws {
        let helper = try TestMetalHelper.requireDevice()
        let sim = try PaintSimulator(width: 128, height: 128)
        sim.initCanvas()

        let point = TestFixtures.singlePoint(at: (64, 64), pressure: 0.8, radius: 20)
        sim.applyStroke([point], mode: .oil)
        sim.simulate(flowSteps: 2, drySteps: 1)
        _ = sim.render()

        // Output texture should have non-zero alpha at center
        if let pixel = helper.readbackRGBA8(from: sim.field.outputTex, x: 64, y: 64) {
            XCTAssertGreaterThan(pixel.a, 0, "Rendered pixel should have non-zero alpha")
        }
    }
}
