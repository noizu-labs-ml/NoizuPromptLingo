import Foundation

@MainActor
final class PhraseDetector {
    private let phrases: PhrasesConfig
    private var firedThisCycle: Bool = false

    init(phrases: PhrasesConfig) {
        self.phrases = phrases
    }

    func reset() {
        firedThisCycle = false
    }

    func detect(in transcript: String, forState state: AppState) -> AppEvent? {
        guard !firedThisCycle else { return nil }

        let lower = transcript.lowercased()

        // Virtual-mic commands are handled while idle (not mid-memo, to avoid clobbering
        // an in-progress capture). Close is checked before open so "robot close X" isn't
        // shadowed by a substring match on "robot open".
        if state == .idle, let micEvent = detectMicCommand(in: lower) {
            firedThisCycle = true
            return micEvent
        }

        switch state {
        case .idle:
            if lower.contains(phrases.wake) {
                firedThisCycle = true
                return .wakeDetected
            }

        case .recording:
            if lower.contains(phrases.cancel) {
                firedThisCycle = true
                return .cancelDetected
            }
            if lower.contains(phrases.end) {
                firedThisCycle = true
                let cleaned = stripPhrase(phrases.end, from: transcript)
                let withoutWake = stripPhrase(phrases.wake, from: cleaned)
                return .endDetected(transcript: withoutWake)
            }

        case .memoReview:
            if lower.contains(phrases.approveMemo) {
                firedThisCycle = true
                return .approveMemoDetected
            }
            if lower.contains(phrases.cancel) {
                firedThisCycle = true
                return .cancelDetected
            }

        case .review:
            if lower.contains(phrases.approve) {
                firedThisCycle = true
                return .approveDetected
            }
            if lower.contains(phrases.revise) {
                firedThisCycle = true
                return .reviseDetected
            }
            if lower.contains(phrases.cancel) {
                firedThisCycle = true
                return .cancelDetected
            }

        case .revising:
            if lower.contains(phrases.cancel) {
                firedThisCycle = true
                return .cancelDetected
            }
            if lower.contains(phrases.end) {
                firedThisCycle = true
                let cleaned = stripPhrase(phrases.end, from: transcript)
                return .endDetected(transcript: cleaned)
            }

        case .processing:
            break
        }

        return nil
    }

    /// Matches the six fixed open/close commands against the (lowercased) transcript.
    /// Close is checked before open so the shorter "open" prefix can't shadow it.
    private func detectMicCommand(in lower: String) -> AppEvent? {
        if lower.contains(phrases.closeClaude) { return .micClose(.claude) }
        if lower.contains(phrases.closeCodex) { return .micClose(.codex) }
        if lower.contains(phrases.closeLlama) { return .micClose(.llama) }
        if lower.contains(phrases.openClaude) { return .micOpen(.claude) }
        if lower.contains(phrases.openCodex) { return .micOpen(.codex) }
        if lower.contains(phrases.openLlama) { return .micOpen(.llama) }
        return nil
    }

    private func stripPhrase(_ phrase: String, from text: String) -> String {
        text.replacingOccurrences(of: phrase, with: "", options: [.caseInsensitive])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
