import Foundation

public struct ToolkitLocator: Sendable {
    public var fileManager: FileManager
    public var environment: [String: String]
    public var homeDirectory: URL
    public var currentDirectory: URL
    public var extraCandidates: [URL]
    public var considerCompilationPath: Bool

    public init(
        fileManager: FileManager = .default,
        environment: [String: String] = ProcessInfo.processInfo.environment,
        homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser,
        currentDirectory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath),
        extraCandidates: [URL] = [],
        considerCompilationPath: Bool = true
    ) {
        self.fileManager = fileManager
        self.environment = environment
        self.homeDirectory = homeDirectory
        self.currentDirectory = currentDirectory
        self.extraCandidates = extraCandidates
        self.considerCompilationPath = considerCompilationPath
    }

    public func locate(explicitRoot: URL? = nil) -> URL? {
        var seen = Set<String>()
        for candidate in candidates(explicitRoot: explicitRoot) {
            let standardized = candidate.standardizedFileURL
            let key = standardized.path
            if seen.contains(key) { continue }
            seen.insert(key)
            if isToolkitRoot(standardized) {
                return standardized
            }
        }
        return nil
    }

    public func isToolkitRoot(_ url: URL) -> Bool {
        let webPackage = url.appendingPathComponent("packages/web/package.json")
        let apiPackage = url.appendingPathComponent("packages/api/package.json")
        let launcher = url.appendingPathComponent("bin/llm-toolkit")
        return fileManager.fileExists(atPath: webPackage.path)
            && fileManager.fileExists(atPath: apiPackage.path)
            && fileManager.fileExists(atPath: launcher.path)
    }

    public func candidates(explicitRoot: URL? = nil) -> [URL] {
        var urls: [URL] = []
        if let explicitRoot {
            urls.append(explicitRoot)
        }
        if let env = environment["LLM_TOOLKIT_ROOT"], !env.isEmpty {
            urls.append(URL(fileURLWithPath: (env as NSString).expandingTildeInPath))
        }
        urls.append(contentsOf: extraCandidates)
        urls.append(contentsOf: walkUp(from: currentDirectory, levels: 10))
        if considerCompilationPath {
            urls.append(contentsOf: walkUp(from: URL(fileURLWithPath: #filePath), levels: 12))
        }

        let localBin = homeDirectory
            .appendingPathComponent(".local/bin/llm-toolkit")
        if let resolved = resolveSymlink(localBin) {
            // ~/.local/bin/llm-toolkit → <root>/bin/llm-toolkit
            urls.append(resolved.deletingLastPathComponent().deletingLastPathComponent())
        }
        return urls
    }

    private func walkUp(from start: URL, levels: Int) -> [URL] {
        var urls: [URL] = []
        var current = start.standardizedFileURL
        if !current.hasDirectoryPath {
            current.deleteLastPathComponent()
        }
        for _ in 0..<levels {
            urls.append(current)
            let parent = current.deletingLastPathComponent()
            if parent.path == current.path { break }
            current = parent
        }
        return urls
    }

    private func resolveSymlink(_ url: URL) -> URL? {
        let path = url.path
        guard fileManager.fileExists(atPath: path) else { return nil }
        let resolved = url.resolvingSymlinksInPath()
        return resolved
    }
}
