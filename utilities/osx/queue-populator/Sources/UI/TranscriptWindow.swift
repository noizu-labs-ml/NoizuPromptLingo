import AppKit

@MainActor
final class TranscriptWindow {
    private let window: NSWindow
    private let textView: NSTextView
    private let scrollView: NSScrollView
    private var liveTranscript = NSAttributedString()
    private let eventLog = NSMutableAttributedString()

    init() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 360),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Queue Populator — Transcript"
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 360, height: 200)

        let container = NSView(frame: window.contentView!.bounds)
        container.autoresizingMask = [.width, .height]

        scrollView = NSScrollView(frame: container.bounds)
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder

        textView = NSTextView(frame: scrollView.contentView.bounds)
        textView.autoresizingMask = [.width]
        textView.isEditable = false
        textView.isSelectable = true
        textView.isRichText = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.textColor = .labelColor
        textView.backgroundColor = .textBackgroundColor
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true

        scrollView.documentView = textView
        container.addSubview(scrollView)

        window.contentView = container
        window.center()
    }

    func show() {
        window.makeKeyAndOrderFront(nil)
    }

    func updateLiveTranscript(_ text: String, state: AppState) {
        let statePrefix = "[\(state.label)] "

        let attributed = NSMutableAttributedString()
        attributed.append(NSAttributedString(
            string: statePrefix,
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .bold),
                .foregroundColor: stateColor(state),
            ]
        ))
        attributed.append(NSAttributedString(
            string: text,
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular),
                .foregroundColor: NSColor.labelColor,
            ]
        ))

        liveTranscript = attributed
        render()
    }

    func appendEvent(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let line = NSMutableAttributedString()

        if eventLog.length > 0 {
            line.append(NSAttributedString(string: "\n"))
        }
        line.append(NSAttributedString(
            string: "[\(timestamp)] ",
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular),
                .foregroundColor: NSColor.secondaryLabelColor,
            ]
        ))
        line.append(NSAttributedString(
            string: message,
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular),
                .foregroundColor: NSColor.labelColor,
            ]
        ))

        eventLog.append(line)
        render()
    }

    func appendBlock(title: String, body: String, color: NSColor = .systemBlue) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let block = NSMutableAttributedString()

        if eventLog.length > 0 {
            block.append(NSAttributedString(string: "\n\n"))
        }
        block.append(NSAttributedString(
            string: "[\(timestamp)] \(title)\n",
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .bold),
                .foregroundColor: color,
            ]
        ))
        block.append(NSAttributedString(
            string: body.isEmpty ? "(empty)" : body,
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                .foregroundColor: NSColor.labelColor,
            ]
        ))

        eventLog.append(block)
        render()
    }

    private func render() {
        let storage = textView.textStorage!
        let rendered = NSMutableAttributedString()
        if liveTranscript.length > 0 {
            rendered.append(liveTranscript)
        }
        if eventLog.length > 0 {
            if rendered.length > 0 {
                rendered.append(NSAttributedString(string: "\n\n"))
            }
            rendered.append(eventLog)
        }
        storage.beginEditing()
        storage.setAttributedString(rendered)
        storage.endEditing()
        textView.scrollToEndOfDocument(nil)
    }

    private func stateColor(_ state: AppState) -> NSColor {
        switch state {
        case .idle: .secondaryLabelColor
        case .recording: .systemRed
        case .processing: .systemOrange
        case .review: .systemGreen
        case .revising: .systemPurple
        }
    }
}
