import Foundation

struct SPHParticle: Sendable {
    var positionX: Float = 0
    var positionY: Float = 0
    var velocityX: Float = 0
    var velocityY: Float = 0
    var colorR: Float16 = 0
    var colorG: Float16 = 0
    var colorB: Float16 = 0
    var colorA: Float16 = 0
    var radius: Float16 = 0
    var mass: Float16 = 0
    var localDensity: Float16 = 0
    var restDensity: Float16 = 0
    var viscosity: Float16 = 0
    var smoothingLength: Float16 = 0
    var wetness: Float16 = 0
    var life: Float16 = 0
    var layerIndex: UInt8 = 0
    var flags: UInt8 = 0
    var _pad0: UInt16 = 0
    var _pad1: UInt32 = 0
}

struct SpatialHashCell: Sendable {
    var offset: UInt32 = 0
    var count: UInt32 = 0
}

struct SPHConstants: Sendable {
    var smoothingLength: Float = 8.0
    var restDensity: Float = 1000.0
    var stiffness: Float = 200.0
    var gamma: Float = 7.0
    var viscosityCoeff: Float = 0.005
    var surfaceTensionCoeff: Float = 0.072
    var dt: Float = 0.1
    var particleCount: UInt32 = 0
    var gridWidth: UInt32 = 0
    var gridHeight: UInt32 = 0
    var cellSize: Float = 8.0
    var canvasWidth: UInt32 = 0
    var canvasHeight: UInt32 = 0
    var _pad0: UInt32 = 0
    var _pad1: UInt32 = 0
    var _pad2: UInt32 = 0
}

struct DryingParams: Sendable {
    var canvasWidth: UInt32 = 0
    var canvasHeight: UInt32 = 0
    var layerCount: UInt32 = 0
    var dt: Float = 0.016
}

struct FluidParams: Sendable {
    var canvasWidth: UInt32 = 0
    var canvasHeight: UInt32 = 0
    var layerCount: UInt32 = 0
    var dt: Float = 0.016
    var viscosity: Float = 0.005
    var iterations: UInt32 = 4
    var _pad0: UInt32 = 0
    var _pad1: UInt32 = 0
}
