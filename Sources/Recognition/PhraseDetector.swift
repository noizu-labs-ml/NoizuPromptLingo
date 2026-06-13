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

    private func stripPhrase(_ phrase: String, from text: String) -> String {
        text.replacingOccurrences(of: phrase, with: "", options: [.caseInsensitive])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
