import AppKit

@MainActor
final class StateOverlay {
    private var window: NSWindow?
    private var dismissTimer: Timer?

    func show(message: String, icon: String = "🎤", duration: Double = 3.0) {
        dismissTimer?.invalidate()

        if window == nil {
            window = createWindow()
        }

        guard let window else { return }
        updateContent(in: window, message: message, icon: icon)
        window.alphaValue = 0
        window.orderFrontRegardless()
        positionAtTopCenter(window)

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            window.animator().alphaValue = 1.0
        }

        dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.dismiss()
            }
        }
    }

    func showState(_ state: AppState, phrases: PhrasesConfig) {
        let (message, icon) = stateDisplay(state, phrases: phrases)
        let duration: Double = state == .processing ? 30.0 : 5.0
        show(message: message, icon: icon, duration: duration)
    }

    func dismiss() {
        guard let window else { return }
        let w = window
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.3
            w.animator().alphaValue = 0
        }, completionHandler: {
            Task { @MainActor [weak self] in
                self?.window?.orderOut(nil)
            }
        })
    }

    private func stateDisplay(_ state: AppState, phrases: PhrasesConfig) -> (String, String) {
        switch state {
        case .idle:
            return ("Listening for \"\(phrases.wake)\"", "👂")
        case .recording:
            return ("Recording... say \"\(phrases.end)\" to finish", "🔴")
        case .memoReview:
            return ("Review memo, edit, or say \"\(phrases.approveMemo)\"", "📝")
        case .processing:
            return ("Classifying with LLM...", "🧠")
        case .review(let entries):
            return ("\(entries.count) entries — say \"\(phrases.approve)\", \"\(phrases.revise)\", or \"\(phrases.cancel)\"", "✅")
        case .revising:
            return ("Recording revision... say \"\(phrases.end)\" to submit", "✏️")
        }
    }

    private func createWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 56),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        let container = NSVisualEffectView(frame: window.contentView!.bounds)
        container.autoresizingMask = [.width, .height]
        container.material = .hudWindow
        container.state = .active
        container.wantsLayer = true
        container.layer?.cornerRadius = 14

        let iconLabel = NSTextField(labelWithString: "")
        iconLabel.identifier = NSUserInterfaceItemIdentifier("overlayIcon")
        iconLabel.font = NSFont.systemFont(ofSize: 22)
        iconLabel.frame = NSRect(x: 14, y: 14, width: 30, height: 28)
        container.addSubview(iconLabel)

        let messageLabel = NSTextField(labelWithString: "")
        messageLabel.identifier = NSUserInterfaceItemIdentifier("overlayMessage")
        messageLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        messageLabel.textColor = .labelColor
        messageLabel.frame = NSRect(x: 48, y: 16, width: 360, height: 22)
        messageLabel.lineBreakMode = .byTruncatingTail
        container.addSubview(messageLabel)

        window.contentView = container
        return window
    }

    private func updateContent(in window: NSWindow, message: String, icon: String) {
        guard let container = window.contentView else { return }
        for view in container.subviews {
            if let label = view as? NSTextField {
                switch label.identifier {
                case NSUserInterfaceItemIdentifier("overlayIcon"):
                    label.stringValue = icon
                case NSUserInterfaceItemIdentifier("overlayMessage"):
                    label.stringValue = message
                default:
                    break
                }
            }
        }
    }

    private func positionAtTopCenter(_ window: NSWindow) {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - window.frame.width / 2
        let y = screenFrame.maxY - window.frame.height - 12
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
