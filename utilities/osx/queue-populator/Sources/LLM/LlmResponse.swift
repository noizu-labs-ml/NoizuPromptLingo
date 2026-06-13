import Foundation

struct ProposedEntry: Codable, Sendable, Equatable {
    let file: String
    let type: String
    let text: String
}

struct ClassificationResponse: Codable, Sendable {
    let entries: [ProposedEntry]
    let reasoning: String?
}

struct ClassificationResult: Sendable {
    let response: ClassificationResponse
    let rawText: String
}
