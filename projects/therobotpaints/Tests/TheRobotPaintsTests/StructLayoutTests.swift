import XCTest
@testable import TheRobotPaints

final class StructLayoutTests: XCTestCase {
    func testVolumeLayerIs32Bytes() {
        XCTAssertEqual(MemoryLayout<VolumeLayer>.size, 32, "VolumeLayer must be exactly 32 bytes")
        XCTAssertEqual(MemoryLayout<VolumeLayer>.stride, 32, "VolumeLayer stride must be 32 bytes")
    }

    func testVolumeLayerAlignment() {
        XCTAssertEqual(MemoryLayout<VolumeLayer>.alignment, 2, "VolumeLayer alignment should be 2 (half)")
    }

    func testVolumeLayerFieldOffsets() {
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.colorR), 0)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.colorG), 2)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.colorB), 4)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.colorO), 6)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.depth), 8)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.wetness), 10)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.viscosity), 12)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.hardness), 14)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.velocityX), 16)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.velocityY), 18)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.surfaceTension), 20)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.age), 22)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.gloss), 24)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.substanceType), 26)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \.flags), 28)
        XCTAssertEqual(MemoryLayout<VolumeLayer>.offset(of: \._padding), 30)
    }

    func testSimParamsLayout() {
        XCTAssertEqual(MemoryLayout<SimParams>.size, 16, "SimParams: 3 × UInt32 + Float = 16 bytes")
    }

    func testRenderParamsLayout() {
        XCTAssertEqual(MemoryLayout<RenderParams>.size, 12, "RenderParams: 3 × UInt32 = 12 bytes")
    }

    func testLightParamsLayout() {
        XCTAssertEqual(MemoryLayout<LightParams>.size, 16, "LightParams: 4 × Float = 16 bytes")
    }

    func testViewParamsLayout() {
        XCTAssertEqual(MemoryLayout<ViewParams>.size, 40, "ViewParams: 6 × Float + 4 × UInt32 = 40 bytes")
    }

    func testBrushPointIs32Bytes() {
        XCTAssertEqual(MemoryLayout<BrushPoint>.size, 32, "BrushPoint must be exactly 32 bytes")
        XCTAssertEqual(MemoryLayout<BrushPoint>.stride, 32, "BrushPoint stride must be 32 bytes")
    }

    func testBrushPointFieldOffsets() {
        XCTAssertEqual(MemoryLayout<BrushPoint>.offset(of: \.positionX), 0)
        XCTAssertEqual(MemoryLayout<BrushPoint>.offset(of: \.positionY), 4)
        XCTAssertEqual(MemoryLayout<BrushPoint>.offset(of: \.pressure), 8)
        XCTAssertEqual(MemoryLayout<BrushPoint>.offset(of: \.tiltX), 12)
        XCTAssertEqual(MemoryLayout<BrushPoint>.offset(of: \.tiltY), 16)
        XCTAssertEqual(MemoryLayout<BrushPoint>.offset(of: \.size), 20)
        XCTAssertEqual(MemoryLayout<BrushPoint>.offset(of: \.timestamp), 24)
    }

    func testBrushParamsIs64Bytes() {
        XCTAssertEqual(MemoryLayout<BrushParams>.size, 64, "BrushParams must be exactly 64 bytes")
        XCTAssertEqual(MemoryLayout<BrushParams>.stride, 64, "BrushParams stride must be 64 bytes")
    }

    func testBrushParamsFieldOffsets() {
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.size), 0)
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.opacity), 4)
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.flow), 8)
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.hardness), 12)
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.mediaType), 16)
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.shapeType), 20)
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.colorR), 24)
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.colorG), 26)
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.colorB), 28)
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.colorO), 30)
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.angle), 32)
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.spacing), 36)
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.scatter), 40)
        XCTAssertEqual(MemoryLayout<BrushParams>.offset(of: \.activeLayer), 44)
    }

    func testDepositParamsLayout() {
        XCTAssertEqual(MemoryLayout<DepositParams>.size, 16, "DepositParams: 4 × UInt32 = 16 bytes")
    }

    func testSPHParticleIs48Bytes() {
        XCTAssertEqual(MemoryLayout<SPHParticle>.size, 48, "SPHParticle must be exactly 48 bytes")
        XCTAssertEqual(MemoryLayout<SPHParticle>.stride, 48, "SPHParticle stride must be 48 bytes")
    }

    func testSPHParticleFieldOffsets() {
        XCTAssertEqual(MemoryLayout<SPHParticle>.offset(of: \.positionX), 0)
        XCTAssertEqual(MemoryLayout<SPHParticle>.offset(of: \.positionY), 4)
        XCTAssertEqual(MemoryLayout<SPHParticle>.offset(of: \.velocityX), 8)
        XCTAssertEqual(MemoryLayout<SPHParticle>.offset(of: \.velocityY), 12)
        XCTAssertEqual(MemoryLayout<SPHParticle>.offset(of: \.colorR), 16)
        XCTAssertEqual(MemoryLayout<SPHParticle>.offset(of: \.mass), 26)
        XCTAssertEqual(MemoryLayout<SPHParticle>.offset(of: \.wetness), 36)
        XCTAssertEqual(MemoryLayout<SPHParticle>.offset(of: \.life), 38)
        XCTAssertEqual(MemoryLayout<SPHParticle>.offset(of: \.layerIndex), 40)
        XCTAssertEqual(MemoryLayout<SPHParticle>.offset(of: \.flags), 41)
    }

    func testSpatialHashCellLayout() {
        XCTAssertEqual(MemoryLayout<SpatialHashCell>.size, 8, "SpatialHashCell: 2 × UInt32 = 8 bytes")
    }

    func testSPHConstantsLayout() {
        XCTAssertEqual(MemoryLayout<SPHConstants>.size, 64, "SPHConstants: 16 × 4 = 64 bytes")
    }

    func testDryingParamsLayout() {
        XCTAssertEqual(MemoryLayout<DryingParams>.size, 16, "DryingParams: 3 × UInt32 + Float = 16 bytes")
    }

    func testFluidParamsLayout() {
        XCTAssertEqual(MemoryLayout<FluidParams>.size, 32, "FluidParams: 8 × 4 = 32 bytes")
    }

    func testLayerStateLayout() {
        XCTAssertEqual(MemoryLayout<LayerState>.size, 16, "LayerState: 4 × UInt32 = 16 bytes")
    }
}
