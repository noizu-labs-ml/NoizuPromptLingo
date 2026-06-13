import XCTest
@testable import KopiGajj

final class BrushPointCodableTests: XCTestCase {

    func testCodingKeysMapping() throws {
        let point = CodableBrushPoint(
            x: 10, y: 20, pressure: 0.5, radius: 15,
            absR: 1.0, absG: 2.0, absB: 3.0, concentration: 0.8,
            viscosity: 0.7
        )
        let data = try JSONEncoder().encode(point)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        // absR/absG/absB map to "r"/"g"/"b", concentration maps to "a"
        XCTAssertNotNil(dict["r"])
        XCTAssertNotNil(dict["g"])
        XCTAssertNotNil(dict["b"])
        XCTAssertNotNil(dict["a"])
        // Original long names should NOT appear
        XCTAssertNil(dict["absR"])
        XCTAssertNil(dict["absG"])
        XCTAssertNil(dict["absB"])
        XCTAssertNil(dict["concentration"])
    }

    func testRoundTrip() throws {
        let original = CodableBrushPoint(
            x: 100, y: 200, pressure: 0.9, radius: 30,
            absR: 5.0, absG: 3.0, absB: 1.5, concentration: 0.95,
            viscosity: 0.6, tipType: 2, angle: 1.2,
            dirX: 0.7, dirY: 0.7, wetness: 0.5
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CodableBrushPoint.self, from: data)

        XCTAssertEqual(decoded.x, original.x, accuracy: 0.001)
        XCTAssertEqual(decoded.absR, original.absR, accuracy: 0.001)
        XCTAssertEqual(decoded.concentration, original.concentration, accuracy: 0.001)
        XCTAssertEqual(decoded.tipType, original.tipType, accuracy: 0.001)
        XCTAssertEqual(decoded.wetness, original.wetness, accuracy: 0.001)
    }

    func testAsBrushPointConversion() {
        let codable = CodableBrushPoint(
            x: 50, y: 60, pressure: 0.8, radius: 25,
            absR: 2.0, absG: 1.5, absB: 0.5, concentration: 1.0,
            viscosity: 0.9, tipType: 3, angle: 0.5,
            dirX: 0.6, dirY: 0.8, wetness: 0.3
        )
        let bp = codable.asBrushPoint

        XCTAssertEqual(bp.x, 50, accuracy: 0.001)
        XCTAssertEqual(bp.y, 60, accuracy: 0.001)
        XCTAssertEqual(bp.absR, 2.0, accuracy: 0.001)
        XCTAssertEqual(bp.absG, 1.5, accuracy: 0.001)
        XCTAssertEqual(bp.absB, 0.5, accuracy: 0.001)
        XCTAssertEqual(bp.concentration, 1.0, accuracy: 0.001)
        XCTAssertEqual(bp.tipType, 3, accuracy: 0.001)
        XCTAssertEqual(bp.wetness, 0.3, accuracy: 0.001)
    }

    func testDefaults() {
        let point = CodableBrushPoint(
            x: 0, y: 0, pressure: 0.5, radius: 10,
            absR: 1, absG: 1, absB: 1, concentration: 1,
            viscosity: 0.5
        )
        // Default values for optional fields
        XCTAssertEqual(point.tipType, 0, accuracy: 0.001)
        XCTAssertEqual(point.angle, 0, accuracy: 0.001)
        XCTAssertEqual(point.dirX, 0, accuracy: 0.001)
        XCTAssertEqual(point.dirY, 0, accuracy: 0.001)
        XCTAssertEqual(point.wetness, 0, accuracy: 0.001)
    }

    func testBrushPointDefaultWetness() {
        let bp = BrushPoint(
            x: 0, y: 0, pressure: 0.5, radius: 10,
            absR: 1, absG: 1, absB: 1, concentration: 1,
            viscosity: 0.5, tipType: 0, angle: 0,
            dirX: 1, dirY: 0
        )
        XCTAssertEqual(bp.wetness, 0, accuracy: 0.001)
    }
}
