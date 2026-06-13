import SwiftUI
import AppKit

/// Procedurally generates a tileable canvas-weave texture.
/// Caches results — only regenerates when parameters change.
final class CanvasTextureGenerator {
    static let shared = CanvasTextureGenerator()

    // MARK: - Cache

    private struct TextureCacheKey: Hashable {
        let threadWeight: Double
        let threadSpacing: Double
        let appearance: Appearance
        let width: CGFloat
        let height: CGFloat
    }

    private struct ImpastoCacheKey: Hashable {
        let params: ImpastoParams
        let appearance: Appearance
        let width: CGFloat
        let height: CGFloat
    }

    private var textureCache: [TextureCacheKey: NSImage] = [:]
    private var impastoCache: [ImpastoCacheKey: NSImage] = [:]

    /// Impasto shape parameters grouped for readability.
    struct ImpastoParams: Hashable {
        var count: Int = 40
        var minWidth: Double = 15
        var maxWidth: Double = 50
        var heightRatio: Double = 0.25
        var taper: Double = 0.4
        var minAlpha: Double = 0.15
        var maxAlpha: Double = 0.45
        var colorShift: Double = 0.08
        var highlight: Double = 0.35
        var rotation: Double = 0.4
        var seed: Int = 99
    }

    /// Generate canvas-weave texture only (no impasto marks).
    /// This is the "fabric" — it stays crisp and unfiltered.
    func texture(
        threadWeight: Double = 2.0,
        threadSpacing: Double = 4.0,
        appearance: Appearance = .light,
        size: CGSize = CGSize(width: 512, height: 512)
    ) -> NSImage {
        let key = TextureCacheKey(threadWeight: threadWeight, threadSpacing: threadSpacing,
                                   appearance: appearance, width: size.width, height: size.height)
        if let cached = textureCache[key] { return cached }

        let image = NSImage(size: size, flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }

            let base: (CGFloat, CGFloat, CGFloat)
            let thread: (CGFloat, CGFloat, CGFloat)

            switch appearance {
            case .light:
                base = (0.94, 0.91, 0.86)
                thread = (0.78, 0.73, 0.66)
            case .dark:
                base = (0.16, 0.15, 0.14)
                thread = (0.28, 0.25, 0.22)
            }

            ctx.setFillColor(CGColor(red: base.0, green: base.1, blue: base.2, alpha: 1.0))
            ctx.fill(rect)

            var rng = SeededRNG(seed: 42)
            let spacing = CGFloat(threadSpacing)
            let lineWidth = CGFloat(threadWeight)

            // Horizontal threads
            var y: CGFloat = 0
            while y < size.height {
                let yOff = CGFloat.random(in: -0.5...0.5, using: &rng)
                let alpha = CGFloat.random(in: 0.35...0.70, using: &rng)
                let w = lineWidth + CGFloat.random(in: -0.5...0.5, using: &rng)

                ctx.setStrokeColor(CGColor(red: thread.0, green: thread.1, blue: thread.2, alpha: alpha))
                ctx.setLineWidth(w)
                ctx.move(to: CGPoint(x: 0, y: y + yOff))
                ctx.addLine(to: CGPoint(x: size.width,
                                        y: y + yOff + CGFloat.random(in: -0.8...0.8, using: &rng)))
                ctx.strokePath()
                y += spacing
            }

            // Vertical threads
            var x: CGFloat = 0
            while x < size.width {
                let xOff = CGFloat.random(in: -0.5...0.5, using: &rng)
                let alpha = CGFloat.random(in: 0.30...0.60, using: &rng)
                let w = lineWidth + CGFloat.random(in: -0.5...0.5, using: &rng)

                ctx.setStrokeColor(CGColor(red: thread.0, green: thread.1, blue: thread.2, alpha: alpha))
                ctx.setLineWidth(w)
                ctx.move(to: CGPoint(x: x + xOff, y: 0))
                ctx.addLine(to: CGPoint(x: x + xOff + CGFloat.random(in: -0.8...0.8, using: &rng),
                                        y: size.height))
                ctx.strokePath()
                x += spacing
            }

            return true
        }
        textureCache[key] = image
        return image
    }

    /// Generate impasto ovoid marks on a transparent background.
    /// This is the "paint on canvas" — it goes through the Kuwahara filter.
    func impastoOverlay(
        impasto: ImpastoParams = ImpastoParams(),
        appearance: Appearance = .light,
        size: CGSize = CGSize(width: 512, height: 512)
    ) -> NSImage {
        let key = ImpastoCacheKey(params: impasto, appearance: appearance,
                                   width: size.width, height: size.height)
        if let cached = impastoCache[key] { return cached }

        // Base paint color derived from canvas thread color
        let paintBase: (CGFloat, CGFloat, CGFloat) = appearance == .light
            ? (0.78, 0.73, 0.66)
            : (0.28, 0.25, 0.22)

        let image = NSImage(size: size, flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }

            // Transparent background — only paint marks render
            ctx.clear(rect)

            var rng = SeededRNG(seed: UInt64(impasto.seed))
            let imp = impasto
            let minW = CGFloat(imp.minWidth)
            let maxW = CGFloat(max(imp.minWidth + 1, imp.maxWidth))
            let minA = CGFloat(imp.minAlpha)
            let maxA = CGFloat(max(imp.minAlpha + 0.01, imp.maxAlpha))
            let colShift = CGFloat(imp.colorShift)
            let maxRot = CGFloat(imp.rotation)
            let hRatio = CGFloat(imp.heightRatio)
            let taper = CGFloat(imp.taper)
            let hlInt = CGFloat(imp.highlight)

            for _ in 0..<imp.count {
                let cx = CGFloat.random(in: 0...size.width, using: &rng)
                let cy = CGFloat.random(in: 0...size.height, using: &rng)
                let sw = CGFloat.random(in: minW...maxW, using: &rng)
                let sh = sw * hRatio
                let angle = CGFloat.random(in: -maxRot...maxRot, using: &rng)
                let alpha = CGFloat.random(in: minA...maxA, using: &rng)
                let warmShift = CGFloat.random(in: -colShift...colShift, using: &rng)

                ctx.saveGState()
                ctx.translateBy(x: cx, y: cy)
                ctx.rotate(by: angle)

                let halfW = sw / 2
                let heelH = sh / 2
                let tipH = sh / 2 * (1.0 - taper)
                let cpOffset = halfW * 0.55

                let path = CGMutablePath()
                path.move(to: CGPoint(x: halfW, y: 0))
                path.addCurve(
                    to: CGPoint(x: -halfW, y: 0),
                    control1: CGPoint(x: cpOffset, y: -tipH),
                    control2: CGPoint(x: -cpOffset, y: -heelH)
                )
                path.addCurve(
                    to: CGPoint(x: halfW, y: 0),
                    control1: CGPoint(x: -cpOffset, y: heelH),
                    control2: CGPoint(x: cpOffset, y: tipH)
                )
                path.closeSubpath()

                ctx.setFillColor(CGColor(
                    red: min(1, paintBase.0 * 0.85 + warmShift),
                    green: paintBase.1 * 0.85,
                    blue: max(0, paintBase.2 * 0.80 - warmShift * 0.5),
                    alpha: alpha
                ))
                ctx.addPath(path)
                ctx.fillPath()

                if hlInt > 0.01 {
                    let hlPath = CGMutablePath()
                    let hlW = halfW * 0.45
                    let hlH = heelH * 0.35
                    hlPath.addEllipse(in: CGRect(x: -halfW * 0.3 - hlW / 2, y: -hlH / 2,
                                                 width: hlW, height: hlH))
                    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 0.95,
                                             alpha: alpha * hlInt))
                    ctx.addPath(hlPath)
                    ctx.fillPath()
                }

                ctx.restoreGState()
            }

            return true
        }
        impastoCache[key] = image
        return image
    }

    /// Invalidate all cached textures (call when appearance changes).
    func invalidateCache() {
        textureCache.removeAll()
        impastoCache.removeAll()
    }

    enum Appearance: Hashable { case light, dark }
}

