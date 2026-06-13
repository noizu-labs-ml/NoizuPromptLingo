import AppKit

@MainActor
final class StatusBarController {
    private var statusItem: NSStatusItem?
    private var config: QueuePopulatorConfig
    private var stateMenuItem: NSMenuItem?
    private var pauseMenuItem: NSMenuItem?
    private var controlPauseMenuItem: NSMenuItem?
    private var onConfigure: (() -> Void)?
    private var onShowTranscript: (() -> Void)?
    private var onTogglePause: (() -> Void)?
    private var onQuit: (() -> Void)?
    private(set) var isPaused: Bool = false

    init(config: QueuePopulatorConfig) {
        self.config = config
    }

    func updateConfig(_ config: QueuePopulatorConfig) {
        self.config = config
        if let button = statusItem?.button {
            button.toolTip = "Queue Populator — Listening for \"\(config.phrases.wake)\""
        }
    }

    func setup(
        onConfigure: @escaping () -> Void,
        onShowTranscript: @escaping () -> Void,
        onTogglePause: @escaping () -> Void,
        onQuit: @escaping () -> Void
    ) {
        self.onConfigure = onConfigure
        self.onShowTranscript = onShowTranscript
        self.onTogglePause = onTogglePause
        self.onQuit = onQuit

        installApplicationMenu()

        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.isVisible = true
        self.statusItem = statusItem

        if let button = statusItem.button {
            button.title = "Q"
            button.image = nil
            button.toolTip = "Queue Populator — Listening for \"\(config.phrases.wake)\""
        }

        let menu = NSMenu()

        let stateItem = NSMenuItem(title: "State: Idle", action: nil, keyEquivalent: "")
        stateItem.isEnabled = false
        self.stateMenuItem = stateItem
        menu.addItem(stateItem)

        menu.addItem(.separator())

        let pauseItem = NSMenuItem(title: "Pause Listening", action: #selector(togglePause(_:)), keyEquivalent: "p")
        pauseItem.target = self
        self.pauseMenuItem = pauseItem
        menu.addItem(pauseItem)

        let transcriptItem = NSMenuItem(title: "Show Transcript", action: #selector(showTranscript(_:)), keyEquivalent: "t")
        transcriptItem.target = self
        menu.addItem(transcriptItem)

        let configureItem = NSMenuItem(title: "Configure...", action: #selector(configure(_:)), keyEquivalent: ",")
        configureItem.target = self
        menu.addItem(configureItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit(_:)), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func installApplicationMenu() {
        let mainMenu = NSMenu()

        let appItem = NSMenuItem()
        mainMenu.addItem(appItem)

        let appMenu = NSMenu(title: "Queue Populator")
        appItem.submenu = appMenu

        let configureItem = NSMenuItem(title: "Configure...", action: #selector(configure(_:)), keyEquivalent: ",")
        configureItem.target = self
        appMenu.addItem(configureItem)

        appMenu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Queue Populator", action: #selector(quit(_:)), keyEquivalent: "q")
        quitItem.target = self
        appMenu.addItem(quitItem)

        let controlItem = NSMenuItem()
        mainMenu.addItem(controlItem)

        let controlMenu = NSMenu(title: "Control")
        controlItem.submenu = controlMenu

        let pauseItem = NSMenuItem(title: "Pause Listening", action: #selector(togglePause(_:)), keyEquivalent: "p")
        pauseItem.target = self
        self.controlPauseMenuItem = pauseItem
        controlMenu.addItem(pauseItem)

        let transcriptItem = NSMenuItem(title: "Show Transcript", action: #selector(showTranscript(_:)), keyEquivalent: "t")
        transcriptItem.target = self
        controlMenu.addItem(transcriptItem)

        let windowItem = NSMenuItem()
        mainMenu.addItem(windowItem)

        let windowMenu = NSMenu(title: "Window")
        windowItem.submenu = windowMenu

        let showTranscriptItem = NSMenuItem(title: "Show Transcript", action: #selector(showTranscript(_:)), keyEquivalent: "")
        showTranscriptItem.target = self
        windowMenu.addItem(showTranscriptItem)

        NSApplication.shared.mainMenu = mainMenu
        NSApplication.shared.windowsMenu = windowMenu
    }

    func updateState(_ state: AppState) {
        guard !isPaused else { return }
        let tooltip = stateTooltip(state)

        if let button = statusItem?.button {
            button.title = "Q"
            button.image = nil
            button.toolTip = tooltip
        }
        stateMenuItem?.title = "State: \(state.label)"
    }

    func setPaused(_ paused: Bool) {
        isPaused = paused
        if paused {
            statusItem?.button?.title = "Q"
            statusItem?.button?.image = nil
            statusItem?.button?.toolTip = "Queue Populator — Paused"
            stateMenuItem?.title = "State: Paused"
            pauseMenuItem?.title = "Resume Listening"
            controlPauseMenuItem?.title = "Resume Listening"
        } else {
            pauseMenuItem?.title = "Pause Listening"
            controlPauseMenuItem?.title = "Pause Listening"
            updateState(.idle)
        }
    }

    private func stateTooltip(_ state: AppState) -> String {
        switch state {
        case .idle:
            "Queue Populator — Listening"
        case .recording:
            "Queue Populator — Recording"
        case .processing:
            "Queue Populator — Processing"
        case .review:
            "Queue Populator — Review"
        case .revising:
            "Queue Populator — Revising"
        }
    }

    @objc private func togglePause(_ sender: Any?) {
        onTogglePause?()
    }

    @objc private func configure(_ sender: Any?) {
        onConfigure?()
    }

    @objc private func showTranscript(_ sender: Any?) {
        onShowTranscript?()
    }

    @objc private func quit(_ sender: Any?) {
        onQuit?()
    }
}
