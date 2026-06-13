protocol MediaTypeDefinition: Sendable {
    var mediaType: MediaType { get }
    var displayName: String { get }
    var dryingRateMultiplier: Float { get }
    var defaultViscosity: Float { get }
    var defaultSurfaceTension: Float { get }
    var defaultWetness: Float { get }
    var defaultGloss: Float { get }
    var supportsFluidSim: Bool { get }
}
