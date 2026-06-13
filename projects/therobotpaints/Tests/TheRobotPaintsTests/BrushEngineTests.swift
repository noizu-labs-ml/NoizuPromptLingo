import XCTest
import simd
@testable import TheRobotPaints

final class BrushEngineTests: XCTestCase {
    func testCatmullRomStraightLine() {
        let p0 = SIMD2<Float>(0, 0)
        let p1 = SIMD2<Float>(10, 0)
        let p2 = SIMD2<Float>(20, 0)
        let p3 = SIMD2<Float>(30, 0)

        let mid = BrushEngine.catmullRom(p0: p0, p1: p1, p2: p2, p3: p3, t: 0.5)
        XCTAssertEqual(mid.x, 15.0, accuracy: 0.01)
        XCTAssertEqual(mid.y, 0.0, accuracy: 0.01)
    }

    func testCatmullRomEndpoints() {
        let p0 = SIMD2<Float>(0, 0)
        let p1 = SIMD2<Float>(10, 10)
        let p2 = SIMD2<Float>(20, 5)
        let p3 = SIMD2<Float>(30, 15)

        let start = BrushEngine.catmullRom(p0: p0, p1: p1, p2: p2, p3: p3, t: 0.0)
        XCTAssertEqual(start.x, 10.0, accuracy: 0.01, "t=0 should be at p1")
        XCTAssertEqual(start.y, 10.0, accuracy: 0.01)

        let end = BrushEngine.catmullRom(p0: p0, p1: p1, p2: p2, p3: p3, t: 1.0)
        XCTAssertEqual(end.x, 20.0, accuracy: 0.01, "t=1 should be at p2")
        XCTAssertEqual(end.y, 5.0, accuracy: 0.01)
    }

    func testCatmullRomCurveDeviates() {
        let p0 = SIMD2<Float>(0, 0)
        let p1 = SIMD2<Float>(10, 0)
        let p2 = SIMD2<Float>(20, 0)
        let p3 = SIMD2<Float>(30, 20)

        let mid = BrushEngine.catmullRom(p0: p0, p1: p1, p2: p2, p3: p3, t: 0.5)
        XCTAssertEqual(mid.x, 15.0, accuracy: 0.5)
        XCTAssertNotEqual(mid.y, 0.0, "Curve should deviate from straight line due to p3 pull")
    }

    func testFlushPointsClearsBuffer() {
        let engine = BrushEngine()
        let points1 = engine.flushPoints()
        XCTAssertTrue(points1.isEmpty)

        let points2 = engine.flushPoints()
        XCTAssertTrue(points2.isEmpty)
    }
}
