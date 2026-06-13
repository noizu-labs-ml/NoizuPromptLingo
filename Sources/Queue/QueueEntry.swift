import Foundation

struct QueueEntry: Codable, Sendable {
    let ts: String
    let type: String
    let text: String
    let source: String
    let processed: Bool

    static func create(type: String, text: String, source: String = "voice") -> QueueEntry {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return QueueEntry(
            ts: formatter.string(from: Date()),
            type: type,
            text: text,
            source: source,
            processed: false
        )
    }
}
