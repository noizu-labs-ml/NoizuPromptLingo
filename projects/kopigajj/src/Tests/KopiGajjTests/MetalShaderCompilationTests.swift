import XCTest
import Metal
@testable import KopiGajj

final class MetalShaderCompilationTests: XCTestCase {

    func testMetal_allPaintKernelsCompile() throws {
        let helper = try TestMetalHelper.requireDevice()
        let device = helper.device

        let kernels: [(source: String, name: String)] = [
            (PaintShaderSource.canvasInit, "canvasInit"),
            (PaintShaderSource.brushStroke, "brushStroke"),
            (PaintShaderSource.flowStep, "flowStep"),
            (PaintShaderSource.dryStep, "dryStep"),
            (PaintShaderSource.render, "paintRender"),
        ]

        for (source, name) in kernels {
            XCTAssertNoThrow(
                try PaintSimulator.compileComputePipeline(device: device, source: source, functionName: name),
                "Failed to compile kernel: \(name)"
            )
        }
    }

    func testMetal_paintSimulatorInitSmall() throws {
        _ = try TestMetalHelper.requireDevice()
        // PaintSimulator.init compiles all 5 kernels + allocates PaintField textures
        XCTAssertNoThrow(try PaintSimulator(width: 64, height: 64))
    }

    func testMetal_invalidFunctionNameThrows() throws {
        let helper = try TestMetalHelper.requireDevice()
        XCTAssertThrowsError(
            try PaintSimulator.compileComputePipeline(
                device: helper.device,
                source: PaintShaderSource.canvasInit,
                functionName: "nonexistentKernel"
            )
        )
    }
}
