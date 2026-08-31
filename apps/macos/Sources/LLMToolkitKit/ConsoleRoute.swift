import Foundation

/// Every route the web console implements in `packages/web/src/App.tsx`.
/// The Mac app navigates this set — it does not invent a second information architecture.
public struct ConsoleRoute: Hashable, Sendable, Codable {
    /// Path + optional query, always beginning with `/`.
    public var path: String

    public init(path: String) {
        self.path = Self.normalize(path)
    }

    public static let explore = ConsoleRoute(path: "/")
    public static let search = ConsoleRoute(path: "/search")
    public static let browse = ConsoleRoute(path: "/browse")
    public static let safetyWatch = ConsoleRoute(path: "/safety-watch")
    public static let datasets = ConsoleRoute(path: "/datasets")
    public static let prompts = ConsoleRoute(path: "/prompts")
    public static let tags = ConsoleRoute(path: "/tags")
    public static let projects = ConsoleRoute(path: "/projects")
    public static let settings = ConsoleRoute(path: "/settings")
    public static let styleGuide = ConsoleRoute(path: "/style-guides")

    public static func thread(id: String) -> ConsoleRoute {
        ConsoleRoute(path: "/thread/\(id)")
    }

    public static func threadContinue(id: String) -> ConsoleRoute {
        ConsoleRoute(path: "/thread/\(id)/continue")
    }

    public static func threadEdit(id: String) -> ConsoleRoute {
        ConsoleRoute(path: "/thread/\(id)/edit")
    }

    public static func threadConvert(id: String) -> ConsoleRoute {
        ConsoleRoute(path: "/thread/\(id)/convert")
    }

    public static func dataset(name: String) -> ConsoleRoute {
        ConsoleRoute(path: "/datasets/\(Self.encodePathSegment(name))")
    }

    public static func project(slug: String) -> ConsoleRoute {
        ConsoleRoute(path: "/projects/\(Self.encodePathSegment(slug))")
    }

    public static func styleGuide(slug: String) -> ConsoleRoute {
        ConsoleRoute(path: "/style-guides/\(Self.encodePathSegment(slug))")
    }

