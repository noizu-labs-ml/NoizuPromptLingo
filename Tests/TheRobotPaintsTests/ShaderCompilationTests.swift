import XCTest
import Metal
@testable import TheRobotPaints

final class ShaderCompilationTests: XCTestCase {
    private func requireDevice() throws -> MTLDevice {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw XCTSkip("Metal is not available on this device")
        }
        return device
    }

    func testCanvasInitCompiles() throws {
        let device = try requireDevice()
        XCTAssertNoThrow(
            try MetalEngine.compilePipeline(
                device: device,
                source: ShaderSource.canvasInit,
                functionName: "canvasInit"
            )
        )
    }

    func testVolumeInitCompiles() throws {
        let device = try requireDevice()
        XCTAssertNoThrow(
            try MetalEngine.compilePipeline(
                device: device,
                source: ShaderSource.volumeInit,
                functionName: "volumeInit"
            )
        )
    }

    func testRenderCompiles() throws {
        let device = try requireDevice()
        XCTAssertNoThrow(
            try MetalEngine.compilePipeline(
                device: device,
                source: ShaderSource.render,
                functionName: "render"
            )
        )
    }

    func testDepositCompiles() throws {
        let device = try requireDevice()
        XCTAssertNoThrow(
            try MetalEngine.compilePipeline(
                device: device,
                source: ShaderSource.deposit,
                functionName: "deposit"
            )
        )
    }

    func testDryingCompiles() throws {
        let device = try requireDevice()
        XCTAssertNoThrow(
            try MetalEngine.compilePipeline(
                device: device,
                source: ShaderSource.drying,
                functionName: "drying"
            )
        )
    }

    func testInstantDryCompiles() throws {
        let device = try requireDevice()
        XCTAssertNoThrow(
            try MetalEngine.compilePipeline(
                device: device,
                source: ShaderSource.drying,
                functionName: "instantDry"
            )
        )
    }

    func testGridFluidCompiles() throws {
        let device = try requireDevice()
        XCTAssertNoThrow(
            try MetalEngine.compilePipeline(
                device: device,
                source: ShaderSource.gridFluid,
                functionName: "gridFluid"
            )
        )
    }

    func testSPHBuildHashCompiles() throws {
        let device = try requireDevice()
        XCTAssertNoThrow(
            try MetalEngine.compilePipeline(
                device: device,
                source: ShaderSource.sphBuildHash,
                functionName: "sphBuildHash"
            )
        )
    }

    func testSPHComputeForcesCompiles() throws {
        let device = try requireDevice()
        XCTAssertNoThrow(
            try MetalEngine.compilePipeline(
                device: device,
                source: ShaderSource.sphComputeForces,
                functionName: "sphComputeForces"
            )
        )
    }

    func testDepositWithParticlesCompiles() throws {
        let device = try requireDevice()
        XCTAssertNoThrow(
            try MetalEngine.compilePipeline(
                device: device,
                source: ShaderSource.depositWithParticles,
                functionName: "depositWithParticles"
            )
        )
    }

    func testParticleToVolumeCompiles() throws {
        let device = try requireDevice()
        XCTAssertNoThrow(
            try MetalEngine.compilePipeline(
                device: device,
                source: ShaderSource.particleToVolume,
                functionName: "particleToVolume"
            )
        )
    }

    func testDebugWetnessCompiles() throws {
        let device = try requireDevice()
        XCTAssertNoThrow(
            try MetalEngine.compilePipeline(
                device: device,
                source: ShaderSource.debugWetness,
                functionName: "debugWetness"
            )
        )
    }

    func testDebugDepthCompiles() throws {
        let device = try requireDevice()
        XCTAssertNoThrow(
            try MetalEngine.compilePipeline(
                device: device,
                source: ShaderSource.debugDepth,
                functionName: "debugDepth"
            )
        )
    }
}
