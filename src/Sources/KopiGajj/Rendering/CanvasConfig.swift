import Foundation

// MARK: - Sub-configs

/// Canvas background texture and impasto parameters.
struct BackgroundConfig: Codable, Equatable {
    var textureOpacity: Double = 0.40
    var textureThreadWeight: Double = 2.0
    var textureThreadSpacing: Double = 4.0
    var impastoMarkCount: Int = 40
    var warmWashOpacity: Double = 0.06
    var coolWashOpacity: Double = 0.04
    var impastoMinWidth: Double = 15
    var impastoMaxWidth: Double = 50
    var impastoHeightRatio: Double = 0.25
    var impastoTaper: Double = 0.4
    var impastoMinAlpha: Double = 0.15
    var impastoMaxAlpha: Double = 0.45
    var impastoColorShift: Double = 0.08
    var impastoHighlight: Double = 0.35
    var impastoRotation: Double = 0.4
    var impastoSeed: Int = 99
}

/// Stroke card appearance parameters.
struct StrokeCardConfig: Codable, Equatable {
    var cardCornerRadius: Double = 18.0
    var cardBorderWidth: Double = 2.5
    var cardBorderOpacity: Double = 0.20
    var cardWarmthSaturation: Double = 0.08
    var cardShadowRadius: Double = 10.0
    var cardShadowOpacity: Double = 0.25
    var cardJaggedness: Double = 3.0
    var cardJaggedFrequency: Double = 12.0
    var maxDesaturation: Double = 0.6
    var maxFade: Double = 0.3
}

/// Paint simulation parameters.
struct PaintSimConfig: Codable, Equatable {
    var simRidgeHeight: Double = 0.04
    var simWeaveScale: Double = 4.0
    var simStrokeCount: Int = 20
    var simSeed: Int = 42
    var simFlowStrength: Double = 0.5
    var simDiffusionRate: Double = 0.3
    var simDryRate: Double = 0.1
    var simEdgeDarken: Double = 0.3
    var simFlowSteps: Int = 8
    var simDrySteps: Int = 4
    var simLightAzimuth: Double = 45.0
    var simLightElevation: Double = 60.0
    var simAmbient: Double = 0.3
    var simSpecular: Double = 0.4
    var simHeightScale: Double = 8.0
    var simDrySmoothRate: Double = 1.0  // multiplier for media-specific dry smoothing (0=no smooth, 2=extra smooth)
    var simBrushTexture: Double = 1.0   // multiplier for bristle/grain height texture (0=flat, 2=exaggerated)
    var simOpacityMult: Double = 1.0    // multiplier for media opacity/coverage (0.5=translucent, 2=opaque)
}

/// Paint filter parameters.
/// Uses Double for consistency with other config sub-structs and SwiftUI bindings.
/// Converted to Float at the Metal API boundary in CanvasMetalRenderer.
struct FilterConfig: Codable, Equatable {
    var filterEnabled: Bool = true
    var filterType: PaintFilterType = .kuwahara
    var filterRadius: Double = 6.0
    var filterParam1: Double = 0.5
    var filterParam2: Double = 0.5
}

// MARK: - CanvasConfig

/// Serializable canvas render engine configuration.
/// Saved as JSON files in ~/.config/kopigajj/themes/
///
/// Composed of focused sub-configs for background, card, simulation, and filter.
/// JSON encoding remains flat for backward compatibility with existing theme files.
struct CanvasConfig: Codable, Equatable {
    var background: BackgroundConfig = .init()
    var card: StrokeCardConfig = .init()
    var sim: PaintSimConfig = .init()
    var filter: FilterConfig = .init()

    static let `default` = CanvasConfig()

    init() {}

    init(background: BackgroundConfig = .init(),
         card: StrokeCardConfig = .init(),
         sim: PaintSimConfig = .init(),
         filter: FilterConfig = .init()) {
        self.background = background
        self.card = card
        self.sim = sim
        self.filter = filter
    }

    // MARK: - Flat JSON backward compatibility

    /// All keys remain flat in JSON to support existing theme files.
    private enum CodingKeys: String, CodingKey {
        // Background
        case textureOpacity, textureThreadWeight, textureThreadSpacing
        case impastoMarkCount, warmWashOpacity, coolWashOpacity
        case impastoMinWidth, impastoMaxWidth, impastoHeightRatio, impastoTaper
        case impastoMinAlpha, impastoMaxAlpha, impastoColorShift, impastoHighlight
        case impastoRotation, impastoSeed
        // Card
        case cardCornerRadius, cardBorderWidth, cardBorderOpacity, cardWarmthSaturation
        case cardShadowRadius, cardShadowOpacity, cardJaggedness, cardJaggedFrequency
        case maxDesaturation, maxFade
        // Sim
        case simRidgeHeight, simWeaveScale, simStrokeCount, simSeed
        case simFlowStrength, simDiffusionRate, simDryRate, simEdgeDarken
        case simFlowSteps, simDrySteps, simLightAzimuth, simLightElevation
        case simAmbient, simSpecular, simHeightScale
        case simDrySmoothRate, simBrushTexture, simOpacityMult
        // Filter
        case filterEnabled, filterType, filterRadius, filterParam1, filterParam2
    }

