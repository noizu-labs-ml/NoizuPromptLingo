import SwiftUI
import MetalKit

class CanvasMTKView: MTKView {
    weak var inputRouter: InputRouter?

    override var acceptsFirstResponder: Bool { true }

    override func mouseDown(with event: NSEvent) {
        inputRouter?.handleMouseDown(event: event, in: self)
    }

    override func mouseDragged(with event: NSEvent) {
        inputRouter?.handleMouseDragged(event: event, in: self)
    }

    override func mouseUp(with event: NSEvent) {
        inputRouter?.handleMouseUp(event: event, in: self)
    }

    override func magnify(with event: NSEvent) {
        inputRouter?.handleMagnify(event: event, in: self)
    }

    override func scrollWheel(with event: NSEvent) {
        inputRouter?.handleScrollWheel(event: event, in: self)
    }

    override func otherMouseDragged(with event: NSEvent) {
        inputRouter?.handleOtherMouseDragged(event: event)
    }

    override func keyDown(with event: NSEvent) {
        inputRouter?.handleKeyDown(event: event)
    }
}

struct MetalView: NSViewRepresentable {
    var lightDirX: Float
    var lightDirY: Float
    var lightDirZ: Float
    @Binding var activeTool: ActiveTool
    @Binding var brushSize: Float
    @Binding var brushOpacity: Float
    @Binding var brushColor: Color
    @Binding var mediaType: MediaType
    @Binding var simSpeed: Float
    var layerManager: LayerManager
    @Binding var zoomPercent: Int

    func makeCoordinator() -> Renderer {
        Renderer()
    }

    func makeNSView(context: Context) -> CanvasMTKView {
        let view = CanvasMTKView()
        view.device = MetalEngine.shared.device
        view.delegate = context.coordinator
        view.inputRouter = context.coordinator.inputRouter
        context.coordinator.viewport.onZoomChanged = { [self] zoom in
            DispatchQueue.main.async {
                self.zoomPercent = Int(zoom * 100)
            }
        }
        view.colorPixelFormat = .bgra8Unorm
        view.enableSetNeedsDisplay = false
        view.isPaused = false
        view.preferredFramesPerSecond = 60
        return view
    }

    func updateNSView(_ nsView: CanvasMTKView, context: Context) {
        let renderer = context.coordinator
        renderer.lightDirX = lightDirX
        renderer.lightDirY = lightDirY
        renderer.lightDirZ = lightDirZ
        renderer.inputRouter.activeTool = activeTool
        renderer.brushEngine.brushParams.size = brushSize
        renderer.brushEngine.brushParams.opacity = brushOpacity
        renderer.brushEngine.brushParams.mediaType = mediaType.rawValue
        renderer.brushEngine.brushParams.isEraser = activeTool == .eraser ? 1 : 0
        renderer.simSpeed = simSpeed
        renderer.brushEngine.brushParams.isWaterOnly = activeTool == .water ? 1 : 0
        if let cgColor = NSColor(brushColor).usingColorSpace(.sRGB) {
            let r = Float(cgColor.redComponent)
            let g = Float(cgColor.greenComponent)
            let b = Float(cgColor.blueComponent)
            // Convert from reflectance (what user wants to see) to absorption (what pigment absorbs)
            // Beer-Lambert: visible = paper * exp(-absorption * 2)
            // So absorption = -log(target / paper) / 2
            let paperR: Float = 0.95, paperG: Float = 0.93, paperB: Float = 0.88
            let absR = -log(max(0.01, min(0.99, r)) / paperR) / 2.0
            let absG = -log(max(0.01, min(0.99, g)) / paperG) / 2.0
            let absB = -log(max(0.01, min(0.99, b)) / paperB) / 2.0
            renderer.brushEngine.brushParams.colorR = Float16(max(0, absR))
            renderer.brushEngine.brushParams.colorG = Float16(max(0, absG))
            renderer.brushEngine.brushParams.colorB = Float16(max(0, absB))
        }

        renderer.layerManager.activeLayer = layerManager.activeLayer
        renderer.layerManager.visibility = layerManager.visibility

        let currentZoom = Int(renderer.viewport.zoomLevel * 100)
        if abs(currentZoom - zoomPercent) > 1 {
            renderer.viewport.zoomLevel = Float(zoomPercent) / 100.0
        }
    }
}