/// Simple seeded PRNG for deterministic texture generation.
private struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

// MARK: - Canvas Background View

/// The base layer of the popup: warm gradient + tileable canvas texture + color washes.
struct CanvasBackground: View {
    @EnvironmentObject var tuning: CanvasTuningState
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let appearance: CanvasTextureGenerator.Appearance = colorScheme == .dark ? .dark : .light

        // Force re-render when textureVersion changes
        let _ = tuning.textureVersion

        ZStack {
            // 1. Base warm gradient
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(white: 0.12), Color(white: 0.10)]
                    : [CanvasTheme.canvasBase, CanvasTheme.canvasEdge],
                startPoint: .top,
                endPoint: .bottom
            )

            // 2. Canvas weave texture (tiled — stays crisp, never filtered)
            Image(nsImage: CanvasTextureGenerator.shared.texture(
                threadWeight: tuning.config.background.textureThreadWeight,
                threadSpacing: tuning.config.background.textureThreadSpacing,
                appearance: appearance
            ))
                .resizable(resizingMode: .tile)
                .blendMode(.multiply)
                .opacity(tuning.config.background.textureOpacity)

            // 3. Impasto paint marks (tiled — in live preview shown directly,
            //    in filtered mode this layer comes from the Kuwahara pipeline instead)
            Image(nsImage: CanvasTextureGenerator.shared.impastoOverlay(
                impasto: .init(
                    count: tuning.config.background.impastoMarkCount,
                    minWidth: tuning.config.background.impastoMinWidth,
                    maxWidth: tuning.config.background.impastoMaxWidth,
                    heightRatio: tuning.config.background.impastoHeightRatio,
                    taper: tuning.config.background.impastoTaper,
                    minAlpha: tuning.config.background.impastoMinAlpha,
                    maxAlpha: tuning.config.background.impastoMaxAlpha,
                    colorShift: tuning.config.background.impastoColorShift,
                    highlight: tuning.config.background.impastoHighlight,
                    rotation: tuning.config.background.impastoRotation,
                    seed: tuning.config.background.impastoSeed
                ),
                appearance: appearance
            ))
                .resizable(resizingMode: .tile)

            // 4. Warm radial wash
            RadialGradient(
                colors: [Color.orange.opacity(tuning.config.background.warmWashOpacity), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 500
            )

            // 4. Cool shadow in bottom-right
            RadialGradient(
                colors: [Color.indigo.opacity(tuning.config.background.coolWashOpacity), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 400
            )
        }
    }
}