    /// Custom decoder that tolerates missing keys — old theme files without
    /// new fields use factory defaults instead of failing to decode.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let d = CanvasConfig.default

        func opt<T: Decodable>(_ key: CodingKeys, _ fallback: T) throws -> T {
            try c.decodeIfPresent(T.self, forKey: key) ?? fallback
        }

        background = BackgroundConfig(
            textureOpacity:       try opt(.textureOpacity, d.background.textureOpacity),
            textureThreadWeight:  try opt(.textureThreadWeight, d.background.textureThreadWeight),
            textureThreadSpacing: try opt(.textureThreadSpacing, d.background.textureThreadSpacing),
            impastoMarkCount:     try opt(.impastoMarkCount, d.background.impastoMarkCount),
            warmWashOpacity:      try opt(.warmWashOpacity, d.background.warmWashOpacity),
            coolWashOpacity:      try opt(.coolWashOpacity, d.background.coolWashOpacity),
            impastoMinWidth:      try opt(.impastoMinWidth, d.background.impastoMinWidth),
            impastoMaxWidth:      try opt(.impastoMaxWidth, d.background.impastoMaxWidth),
            impastoHeightRatio:   try opt(.impastoHeightRatio, d.background.impastoHeightRatio),
            impastoTaper:         try opt(.impastoTaper, d.background.impastoTaper),
            impastoMinAlpha:      try opt(.impastoMinAlpha, d.background.impastoMinAlpha),
            impastoMaxAlpha:      try opt(.impastoMaxAlpha, d.background.impastoMaxAlpha),
            impastoColorShift:    try opt(.impastoColorShift, d.background.impastoColorShift),
            impastoHighlight:     try opt(.impastoHighlight, d.background.impastoHighlight),
            impastoRotation:      try opt(.impastoRotation, d.background.impastoRotation),
            impastoSeed:          try opt(.impastoSeed, d.background.impastoSeed)
        )

        card = StrokeCardConfig(
            cardCornerRadius:     try opt(.cardCornerRadius, d.card.cardCornerRadius),
            cardBorderWidth:      try opt(.cardBorderWidth, d.card.cardBorderWidth),
            cardBorderOpacity:    try opt(.cardBorderOpacity, d.card.cardBorderOpacity),
            cardWarmthSaturation: try opt(.cardWarmthSaturation, d.card.cardWarmthSaturation),
            cardShadowRadius:     try opt(.cardShadowRadius, d.card.cardShadowRadius),
            cardShadowOpacity:    try opt(.cardShadowOpacity, d.card.cardShadowOpacity),
            cardJaggedness:       try opt(.cardJaggedness, d.card.cardJaggedness),
            cardJaggedFrequency:  try opt(.cardJaggedFrequency, d.card.cardJaggedFrequency),
            maxDesaturation:      try opt(.maxDesaturation, d.card.maxDesaturation),
            maxFade:              try opt(.maxFade, d.card.maxFade)
        )

        sim = PaintSimConfig(
            simRidgeHeight:    try opt(.simRidgeHeight, d.sim.simRidgeHeight),
            simWeaveScale:     try opt(.simWeaveScale, d.sim.simWeaveScale),
            simStrokeCount:    try opt(.simStrokeCount, d.sim.simStrokeCount),
            simSeed:           try opt(.simSeed, d.sim.simSeed),
            simFlowStrength:   try opt(.simFlowStrength, d.sim.simFlowStrength),
            simDiffusionRate:  try opt(.simDiffusionRate, d.sim.simDiffusionRate),
            simDryRate:        try opt(.simDryRate, d.sim.simDryRate),
            simEdgeDarken:     try opt(.simEdgeDarken, d.sim.simEdgeDarken),
            simFlowSteps:      try opt(.simFlowSteps, d.sim.simFlowSteps),
            simDrySteps:       try opt(.simDrySteps, d.sim.simDrySteps),
            simLightAzimuth:   try opt(.simLightAzimuth, d.sim.simLightAzimuth),
            simLightElevation: try opt(.simLightElevation, d.sim.simLightElevation),
            simAmbient:        try opt(.simAmbient, d.sim.simAmbient),
            simSpecular:       try opt(.simSpecular, d.sim.simSpecular),
            simHeightScale:    try opt(.simHeightScale, d.sim.simHeightScale),
            simDrySmoothRate:  try opt(.simDrySmoothRate, d.sim.simDrySmoothRate),
            simBrushTexture:   try opt(.simBrushTexture, d.sim.simBrushTexture),
            simOpacityMult:    try opt(.simOpacityMult, d.sim.simOpacityMult)
        )

