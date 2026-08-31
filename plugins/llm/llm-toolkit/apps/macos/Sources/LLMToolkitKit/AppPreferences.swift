import Foundation

public struct AppPreferences: Equatable, Sendable, Codable {
    public var apiURL: URL
    public var toolkitRootPath: String
    public var autoStartServers: Bool
    public var stopServersOnQuit: Bool
    public var useNativeChrome: Bool

    public static let defaultAPIURL = URL(string: "http://localhost:3100")!

    public init(
        apiURL: URL = defaultAPIURL,
        toolkitRootPath: String = "",
        autoStartServers: Bool = true,
        stopServersOnQuit: Bool = false,
        useNativeChrome: Bool = true
    ) {
        self.apiURL = apiURL
        self.toolkitRootPath = toolkitRootPath
        self.autoStartServers = autoStartServers
        self.stopServersOnQuit = stopServersOnQuit
        self.useNativeChrome = useNativeChrome
    }

    public var toolkitRootURL: URL? {
        let trimmed = toolkitRootPath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return URL(fileURLWithPath: (trimmed as NSString).expandingTildeInPath)
    }
}

public protocol PreferenceStore: Sendable {
    func load() -> AppPreferences
    func save(_ preferences: AppPreferences)
}

public struct UserDefaultsPreferenceStore: PreferenceStore, Sendable {
    public static let suiteName = "com.noizu.llm-toolkit"

    private enum Key {
        static let apiURL = "apiURL"
        static let toolkitRootPath = "toolkitRootPath"
        static let autoStartServers = "autoStartServers"
        static let stopServersOnQuit = "stopServersOnQuit"
        static let useNativeChrome = "useNativeChrome"
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = UserDefaults(suiteName: suiteName) ?? .standard) {
        self.defaults = defaults
    }

    public func load() -> AppPreferences {
        var prefs = AppPreferences()
        if let raw = defaults.string(forKey: Key.apiURL), let url = URL(string: raw) {
            prefs.apiURL = url
        }
        prefs.toolkitRootPath = defaults.string(forKey: Key.toolkitRootPath) ?? ""
        if defaults.object(forKey: Key.autoStartServers) != nil {
            prefs.autoStartServers = defaults.bool(forKey: Key.autoStartServers)
        }
        if defaults.object(forKey: Key.stopServersOnQuit) != nil {
            prefs.stopServersOnQuit = defaults.bool(forKey: Key.stopServersOnQuit)
        }
        if defaults.object(forKey: Key.useNativeChrome) != nil {
            prefs.useNativeChrome = defaults.bool(forKey: Key.useNativeChrome)
        }
        return prefs
    }

    public func save(_ preferences: AppPreferences) {
        defaults.set(preferences.apiURL.absoluteString, forKey: Key.apiURL)
        defaults.set(preferences.toolkitRootPath, forKey: Key.toolkitRootPath)
        defaults.set(preferences.autoStartServers, forKey: Key.autoStartServers)
        defaults.set(preferences.stopServersOnQuit, forKey: Key.stopServersOnQuit)
        defaults.set(preferences.useNativeChrome, forKey: Key.useNativeChrome)
    }
}

public final class InMemoryPreferenceStore: PreferenceStore, @unchecked Sendable {
    private let lock = NSLock()
    private var value: AppPreferences

    public init(_ value: AppPreferences = AppPreferences()) {
        self.value = value
    }

    public func load() -> AppPreferences {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    public func save(_ preferences: AppPreferences) {
        lock.lock()
        value = preferences
        lock.unlock()
    }
}
