import XCTest
@testable import KopiGajj

final class MathTests: XCTestCase {

    // MARK: - Beer-Lambert (reflectanceToAbsorption)

    func testBeerLambertWhite() {
        // White (r=1.0) → absorption ≈ 0 (clamped to min(-log(1), 8) = 0)
        let abs = PaintMath.reflectanceToAbsorption(1.0)
        XCTAssertEqual(abs, 0, accuracy: 0.001)
    }

    func testBeerLambertBlack() {
        // Black (r=0) → clamped to -log(0.001) ≈ 6.907, then min(6.907, 8) = 6.907
        let abs = PaintMath.reflectanceToAbsorption(0)
        XCTAssertEqual(abs, -log(0.001), accuracy: 0.01)
        XCTAssertTrue(abs <= 8.0)
    }

    func testBeerLambertMidGray() {
        // r=0.5 → -log(0.5) ≈ 0.693
        let abs = PaintMath.reflectanceToAbsorption(0.5)
        XCTAssertEqual(abs, -log(0.5), accuracy: 0.001)
    }

    func testBeerLambertClampAtFloor() {
        // Input is clamped to max(r, 0.001), so -log(0.001) ≈ 6.9 is the effective max.
        // Values below 0.001 all produce the same result.
        let absZero = PaintMath.reflectanceToAbsorption(0.0)
        let absTiny = PaintMath.reflectanceToAbsorption(0.0001)
        let absFloor = PaintMath.reflectanceToAbsorption(0.001)
        XCTAssertEqual(absZero, absFloor, accuracy: 0.001, "Zero and floor should match")
        XCTAssertEqual(absTiny, absFloor, accuracy: 0.001, "Below-floor and floor should match")
        XCTAssertEqual(absFloor, -log(Float(0.001)), accuracy: 0.01)
    }

    // MARK: - Pressure curve

    func testCurvedPressureLinear() {
        // curve=1.0, thickness=1.0 → identity
        let result = PaintMath.curvedPressure(raw: 0.5, curve: 1.0, thickness: 1.0)
        XCTAssertEqual(result, 0.5, accuracy: 0.001)
    }

    func testCurvedPressureWithThickness() {
        let result = PaintMath.curvedPressure(raw: 0.5, curve: 2.0, thickness: 3.0)
        // pow(0.5, 2.0) * 3.0 = 0.25 * 3.0 = 0.75
        XCTAssertEqual(result, 0.75, accuracy: 0.001)
    }

    // MARK: - Catmull-Rom

    func testCatmullRomAtT0ReturnsP1() {
        let p0 = CGPoint(x: 0, y: 0)
        let p1 = CGPoint(x: 10, y: 20)
        let p2 = CGPoint(x: 30, y: 40)
        let p3 = CGPoint(x: 50, y: 60)
        let result = PaintMath.catmullRom(p0, p1, p2, p3, t: 0)
        XCTAssertEqual(result.x, 10, accuracy: 0.001)
        XCTAssertEqual(result.y, 20, accuracy: 0.001)
    }

    func testCatmullRomAtT1ReturnsP2() {
        let p0 = CGPoint(x: 0, y: 0)
        let p1 = CGPoint(x: 10, y: 20)
        let p2 = CGPoint(x: 30, y: 40)
        let p3 = CGPoint(x: 50, y: 60)
        let result = PaintMath.catmullRom(p0, p1, p2, p3, t: 1)
        XCTAssertEqual(result.x, 30, accuracy: 0.001)
        XCTAssertEqual(result.y, 40, accuracy: 0.001)
    }

    func testCatmullRomMidpoint() {
        // Collinear points: midpoint should be roughly between p1 and p2
        let p0 = CGPoint(x: 0, y: 0)
        let p1 = CGPoint(x: 10, y: 10)
        let p2 = CGPoint(x: 20, y: 20)
        let p3 = CGPoint(x: 30, y: 30)
        let result = PaintMath.catmullRom(p0, p1, p2, p3, t: 0.5)
        XCTAssertEqual(result.x, 15, accuracy: 0.5)
        XCTAssertEqual(result.y, 15, accuracy: 0.5)
    }

    // MARK: - PRNG

    func testPRNGDeterminism() {
        var rng1 = PRNG(seed: 42)
        var rng2 = PRNG(seed: 42)
        for _ in 0..<100 {
            XCTAssertEqual(rng1.next(), rng2.next())
        }
    }

    func testPRNGSeedZeroBecomesOne() {
        var rng0 = PRNG(seed: 0)
        var rng1 = PRNG(seed: 1)
        // Seed 0 is mapped to 1, so they should produce the same sequence
        XCTAssertEqual(rng0.next(), rng1.next())
    }

    func testPRNGDifferentSeeds() {
        var rng1 = PRNG(seed: 42)
        var rng2 = PRNG(seed: 99)
        // Very unlikely to produce the same first value
        XCTAssertNotEqual(rng1.next(), rng2.next())
    }
}
