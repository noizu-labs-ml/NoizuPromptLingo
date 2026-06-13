import Foundation

enum MediaType: UInt32, Sendable, CaseIterable {
    case watercolor = 0
    case oil = 1
    case acrylic = 2
    case charcoal = 3
    case pastel = 4
}

enum BrushShape: UInt32, Sendable {
    case round = 0
    case flat = 1
    case fan = 2
}

struct BrushPoint: Sendable {
    var positionX: Float = 0
    var positionY: Float = 0
    var pressure: Float = 0
    var tiltX: Float = 0
    var tiltY: Float = 0
    var size: Float = 0
    var timestamp: Float = 0
    var _padding: Float = 0
}

struct BrushParams: Sendable {
    var size: Float = 10.0
    var opacity: Float = 1.0
    var flow: Float = 1.0
    var hardness: Float = 0.5
    var mediaType: UInt32 = 0
    var shapeType: UInt32 = 0
    var colorR: Float16 = 0.8
    var colorG: Float16 = 0.2
    var colorB: Float16 = 0.1
    var colorO: Float16 = 1
    var angle: Float = 0
    var spacing: Float = 0.1
    var scatter: Float = 0
    var activeLayer: UInt32 = 0
    var isEraser: UInt32 = 0
    var isWaterOnly: UInt32 = 0
    var _pad2: UInt32 = 0
    var _pad3: UInt32 = 0
}

struct DepositParams: Sendable {
    var canvasWidth: UInt32 = 0
    var canvasHeight: UInt32 = 0
    var layerCount: UInt32 = 0
    var pointCount: UInt32 = 0
}

struct StrokeRecord: Sendable {
    let brushParams: BrushParams
    let points: [BrushPoint]
    let targetLayer: Int
}
