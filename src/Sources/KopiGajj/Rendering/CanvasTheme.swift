import SwiftUI
import Metal

/// Design tokens for the oil-on-canvas aesthetic.
/// All colors, spacing, and render constants live here.
enum CanvasTheme {

    // MARK: - Canvas palette

    /// Warm cream base (#FBF7F1)
    static let canvasBase = Color(red: 0.984, green: 0.969, blue: 0.945)
    /// Darker canvas edge (#EFE8DD)
    static let canvasEdge = Color(red: 0.937, green: 0.910, blue: 0.867)
    /// Subtle indigo wash for depth
    static let warmWash = Color.indigo.opacity(0.05)

    // MARK: - Stroke card palette

    static let cardFill = Color.white.opacity(0.78)
    static let cardShadowColor = Color.black.opacity(0.18)
    static let cardBorderWarm = Color.brown.opacity(0.10)
    static let cardBorderCool = Color.brown.opacity(0.08)

    // MARK: - Typography

    static let cardFont: Font = .system(size: 15, design: .monospaced)
    static let titleFont: Font = .system(size: 24, weight: .semibold, design: .serif)
    static let subtitleFont: Font = .system(size: 14, weight: .regular, design: .serif)

    // MARK: - Dimensions

    static let popupWidth: CGFloat = 420
    static let popupHeight: CGFloat = 520
    static let cardCornerRadius: CGFloat = 18
    static let cardPadding: CGFloat = 14
    static let cardShadowRadius: CGFloat = 10
    static let cardShadowY: CGFloat = 6
    static let bristleAmplitude: Double = 2.5
    static let bristleFrequency: Double = 12.0
    static let kuwaharaRadius: Double = 3.0

    // MARK: - Temporal fade

    /// Fully "dry" after 1 hour
    static let maxDryAge: TimeInterval = 3600
    /// Max desaturation at full dryness (0–1)
    static let maxDesaturation: Double = 0.6
    /// Max opacity reduction at full dryness (0–1)
    static let maxFade: Double = 0.3

    // MARK: - Metal availability

    /// True when the runtime Metal compute pipeline initialized successfully.
    /// Uses MTLDevice.makeLibrary(source:) — works with `swift build`, no Xcode needed.
    static let metalAvailable: Bool = CanvasMetalRenderer.shared != nil
}
