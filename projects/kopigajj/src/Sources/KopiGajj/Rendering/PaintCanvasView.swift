import SwiftUI
import AppKit

/// Interactive paint canvas — drag to paint with oil or watercolor brush.
/// Wraps PaintSimulator and captures mouse events.
struct PaintCanvasView: NSViewRepresentable {
    @ObservedObject var state: PaintCanvasState

    func makeNSView(context: Context) -> PaintCanvasNSView {
        let view = PaintCanvasNSView(state: state)
        return view
    }

    func updateNSView(_ nsView: PaintCanvasNSView, context: Context) {
        nsView.state = state
        nsView.needsDisplay = true  // redraw when timer/stroke updates canvasImage
    }
}
