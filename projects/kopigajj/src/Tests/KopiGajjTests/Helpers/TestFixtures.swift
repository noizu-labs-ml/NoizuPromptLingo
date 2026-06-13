import Foundation
@testable import KopiGajj

/// Reusable test fixtures for brush points and strokes.
enum TestFixtures {

    /// A single brush point at the given coordinates with sensible defaults.
    static func singlePoint(
        at position: (x: Float, y: Float) = (64, 64),
        pressure: Float = 0.7,
        radius: Float = 20,
        absR: Float = 2.0,
        absG: Float = 1.0,
        absB: Float = 0.5,
        concentration: Float = 1.0,
        viscosity: Float = 0.8,
        tip: BrushTip = .round,
        mode: BrushMode = .oil
    ) -> BrushPoint {
        BrushPoint(
            x: position.x, y: position.y,
            pressure: pressure, radius: radius,
            absR: absR, absG: absG, absB: absB,
            concentration: concentration,
            viscosity: viscosity,
            tipType: tip.tipIndex,
            angle: 0,
            dirX: 1, dirY: 0,
            wetness: 0
        )
    }

    /// Two-point stroke from `from` to `to` with direction computed.
    static func twoPointStroke(
        from: (x: Float, y: Float),
        to: (x: Float, y: Float),
        pressure: Float = 0.7,
        radius: Float = 20,
        absR: Float = 2.0,
        absG: Float = 1.0,
        absB: Float = 0.5
    ) -> [BrushPoint] {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let len = sqrt(dx * dx + dy * dy)
        let dirX = len > 0.001 ? dx / len : Float(1)
        let dirY = len > 0.001 ? dy / len : Float(0)

        return [
            BrushPoint(x: from.x, y: from.y, pressure: pressure, radius: radius,
                       absR: absR, absG: absG, absB: absB, concentration: 1.0,
                       viscosity: 0.8, tipType: 0, angle: 0,
                       dirX: dirX, dirY: dirY, wetness: 0),
            BrushPoint(x: to.x, y: to.y, pressure: pressure, radius: radius,
                       absR: absR, absG: absG, absB: absB, concentration: 1.0,
                       viscosity: 0.8, tipType: 0, angle: 0,
                       dirX: dirX, dirY: dirY, wetness: 0),
        ]
    }
}
