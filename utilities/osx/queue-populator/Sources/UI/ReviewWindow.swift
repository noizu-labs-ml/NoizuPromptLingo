import AppKit

@MainActor
final class ReviewWindow {
    private let window: NSWindow
    private let scrollView: NSScrollView
    private let stackView: NSStackView
    private let footerLabel: NSTextField
    private var onApprove: (() -> Void)?
    private var onRevise: (() -> Void)?
    private var onCancel: (() -> Void)?
    private var buttonTargets: [BlockTarget] = []

    init() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 400),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Queue Populator — Review Entries"
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 400, height: 250)

        let container = NSView(frame: window.contentView!.bounds)
        container.autoresizingMask = [.width, .height]

        scrollView = NSScrollView(frame: NSRect(x: 0, y: 56, width: container.bounds.width, height: container.bounds.height - 56))
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder

        stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8
        stackView.edgeInsets = NSEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let clipView = scrollView.contentView
        scrollView.documentView = stackView
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: clipView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: clipView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: clipView.topAnchor),
        ])

        container.addSubview(scrollView)

        let buttonBar = NSView(frame: NSRect(x: 0, y: 0, width: container.bounds.width, height: 56))
        buttonBar.autoresizingMask = [.width, .maxYMargin]

        footerLabel = NSTextField(labelWithString: "Say approve, revise, or cancel")
        footerLabel.font = NSFont.systemFont(ofSize: 11)
        footerLabel.textColor = .secondaryLabelColor
        footerLabel.frame = NSRect(x: 16, y: 20, width: 200, height: 16)
        buttonBar.addSubview(footerLabel)

        let approveBtn = NSButton(frame: NSRect(x: container.bounds.width - 120, y: 12, width: 100, height: 32))
        approveBtn.title = "Approve"
        approveBtn.bezelStyle = .rounded
        approveBtn.keyEquivalent = "\r"
        approveBtn.autoresizingMask = [.minXMargin]
        buttonBar.addSubview(approveBtn)

        let reviseBtn = NSButton(frame: NSRect(x: container.bounds.width - 230, y: 12, width: 100, height: 32))
        reviseBtn.title = "Revise"
        reviseBtn.bezelStyle = .rounded
        reviseBtn.keyEquivalent = "r"
        reviseBtn.autoresizingMask = [.minXMargin]
        buttonBar.addSubview(reviseBtn)

        let cancelBtn = NSButton(frame: NSRect(x: container.bounds.width - 340, y: 12, width: 100, height: 32))
        cancelBtn.title = "Cancel"
        cancelBtn.bezelStyle = .rounded
        cancelBtn.keyEquivalent = "\u{1b}"
        cancelBtn.autoresizingMask = [.minXMargin]
        buttonBar.addSubview(cancelBtn)

        let approveTarget = BlockTarget { [weak self] in self?.onApprove?() }
        let reviseTarget = BlockTarget { [weak self] in self?.onRevise?() }
        let cancelTarget = BlockTarget { [weak self] in self?.onCancel?() }

        approveBtn.target = approveTarget
        approveBtn.action = #selector(BlockTarget.invoke)
        reviseBtn.target = reviseTarget
        reviseBtn.action = #selector(BlockTarget.invoke)
        cancelBtn.target = cancelTarget
        cancelBtn.action = #selector(BlockTarget.invoke)

        buttonTargets = [approveTarget, reviseTarget, cancelTarget]

        container.addSubview(buttonBar)
        window.contentView = container
        window.center()
    }

    func show(entries: [ProposedEntry], approve: @escaping () -> Void, revise: @escaping () -> Void, cancel: @escaping () -> Void) {
        self.onApprove = approve
        self.onRevise = revise
        self.onCancel = cancel

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (i, entry) in entries.enumerated() {
            let row = createEntryRow(index: i + 1, entry: entry)
            stackView.addArrangedSubview(row)
        }

        window.title = "Review \(entries.count) Entries"
        window.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    func hide() {
        window.orderOut(nil)
    }

    private func createEntryRow(index: Int, entry: ProposedEntry) -> NSView {
        let row = NSView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let fileLabel = NSTextField(labelWithString: "→ \(entry.file)")
        fileLabel.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        fileLabel.textColor = .secondaryLabelColor
        fileLabel.translatesAutoresizingMaskIntoConstraints = false

        let typeBadge = NSTextField(labelWithString: entry.type.uppercased())
        typeBadge.font = NSFont.systemFont(ofSize: 10, weight: .bold)
        typeBadge.textColor = .white
        typeBadge.drawsBackground = true
        typeBadge.backgroundColor = badgeColor(for: entry.type)
        typeBadge.wantsLayer = true
        typeBadge.layer?.cornerRadius = 3
        typeBadge.alignment = .center
        typeBadge.translatesAutoresizingMaskIntoConstraints = false

        let textLabel = NSTextField(wrappingLabelWithString: "\(index). \(entry.text)")
        textLabel.font = NSFont.systemFont(ofSize: 13)
        textLabel.textColor = .labelColor
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(typeBadge)
        row.addSubview(textLabel)
        row.addSubview(fileLabel)

        NSLayoutConstraint.activate([
            typeBadge.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            typeBadge.topAnchor.constraint(equalTo: row.topAnchor),
            typeBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),

            textLabel.leadingAnchor.constraint(equalTo: typeBadge.trailingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            textLabel.topAnchor.constraint(equalTo: row.topAnchor),

            fileLabel.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor),
            fileLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 2),
            fileLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -4),

            row.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
        ])

        return row
    }

    private func badgeColor(for type: String) -> NSColor {
        switch type.lowercased() {
        case "idea": .systemBlue
        case "task": .systemOrange
        case "reminder": .systemRed
        case "question": .systemPurple
        case "study": .systemGreen
        case "goal": .systemTeal
        default: .systemGray
        }
    }
}
