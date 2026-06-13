import AppKit

@MainActor
final class StatusBarController {
    private var config: QueuePopulatorConfig
    private var pauseMenuItem: NSMenuItem?
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
        self.pauseMenuItem = pauseItem
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
        // No menu-bar status item; state is surfaced via the overlay and transcript window.
    }

    func setPaused(_ paused: Bool) {
        isPaused = paused
        pauseMenuItem?.title = paused ? "Resume Listening" : "Pause Listening"
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
