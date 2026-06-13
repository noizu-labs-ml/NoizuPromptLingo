import Foundation

/// Pure math functions used across the paint engine.
/// Extracted from inline code for testability.
enum PaintMath {

    /// Beer-Lambert: convert reflectance (0-1) to absorption (0-8).
    /// Black (0) → high absorption; white (1) → zero absorption.
    static func reflectanceToAbsorption(_ r: Float) -> Float {
        min(-log(max(r, 0.001)), 8.0)
    }

    /// Apply pressure curve with thickness multiplier.
    /// `curved = pow(pressure, curve) * thickness`
    static func curvedPressure(raw: Float, curve: Float, thickness: Float) -> Float {
        pow(raw, curve) * thickness
    }

    /// Catmull-Rom spline interpolation between p1 and p2.
    /// t=0 returns p1, t=1 returns p2 (approximately).
    static func catmullRom(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint, t: CGFloat) -> CGPoint {
        let t2 = t * t, t3 = t2 * t
        let x = 0.5 * ((2 * p1.x) + (-p0.x + p2.x) * t + (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * t2 + (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * t3)
        let y = 0.5 * ((2 * p1.y) + (-p0.y + p2.y) * t + (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * t2 + (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * t3)
        return CGPoint(x: x, y: y)
    }
}
