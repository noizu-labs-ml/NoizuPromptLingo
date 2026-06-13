struct ViewParams: Sendable {
    var zoomLevel: Float = 1.0
    var panOffsetX: Float = 0.0
    var panOffsetY: Float = 0.0
    var pitch: Float = 0.0
    var yaw: Float = 0.0
    var roll: Float = 0.0
    var canvasWidth: UInt32 = 0
    var canvasHeight: UInt32 = 0
    var drawableWidth: UInt32 = 0
    var drawableHeight: UInt32 = 0
}
