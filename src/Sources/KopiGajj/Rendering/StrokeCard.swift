import SwiftUI

/// Controls which parts of the StrokeCard are visible.
/// All modes produce identical layout (same frame size).
enum StrokeCardRenderMode {
    case full
    case chromeOnly
    case textOnly
}

/// A rounded rectangle with noise-displaced edges — like torn or brushed paper.
/// `jaggedness` controls displacement amplitude, `frequency` controls how many wobbles.
struct JaggedRoundedRect: Shape {
    var cornerRadius: CGFloat
    var jaggedness: CGFloat
    var frequency: CGFloat
    var seed: CGFloat

    func path(in rect: CGRect) -> Path {
        if jaggedness < 0.5 {
            // No jaggedness — just a plain rounded rect (fast path)
            return RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
        }

        // Walk the perimeter, displacing each point by noise
        let inset = rect.insetBy(dx: jaggedness, dy: jaggedness)
        let cr = min(cornerRadius, min(inset.width, inset.height) / 2)
        let steps = max(60, Int((inset.width + inset.height) * 2 / 4))

        var path = Path()
        let perimeter = 2 * (inset.width + inset.height)

        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let dist = t * perimeter

            // Walk around the rectangle perimeter
            var px: CGFloat, py: CGFloat
            if dist < inset.width {
                px = inset.minX + dist; py = inset.minY
            } else if dist < inset.width + inset.height {
                px = inset.maxX; py = inset.minY + (dist - inset.width)
            } else if dist < 2 * inset.width + inset.height {
                px = inset.maxX - (dist - inset.width - inset.height); py = inset.maxY
            } else {
                px = inset.minX; py = inset.maxY - (dist - 2 * inset.width - inset.height)
            }

            // Corner rounding: pull points toward center if near corners
            let cx = clamp(px, min: inset.minX + cr, max: inset.maxX - cr)
            let cy = clamp(py, min: inset.minY + cr, max: inset.maxY - cr)
            let dx = px - cx, dy = py - cy
            let cornerDist = sqrt(dx * dx + dy * dy)
            if cornerDist > 0.01 {
                let angle = atan2(dy, dx)
                px = cx + cr * cos(angle)
                py = cy + cr * sin(angle)
            }

            // Noise displacement (perpendicular to edge)
            let noise = sin(t * frequency * .pi * 2 + seed * 17.3)
                      * cos(t * frequency * 0.7 * .pi * 2 + seed * 31.1)
            // Outward normal approximation
            let centerX = rect.midX, centerY = rect.midY
            let toEdgeX = px - centerX, toEdgeY = py - centerY
            let edgeDist = sqrt(toEdgeX * toEdgeX + toEdgeY * toEdgeY)
            if edgeDist > 0.01 {
                let nx = toEdgeX / edgeDist, ny = toEdgeY / edgeDist
                px += nx * noise * jaggedness
                py += ny * noise * jaggedness
            }

            if i == 0 { path.move(to: CGPoint(x: px, y: py)) }
            else { path.addLine(to: CGPoint(x: px, y: py)) }
        }
        path.closeSubpath()
        return path
    }

    private func clamp(_ v: CGFloat, min lo: CGFloat, max hi: CGFloat) -> CGFloat {
        Swift.min(Swift.max(v, lo), hi)
    }
}

/// A clipboard item rendered as a "brush stroke" on the canvas.
struct StrokeCard: View {
    @EnvironmentObject var tuning: CanvasTuningState

    let content: String
    let typeIcon: String
    let age: TimeInterval
    let cardIndex: Int
    var renderMode: StrokeCardRenderMode = .full

    private var dryness: Double {
        min(age / CanvasTheme.maxDryAge, 1.0)
    }

    private var warmth: Double {
        [0.08, 0.06, 0.10, 0.04][cardIndex % 4]
    }

    private var showChrome: Bool {
        renderMode == .full || renderMode == .chromeOnly
    }

    private var showText: Bool {
        renderMode == .full || renderMode == .textOnly
    }

    /// The jagged card shape — shared across fill, overlay, and border
    private var cardShape: JaggedRoundedRect {
        JaggedRoundedRect(
            cornerRadius: tuning.config.card.cardCornerRadius,
            jaggedness: tuning.config.card.cardJaggedness,
            frequency: tuning.config.card.cardJaggedFrequency,
            seed: CGFloat(cardIndex) * 7.31 + 1.0
        )
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // Card background
            cardShape
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hue: warmth, saturation: tuning.config.card.cardWarmthSaturation, brightness: 0.97),
                            Color(hue: warmth, saturation: tuning.config.card.cardWarmthSaturation * 0.6, brightness: 0.95),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(showChrome ? 1 : 0)

            // Brush-stroke texture overlay
            cardShape
                .fill(
                    AngularGradient(
                        colors: [
                            Color.brown.opacity(0.06), .clear,
                            Color.orange.opacity(0.04), .clear,
                            Color.brown.opacity(0.05), .clear,
                            Color.yellow.opacity(0.03), .clear,
                        ],
                        center: UnitPoint(x: 0.3 + Double(cardIndex) * 0.15, y: 0.4)
                    )
                )
                .opacity(showChrome ? 1 : 0)

            // Painterly border
            cardShape
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.brown.opacity(tuning.config.card.cardBorderOpacity),
                            Color.brown.opacity(tuning.config.card.cardBorderOpacity * 0.25),
                            Color.orange.opacity(tuning.config.card.cardBorderOpacity * 0.75),
                            Color.brown.opacity(tuning.config.card.cardBorderOpacity * 0.15),
                            Color.brown.opacity(tuning.config.card.cardBorderOpacity * 0.9),
                            Color.clear,
                        ],
                        center: .center
                    ),
                    lineWidth: tuning.config.card.cardBorderWidth
                )
                .opacity(showChrome ? 1 : 0)

            // Content
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: typeIcon)
                    .font(.system(size: 24))
                    .foregroundStyle(showText ? Color.brown.opacity(0.5) : .clear)
                    .frame(width: 30, alignment: .center)

                Text(content)
                    .font(CanvasTheme.cardFont)
                    .lineLimit(3)
                    .foregroundStyle(showText ? Color(white: 0.15) : .clear)
            }
            .padding(CanvasTheme.cardPadding)
        }
        .saturation(showChrome ? 1.0 - dryness * tuning.config.card.maxDesaturation : 1.0)
        .opacity(showChrome ? 1.0 - dryness * tuning.config.card.maxFade : (showText ? 1.0 - dryness * 0.3 : 1.0))
        .shadow(
            color: showChrome
                ? Color.brown.opacity(tuning.config.card.cardShadowOpacity * (1.0 - dryness))
                : .clear,
            radius: tuning.config.card.cardShadowRadius * (1.0 - dryness * 0.5),
            y: CanvasTheme.cardShadowY * (1.0 - dryness * 0.5)
        )
    }
}
