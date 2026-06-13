import XCTest
import Metal
@testable import KopiGajj

final class PaintFieldTests: XCTestCase {

    func testMetal_fieldAllocation() throws {
        let helper = try TestMetalHelper.requireDevice()
        let field = try PaintField(device: helper.device, width: 128, height: 128)

        // All 8 textures should be non-nil (they're non-optional, so just check dimensions)
        XCTAssertEqual(field.wetAbsorbTex.width, 128)
        XCTAssertEqual(field.wetAbsorbTexB.width, 128)
        XCTAssertEqual(field.solidAbsorbTex.width, 128)
        XCTAssertEqual(field.propsTex.width, 128)
        XCTAssertEqual(field.propsTexB.width, 128)
        XCTAssertEqual(field.heightTex.width, 128)
        XCTAssertEqual(field.canvasPropsTex.width, 128)
        XCTAssertEqual(field.outputTex.width, 128)
    }

    func testMetal_fieldDimensions() throws {
        let helper = try TestMetalHelper.requireDevice()
        let field = try PaintField(device: helper.device, width: 256, height: 128)
        XCTAssertEqual(field.width, 256)
        XCTAssertEqual(field.height, 128)
    }

    func testMetal_doubleBufferToggle() throws {
        let helper = try TestMetalHelper.requireDevice()
        let field = try PaintField(device: helper.device, width: 64, height: 64)

        // Phase 0: read=A, write=B
        XCTAssertEqual(field.phase, 0)
        let readA = field.readWetAbsorb
        let writeA = field.writeWetAbsorb

        field.flip()

        // Phase 1: read=B, write=A (swapped)
        XCTAssertEqual(field.phase, 1)
        let readB = field.readWetAbsorb
        let writeB = field.writeWetAbsorb

        // Read/write should have swapped
        XCTAssertTrue(readA === writeB, "After flip, previous read should be current write")
        XCTAssertTrue(writeA === readB, "After flip, previous write should be current read")
    }

    func testMetal_pixelFormats() throws {
        let helper = try TestMetalHelper.requireDevice()
        let field = try PaintField(device: helper.device, width: 64, height: 64)

        XCTAssertEqual(field.wetAbsorbTex.pixelFormat, .rgba16Float)
        XCTAssertEqual(field.solidAbsorbTex.pixelFormat, .rgba16Float)
        XCTAssertEqual(field.propsTex.pixelFormat, .rgba16Float)
        XCTAssertEqual(field.heightTex.pixelFormat, .r32Float)
        XCTAssertEqual(field.canvasPropsTex.pixelFormat, .rgba16Float)
        XCTAssertEqual(field.outputTex.pixelFormat, .rgba8Unorm)
    }
}
