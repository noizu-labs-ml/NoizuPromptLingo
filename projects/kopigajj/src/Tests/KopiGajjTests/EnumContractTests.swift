import XCTest
@testable import KopiGajj

final class EnumContractTests: XCTestCase {

    // MARK: - BrushMode

    func testBrushModeIndices() {
        XCTAssertEqual(BrushMode.oil.modeIndex, 0)
        XCTAssertEqual(BrushMode.watercolor.modeIndex, 1)
        XCTAssertEqual(BrushMode.acrylic.modeIndex, 2)
        XCTAssertEqual(BrushMode.pastel.modeIndex, 3)
        XCTAssertEqual(BrushMode.highlighter.modeIndex, 4)
    }

    func testBrushModeAllCases() {
        XCTAssertEqual(BrushMode.allCases.count, 5)
    }

    func testBrushModeCodableRoundTrip() throws {
        for mode in BrushMode.allCases {
            let data = try JSONEncoder().encode(mode)
            let decoded = try JSONDecoder().decode(BrushMode.self, from: data)
            XCTAssertEqual(decoded, mode, "Round-trip failed for \(mode)")
        }
    }

    func testBrushModeRawValues() {
        XCTAssertEqual(BrushMode.oil.rawValue, "oil")
        XCTAssertEqual(BrushMode.watercolor.rawValue, "watercolor")
        XCTAssertEqual(BrushMode.acrylic.rawValue, "acrylic")
        XCTAssertEqual(BrushMode.pastel.rawValue, "pastel")
        XCTAssertEqual(BrushMode.highlighter.rawValue, "highlighter")
    }

    // MARK: - BrushTip

    func testBrushTipIndices() {
        XCTAssertEqual(BrushTip.round.tipIndex, 0)
        XCTAssertEqual(BrushTip.flat.tipIndex, 1)
        XCTAssertEqual(BrushTip.filbert.tipIndex, 2)
        XCTAssertEqual(BrushTip.fan.tipIndex, 3)
        XCTAssertEqual(BrushTip.knife.tipIndex, 4)
    }

    func testBrushTipAllCases() {
        XCTAssertEqual(BrushTip.allCases.count, 5)
    }
}
