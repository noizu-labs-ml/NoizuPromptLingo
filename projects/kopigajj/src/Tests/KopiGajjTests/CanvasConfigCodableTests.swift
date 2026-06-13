import XCTest
@testable import KopiGajj

final class CanvasConfigCodableTests: XCTestCase {

    func testDefaultRoundTrip() throws {
        let original = CanvasConfig.default
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CanvasConfig.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    func testDecodeEmptyJSON() throws {
        let json = "{}".data(using: .utf8)!
        let config = try JSONDecoder().decode(CanvasConfig.self, from: json)
        // All fields should fall back to defaults
        XCTAssertEqual(config, CanvasConfig.default)
    }

    func testDecodePartialJSON() throws {
        let json = """
        {"textureOpacity": 0.8, "simSeed": 99}
        """.data(using: .utf8)!
        let config = try JSONDecoder().decode(CanvasConfig.self, from: json)
        XCTAssertEqual(config.background.textureOpacity, 0.8, accuracy: 0.001)
        XCTAssertEqual(config.sim.simSeed, 99)
        // Non-specified fields use defaults
        XCTAssertEqual(config.card.cardCornerRadius, 18.0, accuracy: 0.001)
        XCTAssertEqual(config.sim.simFlowStrength, 0.5, accuracy: 0.001)
    }

    func testEncodedJSONIsFlatKeys() throws {
        let config = CanvasConfig.default
        let data = try JSONEncoder().encode(config)
        let dict = try JSONDecoder().decode([String: AnyCodableValue].self, from: data)
        // Flat keys — no nested objects. All keys should be top-level strings.
        XCTAssertNotNil(dict["textureOpacity"])
        XCTAssertNotNil(dict["simSeed"])
        XCTAssertNotNil(dict["cardCornerRadius"])
        XCTAssertNotNil(dict["filterRadius"])
    }

    func testEquatable() {
        let a = CanvasConfig.default
        var b = CanvasConfig.default
        XCTAssertEqual(a, b)
        b.sim.simSeed = 999
        XCTAssertNotEqual(a, b)
    }

    func testSubConfigDefaults() {
        let config = CanvasConfig()
        XCTAssertEqual(config.background.textureOpacity, 0.40, accuracy: 0.001)
        XCTAssertEqual(config.card.cardCornerRadius, 18.0, accuracy: 0.001)
        XCTAssertEqual(config.sim.simRidgeHeight, 0.04, accuracy: 0.001)
        XCTAssertEqual(config.filter.filterRadius, 6.0, accuracy: 0.001)
        XCTAssertTrue(config.filter.filterEnabled)
    }
}

/// Minimal type-erased Codable value for verifying flat JSON structure.
private enum AnyCodableValue: Decodable {
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(Bool.self) { self = .bool(v) }
        else if let v = try? c.decode(Int.self) { self = .int(v) }
        else if let v = try? c.decode(Double.self) { self = .double(v) }
        else if let v = try? c.decode(String.self) { self = .string(v) }
        else { throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unsupported type") }
    }
}
