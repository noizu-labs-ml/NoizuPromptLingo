import Cocoa
import SwiftUI

/// Manages the popup clipboard window lifecycle
///
/// Creates, configures, and controls the floating window that appears
/// when the global hotkey is pressed.
class PopupWindowManager: ObservableObject {
    @Published var isVisible = false

    private var popupWindow: NSWindow?

    /// Show the popup window
    func showPopup() {
        defer { isVisible = true }

        if popupWindow == nil {
            createPopupWindow()
        }

        guard let window = popupWindow else { return }

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        window.center()
        window.orderFrontRegardless()
        window.makeKey()
        window.makeFirstResponder(window.contentView)
    }

    /// Hide the popup window
    func hidePopup() {
        guard let window = popupWindow else { return }

        window.orderOut(nil)
        NSApp.setActivationPolicy(.accessory)
        isVisible = false
    }

    /// Toggle popup visibility
    func togglePopup() {
        if isVisible { hidePopup() } else { showPopup() }
    }

    // MARK: - Private

    private func createPopupWindow() {
        // Stage 0.5: Canvas tuning view (preview + live sliders)
        let contentView = CanvasTuningView {
            self.hidePopup()
        }

        let windowWidth: CGFloat = 1400
        let windowHeight: CGFloat = 900

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .fullSizeContentView, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "Canvas Render Engine — Tuning"
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.titleVisibility = .hidden

        window.level = .floating
        window.backgroundColor = NSColor.windowBackgroundColor
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.minSize = NSSize(width: 700, height: 480)

        // Show close button (hides other buttons)
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.autoresizingMask = [.width, .height]
        window.contentView = hostingView

        self.popupWindow = window
    }
}