        filter = FilterConfig(
            filterEnabled: try opt(.filterEnabled, d.filter.filterEnabled),
            filterType:    try opt(.filterType, d.filter.filterType),
            filterRadius:  try opt(.filterRadius, d.filter.filterRadius),
            filterParam1:  try opt(.filterParam1, d.filter.filterParam1),
            filterParam2:  try opt(.filterParam2, d.filter.filterParam2)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        // Background
        try c.encode(background.textureOpacity, forKey: .textureOpacity)
        try c.encode(background.textureThreadWeight, forKey: .textureThreadWeight)
        try c.encode(background.textureThreadSpacing, forKey: .textureThreadSpacing)
        try c.encode(background.impastoMarkCount, forKey: .impastoMarkCount)
        try c.encode(background.warmWashOpacity, forKey: .warmWashOpacity)
        try c.encode(background.coolWashOpacity, forKey: .coolWashOpacity)
        try c.encode(background.impastoMinWidth, forKey: .impastoMinWidth)
        try c.encode(background.impastoMaxWidth, forKey: .impastoMaxWidth)
        try c.encode(background.impastoHeightRatio, forKey: .impastoHeightRatio)
        try c.encode(background.impastoTaper, forKey: .impastoTaper)
        try c.encode(background.impastoMinAlpha, forKey: .impastoMinAlpha)
        try c.encode(background.impastoMaxAlpha, forKey: .impastoMaxAlpha)
        try c.encode(background.impastoColorShift, forKey: .impastoColorShift)
        try c.encode(background.impastoHighlight, forKey: .impastoHighlight)
        try c.encode(background.impastoRotation, forKey: .impastoRotation)
        try c.encode(background.impastoSeed, forKey: .impastoSeed)
        // Card
        try c.encode(card.cardCornerRadius, forKey: .cardCornerRadius)
        try c.encode(card.cardBorderWidth, forKey: .cardBorderWidth)
        try c.encode(card.cardBorderOpacity, forKey: .cardBorderOpacity)
        try c.encode(card.cardWarmthSaturation, forKey: .cardWarmthSaturation)
        try c.encode(card.cardShadowRadius, forKey: .cardShadowRadius)
        try c.encode(card.cardShadowOpacity, forKey: .cardShadowOpacity)
        try c.encode(card.cardJaggedness, forKey: .cardJaggedness)
        try c.encode(card.cardJaggedFrequency, forKey: .cardJaggedFrequency)
        try c.encode(card.maxDesaturation, forKey: .maxDesaturation)
        try c.encode(card.maxFade, forKey: .maxFade)
        // Sim
        try c.encode(sim.simRidgeHeight, forKey: .simRidgeHeight)
        try c.encode(sim.simWeaveScale, forKey: .simWeaveScale)
        try c.encode(sim.simStrokeCount, forKey: .simStrokeCount)
        try c.encode(sim.simSeed, forKey: .simSeed)
        try c.encode(sim.simFlowStrength, forKey: .simFlowStrength)
        try c.encode(sim.simDiffusionRate, forKey: .simDiffusionRate)
        try c.encode(sim.simDryRate, forKey: .simDryRate)
        try c.encode(sim.simEdgeDarken, forKey: .simEdgeDarken)
        try c.encode(sim.simFlowSteps, forKey: .simFlowSteps)
        try c.encode(sim.simDrySteps, forKey: .simDrySteps)
        try c.encode(sim.simLightAzimuth, forKey: .simLightAzimuth)
        try c.encode(sim.simLightElevation, forKey: .simLightElevation)
        try c.encode(sim.simAmbient, forKey: .simAmbient)
        try c.encode(sim.simSpecular, forKey: .simSpecular)
        try c.encode(sim.simHeightScale, forKey: .simHeightScale)
        try c.encode(sim.simDrySmoothRate, forKey: .simDrySmoothRate)
        try c.encode(sim.simBrushTexture, forKey: .simBrushTexture)
        try c.encode(sim.simOpacityMult, forKey: .simOpacityMult)
        // Filter
        try c.encode(filter.filterEnabled, forKey: .filterEnabled)
        try c.encode(filter.filterType, forKey: .filterType)
        try c.encode(filter.filterRadius, forKey: .filterRadius)
        try c.encode(filter.filterParam1, forKey: .filterParam1)
        try c.encode(filter.filterParam2, forKey: .filterParam2)
    }
}

// MARK: - Persistence

/// Manages saving/loading CanvasConfig files.
enum CanvasConfigStore {

    static let configDir: URL = {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/kopigajj/themes", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    /// List all saved config names (without .json extension).
    static func list() -> [String] {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: configDir, includingPropertiesForKeys: nil
        ) else { return [] }

        return files
            .filter { $0.pathExtension == "json" }
            .map { $0.deletingPathExtension().lastPathComponent }
            .sorted()
    }

    /// Load a config by name.
    static func load(_ name: String) -> CanvasConfig? {
        let url = configDir.appendingPathComponent("\(name).json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(CanvasConfig.self, from: data)
    }

    /// Save a config with the given name.
    static func save(_ config: CanvasConfig, name: String) throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        let url = configDir.appendingPathComponent("\(name).json")
        try data.write(to: url)
        NSLog("💾 Config saved: \(url.path)")
    }

    /// Delete a config by name.
    static func delete(_ name: String) throws {
        let url = configDir.appendingPathComponent("\(name).json")
        try FileManager.default.removeItem(at: url)
    }
}
