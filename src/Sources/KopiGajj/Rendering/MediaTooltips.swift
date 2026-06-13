import SwiftUI

// MARK: - Per-media tooltip descriptions

/// Returns media-specific tooltip text for each brush control, so users
/// understand how the same parameter behaves differently across oil,
/// watercolor, acrylic, and pastel media.
enum MediaTooltips {

    static func radius(for mode: BrushMode) -> String {
        switch mode {
        case .oil:         return "Brush width — wider strokes leave thick impasto ridges with visible bristle marks."
        case .watercolor:  return "Wet area spread — how far the water blooms outward from the brush center."
        case .acrylic:     return "Brush width — produces sharp, well-defined edges at any size."
        case .pastel:      return "Stick width — wider coverage area with a chalky, granular texture."
        case .highlighter: return "Marker tip width — semi-transparent overlay that lets underlying paint show through."
        }
    }

    static func pressure(for mode: BrushMode) -> String {
        switch mode {
        case .oil:         return "Paint thickness / ridge height — more pressure pushes thicker paint onto the canvas."
        case .watercolor:  return "Water amount — higher pressure deposits more water, producing a lighter, more diffuse wash."
        case .acrylic:     return "Coverage density — controls how opaque and even the acrylic layer is."
        case .pastel:      return "How hard you press the stick — more pressure grinds more pigment into the canvas tooth."
        case .highlighter: return "Ink flow — higher pressure saturates the highlight more."
        }
    }

    static func pressureCurve(for mode: BrushMode) -> String {
        switch mode {
        case .oil:         return "Response curve for pressure. < 1 = gradual buildup (glazing), > 1 = snaps to full impasto quickly."
        case .watercolor:  return "Response curve for water flow. < 1 = gentle washes, > 1 = jumps to heavy saturation."
        case .acrylic:     return "Response curve. < 1 = smooth blending strokes, > 1 = hard coverage transition."
        case .pastel:      return "Response curve. < 1 = light dusting, > 1 = immediate heavy pigment deposit."
        case .highlighter: return "Response curve. < 1 = gentle ink buildup, > 1 = snaps to full saturation quickly."
        }
    }

    static func thickness(for mode: BrushMode) -> String {
        switch mode {
        case .oil:         return "Height of paint ridges on the canvas. High values create dramatic impasto relief."
        case .watercolor:  return "Not used for watercolor — water has no height. This control has minimal effect."
        case .acrylic:     return "Paint body thickness. Acrylic applies thick but shrinks ~25% as water evaporates — less final relief than oil."
        case .pastel:      return "Pigment deposit depth. Higher values simulate pressing harder, filling canvas tooth."
        case .highlighter: return "Not used for highlighter — ink has no height. This control has minimal effect."
        }
    }

    static func pigmentLoad(for mode: BrushMode) -> String {
        switch mode {
        case .oil:         return "Pigment concentration on the brush. Low = transparent glaze, high = full-body opaque color."
        case .watercolor:  return "Pigment-to-water ratio. Low = pale dilute wash, high = saturated wet-on-wet color."
        case .acrylic:     return "Pigment density. Low = thin wash (like watercolor), high = full opaque coverage."
        case .pastel:      return "Pigment richness. Low = light dusting that shows canvas, high = dense chalky coverage."
        case .highlighter: return "Ink saturation. Low = faint tint, high = vivid fluorescent highlight."
        }
    }

    static func brushAngle(for mode: BrushMode) -> String {
        switch mode {
        case .oil:         return "Rotation of the brush head. Most visible with flat or knife tips for palette-knife strokes."
        case .watercolor:  return "Brush rotation. Affects wash shape with flat brushes; round brushes are rotationally symmetric."
        case .acrylic:     return "Brush rotation. Controls the angle of flat/filbert tip marks in the dried acrylic."
        case .pastel:      return "Stick rotation. Rotate to use the edge vs. the flat side of the pastel stick."
        case .highlighter: return "Chisel tip angle — rotate to switch between broad and fine strokes."
        }
    }

    static func flowStrength(for mode: BrushMode) -> String {
        switch mode {
        case .oil:         return "How much wet oil paint slides downhill on the canvas. Oil flows slowly."
        case .watercolor:  return "Water flow speed — how fast pigment travels through wet areas. The defining watercolor behavior."
        case .acrylic:     return "Wet acrylic flow before drying. Acrylic dries fast so flow window is short."
        case .pastel:      return "Minimal effect — dry pastel does not flow. Small values simulate chalk dust settling."
        case .highlighter: return "Ink bleed — how far the highlight ink spreads beyond the tip edge."
        }
    }

    static func diffusionRate(for mode: BrushMode) -> String {
        switch mode {
        case .oil:         return "How fast oil pigment spreads through wet regions. Oil is viscous so diffusion is slow."
        case .watercolor:  return "Pigment spread through wet paper — creates the soft, feathered edges of watercolor."
        case .acrylic:     return "Wet acrylic pigment spread before the fast-drying binder locks it in place."
        case .pastel:      return "How far loose pigment dust scatters from the stroke. Simulates chalky haze."
        case .highlighter: return "Ink spread through paper fibers — minimal for marker ink."
        }
    }

    static func dryRate(for mode: BrushMode) -> String {
        switch mode {
        case .oil:         return "Oil dries very slowly in reality. Low values keep paint workable for blending."
        case .watercolor:  return "Water evaporation rate. Affects how long pigment can flow before edges lock."
        case .acrylic:     return "Acrylic dries fast. Higher values simulate the rapid skin-forming of acrylic medium."
        case .pastel:      return "How quickly the pastel pigment bonds to canvas tooth. Pastel is essentially instant."
        case .highlighter: return "Ink drying speed — marker ink dries almost instantly on paper."
        }
    }

    static let wetness = "Water saturation on the brush. Low = dry brush (textured, concentrated pigment, minimal spread). High = saturated (thin wash, lots of bleeding and flow). The defining control for watercolor expression."

    static func transparent(for mode: BrushMode) -> String {
        switch mode {
        case .watercolor:  return "Clean water brush — deposits only water, no pigment. Existing watercolor pigment reactivates and diffuses into the wet area, creating blooms and soft edges."
        case .oil:         return "Glazing medium — deposits brush texture and grain on the surface without adding color. The paint below shows through completely. Used for building impasto texture over finished areas."
        case .acrylic:     return "Clear medium — applies acrylic texture and grain without pigment. Creates surface relief that catches light while the underlying color remains visible."
        case .pastel:      return "Blending mode — applies grain and pressure to the surface without adding pigment. Redistributes existing pastel over the canvas tooth."
        case .highlighter: return "Clear overlay — no visible effect (highlighter has no grain or physical texture to deposit)."
        }
    }

    static func edgeDarken(for mode: BrushMode) -> String {
        switch mode {
        case .oil:         return "Slight pigment concentration at stroke edges from paint displacement."
        case .watercolor:  return "Classic watercolor edge effect — pigment concentrates at the drying boundary."
        case .acrylic:     return "Mild edge darkening as acrylic medium pulls pigment during fast drying."
        case .pastel:      return "Edge intensity from the pastel stick pressing harder at stroke boundaries."
        case .highlighter: return "Edge definition — ink concentrates slightly at stroke boundaries."
        }
    }
}
