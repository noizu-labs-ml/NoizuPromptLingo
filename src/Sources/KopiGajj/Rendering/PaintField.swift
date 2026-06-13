import Metal

/// The paint field — a 2D grid of texels representing canvas + paint in two layers.
///
/// **Solid layer** — dried/cured paint. Immobile during flow, written only during dry step.
/// **Wet layer** — active pigment that flows, diffuses, and mixes. Double-buffered.
///
/// Textures:
/// - `wetAbsorbTex`   (rgba16Float): wet pigment absorption RGB + concentration A (flows, mixes)
/// - `solidAbsorbTex` (rgba16Float): dried pigment absorption RGB + concentration A (immobile)
/// - `propsTex`       (rgba16Float): R=wetness, G=hardness, B=viscosity, A=mediaType
/// - `heightTex`      (r32Float):    canvas relief + total paint thickness
/// - `outputTex`      (rgba8Unorm):  final rendered RGBA
final class PaintField: MetalTextureFactory {
    let device: MTLDevice
    let width: Int
    let height: Int

    // Wet layer (double-buffered for flow/dry) — stores absorption RGB + concentration
    var wetAbsorbTex: MTLTexture
    var wetAbsorbTexB: MTLTexture

    // Solid layer (dried paint — written only during dry transfer) — stores absorption RGB + concentration
    var solidAbsorbTex: MTLTexture

    // Properties (double-buffered)
    var propsTex: MTLTexture
    var propsTexB: MTLTexture

    // Canvas surface (immutable after init)
    var heightTex: MTLTexture        // relief + paint thickness
    var canvasPropsTex: MTLTexture   // R=absorbency, G=roughness, B=porosity

    // Final output
    var outputTex: MTLTexture

    var phase: Int = 0

    // Wet layer ping-pong
    var readWetAbsorb: MTLTexture  { phase % 2 == 0 ? wetAbsorbTex : wetAbsorbTexB }
    var writeWetAbsorb: MTLTexture { phase % 2 == 0 ? wetAbsorbTexB : wetAbsorbTex }
    var readProps: MTLTexture     { phase % 2 == 0 ? propsTex : propsTexB }
    var writeProps: MTLTexture    { phase % 2 == 0 ? propsTexB : propsTex }

    func flip() { phase += 1 }

    init(device: MTLDevice, width: Int = 1024, height: Int = 1024) throws {
        self.device = device
        self.width = width
        self.height = height

        self.wetAbsorbTex    = try Self.makeTexture2DOrThrow(device: device, width: width, height: height, pixelFormat: .rgba16Float)
        self.wetAbsorbTexB   = try Self.makeTexture2DOrThrow(device: device, width: width, height: height, pixelFormat: .rgba16Float)
        self.solidAbsorbTex  = try Self.makeTexture2DOrThrow(device: device, width: width, height: height, pixelFormat: .rgba16Float)
        self.propsTex       = try Self.makeTexture2DOrThrow(device: device, width: width, height: height, pixelFormat: .rgba16Float)
        self.propsTexB      = try Self.makeTexture2DOrThrow(device: device, width: width, height: height, pixelFormat: .rgba16Float)
        self.heightTex      = try Self.makeTexture2DOrThrow(device: device, width: width, height: height, pixelFormat: .r32Float)
        self.canvasPropsTex = try Self.makeTexture2DOrThrow(device: device, width: width, height: height, pixelFormat: .rgba16Float)
        self.outputTex      = try Self.makeTexture2DOrThrow(device: device, width: width, height: height, pixelFormat: .rgba8Unorm)
    }

}

// MARK: - Brush point (CPU → GPU)

/// Must match Metal BrushPoint layout exactly — all flat floats, 56 bytes.
/// Stores absorption values (0 = transparent, higher = more opaque pigment).
struct BrushPoint {
    var x: Float
    var y: Float
    var pressure: Float
    var radius: Float
    var absR: Float         // absorption red channel (0-8+)
    var absG: Float         // absorption green channel (0-8+)
    var absB: Float         // absorption blue channel (0-8+)
    var concentration: Float // pigment concentration (0-1)
    var viscosity: Float
    var tipType: Float      // 0=round, 1=flat, 2=filbert, 3=fan, 4=knife
    var angle: Float        // brush tip rotation in radians
    var dirX: Float         // stroke travel direction (normalized)
    var dirY: Float
    var wetness: Float = 0  // brush wetness (0=dry brush, 1=saturated)

