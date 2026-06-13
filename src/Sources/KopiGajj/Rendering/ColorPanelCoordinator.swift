import AppKit

// MARK: - NSColorPanel coordinator

/// Bridges NSColorPanel (target/action) back into SwiftUI ObservableObject state.
/// Singleton so it persists across SwiftUI re-renders (PaintCanvasControls is a struct).
final class ColorPanelCoordinator: NSObject {
    static let shared = ColorPanelCoordinator()
    private weak var state: PaintCanvasState?

    private override init() { super.init() }

    func attach(state: PaintCanvasState, panel: NSColorPanel) {
        self.state = state
        panel.setTarget(self)
        panel.setAction(#selector(colorChanged(_:)))
    }

    @objc private func colorChanged(_ sender: NSColorPanel) {
        guard let state else { return }
        let color = sender.color
        DispatchQueue.main.async {
            if let rgb = color.usingColorSpace(.deviceRGB) {
                state.brushColor = rgb
            }
        }
    }
}

// MARK: - NSColor comparison helper

extension NSColor {
    func isClose(to other: NSColor, tolerance: CGFloat = 0.02) -> Bool {
        abs(redComponent - other.redComponent) < tolerance &&
        abs(greenComponent - other.greenComponent) < tolerance &&
        abs(blueComponent - other.blueComponent) < tolerance
    }
}
