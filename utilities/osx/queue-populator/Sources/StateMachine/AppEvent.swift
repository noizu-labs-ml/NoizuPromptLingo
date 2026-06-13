import Foundation

enum AppEvent: Sendable {
    case wakeDetected
    case endDetected(transcript: String)
    case approveMemoDetected
    case memoApproved(transcript: String)
    case cancelDetected
    case approveDetected
    case reviseDetected
    case llmCompleted([ProposedEntry])
    case llmFailed(String)
    case writeCompleted(Int)

    // Virtual-mic routing commands. These are independent of the memo state machine
    // and are handled directly by the Coordinator, not AppStateMachine.
    case micOpen(MicTarget)
    case micClose(MicTarget)
}
