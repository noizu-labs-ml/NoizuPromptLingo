import AppKit

@MainActor
final class MemoReviewWindow {
    private let window: NSWindow
    private let textView: NSTextView
    private var onProcess: ((String) -> Void)?
    private var onCancel: (() -> Void)?
    private var buttonTargets: [BlockTarget] = []

    var currentText: String {
        textView.string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 360),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Queue Populator - Review Memo"
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 420, height: 260)

        let container = NSView(frame: window.contentView!.bounds)
        container.autoresizingMask = [.width, .height]

        let promptLabel = NSTextField(labelWithString: "Review the captured memo before LLM processing. Say \"approve memo\" to process the current capture.")
        promptLabel.font = NSFont.systemFont(ofSize: 12)
        promptLabel.textColor = .secondaryLabelColor
        promptLabel.frame = NSRect(x: 16, y: container.bounds.height - 38, width: container.bounds.width - 32, height: 18)
        promptLabel.autoresizingMask = [.width, .minYMargin]
        container.addSubview(promptLabel)

        let scrollView = NSScrollView(frame: NSRect(x: 16, y: 64, width: container.bounds.width - 32, height: container.bounds.height - 112))
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder

        textView = NSTextView(frame: scrollView.contentView.bounds)
        textView.autoresizingMask = [.width]
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true
        scrollView.documentView = textView
        container.addSubview(scrollView)

        let buttonBar = NSView(frame: NSRect(x: 0, y: 0, width: container.bounds.width, height: 56))
        buttonBar.autoresizingMask = [.width, .maxYMargin]

        let cancelBtn = NSButton(frame: NSRect(x: container.bounds.width - 236, y: 12, width: 100, height: 32))
        cancelBtn.title = "Cancel"
        cancelBtn.bezelStyle = .rounded
        cancelBtn.keyEquivalent = "\u{1b}"
        cancelBtn.autoresizingMask = [.minXMargin]
        buttonBar.addSubview(cancelBtn)

        let processBtn = NSButton(frame: NSRect(x: container.bounds.width - 126, y: 12, width: 110, height: 32))
        processBtn.title = "Process"
        processBtn.bezelStyle = .rounded
        processBtn.keyEquivalent = "\r"
        processBtn.autoresizingMask = [.minXMargin]
        buttonBar.addSubview(processBtn)

        let processTarget = BlockTarget { [weak self] in
            guard let self else { return }
            self.onProcess?(self.currentText)
        }
        let cancelTarget = BlockTarget { [weak self] in self?.onCancel?() }

        processBtn.target = processTarget
        processBtn.action = #selector(BlockTarget.invoke)
        cancelBtn.target = cancelTarget
        cancelBtn.action = #selector(BlockTarget.invoke)
        buttonTargets = [processTarget, cancelTarget]

        container.addSubview(buttonBar)
        window.contentView = container
        window.center()
    }

    func show(memo: String, process: @escaping (String) -> Void, cancel: @escaping () -> Void) {
        self.onProcess = process
        self.onCancel = cancel
        textView.string = memo
        showInteractiveWindow(window)
    }

    func hide() {
        window.orderOut(nil)
    }
}
