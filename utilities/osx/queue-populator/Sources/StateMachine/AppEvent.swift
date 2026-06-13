import Foundation

enum AppEvent: Sendable {
    case wakeDetected
    case endDetected(transcript: String)
    case cancelDetected
    case approveDetected
    case reviseDetected
    case llmCompleted([ProposedEntry])
    case llmFailed(String)
    case writeCompleted(Int)
}
