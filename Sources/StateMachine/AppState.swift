import Foundation

enum AppState: Sendable, Equatable {
    case idle
    case recording
    case processing
    case review([ProposedEntry])
    case revising([ProposedEntry])

    var label: String {
        switch self {
        case .idle: "Idle"
        case .recording: "Recording"
        case .processing: "Processing"
        case .review: "Review"
        case .revising: "Revising"
        }
    }

    var isListening: Bool {
        switch self {
        case .idle, .recording, .review, .revising: true
        case .processing: false
        }
    }

    var activePhraseHints: String {
        switch self {
        case .idle: "Say wake phrase to begin"
        case .recording: "Say end phrase to finish, or cancel phrase to abort"
        case .processing: "Processing..."
        case .review: "Say approve, revise, or cancel"
        case .revising: "Say end phrase to submit revision, or cancel"
        }
    }
}
