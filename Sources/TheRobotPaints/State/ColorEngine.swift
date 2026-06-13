import SwiftUI
import Observation

@Observable
final class ColorEngine: @unchecked Sendable {
    var absorptionR: Float = 0.8
    var absorptionG: Float = 0.2
    var absorptionB: Float = 0.1

    var recentColors: [(r: Float, g: Float, b: Float)] = []
    private let maxRecent = 16

    var visibleColor: Color {
        let canvasR: Float = 0.95
        let canvasG: Float = 0.93
        let canvasB: Float = 0.88

        let vr = canvasR * exp(-absorptionR)
        let vg = canvasG * exp(-absorptionG)
        let vb = canvasB * exp(-absorptionB)

        return Color(
            red: Double(vr.clamped(to: 0...1)),
            green: Double(vg.clamped(to: 0...1)),
            blue: Double(vb.clamped(to: 0...1)))
    }

    func setFromVisible(r: Float, g: Float, b: Float) {
        let canvasR: Float = 0.95
        let canvasG: Float = 0.93
        let canvasB: Float = 0.88

        absorptionR = -log(max(0.001, min(0.999, r / canvasR)))
        absorptionG = -log(max(0.001, min(0.999, g / canvasG)))
        absorptionB = -log(max(0.001, min(0.999, b / canvasB)))
    }

    func commitColor() {
        recentColors.insert((absorptionR, absorptionG, absorptionB), at: 0)
        if recentColors.count > maxRecent {
            recentColors.removeLast()
        }
    }

    var asFloat16: (r: Float16, g: Float16, b: Float16) {
        (Float16(absorptionR), Float16(absorptionG), Float16(absorptionB))
    }
}

private extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
