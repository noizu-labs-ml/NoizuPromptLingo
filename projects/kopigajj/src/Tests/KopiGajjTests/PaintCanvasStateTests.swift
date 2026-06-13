import XCTest
@testable import KopiGajj

final class PaintCanvasStateTests: XCTestCase {

    func testDefaultValues() {
        let state = PaintCanvasState()
        XCTAssertEqual(state.brushMode, .oil)
        XCTAssertEqual(state.brushTip, .round)
        XCTAssertEqual(state.brushAngle, 0, accuracy: 0.001)
        XCTAssertEqual(state.brushRadius, 20, accuracy: 0.001)
        XCTAssertEqual(state.brushPressure, 0.6, accuracy: 0.001)
        XCTAssertEqual(state.pressureCurve, 1.5, accuracy: 0.001)
        XCTAssertEqual(state.paintThickness, 1.0, accuracy: 0.001)
        XCTAssertEqual(state.pigmentDilution, 1.0, accuracy: 0.001)
        XCTAssertEqual(state.flowStepsPerStroke, 20)
        XCTAssertEqual(state.dryStepsPerStroke, 10)
        XCTAssertEqual(state.flowStrength, 0.5, accuracy: 0.001)
        XCTAssertEqual(state.dryRate, 0.1, accuracy: 0.001)
        XCTAssertEqual(state.diffusionRate, 0.3, accuracy: 0.001)
        XCTAssertEqual(state.edgeDarken, 0.3, accuracy: 0.001)
        XCTAssertEqual(state.ridgeHeight, 0.04, accuracy: 0.001)
        XCTAssertEqual(state.weaveScale, 4.0, accuracy: 0.001)
        XCTAssertEqual(state.seed, 42)
        XCTAssertEqual(state.lightAzimuth, 45, accuracy: 0.001)
        XCTAssertEqual(state.lightElevation, 60, accuracy: 0.001)
        XCTAssertEqual(state.heightScale, 16.0, accuracy: 0.001)
    }

    func testRenderModeDefault() {
        let state = PaintCanvasState()
        XCTAssertEqual(state.renderMode, .lit)
    }

    func testPresetTableHasAllCombinations() {
        // Every BrushMode × BrushTip combination should have a preset
        for mode in BrushMode.allCases {
            for tip in BrushTip.allCases {
                XCTAssertNotNil(
                    PaintCanvasState.presets[mode]?[tip],
                    "Missing preset for \(mode) × \(tip)"
                )
            }
        }
    }

    func testPresetCount() {
        let totalPresets = PaintCanvasState.presets.values.flatMap { $0.values }.count
        // 5 modes × 5 tips = 25
        XCTAssertEqual(totalPresets, 25)
    }
}
