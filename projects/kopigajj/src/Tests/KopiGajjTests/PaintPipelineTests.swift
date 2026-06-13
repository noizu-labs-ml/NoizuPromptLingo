import XCTest
import Metal
@testable import KopiGajj

final class PaintPipelineTests: XCTestCase {

    private func makeSimulator() throws -> PaintSimulator {
        _ = try TestMetalHelper.requireDevice()
        return try PaintSimulator(width: 128, height: 128)
    }

    // MARK: - Canvas Init

    func testMetal_initCanvasRuns() throws {
        let sim = try makeSimulator()
        // Should not crash
        sim.initCanvas(spacing: 4, weight: 2, ridgeHeight: 0.04, seed: 42)
    }

    func testMetal_initCanvasResetsPhase() throws {
        let sim = try makeSimulator()
        sim.field.flip()
        sim.field.flip()
        XCTAssertEqual(sim.field.phase, 2)
        sim.initCanvas()
        XCTAssertEqual(sim.field.phase, 0)
    }

    func testMetal_canvasInitWritesHeight() throws {
        let helper = try TestMetalHelper.requireDevice()
        let sim = try PaintSimulator(width: 128, height: 128)
        sim.initCanvas(ridgeHeight: 0.1, seed: 42)

        // After init, height texture should have non-zero values at most pixels
        // (canvas weave creates relief). Check a few pixels.
        var hasNonZero = false
        for coord in [(32, 32), (64, 64), (96, 96)] {
            if let h = helper.readbackFloat(from: sim.field.heightTex, x: coord.0, y: coord.1), h != 0 {
                hasNonZero = true
                break
            }
        }
        XCTAssertTrue(hasNonZero, "Canvas init should produce non-zero height values")
    }

    // MARK: - Brush Stroke

    func testMetal_applyStrokeDoesNotCrash() throws {
        let sim = try makeSimulator()
        sim.initCanvas()
        let points = TestFixtures.twoPointStroke(from: (30, 64), to: (98, 64))
        sim.applyStroke(points, mode: .oil)
    }

    func testMetal_applyStrokeDepositsWetPaint() throws {
        let helper = try TestMetalHelper.requireDevice()
        let sim = try PaintSimulator(width: 128, height: 128)
        sim.initCanvas()

        // Apply a stroke at the center
        let point = TestFixtures.singlePoint(at: (64, 64), pressure: 0.9, radius: 30,
                                             absR: 4.0, absG: 2.0, absB: 1.0)
        sim.applyStroke([point], mode: .oil)

        // Read wet absorb at stroke center — should have nonzero absorption
        if let pixel = helper.readbackFloat4(from: sim.field.readWetAbsorb, x: 64, y: 64) {
            let totalAbsorb = pixel.r + pixel.g + pixel.b
            XCTAssertGreaterThan(totalAbsorb, 0, "Stroke should deposit wet paint at center")
        }
    }

    func testMetal_emptyStrokeIsNoop() throws {
        let sim = try makeSimulator()
        sim.initCanvas()
        // Empty points array — should not crash
        sim.applyStroke([], mode: .oil)
    }

    // MARK: - Simulate

    func testMetal_simulateRuns() throws {
        let sim = try makeSimulator()
        sim.initCanvas()
        let point = TestFixtures.singlePoint(at: (64, 64))
        sim.applyStroke([point], mode: .oil)
        // Should not crash
        sim.simulate(flowSteps: 4, drySteps: 2)
    }

    func testMetal_simulateAdvancesPhase() throws {
        let sim = try makeSimulator()
        sim.initCanvas()
        XCTAssertEqual(sim.field.phase, 0)
        sim.simulate(flowSteps: 3, drySteps: 2)
        // Each flow step + each dry step flips once
        XCTAssertEqual(sim.field.phase, 5)
    }

    // MARK: - Render

    func testMetal_renderProducesImage() throws {
        let sim = try makeSimulator()
        sim.initCanvas()
        let point = TestFixtures.singlePoint(at: (64, 64))
        sim.applyStroke([point], mode: .oil)
        sim.simulate(flowSteps: 2, drySteps: 1)

        let image = sim.render()
        XCTAssertNotNil(image, "Render should produce a non-nil NSImage")
    }

    func testMetal_renderOutputDimensions() throws {
        let sim = try makeSimulator()
        sim.initCanvas()
        let image = sim.render()
        XCTAssertNotNil(image)
        XCTAssertEqual(Int(image!.size.width), 128)
        XCTAssertEqual(Int(image!.size.height), 128)
    }
}
