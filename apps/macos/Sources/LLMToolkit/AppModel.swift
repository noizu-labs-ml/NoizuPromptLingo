import AppKit
import Foundation
import LLMToolkitKit
import Observation

@MainActor
@Observable
final class AppModel {
    var preferences: AppPreferences {
        didSet { store.save(preferences) }
    }
    var route: ConsoleRoute = .explore
    var harness: Harness = .claude
    var health = ServiceHealth()
    var isStarting = false
    var banner: String?
    var reloadToken = 0
    var searchText = ""
    var lastError: String?

    @ObservationIgnored private let store: any PreferenceStore
    @ObservationIgnored private let healthClient: any HealthChecking
    @ObservationIgnored private var supervisor: ServerSupervisor
    @ObservationIgnored private var child: Process?
    @ObservationIgnored private var pollTask: Task<Void, Never>?
    @ObservationIgnored private var startedChild = false

    init(
        store: any PreferenceStore = UserDefaultsPreferenceStore(),
        healthClient: any HealthChecking = HealthClient(),
        supervisor: ServerSupervisor = ServerSupervisor()
    ) {
        self.store = store
        self.healthClient = healthClient
        self.supervisor = supervisor
        self.preferences = store.load()
    }

    var windowTitle: String {
        "\(route.title) — LLM Toolkit"
    }

    var canOperateOnThread: Bool {
        route.threadID != nil
    }

    func start() {
        pollTask?.cancel()
        pollTask = Task { [weak self] in
            await self?.bootstrap()
            while let self, !Task.isCancelled {
                await self.refreshHealth()
                try? await Task.sleep(for: .seconds(3))
            }
        }
    }

    func stop() {
        pollTask?.cancel()
        pollTask = nil
        if preferences.stopServersOnQuit, startedChild, let child {
            supervisor.stop(child)
        }
    }

    func applyRoute(_ next: ConsoleRoute) {
        if route != next {
            route = next
        }
    }

    func open(_ item: SidebarItem) {
        applyRoute(item.route)
    }

    func searchFromToolbar() {
        applyRoute(.explore(query: searchText))
    }

    func reloadConsole() {
        reloadToken += 1
    }

    func revealInBrowser() {
        if let url = route.url(relativeTo: preferences.apiURL) {
            NSWorkspace.shared.open(url)
        }
    }

    func chooseToolkitRoot() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Use Folder"
        panel.message = "Select the llm-toolkit checkout (the folder that contains packages/api)."
        if let current = preferences.toolkitRootURL {
            panel.directoryURL = current
        }
        if panel.runModal() == .OK, let url = panel.url {
            preferences.toolkitRootPath = url.path
        }
    }

    func startServers() async {
        if health.isReady {
            banner = "Console is already running."
            return
        }
        isStarting = true
        lastError = nil
        defer { isStarting = false }
        do {
            if child?.isRunning == true {
                banner = "Launch already in progress."
            } else {
                child = try supervisor.start(preferences: preferences)
                startedChild = true
                banner = "Starting…"
            }
            for _ in 0..<40 {
                await refreshHealth()
                if health.isReady { break }
                try await Task.sleep(for: .milliseconds(500))
            }
            if health.isReady {
                banner = "Console ready."
                reloadConsole()
            } else {
                lastError = "Could not reach the local toolkit. Check Settings for the checkout path."
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func cloneCurrentThread() async {
        guard let id = route.threadID else { return }
        do {
            let client = ToolkitAPIClient(apiURL: preferences.apiURL)
            let result = try await client.cloneConversation(id: id)
            applyRoute(.thread(id: result.id))
            banner = "Cloned thread \(result.id)"
        } catch {
            lastError = error.localizedDescription
        }
    }

    func archiveCurrentThread() async {
        guard let id = route.threadID else { return }
        do {
            let client = ToolkitAPIClient(apiURL: preferences.apiURL)
            try await client.archiveConversation(id: id)
            banner = "Archived thread"
            applyRoute(.explore)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func rebuildIndex() async {
        do {
            let client = ToolkitAPIClient(apiURL: preferences.apiURL)
            try await client.rebuildIndex()
            banner = "Index rebuild requested"
            await refreshHealth()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func openThreadAction(_ suffix: ThreadAction) {
        guard let id = route.threadID else { return }
        switch suffix {
        case .view: applyRoute(.thread(id: id))
        case .edit: applyRoute(.threadEdit(id: id))
        case .convert: applyRoute(.threadConvert(id: id))
        case .continueSession: applyRoute(.threadContinue(id: id))
        }
    }

    private func bootstrap() async {
        await refreshHealth()
        if !health.isReady, preferences.autoStartServers {
            await startServers()
        }
    }

    func refreshHealth() async {
        health = await healthClient.probe(apiURL: preferences.apiURL)
    }
}

enum ThreadAction {
    case view
    case edit
    case convert
    case continueSession
}
