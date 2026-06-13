struct WatercolorMedia: MediaTypeDefinition {
    let mediaType: MediaType = .watercolor
    let displayName = "Watercolor"
    let dryingRateMultiplier: Float = 1.0
    let defaultViscosity: Float = 0.005
    let defaultSurfaceTension: Float = 0.072
    let defaultWetness: Float = 1.0
    let defaultGloss: Float = 0.3
    let supportsFluidSim = true
}

struct OilMedia: MediaTypeDefinition {
    let mediaType: MediaType = .oil
    let displayName = "Oil"
    let dryingRateMultiplier: Float = 0.05
    let defaultViscosity: Float = 50.0
    let defaultSurfaceTension: Float = 0.025
    let defaultWetness: Float = 0.8
    let defaultGloss: Float = 0.7
    let supportsFluidSim = true
}

struct AcrylicMedia: MediaTypeDefinition {
    let mediaType: MediaType = .acrylic
    let displayName = "Acrylic"
    let dryingRateMultiplier: Float = 8.0
    let defaultViscosity: Float = 1.0
    let defaultSurfaceTension: Float = 0.035
    let defaultWetness: Float = 0.6
    let defaultGloss: Float = 0.5
    let supportsFluidSim = true
}

struct CharcoalMedia: MediaTypeDefinition {
    let mediaType: MediaType = .charcoal
    let displayName = "Charcoal"
    let dryingRateMultiplier: Float = 1000.0
    let defaultViscosity: Float = 0
    let defaultSurfaceTension: Float = 0
    let defaultWetness: Float = 0
    let defaultGloss: Float = 0.05
    let supportsFluidSim = false
}

struct PastelMedia: MediaTypeDefinition {
    let mediaType: MediaType = .pastel
    let displayName = "Pastel"
    let dryingRateMultiplier: Float = 1000.0
    let defaultViscosity: Float = 0
    let defaultSurfaceTension: Float = 0
    let defaultWetness: Float = 0
    let defaultGloss: Float = 0.1
    let supportsFluidSim = false
}

enum MediaRegistry {
    static let all: [any MediaTypeDefinition] = [
        WatercolorMedia(),
        OilMedia(),
        AcrylicMedia(),
        CharcoalMedia(),
        PastelMedia()
    ]

    static func definition(for type: MediaType) -> any MediaTypeDefinition {
        all.first { $0.mediaType == type } ?? WatercolorMedia()
    }
}
