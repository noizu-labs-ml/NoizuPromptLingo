import Foundation

enum SideEffect: Sendable {
    case startRecording
    case stopRecording
    case showMemoReview(String)
    case hideMemoReview
    case sendToLlm(transcript: String)
    case sendRevisionToLlm(original: [ProposedEntry], revision: String)
    case showReview([ProposedEntry])
    case writeEntries([ProposedEntry])
    case showOverlay(String)
    case showError(String)
    case returnToIdle
}

@MainActor
final class AppStateMachine {
    private(set) var state: AppState = .idle

    func handle(_ event: AppEvent) -> [SideEffect] {
        switch (state, event) {

        case (.idle, .wakeDetected):
            state = .recording
            return [.startRecording, .showOverlay("Recording...")]

        case (.recording, .endDetected(let transcript)):
            let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                state = .idle
                return [.stopRecording, .showOverlay("Nothing heard"), .returnToIdle]
            }
            state = .memoReview(trimmed)
            return [.stopRecording, .showOverlay("Review memo"), .showMemoReview(trimmed)]

        case (.recording, .cancelDetected):
            state = .idle
            return [.stopRecording, .showOverlay("Cancelled"), .returnToIdle]

        case (.memoReview, .memoApproved(let transcript)):
            let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                state = .idle
                return [.hideMemoReview, .showOverlay("Nothing heard"), .returnToIdle]
            }
            state = .processing
            return [.hideMemoReview, .showOverlay("Processing..."), .sendToLlm(transcript: trimmed)]

        case (.memoReview(let transcript), .approveMemoDetected):
            state = .processing
            return [.hideMemoReview, .showOverlay("Processing..."), .sendToLlm(transcript: transcript)]

        case (.memoReview, .cancelDetected):
            state = .idle
            return [.hideMemoReview, .showOverlay("Memo discarded"), .returnToIdle]

        case (.processing, .llmCompleted(let entries)):
            guard !entries.isEmpty else {
                state = .idle
                return [.showOverlay("No entries classified"), .returnToIdle]
            }
            state = .review(entries)
            return [.showReview(entries)]

        case (.processing, .llmFailed(let error)):
            state = .idle
            return [.showError(error), .returnToIdle]

        case (.review(let entries), .approveDetected):
            state = .idle
            return [.writeEntries(entries), .showOverlay("Writing \(entries.count) entries...")]

        case (.review, .reviseDetected):
            if case .review(let entries) = state {
                state = .revising(entries)
                return [.startRecording, .showOverlay("Recording revision...")]
            }
            return []

        case (.review, .cancelDetected):
            state = .idle
            return [.showOverlay("Discarded"), .returnToIdle]

        case (.revising(let entries), .endDetected(let revision)):
            let trimmed = revision.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                state = .review(entries)
                return [.stopRecording, .showOverlay("No revision heard"), .showReview(entries)]
            }
            state = .processing
            return [.stopRecording, .showOverlay("Revising..."), .sendRevisionToLlm(original: entries, revision: trimmed)]

        case (.revising(let entries), .cancelDetected):
            state = .review(entries)
            return [.stopRecording, .showOverlay("Revision cancelled"), .showReview(entries)]

        case (_, .writeCompleted(let count)):
            return [.showOverlay("Wrote \(count) entries"), .returnToIdle]

        default:
            return []
        }
    }
}
