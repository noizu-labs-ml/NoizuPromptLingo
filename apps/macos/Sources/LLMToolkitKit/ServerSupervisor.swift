import Foundation

public struct LaunchPlan: Equatable, Sendable {
    public var executable: URL
    public var arguments: [String]
    public var currentDirectory: URL
    public var environment: [String: String]

    public init(
        executable: URL,
        arguments: [String],
        currentDirectory: URL,
        environment: [String: String]
    ) {
        self.executable = executable
        self.arguments = arguments
        self.currentDirectory = currentDirectory
        self.environment = environment
    }
}

public enum ServerSupervisorError: LocalizedError, Equatable {
    case toolkitRootNotFound
    case alreadyRunning
    case launchFailed(String)

    public var errorDescription: String? {
        switch self {
        case .toolkitRootNotFound:
            return "Could not find the llm-toolkit checkout. Set the toolkit root in Settings or install the llm-toolkit launcher."
        case .alreadyRunning:
            return "Already running."
        case .launchFailed(let message):
            return message
        }
    }
}

public struct ServerSupervisor: Sendable {
    public var locator: ToolkitLocator
    public var shellURL: URL
    public var pathEnvironment: [String: String]

    public init(
        locator: ToolkitLocator = ToolkitLocator(),
        shellURL: URL = URL(fileURLWithPath: "/bin/zsh"),
        pathEnvironment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        self.locator = locator
        self.shellURL = shellURL
        self.pathEnvironment = pathEnvironment
    }

    public func resolveRoot(preferences: AppPreferences) -> URL? {
        locator.locate(explicitRoot: preferences.toolkitRootURL)
    }

    public func makeLaunchPlan(preferences: AppPreferences) throws -> LaunchPlan {
        guard let root = resolveRoot(preferences: preferences) else {
            throw ServerSupervisorError.toolkitRootNotFound
        }
        let quoted = shellQuote(root.path)
        let script = "cd \(quoted) && if [ ! -f packages/web/dist/index.html ]; then pnpm --filter @llm-toolkit/web build; fi && pnpm dev:api"
        var environment = pathEnvironment
        if environment["PORT"] == nil {
            environment["PORT"] = "\(preferences.apiURL.port ?? 3100)"
        }
        return LaunchPlan(
            executable: shellURL,
            arguments: ["-lc", script],
            currentDirectory: root,
            environment: environment
        )
    }

    public func start(preferences: AppPreferences) throws -> Process {
        let plan = try makeLaunchPlan(preferences: preferences)
        let process = Process()
        process.executableURL = plan.executable
        process.arguments = plan.arguments
        process.currentDirectoryURL = plan.currentDirectory
        process.environment = plan.environment
        process.standardOutput = logFileHandle()
        process.standardError = process.standardOutput
        do {
            try process.run()
        } catch {
            throw ServerSupervisorError.launchFailed(error.localizedDescription)
        }
        return process
    }

    public func stop(_ process: Process) {
        guard process.isRunning else { return }
        process.terminate()
        let deadline = Date().addingTimeInterval(2)
        while process.isRunning, Date() < deadline {
            Thread.sleep(forTimeInterval: 0.05)
        }
        if process.isRunning {
            process.interrupt()
        }
    }

    private func logFileHandle() -> FileHandle? {
        let logs = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/LLMToolkit", isDirectory: true)
        try? FileManager.default.createDirectory(at: logs, withIntermediateDirectories: true)
        let file = logs.appendingPathComponent("console.log")
        if !FileManager.default.fileExists(atPath: file.path) {
            FileManager.default.createFile(atPath: file.path, contents: nil)
        }
        return try? FileHandle(forWritingTo: file)
    }

    public func shellQuote(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
