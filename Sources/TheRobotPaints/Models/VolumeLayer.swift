import Foundation

struct VolumeLayer: Sendable {
    var colorR: Float16 = 0
    var colorG: Float16 = 0
    var colorB: Float16 = 0
    var colorO: Float16 = 0
    var depth: Float16 = 0
    var wetness: Float16 = 0
    var viscosity: Float16 = 0
    var hardness: Float16 = 0
    var velocityX: Float16 = 0
    var velocityY: Float16 = 0
    var surfaceTension: Float16 = 0
    var age: Float16 = 0
    var gloss: Float16 = 0
    var substanceType: Float16 = 0
    var flags: Float16 = 0
    var _padding: Float16 = 0

    static let layerCount = 8
}

struct SimParams: Sendable {
    var canvasWidth: UInt32 = 0
    var canvasHeight: UInt32 = 0
    var layerCount: UInt32 = 0
    var dt: Float = 0
}

struct RenderParams: Sendable {
    var canvasWidth: UInt32 = 0
    var canvasHeight: UInt32 = 0
    var layerCount: UInt32 = 0
}

struct LightParams: Sendable {
    var lightDirX: Float = 0
    var lightDirY: Float = 0
    var lightDirZ: Float = 0
    var ambient: Float = 0
}
