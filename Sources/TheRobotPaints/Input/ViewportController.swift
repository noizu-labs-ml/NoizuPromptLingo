import AppKit

final class ViewportController: @unchecked Sendable {
    let canvasWidth: Int
    let canvasHeight: Int

    var zoomLevel: Float = 1.0 {
        didSet { onZoomChanged?(zoomLevel) }
    }
    var onZoomChanged: ((Float) -> Void)?
    var panOffsetX: Float = 0.0
    var panOffsetY: Float = 0.0

    private var lastDrawableWidth: Int = 0
    private var lastDrawableHeight: Int = 0

    init(canvasWidth: Int, canvasHeight: Int) {
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
    }

    var currentScale: Float {
        guard lastDrawableWidth > 0, lastDrawableHeight > 0 else { return 1.0 }
        let fitScale = min(Float(lastDrawableWidth) / Float(canvasWidth),
                           Float(lastDrawableHeight) / Float(canvasHeight))
        return fitScale * zoomLevel
    }

    func updateDrawableSize(width: Int, height: Int) {
        lastDrawableWidth = width
        lastDrawableHeight = height
    }

    func handleMagnify(delta: Float, atDrawablePixel pixel: CGPoint) {
        let oldScale = currentScale
        let clampedDelta = max(-0.5, min(0.5, delta))
        zoomLevel = max(0.1, min(32.0, zoomLevel * (1.0 + clampedDelta)))
        let newScale = currentScale

        guard oldScale > 0, newScale > 0 else { return }
        let cursorX = Float(pixel.x)
        let cursorY = Float(pixel.y)
        let dw = Float(lastDrawableWidth)
        let dh = Float(lastDrawableHeight)
        panOffsetX += (cursorX - dw / 2.0) * (1.0 / oldScale - 1.0 / newScale)
        panOffsetY += (cursorY - dh / 2.0) * (1.0 / oldScale - 1.0 / newScale)
    }

    func handlePan(dx: Float, dy: Float) {
        let scale = currentScale
        guard scale > 0 else { return }
        panOffsetX -= dx / scale
        panOffsetY -= dy / scale
    }

    func handle3DMouse(translationX: Float, translationY: Float, translationZ: Float) {
        let scale = currentScale
        guard scale > 0 else { return }
        panOffsetX += translationX * 2.0 / scale
        panOffsetY -= translationY * 2.0 / scale
        let zoomDelta = translationZ * 0.02
        zoomLevel = max(0.1, min(32.0, zoomLevel * (1.0 + zoomDelta)))
    }

    func resetView() {
        zoomLevel = 1.0
        panOffsetX = 0.0
        panOffsetY = 0.0
    }

    func screenToCanvas(drawablePixel: CGPoint) -> CGPoint {
        let scale = currentScale
        guard scale > 0 else { return .zero }
        let dw = Float(lastDrawableWidth)
        let dh = Float(lastDrawableHeight)
        let cw = Float(canvasWidth)
        let ch = Float(canvasHeight)
        let fitScale = min(dw / cw, dh / ch)
        let baseX = cw / 2.0 - dw / (2.0 * fitScale * zoomLevel)
        let baseY = ch / 2.0 - dh / (2.0 * fitScale * zoomLevel)
        let canvasX = Float(drawablePixel.x) / scale + baseX + panOffsetX
        let canvasY = Float(drawablePixel.y) / scale + baseY + panOffsetY
        return CGPoint(x: CGFloat(canvasX), y: CGFloat(canvasY))
    }

    func makeViewParams(drawableWidth: Int, drawableHeight: Int) -> ViewParams {
        ViewParams(
            zoomLevel: zoomLevel,
            panOffsetX: panOffsetX,
            panOffsetY: panOffsetY,
            canvasWidth: UInt32(canvasWidth),
            canvasHeight: UInt32(canvasHeight),
            drawableWidth: UInt32(drawableWidth),
            drawableHeight: UInt32(drawableHeight))
    }
}