    static let stride = MemoryLayout<BrushPoint>.stride
}

/// Codable-friendly brush point — stores absorption values.
struct CodableBrushPoint: Codable {
    var x: Float, y: Float
    var pressure: Float, radius: Float
    var absR: Float, absG: Float, absB: Float, concentration: Float
    var viscosity: Float
    var tipType: Float = 0
    var angle: Float = 0
    var dirX: Float = 0
    var dirY: Float = 0
    var wetness: Float = 0

    /// Map new field names to legacy JSON keys for backward compatibility.
    enum CodingKeys: String, CodingKey {
        case x, y, pressure, radius
        case absR = "r"
        case absG = "g"
        case absB = "b"
        case concentration = "a"
        case viscosity, tipType, angle, dirX, dirY, wetness
    }

    var asBrushPoint: BrushPoint {
        BrushPoint(x: x, y: y, pressure: pressure, radius: radius,
                   absR: absR, absG: absG, absB: absB, concentration: concentration,
                   viscosity: viscosity, tipType: tipType, angle: angle,
                   dirX: dirX, dirY: dirY, wetness: wetness)
    }
}

enum BrushMode: String, Codable, CaseIterable, Identifiable {
    case oil
    case watercolor
    case acrylic
    case pastel
    case highlighter

    var id: String { rawValue }

    /// Metal kernel mode index
    var modeIndex: Int32 {
        switch self {
        case .oil: return 0
        case .watercolor: return 1
        case .acrylic: return 2
        case .pastel: return 3
        case .highlighter: return 4
        }
    }
}

enum BrushTip: String, CaseIterable, Identifiable {
    case round = "Round"
    case flat = "Flat"
    case filbert = "Filbert"
    case fan = "Fan"
    case knife = "Knife"
    // Watercolor-specific
    case mop = "Mop"
    case rigger = "Rigger"
    case wash = "Wash"
    // Pastel-specific
    case stick = "Stick"
    case edge = "Edge"
    case blender = "Blender"
    case hard = "Hard"
    case soft = "Soft"
    // Highlighter-specific
    case chisel = "Chisel"
    case fine = "Fine"
    case bullet = "Bullet"

    var id: String { rawValue }

    var tipIndex: Float {
        switch self {
        case .round:   return 0
        case .flat:    return 1
        case .filbert: return 2
        case .fan:     return 3
        case .knife:   return 4
        case .mop:     return 5
        case .rigger:  return 6
        case .wash:    return 7
        case .stick:   return 8
        case .edge:    return 9
        case .blender: return 10
        case .hard:    return 11
        case .soft:    return 12
        case .chisel:  return 13
        case .fine:    return 14
        case .bullet:  return 15
        }
    }

    /// Returns the set of tips available for a given medium.
    static func tips(for medium: BrushMode) -> [BrushTip] {
        switch medium {
        case .oil:         return [.round, .flat, .filbert, .fan, .knife]
        case .watercolor:  return [.round, .flat, .mop, .rigger, .wash]
        case .acrylic:     return [.round, .flat, .filbert, .fan, .knife]
        case .pastel:      return [.stick, .edge, .blender, .hard, .soft]
        case .highlighter: return [.chisel, .fine, .bullet]
        }
    }
}

/// Complete brush stroke.
struct BrushStroke: Codable {
    var points: [CodableBrushPoint]
    var mode: BrushMode
    var timestamp: Date = Date()
}

/// Stroke history for save/load.
struct StrokeHistory: Codable {
    var strokes: [BrushStroke] = []

    static let stateDir: URL = {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/kopigajj/paint-state", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    func save(name: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)
        try data.write(to: Self.stateDir.appendingPathComponent("\(name).json"))
    }

    static func load(name: String) -> StrokeHistory? {
        let url = stateDir.appendingPathComponent("\(name).json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(StrokeHistory.self, from: data)
    }

    static func list() -> [String] {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: stateDir, includingPropertiesForKeys: nil
        ) else { return [] }
        return files.filter { $0.pathExtension == "json" }
            .map { $0.deletingPathExtension().lastPathComponent }
            .sorted()
    }
}