    public static func explore(query: String, mode: String = "fts") -> ConsoleRoute {
        var items: [URLQueryItem] = []
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            items.append(URLQueryItem(name: "q", value: trimmed))
            items.append(URLQueryItem(name: "mode", value: mode))
        }
        return ConsoleRoute(path: Self.pathByAddingQuery("/", items: items))
    }

    /// Routes that exist as first-class pages in the web SPA.
    public static let catalog: [ConsoleRoute] = [
        .explore,
        .search,
        .browse,
        .safetyWatch,
        ConsoleRoute(path: "/thread/:id"),
        ConsoleRoute(path: "/thread/:id/continue"),
        ConsoleRoute(path: "/thread/:id/edit"),
        ConsoleRoute(path: "/thread/:id/convert"),
        .datasets,
        ConsoleRoute(path: "/datasets/:name"),
        .prompts,
        .tags,
        .projects,
        ConsoleRoute(path: "/projects/:slug"),
        .settings,
        .styleGuide,
        ConsoleRoute(path: "/style-guides/:slug"),
    ]

    public var pathname: String {
        if let idx = path.firstIndex(of: "?") {
            return String(path[..<idx])
        }
        return path
    }

    public var query: String? {
        guard let idx = path.firstIndex(of: "?") else { return nil }
        let value = String(path[path.index(after: idx)...])
        return value.isEmpty ? nil : value
    }

    public var segments: [String] {
        pathname.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
    }

    public var threadID: String? {
        let segs = segments
        guard segs.first == "thread", segs.count >= 2 else { return nil }
        return segs[1]
    }

    public var isThreadFamily: Bool {
        threadID != nil
    }

    public var sidebarItem: SidebarItem {
        let segs = segments
        guard let head = segs.first else { return .explore }
        switch head {
        case "safety-watch":
            return .safetyWatch
        case "datasets":
            return .datasets
        case "prompts":
            return .prompts
        case "tags":
            return .tags
        case "projects":
            return .projects
        case "settings":
            return .settings
        case "style-guides":
            return .styleGuide
        case "search", "browse", "thread":
            return .explore
        default:
            return .explore
        }
    }

    public var title: String {
        let segs = segments
        switch segs.first {
        case nil:
            return "Explore"
        case "search":
            return "Search"
        case "browse":
            return "Browse"
        case "safety-watch":
            return "Safety Watch"
        case "datasets":
            return segs.count > 1 ? "Dataset" : "Datasets"
        case "prompts":
            return "Prompts"
        case "tags":
            return "Tags"
        case "projects":
            return segs.count > 1 ? "Project" : "Projects"
        case "settings":
            return "Settings"
        case "style-guides":
            return "Style Guide"
        case "thread":
            guard segs.count >= 3 else { return "Thread" }
            switch segs[2] {
            case "edit": return "Edit Thread"
            case "convert": return "Convert"
            case "continue": return "Continue Session"
            default: return "Thread"
            }
        default:
            return "LLM Toolkit"
        }
    }

    public func url(relativeTo base: URL) -> URL? {
        var baseString = base.absoluteString
        if baseString.hasSuffix("/") {
            baseString.removeLast()
        }
        return URL(string: baseString + path)
    }

    public static func parse(url: URL) -> ConsoleRoute {
        var path = url.path
        if path.isEmpty {
            path = "/"
        }
        if let query = url.query, !query.isEmpty {
            path += "?\(query)"
        }
        return ConsoleRoute(path: path)
    }

    public static func parse(pathFromHost raw: String) -> ConsoleRoute {
        ConsoleRoute(path: raw)
    }

    public static func normalize(_ raw: String) -> String {
        var value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty {
            return "/"
        }
        if let url = URL(string: value), let scheme = url.scheme, scheme == "http" || scheme == "https" {
            return parse(url: url).path
        }
        if !value.hasPrefix("/") {
            value = "/" + value
        }
        if value.count > 1, value.hasSuffix("/") {
            value.removeLast()
        }
        return value
    }

    private static func encodePathSegment(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? value
    }

    private static func pathByAddingQuery(_ path: String, items: [URLQueryItem]) -> String {
        guard !items.isEmpty else { return path }
        var parts = URLComponents()
        parts.queryItems = items
        guard let query = parts.percentEncodedQuery, !query.isEmpty else { return path }
        return "\(path)?\(query)"
    }
}

public enum SidebarItem: String, CaseIterable, Identifiable, Sendable {
    case explore
    case safetyWatch
    case datasets
    case prompts
    case tags
    case projects
    case settings
    case styleGuide

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .explore: return "Explore"
        case .safetyWatch: return "Safety Watch"
        case .datasets: return "Datasets"
        case .prompts: return "Prompts"
        case .tags: return "Tags"
        case .projects: return "Projects"
        case .settings: return "Settings"
        case .styleGuide: return "Style Guide"
        }
    }

    public var systemImage: String {
        switch self {
        case .explore: return "rectangle.and.text.magnifyingglass"
        case .safetyWatch: return "shield.lefthalf.filled"
        case .datasets: return "cylinder.split.1x2"
        case .prompts: return "text.badge.star"
        case .tags: return "tag"
        case .projects: return "folder"
        case .settings: return "gearshape"
        case .styleGuide: return "paintpalette"
        }
    }

    public var route: ConsoleRoute {
        switch self {
        case .explore: return .explore
        case .safetyWatch: return .safetyWatch
        case .datasets: return .datasets
        case .prompts: return .prompts
        case .tags: return .tags
        case .projects: return .projects
        case .settings: return .settings
        case .styleGuide: return .styleGuide
        }
    }

    /// Persistent sidebar groups matching `packages/web/src/components/Layout.tsx`.
    public static let primary: [SidebarItem] = [.explore, .safetyWatch]
    public static let library: [SidebarItem] = [.datasets, .prompts, .tags, .projects]
    public static let utility: [SidebarItem] = [.settings]
}
