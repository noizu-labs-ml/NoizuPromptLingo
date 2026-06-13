import AppKit

enum ActiveTool: Sendable {
    case brush
    case eraser
    case water
    case pan
    case zoom
    case eyedropper
}

final class InputRouter: @unchecked Sendable {
    var activeTool: ActiveTool = .brush

    let brushEngine: BrushEngine
    let viewport: ViewportController
    var onUndo: (() -> Void)?
    var onRedo: (() -> Void)?
    var onStrokeStart: (() -> Void)?

    init(brushEngine: BrushEngine, viewport: ViewportController) {
        self.brushEngine = brushEngine
        self.viewport = viewport
    }

    func handleMouseDown(event: NSEvent, in view: NSView) {
        if event.clickCount == 2 {
            viewport.resetView()
            return
        }

        let effectiveTool = overriddenTool(for: event)

        switch effectiveTool {
        case .brush, .eraser, .water:
            let viewPoint = view.convert(event.locationInWindow, from: nil)
            let canvasPoint = viewport.screenToCanvas(drawablePixel: viewToDrawablePixel(viewPoint, in: view))
            onStrokeStart?()
            brushEngine.startStroke(event: event, canvasPoint: canvasPoint)
        case .zoom:
            let viewPoint = view.convert(event.locationInWindow, from: nil)
            let pixel = viewToDrawablePixel(viewPoint, in: view)
            let delta: Float = event.modifierFlags.contains(.option) ? -0.3 : 0.3
            viewport.handleMagnify(delta: delta, atDrawablePixel: pixel)
        case .pan, .eyedropper:
            break
        }
    }

    func handleMouseDragged(event: NSEvent, in view: NSView) {
        let effectiveTool = overriddenTool(for: event)

        switch effectiveTool {
        case .brush, .eraser, .water:
            let viewPoint = view.convert(event.locationInWindow, from: nil)
            let canvasPoint = viewport.screenToCanvas(drawablePixel: viewToDrawablePixel(viewPoint, in: view))
            brushEngine.addPoint(event: event, canvasPoint: canvasPoint)
        case .pan:
            viewport.handlePan(dx: Float(event.deltaX), dy: Float(event.deltaY))
        case .zoom, .eyedropper:
            break
        }
    }

    func handleMouseUp(event: NSEvent, in view: NSView) {
        let effectiveTool = overriddenTool(for: event)

        switch effectiveTool {
        case .brush, .eraser, .water:
            _ = brushEngine.endStroke()
        case .pan, .zoom, .eyedropper:
            break
        }
    }

    func handleMagnify(event: NSEvent, in view: NSView) {
        let viewPoint = view.convert(event.locationInWindow, from: nil)
        let pixel = viewToDrawablePixel(viewPoint, in: view)
        viewport.handleMagnify(delta: Float(event.magnification), atDrawablePixel: pixel)
    }

    func handleScrollWheel(event: NSEvent, in view: NSView) {
        let dx = Float(event.scrollingDeltaX)
        let dy = Float(event.scrollingDeltaY)

        if event.modifierFlags.contains(.command) {
            let viewPoint = view.convert(event.locationInWindow, from: nil)
            let pixel = viewToDrawablePixel(viewPoint, in: view)
            viewport.handleMagnify(delta: dy * 0.005, atDrawablePixel: pixel)
        } else if abs(dy) > abs(dx), event.hasPreciseScrollingDeltas {
            let viewPoint = view.convert(event.locationInWindow, from: nil)
            let pixel = viewToDrawablePixel(viewPoint, in: view)
            viewport.handleMagnify(delta: -dy * 0.002, atDrawablePixel: pixel)
        } else {
            viewport.handlePan(dx: dx, dy: dy)
        }
    }

    func handleOtherMouseDragged(event: NSEvent) {
        viewport.handlePan(dx: Float(event.deltaX), dy: Float(event.deltaY))
    }

    func handleKeyDown(event: NSEvent) {
        if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "0" {
            viewport.resetView()
        }
        if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "z" {
            if event.modifierFlags.contains(.shift) {
                onRedo?()
            } else {
                onUndo?()
            }
        }
    }

    private func overriddenTool(for event: NSEvent) -> ActiveTool {
        if event.modifierFlags.contains(.option) { return .eyedropper }
        if spaceIsHeld { return .pan }
        return activeTool
    }

    private func viewToDrawablePixel(_ viewPoint: NSPoint, in view: NSView) -> CGPoint {
        let backingScale = view.window?.backingScaleFactor ?? 2.0
        let pixelX = viewPoint.x * backingScale
        let pixelY = (view.bounds.height - viewPoint.y) * backingScale
        return CGPoint(x: pixelX, y: pixelY)
    }

    private var spaceIsHeld: Bool {
        NSEvent.modifierFlags.contains(.function) == false &&
        CGEventSource.keyState(.combinedSessionState, key: CGKeyCode(49))
    }
}
