import XCTest
@testable import KopiGajj

final class StructLayoutTests: XCTestCase {

    // MARK: - BrushPoint

    func testBrushPointSize() {
        XCTAssertEqual(MemoryLayout<BrushPoint>.size, 56)
    }

    func testBrushPointStride() {
        XCTAssertEqual(MemoryLayout<BrushPoint>.stride, 56)
    }

    func testBrushPointStaticStride() {
        XCTAssertEqual(BrushPoint.stride, 56)
    }

    func testBrushPointFieldCount() {
        // 14 Float fields × 4 bytes = 56 bytes
        XCTAssertEqual(MemoryLayout<BrushPoint>.size, 14 * MemoryLayout<Float>.size)
    }

    // MARK: - CanvasGPUParams

    func testCanvasGPUParamsSize() {
        // 3 Float + 1 UInt32 + 2 Int32 + 3 Float + 1 Float(_pad) = 10 × 4 = 40
        XCTAssertEqual(MemoryLayout<PaintSimulator.CanvasGPUParams>.size, 40)
    }

    func testCanvasGPUParamsStride() {
        XCTAssertEqual(MemoryLayout<PaintSimulator.CanvasGPUParams>.stride, 40)
    }

    // MARK: - SimGPUParams

    func testSimGPUParamsSize() {
        // 5 Float = 20 bytes
        XCTAssertEqual(MemoryLayout<PaintSimulator.SimGPUParams>.size, 20)
    }

    func testSimGPUParamsStride() {
        XCTAssertEqual(MemoryLayout<PaintSimulator.SimGPUParams>.stride, 20)
    }

    // MARK: - RenderGPUParams

    func testRenderGPUParamsSize() {
        // 10 Float + 1 Int32 + 1 Float(_pad) = 48 bytes
        XCTAssertEqual(MemoryLayout<PaintSimulator.RenderGPUParams>.size, 48)
    }

    func testRenderGPUParamsStride() {
        XCTAssertEqual(MemoryLayout<PaintSimulator.RenderGPUParams>.stride, 48)
    }
}
