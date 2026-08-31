import Foundation

/// Matches `AgentHarness` in `packages/web/src/context/HarnessContext.tsx`.
public enum Harness: String, CaseIterable, Identifiable, Sendable, Codable {
    case claude
    case codex
    case gemini
    case other

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .claude: return "Claude"
        case .codex: return "Codex"
        case .gemini: return "Gemini"
        case .other: return "Other"
        }
    }

    public static func parse(_ raw: String?) -> Harness? {
        guard let raw else { return nil }
        return Harness(rawValue: raw)
    }
}
