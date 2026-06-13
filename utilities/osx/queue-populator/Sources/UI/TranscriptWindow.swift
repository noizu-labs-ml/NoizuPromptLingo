import AppKit

@MainActor
final class TranscriptWindow {
    private let window: NSWindow
    private let statusLabel = NSTextField(labelWithString: "Idle")
    private let liveTextView = NSTextView()
    private let eventTextView = NSTextView()
    private var eventScrollView: NSScrollView?
    private let eventLog = NSMutableAttributedString()
    private var phrases = PhrasesConfig()
    private var onConfigure: (() -> Void)?
    private var onBrowseQueue: (() -> Void)?
    private var commandsTarget: BlockTarget?
    private var configureTarget: BlockTarget?
    private var eventLogTarget: BlockTarget?
    private var browseQueueTarget: BlockTarget?

    init() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 760, height: 560),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Queue Populator - Transcript"
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 560, height: 380)

        let container = NSView(frame: window.contentView!.bounds)
        container.autoresizingMask = [.width, .height]
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        let header = NSVisualEffectView(frame: NSRect(x: 0, y: container.bounds.height - 74, width: container.bounds.width, height: 74))
        header.autoresizingMask = [.width, .minYMargin]
        header.material = .headerView
        header.state = .active
        container.addSubview(header)

        let appIcon = NSImageView(frame: NSRect(x: 16, y: 17, width: 40, height: 40))
        appIcon.image = queuePopulatorAppIcon(size: NSSize(width: 40, height: 40))
        appIcon.imageScaling = .scaleProportionallyUpOrDown
        header.addSubview(appIcon)

        let title = NSTextField(labelWithString: "Queue Populator")
        title.frame = NSRect(x: 68, y: 38, width: 260, height: 24)
        title.font = NSFont.systemFont(ofSize: 20, weight: .semibold)
        title.textColor = .labelColor
        header.addSubview(title)

        statusLabel.frame = NSRect(x: 69, y: 18, width: 420, height: 18)
        statusLabel.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        statusLabel.textColor = .secondaryLabelColor
        header.addSubview(statusLabel)

        let commandsButton = NSButton(frame: NSRect(x: container.bounds.width - 500, y: 24, width: 96, height: 28))
        commandsButton.title = "Commands"
        commandsButton.image = NSImage(systemSymbolName: "quote.bubble", accessibilityDescription: "Commands")
        commandsButton.imagePosition = .imageLeading
        commandsButton.bezelStyle = .texturedRounded
        commandsButton.toolTip = "Show command phrases"
        commandsButton.autoresizingMask = [.minXMargin]
        let commandsTarget = BlockTarget { [weak self] in self?.showCommandsPopup() }
        commandsButton.target = commandsTarget
        commandsButton.action = #selector(BlockTarget.invoke)
        self.commandsTarget = commandsTarget
        header.addSubview(commandsButton)

        let eventButton = NSButton(frame: NSRect(x: container.bounds.width - 394, y: 24, width: 92, height: 28))
        eventButton.title = "Event Log"
        eventButton.image = NSImage(systemSymbolName: "list.bullet.rectangle", accessibilityDescription: "Event Log")
        eventButton.imagePosition = .imageLeading
        eventButton.bezelStyle = .texturedRounded
        eventButton.toolTip = "Jump to latest event"
        eventButton.autoresizingMask = [.minXMargin]
        let eventTarget = BlockTarget { [weak self] in self?.focusEventLog() }
        eventButton.target = eventTarget
        eventButton.action = #selector(BlockTarget.invoke)
        self.eventLogTarget = eventTarget
        header.addSubview(eventButton)

        let browseButton = NSButton(frame: NSRect(x: container.bounds.width - 294, y: 24, width: 232, height: 28))
        browseButton.title = "Queue Folder"
        browseButton.image = NSImage(systemSymbolName: "folder", accessibilityDescription: "Queue Folder")
        browseButton.imagePosition = .imageLeading
        browseButton.bezelStyle = .texturedRounded
        browseButton.toolTip = "Browse Personal Development queue folder"
        browseButton.autoresizingMask = [.minXMargin]
        let browseTarget = BlockTarget { [weak self] in self?.onBrowseQueue?() }
        browseButton.target = browseTarget
        browseButton.action = #selector(BlockTarget.invoke)
        self.browseQueueTarget = browseTarget
        header.addSubview(browseButton)

        let configureButton = NSButton(frame: NSRect(x: container.bounds.width - 52, y: 24, width: 32, height: 28))
        configureButton.title = ""
        configureButton.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: "Configure")
        configureButton.imagePosition = .imageOnly
        configureButton.bezelStyle = .texturedRounded
        configureButton.toolTip = "Configure"
        configureButton.autoresizingMask = [.minXMargin]
        let configureTarget = BlockTarget { [weak self] in self?.onConfigure?() }
        configureButton.target = configureTarget
        configureButton.action = #selector(BlockTarget.invoke)
        self.configureTarget = configureTarget
        header.addSubview(configureButton)

        let livePanel = panel(frame: NSRect(x: 16, y: container.bounds.height - 234, width: container.bounds.width - 32, height: 144))
        livePanel.autoresizingMask = [.width, .minYMargin]
        container.addSubview(livePanel)

        let liveTitle = sectionLabel("Live memo")
        liveTitle.frame = NSRect(x: 14, y: livePanel.bounds.height - 30, width: 200, height: 18)
        livePanel.addSubview(liveTitle)

        configure(liveTextView, fontSize: 16, weight: .semibold)
        let liveScroll = scrollView(frame: NSRect(x: 12, y: 12, width: livePanel.bounds.width - 24, height: livePanel.bounds.height - 48), textView: liveTextView)
        liveScroll.autoresizingMask = [.width, .height]
        livePanel.addSubview(liveScroll)

        let eventPanel = panel(frame: NSRect(x: 16, y: 16, width: container.bounds.width - 32, height: container.bounds.height - 266))
        eventPanel.autoresizingMask = [.width, .height]
        container.addSubview(eventPanel)

        let eventTitle = sectionLabel("Events and LLM trace")
        eventTitle.frame = NSRect(x: 14, y: eventPanel.bounds.height - 30, width: 240, height: 18)
        eventTitle.autoresizingMask = [.maxYMargin]
        eventPanel.addSubview(eventTitle)

        configure(eventTextView, fontSize: 12, weight: .regular)
        let eventScroll = scrollView(frame: NSRect(x: 12, y: 12, width: eventPanel.bounds.width - 24, height: eventPanel.bounds.height - 48), textView: eventTextView)
        eventScroll.autoresizingMask = [.width, .height]
        eventScrollView = eventScroll
        eventPanel.addSubview(eventScroll)

        window.contentView = container
        window.center()
    }

    func show() {
        showInteractiveWindow(window)
    }

    func setOnConfigure(_ handler: @escaping () -> Void) {
        onConfigure = handler
    }

    func setOnBrowseQueue(_ handler: @escaping () -> Void) {
        onBrowseQueue = handler
    }

    func updateCommands(phrases: PhrasesConfig) {
        self.phrases = phrases
    }

    func updateLiveTranscript(_ text: String, state: AppState) {
        statusLabel.stringValue = "\(state.label) - \(state.activePhraseHints)"
        statusLabel.textColor = stateColor(state)

        let attributed = NSMutableAttributedString()
        attributed.append(NSAttributedString(
            string: text.isEmpty ? "Listening..." : text,
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: text.isEmpty ? NSColor.secondaryLabelColor : NSColor.labelColor,
            ]
        ))
        set(liveTextView, to: attributed)
    }

    func appendEvent(_ message: String) {
        appendToEventLog(spacing: eventLog.length > 0 ? "\n" : "") {
            let line = NSMutableAttributedString()
            line.append(timestamp())
            line.append(NSAttributedString(
                string: message,
                attributes: bodyAttributes()
            ))
            return line
        }
    }

    func appendBlock(title: String, body: String, color: NSColor = .systemBlue) {
        appendToEventLog(spacing: eventLog.length > 0 ? "\n\n" : "") {
            let block = NSMutableAttributedString()
            block.append(NSAttributedString(
                string: "\(title)\n",
                attributes: [
                    .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .bold),
                    .foregroundColor: color,
                ]
            ))
            block.append(NSAttributedString(
                string: body.isEmpty ? "(empty)" : body,
                attributes: bodyAttributes()
            ))
            return block
        }
    }

    private func appendToEventLog(spacing: String, build: () -> NSAttributedString) {
        if !spacing.isEmpty {
            eventLog.append(NSAttributedString(string: spacing))
        }
        eventLog.append(build())
        set(eventTextView, to: eventLog)
        eventTextView.scrollToEndOfDocument(nil)
    }

    private func focusEventLog() {
        showInteractiveWindow(window)
        eventScrollView?.flashScrollers()
        eventTextView.scrollToEndOfDocument(nil)
    }

    private func showCommandsPopup() {
        let alert = NSAlert()
        alert.messageText = "Command Phrases"
        alert.informativeText = """
        Wake: \(phrases.wake)
        End memo: \(phrases.end)
        Approve memo: \(phrases.approveMemo)
        Cancel: \(phrases.cancel)
        Approve entries: \(phrases.approve)
        Revise entries: \(phrases.revise)
        """
        alert.addButton(withTitle: "Done")
        alert.beginSheetModal(for: window)
    }

    private func timestamp() -> NSAttributedString {
        let value = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        return NSAttributedString(
            string: "[\(value)] ",
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium),
                .foregroundColor: NSColor.secondaryLabelColor,
            ]
        )
    }

    private func bodyAttributes() -> [NSAttributedString.Key: Any] {
        [
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .foregroundColor: NSColor.labelColor,
        ]
    }

    private func set(_ textView: NSTextView, to attributed: NSAttributedString) {
        let storage = textView.textStorage!
        storage.beginEditing()
        storage.setAttributedString(attributed)
        storage.endEditing()
    }

    private func panel(frame: NSRect) -> NSView {
        let view = NSView(frame: frame)
        view.wantsLayer = true
        view.layer?.cornerRadius = 8
        view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        view.layer?.borderColor = NSColor.separatorColor.cgColor
        view.layer?.borderWidth = 1
        return view
    }

    private func sectionLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text.uppercased())
        label.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .bold)
        label.textColor = .secondaryLabelColor
        return label
    }

    private func scrollView(frame: NSRect, textView: NSTextView) -> NSScrollView {
        let scroll = NSScrollView(frame: frame)
        scroll.hasVerticalScroller = true
        scroll.borderType = .noBorder
        scroll.documentView = textView
        return scroll
    }

    private func configure(_ textView: NSTextView, fontSize: CGFloat, weight: NSFont.Weight) {
        textView.isEditable = false
        textView.isSelectable = true
        textView.isRichText = true
        textView.drawsBackground = false
        textView.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: weight)
        textView.textColor = .labelColor
        textView.textContainerInset = NSSize(width: 6, height: 6)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true
    }

    private func stateColor(_ state: AppState) -> NSColor {
        switch state {
        case .idle: .secondaryLabelColor
        case .recording: .systemRed
        case .memoReview: .systemBlue
        case .processing: .systemOrange
        case .review: .systemGreen
        case .revising: .systemPurple
        }
    }
}
